<?php
/**
 * 获取工单消息列表
 * GET /api/rental/tickets/messages?ticket_id=1&page=1&page_size=20
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求参数：
 * - ticket_id: 工单ID（必填）
 * - page: 页码（选填，默认1）
 * - page_size: 每页条数（选填，默认20，最大100）
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "获取成功",
 *   "data": {
 *     "ticket_id": 1,
 *     "ticket_no": "TK20260114123456",
 *     "ticket_status": 0,
 *     "messages": [
 *       {
 *         "id": 1,
 *         "sender_type": 4,
 *         "sender_type_text": "系统",
 *         "sender_id": null,
 *         "sender_name": "系统",
 *         "message_type": 3,
 *         "message_type_text": "系统通知",
 *         "content": "【工单已创建】...",
 *         "attachments": null,
 *         "is_read": 1,
 *         "is_mine": false,
 *         "created_at": "2026-01-14 12:34:56"
 *       }
 *     ],
 *     "pagination": {
 *       "page": 1,
 *       "page_size": 20,
 *       "total": 5,
 *       "total_pages": 1
 *     }
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 权限：买方或卖方可查看
 * 说明：查看消息列表时，非自己发送的消息会自动标记为已读
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
$ticketId = intval($_GET['ticket_id'] ?? 0);
$page = max(1, intval($_GET['page'] ?? 1));
$pageSize = min(100, max(1, intval($_GET['page_size'] ?? 20)));

// 参数校验
if ($ticketId <= 0) {
    Response::error('工单ID无效', $errorCodes['INVALID_PARAMS']);
}

try {
    $userTypeStr = ($userType === 1) ? 'c' : 'b';

    // 查询工单信息并验证权限
    $ticketStmt = $db->prepare("
        SELECT 
            rt.id, rt.ticket_no, rt.title, rt.status,
            ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type
        FROM rental_tickets rt
        INNER JOIN rental_orders ro ON rt.order_id = ro.id
        WHERE rt.id = ?
    ");
    $ticketStmt->execute([$ticketId]);
    $ticket = $ticketStmt->fetch(PDO::FETCH_ASSOC);

    if (!$ticket) {
        Response::error('工单不存在', $errorCodes['RENTAL_TICKET_NOT_FOUND']);
    }

    // 权限检查：只有买方或卖方可以查看消息
    $isBuyer = ($ticket['buyer_user_id'] == $userId && 
                ($ticket['buyer_user_type'] === $userTypeStr || intval($ticket['buyer_user_type']) === $userType));
    $isSeller = ($ticket['seller_user_id'] == $userId && 
                 ($ticket['seller_user_type'] === $userTypeStr || intval($ticket['seller_user_type']) === $userType));

    if (!$isBuyer && !$isSeller) {
        Response::error('无权查看此工单消息', $errorCodes['RENTAL_TICKET_NO_PERMISSION']);
    }

    // 查询消息总数
    $countStmt = $db->prepare("SELECT COUNT(*) as total FROM rental_ticket_messages WHERE ticket_id = ?");
    $countStmt->execute([$ticketId]);
    $total = intval($countStmt->fetch(PDO::FETCH_ASSOC)['total']);

    $totalPages = $total > 0 ? ceil($total / $pageSize) : 1;
    $offset = ($page - 1) * $pageSize;

    // 查询消息列表（按时间正序）
    $messagesStmt = $db->prepare("
        SELECT 
            rtm.id, rtm.sender_type, rtm.sender_id, rtm.message_type, 
            rtm.content, rtm.attachments, rtm.is_read, rtm.created_at,
            CASE 
                WHEN rtm.sender_type = 1 THEN cu.username
                WHEN rtm.sender_type = 2 THEN bu.username
                WHEN rtm.sender_type = 3 THEN 'Admin'
                WHEN rtm.sender_type = 4 THEN '系统'
                ELSE NULL
            END as sender_name
        FROM rental_ticket_messages rtm
        LEFT JOIN c_users cu ON rtm.sender_type = 1 AND rtm.sender_id = cu.id
        LEFT JOIN b_users bu ON rtm.sender_type = 2 AND rtm.sender_id = bu.id
        WHERE rtm.ticket_id = ?
        ORDER BY rtm.created_at ASC
        LIMIT {$pageSize} OFFSET {$offset}
    ");
    $messagesStmt->execute([$ticketId]);
    $messages = $messagesStmt->fetchAll(PDO::FETCH_ASSOC);

    // 格式化消息
    $senderTypeText = [1 => 'C端用户', 2 => 'B端用户', 3 => 'Admin', 4 => '系统'];
    $messageTypeText = [0 => '文本', 1 => '图片', 2 => '文件', 3 => '系统通知'];

    $formattedMessages = array_map(function($msg) use ($userId, $userType, $senderTypeText, $messageTypeText) {
        $isMine = ($msg['sender_id'] == $userId && $msg['sender_type'] == $userType);
        
        return [
            'id' => intval($msg['id']),
            'sender_type' => intval($msg['sender_type']),
            'sender_type_text' => $senderTypeText[$msg['sender_type']] ?? '未知',
            'sender_id' => $msg['sender_id'] ? intval($msg['sender_id']) : null,
            'sender_name' => $msg['sender_name'] ?? '未知',
            'message_type' => intval($msg['message_type']),
            'message_type_text' => $messageTypeText[$msg['message_type']] ?? '未知',
            'content' => $msg['content'],
            'attachments' => $msg['attachments'] ? json_decode($msg['attachments'], true) : null,
            'is_read' => intval($msg['is_read']),
            'is_mine' => $isMine,
            'created_at' => $msg['created_at']
        ];
    }, $messages);

    // 标记消息为已读（非自己发送的消息）
    if (count($messages) > 0) {
        $markReadStmt = $db->prepare("
            UPDATE rental_ticket_messages 
            SET is_read = 1 
            WHERE ticket_id = ? 
            AND (sender_id != ? OR sender_type != ? OR sender_id IS NULL)
            AND is_read = 0
        ");
        $markReadStmt->execute([$ticketId, $userId, $userType]);
    }

    Response::success([
        'ticket_id' => $ticketId,
        'ticket_no' => $ticket['ticket_no'],
        'ticket_status' => intval($ticket['status']),
        'messages' => $formattedMessages,
        'pagination' => [
            'page' => $page,
            'page_size' => $pageSize,
            'total' => $total,
            'total_pages' => $totalPages
        ]
    ], '获取成功');

} catch (PDOException $e) {
    Response::error('获取消息列表失败：' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
} catch (Exception $e) {
    Response::error($e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
