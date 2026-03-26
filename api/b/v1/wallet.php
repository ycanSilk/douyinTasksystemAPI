<?php
/**
 * B端钱包信息接口
 *
 * GET /api/b/v1/wallet
 *
 * 请求头：
 * X-Token: <token> (B端)
 *
 * 查询参数（可选）：
 * - page: 页码（默认1）
 * - page_size: 每页记录数（默认20，最大100）
 * - type: 类型筛选（1=收入，2=支出，不传则返回全部）
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "wallet": {
 *       "balance": "100.00",
 *       "wallet_id": 1
 *     },
 *     "transactions": [
 *       {
 *         "id": 1,
 *         "type": 2,
 *         "type_text": "支出",
 *         "amount": "10.00",
 *         "before_balance": "110.00",
 *         "after_balance": "100.00",
 *         "related_type": "task",
 *         "related_id": 123,
 *         "remark": "发布任务扣费",
 *         "created_at": "2026-01-11 12:00:00"
 *       }
 *     ],
 *     "pagination": {
 *       "page": 1,
 *       "page_size": 20,
 *       "total": 50,
 *       "total_pages": 3
 *     }
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4012 - 用户认证失败
 * 5001 - 数据库错误
 * 5002 - 查询失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/wallet');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== B端钱包信息请求开始 ===', [
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
    $auditLogger->warning('B端用户查询钱包信息失败：请求方法错误', [
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
        'data' => []
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
    'page_size' => $_GET['page_size'] ?? null,
    'type' => $_GET['type'] ?? null,
]);

try {
    // 数据库连接
    try {
        $db = Database::connect();
        $requestLogger->debug('数据库连接成功');
    } catch (Exception $e) {
        $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

        // 记录审计日志
        $auditLogger->error('B端用户查询钱包信息失败：数据库连接失败', [
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
            'data' => []
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Token 认证（必须是 B端用户）
    try {
        $auth = new AuthMiddleware($db);
        $currentUser = $auth->authenticateB();
        $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
    } catch (Exception $e) {
        $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);

        // 记录审计日志
        $auditLogger->warning('B端用户查询钱包信息失败：Token 认证失败', [
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
            'data' => []
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 获取分页参数
    $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
    $pageSize = isset($_GET['page_size']) ? min(100, max(1, (int)$_GET['page_size'])) : 20;
    $offset = ($page - 1) * $pageSize;

    // 获取类型筛选参数
    $type = isset($_GET['type']) ? (int)$_GET['type'] : null;
    $typeFilter = '';
    $typeParams = [];

    // 如果传入了 type 参数，构建筛选条件
    if ($type !== null && in_array($type, [1, 2], true)) {
        $typeFilter = 'AND type = ?';
        $typeParams[] = $type;
        $requestLogger->debug('添加类型筛选条件', ['type' => $type]);
    }

    // 记录请求参数
    $requestLogger->debug('请求参数', [
        'user_id' => $currentUser['user_id'],
        'page' => $page,
        'page_size' => $pageSize,
        'type' => $type,
    ]);

    // 1. 查询B端用户钱包信息
    $stmt = $db->prepare("SELECT wallet_id FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$bUser) {
        $errorLogger->error('用户信息异常', ['user_id' => $currentUser['user_id']]);

        // 记录审计日志
        $auditLogger->error('B端用户查询钱包信息失败：用户信息异常', [
            'user_id' => $currentUser['user_id'],
            'reason' => '用户信息异常',
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
            'message' => '用户信息异常',
            'data' => []
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 2. 查询钱包余额
    $stmt = $db->prepare("SELECT id, balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$wallet) {
        $errorLogger->error('钱包不存在', ['wallet_id' => $bUser['wallet_id']]);

        // 记录审计日志
        $auditLogger->error('B端用户查询钱包信息失败：钱包不存在', [
            'wallet_id' => $bUser['wallet_id'],
            'reason' => '钱包不存在',
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
            'message' => '钱包不存在',
            'data' => []
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $requestLogger->debug('钱包信息查询成功', ['balance' => $wallet['balance']]);

    // 3. 查询交易记录总数
    $countSql = "
        SELECT COUNT(*) as total
        FROM wallets_log
        WHERE wallet_id = ? AND user_type = 2 {$typeFilter}
    ";
    $stmt = $db->prepare($countSql);
    $stmt->execute(array_merge([$bUser['wallet_id']], $typeParams));
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('交易记录总数查询成功', ['total' => $totalCount]);

    // 4. 查询交易记录（分页）
    $listSql = "
        SELECT
            id,
            type,
            amount,
            before_balance,
            after_balance,
            related_type,
            related_id,
            remark,
            created_at
        FROM wallets_log
        WHERE wallet_id = ? AND user_type = 2 {$typeFilter}
        ORDER BY created_at DESC, id DESC
        LIMIT ? OFFSET ?
    ";
    $stmt = $db->prepare($listSql);
    $stmt->execute(array_merge([$bUser['wallet_id']], $typeParams, [$pageSize, $offset]));
    $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('交易记录列表查询成功', ['count' => count($transactions)]);

    // 5. 格式化交易记录
    $formattedTransactions = [];
    foreach ($transactions as $transaction) {
        $formattedTransactions[] = [
            'id' => (int)$transaction['id'],
            'type' => (int)$transaction['type'],
            'type_text' => (int)$transaction['type'] === 1 ? '收入' : '支出',
            'amount' => number_format($transaction['amount'] / 100, 2),
            'before_balance' => number_format($transaction['before_balance'] / 100, 2),
            'after_balance' => number_format($transaction['after_balance'] / 100, 2),
            'related_type' => $transaction['related_type'],
            'related_id' => $transaction['related_id'] ? (int)$transaction['related_id'] : null,
            'remark' => $transaction['remark'],
            'created_at' => $transaction['created_at']
        ];
    }

    // 6. 计算总页数
    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;

    // 记录审计日志
    $auditLogger->notice('B端用户查询钱包信息成功', [
        'user_id' => $currentUser['user_id'],
        'wallet_id' => $bUser['wallet_id'],
        'balance' => $wallet['balance'],
        'total' => $totalCount,
        'page' => $page,
        'page_size' => $pageSize,
        'type' => $type,
        'returned_count' => count($formattedTransactions),
    ]);

    // 手动刷新异步队列
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    // 7. 返回成功响应
    $requestLogger->info('钱包信息获取成功', [
        'user_id' => $currentUser['user_id'],
        'balance' => $wallet['balance'],
        'total' => $totalCount,
        'returned_count' => count($formattedTransactions),
    ]);

    echo json_encode([
        'code' => 0,
        'message' => '获取成功',
        'data' => [
            'wallet' => [
                'balance' => number_format($wallet['balance'] / 100, 2),
                'wallet_id' => (int)$wallet['id']
            ],
            'transactions' => $formattedTransactions,
            'pagination' => [
                'page' => $page,
                'page_size' => $pageSize,
                'total' => $totalCount,
                'total_pages' => $totalPages
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    // 回滚事务（如果有）
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    // 记录错误
    $errorLogger->error('查询失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    // 记录审计日志
    $auditLogger->error('B端用户查询钱包信息失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'reason' => '数据库异常',
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
        'message' => '查询失败',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // 回滚事务（如果有）
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    // 记录错误
    $errorLogger->error('查询失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    // 记录审计日志
    $auditLogger->error('B端用户查询钱包信息失败：系统异常', [
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
        'message' => '查询失败',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}