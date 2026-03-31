<?php
/**
 * C 端放弃任务接口
 *
 * POST /api/c/v1/tasks/abandon
 *
 * 请求头：
 * X-Token: <token> (C 端)
 *
 * 请求体：
 * {
 *   "record_id": 123,
 *   "b_task_id": 456
 * }
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "放弃成功",
 *   "data": {
 *     "record_id": 123,
 *     "b_task_id": 456
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 放弃规则：
 * 1. 只能放弃状态为 1(进行中) 的任务
 * 2. 放弃后任务状态变为 5(已取消)
 * 3. 放弃后 B 端任务的 task_doing 数量减 1（释放回任务池）
 * 4. 放弃后 C 端用户的 abandon_count + 1
 * 5. 如果用户当日 abandon_count >= abandon_count 配置值，则禁止放弃
 *
 * 错误码说明：
 * 1001  - 请求方法错误
 * 1002  - 数据库错误
 * 2001  - Token 无效
 * 2002  - Token 过期
 * 4001  - 参数错误
 * 4002  - 任务记录不存在
 * 4003  - 权限不足（只能放弃自己的任务）
 * 4004  - 任务状态不允许放弃（只能放弃进行中的任务）
 * 5000  - 系统错误
 * 9001  - 放弃失败
 * 9002  - 您今日已弃单超过限制次数，暂时无法放弃任务
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/tasks/abandon');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C 端放弃任务请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C 端用户放弃任务失败：请求方法错误', [
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

try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
    
    // 从 app_config 表获取弃单次数限制
    require_once __DIR__ . '/../../../../core/AppConfig.php';
    $abandonCountLimit = AppConfig::get('abandon_count', 6); // 默认值为 6
    $requestLogger->debug('获取弃单次数限制配置', ['abandon_count_limit' => $abandonCountLimit]);
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C 端用户放弃任务失败：数据库连接失败', [
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
        'code' => 1002,
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
    $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);

    $auditLogger->warning('C 端用户放弃任务失败：Token 认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token 认证失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 2001,
        'message' => '认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$input = json_decode($requestBody, true);
$recordId = $input['record_id'] ?? 0;
$bTaskIdInput = $input['b_task_id'] ?? 0;
$requestLogger->debug('获取请求参数', [
    'record_id' => $recordId,
    'b_task_id' => $bTaskIdInput
]);

if (empty($recordId) || !is_numeric($recordId)) {
    $requestLogger->warning('任务记录 ID 为空或无效', ['record_id' => $recordId]);

    $auditLogger->warning('C 端用户放弃任务失败：record_id 参数错误', [
        'user_id' => $currentUser['user_id'],
        'record_id' => $recordId,
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 4001,
        'message' => '任务记录 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($bTaskIdInput) || !is_numeric($bTaskIdInput)) {
    $requestLogger->warning('B 端任务 ID 为空或无效', ['b_task_id' => $bTaskIdInput]);

    $auditLogger->warning('C 端用户放弃任务失败：b_task_id 参数错误', [
        'user_id' => $currentUser['user_id'],
        'b_task_id' => $bTaskIdInput,
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 4001,
        'message' => 'B 端任务 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $requestLogger->debug('查询任务记录信息', ['record_id' => $recordId]);
    $stmt = $db->prepare("
        SELECT 
            ctr.id,
            ctr.c_user_id,
            ctr.b_task_id,
            ctr.b_user_id,
            ctr.status,
            ctr.task_stage,
            ctr.task_stage_text,
            ctr.template_title,
            bt.task_doing,
            bt.status as b_task_status
        FROM c_task_records ctr
        INNER JOIN b_tasks bt ON ctr.b_task_id = bt.id
        WHERE ctr.id = ?
    ");
    $stmt->execute([$recordId]);
    $taskRecord = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$taskRecord) {
        $requestLogger->warning('任务记录不存在', ['record_id' => $recordId]);

        $auditLogger->notice('C 端用户放弃任务失败：任务记录不存在', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 4002,
            'message' => '任务记录不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('任务记录查询成功', [
        'record_id' => $taskRecord['id'],
        'b_task_id' => $taskRecord['b_task_id'],
        'c_user_id' => $taskRecord['c_user_id']
    ]);

    // 校验传入的 b_task_id 是否与记录中的 b_task_id 匹配
    if ((int)$taskRecord['b_task_id'] !== (int)$bTaskIdInput) {
        $requestLogger->warning('b_task_id 不匹配', [
            'input_b_task_id' => $bTaskIdInput,
            'record_b_task_id' => $taskRecord['b_task_id']
        ]);

        $auditLogger->warning('C 端用户放弃任务失败：b_task_id 不匹配', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'input_b_task_id' => $bTaskIdInput,
            'record_b_task_id' => $taskRecord['b_task_id'],
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 4001,
            'message' => '任务记录 ID 与 B 端任务 ID 不匹配',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('b_task_id 校验通过');

    if ($taskRecord['c_user_id'] != $currentUser['user_id']) {
        $requestLogger->warning('权限不足，不能放弃他人任务', [
            'record_id' => $recordId,
            'owner_id' => $taskRecord['c_user_id'],
            'current_user_id' => $currentUser['user_id']
        ]);

        $auditLogger->warning('C 端用户放弃任务失败：权限不足', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'owner_id' => $taskRecord['c_user_id'],
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 4003,
            'message' => '权限不足，不能放弃他人任务',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('权限校验通过');

    $taskStatus = (int)$taskRecord['status'];
    if ($taskStatus !== 1) {
        $requestLogger->warning('任务状态不允许放弃', [
            'record_id' => $recordId,
            'status' => $taskStatus
        ]);

        $auditLogger->notice('C 端用户放弃任务失败：任务状态不允许', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'status' => $taskStatus,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        $statusTexts = [
            1 => '进行中',
            2 => '待审核',
            3 => '已通过',
            4 => '已驳回',
            5 => '已取消'
        ];
        $currentStatusText = $statusTexts[$taskStatus] ?? '未知';

        echo json_encode([
            'code' => 4004,
            'message' => "任务状态为{$currentStatusText}，只能放弃进行中的任务",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('任务状态校验通过，允许放弃');

    $today = date('Y-m-d');
    $requestLogger->debug('查询当日统计记录', ['user_id' => $currentUser['user_id'], 'stat_date' => $today]);
    $stmt = $db->prepare("
        SELECT id, abandon_count
        FROM c_user_daily_stats
        WHERE c_user_id = ? AND stat_date = ?
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);

    $abandonCount = 0;
    $dailyStatsId = null;

    if ($dailyStats) {
        $abandonCount = (int)$dailyStats['abandon_count'];
        $dailyStatsId = $dailyStats['id'];
        $requestLogger->debug('当日统计已存在', [
            'daily_stats_id' => $dailyStatsId,
            'abandon_count' => $abandonCount
        ]);
    } else {
        $requestLogger->debug('当日统计记录不存在，将自动创建');
    }

    if ($abandonCount >= $abandonCountLimit) {
        $requestLogger->warning('用户弃单次数超限', [
            'abandon_count' => $abandonCount,
            'abandon_count_limit' => $abandonCountLimit
        ]);

        $auditLogger->notice('C 端用户放弃任务失败：弃单次数超限', [
            'user_id' => $currentUser['user_id'],
            'abandon_count' => $abandonCount,
            'abandon_count_limit' => $abandonCountLimit,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 9002,
            'message' => "您今日已弃单超过{$abandonCountLimit}次，暂时无法放弃任务",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('弃单次数未超限', [
        'abandon_count' => $abandonCount,
        'abandon_count_limit' => $abandonCountLimit
    ]);

    $requestLogger->debug('开启数据库事务');
    $db->beginTransaction();

    try {
        $bTaskId = (int)$taskRecord['b_task_id'];
        $bUserId = (int)$taskRecord['b_user_id'];

        $requestLogger->info('开始处理放弃任务', [
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'b_user_id' => $bUserId,
            'c_user_id' => $currentUser['user_id']
        ]);

        $requestLogger->debug('更新 C 端任务记录状态为已取消', ['record_id' => $recordId]);
        $stmt = $db->prepare("
            UPDATE c_task_records
            SET status = 5, update_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$recordId]);
        $affectedRows = $stmt->rowCount();
        $requestLogger->debug('C 端任务记录状态更新完成', [
            'record_id' => $recordId,
            'affected_rows' => $affectedRows
        ]);

        $requestLogger->debug('更新 B 端任务 task_doing 数量（释放回任务池）', [
            'b_task_id' => $bTaskId
        ]);
        $stmt = $db->prepare("
            UPDATE b_tasks
            SET task_doing = CASE 
                WHEN task_doing > 0 THEN task_doing - 1 
                ELSE 0 
            END,
            updated_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);
        $requestLogger->info('B 端任务更新成功（任务已释放回任务池）', [
            'b_task_id' => $bTaskId
        ]);

        if (!$dailyStatsId) {
            $requestLogger->debug('创建当日统计记录', ['c_user_id' => $currentUser['user_id']]);
            $stmt = $db->prepare("
                INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, abandon_count, approved_count, rejected_count, submit_count)
                VALUES (?, ?, 0, 1, 0, 0, 0)
            ");
            $stmt->execute([$currentUser['user_id'], $today]);
            $dailyStatsId = $db->lastInsertId();
            $requestLogger->info('当日统计记录创建成功', [
                'c_user_id' => $currentUser['user_id'],
                'daily_stats_id' => $dailyStatsId
            ]);
        } else {
            $requestLogger->debug('更新当日弃单统计', ['daily_stats_id' => $dailyStatsId]);
            $stmt = $db->prepare("
                UPDATE c_user_daily_stats
                SET abandon_count = abandon_count + 1
                WHERE id = ?
            ");
            $stmt->execute([$dailyStatsId]);
            $requestLogger->info('当日统计记录更新成功', ['daily_stats_id' => $dailyStatsId]);
        }

        $requestLogger->debug('提交数据库事务');
        $db->commit();
        $requestLogger->debug('事务提交成功');

        $auditLogger->notice('C 端用户放弃任务成功', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'abandon_count' => $abandonCount + 1,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }

        $requestLogger->info('放弃任务成功', [
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'new_abandon_count' => $abandonCount + 1
        ]);

        echo json_encode([
            'code' => 0,
            'message' => '放弃成功',
            'data' => [
                'record_id' => (int)$recordId,
                'b_task_id' => (int)$bTaskId
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);

    } catch (Exception $e) {
        $requestLogger->error('事务处理异常', [
            'record_id' => $recordId,
            'exception' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
        
        if ($db->inTransaction()) {
            $requestLogger->debug('回滚数据库事务');
            $db->rollBack();
        }
        
        throw $e;
    }

} catch (PDOException $e) {
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('PDO 异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C 端用户放弃任务失败：数据库异常', [
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 5000,
        'message' => '放弃失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C 端用户放弃任务失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 5000,
        'message' => '放弃失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
