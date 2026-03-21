<?php
/**
 * 关闭工单
 * POST /api/rental/tickets/close
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体：
 * {
 *   "ticket_id": 1,
 *   "close_reason": "问题已解决"
 * }
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "工单已关闭",
 *   "data": {
 *     "ticket_id": 1,
 *     "ticket_no": "TK20260114123456",
 *     "status": 3,
 *     "status_text": "已关闭"
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 权限：仅创建者可以关闭工单
 */

require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../config/error_codes.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Notification.php';

header('Content-Type: application/json; charset=utf-8');

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 身份验证（B/C端共用）
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type']; // 1=C端, 2=B端

// 获取POST数据
$input = json_decode(file_get_contents('php://input'), true);
$ticketId = intval($input['ticket_id'] ?? 0);
$closeReason = trim($input['close_reason'] ?? '用户主动关闭工单');

// 参数校验
if ($ticketId <= 0) {
    Response::error('工单ID无效', $errorCodes['INVALID_PARAMS']);
}

if (empty($closeReason)) {
    $closeReason = '用户主动关闭工单';
}

if (mb_strlen($closeReason) > 500) {
    Response::error('关闭原因最多500字符', $errorCodes['INVALID_PARAMS']);
}

try {
    $db->beginTransaction();

    // 查询工单信息
    $stmt = $db->prepare("
        SELECT 
            rt.id, rt.ticket_no, rt.order_id, rt.title, rt.status, 
            rt.creator_user_id, rt.creator_user_type,
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

    // 权限检查：只有创建者可以关闭工单
    if ($ticket['creator_user_id'] != $userId || $ticket['creator_user_type'] != $userType) {
        $db->rollBack();
        Response::error('只有工单创建者可以关闭工单', $errorCodes['RENTAL_TICKET_NO_PERMISSION']);
    }

    // 状态检查：已关闭的工单不能再关闭
    if ($ticket['status'] == 3) {
        $db->rollBack();
        Response::error('工单已关闭，无需重复操作', $errorCodes['RENTAL_TICKET_ALREADY_CLOSED']);
    }

    // 更新工单状态为已关闭（3）
    $updateStmt = $db->prepare("
        UPDATE rental_tickets 
        SET status = 3, closed_at = NOW(), updated_at = NOW()
        WHERE id = ?
    ");
    $updateStmt->execute([$ticketId]);

    // 添加系统消息
    $systemMessage = "━━━━━━━━━━━━━━━━\n";
    $systemMessage .= "【工单已关闭】\n";
    $systemMessage .= "工单编号：{$ticket['ticket_no']}\n";
    $systemMessage .= "关闭原因：{$closeReason}\n";
    $systemMessage .= "关闭时间：" . date('Y-m-d H:i:s') . "\n";
    $systemMessage .= "━━━━━━━━━━━━━━━━";

    $messageStmt = $db->prepare("
        INSERT INTO rental_ticket_messages (
            ticket_id, sender_type, sender_id, message_type, content, created_at
        ) VALUES (?, 4, NULL, 3, ?, NOW())
    ");
    $messageStmt->execute([$ticketId, $systemMessage]);

    $db->commit();

    // 通知出租方（卖方）
    $sellerUserId = $ticket['seller_user_id'];
    $sellerUserType = ($ticket['seller_user_type'] === 'c' || $ticket['seller_user_type'] === '1') ? 1 : 2;
    
    Notification::sendToUser(
        $db,
        $sellerUserId,
        $sellerUserType,
        '工单已关闭',
        "工单「{$ticket['title']}」已被关闭。工单编号：{$ticket['ticket_no']}",
        'rental_ticket',
        $ticketId
    );

    Response::success([
        'ticket_id' => $ticketId,
        'ticket_no' => $ticket['ticket_no'],
        'status' => 3,
        'status_text' => '已关闭'
    ], '工单已关闭');

} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error('关闭工单失败：' . $e->getMessage(), $errorCodes['RENTAL_TICKET_CLOSE_FAILED']);
} catch (Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error($e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
