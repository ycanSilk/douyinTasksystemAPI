<?php
/**
 * 从出租信息直接下单
 * POST /api/rental/orders/create-from-offer
 * 
 * 请求体：
 * {
 *   "offer_id": 1,
 *   "days": 7,
 *   "buyer_info": {
 *     "usage": "用于直播带货",
 *     "contact": "微信xxx",
 *     "notes": "需要高权重账号"
 *   }
 * }
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
$offerId = intval($input['offer_id'] ?? 0);
$days = intval($input['days'] ?? 0);
$buyerInfo = $input['buyer_info'] ?? null;

if ($offerId <= 0) {
    Response::error('出租信息ID无效', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
}

if ($days <= 0) {
    Response::error('租期必须大于0天', $errorCodes['RENTAL_ORDER_DAYS_INVALID']);
}

try {
    // 获取出租信息
    $stmt = $db->prepare("
        SELECT 
            id, user_id, user_type, title, price_per_day, min_days, max_days, allow_renew, content_json, status
        FROM rental_offers
        WHERE id = ?
    ");
    $stmt->execute([$offerId]);
    $offer = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$offer) {
        Response::error('出租信息不存在', $errorCodes['RENTAL_OFFER_NOT_FOUND']);
    }

    // 检查状态
    if ($offer['status'] != 1) {
        Response::error('出租信息已下架或已封禁', $errorCodes['RENTAL_ORDER_OFFER_NOT_AVAILABLE']);
    }

    // 不能租自己的
    if ($offer['user_id'] == $userId && $offer['user_type'] == $userType) {
        Response::error('不能租赁自己的账号', $errorCodes['RENTAL_ORDER_OFFER_NOT_AVAILABLE']);
    }

    // 检查租期
    if ($days < $offer['min_days'] || $days > $offer['max_days']) {
        Response::error("租期必须在 {$offer['min_days']}-{$offer['max_days']} 天之间", $errorCodes['RENTAL_ORDER_DAYS_INVALID']);
    }

    // 计算总价
    $totalAmount = $offer['price_per_day'] * $days;

    // 获取买方（租赁方）钱包信息
    $buyerWalletStmt = $db->prepare("
        SELECT wallet_id, username
        FROM " . ($userType == Token::TYPE_B ? 'b_users' : 'c_users') . "
        WHERE id = ?
    ");
    $buyerWalletStmt->execute([$userId]);
    $buyerWallet = $buyerWalletStmt->fetch(PDO::FETCH_ASSOC);

    // 获取卖方（出租方）钱包信息
    $sellerWalletStmt = $db->prepare("
        SELECT wallet_id, username
        FROM " . ($offer['user_type'] == Token::TYPE_B ? 'b_users' : 'c_users') . "
        WHERE id = ?
    ");
    $sellerWalletStmt->execute([$offer['user_id']]);
    $sellerWallet = $sellerWalletStmt->fetch(PDO::FETCH_ASSOC);

    // 检查买方余额
    $balanceStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $balanceStmt->execute([$buyerWallet['wallet_id']]);
    $currentBalance = $balanceStmt->fetchColumn();

    if ($currentBalance < $totalAmount) {
        Response::error('钱包余额不足', $errorCodes['RENTAL_ORDER_INSUFFICIENT_BALANCE']);
    }

    $db->beginTransaction();

    // 扣除买方余额
    $newBalance = $currentBalance - $totalAmount;
    $updateWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $updateWalletStmt->execute([$newBalance, $buyerWallet['wallet_id']]);

    // 计算分成
    $sellerRate = (int)AppConfig::get('rental_seller_rate', 70);
    $agentRate = (int)AppConfig::get('rental_agent_rate', 10);
    $seniorAgentRate = (int)AppConfig::get('rental_senior_agent_rate', 10);

    $sellerAmount = intval($totalAmount * $sellerRate / 100);

    // 查询卖方（出租方）的团长上级
    $agentUserId = null;
    $agentAmount = 0;

    // 卖方是C端用户时才查团长
    if ($offer['user_type'] == Token::TYPE_C) {
        $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
        $stmt->execute([$offer['user_id']]);
        $sellerCUser = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($sellerCUser && !empty($sellerCUser['parent_id'])) {
            $stmt = $db->prepare("SELECT id, is_agent FROM c_users WHERE id = ?");
            $stmt->execute([$sellerCUser['parent_id']]);
            $parentUser = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($parentUser && (int)$parentUser['is_agent'] >= 1) {
                $agentUserId = (int)$parentUser['id'];
                if ((int)$parentUser['is_agent'] === 2) {
                    $agentAmount = intval($totalAmount * $seniorAgentRate / 100);
                } else {
                    $agentAmount = intval($totalAmount * $agentRate / 100);
                }
            }
        }
    }

    $platformAmount = $totalAmount - $sellerAmount - $agentAmount;

    // 创建订单
    $createOrderStmt = $db->prepare("
        INSERT INTO rental_orders
        (
            source_type, source_id,
            buyer_user_id, buyer_user_type, buyer_wallet_id, buyer_info_json,
            seller_user_id, seller_user_type, seller_wallet_id, seller_info_json,
            agent_user_id, agent_amount,
            total_amount, platform_amount, seller_amount,
            days, allow_renew, order_json,
            status, created_at, updated_at
        )
        VALUES
        (0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())
    ");
    $createOrderStmt->execute([
        $offerId,
        $userId,
        $userType == Token::TYPE_C ? 'c' : 'b',
        $buyerWallet['wallet_id'],
        json_encode($buyerInfo, JSON_UNESCAPED_UNICODE),
        $offer['user_id'],
        $offer['user_type'] == Token::TYPE_C ? 'c' : 'b',
        $sellerWallet['wallet_id'],
        $offer['content_json'],
        $agentUserId,
        $agentAmount,
        $totalAmount,
        $platformAmount,
        $sellerAmount,
        $days,
        $offer['allow_renew'],
        json_encode([
            'price_per_day' => $offer['price_per_day'],
            'offer_title' => $offer['title'],
            'min_days' => $offer['min_days'],
            'max_days' => $offer['max_days']
        ], JSON_UNESCAPED_UNICODE)
    ]);

    $orderId = $db->lastInsertId();

    // 下架出租信息（防止重复售出）
    $updateOfferStmt = $db->prepare("UPDATE rental_offers SET status = 0 WHERE id = ?");
    $updateOfferStmt->execute([$offerId]);

    // 买方钱包流水
    $insertBuyerLogStmt = $db->prepare(" 
        INSERT INTO wallets_log 
        (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, task_types, task_types_text, remark, created_at) 
        VALUES 
        (?, ?, ?, ?, 2, ?, ?, ?, 'rental_order_pay', ?, ?, ?, ?, NOW())
    ");
    $insertBuyerLogStmt->execute([
        $buyerWallet['wallet_id'],
        $userId,
        $buyerWallet['username'],
        $userType,
        $totalAmount,
        $currentBalance,
        $newBalance,
        $orderId,
        6, // 出租订单
        '出租订单',
        "租赁订单支付：{$offer['title']}（{$days}天）"
    ]);
    
    // 记录C端任务统计（仅当买方是C端用户时）
    if ($userType == Token::TYPE_C) {
        try {
            $stmt = $db->prepare(" 
                INSERT INTO c_task_statistics (
                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                    related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                ) VALUES (?, ?, 2, ?, ?, ?, 'account_rental', ?, 6, '出租订单',10,'出租订单已支付', ?)
            ");
            $stmt->execute([
                $userId,
                $buyerWallet['username'],
                $totalAmount,
                $currentBalance,
                $newBalance,
                $orderId,
                "租赁订单支付：{$offer['title']}（{$days}天）"
            ]);
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            error_log('插入c_task_statistics失败: ' . $e->getMessage());
        }
    }
    
    // 仅当买方是B端用户时，插入B端任务统计记录
    if ($userType == Token::TYPE_B) {
        try {
            $stmt = $db->prepare(" 
                INSERT INTO b_task_statistics (
                    b_user_id, username, flow_type, amount, before_balance, after_balance, 
                    related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                ) VALUES (?, ?, 2, ?, ?, ?, 'account_rental', ?, 6, '出租订单',10,'出租订单已支付', ?)
            ");
            $stmt->execute([
                $userId,
                $buyerWallet['username'],
                $totalAmount,
                $currentBalance,
                $newBalance,
                $orderId,
                "租赁订单支付：{$offer['title']}（{$days}天）"
            ]);
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            error_log('插入b_task_statistics失败: ' . $e->getMessage());
        }
    }

    // 卖方钱包流水（amount=0，冻结状态）
    $insertSellerLogStmt = $db->prepare("
        INSERT INTO wallets_log 
        (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, task_types, task_types_text, remark, created_at) 
        VALUES 
        (?, ?, ?, ?, 2, 0, 0, 0, 'rental_order_pending', ?, ?, ?, ?, NOW())
    ");
    $insertSellerLogStmt->execute([
        $sellerWallet['wallet_id'],
        $offer['user_id'],
        $sellerWallet['username'],
        $offer['user_type'],
        $orderId,
        6, // 出租订单
        '出租订单',
        "租赁订单已创建，待客服处理：{$offer['title']}（{$days}天，预计收益：{$sellerAmount}）"
    ]);

    $db->commit();

    // 发送通知（在事务外）
    // 1. 通知出租方（卖方）
    Notification::sendToUser(
        $db,
        $offer['user_id'],
        $offer['user_type'],
        '收到新的租赁订单',
        "您的出租「{$offer['title']}」收到新订单，租期{$days}天，等待客服处理",
        'rental_order',
        $orderId
    );

    // 2. 通知购买方（买方）
    Notification::sendToUser(
        $db,
        $userId,
        $userType,
        '租赁订单支付成功',
        "您租赁的「{$offer['title']}」已支付成功，等待客服处理",
        'rental_order',
        $orderId
    );

    Response::success([
        'order_id' => $orderId,
        'offer_id' => $offerId,
        'days' => $days,
        'total_amount' => $totalAmount,
        'status' => 1,
        'status_text' => '已支付，待客服处理'
    ], '下单成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log('Create order from offer failed: ' . $e->getMessage());
    Response::error('下单失败：' . $e->getMessage(), $errorCodes['RENTAL_ORDER_CREATE_FAILED']);
}
