<?php
/**
 * C端用户列表
 * GET /task_admin/api/c_users/list.php
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
    $whereClause = '';
    $params = [];
    if ($search) {
        $whereClause = 'WHERE c.username LIKE ? OR c.email LIKE ? OR c.invite_code LIKE ?';
        $params = ["%{$search}%", "%{$search}%", "%{$search}%"];
    }
    
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_users c $whereClause");
    $stmt->execute($params);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    $stmt = $db->prepare("
        SELECT 
            c.id, c.username, c.email, c.phone, c.invite_code, c.parent_id,
            c.is_agent, c.wallet_id, c.status, c.reason, c.create_ip,
            c.created_at, c.updated_at, w.balance, p.username as parent_username
        FROM c_users c
        LEFT JOIN wallets w ON c.wallet_id = w.id
        LEFT JOIN c_users p ON c.parent_id = p.id
        $whereClause
        ORDER BY c.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute(array_merge($params, [$pageSize, $offset]));
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $today = date('Y-m-d');
    
    foreach ($list as &$item) {
        $userId = (int)$item['id'];
        
        // 总完成单数（已通过）
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE c_user_id = ? AND status = 3");
        $stmt2->execute([$userId]);
        $item['total_completed'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 总通过
        $item['total_approved'] = $item['total_completed'];
        
        // 总驳回
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE c_user_id = ? AND status = 4");
        $stmt2->execute([$userId]);
        $item['total_rejected'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 当日完成单数（今日审核通过）
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE c_user_id = ? AND status = 3 AND DATE(reviewed_at) = ?");
        $stmt2->execute([$userId, $today]);
        $item['today_completed'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 当日通过
        $item['today_approved'] = $item['today_completed'];
        
        // 当日驳回
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE c_user_id = ? AND status = 4 AND DATE(reviewed_at) = ?");
        $stmt2->execute([$userId, $today]);
        $item['today_rejected'] = (int)$stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        
        $item['id'] = $userId;
        $item['wallet_id'] = (int)$item['wallet_id'];
        $item['parent_id'] = $item['parent_id'] ? (int)$item['parent_id'] : null;
        $item['is_agent'] = (int)$item['is_agent'];
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
