<?php
/**
 * C端提现记录查询接口
 * 
 * GET /api/c/v1/withdraw-list
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 查询参数（可选）：
 * - page: 页码（默认1）
 * - page_size: 每页记录数（默认20，最大100）
 * - status: 审核状态筛选（0=待审核，1=审核通过，2=审核拒绝，不传=全部）
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "list": [
 *       {
 *         "id": 1,
 *         "amount": "100.00",
 *         "withdraw_method": "alipay",
 *         "withdraw_account": "13800138000",
 *         "status": 1,
 *         "status_text": "审核通过",
 *         "reject_reason": null,
 *         "img_url": "http://example.com/img/xxx.jpg",
 *         "reviewed_at": "2026-01-11 12:00:00",
 *         "created_at": "2026-01-11 11:00:00"
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

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 获取分页参数
$page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
$pageSize = isset($_GET['page_size']) ? min(100, max(1, (int)$_GET['page_size'])) : 20;
$offset = ($page - 1) * $pageSize;

// 获取状态筛选参数
$statusFilter = isset($_GET['status']) && $_GET['status'] !== '' ? (int)$_GET['status'] : null;

try {
    // 构建查询条件
    $whereConditions = ["user_id = ? AND user_type = 1"];
    $params = [$currentUser['user_id']];
    
    if ($statusFilter !== null) {
        $whereConditions[] = "status = ?";
        $params[] = $statusFilter;
    }
    
    $whereClause = implode(' AND ', $whereConditions);
    
    // 1. 查询总记录数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM withdraw_requests 
        WHERE {$whereClause}
    ");
    $stmt->execute($params);
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 查询提现记录（分页）
    $stmt = $db->prepare("
        SELECT
            id,
            amount,
            fee_rate,
            fee_amount,
            actual_amount,
            withdraw_method,
            withdraw_account,
            status,
            reject_reason,
            img_url,
            reviewed_at,
            created_at
        FROM withdraw_requests 
        WHERE {$whereClause}
        ORDER BY created_at DESC, id DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $withdrawRecords = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 格式化记录
    $statusTexts = [
        0 => '待审核',
        1 => '审核通过',
        2 => '审核拒绝'
    ];
    
    $formattedRecords = [];
    foreach ($withdrawRecords as $record) {
        $formattedRecords[] = [
            'id' => (int)$record['id'],
            'amount' => number_format($record['amount'] / 100, 2),
            'fee_rate' => (float)$record['fee_rate'],
            'fee_amount' => number_format($record['fee_amount'] / 100, 2),
            'actual_amount' => number_format($record['actual_amount'] / 100, 2),
            'withdraw_method' => $record['withdraw_method'],
            'withdraw_account' => $record['withdraw_account'],
            'status' => (int)$record['status'],
            'status_text' => $statusTexts[(int)$record['status']] ?? '未知',
            'reject_reason' => $record['reject_reason'],
            'img_url' => $record['img_url'],
            'reviewed_at' => $record['reviewed_at'],
            'created_at' => $record['created_at']
        ];
    }
    
    // 4. 计算总页数
    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;
    
    // 5. 返回成功响应
    Response::success([
        'list' => $formattedRecords,
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
