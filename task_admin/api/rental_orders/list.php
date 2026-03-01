<?php
/**
 * 租赁订单列表 (Admin)
 * GET /task_admin/api/rental_orders/list.php
 * 
 * 参数：
 * - page: 页码，默认1
 * - limit: 每页数量，默认10
 * - status: 状态筛选 (0=待支付, 1=已支付/待客服, 2=进行中, 3=已完成, 4=已取消)
 * - order_id: 订单ID筛选
 * - buyer_id: 买家ID
 * - seller_id: 卖家ID
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

$admin = AdminAuthMiddleware::authenticate();
$db = Database::connect();

$page = max(1, intval($_GET['page'] ?? 1));
$limit = max(1, min(100, intval($_GET['limit'] ?? 10)));
$offset = ($page - 1) * $limit;

$conditions = [];
$params = [];

if (isset($_GET['status']) && $_GET['status'] !== '') {
    $conditions[] = "ro.status = ?";
    $params[] = intval($_GET['status']);
}

if (!empty($_GET['order_id'])) {
    $conditions[] = "ro.id = ?";
    $params[] = intval($_GET['order_id']);
}

if (!empty($_GET['buyer_id'])) {
    $conditions[] = "ro.buyer_user_id = ?";
    $params[] = intval($_GET['buyer_id']);
}

if (!empty($_GET['seller_id'])) {
    $conditions[] = "ro.seller_user_id = ?";
    $params[] = intval($_GET['seller_id']);
}

$whereClause = $conditions ? "WHERE " . implode(" AND ", $conditions) : "";

try {
    // 总数
    $countStmt = $db->prepare("SELECT COUNT(*) FROM rental_orders ro $whereClause");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();

    // 列表
    $sql = "
        SELECT 
            ro.*,
            COALESCE(cu_buyer.username, bu_buyer.username, '未知用户') as buyer_username,
            COALESCE(cu_seller.username, bu_seller.username, '未知用户') as seller_username
        FROM rental_orders ro
        LEFT JOIN c_users cu_buyer ON (ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1') AND ro.buyer_user_id = cu_buyer.id
        LEFT JOIN b_users bu_buyer ON (ro.buyer_user_type = 'b' OR ro.buyer_user_type = '2') AND ro.buyer_user_id = bu_buyer.id
        LEFT JOIN c_users cu_seller ON (ro.seller_user_type = 'c' OR ro.seller_user_type = '1') AND ro.seller_user_id = cu_seller.id
        LEFT JOIN b_users bu_seller ON (ro.seller_user_type = 'b' OR ro.seller_user_type = '2') AND ro.seller_user_id = bu_seller.id
        $whereClause
        ORDER BY ro.created_at DESC
        LIMIT $limit OFFSET $offset
    ";

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 处理 JSON 字段
    foreach ($orders as &$order) {
        $order['buyer_info_json'] = json_decode($order['buyer_info_json'] ?? '{}', true);
        $order['seller_info_json'] = json_decode($order['seller_info_json'] ?? '{}', true);
        $order['order_json'] = json_decode($order['order_json'] ?? '{}', true);
    }

    echo json_encode([
        'code' => 0,
        'message' => '获取成功',
        'data' => [
            'list' => $orders,
            'pagination' => [
                'page' => $page,
                'page_size' => $limit,
                'total' => (int)$total,
                'total_pages' => $total > 0 ? (int)ceil($total / $limit) : 0
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '系统错误：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
