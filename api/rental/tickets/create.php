<?php
/**
 * 创建租赁工单
 * POST /api/rental/tickets/create
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体：
 * {
 *   "order_id": 123,
 *   "title": "账号无法登录",
 *   "description": "账号密码错误，无法登录，请卖家检查账号信息"
 * }
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "工单创建成功",
 *   "data": {
 *     "ticket_id": 1,
 *     "ticket_no": "TK20260114123456",
 *     "message": "工单创建成功，已通知出租方"
 *   },
 *   "timestamp": 1737123456
 * }
 * 
 * 规则：
 * - 仅购买方（buyer）可以创建工单
 * - 订单状态必须是 2=进行中 或 3=已完成
 * - 每个订单同时只能有一个未关闭的工单
 * - 售卖方无法退出或拒绝工单
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
$orderId = intval($input['order_id'] ?? 0);
$title = trim($input['title'] ?? '');
$description = trim($input['description'] ?? '');

// 参数校验
if ($orderId <= 0) {
    Response::error('订单ID无效', $errorCodes['INVALID_PARAMS']);
}

if (empty($title)) {
    Response::error('请输入工单标题', $errorCodes['INVALID_PARAMS']);
}

if (mb_strlen($title) > 200) {
    Response::error('工单标题最多200字符', $errorCodes['INVALID_PARAMS']);
}

if (empty($description)) {
    Response::error('请输入问题描述', $errorCodes['INVALID_PARAMS']);
}

if (mb_strlen($description) > 2000) {
    Response::error('问题描述最多2000字符', $errorCodes['INVALID_PARAMS']);
}

try {
    $db->beginTransaction();

    // 查询订单信息
    $userTypeStr = ($userType === 1) ? 'c' : 'b';
    $stmt = $db->prepare("
        SELECT 
            id, source_type, buyer_user_id, buyer_user_type, seller_user_id, seller_user_type,
            total_amount, days, status, created_at
        FROM rental_orders
        WHERE id = ?
    ");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        $db->rollBack();
        Response::error('订单不存在', $errorCodes['RENTAL_ORDER_NOT_FOUND']);
    }

    // 权限检查：只有购买方可以创建工单
    if ($order['buyer_user_id'] != $userId || 
        ($order['buyer_user_type'] !== $userTypeStr && intval($order['buyer_user_type']) !== $userType)) {
        $db->rollBack();
        Response::error('只有购买方可以创建工单', $errorCodes['RENTAL_TICKET_NO_PERMISSION']);
    }

    // 状态检查：只有进行中（2）或已完成（3）的订单可以创建工单
    if (!in_array($order['status'], [2, 3])) {
        $statusText = [
            0 => '待支付',
            1 => '待客服',
            2 => '进行中',
            3 => '已完成',
            4 => '已取消'
        ];
        $currentStatus = $statusText[$order['status']] ?? '未知';
        $db->rollBack();
        Response::error('只有进行中或已完成的订单可以创建工单（当前状态：' . $currentStatus . '）', $errorCodes['RENTAL_TICKET_ORDER_STATUS_INVALID']);
    }

    // 检查该订单是否已有未关闭的工单
    $checkStmt = $db->prepare("
        SELECT id, ticket_no, status 
        FROM rental_tickets 
        WHERE order_id = ? AND status IN (0, 1, 2)
        LIMIT 1
    ");
    $checkStmt->execute([$orderId]);
    $existingTicket = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if ($existingTicket) {
        $db->rollBack();
        $statusText = [0 => '待处理', 1 => '处理中', 2 => '已解决'];
        Response::error('该订单已有未关闭的工单（工单号：' . $existingTicket['ticket_no'] . '，状态：' . $statusText[$existingTicket['status']] . '）', $errorCodes['RENTAL_TICKET_ALREADY_EXISTS']);
    }

    // 生成工单编号：TK + YYYYMMDD + 6位随机数
    do {
        $ticketNo = 'TK' . date('Ymd') . str_pad(mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $checkNoStmt = $db->prepare("SELECT id FROM rental_tickets WHERE ticket_no = ?");
        $checkNoStmt->execute([$ticketNo]);
    } while ($checkNoStmt->fetch());

    // 创建工单
    $createTicketStmt = $db->prepare("
        INSERT INTO rental_tickets (
            ticket_no, order_id, creator_user_id, creator_user_type, 
            title, description, status, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, 0, NOW())
    ");
    $createTicketStmt->execute([
        $ticketNo,
        $orderId,
        $userId,
        $userType,
        $title,
        $description
    ]);

    $ticketId = $db->lastInsertId();

    // 创建系统欢迎消息
    $sourceTypeText = $order['source_type'] == 0 ? '出租' : '求租';
    $buyerTypeText = ($order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1') ? 'C端' : 'B端';
    $sellerTypeText = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 'C端' : 'B端';
    
    $systemMessage = "【工单已创建】\n";
    $systemMessage .= "━━━━━━━━━━━━━━━━\n";
    $systemMessage .= "工单编号：{$ticketNo}\n";
    $systemMessage .= "关联订单：#{$orderId}\n";
    $systemMessage .= "订单类型：{$sourceTypeText}\n";
    $systemMessage .= "订单状态：" . ($order['status'] == 2 ? '进行中' : '已完成') . "\n";
    $systemMessage .= "租赁天数：{$order['days']}天\n";
    $systemMessage .= "订单金额：¥" . number_format($order['total_amount'] / 100, 2) . "\n";
    $systemMessage .= "购买方：{$buyerTypeText}用户（ID:{$order['buyer_user_id']}）\n";
    $systemMessage .= "出租方：{$sellerTypeText}用户（ID:{$order['seller_user_id']}）\n";
    $systemMessage .= "创建时间：" . date('Y-m-d H:i:s', strtotime($order['created_at'])) . "\n";
    $systemMessage .= "━━━━━━━━━━━━━━━━\n";
    $systemMessage .= "工单问题：{$title}\n";
    $systemMessage .= "问题描述：{$description}\n";
    $systemMessage .= "━━━━━━━━━━━━━━━━\n";
    $systemMessage .= "本工单由购买方发起，买卖双方及管理员可参与讨论。\n";
    $systemMessage .= "请勿脱离平台交易，谨防诈骗！";

    $createMessageStmt = $db->prepare("
        INSERT INTO rental_ticket_messages (
            ticket_id, sender_type, sender_id, message_type, content, created_at
        ) VALUES (?, 4, NULL, 3, ?, NOW())
    ");
    $createMessageStmt->execute([$ticketId, $systemMessage]);

    $db->commit();

    // 发送通知给出租方（卖方）
    $sellerUserId = $order['seller_user_id'];
    $sellerUserType = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 1 : 2;
    
    Notification::sendToUser(
        $db,
        $sellerUserId,
        $sellerUserType,
        '新工单通知',
        "您的租赁订单 #{$orderId} 收到新工单：{$title}。工单编号：{$ticketNo}，请及时查看处理。",
        'rental_ticket',
        $ticketId
    );

    Response::success([
        'ticket_id' => $ticketId,
        'ticket_no' => $ticketNo,
        'message' => '工单创建成功，已通知出租方'
    ], '工单创建成功');

} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error('工单创建失败：' . $e->getMessage(), $errorCodes['RENTAL_TICKET_CREATE_FAILED']);
} catch (Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    Response::error($e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
