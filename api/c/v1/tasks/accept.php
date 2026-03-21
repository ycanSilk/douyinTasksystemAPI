<?php
/**
 * C端接单接口
 * 
 * POST /api/c/v1/tasks/accept
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 请求体：
 * {
 *   "b_task_id": 123
 * }
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "接单成功",
 *   "data": {
 *     "record_id": 1,
 *     "b_task_id": 123,
 *     "video_url": "https://example.com/video",
 *     "recommend_mark": {
 *       "comment": "这个产品不错",
 *       "image_url": "http://..."
 *     },
 *     "reward_amount": "4.00",
 *     "deadline": 1736524800,
 *     "status": 1,
 *     "status_text": "进行中"
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 接单规则：
 * 1. 一个C端用户同一时间只能有1条doing状态任务
 * 2. 同一个b_tasks id，每个C用户只能接一次（组合任务内同一用户只能接一次，接了阶段1就不能接阶段2）
 * 3. 如果用户当日rejected_count >= 3，则禁止接单
 * 4. 如果任务剩余数量 <= 0，则禁止接单
 * 5. 只能接开放状态的任务（stage_status=1）
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 查询用户封禁状态
$stmt = $db->prepare(" 
    SELECT blocked_status, blocked_start_time, blocked_duration, blocked_end_time 
    FROM c_users 
    WHERE id = ?
");
$stmt->execute([$currentUser['user_id']]);
$userInfo = $stmt->fetch(PDO::FETCH_ASSOC);

// 检查封禁状态
if ($userInfo) {
    if ($userInfo['blocked_status'] == 2) {
        $endTime = $userInfo['blocked_end_time'] ?? null;
        $message = '账号已被禁止登录';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        Response::error($message, $errorCodes['AUTH_ACCOUNT_BLOCKED']);
    } 
    if ($userInfo['blocked_status'] == 1) {
        $endTime = $userInfo['blocked_end_time'] ?? null;
        $message = '账号已被禁止接单';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        Response::error($message, $errorCodes['TASK_ACCEPT_BLOCKED']);
    }
}

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}

try {
    // 1. 校验用户是否有进行中的任务
    $stmt = $db->prepare("
        SELECT id FROM c_task_records 
        WHERE c_user_id = ? AND status = 1
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        Response::error('您当前有进行中的任务，请先完成或提交后再接新任务', $errorCodes['TASK_ACCEPT_ALREADY_DOING']);
    }
    
    // 2. 校验是否已接过该任务（包括超时记录，status=5）
    $stmt = $db->prepare("
        SELECT id FROM c_task_records
        WHERE c_user_id = ? AND b_task_id = ?
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id'], $bTaskId]);
    if ($stmt->fetch()) {
        Response::error('您已接过该任务，不能重复接单', $errorCodes['TASK_ACCEPT_ALREADY_ACCEPTED']);
    }
    
    // 3. 查询或创建当日统计记录
    $today = date('Y-m-d');
    $stmt = $db->prepare("
        SELECT id, rejected_count 
        FROM c_user_daily_stats 
        WHERE c_user_id = ? AND stat_date = ?
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$dailyStats) {
        // 创建当日统计记录
        $stmt = $db->prepare("
            INSERT INTO c_user_daily_stats (c_user_id, stat_date)
            VALUES (?, ?)
        ");
        $stmt->execute([$currentUser['user_id'], $today]);
        $dailyStatsId = $db->lastInsertId();
        $rejectedCount = 0;
    } else {
        $dailyStatsId = $dailyStats['id'];
        $rejectedCount = (int)$dailyStats['rejected_count'];
    }
    
    // 4. 校验当日驳回次数
    if ($rejectedCount >= 3) {
        Response::error('您今日已被驳回3次，暂时无法接单，请明天再试', $errorCodes['TASK_ACCEPT_REJECT_LIMIT']);
    }
    
    // 5. 校验当日弃单次数
    $abandonCount = (int)($dailyStats['abandon_count'] ?? 0);
    if ($abandonCount > 3) {
        Response::error('您今日已弃单超过3次，暂时无法接单，请明天再试', $errorCodes['TASK_ACCEPT_REJECT_LIMIT']);
    }
    
    // 6. 校验最后一次接单时间，需间隔3分钟
    $stmt = $db->prepare("SELECT accept_task_update_at FROM c_user_task_records_static WHERE user_id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $staticRecord = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($staticRecord && isset($staticRecord['accept_task_update_at'])) {
        $lastAcceptTime = strtotime($staticRecord['accept_task_update_at']);
        $currentTime = time();
        $timeDiff = $currentTime - $lastAcceptTime;
        
        if ($timeDiff < 180) { // 3分钟 = 180秒
            Response::error('请稍后再试，接单间隔需至少3分钟', $errorCodes['TASK_ACCEPT_FREQUENCY_LIMIT']);
        }
    }
    
    // 5. 查询任务信息
    $stmt = $db->prepare("
        SELECT
            id, b_user_id, template_id, video_url, deadline,
            recommend_marks, task_count, task_done, task_doing, task_reviewing,
            unit_price, stage, stage_status, status, combo_task_id
        FROM b_tasks 
        WHERE id = ?
    ");
    $stmt->execute([$bTaskId]);
    $bTask = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bTask) {
        Response::error('任务不存在', $errorCodes['TASK_NOT_FOUND']);
    }

    // 6. 校验组合任务：同一combo_task_id下，同一用户只能接一次
    $comboTaskId = $bTask['combo_task_id'];
    if (!empty($comboTaskId)) {
        $stmt = $db->prepare("
            SELECT ctr.id FROM c_task_records ctr
            INNER JOIN b_tasks bt ON bt.id = ctr.b_task_id
            WHERE ctr.c_user_id = ? AND bt.combo_task_id = ?
            LIMIT 1
        ");
        $stmt->execute([$currentUser['user_id'], $comboTaskId]);
        if ($stmt->fetch()) {
            Response::error('您已接过该组合任务，不能重复接单', $errorCodes['TASK_ACCEPT_ALREADY_ACCEPTED']);
        }
    }

    // 7. 校验任务是否开放
    if ((int)$bTask['stage_status'] !== 1) {
        Response::error('该任务暂未开放，无法接单', $errorCodes['TASK_NOT_OPEN']);
    }
    
    // 8. 校验任务状态
    if ((int)$bTask['status'] !== 1) {
        Response::error('该任务已结束，无法接单', $errorCodes['TASK_NOT_FOUND']);
    }
    
    // 8. 校验任务剩余数量
    $taskDone = (int)$bTask['task_done'];
    $taskDoing = (int)$bTask['task_doing'];
    $taskReviewing = (int)$bTask['task_reviewing'];
    $taskCount = (int)$bTask['task_count'];
    $remainingCount = $taskCount - $taskDone - $taskDoing - $taskReviewing;
    
    if ($remainingCount <= 0) {
        Response::error('该任务已无剩余名额，无法接单', $errorCodes['TASK_ACCEPT_NO_STOCK']);
    }
    
    // 9. 解析推荐评论，分配一个给当前用户
    $recommendMarks = json_decode($bTask['recommend_marks'], true);
    if (!is_array($recommendMarks) || empty($recommendMarks)) {
        $recommendMark = null;
    } else {
        // 随机分配一个推荐评论（也可以按顺序分配）
        $recommendMark = $recommendMarks[array_rand($recommendMarks)];
    }
    
    // 10. 开启事务
    $db->beginTransaction();
    
    // 11. 查询模板佣金配置，计算reward_amount
    $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
    $stmt->execute([$bTask['template_id']]);
    $template = $stmt->fetch(PDO::FETCH_ASSOC);

    $stage = (int)($bTask['stage'] ?? 0);
    if ($stage === 1) {
        $rewardAmount = (int)($template['stage1_c_user_commission'] ?? 0);
    } elseif ($stage === 2) {
        $rewardAmount = (int)($template['stage2_c_user_commission'] ?? 0);
    } else {
        $rewardAmount = (int)($template['c_user_commission'] ?? 0);
    }

    // 计算任务阶段和阶段文本
    $taskStage = (int)$bTask['stage'];
    $taskStageText = '';
    
    $templateId = (int)$bTask['template_id'];
    
    // 如果是单任务（stage为0），使用模板标题作为task_stage_text
    if ($taskStage === 0) {
        $taskStageText = $template['title'] ?? '';
    } else {
        // 多阶段任务
        switch ($templateId) {
            case 1:
                $taskStageText = '上评评论';
                break;
            case 2:
                $taskStageText = '中评评论';
                break;
            case 3:
                $taskStageText = '放大镜搜索词';
                break;
            case 4:
                if ($taskStage === 1) {
                    $taskStageText = '上评评论';
                } elseif ($taskStage === 2) {
                    $taskStageText = '中评评论';
                }
                break;
            case 5:
                if ($taskStage === 1) {
                    $taskStageText = '中评评论';
                } elseif ($taskStage === 2) {
                    $taskStageText = '下评评论';
                }
                break;
        }
    }
    
    // 12. 插入C端任务记录
    $stmt = $db->prepare("
        INSERT INTO c_task_records (
            c_user_id, b_task_id, b_user_id, template_id,
            video_url, recommend_mark, reward_amount, status, task_stage, task_stage_text
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
    ");
    $stmt->execute([
        $currentUser['user_id'],
        $bTaskId,
        $bTask['b_user_id'],
        $bTask['template_id'],
        $bTask['video_url'],
        json_encode($recommendMark, JSON_UNESCAPED_UNICODE),
        $rewardAmount,
        $taskStage,
        $taskStageText
    ]);
    $recordId = $db->lastInsertId();
    
    // 12. 更新B端任务进行中数量
    $stmt = $db->prepare("
        UPDATE b_tasks 
        SET task_doing = task_doing + 1 
        WHERE id = ?
    ");
    $stmt->execute([$bTaskId]);
    
    // 13. 更新当日接单统计
    $stmt = $db->prepare("
        UPDATE c_user_daily_stats 
        SET accept_count = accept_count + 1 
        WHERE id = ?
    ");
    $stmt->execute([$dailyStatsId]);
    
    // 14. 更新用户任务静态记录的最后接单时间
    $currentDatetime = date('Y-m-d H:i:s');
    $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, accept_task_update_at) VALUES (?, ?) ON DUPLICATE KEY UPDATE accept_task_update_at = ?");
    $stmt->execute([$currentUser['user_id'], $currentDatetime, $currentDatetime]);
    
    // 15. 提交事务
    $db->commit();
    
    // 16. 返回成功响应
    Response::success([
        'record_id' => (int)$recordId,
        'b_task_id' => (int)$bTaskId,
        'video_url' => $bTask['video_url'],
        'recommend_mark' => $recommendMark,
        'reward_amount' => number_format($rewardAmount / 100, 2),
        'deadline' => (int)$bTask['deadline'],
        'status' => 1,
        'status_text' => '进行中',
        'task_stage' => $taskStage,
        'task_stage_text' => $taskStageText
    ], '接单成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('接单失败', $errorCodes['TASK_ACCEPT_FAILED'], 500);
}
