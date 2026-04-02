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
 * 3. 如果用户当日rejected_count >= 6，则禁止接单
 * 4. 如果用户当日abandon_count >= 6，则禁止接单
 * 5. 如果任务剩余数量 <= 0，则禁止接单
 * 6. 只能接开放状态的任务（stage_status=1）
 *
 * 错误码说明：
 * 1001  - 请求方法错误
 * 1002  - 数据库错误
 * 2001  - Token无效
 * 2002  - Token过期
 * 4002  - 任务不存在或已结束
 * 4003  - 权限不足
 * 4005  - 任务未开放
 * 5000  - 系统错误
 * 9000  - 您当前有进行中的任务，请先完成或提交后再接新任务
 * 9001  - 您已接过该任务，不能重复接单
 * 9002  - 您今日已被驳回6次，暂时无法接单，请明天再试
 * 9003  - 您今日已弃单超过6次，暂时无法接单，请明天再试
 * 9004  - 接单失败
 * 9005  - 该任务暂未开放，无法接单
 * 9011  - 账号已被禁止接单
 * 9013  - 该任务已无剩余名额，无法接单
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/tasks/accept');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C端接单接口请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户接单失败：请求方法错误', [
        'reason' => '请求方法错误',
    ]);

    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$requestLogger->debug('读取请求体');
