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

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== C 端接单接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    error_log('请求方法错误: ' . $_SERVER['REQUEST_METHOD']);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 记录请求体
try {
    $requestBody = file_get_contents('php://input');
    error_log('请求体: ' . $requestBody);
} catch (Exception $e) {
    error_log('读取请求体失败: ' . $e->getMessage());
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    error_log('数据库连接失败: ' . $e->getMessage());
    Response::error('数据库连接失败', $errorCodes['DATABASE_ERROR'], 500);
}

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    error_log('用户认证成功，用户ID: ' . $currentUser['user_id']);
} catch (Exception $e) {
    error_log('用户认证失败: ' . $e->getMessage());
    Response::error('认证失败', $errorCodes['AUTH_FAILED'], 401);
}

// 1. 校验最后一次接单时间，需间隔3分钟（放在最前面）
$requestLogger->debug('校验最后一次接单时间');
$stmt = $db->prepare("SELECT accept_task_update_at FROM c_user_task_records_static WHERE user_id = ?");
$stmt->execute([$currentUser['user_id']]);
$staticRecord = $stmt->fetch(PDO::FETCH_ASSOC);

if ($staticRecord && !empty($staticRecord['accept_task_update_at'])) {
    // 转换为时间戳进行准确比较
    $lastAcceptTime = strtotime($staticRecord['accept_task_update_at']);
    $currentTime = time();
    $timeDiff = $currentTime - $lastAcceptTime;
    error_log('最后接单时间: ' . $staticRecord['accept_task_update_at'] . '，时间差: ' . $timeDiff . '秒');
    
    if ($timeDiff < 180) { // 3分钟 = 180秒
        error_log('接单间隔不足3分钟，禁止接单');
        Response::error('请稍后再试，接单间隔需至少3分钟', 9012);
    }
}
$requestLogger->debug('接单间隔符合要求');

// 查询用户封禁状态和新手状态
error_log('查询用户封禁状态和新手状态，用户ID: ' . $currentUser['user_id']);
$stmt = $db->prepare(" 
    SELECT blocked_status, blocked_start_time, blocked_duration, blocked_end_time, is_newbie 
    FROM c_users 
    WHERE id = ?
");
$stmt->execute([$currentUser['user_id']]);
$userInfo = $stmt->fetch(PDO::FETCH_ASSOC);

// 获取用户新手状态
$isNewbie = (int)($userInfo['is_newbie'] ?? 1);
error_log('用户新手状态: ' . $isNewbie);

// 根据新手状态选择任务表
$taskTable = $isNewbie ? 'b_newbie_tasks' : 'b_tasks';
error_log('选择任务表: ' . $taskTable);

// 检查封禁状态
if ($userInfo) {
    error_log('用户封禁状态: ' . $userInfo['blocked_status']);
    if ($userInfo['blocked_status'] == 2) {
        $endTime = $userInfo['blocked_end_time'] ?? null;
        $message = '账号已被禁止登录';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        error_log('用户被禁止登录: ' . $message);
        Response::error($message, $errorCodes['AUTH_ACCOUNT_BLOCKED']);
        exit;
    } 
    if ($userInfo['blocked_status'] == 1) {
        $endTime = $userInfo['blocked_end_time'] ?? null;
        $message = '账号已被禁止接单';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        $auditLogger->notice('用户被禁止接单', ['message' => $message]);
        Response::error($message, $errorCodes['TASK_ACCEPT_BLOCKED']);
        exit;
    }
}

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
error_log('获取到任务ID: ' . $bTaskId);

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    error_log('任务ID为空或无效: ' . $bTaskId);
    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}

