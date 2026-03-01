<?php
/**
 * 订单续租
 * POST /api/rental/orders/renew
 * 
 * 请求体：
 * {
 *   "order_id": 1,
 *   "renew_days": 7
 * }
 * 
 * 规则：
 * - 仅允许订单状态=进行中（status=2）
 * - allow_renew=1 才允许
 * - 不需要出租方确认
 * - 续租费用按原单价计算
 * - 更新订单租期和金额
 * - 发送通知给出租方
 */

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/Notification.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';
$db = Database::connect();

// 认证
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type'];

// 获取参数
$input = json_decode(file_get_contents('php://input'), true);
$orderId = intval($input['order_id'] ?? 0);
$renewDays = intval($input['renew_days'] ?? 0);

if ($orderId <= 0) {
    Response::error('订单ID无效', $errorCodes['RENTAL_ORDER_NOT_FOUND']);
}

if ($renewDays <= 0) {
    Response::error('续租天数必须大于0', $errorCodes['RENTAL_ORDER_DAYS_INVALID']);
}

try {
    $db->beginTransaction();

    // 获取订单信息并锁定
    $stmt = $db->prepare("SELECT * FROM rental_orders WHERE id = ? FOR UPDATE");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        $db->rollBack();
        Response::error('订单不存在', $errorCodes['RENTAL_ORDER_NOT_FOUND']);
    }

    // 检查是否是买方（租用方）
    $buyerUserType = ($order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1') ? 1 : 2;
    if ($order['buyer_user_id'] != $userId || $buyerUserType != $userType) {
        $db->rollBack();
        Response::error('只有租用方可以续租', $errorCodes['RENTAL_ORDER_NOT_FOUND']);
    }

    // 检查订单状态（必须是进行中）
    if ($order['status'] != 2) {
        $db->rollBack();
        Response::error('只有进行中的订单可以续租', $errorCodes['RENTAL_ORDER_INVALID_STATUS']);
    }

    // 检查是否允许续租
    if ($order['allow_renew'] != 1) {
        $db->rollBack();
        Response::error('该订单不允许续租', $errorCodes['RENTAL_ORDER_RENEW_NOT_ALLOWED']);
    }

    // 解析订单 JSON 获取原始价格信息
    $orderJson = json_decode($order['order_json'] ?? '{}', true);
    $pricePerDay = intval($orderJson['price_per_day'] ?? 0);

    if ($pricePerDay <= 0) {
        $db->rollBack();
        Response::error('订单价格信息异常', 5000);
    }

    // 检查续租天数是否在允许范围内
    $minDays = intval($orderJson['min_days'] ?? 1);
    $maxDays = intval($orderJson['max_days'] ?? 30);
    if ($renewDays < $minDays || $renewDays > $maxDays) {
        $db->rollBack();
        Response::error("续租天数必须在 {$minDays}-{$maxDays} 天之间", $errorCodes['RENTAL_ORDER_DAYS_INVALID']);
    }

    // 计算续租费用
    $renewAmount = $pricePerDay * $renewDays;
    $sellerRate = (int)AppConfig::get('rental_seller_rate', 70);
    $agentRate = (int)AppConfig::get('rental_agent_rate', 10);
    $seniorAgentRate = (int)AppConfig::get('rental_senior_agent_rate', 10);

    $sellerRenewAmount = intval($renewAmount * $sellerRate / 100);

    // 续租时沿用订单中的团长信息
    $agentRenewAmount = 0;
    $orderAgentUserId = $order['agent_user_id'] ?? null;
    if ($orderAgentUserId) {
        // 查询团长等级
        $stmt = $db->prepare("SELECT is_agent FROM c_users WHERE id = ?");
        $stmt->execute([$orderAgentUserId]);
        $agentInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($agentInfo && (int)$agentInfo['is_agent'] === 2) {
            $agentRenewAmount = intval($renewAmount * $seniorAgentRate / 100);
        } elseif ($agentInfo && (int)$agentInfo['is_agent'] >= 1) {
            $agentRenewAmount = intval($renewAmount * $agentRate / 100);
        }
    }

    $platformRenewAmount = $renewAmount - $sellerRenewAmount - $agentRenewAmount;

    // 获取买方钱包并检查余额
    $buyerWalletId = $order['buyer_wallet_id'];
    $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
    $walletStmt->execute([$buyerWalletId]);
    $buyerBalance = $walletStmt->fetchColumn();

    if ($buyerBalance === false) {
        $db->rollBack();
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }

    if ($buyerBalance < $renewAmount) {
        $db->rollBack();
        Response::error('钱包余额不足', $errorCodes['WALLET_INSUFFICIENT_BALANCE']);
    }

    // 扣除买方余额
    $newBuyerBalance = $buyerBalance - $renewAmount;
    $updateWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $updateWalletStmt->execute([$newBuyerBalance, $buyerWalletId]);

    // 获取买方用户名
    $buyerUsername = '';
    if ($buyerUserType == 1) {
        $uStmt = $db->prepare("SELECT username FROM c_users WHERE id = ?");
        $uStmt->execute([$order['buyer_user_id']]);
        $buyerUsername = $uStmt->fetchColumn();
    } else {
        $uStmt = $db->prepare("SELECT username FROM b_users WHERE id = ?");
        $uStmt->execute([$order['buyer_user_id']]);
        $buyerUsername = $uStmt->fetchColumn();
    }

    // 创建买方 wallet_log（续租扣费）
    $logStmt = $db->prepare("
        INSERT INTO wallets_log 
        (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at)
        VALUES (?, ?, ?, ?, 2, ?, ?, ?, 'rental_order_renew', ?, ?, NOW())
    ");

    $logStmt->execute([
        $buyerWalletId,
        $order['buyer_user_id'],
        $buyerUsername,
        $buyerUserType,
        $renewAmount,
        $buyerBalance,
        $newBuyerBalance,
        $orderId,
        "订单续租 {$renewDays} 天"
    ]);

    // 创建卖方 wallet_log（续租收入，amount=0 因为资金冻结中）
    $sellerUserType = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 1 : 2;
    $sellerUsername = '';
    if ($sellerUserType == 1) {
        $uStmt = $db->prepare("SELECT username FROM c_users WHERE id = ?");
        $uStmt->execute([$order['seller_user_id']]);
        $sellerUsername = $uStmt->fetchColumn();
    } else {
        $uStmt = $db->prepare("SELECT username FROM b_users WHERE id = ?");
        $uStmt->execute([$order['seller_user_id']]);
        $sellerUsername = $uStmt->fetchColumn();
    }

    $sellerLogStmt = $db->prepare("
        INSERT INTO wallets_log 
        (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at)
        VALUES (?, ?, ?, ?, 1, 0, 0, 0, 'rental_order_renew', ?, ?, NOW())
    ");

    $sellerLogStmt->execute([
        $order['seller_wallet_id'],
        $order['seller_user_id'],
        $sellerUsername,
        $sellerUserType,
        $orderId,
        "订单续租收入 {$renewDays} 天（待结算：¥" . number_format($sellerRenewAmount / 100, 2) . "）"
    ]);

    // 更新订单信息
    $newTotalAmount = intval($order['total_amount']) + $renewAmount;
    $newPlatformAmount = intval($order['platform_amount']) + $platformRenewAmount;
    $newSellerAmount = intval($order['seller_amount']) + $sellerRenewAmount;
    $newAgentAmount = intval($order['agent_amount'] ?? 0) + $agentRenewAmount;
    $newDays = intval($order['days']) + $renewDays;

    // 更新 order_json 中的 end_time
    $currentEndTime = intval($orderJson['end_time'] ?? 0);
    
    // 订单必须已开始（有 end_time），否则不能续租
    if ($currentEndTime <= 0) {
        $db->rollBack();
        Response::error('订单尚未开始，无法续租', $errorCodes['RENTAL_ORDER_INVALID_STATUS']);
    }
    
    $newEndTime = $currentEndTime + ($renewDays * 86400);
    $orderJson['end_time'] = $newEndTime;
    
    // 记录续租历史
    if (!isset($orderJson['renew_history'])) {
        $orderJson['renew_history'] = [];
    }
    $orderJson['renew_history'][] = [
        'renew_at' => time(),
        'renew_days' => $renewDays,
        'renew_amount' => $renewAmount,
        'new_end_time' => $newEndTime
    ];

    $updateOrderStmt = $db->prepare("
        UPDATE rental_orders
        SET days = ?, total_amount = ?, platform_amount = ?, seller_amount = ?, agent_amount = ?, order_json = ?, updated_at = NOW()
        WHERE id = ?
    ");

    $updateOrderStmt->execute([
        $newDays,
        $newTotalAmount,
        $newPlatformAmount,
        $newSellerAmount,
        $newAgentAmount,
        json_encode($orderJson, JSON_UNESCAPED_UNICODE),
        $orderId
    ]);

    // 提交事务
    $db->commit();

    // 发送通知给出租方
    Notification::sendToUser(
        $db,
        $order['seller_user_id'],
        $sellerUserType,
        '订单已续租',
        "您的订单 #{$orderId} 已被租用方续租 {$renewDays} 天，新的到期时间：" . date('Y-m-d H:i:s', $newEndTime),
        'rental_order',
        $orderId
    );

    // 发送通知给租用方（确认续租成功）
    Notification::sendToUser(
        $db,
        $order['buyer_user_id'],
        $buyerUserType,
        '订单续租成功',
        "订单 #{$orderId} 续租成功，续租 {$renewDays} 天，扣费 ¥" . number_format($renewAmount / 100, 2) . "，新的到期时间：" . date('Y-m-d H:i:s', $newEndTime),
        'rental_order',
        $orderId
    );

    echo json_encode([
        'code' => 0,
        'message' => '续租成功',
        'data' => [
            'order_id' => $orderId,
            'renew_days' => $renewDays,
            'renew_amount' => $renewAmount / 100,
            'new_total_days' => $newDays,
            'new_total_amount' => $newTotalAmount / 100,
            'new_end_time' => date('Y-m-d H:i:s', $newEndTime)
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
        'message' => '续租失败：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
