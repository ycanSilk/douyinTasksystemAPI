<?php
/**
 * Admin - 工单列表
 * GET /task_admin/api/rental_tickets/list.php
 */

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../config/error_codes.php';

header('Content-Type: application/json; charset=utf-8');

// Admin验证
AdminAuthMiddleware::authenticate();

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

try {
    $db = Database::connect();
    
    // 获取请求参数
    $status = isset($_GET['status']) ? intval($_GET['status']) : null;
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $pageSize = isset($_GET['page_size']) ? max(1, min(100, intval($_GET['page_size']))) : 20;
    $offset = ($page - 1) * $pageSize;
    
    // 构建查询条件
    $whereClause = "1=1";
    $params = [];
    
    if ($status !== null && in_array($status, [0, 1, 2])) {
        $whereClause .= " AND rt.status = ?";
        $params[] = $status;
    }
    
    // 1. 查询总数
    $countStmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM rental_tickets rt
        WHERE {$whereClause}
    ");
    $countStmt->execute($params);
    $total = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 查询工单列表（分页）
    $stmt = $db->prepare("
        SELECT 
            rt.id, rt.ticket_no, rt.order_id, rt.creator_user_id, rt.creator_user_type,
            rt.title, rt.description, rt.status, rt.handler_id,
            rt.created_at, rt.updated_at, rt.closed_at,
            ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type,
            ro.total_amount, ro.days, ro.status as order_status, ro.source_type,
            CASE 
                WHEN ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1' THEN COALESCE(cu_buyer.username, '未知用户')
                ELSE COALESCE(bu_buyer.username, '未知用户')
            END as buyer_username,
            CASE 
                WHEN ro.seller_user_type = 'c' OR ro.seller_user_type = '1' THEN COALESCE(cu_seller.username, '未知用户')
                ELSE COALESCE(bu_seller.username, '未知用户')
            END as seller_username,
            CASE 
                WHEN rt.creator_user_type = 'c' OR rt.creator_user_type = '1' THEN COALESCE(cu_creator.username, '未知用户')
                ELSE COALESCE(bu_creator.username, '未知用户')
            END as creator_username,
            (SELECT COUNT(*) FROM rental_ticket_messages WHERE ticket_id = rt.id) as message_count,
            (SELECT COUNT(*) FROM rental_ticket_messages WHERE ticket_id = rt.id AND sender_type = 3 AND is_read = 0) as unread_admin_count
        FROM rental_tickets rt
        INNER JOIN rental_orders ro ON rt.order_id = ro.id
        LEFT JOIN c_users cu_buyer ON (ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1') AND ro.buyer_user_id = cu_buyer.id
        LEFT JOIN b_users bu_buyer ON (ro.buyer_user_type = 'b' OR ro.buyer_user_type = '2') AND ro.buyer_user_id = bu_buyer.id
        LEFT JOIN c_users cu_seller ON (ro.seller_user_type = 'c' OR ro.seller_user_type = '1') AND ro.seller_user_id = cu_seller.id
        LEFT JOIN b_users bu_seller ON (ro.seller_user_type = 'b' OR ro.seller_user_type = '2') AND ro.seller_user_id = bu_seller.id
        LEFT JOIN c_users cu_creator ON (rt.creator_user_type = 'c' OR rt.creator_user_type = '1') AND rt.creator_user_id = cu_creator.id
        LEFT JOIN b_users bu_creator ON (rt.creator_user_type = 'b' OR rt.creator_user_type = '2') AND rt.creator_user_id = bu_creator.id
        WHERE {$whereClause}
        ORDER BY rt.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 格式化工单列表
    $statusTexts = [
        0 => '待处理',
        1 => '处理中',
        2 => '已关闭'
    ];
    
    $orderStatusTexts = [
        0 => '已支付/待客服',
        1 => '待支付',
        2 => '进行中',
        3 => '已完成',
        4 => '已退款'
    ];
    
    $formattedTickets = [];
    foreach ($tickets as $ticket) {
        $formattedTickets[] = [
            'ticket_id' => (int)$ticket['id'],
            'ticket_no' => $ticket['ticket_no'],
            'title' => $ticket['title'],
            'description' => $ticket['description'],
            'status' => (int)$ticket['status'],
            'status_text' => $statusTexts[(int)$ticket['status']] ?? '未知',
            'order_id' => (int)$ticket['order_id'],
            'order_status' => (int)$ticket['order_status'],
            'order_status_text' => $orderStatusTexts[(int)$ticket['order_status']] ?? '未知',
            'source_type' => (int)$ticket['source_type'],
            'source_type_text' => ((int)$ticket['source_type'] === 1) ? '求租' : '出租',
            'buyer_username' => $ticket['buyer_username'],
            'seller_username' => $ticket['seller_username'],
            'creator_username' => $ticket['creator_username'],
            'creator_user_type' => $ticket['creator_user_type'],
            'message_count' => (int)$ticket['message_count'],
            'unread_admin_count' => (int)$ticket['unread_admin_count'],
            'handler_id' => $ticket['handler_id'] ? (int)$ticket['handler_id'] : null,
            'created_at' => $ticket['created_at'],
            'updated_at' => $ticket['updated_at'],
            'closed_at' => $ticket['closed_at']
        ];
    }
    
    // 4. 返回结果
    Response::success([
        'tickets' => $formattedTickets,
        'pagination' => [
            'current_page' => $page,
            'page_size' => $pageSize,
            'total' => (int)$total,
            'total_pages' => ceil($total / $pageSize)
        ]
    ], '获取成功');
    
} catch (Exception $e) {
    error_log("Admin工单列表错误: " . $e->getMessage());
    Response::error('获取工单列表失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
