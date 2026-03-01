<?php
/**
 * Admin - 关闭工单
 * POST /task_admin/api/rental_tickets/close.php
 * 
 * 请求体：
 * {
 *   "ticket_id": 1,
 *   "close_reason": "问题已解决"
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
$closeReason = trim($input['close_reason'] ?? '管理员关闭工单');

// 参数校验
if ($ticketId <= 0) {
    Response::error('工单ID无效', $errorCodes['INVALID_PARAMS']);
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

    // 检查工单是否已关闭
    if ((int)$ticket['status'] === 2) {
        $db->rollBack();
        Response::error('工单已经关闭', $errorCodes['RENTAL_TICKET_ALREADY_CLOSED']);
    }

    // 关闭工单
    $updateStmt = $db->prepare("
        UPDATE rental_tickets 
        SET status = 2, closed_at = NOW(), updated_at = NOW()
        WHERE id = ?
    ");
    $updateStmt->execute([$ticketId]);

    // 添加系统消息
    $systemMessage = "工单已由管理员关闭。原因：{$closeReason}";
    $insertStmt = $db->prepare("
        INSERT INTO rental_ticket_messages 
        (ticket_id, sender_type, sender_id, message_type, content, is_read, created_at)
        VALUES (?, 4, NULL, 0, ?, 1, NOW())
    ");
    $insertStmt->execute([$ticketId, $systemMessage]);

    // 准备通知
    $notifications = [
        [
            'user_id' => $ticket['buyer_user_id'],
            'user_type' => ($ticket['buyer_user_type'] === 'c' || $ticket['buyer_user_type'] === '1') ? 1 : 2,
            'title' => '工单已关闭',
            'content' => "工单「{$ticket['title']}」已被管理员关闭。{$closeReason}",
            'related_type' => 'rental_ticket',
            'related_id' => $ticketId
        ],
        [
            'user_id' => $ticket['seller_user_id'],
            'user_type' => ($ticket['seller_user_type'] === 'c' || $ticket['seller_user_type'] === '1') ? 1 : 2,
            'title' => '工单已关闭',
            'content' => "工单「{$ticket['title']}」已被管理员关闭。{$closeReason}",
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
            error_log("发送工单关闭通知失败: " . $e->getMessage());
        }
    }

    Response::success([
        'ticket_id' => $ticketId,
        'closed_at' => date('Y-m-d H:i:s')
    ], '工单关闭成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Admin关闭工单错误: " . $e->getMessage());
    Response::error('关闭工单失败: ' . $e->getMessage(), $errorCodes['RENTAL_TICKET_CLOSE_FAILED']);
}
