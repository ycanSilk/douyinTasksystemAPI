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
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取分页参数
$page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
$pageSize = isset($_GET['page_size']) ? min(100, max(1, (int)$_GET['page_size'])) : 20;
$offset = ($page - 1) * $pageSize;

try {
    // 1. 查询B端用户钱包信息
    $stmt = $db->prepare("SELECT wallet_id FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 2. 查询钱包余额
    $stmt = $db->prepare("SELECT id, balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }
    
    // 3. 查询交易记录总数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM wallets_log 
        WHERE wallet_id = ? AND user_type = 2
    ");
    $stmt->execute([$bUser['wallet_id']]);
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 4. 查询交易记录（分页）
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
        WHERE wallet_id = ? AND user_type = 2
        ORDER BY created_at DESC, id DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$bUser['wallet_id'], $pageSize, $offset]);
    $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
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
    
    // 7. 返回成功响应
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
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
