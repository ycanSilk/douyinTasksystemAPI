<?php
/**
 * 我出租的订单列表
 * GET /api/rental/orders/my-seller
 * 
 * 查询参数：
 * - page: 页码，默认1
 * - limit: 每页数量，默认10
 * - status: 状态筛选（可选）0=待支付, 1=已支付/待客服, 2=进行中, 3=已完成, 4=已取消
 * 
 * 说明：
 * - B端和C端通用
 * - 返回当前用户作为出租方（seller）的所有订单
 * - 包含买方（租用方）的基本信息
 * - 包含订单详细信息和时间信息
 */

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';
$db = Database::connect();

// 认证
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type'];

// 获取参数
$page = max(1, intval($_GET['page'] ?? 1));
$limit = max(1, min(100, intval($_GET['limit'] ?? 10)));
$offset = ($page - 1) * $limit;
$status = isset($_GET['status']) && $_GET['status'] !== '' ? intval($_GET['status']) : null;

try {
    // 构建查询条件
    $conditions = [];
    $params = [];
    
    // 必须是当前用户作为卖方
    $userTypeStr = $userType == 1 ? 'c' : 'b';
    $conditions[] = "ro.seller_user_id = ?";
    $conditions[] = "(ro.seller_user_type = ? OR ro.seller_user_type = ?)";
    $params[] = $userId;
    $params[] = $userTypeStr;
    $params[] = strval($userType); // 兼容 '1'/'2' 格式
    
    // 状态筛选
    if ($status !== null) {
        $conditions[] = "ro.status = ?";
        $params[] = $status;
    }
    
    $whereClause = "WHERE " . implode(" AND ", $conditions);
    
    // 查询总数
    $countStmt = $db->prepare("SELECT COUNT(*) FROM rental_orders ro $whereClause");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // 查询订单列表
    $sql = "
        SELECT 
            ro.*,
            CASE 
                WHEN ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1' THEN cu_buyer.username
                ELSE bu_buyer.username
            END as buyer_username,
            CASE 
                WHEN ro.seller_user_type = 'c' OR ro.seller_user_type = '1' THEN cu_seller.username
                ELSE bu_seller.username
            END as seller_username
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
    
    // 处理数据
    $statusMap = [
        0 => '待支付',
        1 => '已支付/待客服',
        2 => '进行中',
        3 => '已完成',
        4 => '已取消'
    ];
    
    $sourceTypeMap = [
        0 => '出租信息成交',
        1 => '求租信息成交'
    ];
    
    foreach ($orders as &$order) {
        // 解析 JSON 字段
        $order['order_json'] = json_decode($order['order_json'] ?? '{}', true);
        $order['buyer_info_json'] = json_decode($order['buyer_info_json'] ?? '{}', true);
        $order['seller_info_json'] = json_decode($order['seller_info_json'] ?? '{}', true);
        
        // 添加状态文本
        $order['status_text'] = $statusMap[$order['status']] ?? '未知';
        $order['source_type_text'] = $sourceTypeMap[$order['source_type']] ?? '未知';
        
        // 添加用户类型文本
        $order['buyer_user_type_text'] = ($order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1') ? 'C端' : 'B端';
        $order['seller_user_type_text'] = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 'C端' : 'B端';
        
        // 格式化金额（分转元）
        $order['total_amount_yuan'] = number_format($order['total_amount'] / 100, 2);
        $order['platform_amount_yuan'] = number_format($order['platform_amount'] / 100, 2);
        $order['seller_amount_yuan'] = number_format($order['seller_amount'] / 100, 2);
        
        // 时间信息
        $order['start_time'] = $order['order_json']['start_time'] ?? null;
        $order['end_time'] = $order['order_json']['end_time'] ?? null;
        $order['start_time_text'] = $order['start_time'] ? date('Y-m-d H:i:s', $order['start_time']) : null;
        $order['end_time_text'] = $order['end_time'] ? date('Y-m-d H:i:s', $order['end_time']) : null;
        
        // 续租历史
        $order['renew_history'] = $order['order_json']['renew_history'] ?? [];
        $order['renew_count'] = count($order['renew_history']);
    }
    
    echo json_encode([
        'code' => 0,
        'message' => '获取成功',
        'data' => [
            'list' => $orders,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
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
