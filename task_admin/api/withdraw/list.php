<?php
/**
 * 提现申请列表
 * GET /task_admin/api/withdraw/list.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;
$status = !empty($_GET['status']) || $_GET['status'] === '0' ? (int)$_GET['status'] : null;

try {
    $whereClause = '';
    $params = [];
    if ($status !== null) {
        $whereClause = 'WHERE status = ?';
        $params[] = $status;
    }
    
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM withdraw_requests $whereClause");
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    $stmt = $db->prepare("
        SELECT *
        FROM withdraw_requests
        $whereClause
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute(array_merge($params, [$pageSize, $offset]));
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($list as &$item) {
        $item['id'] = (int)$item['id'];
        $item['user_id'] = (int)$item['user_id'];
        $item['user_type'] = (int)$item['user_type'];
        $item['wallet_id'] = (int)$item['wallet_id'];
        $item['amount'] = number_format((int)$item['amount'] / 100, 2);
        $item['fee_rate'] = (float)($item['fee_rate'] ?? 0);
        $item['fee_amount'] = number_format((int)($item['fee_amount'] ?? 0) / 100, 2);
        $item['actual_amount'] = number_format((int)($item['actual_amount'] ?? 0) / 100, 2);
        $item['status'] = (int)$item['status'];
        $item['log_id'] = $item['log_id'] ? (int)$item['log_id'] : null;
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => [
            'list' => $list,
            'pagination' => [
                'page' => $page,
                'page_size' => $pageSize,
                'total' => $total,
                'total_pages' => $total > 0 ? (int)ceil($total / $pageSize) : 0
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '查询失败', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
