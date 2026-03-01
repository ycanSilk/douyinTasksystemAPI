<?php
/**
 * 查看工单详情
 * GET /api/rental/tickets/detail?ticket=1 或 ?ticket=TK20260114123456
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求参数：
 * - ticket: 工单ID或工单号（必填），支持数字ID或TK开头的工单号
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "获取成功",
 *   "data": {
 *     "ticket_id": 1,
 *     "ticket_no": "TK20260114123456",
 *     "title": "账号无法登录",
 *     "description": "账号密码错误...",
 *     "status": 0,
 *     "status_text": "待处理",
 *     "order_info": {...},
 *     "recent_messages": [...],
 *     "role": "buyer",
 *     "can_close": true,
 *     "can_send_message": true
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 权限：买方或卖方可查看
 */

require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../config/error_codes.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';

header('Content-Type: application/json; charset=utf-8');

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 身份验证（B/C端共用）
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type']; // 1=C端, 2=B端

// 获取参数
$ticket = trim($_GET['ticket'] ?? '');

// 参数校验
if (empty($ticket)) {
    Response::error('请提供工单ID或工单号', $errorCodes['INVALID_PARAMS']);
}

try {
    // 判断是工单ID还是工单号
    $isTicketNo = !is_numeric($ticket) || strpos($ticket, 'TK') === 0;
    
    // 查询工单信息及关联订单
    $userTypeStr = ($userType === 1) ? 'c' : 'b';
    
    if ($isTicketNo) {
        // 使用工单号查询
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
        // 使用工单ID查询
        $ticketId = intval($ticket);
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
    $ticket = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$ticket) {
        Response::error('工单不存在', $errorCodes['RENTAL_TICKET_NOT_FOUND']);
    }
    
    // 统一获取工单ID（无论是通过ID还是工单号查询）
    $ticketId = intval($ticket['id']);

    // 权限检查：只有买方或卖方可以查看
    $isBuyer = ($ticket['buyer_user_id'] == $userId && 
                ($ticket['buyer_user_type'] === $userTypeStr || intval($ticket['buyer_user_type']) === $userType));
    $isSeller = ($ticket['seller_user_id'] == $userId && 
                 ($ticket['seller_user_type'] === $userTypeStr || intval($ticket['seller_user_type']) === $userType));

    if (!$isBuyer && !$isSeller) {
        Response::error('无权查看此工单', $errorCodes['RENTAL_TICKET_NO_PERMISSION']);
    }

    // 获取最新10条消息
    $messagesStmt = $db->prepare("
        SELECT 
            id, sender_type, sender_id, message_type, content, attachments, 
            is_read, created_at
        FROM rental_ticket_messages
        WHERE ticket_id = ?
        ORDER BY created_at DESC
        LIMIT 10
    ");
    $messagesStmt->execute([$ticketId]);
    $recentMessages = $messagesStmt->fetchAll(PDO::FETCH_ASSOC);

    // 格式化消息
    $messages = array_reverse(array_map(function($msg) {
        return [
            'id' => intval($msg['id']),
            'sender_type' => intval($msg['sender_type']),
            'sender_type_text' => ['', 'C端', 'B端', 'Admin', '系统'][intval($msg['sender_type'])] ?? '未知',
            'sender_id' => $msg['sender_id'] ? intval($msg['sender_id']) : null,
            'message_type' => intval($msg['message_type']),
            'message_type_text' => ['文本', '图片', '文件', '系统通知'][intval($msg['message_type'])] ?? '未知',
            'content' => $msg['content'],
            'attachments' => $msg['attachments'] ? json_decode($msg['attachments'], true) : null,
            'is_read' => intval($msg['is_read']),
            'created_at' => $msg['created_at']
        ];
    }, $recentMessages));

    // 格式化工单状态
    $statusText = [
        0 => '待处理',
        1 => '处理中',
        2 => '已解决',
        3 => '已关闭'
    ];

    $orderStatusText = [
        0 => '待支付',
        1 => '待客服',
        2 => '进行中',
        3 => '已完成',
        4 => '已取消'
    ];

    $result = [
        'ticket_id' => intval($ticket['id']),
        'ticket_no' => $ticket['ticket_no'],
        'title' => $ticket['title'],
        'description' => $ticket['description'],
        'status' => intval($ticket['status']),
        'status_text' => $statusText[$ticket['status']] ?? '未知',
        'creator_user_id' => intval($ticket['creator_user_id']),
        'creator_user_type' => intval($ticket['creator_user_type']),
        'is_creator' => $ticket['creator_user_id'] == $userId,
        'handler_id' => $ticket['handler_id'] ? intval($ticket['handler_id']) : null,
        'created_at' => $ticket['created_at'],
        'updated_at' => $ticket['updated_at'],
        'closed_at' => $ticket['closed_at'],
        'order_info' => [
            'order_id' => intval($ticket['order_id']),
            'source_type' => intval($ticket['source_type']),
            'source_type_text' => $ticket['source_type'] == 0 ? '出租' : '求租',
            'buyer_user_id' => intval($ticket['buyer_user_id']),
            'buyer_username' => $ticket['buyer_username'],
            'seller_user_id' => intval($ticket['seller_user_id']),
            'seller_username' => $ticket['seller_username'],
            'total_amount' => intval($ticket['total_amount']),
            'total_amount_yuan' => number_format($ticket['total_amount'] / 100, 2),
            'days' => intval($ticket['days']),
            'order_status' => intval($ticket['order_status']),
            'order_status_text' => $orderStatusText[$ticket['order_status']] ?? '未知'
        ],
        'recent_messages' => $messages,
        'role' => $isBuyer ? 'buyer' : 'seller', // 当前用户在工单中的角色
        'can_close' => ($ticket['creator_user_id'] == $userId && in_array($ticket['status'], [0, 1, 2])), // 只有创建者且未关闭才能关闭
        'can_send_message' => in_array($ticket['status'], [0, 1, 2]) // 未关闭的工单可以发消息
    ];

    Response::success($result, '获取成功');

} catch (PDOException $e) {
    Response::error('获取工单失败：' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
} catch (Exception $e) {
    Response::error($e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
