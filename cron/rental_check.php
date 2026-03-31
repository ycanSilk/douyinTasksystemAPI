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
require_once __DIR__ . '/../core/AppConfig.php';

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
                (?, ?, ?, ?, 1, ?, ?, ?, '求租到期退回预算', ?, ?, NOW())
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
                (?, ?, ?, ?, 1, ?, ?, ?, '求租到期退回预算', ?, ?, NOW())
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
                            (?, ?, ?, 1, 1, ?, ?, ?, '租赁团长佣金', ?, ?, NOW())
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
            
            // 5. 插入统计记录
            // 5.1 为卖方插入统计记录（仅C端用户）
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
                        $currentBalance,
                        $newBalance,
                        $orderId,
                        3, // record_status: 订单完成
                        '租赁订单已完成', // record_status_text
                        "租赁订单结算收益（订单#{$orderId}）"
                    ]);
                    logMessage("  - 插入C端统计记录: seller_id={$sellerUserId}");
                } catch (Exception $e) {
                    // 记录插入失败时的错误日志，但不影响主流程
                    error_log('插入c_task_statistics失败: ' . $e->getMessage());
                }
            }
            
            // 5.2 为买方插入统计记录（仅C端用户）
            if ($buyerUserType === 1) {
                try {
                    // 查询买方钱包余额
                    $buyerWalletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $buyerWalletStmt->execute([$order['buyer_wallet_id']]);
                    $buyerBalance = $buyerWalletStmt->fetchColumn();
                    
                    if ($buyerBalance !== false) {
                        $stmt = $db->prepare(" 
                            INSERT INTO c_task_statistics (
                                c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                            ) VALUES (?, ?, 2, ?, ?, ?, 'rental_order', ?, 7, '求租订单', ?, ?, ?)
                        ");
                        $stmt->execute([
                            $buyerUserId,
                            $buyerUsername,
                            $order['total_amount'],
                            $buyerBalance,
                            $buyerBalance,
                            $orderId,
                            3, // record_status: 订单完成
                            '租赁订单已完成', // record_status_text
                            "租赁订单支付（订单#{$orderId}）"
                        ]);
                        logMessage("  - 插入C端统计记录: buyer_id={$buyerUserId}");
                    }
                } catch (Exception $e) {
                    // 记录插入失败时的错误日志，但不影响主流程
                    error_log('插入c_task_statistics失败: ' . $e->getMessage());
                }
            }
            
            // 5.3 为团长和二级代理插入佣金统计记录
            if ($sellerUserType === 1) {
                // 查询卖方的上级代理
                $stmt = $db->prepare("SELECT id, username, wallet_id, parent_id, is_agent FROM c_users WHERE id = ?");
                $stmt->execute([$sellerUserId]);
                $sellerUser = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if ($sellerUser && !empty($sellerUser['parent_id'])) {
                    // 查询一级上级用户
                    $stmt = $db->prepare("SELECT id, username, wallet_id, is_agent, parent_id FROM c_users WHERE id = ?");
                    $stmt->execute([$sellerUser['parent_id']]);
                    $parentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    $parentAgentLevel = $parentUser ? (int)$parentUser['is_agent'] : 0;
                    
                    if ($parentUser && $parentAgentLevel >= 1) {
                        // 获取代理佣金配置
                        $agentCommissionAmount = (int)AppConfig::get('rental_agent_commission', 0);
                        $seniorAgentCommissionAmount = (int)AppConfig::get('rental_senior_agent_commission', 0);
                        
                        // 大团团长(3)、高级团长(2)用senior_agent佣金，普通团长(1)用agent佣金
                        if ($parentAgentLevel === 3 || $parentAgentLevel === 2) {
                            $agentCommission = $seniorAgentCommissionAmount;
                        } else {
                            $agentCommission = $agentCommissionAmount;
                        }
                        
                        // 查询团长钱包
                        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                        $stmt->execute([$parentUser['wallet_id']]);
                        $agentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        if ($agentWallet) {
                            $agentBeforeBalance = (int)$agentWallet['balance'];
                            $agentAfterBalance = $agentBeforeBalance + $agentCommission;
                            
                            // 记录一级代理C端任务统计
                            try {
                                $stmt = $db->prepare(" 
                                    INSERT INTO c_task_statistics (
                                        c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                        related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                                    ) VALUES (?, ?, 1, ?, ?, ?, 'agent_commission', ?, 6, '出租订单', ?, ?, ?)
                                ");
                                $stmt->execute([
                                    $parentUser['id'],
                                    $parentUser['username'],
                                    $agentCommission,
                                    $agentBeforeBalance,
                                    $agentAfterBalance,
                                    $orderId,
                                    3, // record_status: 订单完成
                                    '租赁订单已完成', // record_status_text
                                    "租赁订单团长佣金（订单#{$orderId}）"
                                ]);
                                logMessage("  - 插入一级代理统计记录: agent_id={$parentUser['id']}");
                            } catch (Exception $e) {
                                // 记录插入失败时的错误日志，但不影响主流程
                                error_log('插入c_task_statistics失败: ' . $e->getMessage());
                            }
                            
                            // 查询二级上级用户
                            if (!empty($parentUser['parent_id'])) {
                                $stmt = $db->prepare("SELECT id, username, wallet_id, is_agent FROM c_users WHERE id = ?");
                                $stmt->execute([$parentUser['parent_id']]);
                                $secondParentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                                
                                $secondParentAgentLevel = $secondParentUser ? (int)$secondParentUser['is_agent'] : 0;
                                
                                if ($secondParentUser && $secondParentAgentLevel >= 1) {
                                    // 大团团长(3)、高级团长(2)用senior_agent佣金，普通团长(1)用agent佣金
                                    if ($secondParentAgentLevel === 3 || $secondParentAgentLevel === 2) {
                                        $secondAgentCommission = $seniorAgentCommissionAmount;
                                    } else {
                                        $secondAgentCommission = $agentCommissionAmount;
                                    }
                                    
                                    // 查询二级团长钱包
                                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                                    $stmt->execute([$secondParentUser['wallet_id']]);
                                    $secondAgentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                                    
                                    if ($secondAgentWallet) {
                                        $secondAgentBeforeBalance = (int)$secondAgentWallet['balance'];
                                        $secondAgentAfterBalance = $secondAgentBeforeBalance + $secondAgentCommission;
                                        
                                        // 记录二级代理C端任务统计
                                        try {
                                            $stmt = $db->prepare(" 
                                                INSERT INTO c_task_statistics (
                                                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                                    related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                                                ) VALUES (?, ?, 1, ?, ?, ?, 'second_agent_commission', ?, 6, '出租订单', ?, ?, ?)
                                            ");
                                            $stmt->execute([
                                                $secondParentUser['id'],
                                                $secondParentUser['username'],
                                                $secondAgentCommission,
                                                $secondAgentBeforeBalance,
                                                $secondAgentAfterBalance,
                                                $orderId,
                                                3, // record_status: 订单完成
                                                '租赁订单已完成', // record_status_text
                                                "租赁订单二级代理佣金（订单#{$orderId}）"
                                            ]);
                                            logMessage("  - 插入二级代理统计记录: agent_id={$secondParentUser['id']}");
                                        } catch (Exception $e) {
                                            // 记录插入失败时的错误日志，但不影响主流程
                                            error_log('插入c_task_statistics失败: ' . $e->getMessage());
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 5.4 发放代理佣金
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
                    
                    // 读取配置
                    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = ?");
                    $stmt->execute(['rental_agent_rate']);
                    $rentalAgentRate = $stmt->fetchColumn();
                    $rentalAgentRate = $rentalAgentRate ? (float)$rentalAgentRate : 5; // 默认5%
                    
                    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = ?");
                    $stmt->execute(['rental_senior_agent_rate']);
                    $rentalSeniorAgentRate = $stmt->fetchColumn();
                    $rentalSeniorAgentRate = $rentalSeniorAgentRate ? (float)$rentalSeniorAgentRate : 5; // 默认5%
                    
                    logMessage("开始发放代理佣金，卖方用户ID: {$sellerUserId}, 一级代理ID: {$currentUserId}");
                    
                    while (!empty($currentUserId) && $level < $maxLevel) {
                        logMessage("循环开始，当前level: {$level}, currentUserId: {$currentUserId}");
                        
                        $stmt = $db->prepare("SELECT id, username, wallet_id, is_agent, parent_id FROM c_users WHERE id = ?");
                        $stmt->execute([$currentUserId]);
                        $agentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        if (!$agentUser) {
                            logMessage("未找到代理用户，currentUserId: {$currentUserId}");
                            break;
                        }
                        
                        $agentLevel = $agentUser['is_agent'] ?? 0;
                        logMessage("找到代理用户，ID: {$agentUser['id']}, 用户名: {$agentUser['username']}, level: {$level}, is_agent: {$agentLevel}");
                        
                        // 只有团长或以上等级才发放佣金
                        if ($agentLevel > 0) {
                            // 根据代理等级计算佣金
                            if ($agentLevel === 1) {
                                // 普通团长
                                $commissionRate = $rentalAgentRate;
                            } else {
                                // 高级团长或大团团长
                                $commissionRate = $rentalSeniorAgentRate;
                            }
                            
                            // 计算佣金金额：账号结算金额 * 配置值（百分比）
                            $agentCommission = (int)round($sellerAmount * $commissionRate / 100);
                            
                            if ($agentCommission > 0) {
                                // 查询代理钱包
                                $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                                $stmt->execute([$agentUser['wallet_id']]);
                                $agentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                                
                                if ($agentWallet) {
                                    $agentBeforeBalance = (int)$agentWallet['balance'];
                                    $agentAfterBalance = $agentBeforeBalance + $agentCommission;
                                    
                                    // 更新代理钱包
                                    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                                    $stmt->execute([$agentAfterBalance, $agentUser['wallet_id']]);
                                    
                                    // 记录代理钱包流水
                                    $stmt = $db->prepare(" 
                                        INSERT INTO wallets_log (
                                            wallet_id, user_id, username, user_type, type, 
                                            amount, before_balance, after_balance, 
                                            related_type, related_id, remark, created_at
                                        ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, '租赁团长佣金', ?, ?, NOW())
                                    ");
                                    $stmt->execute([
                                        $agentUser['wallet_id'],
                                        $agentUser['id'],
                                        $agentUser['username'],
                                        $agentCommission,
                                        $agentBeforeBalance,
                                        $agentAfterBalance,
                                        $orderId,
                                        "租赁订单代理佣金（订单#{$orderId}）"
                                    ]);
                                    
                                    // 记录代理C端任务统计
                                    try {
                                        $stmt = $db->prepare(" 
                                            INSERT INTO c_task_statistics (
                                                c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                                related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                                            ) VALUES (?, ?, 1, ?, ?, ?, 'rental_agent_commission', ?, 6, '出租订单', ?, ?, ?)
                                        ");
                                        $stmt->execute([
                                            $agentUser['id'],
                                            $agentUser['username'],
                                            $agentCommission,
                                            $agentBeforeBalance,
                                            $agentAfterBalance,
                                            $orderId,
                                            3, // record_status: 订单完成
                                            '租赁订单已完成', // record_status_text
                                            "租赁订单代理佣金（订单#{$orderId}）"
                                        ]);
                                        logMessage("  - 插入代理统计记录: agent_id={$agentUser['id']}, 金额={$agentCommission}分");
                                    } catch (Exception $e) {
                                        // 记录插入失败时的错误日志，但不影响主流程
                                        error_log('插入c_task_statistics失败: ' . $e->getMessage());
                                    }
                                }
                            }
                        }
                        
                        // 继续向上查找
                        $currentUserId = $agentUser['parent_id'] ?? null;
                        logMessage("继续向上查找，下一级代理ID: {$currentUserId}");
                        $level++;
                    }
                    
                    logMessage("代理佣金发放循环结束");
                }
            } catch (Exception $e) {
                // 记录插入失败时的错误日志，但不影响主流程
                error_log('发放代理佣金失败: ' . $e->getMessage());
                logMessage("代理佣金发放失败: " . $e->getMessage());
            }
            
            // 5.5 记录团队收益统计
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
                    logMessage("开始记录团队收益统计，卖方用户ID: {$sellerUserId}, 一级代理ID: {$currentUserId}");
                    
                    while (!empty($currentUserId) && $level < $maxLevel) {
                        logMessage("循环开始，当前level: {$level}, currentUserId: {$currentUserId}");
                        
                        $stmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
                        $stmt->execute([$currentUserId]);
                        $agentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        if (!$agentUser) {
                            logMessage("未找到代理用户，currentUserId: {$currentUserId}");
                            break;
                        }
                        
                        logMessage("找到代理用户，ID: {$agentUser['id']}, 用户名: {$agentUser['username']}, level: {$level}");
                        
                        // 团队收益金额与卖方获得的收益金额相同
                        $agentCommAmount = $sellerAmount;
                        
                        // 查询当前代理的团队收益汇总记录，获取当前收益总额
                        $stmt = $db->prepare("SELECT total_team_revenue FROM team_revenue_statistics_summary WHERE user_id = ?");
                        $stmt->execute([$agentUser['id']]);
                        $summary = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        $agentBeforeAmount = $summary ? (float)$summary['total_team_revenue'] : 0;
                        $agentAfterAmount = $agentBeforeAmount + $agentCommAmount;
                        
                        // 插入团队收益记录
                        logMessage("准备插入团队收益记录，代理ID: {$agentUser['id']}, 层级: " . ($level + 1) . ", 金额: {$agentCommAmount}");
                        
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
                        
                        logMessage("插入团队收益记录结果: " . ($result ? "成功" : "失败") . ", 代理ID: {$agentUser['id']}");
                        
                        // 更新团队收益汇总表
                        // 先查询是否存在记录
                        $stmt = $db->prepare("SELECT id FROM team_revenue_statistics_summary WHERE user_id = ?");
                        $stmt->execute([$agentUser['id']]);
                        $exists = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        $revenueSource = 2; // 账号出租收益
                        $agentLevel = $level + 1;
                        $currentTime = date('Y-m-d H:i:s');
                        
                        logMessage("准备更新团队收益汇总表，代理ID: {$agentUser['id']}, 层级: {$agentLevel}, 金额: {$agentCommAmount}");
                        
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
                        
                        logMessage("更新团队收益汇总表结果: " . ($result ? "成功" : "失败") . ", 代理ID: {$agentUser['id']}");
                        
                        // 继续向上查找
                        $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                        $stmt->execute([$agentUser['id']]);
                        $nextParent = $stmt->fetch(PDO::FETCH_ASSOC);
                        $currentUserId = $nextParent['parent_id'] ?? null;
                        logMessage("继续向上查找，下一级代理ID: {$currentUserId}");
                        $level++;
                    }
                    
                    logMessage("团队收益统计循环结束");
                }
            } catch (Exception $e) {
                // 记录插入失败时的错误日志，但不影响主流程
                error_log('插入team_revenue_statistics_breakdown失败: ' . $e->getMessage());
                logMessage("团队收益统计失败: " . $e->getMessage());
            }
            
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
