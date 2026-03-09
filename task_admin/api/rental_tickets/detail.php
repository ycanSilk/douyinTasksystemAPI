<?php
/**
 * Admin - 工单详情
 * GET /task_admin/api/rental_tickets/detail.php?ticket=1
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../config/error_codes.php';


// Admin验证
AdminAuthMiddleware::authenticate();

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 获取参数
$ticket = trim($_GET['ticket'] ?? '');

// 参数校验
if (empty($ticket)) {
    Response::error('请提供工单ID或工单号', $errorCodes['INVALID_PARAMS']);
}

try {
    $db = Database::connect();
    
    // 判断是工单ID还是工单号
    $isTicketNo = !is_numeric($ticket) || strpos($ticket, 'TK') === 0;
    
    // 查询工单信息及关联订单
    if ($isTicketNo) {
        $stmt = $db->prepare("
            SELECT 
                rt.id, rt.ticket_no, rt.order_id, rt.creator_user_id, rt.creator_user_type,
                rt.title, rt.description, rt.status, rt.handler_id,
                rt.created_at, rt.updated_at, rt.closed_at,
                ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type,
                ro.buyer_wallet_id, ro.seller_wallet_id,
                ro.total_amount, ro.platform_amount, ro.seller_amount, ro.days, 
                ro.status as order_status, ro.source_type,
                ro.buyer_info_json, ro.seller_info_json, ro.order_json,
                ro.created_at as order_created_at,
                CASE 
                    WHEN ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1' THEN COALESCE(cu_buyer.username, '未知用户')
                    ELSE COALESCE(bu_buyer.username, '未知用户')
                END as buyer_username,
                CASE 
                    WHEN ro.seller_user_type = 'c' OR ro.seller_user_type = '1' THEN COALESCE(cu_seller.username, '未知用户')
                    ELSE COALESCE(bu_seller.username, '未知用户')
                END as seller_username
            FROM rental_tickets rt
            INNER JOIN rental_orders ro ON rt.order_id = ro.id
            LEFT JOIN c_users cu_buyer ON (ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1') AND ro.buyer_user_id = cu_buyer.id
            LEFT JOIN b_users bu_buyer ON (ro.buyer_user_type = 'b' OR ro.buyer_user_type = '2') AND ro.buyer_user_id = bu_buyer.id
            LEFT JOIN c_users cu_seller ON (ro.seller_user_type = 'c' OR ro.seller_user_type = '1') AND ro.seller_user_id = cu_seller.id
            LEFT JOIN b_users bu_seller ON (ro.seller_user_type = 'b' OR ro.seller_user_type = '2') AND ro.seller_user_id = bu_seller.id
            WHERE rt.ticket_no = ?
        ");
        $stmt->execute([$ticket]);
    } else {
        $ticketId = intval($ticket);
        $stmt = $db->prepare("
            SELECT 
                rt.id, rt.ticket_no, rt.order_id, rt.creator_user_id, rt.creator_user_type,
                rt.title, rt.description, rt.status, rt.handler_id,
                rt.created_at, rt.updated_at, rt.closed_at,
                ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type,
                ro.buyer_wallet_id, ro.seller_wallet_id,
                ro.total_amount, ro.platform_amount, ro.seller_amount, ro.days, 
                ro.status as order_status, ro.source_type,
                ro.buyer_info_json, ro.seller_info_json, ro.order_json,
                ro.created_at as order_created_at,
                CASE 
                    WHEN ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1' THEN COALESCE(cu_buyer.username, '未知用户')
                    ELSE COALESCE(bu_buyer.username, '未知用户')
                END as buyer_username,
                CASE 
                    WHEN ro.seller_user_type = 'c' OR ro.seller_user_type = '1' THEN COALESCE(cu_seller.username, '未知用户')
                    ELSE COALESCE(bu_seller.username, '未知用户')
                END as seller_username
            FROM rental_tickets rt
            INNER JOIN rental_orders ro ON rt.order_id = ro.id
            LEFT JOIN c_users cu_buyer ON (ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1') AND ro.buyer_user_id = cu_buyer.id
            LEFT JOIN b_users bu_buyer ON (ro.buyer_user_type = 'b' OR ro.buyer_user_type = '2') AND ro.buyer_user_id = bu_buyer.id
            LEFT JOIN c_users cu_seller ON (ro.seller_user_type = 'c' OR ro.seller_user_type = '1') AND ro.seller_user_id = cu_seller.id
            LEFT JOIN b_users bu_seller ON (ro.seller_user_type = 'b' OR ro.seller_user_type = '2') AND ro.seller_user_id = bu_seller.id
            WHERE rt.id = ?
        ");
        $stmt->execute([$ticketId]);
    }
    
    $ticketData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$ticketData) {
        Response::error('工单不存在', $errorCodes['RENTAL_TICKET_NOT_FOUND']);
    }
    
    // 统一获取工单ID
    $ticketId = intval($ticketData['id']);
    
    // 查询所有消息
    $messagesStmt = $db->prepare("
        SELECT 
            id, sender_type, sender_id, message_type, content, attachments, 
            is_read, created_at
        FROM rental_ticket_messages
        WHERE ticket_id = ?
        ORDER BY created_at ASC
    ");
    $messagesStmt->execute([$ticketId]);
    $messages = $messagesStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化消息
    $formattedMessages = [];
    $senderTypeTexts = [
        0 => '未知',
        1 => 'C端用户',
        2 => 'B端用户',
        3 => '管理员',
        4 => '系统'
    ];
    
    foreach ($messages as $msg) {
        $senderType = intval($msg['sender_type']);
        $messageData = [
            'id' => intval($msg['id']),
            'sender_type' => $senderType,
            'sender_type_text' => $senderTypeTexts[$senderType] ?? '未知',
            'sender_id' => $msg['sender_id'] ? intval($msg['sender_id']) : null,
            'message_type' => intval($msg['message_type']),
            'message_type_text' => (intval($msg['message_type']) === 0) ? '文本' : '图片',
            'content' => $msg['content'],
            'attachments' => null,
            'is_read' => (bool)$msg['is_read'],
            'created_at' => $msg['created_at']
        ];
        
        // 解析附件
        if (!empty($msg['attachments'])) {
            $messageData['attachments'] = json_decode($msg['attachments'], true);
        }
        
        // 标识是买家还是卖家
        if ($senderType === 1 || $senderType === 2) {
            if ($msg['sender_id'] == $ticketData['buyer_user_id']) {
                $messageData['role'] = 'buyer';
                $messageData['role_text'] = '买家';
            } elseif ($msg['sender_id'] == $ticketData['seller_user_id']) {
                $messageData['role'] = 'seller';
                $messageData['role_text'] = '卖家';
            } else {
                $messageData['role'] = 'unknown';
                $messageData['role_text'] = '未知';
            }
        } else {
            $messageData['role'] = null;
            $messageData['role_text'] = null;
        }
        
        $formattedMessages[] = $messageData;
    }
    
    // 返回详细信息
    $statusTexts = [0 => '待处理', 1 => '处理中', 2 => '已关闭'];
    $orderStatusTexts = [0 => '已支付/待客服', 1 => '待支付', 2 => '进行中', 3 => '已完成', 4 => '已退款'];
    
    $result = [
        'ticket_id' => $ticketId,
        'ticket_no' => $ticketData['ticket_no'],
        'title' => $ticketData['title'],
        'description' => $ticketData['description'],
        'status' => (int)$ticketData['status'],
        'status_text' => $statusTexts[(int)$ticketData['status']] ?? '未知',
        'creator_user_id' => (int)$ticketData['creator_user_id'],
        'creator_user_type' => $ticketData['creator_user_type'],
        'handler_id' => $ticketData['handler_id'] ? (int)$ticketData['handler_id'] : null,
        'created_at' => $ticketData['created_at'],
        'updated_at' => $ticketData['updated_at'],
        'closed_at' => $ticketData['closed_at'],
        'order_info' => [
            'order_id' => (int)$ticketData['order_id'],
            'source_type' => (int)$ticketData['source_type'],
            'source_type_text' => ((int)$ticketData['source_type'] === 1) ? '求租' : '出租',
            'buyer_user_id' => (int)$ticketData['buyer_user_id'],
            'buyer_username' => $ticketData['buyer_username'],
            'seller_user_id' => (int)$ticketData['seller_user_id'],
            'seller_username' => $ticketData['seller_username'],
            'total_amount' => (int)$ticketData['total_amount'],
            'total_amount_yuan' => number_format($ticketData['total_amount'] / 100, 2),
            'platform_amount' => (int)$ticketData['platform_amount'],
            'platform_amount_yuan' => number_format($ticketData['platform_amount'] / 100, 2),
            'seller_amount' => (int)$ticketData['seller_amount'],
            'seller_amount_yuan' => number_format($ticketData['seller_amount'] / 100, 2),
            'days' => (int)$ticketData['days'],
            'order_status' => (int)$ticketData['order_status'],
            'order_status_text' => $orderStatusTexts[(int)$ticketData['order_status']] ?? '未知',
            'buyer_info_json' => json_decode($ticketData['buyer_info_json'], true),
            'seller_info_json' => json_decode($ticketData['seller_info_json'], true),
            'order_json' => json_decode($ticketData['order_json'], true),
            'order_created_at' => $ticketData['order_created_at']
        ],
        'messages' => $formattedMessages
    ];
    
    Response::success($result, '获取成功');
    
} catch (Exception $e) {
    error_log("Admin工单详情错误: " . $e->getMessage());
    Response::error('获取工单详情失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
