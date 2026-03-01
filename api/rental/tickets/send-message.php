<?php
/**
 * 发送工单消息
 * POST /api/rental/tickets/send-message
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体（文本消息）：
 * {
 *   "ticket_id": 1,
 *   "message_type": 0,
 *   "content": "请问账号密码是多少？"
 * }
 * 
 * 请求体（图片消息）：
 * {
 *   "ticket_id": 1,
 *   "message_type": 1,
 *   "content": "这是截图，请查看",
 *   "attachments": [
 *     "https://example.com/image1.jpg",
 *     "https://example.com/image2.jpg"
 *   ]
 * }
 * 
 * 注意：attachments最多支持3张图片
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "消息发送成功",
 *   "data": {
 *     "message_id": 5,
 *     "ticket_id": 1,
 *     "created_at": "2026-01-14 13:00:00"
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 权限：买方或卖方可发送
 * 消息类型：0=文本, 1=图片
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
        
        // 简单验证URL格式
        if (!filter_var($imageUrl, FILTER_VALIDATE_URL)) {
            Response::error('图片链接格式无效', $errorCodes['INVALID_PARAMS']);
        }
    }
    
    // 转换为统一格式存储（为了兼容性，仍以JSON数组形式存储URL）
    $attachments = array_values($attachments); // 重新索引数组
}

try {
    $db->beginTransaction();

    $userTypeStr = ($userType === 1) ? 'c' : 'b';

    // 查询工单信息
    $stmt = $db->prepare("
        SELECT 
            rt.id, rt.ticket_no, rt.title, rt.status,
            ro.buyer_user_id, ro.buyer_user_type, ro.seller_user_id, ro.seller_user_type,
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
    $ticket = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$ticket) {
        $db->rollBack();
        Response::error('工单不存在', $errorCodes['RENTAL_TICKET_NOT_FOUND']);
    }

    // 权限检查：只有买方或卖方可以发送消息
    $isBuyer = ($ticket['buyer_user_id'] == $userId && 
                ($ticket['buyer_user_type'] === $userTypeStr || intval($ticket['buyer_user_type']) === $userType));
    $isSeller = ($ticket['seller_user_id'] == $userId && 
                 ($ticket['seller_user_type'] === $userTypeStr || intval($ticket['seller_user_type']) === $userType));

    if (!$isBuyer && !$isSeller) {
        $db->rollBack();
        Response::error('无权在此工单发送消息', $errorCodes['RENTAL_TICKET_NO_PERMISSION']);
    }

    // 状态检查：已关闭的工单不能发送消息
    if ($ticket['status'] == 3) {
        $db->rollBack();
        Response::error('工单已关闭，无法发送消息', $errorCodes['RENTAL_TICKET_INVALID_STATUS']);
    }

    // 插入消息
    $attachmentsJson = $attachments ? json_encode($attachments, JSON_UNESCAPED_UNICODE) : null;
    
    $insertStmt = $db->prepare("
        INSERT INTO rental_ticket_messages (
            ticket_id, sender_type, sender_id, message_type, content, attachments, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, NOW())
    ");
    $insertStmt->execute([
        $ticketId,
        $userType, // 1=C端, 2=B端
        $userId,
        $messageType,
        $content,
        $attachmentsJson
    ]);

    $messageId = $db->lastInsertId();

    // 更新工单更新时间
    $updateTicketStmt = $db->prepare("UPDATE rental_tickets SET updated_at = NOW() WHERE id = ?");
    $updateTicketStmt->execute([$ticketId]);

    $db->commit();

    // 发送通知给对方
    if ($isBuyer) {
        // 当前是买方，通知卖方
        $notifyUserId = $ticket['seller_user_id'];
        $notifyUserType = ($ticket['seller_user_type'] === 'c' || $ticket['seller_user_type'] === '1') ? 1 : 2;
        $senderRole = '购买方';
    } else {
        // 当前是卖方，通知买方
        $notifyUserId = $ticket['buyer_user_id'];
        $notifyUserType = ($ticket['buyer_user_type'] === 'c' || $ticket['buyer_user_type'] === '1') ? 1 : 2;
        $senderRole = '出租方';
    }

    $messageTypeText = $messageType === 0 ? '文本消息' : '图片消息';
    $contentPreview = mb_substr($content, 0, 50) . (mb_strlen($content) > 50 ? '...' : '');

    Notification::sendToUser(
        $db,
        $notifyUserId,
        $notifyUserType,
        '工单新消息',
        "工单「{$ticket['title']}」收到来自{$senderRole}的新消息（{$messageTypeText}）：{$contentPreview}",
        'rental_ticket',
        $ticketId
    );

    Response::success([
        'message_id' => $messageId,
        'ticket_id' => $ticketId,
        'created_at' => date('Y-m-d H:i:s')
    ], '消息发送成功');

} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error('发送消息失败：' . $e->getMessage(), $errorCodes['RENTAL_TICKET_MESSAGE_SEND_FAILED']);
} catch (Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error($e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
