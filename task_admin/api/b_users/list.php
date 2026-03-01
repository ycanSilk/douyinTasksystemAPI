<?php
/**
 * B端用户列表
 * GET /task_admin/api/b_users/list.php
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
$search = trim($_GET['search'] ?? '');

try {
    // 查询总数
    $whereClause = '';
    $params = [];
    if ($search) {
        $whereClause = 'WHERE username LIKE ? OR email LIKE ? OR organization_name LIKE ?';
        $params = ["%{$search}%", "%{$search}%", "%{$search}%"];
    }
    
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM b_users $whereClause");
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 查询列表
    $stmt = $db->prepare("
        SELECT 
            b.id, b.username, b.email, b.phone, b.organization_name, 
            b.organization_leader, b.wallet_id, b.status, b.reason,
            b.create_ip, b.created_at, b.updated_at, w.balance
        FROM b_users b
        LEFT JOIN wallets w ON b.wallet_id = w.id
        $whereClause
        ORDER BY b.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute(array_merge($params, [$pageSize, $offset]));
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $today = date('Y-m-d');
    
    // 格式化数据并添加统计
    foreach ($list as &$item) {
        $userId = (int)$item['id'];
        
        // 总发布数
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM b_tasks WHERE b_user_id = ?");
        $stmt2->execute([$userId]);
        $item['total_tasks'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 当日发布数
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM b_tasks WHERE b_user_id = ? AND DATE(created_at) = ?");
        $stmt2->execute([$userId, $today]);
        $item['today_tasks'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 当前待审核数
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE b_user_id = ? AND status = 2");
        $stmt2->execute([$userId]);
        $item['reviewing_tasks'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 驳回总数
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE b_user_id = ? AND status = 4");
        $stmt2->execute([$userId]);
        $item['total_rejected'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 当日驳回数
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE b_user_id = ? AND status = 4 AND DATE(reviewed_at) = ?");
        $stmt2->execute([$userId, $today]);
        $item['today_rejected'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        $item['id'] = $userId;
        $item['wallet_id'] = (int)$item['wallet_id'];
        $item['status'] = (int)$item['status'];
        $item['balance'] = number_format((int)$item['balance'] / 100, 2);
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
