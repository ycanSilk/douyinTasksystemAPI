<?php
/**
 * Admin - 发送工单消息
 * POST /task_admin/api/rental_tickets/send-message.php
 * 
 * 请求体：
 * {
 *   "ticket_id": 1,
 *   "message_type": 0,
 *   "content": "我们正在处理您的问题",
 *   "attachments": ["https://example.com/image1.jpg"]
 * }
 */

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/Notification.php';
require_once __DIR__ . '/../../../config/error_codes.php';

header('Content-Type: application/json; charset=utf-8');

// Admin验证
$adminUser = AdminAuthMiddleware::authenticate();
$adminId = $adminUser['id'] ?? 0;

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 获取POST数据
$input = json_decode(file_get_contents('php://input'), true);
$ticketId = intval($input['ticket_id'] ?? 0);
$messageType = intval($input['message_type'] ?? 0);
$content = trim($input['content'] ?? '');
$attachments = $input['attachments'] ?? null;

// 参数校验
if ($ticketId <= 0) {
    Response::error('工单ID无效', $errorCodes['INVALID_PARAMS']);
}

if (!in_array($messageType, [0, 1])) {
    Response::error('消息类型无效（0=文本, 1=图片）', $errorCodes['INVALID_PARAMS']);
}

if (empty($content)) {
    Response::error('消息内容不能为空', $errorCodes['INVALID_PARAMS']);
}

if (mb_strlen($content) > 2000) {
    Response::error('消息内容最多2000字符', $errorCodes['INVALID_PARAMS']);
}

// 图片消息必须有附件
if ($messageType === 1) {
    if (!$attachments || !is_array($attachments) || count($attachments) === 0) {
        Response::error('图片消息必须包含图片链接', $errorCodes['INVALID_PARAMS']);
    }
    
    // 限制最多3张图片
    if (count($attachments) > 3) {
        Response::error('最多支持上传3张图片', $errorCodes['INVALID_PARAMS']);
    }
    
    // 验证图片链接格式
    foreach ($attachments as $imageUrl) {
        if (!is_string($imageUrl) || empty(trim($imageUrl))) {
            Response::error('图片链接不能为空', $errorCodes['INVALID_PARAMS']);
        }
        
        if (!filter_var($imageUrl, FILTER_VALIDATE_URL)) {
            Response::error('图片链接格式无效', $errorCodes['INVALID_PARAMS']);
        }
    }
    
    $attachments = array_values($attachments);
}

try {
    $db = Database::connect();
    $db->beginTransaction();

    // 查询工单信息
    $stmt = $db->prepare("
        SELECT 
            rt.id, rt.ticket_no, rt.title, rt.status,
            ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type
        FROM rental_tickets rt
        INNER JOIN rental_orders ro ON rt.order_id = ro.id
        WHERE rt.id = ?
    ");
    $stmt->execute([$ticketId]);
    $ticket = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$ticket) {
        $db->rollBack();
        Response::error('工单不存在', $errorCodes['RENTAL_TICKET_NOT_FOUND']);
    }

    // 检查工单状态
    if ((int)$ticket['status'] === 2) {
        $db->rollBack();
        Response::error('工单已关闭，无法发送消息', $errorCodes['RENTAL_TICKET_ALREADY_CLOSED']);
    }

    // 插入消息
    $attachmentsJson = $attachments ? json_encode($attachments, JSON_UNESCAPED_UNICODE) : null;
    
    $insertStmt = $db->prepare("
        INSERT INTO rental_ticket_messages 
        (ticket_id, sender_type, sender_id, message_type, content, attachments, is_read, created_at)
        VALUES (?, 3, ?, ?, ?, ?, 0, NOW())
    ");
    $insertStmt->execute([
        $ticketId,
        $adminId,
        $messageType,
        $content,
        $attachmentsJson
    ]);
    
    $messageId = $db->lastInsertId();

    // 更新工单状态为处理中（如果是待处理）
    if ((int)$ticket['status'] === 0) {
        $updateStmt = $db->prepare("
            UPDATE rental_tickets 
            SET status = 1, handler_id = ?, updated_at = NOW()
            WHERE id = ?
        ");
        $updateStmt->execute([$adminId, $ticketId]);
    } else {
        // 更新工单最后更新时间
        $updateStmt = $db->prepare("UPDATE rental_tickets SET updated_at = NOW() WHERE id = ?");
        $updateStmt->execute([$ticketId]);
    }

    // 准备通知（事务后发送）
    $notifications = [
        [
            'user_id' => $ticket['buyer_user_id'],
            'user_type' => ($ticket['buyer_user_type'] === 'c' || $ticket['buyer_user_type'] === '1') ? 1 : 2,
            'title' => '工单新消息',
            'content' => "工单「{$ticket['title']}」有新的管理员回复",
            'related_type' => 'rental_ticket',
            'related_id' => $ticketId
        ],
        [
            'user_id' => $ticket['seller_user_id'],
            'user_type' => ($ticket['seller_user_type'] === 'c' || $ticket['seller_user_type'] === '1') ? 1 : 2,
            'title' => '工单新消息',
            'content' => "工单「{$ticket['title']}」有新的管理员回复",
            'related_type' => 'rental_ticket',
            'related_id' => $ticketId
        ]
    ];

    $db->commit();
    
    // 发送通知
    foreach ($notifications as $notif) {
        try {
            Notification::sendToUser(
                $db,
                $notif['user_id'],
                $notif['user_type'],
                $notif['title'],
                $notif['content'],
                $notif['related_type'],
                $notif['related_id']
            );
        } catch (Exception $e) {
            error_log("发送工单消息通知失败: " . $e->getMessage());
        }
    }

    Response::success([
        'message_id' => (int)$messageId,
        'ticket_id' => $ticketId,
        'created_at' => date('Y-m-d H:i:s')
    ], '消息发送成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Admin发送工单消息错误: " . $e->getMessage());
    Response::error('发送消息失败: ' . $e->getMessage(), $errorCodes['RENTAL_TICKET_MESSAGE_SEND_FAILED']);
}
