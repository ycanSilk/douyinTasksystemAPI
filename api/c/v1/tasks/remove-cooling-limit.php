<?php
/**
 * C 端解除接取任务冷却时间限制接口
 *
 * POST /api/c/v1/tasks/remove-cooling-limit
 *
 * 请求头：
 * X-Token: <token> (C 端)
 *
 * 请求体：
 * {
 *   "cooling_time_limit": 0
 * }
 *
 * 参数说明：
 * - cooling_time_limit: 接取任务冷却时间限制 0=不开启，1=开启
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "设置成功",
 *   "data": {
 *     "cooling_time_limit": 0
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 功能说明：
 * 1. 修改 c_users 表的 cooling_time_limit 字段
 * 2. cooling_time_limit=0：不开启冷却时间限制，接单无需等待 3 分钟
 * 3. cooling_time_limit=1：开启冷却时间限制，接单需间隔 3 分钟
 *
 * 错误码说明：
 * 1001  - 请求方法错误
 * 1002  - 数据库错误
 * 2001  - Token 无效
 * 2002  - Token 过期
 * 4001  - 参数错误
 * 5000  - 系统错误
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/tasks/remove-cooling-limit');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C 端解除冷却时间限制请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C 端用户解除冷却时间限制失败：请求方法错误', [
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
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C 端用户解除冷却时间限制失败：数据库连接失败', [
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

    $auditLogger->warning('C 端用户解除冷却时间限制失败：Token 认证失败', [
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
$coolingTimeLimit = $input['cooling_time_limit'] ?? null;
$requestLogger->debug('获取请求参数', ['cooling_time_limit' => $coolingTimeLimit]);

if ($coolingTimeLimit === null || !in_array($coolingTimeLimit, [0, 1], true)) {
    $requestLogger->warning('冷却时间限制参数无效', ['cooling_time_limit' => $coolingTimeLimit]);

    $auditLogger->warning('C 端用户解除冷却时间限制失败：参数错误', [
        'user_id' => $currentUser['user_id'],
        'cooling_time_limit' => $coolingTimeLimit,
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 4001,
        'message' => '参数错误，cooling_time_limit 必须为 0 或 1',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $requestLogger->debug('查询用户信息', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("SELECT id, cooling_time_limit FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$userInfo) {
        $requestLogger->warning('用户不存在', ['user_id' => $currentUser['user_id']]);

        $auditLogger->notice('C 端用户解除冷却时间限制失败：用户不存在', [
            'user_id' => $currentUser['user_id'],
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 4002,
            'message' => '用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $currentCoolingLimit = $userInfo['cooling_time_limit'] ?? 1;
    $requestLogger->debug('用户当前冷却限制设置', [
        'user_id' => $currentUser['user_id'],
        'current_cooling_time_limit' => $currentCoolingLimit
    ]);

    // 如果没有传入 cooling_time_limit 参数，返回当前状态（用于查询）
    if ($coolingTimeLimit === null) {
        $requestLogger->info('查询用户冷却限制状态', [
            'user_id' => $currentUser['user_id'],
            'cooling_time_limit' => $currentCoolingLimit
        ]);

        echo json_encode([
            'code' => 0,
            'message' => '查询成功',
            'data' => [
                'cooling_time_limit' => (int)$currentCoolingLimit,
                'description' => $currentCoolingLimit === 0 ? '接单无需等待' : '接单需要冷却'
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($currentCoolingLimit == $coolingTimeLimit) {
        $requestLogger->info('冷却限制设置未变化', [
            'user_id' => $currentUser['user_id'],
            'cooling_time_limit' => $coolingTimeLimit
        ]);

        echo json_encode([
            'code' => 0,
            'message' => '设置成功（无变化）',
            'data' => [
                'cooling_time_limit' => (int)$coolingTimeLimit,
                'current_status' => (int)$currentCoolingLimit
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $requestLogger->debug('更新用户冷却时间限制设置', [
        'user_id' => $currentUser['user_id'],
        'old_value' => $currentCoolingLimit,
        'new_value' => $coolingTimeLimit
    ]);

    $stmt = $db->prepare("
        UPDATE c_users
        SET cooling_time_limit = ?, updated_at = NOW()
        WHERE id = ?
    ");
    $stmt->execute([$coolingTimeLimit, $currentUser['user_id']]);
    $affectedRows = $stmt->rowCount();

    if ($affectedRows > 0) {
        $requestLogger->info('用户冷却时间限制更新成功', [
            'user_id' => $currentUser['user_id'],
            'cooling_time_limit' => $coolingTimeLimit,
            'affected_rows' => $affectedRows
        ]);

        $auditLogger->notice('C 端用户解除冷却时间限制成功', [
            'user_id' => $currentUser['user_id'],
            'old_cooling_time_limit' => $currentCoolingLimit,
            'new_cooling_time_limit' => $coolingTimeLimit,
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }

        $statusText = $coolingTimeLimit === 0 ? '已解除' : '已开启';
        echo json_encode([
            'code' => 0,
            'message' => "{$statusText}接取任务冷却时间限制",
            'data' => [
                'cooling_time_limit' => (int)$coolingTimeLimit,
                'description' => $coolingTimeLimit === 0 ? '接单无需等待' : '接单需要冷却'
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);

    } else {
        $requestLogger->warning('用户冷却时间限制更新失败', [
            'user_id' => $currentUser['user_id'],
            'cooling_time_limit' => $coolingTimeLimit,
            'affected_rows' => $affectedRows
        ]);

        $auditLogger->error('C 端用户解除冷却时间限制失败：更新失败', [
            'user_id' => $currentUser['user_id'],
            'cooling_time_limit' => $coolingTimeLimit,
            'reason' => '更新失败',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 5000,
            'message' => '设置失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('PDO 异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C 端用户解除冷却时间限制失败：数据库异常', [
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
        'message' => '设置失败',
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

    $auditLogger->error('C 端用户解除冷却时间限制失败：系统异常', [
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
        'message' => '设置失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