try {
    // 2. 校验用户是否有进行中的任务
    error_log('校验用户是否有进行中的任务，用户ID: ' . $currentUser['user_id']);
    $stmt = $db->prepare(" 
        SELECT id FROM c_task_records 
        WHERE c_user_id = ? AND status = 1
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        $auditLogger->notice('用户有进行中任务，禁止接单');
        Response::error('您当前有进行中的任务，请先完成或提交后再接新任务', $errorCodes['TASK_ACCEPT_ALREADY_DOING']);
    }
    $requestLogger->debug('无进行中任务');
    
    // 3. 校验是否已接过该任务（包括超时记录，status=5）
    error_log('校验用户是否已接过该任务，任务ID: ' . $bTaskId);
    $stmt = $db->prepare(" 
        SELECT id FROM c_task_records
        WHERE c_user_id = ? AND b_task_id = ?
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id'], $bTaskId]);
    if ($stmt->fetch()) {
        $auditLogger->notice('用户重复接单被拒');
        Response::error('您已接过该任务，不能重复接单', $errorCodes['TASK_ACCEPT_ALREADY_ACCEPTED']);
    }
    $requestLogger->debug('非重复接单');
    
    // 4. 查询或创建当日统计记录
    $today = date('Y-m-d');
    error_log('查询当日统计记录，用户ID: ' . $currentUser['user_id'] . '，日期: ' . $today);
    $stmt = $db->prepare(" 
        SELECT id, rejected_count, approved_count, abandon_count 
        FROM c_user_daily_stats 
        WHERE c_user_id = ? AND stat_date = ?
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$dailyStats) {
        // 创建当日统计记录
        $requestLogger->debug('创建当日统计记录');
        $stmt = $db->prepare(" 
            INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, rejected_count, submit_count, abandon_count, approved_count)
            VALUES (?, ?, 0, 0, 0, 0, 0)
        ");
        $stmt->execute([$currentUser['user_id'], $today]);
        $dailyStatsId = $db->lastInsertId();
        $rejectedCount = 0;
        $requestLogger->debug('当日统计创建成功', ['id' => $dailyStatsId]);
    } else {
        $dailyStatsId = $dailyStats['id'];
        $rejectedCount = (int)$dailyStats['rejected_count'];
        $approvedCount = (int)$dailyStats['approved_count'];
        $abandonCount = (int)$dailyStats['abandon_count'];
        $requestLogger->debug('当日统计已存在', ['id' => $dailyStatsId, 'rejected' => $rejectedCount, 'approved' => $approvedCount, 'abandon' => $abandonCount]);
    }
    
    // 5. 校验当日驳回次数
    if ($rejectedCount >= 3) {
        $auditLogger->notice('用户驳回次数超限', ['rejected_count' => $rejectedCount]);
        Response::error('您今日已被驳回 3 次，暂时无法接单，请明天再试', $errorCodes['TASK_ACCEPT_REJECT_LIMIT']);
    }
    $requestLogger->debug('驳回次数未超限');
    
    // 6. 校验当日弃单次数（弃单 4 次后不能再接单）
    $requestLogger->debug('用户弃单次数', ['abandon_count' => $abandonCount]);
    if ($abandonCount >= 4) {
        $auditLogger->notice('用户弃单次数超限', ['abandon_count' => $abandonCount]);
        Response::error('您今日已弃单超过 4 次，暂时无法接单，请明天再试', $errorCodes['TASK_ACCEPT_REJECT_LIMIT']);
    }
    $requestLogger->debug('弃单次数未超限');
    
    // 5. 查询任务信息
    error_log('查询任务信息，任务ID: ' . $bTaskId);
    $stmt = $db->prepare(" 
        SELECT 
            id, b_user_id, template_id, video_url, deadline, 
            recommend_marks, task_count, task_done, task_doing, task_reviewing, 
            unit_price, stage, stage_status, status, combo_task_id
        FROM $taskTable 
        WHERE id = ?
    ");
    $stmt->execute([$bTaskId]);
    $bTask = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bTask) {
        error_log('任务不存在，任务ID: ' . $bTaskId);
        Response::error('任务不存在', $errorCodes['TASK_NOT_FOUND']);
    }
    error_log('任务信息查询成功，任务ID: ' . $bTask['id']);

    // 6. 校验组合任务：同一combo_task_id下，同一用户只能接一次
    $comboTaskId = $bTask['combo_task_id'];
    if (!empty($comboTaskId)) {
        $requestLogger->debug('校验组合任务', ['combo_task_id' => $comboTaskId]);
        $stmt = $db->prepare(" 
            SELECT ctr.id FROM c_task_records ctr
            INNER JOIN $taskTable bt ON bt.id = ctr.b_task_id
            WHERE ctr.c_user_id = ? AND bt.combo_task_id = ?
            LIMIT 1
        ");
        $stmt->execute([$currentUser['user_id'], $comboTaskId]);
        if ($stmt->fetch()) {
            $auditLogger->notice('用户重复接组合任务被拒');
            Response::error('您已接过该组合任务，不能重复接单', $errorCodes['TASK_ACCEPT_ALREADY_ACCEPTED']);
        }
        $requestLogger->debug('非重复接组合任务');
    }

    // 7. 校验任务是否开放
    $requestLogger->debug('校验任务开放状态', ['stage_status' => $bTask['stage_status']]);
    if ((int)$bTask['stage_status'] !== 1) {
        $auditLogger->notice('任务未开放');
        Response::error('该任务暂未开放，无法接单', $errorCodes['TASK_NOT_OPEN']);
    }
    $requestLogger->debug('任务已开放');
    
    // 8. 校验任务状态
    $requestLogger->debug('校验任务状态', ['status' => $bTask['status']]);
    if ((int)$bTask['status'] !== 1) {
        $auditLogger->notice('任务已结束');
        Response::error('该任务已结束，无法接单', $errorCodes['TASK_NOT_FOUND']);
    }
    $requestLogger->debug('任务状态正常');
    
    // 8. 校验任务剩余数量
    $taskDone = (int)$bTask['task_done'];
    $taskDoing = (int)$bTask['task_doing'];
    $taskReviewing = (int)$bTask['task_reviewing'];
    $taskCount = (int)$bTask['task_count'];
    $remainingCount = $taskCount - $taskDone - $taskDoing - $taskReviewing;
    error_log('任务剩余数量: ' . $remainingCount . '，总数量: ' . $taskCount . '，已完成: ' . $taskDone . '，进行中: ' . $taskDoing . '，待审核: ' . $taskReviewing);
    
    if ($remainingCount <= 0) {
        $auditLogger->notice('任务无剩余名额');
        Response::error('该任务已无剩余名额，无法接单', $errorCodes['TASK_ACCEPT_NO_STOCK']);
    }
    $requestLogger->debug('任务有剩余名额');
    
    // 9. 解析推荐评论，分配一个给当前用户
    $requestLogger->debug('解析推荐评论');
    $recommendMarks = json_decode($bTask['recommend_marks'], true);
    if (!is_array($recommendMarks) || empty($recommendMarks)) {
        $recommendMark = null;
        $requestLogger->debug('无推荐评论');
    } else {
        // 随机分配一个推荐评论（也可以按顺序分配）
        $recommendMark = $recommendMarks[array_rand($recommendMarks)];
        $requestLogger->debug('推荐评论分配成功');
    }
    
    // 10. 开启事务
    $requestLogger->debug('开启数据库事务');
    $db->beginTransaction();
    
    // 11. 查询模板佣金配置，计算reward_amount
    error_log('查询模板佣金配置，模板ID: ' . $bTask['template_id']);
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
    error_log('计算佣金，阶段: ' . $stage . '，佣金: ' . $rewardAmount . '分');

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
    error_log('任务阶段: ' . $taskStage . '，阶段文本: ' . $taskStageText);
    
    // 12. 插入C端任务记录
    error_log('插入C端任务记录');
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
    error_log('C端任务记录插入成功，记录ID: ' . $recordId);
    
    // 12. 更新 B 端任务进行中数量（先查询再计算，避免 UNSIGNED 溢出）
    $requestLogger->debug('查询任务 task_doing', ['b_task_id' => $bTaskId]);
    $stmt = $db->prepare("SELECT task_doing FROM $taskTable WHERE id = ?");
    $stmt->execute([$bTaskId]);
    $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
    $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
    $newTaskDoing = $currentTaskDoing + 1;
    $requestLogger->debug('计算 task_doing', ['current' => $currentTaskDoing, 'new' => $newTaskDoing]);
    
    $requestLogger->debug('更新 B 端任务 doing 数量', ['b_task_id' => $bTaskId, 'new_doing' => $newTaskDoing]);
    $stmt = $db->prepare(" 
        UPDATE $taskTable 
        SET task_doing = ?
        WHERE id = ?
    ");
    $stmt->execute([$newTaskDoing, $bTaskId]);
    $requestLogger->debug('B 端任务更新成功');
    
    // 13. 更新当日接单统计
    error_log('更新当日接单统计，统计ID: ' . $dailyStatsId);
    $stmt = $db->prepare(" 
        UPDATE c_user_daily_stats 
        SET accept_count = accept_count + 1 
        WHERE id = ?
    ");
    $stmt->execute([$dailyStatsId]);
    $requestLogger->debug('接单统计更新成功');
    
    // 14. 更新用户任务静态记录的最后接单时间
    $requestLogger->debug('更新用户静态记录');
    $currentDatetime = date('Y-m-d H:i:s');
    // 先尝试更新，如果不存在则插入
    $stmt = $db->prepare("UPDATE c_user_task_records_static SET accept_task_update_at = ? WHERE user_id = ?");
    $result = $stmt->execute([$currentDatetime, $currentUser['user_id']]);
    
    // 如果更新失败（记录不存在），则插入新记录
    if ($result === false || $stmt->rowCount() === 0) {
        $requestLogger->debug('创建用户静态记录');
        $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, accept_task_update_at) VALUES (?, ?)");
        $stmt->execute([$currentUser['user_id'], $currentDatetime]);
    }
    $requestLogger->debug('用户静态记录更新成功');
    
    // 15. 提交事务
    $requestLogger->debug('提交数据库事务');
    $db->commit();
    $requestLogger->debug('事务提交成功');
    
    // 16. 返回成功响应
    error_log('接单成功，返回响应，记录ID: ' . $recordId);
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
        $errorLogger->error('事务回滚', ['exception' => 'PDOException']);
        $db->rollBack();
    }
    
    error_log('PDO异常: ' . $e->getMessage());
    error_log('异常文件: ' . $e->getFile());
    error_log('异常行号: ' . $e->getLine());
    Response::error('接单失败', $errorCodes['TASK_ACCEPT_FAILED'], 500);
}
