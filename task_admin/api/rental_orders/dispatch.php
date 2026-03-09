<?php
/**
 * 租赁订单调度 (Admin / 客服)
 * POST /task_admin/api/rental_orders/dispatch.php
 * 
 * 参数：
 * - order_id: 订单ID
 * - action: 操作动作 (start, refund, terminate)
 *   - start: 待客服(1) -> 进行中(2)。开始计时。
 *   - refund: 待客服(1) -> 已取消(4)。全额退款给买家。
 *   - terminate: 进行中(2) -> 已取消(4)。停止计时，不退款。
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}


if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Notification.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

$admin = AdminAuthMiddleware::authenticate();
$db = Database::connect();

$input = json_decode(file_get_contents('php://input'), true);
$orderId = intval($input['order_id'] ?? 0);
$action = trim($input['action'] ?? '');

if ($orderId <= 0) {
    echo json_encode(['code' => 1002, 'message' => '订单ID无效', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($action, ['start', 'refund', 'terminate'])) {
    echo json_encode(['code' => $errorCodes['RENTAL_ORDER_INVALID_ACTION'], 'message' => '操作动作无效', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $db->beginTransaction();

    // 获取订单信息 (锁定行)
    $stmt = $db->prepare("SELECT * FROM rental_orders WHERE id = ? FOR UPDATE");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        $db->rollBack();
        echo json_encode(['code' => $errorCodes['RENTAL_ORDER_NOT_FOUND'], 'message' => '订单不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $currentStatus = intval($order['status']);
    $orderJson = json_decode($order['order_json'] ?? '{}', true);

    // 用于存储待发送的通知
    $notifications = [];
    $message = '';

    // 动作分发
    if ($action === 'start') {
        // 1. 启动订单 (1 -> 2)
        if ($currentStatus !== 1) {
            $db->rollBack();
            echo json_encode(['code' => $errorCodes['RENTAL_ORDER_INVALID_STATUS'], 'message' => '只有「待客服」状态的订单可以开始', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $startTime = time();
        $days = intval($order['days']);
        $endTime = $startTime + ($days * 86400);

        $orderJson['start_time'] = $startTime;
        $orderJson['end_time'] = $endTime;

        $updateStmt = $db->prepare("UPDATE rental_orders SET status = 2, order_json = ? WHERE id = ?");
        $updateStmt->execute([json_encode($orderJson, JSON_UNESCAPED_UNICODE), $orderId]);

        // 准备通知数据（稍后发送）
        $notifications[] = [
            'user_id' => $order['buyer_user_id'],
            'user_type' => $order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已开始',
            'content' => "您租用的订单 #{$orderId} 已开始执行，租期 {$days} 天，到期时间：" . date('Y-m-d H:i:s', $endTime),
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $notifications[] = [
            'user_id' => $order['seller_user_id'],
            'user_type' => $order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已开始',
            'content' => "您出租的订单 #{$orderId} 已开始执行，租期 {$days} 天，到期时间：" . date('Y-m-d H:i:s', $endTime),
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $message = '订单已开始';

    } elseif ($action === 'refund') {
        // 2. 待客服期间退款 (1 -> 4)
        if ($currentStatus !== 1) {
            $db->rollBack();
            echo json_encode(['code' => $errorCodes['RENTAL_ORDER_INVALID_STATUS'], 'message' => '只有「待客服」状态的订单可以进行此退款操作', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }

        // 退款给买家
        $buyerWalletId = $order['buyer_wallet_id'];
        $totalAmount = intval($order['total_amount']);

        // 获取买家钱包
        $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
        $walletStmt->execute([$buyerWalletId]);
        $buyerWalletBalance = $walletStmt->fetchColumn();

        if ($buyerWalletBalance === false) {
             throw new Exception("买家钱包不存在");
        }

        $newBalance = $buyerWalletBalance + $totalAmount;
        $updateWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $updateWalletStmt->execute([$newBalance, $buyerWalletId]);

        // 获取用户名用于Log
        $username = ''; 
        if ($order['buyer_user_type'] === 'c') {
            $uStmt = $db->prepare("SELECT username FROM c_users WHERE id = ?");
            $uStmt->execute([$order['buyer_user_id']]);
            $username = $uStmt->fetchColumn();
        } else {
            $uStmt = $db->prepare("SELECT username FROM b_users WHERE id = ?");
            $uStmt->execute([$order['buyer_user_id']]);
            $username = $uStmt->fetchColumn();
        }

        // 记录 Log
        $logStmt = $db->prepare("
            INSERT INTO wallets_log 
            (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at)
            VALUES (?, ?, ?, ?, 1, ?, ?, ?, 'rental_order_refund', ?, ?, NOW())
        ");

        $logStmt->execute([
            $buyerWalletId,
            $order['buyer_user_id'],
            $username,
            $order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1' ? 1 : 2,
            $totalAmount,
            $buyerWalletBalance,
            $newBalance,
            $orderId,
            "订单取消退款"
        ]);

        // 更新订单状态
        $updateStmt = $db->prepare("UPDATE rental_orders SET status = 4 WHERE id = ?");
        $updateStmt->execute([$orderId]);

        // 准备通知数据（稍后发送）
        $notifications[] = [
            'user_id' => $order['buyer_user_id'],
            'user_type' => $order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已取消并退款',
            'content' => "您租用的订单 #{$orderId} 已由客服取消，款项已退回钱包。",
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $notifications[] = [
            'user_id' => $order['seller_user_id'],
            'user_type' => $order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已取消',
            'content' => "您出租的订单 #{$orderId} 已由客服取消。",
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $message = '订单已取消并全额退款';

    } elseif ($action === 'terminate') {
        // 3. 进行中强行终止 (2 -> 4)
        if ($currentStatus !== 2) {
            $db->rollBack();
            echo json_encode(['code' => $errorCodes['RENTAL_ORDER_INVALID_STATUS'], 'message' => '只有「进行中」状态的订单可以进行终止操作', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $now = time();
        $orderJson['terminated_at'] = $now;
        $orderJson['original_end_time'] = $orderJson['end_time'] ?? 0;
        $orderJson['end_time'] = $now; // 修正结束时间为现在

        // 更新订单状态
        $updateStmt = $db->prepare("UPDATE rental_orders SET status = 4, order_json = ? WHERE id = ?");
        $updateStmt->execute([json_encode($orderJson, JSON_UNESCAPED_UNICODE), $orderId]);

        // 准备通知数据（稍后发送）
        $notifications[] = [
            'user_id' => $order['buyer_user_id'],
            'user_type' => $order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已终止',
            'content' => "您租用的订单 #{$orderId} 已被客服终止，如有疑问请联系客服。",
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $notifications[] = [
            'user_id' => $order['seller_user_id'],
            'user_type' => $order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已终止',
            'content' => "您出租的订单 #{$orderId} 已被客服终止。",
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $message = '订单已终止（不涉及自动退款）';
    }

    // 提交事务
    $db->commit();

    // 事务提交后发送通知
    foreach ($notifications as $notif) {
        Notification::sendToUser(
            $db,
            $notif['user_id'],
            $notif['user_type'],
            $notif['title'],
            $notif['content'],
            $notif['related_type'],
            $notif['related_id']
        );
    }

    echo json_encode([
        'code' => 0,
        'message' => $message,
        'data' => [
            'order_id' => $orderId,
            'status' => $action === 'start' ? 2 : 4
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '系统错误：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
