<?php
/**
 * 租赁订单调度 (Admin / 客服)
 * POST /task_admin/api/rental_orders/dispatch.php
 * 
 * 参数：
 * - order_id: 订单ID
 * - action: 操作动作 (start, refund, terminate, terminate_refund)
 *   - start: 待客服(1) -> 进行中(2)。开始计时。
 *   - refund: 待客服(1) -> 已取消(4)。全额退款给买家。
 *   - terminate: 进行中(2) -> 已取消(4)。停止计时，不退款。
 *   - terminate_refund: 进行中(2) -> 已取消(4)。停止计时，计算剩余天数并原路退款。
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

if (!in_array($action, ['start', 'refund', 'terminate', 'terminate_refund'])) {
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
        
        // 记录C端任务统计（仅当买家是C端用户时）
            if ($order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1') {
                try {
                    $stmt = $db->prepare(" 
                        INSERT INTO c_task_statistics (
                            c_user_id, username, flow_type, amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                        ) VALUES (?, ?, 1, ?, ?, ?, 'account_rental', ?, 6, '出租订单', ?, ?, ?)
                    ");
                    $stmt->execute([
                        $order['buyer_user_id'],
                        $username,
                        $totalAmount,
                        $buyerWalletBalance,
                        $newBalance,
                        $orderId,
                        8, // record_status: 订单没开始就取消
                        '租赁订单已取消，已退款', // record_status_text
                        "订单取消退款"
                    ]);
                } catch (Exception $e) {
                    // 记录插入失败时的错误日志，但不影响主流程
                    error_log('插入c_task_statistics失败: ' . $e->getMessage());
                }
            }
            
            // 仅当买家是B端用户时，插入B端任务统计记录
            if ($order['buyer_user_type'] === 'b' || $order['buyer_user_type'] === '2') {
                try {
                    $stmt = $db->prepare(" 
                        INSERT INTO b_task_statistics (
                            b_user_id, username, flow_type, amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                        ) VALUES (?, ?, 1, ?, ?, ?, 'account_rental', ?, 6, '出租订单', ?, ?, ?)
                    ");
                    $stmt->execute([
                        $order['buyer_user_id'],
                        $username,
                        $totalAmount,
                        $buyerWalletBalance,
                        $newBalance,
                        $orderId,
                        8, // record_status: 订单没开始就取消
                        '租赁订单已取消，已退款', // record_status_text
                        "订单取消退款"
                    ]);
                } catch (Exception $e) {
                    // 记录插入失败时的错误日志，但不影响主流程
                    error_log('插入b_task_statistics失败: ' . $e->getMessage());
                }
            }

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

        // 计算已租赁天数和剩余天数
        $startTime = $orderJson['start_time'] ?? $now;
        $totalDays = intval($order['days']);
        $rentedDays = ceil(($now - $startTime) / 86400);
        $remainingDays = max(0, $totalDays - $rentedDays);
        $sellerAmount = $rentedDays * ceil(intval($order['total_amount']) / $totalDays);
        $refundAmount = 0;

        // 更新订单状态
        $updateStmt = $db->prepare("UPDATE rental_orders SET status = 4, order_json = ? WHERE id = ?");
        $updateStmt->execute([json_encode($orderJson, JSON_UNESCAPED_UNICODE), $orderId]);

        // 插入终止租赁订单记录
        $insertTerminationStmt = $db->prepare("INSERT INTO termination_rental_orders (
            rental_order_id, termination_type, buyer_user_id, buyer_user_type, 
            seller_user_id, seller_user_type, total_amount, refund_amount, 
            seller_amount, rented_days, remaining_days, terminated_at, 
            admin_user_id, order_json
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        $insertTerminationStmt->execute([
            $orderId,
            1, // 终止类型：1=终止租赁不退款
            $order['buyer_user_id'],
            $order['buyer_user_type'],
            $order['seller_user_id'],
            $order['seller_user_type'],
            intval($order['total_amount']),
            $refundAmount,
            $sellerAmount,
            $rentedDays,
            $remainingDays,
            date('Y-m-d H:i:s', $now),
            $admin['admin_id'],
            json_encode($orderJson, JSON_UNESCAPED_UNICODE)
        ]);

        // 记录卖家统计记录
        $sellerUserId = $order['seller_user_id'];
        $sellerUserType = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 1 : 2;
        $sellerUsername = '';
        if ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') {
            $uStmt = $db->prepare("SELECT username FROM c_users WHERE id = ?");
            $uStmt->execute([$sellerUserId]);
            $sellerUsername = $uStmt->fetchColumn();
        } else {
            $uStmt = $db->prepare("SELECT username FROM b_users WHERE id = ?");
            $uStmt->execute([$sellerUserId]);
            $sellerUsername = $uStmt->fetchColumn();
        }
        
        if ($sellerUserType === 1) {
            // C端用户
            try {
                $stmt = $db->prepare(" 
                    INSERT INTO c_task_statistics (
                        c_user_id, username, flow_type, amount, before_balance, after_balance, 
                        related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                    ) VALUES (?, ?, 1, ?, ?, ?, 'rental_order_settlement', ?, 6, '出租订单', ?, ?, ?)
                ");
                $stmt->execute([
                    $sellerUserId,
                    $sellerUsername,
                    $sellerAmount,
                    0,
                    0,
                    $orderId,
                    8, // record_status: 订单终止不退款
                    '租赁订单终止，不退款', // record_status_text
                    "订单终止结算"
                ]);
            } catch (Exception $e) {
                error_log('插入c_task_statistics失败: ' . $e->getMessage());
            }
        } else {
            // B端用户
            try {
                $stmt = $db->prepare(" 
                    INSERT INTO b_task_statistics (
                        b_user_id, username, flow_type, amount, before_balance, after_balance, 
                        related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                    ) VALUES (?, ?, 1, ?, ?, ?, 'rental_order_settlement', ?, 6, '出租订单', ?, ?, ?)
                ");
                $stmt->execute([
                    $sellerUserId,
                    $sellerUsername,
                    $sellerAmount,
                    0,
                    0,
                    $orderId,
                    8, // record_status: 订单终止不退款
                    '租赁订单终止，不退款', // record_status_text
                    "订单终止结算"
                ]);
            } catch (Exception $e) {
                error_log('插入b_task_statistics失败: ' . $e->getMessage());
            }
        }

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
    } elseif ($action === 'terminate_refund') {
        // 4. 终止并退款 (2 -> 4)
        if ($currentStatus !== 2) {
            $db->rollBack();
            echo json_encode(['code' => $errorCodes['RENTAL_ORDER_INVALID_STATUS'], 'message' => '只有「进行中」状态的订单可以进行终止并退款操作', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $now = time();
        $startTime = $orderJson['start_time'] ?? $now;
        $totalDays = intval($order['days']);
        $totalAmount = intval($order['total_amount']);

        // 计算已租赁天数（按整天计算，未满一天按一天算）
        $rentedDays = ceil(($now - $startTime) / 86400);
        $remainingDays = max(0, $totalDays - $rentedDays);

        // 计算退款金额
        $dailyAmount = $totalDays > 0 ? ceil($totalAmount / $totalDays) : 0;
        $refundAmount = $remainingDays * $dailyAmount;
        $sellerAmount = $rentedDays * $dailyAmount;

        if ($refundAmount > 0) {
            // 退款给买家
            $buyerWalletId = $order['buyer_wallet_id'];

            // 获取买家钱包
            $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
            $walletStmt->execute([$buyerWalletId]);
            $buyerWalletBalance = $walletStmt->fetchColumn();

            if ($buyerWalletBalance === false) {
                throw new Exception("买家钱包不存在");
            }

            $newBalance = $buyerWalletBalance + $refundAmount;
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
                $refundAmount,
                $buyerWalletBalance,
                $newBalance,
                $orderId,
                "订单终止退款"
            ]);
            
            // 记录C端任务统计（仅当买家是C端用户时）
            if ($order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1') {
                try {
                    $stmt = $db->prepare(" 
                        INSERT INTO c_task_statistics (
                            c_user_id, username, flow_type, amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                        ) VALUES (?, ?, 1, ?, ?, ?, 'account_rental', ?, 6, '出租订单', ?, ?, ?)
                    ");
                    $stmt->execute([
                        $order['buyer_user_id'],
                        $username,
                        $refundAmount,
                        $buyerWalletBalance,
                        $newBalance,
                        $orderId,
                        9, // record_status: 订单终止并退款
                        '租赁订单终止，已退款', // record_status_text
                        "订单终止退款"
                    ]);
                } catch (Exception $e) {
                    // 记录插入失败时的错误日志，但不影响主流程
                    error_log('插入c_task_statistics失败: ' . $e->getMessage());
                }
            }
            
            // 仅当买家是B端用户时，插入B端任务统计记录
            if ($order['buyer_user_type'] === 'b' || $order['buyer_user_type'] === '2') {
                try {
                    $stmt = $db->prepare(" 
                        INSERT INTO b_task_statistics (
                            b_user_id, username, flow_type, amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                        ) VALUES (?, ?, 1, ?, ?, ?, 'account_rental', ?, 6, '出租订单', ?, ?, ?)
                    ");
                    $stmt->execute([
                        $order['buyer_user_id'],
                        $username,
                        $refundAmount,
                        $buyerWalletBalance,
                        $newBalance,
                        $orderId,
                        9, // record_status: 订单终止并退款
                        '租赁订单终止，已退款', // record_status_text
                        "订单终止退款"
                    ]);
                } catch (Exception $e) {
                    // 记录插入失败时的错误日志，但不影响主流程
                    error_log('插入b_task_statistics失败: ' . $e->getMessage());
                }
            }
        }

        // 结算给卖家
        if ($sellerAmount > 0) {
            $sellerWalletId = $order['seller_wallet_id'];
            $sellerUserId = $order['seller_user_id'];
            $sellerUserType = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 1 : 2;
            
            // 获取卖家钱包
            $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
            $walletStmt->execute([$sellerWalletId]);
            $sellerWalletBalance = $walletStmt->fetchColumn();

            if ($sellerWalletBalance === false) {
                throw new Exception("卖家钱包不存在");
            }

            $newSellerBalance = $sellerWalletBalance + $sellerAmount;
            $updateWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
            $updateWalletStmt->execute([$newSellerBalance, $sellerWalletId]);

            // 获取卖家用户名
            $sellerUsername = '';
            if ($order['seller_user_type'] === 'c') {
                $uStmt = $db->prepare("SELECT username FROM c_users WHERE id = ?");
                $uStmt->execute([$sellerUserId]);
                $sellerUsername = $uStmt->fetchColumn();
            } else {
                $uStmt = $db->prepare("SELECT username FROM b_users WHERE id = ?");
                $uStmt->execute([$sellerUserId]);
                $sellerUsername = $uStmt->fetchColumn();
            }

            // 记录卖家钱包流水
            $logStmt = $db->prepare(" 
                INSERT INTO wallets_log 
                (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at)
                VALUES (?, ?, ?, ?, 1, ?, ?, ?, 'rental_order_settlement', ?, ?, NOW())
            ");

            $logStmt->execute([
                $sellerWalletId,
                $sellerUserId,
                $sellerUsername,
                $sellerUserType,
                $sellerAmount,
                $sellerWalletBalance,
                $newSellerBalance,
                $orderId,
                "订单终止结算"
            ]);
            
            // 记录卖家统计记录
            if ($sellerUserType === 1) {
                // C端用户
                try {
                    $stmt = $db->prepare(" 
                        INSERT INTO c_task_statistics (
                            c_user_id, username, flow_type, amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                        ) VALUES (?, ?, 1, ?, ?, ?, 'rental_order_settlement', ?, 6, '出租订单', ?, ?, ?)
                    ");
                    $stmt->execute([
                        $sellerUserId,
                        $sellerUsername,
                        $sellerAmount,
                        $sellerWalletBalance,
                        $newSellerBalance,
                        $orderId,
                        9, // record_status: 订单终止并退款
                        '租赁订单终止，已退款', // record_status_text
                        "订单终止结算"
                    ]);
                } catch (Exception $e) {
                    error_log('插入c_task_statistics失败: ' . $e->getMessage());
                }
            } else {
                // B端用户
                try {
                    $stmt = $db->prepare(" 
                        INSERT INTO b_task_statistics (
                            b_user_id, username, flow_type, amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                        ) VALUES (?, ?, 1, ?, ?, ?, 'rental_order_settlement', ?, 6, '出租订单', ?, ?, ?)
                    ");
                    $stmt->execute([
                        $sellerUserId,
                        $sellerUsername,
                        $sellerAmount,
                        $sellerWalletBalance,
                        $newSellerBalance,
                        $orderId,
                        9, // record_status: 订单终止并退款
                        '租赁订单终止，已退款', // record_status_text
                        "订单终止结算"
                    ]);
                } catch (Exception $e) {
                    error_log('插入b_task_statistics失败: ' . $e->getMessage());
                }
            }
            
            // 记录团队收益统计
            try {
                // 查询卖方用户的一级和二级代理
                if ($sellerUserType === 1) {
                    // 查询卖方用户信息
                    $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                    $stmt->execute([$sellerUserId]);
                    $sellerUser = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    $currentUserId = $sellerUser['parent_id'] ?? null;
                    $level = 0;
                    $maxLevel = 2; // 最多查找两级
                    
                    // 调试日志
                    error_log("开始记录团队收益统计，卖方用户ID: {$sellerUserId}, 一级代理ID: {$currentUserId}");
                    
                    while (!empty($currentUserId) && $level < $maxLevel) {
                        error_log("循环开始，当前level: {$level}, currentUserId: {$currentUserId}");
                        
                        $stmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
                        $stmt->execute([$currentUserId]);
                        $agentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        if (!$agentUser) {
                            error_log("未找到代理用户，currentUserId: {$currentUserId}");
                            break;
                        }
                        
                        error_log("找到代理用户，ID: {$agentUser['id']}, 用户名: {$agentUser['username']}, level: {$level}");
                        
                        // 团队收益金额与卖方获得的收益金额相同
                        $agentCommAmount = $sellerAmount;
                        
                        // 查询当前代理的团队收益汇总记录，获取当前收益总额
                        $stmt = $db->prepare("SELECT total_team_revenue FROM team_revenue_statistics_summary WHERE user_id = ?");
                        $stmt->execute([$agentUser['id']]);
                        $summary = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        $agentBeforeAmount = $summary ? (float)$summary['total_team_revenue'] : 0;
                        $agentAfterAmount = $agentBeforeAmount + $agentCommAmount;
                        
                        // 插入团队收益记录
                        error_log("准备插入团队收益记录，代理ID: {$agentUser['id']}, 层级: " . ($level + 1) . ", 金额: {$agentCommAmount}");
                        
                        $stmt = $db->prepare("INSERT INTO team_revenue_statistics_breakdown (
                            agent_id, agent_username, agent_level, 
                            downline_user_id, downline_username, downline_user_amount, 
                            team_revenue_amount, agent_before_amount, agent_after_amount, 
                            related_id, revenue_source, revenue_source_text, 
                            order_type, order_type_text
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                        
                        $result = $stmt->execute([
                            $agentUser['id'],
                            $agentUser['username'],
                            $level + 1, // 代理层级：1=一级代理，2=二级代理
                            $sellerUserId,
                            $sellerUsername,
                            $sellerAmount, // 下线用户获得的金额
                            $agentCommAmount, // 代理获得的团队收益金额
                            $agentBeforeAmount,
                            $agentAfterAmount,
                            $orderId,
                            2, // 收益来源：2=账号出租收益
                            '账号出租收益',
                            1, // 订单类型：1=出租订单
                            '出租订单'
                        ]);
                        
                        error_log("插入团队收益记录结果: " . ($result ? "成功" : "失败") . ", 代理ID: {$agentUser['id']}");
                        
                        // 更新团队收益汇总表
                        // 先查询是否存在记录
                        $stmt = $db->prepare("SELECT id FROM team_revenue_statistics_summary WHERE user_id = ?");
                        $stmt->execute([$agentUser['id']]);
                        $exists = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        $revenueSource = 2; // 账号出租收益
                        $agentLevel = $level + 1;
                        $currentTime = date('Y-m-d H:i:s');
                        
                        error_log("准备更新团队收益汇总表，代理ID: {$agentUser['id']}, 层级: {$agentLevel}, 金额: {$agentCommAmount}");
                        
                        if ($exists) {
                            // 记录存在，执行更新
                            $updateSql = "UPDATE team_revenue_statistics_summary SET ";
                            $updateParams = [];
                            
                            // 总团队收益
                            $updateSql .= "total_team_revenue = total_team_revenue + ?, ";
                            $updateParams[] = $agentCommAmount;
                            
                            // 一级或二级下线收益
                            if ($agentLevel == 1) {
                                $updateSql .= "level1_team_revenue = level1_team_revenue + ?, ";
                                $updateParams[] = $agentCommAmount;
                            } elseif ($agentLevel == 2) {
                                $updateSql .= "level2_team_revenue = level2_team_revenue + ?, ";
                                $updateParams[] = $agentCommAmount;
                            }
                            
                            // 订单收益笔数和金额
                            $updateSql .= "order_revenue_count = order_revenue_count + 1, ";
                            $updateSql .= "order_revenue_amount = order_revenue_amount + ?, ";
                            $updateParams[] = $agentCommAmount;
                            
                            // 一级或二级下线收益笔数
                            if ($agentLevel == 1) {
                                $updateSql .= "level1_revenue_count = level1_revenue_count + 1, ";
                            } elseif ($agentLevel == 2) {
                                $updateSql .= "level2_revenue_count = level2_revenue_count + 1, ";
                            }
                            
                            // 最后收益时间
                            $updateSql .= "last_revenue_time = ?, ";
                            $updateParams[] = $currentTime;
                            
                            // 最后一级或二级下线收益时间
                            if ($agentLevel == 1) {
                                $updateSql .= "last_level1_revenue_time = ? ";
                                $updateParams[] = $currentTime;
                            } elseif ($agentLevel == 2) {
                                $updateSql .= "last_level2_revenue_time = ? ";
                                $updateParams[] = $currentTime;
                            }
                            
                            $updateSql .= "WHERE user_id = ?";
                            $updateParams[] = $agentUser['id'];
                            
                            $stmt = $db->prepare($updateSql);
                            $result = $stmt->execute($updateParams);
                        } else {
                            // 记录不存在，执行插入
                            $insertSql = "INSERT INTO team_revenue_statistics_summary (
                                user_id, username, total_team_revenue, level1_team_revenue, level2_team_revenue,
                                level1_downline_count, level2_downline_count, total_downline_count,
                                level1_active_count, level2_active_count, total_active_count,
                                task_revenue_count, order_revenue_count, task_revenue_amount, order_revenue_amount,
                                level1_revenue_count, level2_revenue_count,
                                last_revenue_time, last_level1_revenue_time, last_level2_revenue_time
                            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            
                            $insertParams = [
                                $agentUser['id'],
                                $agentUser['username'],
                                $agentCommAmount,
                                $agentLevel == 1 ? $agentCommAmount : 0,
                                $agentLevel == 2 ? $agentCommAmount : 0,
                                0, 0, 0, 0, 0, 0, // 下线人数相关字段
                                0, 1, // 任务收益笔数和订单收益笔数
                                0, $agentCommAmount, // 任务收益金额和订单收益金额
                                $agentLevel == 1 ? 1 : 0, // 一级下线收益笔数
                                $agentLevel == 2 ? 1 : 0, // 二级下线收益笔数
                                $currentTime,
                                $agentLevel == 1 ? $currentTime : null,
                                $agentLevel == 2 ? $currentTime : null
                            ];
                            
                            $stmt = $db->prepare($insertSql);
                            $result = $stmt->execute($insertParams);
                        }
                        
                        error_log("更新团队收益汇总表结果: " . ($result ? "成功" : "失败") . ", 代理ID: {$agentUser['id']}");
                        
                        // 继续向上查找
                        $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                        $stmt->execute([$agentUser['id']]);
                        $nextParent = $stmt->fetch(PDO::FETCH_ASSOC);
                        $currentUserId = $nextParent['parent_id'] ?? null;
                        error_log("继续向上查找，下一级代理ID: {$currentUserId}");
                        $level++;
                    }
                    
                    error_log("团队收益统计循环结束");
                }
            } catch (Exception $e) {
                // 记录插入失败时的错误日志，但不影响主流程
                error_log('插入team_revenue_statistics_breakdown失败: ' . $e->getMessage());
            }
        }

        // 更新订单信息
        $orderJson['terminated_at'] = $now;
        $orderJson['original_end_time'] = $orderJson['end_time'] ?? 0;
        $orderJson['end_time'] = $now; // 修正结束时间为现在
        $orderJson['refund_amount'] = $refundAmount;
        $orderJson['seller_amount'] = $sellerAmount;
        $orderJson['rented_days'] = $rentedDays;
        $orderJson['remaining_days'] = $remainingDays;

        // 更新订单状态
        $updateStmt = $db->prepare("UPDATE rental_orders SET status = 4, order_json = ? WHERE id = ?");
        $updateStmt->execute([json_encode($orderJson, JSON_UNESCAPED_UNICODE), $orderId]);

        // 插入终止租赁订单记录
        $insertTerminationStmt = $db->prepare("INSERT INTO termination_rental_orders (
            rental_order_id, termination_type, buyer_user_id, buyer_user_type, 
            seller_user_id, seller_user_type, total_amount, refund_amount, 
            seller_amount, rented_days, remaining_days, terminated_at, 
            admin_user_id, order_json
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        
        $insertTerminationStmt->execute([
            $orderId,
            2, // 终止类型：2=终止租赁并退款
            $order['buyer_user_id'],
            $order['buyer_user_type'],
            $order['seller_user_id'],
            $order['seller_user_type'],
            intval($order['total_amount']),
            $refundAmount,
            $sellerAmount,
            $rentedDays,
            $remainingDays,
            date('Y-m-d H:i:s', $now),
            $admin['admin_id'],
            json_encode($orderJson, JSON_UNESCAPED_UNICODE)
        ]);

        // 准备通知数据（稍后发送）
        $notifications[] = [
            'user_id' => $order['buyer_user_id'],
            'user_type' => $order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已终止并退款',
            'content' => "您租用的订单 #{$orderId} 已被客服终止，已退款 ¥" . number_format($refundAmount / 100, 2) . " 至您的钱包。",
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $notifications[] = [
            'user_id' => $order['seller_user_id'],
            'user_type' => $order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1' ? 1 : 2,
            'title' => '租赁订单已终止并结算',
            'content' => "您出租的订单 #{$orderId} 已被客服终止，已结算 ¥" . number_format($sellerAmount / 100, 2) . " 至您的钱包，已退款 ¥" . number_format($refundAmount / 100, 2) . " 给买家。",
            'related_type' => 'rental_order',
            'related_id' => $orderId
        ];

        $message = '订单已终止，已退款 ¥' . number_format($refundAmount / 100, 2) . '，已结算 ¥' . number_format($sellerAmount / 100, 2) . ' 给卖家';
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
