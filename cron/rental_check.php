<?php
/**
 * 租赁系统定时检测任务
 * 
 * 功能：
 * 1. 检测过期的求租信息（status=1 且 deadline < NOW()）
 *    - 自动下架并退回冻结的预算金额
 * 2. 检测到期的租赁订单（status=2 且 end_time < NOW()）
 *    - 自动完成订单
 *    - 结算卖方收益（扣除平台手续费后打入钱包）
 * 
 * 执行频率：建议每分钟执行一次
 * 命令：php /path/to/cron/rental_check.php
 */

// 设置时区
date_default_timezone_set('Asia/Shanghai');

// 引入核心文件
require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/Notification.php';

// 日志函数
function logMessage($message) {
    $timestamp = date('Y-m-d H:i:s');
    echo "[{$timestamp}] {$message}\n";
}

logMessage("=== 租赁系统定时检测任务开始 ===");

try {
    $db = Database::connect();
    
    // ==========================================
    // 任务1: 检测过期的求租信息
    // ==========================================
    logMessage("正在检测过期的求租信息...");
    
    // 查询所有过期的求租信息（status=1 且 deadline < NOW()）
    $stmt = $db->prepare("
        SELECT 
            rd.id,
            rd.user_id,
            rd.user_type,
            rd.wallet_id,
            rd.title,
            rd.budget_amount,
            rd.days_needed,
            rd.deadline,
            CASE 
                WHEN rd.user_type = 1 THEN cu.username
                WHEN rd.user_type = 2 THEN bu.username
            END as username
        FROM rental_demands rd
        LEFT JOIN c_users cu ON rd.user_type = 1 AND rd.user_id = cu.id
        LEFT JOIN b_users bu ON rd.user_type = 2 AND rd.user_id = bu.id
        WHERE rd.status = 1 
        AND rd.deadline < NOW()
    ");
    
    $stmt->execute();
    $expiredDemands = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $processedCount = 0;
    $errorCount = 0;
    
    foreach ($expiredDemands as $demand) {
        try {
            $db->beginTransaction();
            
            $demandId = $demand['id'];
            $walletId = $demand['wallet_id'];
            $userId = $demand['user_id'];
            $userType = $demand['user_type'];
            $username = $demand['username'];
            $budgetAmount = $demand['budget_amount']; // 日预算
            $daysNeeded = $demand['days_needed']; // 租期天数
            $totalAmount = $budgetAmount * $daysNeeded; // 总冻结金额
            $title = $demand['title'];
            
            logMessage("处理过期求租信息 ID={$demandId}, 标题={$title}, 日预算={$budgetAmount}分/天, 租期={$daysNeeded}天, 总冻结={$totalAmount}分");
            
            // 1. 获取当前钱包余额
            $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
            $walletStmt->execute([$walletId]);
            $currentBalance = $walletStmt->fetchColumn();
            
            if ($currentBalance === false) {
                throw new Exception("钱包不存在 (wallet_id={$walletId})");
            }
            
            // 2. 退回冻结金额到钱包（总金额 = 日预算×天数）
            $newBalance = $currentBalance + $totalAmount;
            $updateWalletStmt = $db->prepare("
                UPDATE wallets 
                SET balance = ? 
                WHERE id = ?
            ");
            $updateWalletStmt->execute([$newBalance, $walletId]);
            
            logMessage("  - 钱包余额: {$currentBalance}分 -> {$newBalance}分 (+{$totalAmount}分)");
            
            // 3. 插入钱包流水记录（解冻）
            $insertLogStmt = $db->prepare("
                INSERT INTO wallets_log 
                (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
                VALUES 
                (?, ?, ?, ?, 1, ?, ?, ?, 'rental_unfreeze', ?, ?, NOW())
            ");
            $insertLogStmt->execute([
                $walletId,
                $userId,
                $username,
                $userType,
                $totalAmount,
                $currentBalance,
                $newBalance,
                $demandId,
                "求租到期退回预算（{$budgetAmount}分/天×{$daysNeeded}天）：{$title}"
            ]);
            
            $logId = $db->lastInsertId();
            logMessage("  - 生成钱包流水: log_id={$logId}");
            
            // 4. 更新求租信息状态为"已过期"（status=3）
            $updateDemandStmt = $db->prepare("
                UPDATE rental_demands 
                SET status = 3, updated_at = NOW() 
                WHERE id = ?
            ");
            $updateDemandStmt->execute([$demandId]);
            
            logMessage("  - 更新求租状态: status=3 (已过期)");
            
            $db->commit();

            // 发送通知
            Notification::sendToUser(
                $db,
                $userId,
                $userType,
                '求租已过期',
                "您的求租「{$title}」已过期，预算金额已退回您的钱包。",
                'rental_demand',
                $demandId
            );

            $processedCount++;
            
            logMessage("✓ 成功处理求租信息 ID={$demandId}");
            
        } catch (Exception $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            $errorCount++;
            logMessage("✗ 处理失败 ID={$demandId}: " . $e->getMessage());
        }
    }
    
    logMessage("过期求租信息检测完成: 共{$processedCount}条成功，{$errorCount}条失败");
    
    // ==========================================
    // 任务2: 检测到期的租赁订单并结算
    // ==========================================
    logMessage("\n--- 开始检测到期的租赁订单 ---");
    
    // 读取配置
    $appConfig = require __DIR__ . '/../config/app.php';
    
    // 查询到期的订单（status=2 进行中，且 end_time < 当前时间）
    $stmt = $db->prepare("
        SELECT
            ro.id,
            ro.buyer_user_id,
            ro.buyer_user_type,
            ro.buyer_wallet_id,
            ro.seller_user_id,
            ro.seller_user_type,
            ro.seller_wallet_id,
            ro.total_amount,
            ro.seller_amount,
            ro.agent_user_id,
            ro.agent_amount,
            ro.order_json,
            CASE 
                WHEN ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1' THEN cu_buyer.username
                ELSE bu_buyer.username
            END as buyer_username,
            CASE 
                WHEN ro.seller_user_type = 'c' OR ro.seller_user_type = '1' THEN cu_seller.username
                ELSE bu_seller.username
            END as seller_username
        FROM rental_orders ro
        LEFT JOIN c_users cu_buyer ON (ro.buyer_user_type = 'c' OR ro.buyer_user_type = '1') AND ro.buyer_user_id = cu_buyer.id
        LEFT JOIN b_users bu_buyer ON (ro.buyer_user_type = 'b' OR ro.buyer_user_type = '2') AND ro.buyer_user_id = bu_buyer.id
        LEFT JOIN c_users cu_seller ON (ro.seller_user_type = 'c' OR ro.seller_user_type = '1') AND ro.seller_user_id = cu_seller.id
        LEFT JOIN b_users bu_seller ON (ro.seller_user_type = 'b' OR ro.seller_user_type = '2') AND ro.seller_user_id = bu_seller.id
        WHERE ro.status = 2 
        AND JSON_EXTRACT(ro.order_json, '$.end_time') < UNIX_TIMESTAMP()
    ");
    
    $stmt->execute();
    $expiredOrders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $orderProcessedCount = 0;
    $orderErrorCount = 0;
    
    logMessage("找到 " . count($expiredOrders) . " 个到期订单");
    
    foreach ($expiredOrders as $order) {
        try {
            $db->beginTransaction();
            
            $orderId = $order['id'];
            $sellerWalletId = $order['seller_wallet_id'];
            $sellerUserId = $order['seller_user_id'];
            $sellerUserType = ($order['seller_user_type'] === 'c' || $order['seller_user_type'] === '1') ? 1 : 2;
            $sellerUsername = $order['seller_username'];
            $sellerAmount = $order['seller_amount'];
            
            $buyerUserId = $order['buyer_user_id'];
            $buyerUserType = ($order['buyer_user_type'] === 'c' || $order['buyer_user_type'] === '1') ? 1 : 2;
            $buyerUsername = $order['buyer_username'];
            
            $orderJson = json_decode($order['order_json'], true);
            $endTime = $orderJson['end_time'] ?? 0;
            
            logMessage("处理到期订单 ID={$orderId}, 卖方={$sellerUsername}, 应得金额={$sellerAmount}分");
            
            // 1. 获取卖方钱包余额
            $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
            $walletStmt->execute([$sellerWalletId]);
            $currentBalance = $walletStmt->fetchColumn();
            
            if ($currentBalance === false) {
                throw new Exception("卖方钱包不存在 (wallet_id={$sellerWalletId})");
            }
            
            // 2. 将卖方收益打入钱包
            $newBalance = $currentBalance + $sellerAmount;
            $updateWalletStmt = $db->prepare("
                UPDATE wallets 
                SET balance = ? 
                WHERE id = ?
            ");
            $updateWalletStmt->execute([$newBalance, $sellerWalletId]);
            
            logMessage("  - 卖方钱包余额: {$currentBalance}分 -> {$newBalance}分 (+{$sellerAmount}分)");
            
            // 3. 插入卖方钱包流水记录（收益结算）
            $insertLogStmt = $db->prepare("
                INSERT INTO wallets_log 
                (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
                VALUES 
                (?, ?, ?, ?, 1, ?, ?, ?, 'rental_order_settlement', ?, ?, NOW())
            ");
            $insertLogStmt->execute([
                $sellerWalletId,
                $sellerUserId,
                $sellerUsername,
                $sellerUserType,
                $sellerAmount,
                $currentBalance,
                $newBalance,
                $orderId,
                "租赁订单结算收益（订单#{$orderId}）"
            ]);

            logMessage("  - 创建钱包流水记录");

            // 2.5 结算团长佣金（如果有）
            $agentUserId = $order['agent_user_id'] ?? null;
            $agentAmount = intval($order['agent_amount'] ?? 0);

            if ($agentUserId && $agentAmount > 0) {
                // 查询团长信息
                $agentStmt = $db->prepare("SELECT id, username, wallet_id FROM c_users WHERE id = ?");
                $agentStmt->execute([$agentUserId]);
                $agentUser = $agentStmt->fetch(PDO::FETCH_ASSOC);

                if ($agentUser) {
                    $agentWalletId = $agentUser['wallet_id'];

                    // 获取团长钱包余额
                    $agentWalletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $agentWalletStmt->execute([$agentWalletId]);
                    $agentCurrentBalance = $agentWalletStmt->fetchColumn();

                    if ($agentCurrentBalance !== false) {
                        $agentNewBalance = $agentCurrentBalance + $agentAmount;

                        // 更新团长钱包
                        $updateAgentWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $updateAgentWalletStmt->execute([$agentNewBalance, $agentWalletId]);

                        // 插入团长钱包流水
                        $insertAgentLogStmt = $db->prepare("
                            INSERT INTO wallets_log
                            (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at)
                            VALUES
                            (?, ?, ?, 1, 1, ?, ?, ?, 'rental_agent_commission', ?, ?, NOW())
                        ");
                        $insertAgentLogStmt->execute([
                            $agentWalletId,
                            $agentUser['id'],
                            $agentUser['username'],
                            $agentAmount,
                            $agentCurrentBalance,
                            $agentNewBalance,
                            $orderId,
                            "租赁订单团长佣金（订单#{$orderId}）"
                        ]);

                        logMessage("  - 团长佣金结算: {$agentUser['username']} +{$agentAmount}分");
                    }
                }
            }
            
            // 4. 更新订单状态为已完成
            $updateOrderStmt = $db->prepare("
                UPDATE rental_orders 
                SET status = 3, updated_at = NOW()
                WHERE id = ?
            ");
            $updateOrderStmt->execute([$orderId]);
            
            logMessage("  - 更新订单状态: 进行中(2) -> 已完成(3)");
            
            $db->commit();
            
            // 5. 发送通知（在事务外）
            // 通知卖方
            Notification::sendToUser(
                $db,
                $sellerUserId,
                $sellerUserType,
                '租赁订单已完成',
                "您出租的订单 #{$orderId} 已完成，收益 ¥" . number_format($sellerAmount / 100, 2) . " 已到账",
                'rental_order',
                $orderId
            );
            
            // 通知买方
            Notification::sendToUser(
                $db,
                $buyerUserId,
                $buyerUserType,
                '租赁订单已完成',
                "您租用的订单 #{$orderId} 已到期完成，感谢使用",
                'rental_order',
                $orderId
            );
            
            logMessage("  - 发送通知给买卖双方");
            
            $orderProcessedCount++;
            
            logMessage("✓ 成功处理订单 ID={$orderId}");
            
        } catch (Exception $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            $orderErrorCount++;
            logMessage("✗ 处理订单失败 ID={$orderId}: " . $e->getMessage());
        }
    }
    
    logMessage("到期订单检测完成: 共{$orderProcessedCount}条成功，{$orderErrorCount}条失败");
    
    logMessage("\n=== 租赁系统定时检测任务结束 ===");
    
} catch (Exception $e) {
    logMessage("定时任务执行失败: " . $e->getMessage());
    exit(1);
}

exit(0);
