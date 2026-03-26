<?php
/**
 * B 端充值记录查询接口
 * 
 * GET /api/b/v1/recharge-list
 * 
 * 请求头：
 * X-Token: <token> (B 端)
 * 
 * 请求参数：
 * - page (可选): 页码，默认 1
 * - page_size (可选): 每页数量，默认 20
 * 
 * 请求示例：
 * GET /api/b/v1/recharge-list?page=1&page_size=20
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "获取成功",
 *   "data": {
 *     "records": [
 *       {
 *         "id": 1,
 *         "wallet_id": 67,
 *         "user_id": 9,
 *         "username": "task",
 *         "user_type": 2,
 *         "user_type_text": "B端用户",
 *         "type": 1,
 *         "type_text": "收入",
 *         "amount": "100.00",
 *         "before_balance": "0.00",
 *         "after_balance": "100.00",
 *         "related_type": "recharge",
 *         "related_id": null,
 *         "remark": "充值",
 *         "created_at": "2026-03-24 10:00:00"
 *       }
 *     ],
 *     "pagination": {
 *       "current_page": 1,
 *       "page_size": 20,
 *       "total": 50,
 *       "total_pages": 3
 *     }
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 5001,
 *   "message": "数据库连接失败",
 *   "data": []
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4012 - 用户认证失败
 * 5001 - 数据库错误
 * 5002 - 获取充值记录失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/recharge-list');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== B 端充值记录查询请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    // 记录审计日志
    $auditLogger->warning('B端用户查询充值记录失败：请求方法错误', [
        'method' => $_SERVER['REQUEST_METHOD'],
        'reason' => '请求方法错误',
    ]);

    // 手动刷新异步队列
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

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';

// 记录请求体
try {
    $rawInput = file_get_contents('php://input');
    $requestLogger->debug('请求体内容', ['body' => $rawInput]);
} catch (Exception $e) {
    $errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()]);
    $rawInput = '';
}

// 记录 GET 参数
$requestLogger->debug('查询参数', [
    'page' => $_GET['page'] ?? null,
    'page_size' => $_GET['page_size'] ?? null
]);

try {
    // 数据库连接
    try {
        $db = Database::connect();
        $requestLogger->debug('数据库连接成功');
    } catch (Exception $e) {
        $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

        // 记录审计日志
        $auditLogger->error('B端用户查询充值记录失败：数据库连接失败', [
            'exception' => $e->getMessage(),
            'reason' => '数据库连接失败',
        ]);

        // 手动刷新异步队列
        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 5001,
            'message' => '数据库连接失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Token 认证
    try {
        $auth = new AuthMiddleware($db);
        $currentUser = $auth->authenticateB(); // B 端专用认证
        $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
    } catch (Exception $e) {
        $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);

        // 记录审计日志
        $auditLogger->warning('B端用户查询充值记录失败：Token 认证失败', [
            'exception' => $e->getMessage(),
            'reason' => 'Token 认证失败',
        ]);

        // 手动刷新异步队列
        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        echo json_encode([
            'code' => 4012,
            'message' => '用户认证失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 获取请求参数
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $pageSize = isset($_GET['page_size']) ? max(1, min(100, intval($_GET['page_size']))) : 20;
    $offset = ($page - 1) * $pageSize;

    // 记录请求参数
    $requestLogger->debug('请求参数', [
        'user_id' => $currentUser['user_id'],
        'page' => $page,
        'page_size' => $pageSize,
        'offset' => $offset
    ]);

    // 查询充值记录总数
    $countStmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM wallets_log
        WHERE user_id = ? AND user_type = 2 AND related_type = 'recharge'
    ");
    $countStmt->execute([$currentUser['user_id']]);
    $total = (int)$countStmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('充值记录总数查询成功', ['total' => $total]);

    // 查询充值记录列表
    $stmt = $db->prepare("
        SELECT 
            id,
            wallet_id,
            user_id,
            username,
            user_type,
            type,
            amount,
            before_balance,
            after_balance,
            related_type,
            related_id,
            remark,
            created_at
        FROM wallets_log
        WHERE user_id = ? AND user_type = 2 AND related_type = 'recharge'
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$currentUser['user_id'], $pageSize, $offset]);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('充值记录列表查询成功', ['count' => count($records)]);

    // 格式化充值记录
    $typeTexts = [
        1 => '收入',
        2 => '支出'
    ];

    $userTypeTexts = [
        1 => 'C端用户',
        2 => 'B端用户'
    ];

    $formattedRecords = [];
    foreach ($records as $record) {
        $formattedRecord = [
            'id' => (int)$record['id'],
            'wallet_id' => (int)$record['wallet_id'],
            'user_id' => (int)$record['user_id'],
            'username' => $record['username'],
            'user_type' => (int)$record['user_type'],
            'user_type_text' => $userTypeTexts[$record['user_type']] ?? '未知',
            'type' => (int)$record['type'],
            'type_text' => $typeTexts[$record['type']] ?? '未知',
            'amount' => number_format($record['amount'] / 100, 2),
            'before_balance' => number_format($record['before_balance'] / 100, 2),
            'after_balance' => number_format($record['after_balance'] / 100, 2),
            'related_type' => $record['related_type'],
            'related_id' => $record['related_id'] ? (int)$record['related_id'] : null,
            'remark' => $record['remark'],
            'created_at' => $record['created_at']
        ];
        $formattedRecords[] = $formattedRecord;
    }

    $requestLogger->debug('充值记录格式化完成', ['formatted_count' => count($formattedRecords)]);

    // 记录审计日志
    $auditLogger->notice('B端用户查询充值记录成功', [
        'user_id' => $currentUser['user_id'],
        'total' => $total,
        'page' => $page,
        'page_size' => $pageSize,
        'returned_count' => count($formattedRecords)
    ]);

    // 手动刷新异步队列
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    // 返回结果
    $requestLogger->info('充值记录获取成功', [
        'total' => $total,
        'page' => $page,
        'page_size' => $pageSize,
        'returned_count' => count($formattedRecords)
    ]);

    echo json_encode([
        'code' => 0,
        'message' => '获取成功',
        'data' => [
            'records' => $formattedRecords,
            'pagination' => [
                'current_page' => $page,
                'page_size' => $pageSize,
                'total' => $total,
                'total_pages' => $total > 0 ? ceil($total / $pageSize) : 0
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // 回滚事务（如果有）
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    // 记录错误
    $errorLogger->error('获取充值记录失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    // 记录审计日志
    $auditLogger->error('B端用户查询充值记录失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'reason' => '系统异常',
    ]);

    // 手动刷新异步队列
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 5002,
        'message' => '获取充值记录失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}