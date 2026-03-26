<?php
/**
 * C端钱包信息接口
 *
 * GET /api/c/v1/wallet
 *
 * 请求头：
 * X-Token: <token> (C端)
 *
 * 查询参数（可选）：
 * - page: 页码（默认1）
 * - page_size: 每页记录数（默认20，最大100）
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
 *         "type": 1,
 *         "type_text": "收入",
 *         "amount": "10.00",
 *         "before_balance": "90.00",
 *         "after_balance": "100.00",
 *         "related_type": "task",
 *         "related_id": 123,
 *         "remark": "完成任务获得奖励",
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
 * 1002 - 数据库错误
 * 2001 - Token无效
 * 2002 - Token过期
 * 3003 - 用户不存在
 * 5001 - 钱包不存在
 * 5000 - 系统错误
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/wallet');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C端钱包信息请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户查询钱包信息失败：请求方法错误', [
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

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C端用户查询钱包信息失败：数据库连接失败', [
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
        'code' => $errorCodes['DATABASE_ERROR'] ?? 1002,
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

    $auditLogger->warning('C端用户查询钱包信息失败：Token认证失败', [
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

$page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
$pageSize = isset($_GET['page_size']) ? min(100, max(1, (int)$_GET['page_size'])) : 20;
$offset = ($page - 1) * $pageSize;

$requestLogger->debug('请求参数', [
    'user_id' => $currentUser['user_id'],
    'page' => $page,
    'page_size' => $pageSize,
]);

try {
    $requestLogger->debug('查询C端用户钱包信息', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("SELECT wallet_id FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $cUser = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$cUser) {
        $errorLogger->error('C端用户不存在', ['user_id' => $currentUser['user_id']]);

        $auditLogger->error('C端用户查询钱包信息失败：用户不存在', [
            'user_id' => $currentUser['user_id'],
            'reason' => '用户不存在',
        ]);

        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND'] ?? 3003);
    }

    $requestLogger->debug('查询钱包余额', ['wallet_id' => $cUser['wallet_id']]);
    $stmt = $db->prepare("SELECT id, balance FROM wallets WHERE id = ?");
    $stmt->execute([$cUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$wallet) {
        $errorLogger->error('钱包不存在', ['wallet_id' => $cUser['wallet_id']]);

        $auditLogger->error('C端用户查询钱包信息失败：钱包不存在', [
            'user_id' => $currentUser['user_id'],
            'wallet_id' => $cUser['wallet_id'],
            'reason' => '钱包不存在',
        ]);

        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND'] ?? 5001);
    }
    $requestLogger->debug('钱包信息查询成功', ['balance' => $wallet['balance']]);

    $requestLogger->debug('查询交易记录总数');
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM wallets_log
        WHERE wallet_id = ? AND user_type = 1
    ");
    $stmt->execute([$cUser['wallet_id']]);
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('交易记录总数查询成功', ['total' => $totalCount]);

    $requestLogger->debug('查询交易记录列表');
    $stmt = $db->prepare("
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
        WHERE wallet_id = ? AND user_type = 1
        ORDER BY created_at DESC, id DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$cUser['wallet_id'], $pageSize, $offset]);
    $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('交易记录列表查询成功', ['count' => count($transactions)]);

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

    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;

    $auditLogger->notice('C端用户查询钱包信息成功', [
        'user_id' => $currentUser['user_id'],
        'wallet_id' => $cUser['wallet_id'],
        'balance' => $wallet['balance'],
        'total' => $totalCount,
        'page' => $page,
        'page_size' => $pageSize,
        'returned_count' => count($formattedTransactions),
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    $requestLogger->info('C端钱包信息获取成功', [
        'user_id' => $currentUser['user_id'],
        'balance' => $wallet['balance'],
        'total' => $totalCount,
        'returned_count' => count($formattedTransactions),
    ]);

    Response::success([
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
    ]);

} catch (PDOException $e) {
    $errorLogger->error('查询失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户查询钱包信息失败：数据库异常', [
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('查询失败', $errorCodes['DATABASE_ERROR'] ?? 1002, 500);
} catch (Exception $e) {
    $errorLogger->error('查询失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户查询钱包信息失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('查询失败', $errorCodes['SYSTEM_ERROR'] ?? 5000, 500);
}