$requestBody = file_get_contents('php://input');
$requestLogger->debug('请求体内容', ['body' => $requestBody]);

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
    
    // 从 app_config 表获取弃单次数和驳回次数限制
    require_once __DIR__ . '/../../../../core/AppConfig.php';
    $abandonCountLimit = AppConfig::get('abandon_count', 6); // 默认值为 6
    $rejectedCountLimit = AppConfig::get('rejected_count', 6); // 默认值为 6
    $requestLogger->debug('获取配置限制', [
        'abandon_count_limit' => $abandonCountLimit,
        'rejected_count_limit' => $rejectedCountLimit
    ]);
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C 端用户接单失败：数据库连接失败', [
        'exception' => $e->getMessage(),
        'reason' => '数据库连接失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => $errorCodes['DATABASE_ERROR'],
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token认证失败', ['exception' => $e->getMessage()]);

    $auditLogger->warning('C端用户接单失败：Token认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token认证失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => $errorCodes['AUTH_TOKEN_INVALID'] ?? 2001,
        'message' => '认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$requestLogger->debug('查询用户封禁状态', ['user_id' => $currentUser['user_id']]);
$stmt = $db->prepare("
    SELECT blocked_status, blocked_start_time, blocked_duration, blocked_end_time
    FROM c_users
    WHERE id = ?
");
$stmt->execute([$currentUser['user_id']]);
$userInfo = $stmt->fetch(PDO::FETCH_ASSOC);

$taskTable = 'b_tasks';
$requestLogger->debug('从b_tasks表获取任务');

if ($userInfo) {
    $requestLogger->debug('用户封禁状态', ['blocked_status' => $userInfo['blocked_status']]);
    if ($userInfo['blocked_status'] == 2) {
        $endTime = $userInfo['blocked_end_time'] ?? null;
        $message = '账号已被禁止登录';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        $errorLogger->warning('用户被禁止登录', ['message' => $message]);

        $auditLogger->warning('C端用户接单失败：账号被禁止登录', [
            'user_id' => $currentUser['user_id'],
            'blocked_end_time' => $endTime,
        ]);

        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error($message, $errorCodes['AUTH_ACCOUNT_BLOCKED']);
    }
    if ($userInfo['blocked_status'] == 1) {
        $endTime = $userInfo['blocked_end_time'] ?? null;
        $message = '账号已被禁止接单';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        $errorLogger->warning('用户被禁止接单', ['message' => $message]);

        $auditLogger->warning('C端用户接单失败：账号被禁止接单', [
            'user_id' => $currentUser['user_id'],
            'blocked_end_time' => $endTime,
        ]);

        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error($message, $errorCodes['TASK_ACCEPT_BLOCKED']);
    }
}

$requestLogger->info('移除接单冷却时间限制，跳过接单间隔检查');

$input = json_decode($requestBody, true);
$bTaskId = $input['b_task_id'] ?? 0;
$requestLogger->debug('获取任务ID', ['b_task_id' => $bTaskId]);

if (empty($bTaskId) || !is_numeric($bTaskId)) {
    $requestLogger->warning('任务ID为空或无效', ['b_task_id' => $bTaskId]);
    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}

try {
    $requestLogger->debug('校验用户是否有进行中的任务', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("
        SELECT id FROM c_task_records
        WHERE c_user_id = ? AND status = 1
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        $auditLogger->notice('C端用户接单失败：有进行中任务', [
            'user_id' => $currentUser['user_id'],
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('您当前有进行中的任务，请先完成或提交后再接新任务', $errorCodes['TASK_ACCEPT_ALREADY_DOING']);
    }
    $requestLogger->debug('无进行中任务');

    $requestLogger->debug('校验用户是否已接过该任务', ['b_task_id' => $bTaskId]);
    $stmt = $db->prepare("
        SELECT id FROM c_task_records
        WHERE c_user_id = ? AND b_task_id = ?
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id'], $bTaskId]);
    if ($stmt->fetch()) {
        $auditLogger->notice('C端用户接单失败：重复接单', [
            'user_id' => $currentUser['user_id'],
            'b_task_id' => $bTaskId,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('您已接过该任务，不能重复接单', $errorCodes['TASK_ACCEPT_ALREADY_ACCEPTED']);
    }
    $requestLogger->debug('非重复接单');

    // ========== 注释掉弃单次数和驳回次数的限制功能 ==========
    /*
    $today = date('Y-m-d');
    $requestLogger->debug('查询当日统计记录', ['user_id' => $currentUser['user_id'], 'stat_date' => $today]);
    $stmt = $db->prepare("
        SELECT id, rejected_count, approved_count, abandon_count
        FROM c_user_daily_stats
        WHERE c_user_id = ? AND stat_date = ?
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$dailyStats) {
        $requestLogger->debug('创建当日统计记录');
        $stmt = $db->prepare("
            INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, rejected_count, submit_count, abandon_count, approved_count)
            VALUES (?, ?, 0, 0, 0, 0, 0)
        ");
        $stmt->execute([$currentUser['user_id'], $today]);
        $dailyStatsId = $db->lastInsertId();
        $rejectedCount = 0;
        $abandonCount = 0;
        $requestLogger->debug('当日统计创建成功', ['id' => $dailyStatsId]);
    } else {
        $dailyStatsId = $dailyStats['id'];
        $rejectedCount = (int)$dailyStats['rejected_count'];
        $approvedCount = (int)$dailyStats['approved_count'];
        $abandonCount = (int)$dailyStats['abandon_count'];
        $requestLogger->debug('当日统计已存在', [
            'id' => $dailyStatsId,
            'rejected' => $rejectedCount,
            'approved' => $approvedCount,
            'abandon' => $abandonCount
        ]);
    }

    if ($rejectedCount >= $rejectedCountLimit) {
        $requestLogger->warning('用户驳回次数超限', [
            'rejected_count' => $rejectedCount,
            'rejected_count_limit' => $rejectedCountLimit
        ]);

        $auditLogger->notice('C 端用户接单失败：驳回次数超限', [
            'user_id' => $currentUser['user_id'],
            'rejected_count' => $rejectedCount,
            'rejected_count_limit' => $rejectedCountLimit,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("您今日已被驳回{$rejectedCountLimit}次，暂时无法接单，请明天再试", $errorCodes['TASK_ACCEPT_REJECT_LIMIT']);
    }
    $requestLogger->debug('驳回次数未超限', [
        'rejected_count' => $rejectedCount,
        'rejected_count_limit' => $rejectedCountLimit
    ]);

    $requestLogger->debug('校验弃单次数', ['abandon_count' => $abandonCount]);
    if ($abandonCount >= $abandonCountLimit) {
        $requestLogger->warning('用户弃单次数超限', [
            'abandon_count' => $abandonCount,
            'abandon_count_limit' => $abandonCountLimit
        ]);

        $auditLogger->notice('C 端用户接单失败：弃单次数超限', [
            'user_id' => $currentUser['user_id'],
            'abandon_count' => $abandonCount,
            'abandon_count_limit' => $abandonCountLimit,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("您今日已弃单超过{$abandonCountLimit}次，暂时无法接单，请明天再试", $errorCodes['TASK_ACCEPT_REJECT_LIMIT']);
    }
    $requestLogger->debug('弃单次数未超限', [
        'abandon_count' => $abandonCount,
        'abandon_count_limit' => $abandonCountLimit
    ]);
    */
    
    // 设置默认值，保证后续代码正常运行
    $dailyStatsId = null;
    $rejectedCount = 0;
    $abandonCount = 0;
    $requestLogger->info('已注释弃单次数和驳回次数限制功能');

    $requestLogger->debug('查询任务信息', ['b_task_id' => $bTaskId, 'table' => $taskTable]);
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
        $requestLogger->warning('任务不存在', ['b_task_id' => $bTaskId]);

        $auditLogger->notice('C端用户接单失败：任务不存在', [
            'user_id' => $currentUser['user_id'],
            'b_task_id' => $bTaskId,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('任务不存在', $errorCodes['TASK_NOT_FOUND']);
    }
    $requestLogger->debug('任务信息查询成功', ['b_task_id' => $bTask['id']]);

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
            $auditLogger->notice('C端用户接单失败：重复接组合任务', [
                'user_id' => $currentUser['user_id'],
                'combo_task_id' => $comboTaskId,
            ]);

            if (method_exists($auditLogger, 'flush')) {
                $auditLogger->flush();
            }

            Response::error('您已接过该组合任务，不能重复接单', $errorCodes['TASK_ACCEPT_ALREADY_ACCEPTED']);
        }
        $requestLogger->debug('非重复接组合任务');
    }

    $requestLogger->debug('校验任务开放状态', ['stage_status' => $bTask['stage_status']]);
    if ((int)$bTask['stage_status'] !== 1) {
        $auditLogger->notice('C端用户接单失败：任务未开放', [
            'user_id' => $currentUser['user_id'],
            'b_task_id' => $bTaskId,
            'stage_status' => $bTask['stage_status'],
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('该任务暂未开放，无法接单', $errorCodes['TASK_NOT_OPEN']);
    }
    $requestLogger->debug('任务已开放');

    $requestLogger->debug('校验任务状态', ['status' => $bTask['status']]);
    if ((int)$bTask['status'] !== 1) {
        $auditLogger->notice('C端用户接单失败：任务已结束', [
            'user_id' => $currentUser['user_id'],
            'b_task_id' => $bTaskId,
            'status' => $bTask['status'],
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('该任务已结束，无法接单', $errorCodes['TASK_NOT_FOUND']);
    }
    $requestLogger->debug('任务状态正常');

    $taskDone = (int)$bTask['task_done'];
    $taskDoing = (int)$bTask['task_doing'];
    $taskReviewing = (int)$bTask['task_reviewing'];
    $taskCount = (int)$bTask['task_count'];
    $remainingCount = $taskCount - $taskDone - $taskDoing - $taskReviewing;
    $requestLogger->debug('任务剩余数量', [
        'remaining' => $remainingCount,
        'total' => $taskCount,
        'done' => $taskDone,
        'doing' => $taskDoing,
        'reviewing' => $taskReviewing
    ]);

    if ($remainingCount <= 0) {
        $auditLogger->notice('C端用户接单失败：任务无剩余名额', [
            'user_id' => $currentUser['user_id'],
            'b_task_id' => $bTaskId,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('该任务已无剩余名额，无法接单', $errorCodes['TASK_ACCEPT_NO_STOCK']);
    }
    $requestLogger->debug('任务有剩余名额');

    $requestLogger->debug('解析推荐评论');
    $recommendMarks = json_decode($bTask['recommend_marks'], true);
    if (!is_array($recommendMarks) || empty($recommendMarks)) {
        $recommendMark = null;
        $requestLogger->debug('无推荐评论');
    } else {
        $recommendMark = $recommendMarks[array_rand($recommendMarks)];
        $requestLogger->debug('推荐评论分配成功');
    }

    $requestLogger->debug('开启数据库事务');
    $db->beginTransaction();

    $requestLogger->debug('查询模板佣金配置', ['template_id' => $bTask['template_id']]);
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
    $requestLogger->debug('计算佣金', ['stage' => $stage, 'reward_amount' => $rewardAmount . '分']);

    $taskStage = (int)$bTask['stage'];
    $templateId = (int)$bTask['template_id'];
    $templateTitle = $template['title'] ?? '';

    // 根据stage获取task_stage_text
    if ($taskStage === 0) {
        // 单任务：使用description1字段
        $taskStageText = $template['description1'] ?? '';
    } elseif ($taskStage === 1) {
        // 组合任务阶段1：使用stage1_title字段
        $taskStageText = $template['stage1_title'] ?? '';
    } elseif ($taskStage === 2) {
        // 组合任务阶段2：使用stage2_title字段
        $taskStageText = $template['stage2_title'] ?? '';
    } else {
        $taskStageText = '';
    }
    $requestLogger->debug('任务阶段信息', ['stage' => $taskStage, 'stage_text' => $taskStageText, 'template_title' => $templateTitle]);

    $requestLogger->debug('插入C端任务记录');

    // 插入到c_task_records表
    $stmt = $db->prepare("
        INSERT INTO c_task_records (
            c_user_id, b_task_id, b_user_id, template_id, template_title,
            video_url, recommend_mark, reward_amount, status, task_stage, task_stage_text
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
    ");
    $stmt->execute([
        $currentUser['user_id'],
        $bTaskId,
        $bTask['b_user_id'],
        $bTask['template_id'],
        $templateTitle,
        $bTask['video_url'],
        json_encode($recommendMark, JSON_UNESCAPED_UNICODE),
        $rewardAmount,
        $taskStage,
        $taskStageText
    ]);
    $recordId = $db->lastInsertId();
    $requestLogger->debug('C端任务记录插入成功', ['record_id' => $recordId]);

    $requestLogger->debug('查询任务task_doing', ['b_task_id' => $bTaskId]);
    $stmt = $db->prepare("SELECT task_doing FROM $taskTable WHERE id = ?");
    $stmt->execute([$bTaskId]);
    $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
    $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
    $newTaskDoing = $currentTaskDoing + 1;
    $requestLogger->debug('计算task_doing', ['current' => $currentTaskDoing, 'new' => $newTaskDoing]);

    $requestLogger->debug('更新B端任务doing数量', ['b_task_id' => $bTaskId, 'new_doing' => $newTaskDoing]);
    $stmt = $db->prepare("
        UPDATE $taskTable
        SET task_doing = ?
        WHERE id = ?
    ");
    $stmt->execute([$newTaskDoing, $bTaskId]);
    $requestLogger->debug('B 端任务更新成功');

    // ========== 注释掉更新当日接单统计功能 ==========
    /*
    $requestLogger->debug('更新当日接单统计', ['daily_stats_id' => $dailyStatsId]);
    $stmt = $db->prepare("
        UPDATE c_user_daily_stats
        SET accept_count = accept_count + 1
        WHERE id = ?
    ");
    $stmt->execute([$dailyStatsId]);
    $requestLogger->debug('接单统计更新成功');
    */
    $requestLogger->info('已跳过更新当日接单统计');

    $requestLogger->info('移除接单冷却时间限制，跳过更新用户静态记录');

    $requestLogger->debug('提交数据库事务');
    $db->commit();
    $requestLogger->debug('事务提交成功');

    $auditLogger->notice('C端用户接单成功', [
        'user_id' => $currentUser['user_id'],
        'record_id' => $recordId,
        'b_task_id' => $bTaskId,
        'reward_amount' => $rewardAmount,
        'task_stage' => $taskStage,
        'task_stage_text' => $taskStageText,
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    $requestLogger->info('接单成功', [
        'record_id' => $recordId,
        'b_task_id' => $bTaskId,
        'reward_amount' => number_format($rewardAmount / 100, 2),
    ]);

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
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('PDO异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户接单失败：数据库异常', [
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('接单失败', $errorCodes['TASK_ACCEPT_FAILED'], 500);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户接单失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('接单失败', $errorCodes['TASK_ACCEPT_FAILED'], 500);
}