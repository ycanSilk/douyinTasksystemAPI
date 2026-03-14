<?php
/**
 * 提现申请审核
 * POST /task_admin/api/withdraw/review.php
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Notification.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

$admin = AdminAuthMiddleware::authenticate();
$db = Database::connect();

$input = json_decode(file_get_contents('php://input'), true);
$id = (int)($input['id'] ?? 0);
$action = trim($input['action'] ?? ''); // approve / reject
$rejectReason = trim($input['reject_reason'] ?? '');
$imgUrl = trim($input['img_url'] ?? ''); // 审核凭证图片

if (!$id) {
    echo json_encode(['code' => 1002, 'message' => '申请ID不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($action, ['approve', 'reject'])) {
    echo json_encode(['code' => 1003, 'message' => '审核操作无效', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'reject' && empty($rejectReason)) {
    echo json_encode(['code' => 1004, 'message' => '拒绝时必须填写原因', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $db->beginTransaction();
    
    // 查询申请记录
    $stmt = $db->prepare("SELECT * FROM withdraw_requests WHERE id = ? FOR UPDATE");
    $stmt->execute([$id]);
    $request = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$request) {
        $db->rollBack();
        echo json_encode(['code' => 1005, 'message' => '申请记录不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if ((int)$request['status'] !== 0) {
        $db->rollBack();
        echo json_encode(['code' => 1006, 'message' => '该申请已审核，不能重复操作', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $walletId = (int)$request['wallet_id'];
    $amount = (int)$request['amount'];
    $logId = (int)$request['log_id'];
    
    if ($action === 'approve') {
        // 审核通过（款项已在申请时扣除，这里只记录审核通过）
        
        // 1. 查询当前钱包余额
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$walletId]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$wallet) {
            $db->rollBack();
            echo json_encode(['code' => 1007, 'message' => '钱包不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $currentBalance = (int)$wallet['balance'];
        
        // 2. 插入新的wallet_log记录（amount=0，仅记录审核通过）
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, remark, created_at
            ) VALUES (?, ?, ?, ?, 2, 0, ?, ?, 'withdraw', ?, ?, NOW())
        ");
        $stmt->execute([
            $walletId,
            (int)$request['user_id'],
            $request['username'],
            (int)$request['user_type'],
            $currentBalance,
            $currentBalance,
            $id,
            "提现审核通过：¥" . number_format($amount / 100, 2)
        ]);
        
        // 3. 记录C端任务统计（仅当用户类型为C端时）
        if ((int)$request['user_type'] === 1) {
            try {
                $stmt = $db->prepare(" 
                    INSERT INTO c_task_statistics (
                        c_user_id, username, flow_type, amount, before_balance, after_balance, 
                        related_type, related_id, task_types, task_types_text, remark
                    ) VALUES (?, ?, 2, 0, ?, ?, 'withdraw', ?, NULL, NULL, ?)
                ");
                $stmt->execute([
                    (int)$request['user_id'],
                    $request['username'],
                    $currentBalance,
                    $currentBalance,
                    $id,
                    "提现审核通过：¥" . number_format($amount / 100, 2)
                ]);
            } catch (Exception $e) {
                // 记录插入失败时的错误日志，但不影响主流程
                error_log('插入c_task_statistics失败: ' . $e->getMessage());
            }
        }
        
        // 3. 更新申请记录（包含图片）
        $stmt = $db->prepare("
            UPDATE withdraw_requests 
            SET status = 1, img_url = ?, reviewed_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$imgUrl, $id]);
        
        // 4. 提交事务（先完成主业务）
        $db->commit();
        
        // 5. 发送通知给用户（事务外，避免嵌套事务）
        $actualAmount = (int)$request['actual_amount'];
        $feeAmount = (int)$request['fee_amount'];
        $notificationTitle = '提现审核通过';
        $notificationContent = "您的提现申请已审核通过，提现金额：¥" . number_format($amount / 100, 2) . "，手续费：¥" . number_format($feeAmount / 100, 2) . "，实际到账：¥" . number_format($actualAmount / 100, 2) . "。\n\n收款方式：{$request['withdraw_method']}\n收款账号：{$request['withdraw_account']}";
        Notification::send(
            $db,
            $notificationTitle,
            $notificationContent,
            Notification::TARGET_USER,
            (int)$request['user_id'],
            (int)$request['user_type'],
            Notification::SENDER_SYSTEM
        );

        // ========== 团长激励逻辑（事务外独立执行） ==========
        try {
            // 仅C端用户触发激励
            if ((int)$request['user_type'] === 1) {
                $incentiveEnabled = (int)AppConfig::get('agent_incentive_enabled', 0);
                $incentiveEndTime = AppConfig::get('agent_incentive_end_time', '2000-01-01 00:00:00');
                $incentiveAmount = (int)AppConfig::get('agent_incentive_amount', 1000);
                $incentiveMinWithdraw = (int)AppConfig::get('agent_incentive_min_withdraw', 10000);
                $incentiveLimitEnabled = (int)AppConfig::get('agent_incentive_limit_enabled', 0);
                $incentiveLimitCount = (int)AppConfig::get('agent_incentive_limit_count', 10);

                if ($incentiveEnabled === 1
                    && date('Y-m-d H:i:s') < $incentiveEndTime
                    && $amount >= $incentiveMinWithdraw
                ) {
                    // 检查是否为该用户的首次成功提现（排除当前这笔）
                    $stmtFirst = $db->prepare("
                        SELECT COUNT(*) FROM withdraw_requests
                        WHERE user_id = ? AND user_type = 1 AND status = 1 AND id != ?
                    ");
                    $stmtFirst->execute([(int)$request['user_id'], $id]);
                    $previousApproved = (int)$stmtFirst->fetchColumn();

                    if ($previousApproved === 0) {
                        // 查询用户的上级
                        $stmtParent = $db->prepare("
                            SELECT id, username, parent_id, is_agent, wallet_id
                            FROM c_users WHERE id = ?
                        ");
                        $stmtParent->execute([(int)$request['user_id']]);
                        $cUser = $stmtParent->fetch(PDO::FETCH_ASSOC);

                        if ($cUser && $cUser['parent_id']) {
                            // 查询上级是否为团长
                            $stmtAgent = $db->prepare("
                                SELECT id, username, is_agent, wallet_id
                                FROM c_users WHERE id = ? AND is_agent >= 1
                            ");
                            $stmtAgent->execute([(int)$cUser['parent_id']]);
                            $agent = $stmtAgent->fetch(PDO::FETCH_ASSOC);

                            if ($agent) {
                                $canReward = true;

                                // 检查人数限制
                                if ($incentiveLimitEnabled === 1) {
                                    $stmtCount = $db->prepare("
                                        SELECT COUNT(*) FROM wallets_log
                                        WHERE user_id = ? AND user_type = 1 AND related_type = 'agent_incentive'
                                    ");
                                    $stmtCount->execute([(int)$agent['id']]);
                                    $rewardedCount = (int)$stmtCount->fetchColumn();
                                    if ($rewardedCount >= $incentiveLimitCount) {
                                        $canReward = false;
                                    }
                                }

                                if ($canReward) {
                                    // 开启事务给团长充值
                                    $db->beginTransaction();

                                    $stmtWallet = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
                                    $stmtWallet->execute([(int)$agent['wallet_id']]);
                                    $agentWallet = $stmtWallet->fetch(PDO::FETCH_ASSOC);

                                    if ($agentWallet) {
                                        $agentBefore = (int)$agentWallet['balance'];
                                        $agentAfter = $agentBefore + $incentiveAmount;

                                        // 更新团长钱包余额
                                        $stmtUp = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                                        $stmtUp->execute([$agentAfter, (int)$agent['wallet_id']]);

                                        // 写入流水记录
                                        $stmtLog = $db->prepare("
                                            INSERT INTO wallets_log (
                                                wallet_id, user_id, username, user_type, type,
                                                amount, before_balance, after_balance,
                                                related_type, related_id, remark, created_at
                                            ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'agent_incentive', ?, ?, NOW())
                                        ");
                                        $stmtLog->execute([
                                            (int)$agent['wallet_id'],
                                            (int)$agent['id'],
                                            $agent['username'],
                                            $incentiveAmount,
                                            $agentBefore,
                                            $agentAfter,
                                            $id,
                                            "团长激励奖励：下级用户{$request['username']}首次提现，奖励¥" . number_format($incentiveAmount / 100, 2)
                                        ]);

                                        $db->commit();

                                        // 发送通知给团长
                                        Notification::send(
                                            $db,
                                            '团长激励奖励到账',
                                            "恭喜！您的下级用户 {$request['username']} 完成首次提现，您获得激励奖励 ¥" . number_format($incentiveAmount / 100, 2) . "，已自动充值到您的钱包。",
                                            Notification::TARGET_USER,
                                            (int)$agent['id'],
                                            1,
                                            Notification::SENDER_SYSTEM
                                        );
                                    } else {
                                        $db->rollBack();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception $e) {
            // 激励逻辑失败不影响主流程，仅记录日志
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            error_log("团长激励逻辑异常: " . $e->getMessage());
        }
        // ========== 团长激励逻辑结束 ==========

        echo json_encode(['code' => 0, 'message' => '审核通过，已打款', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        
    } else {
        // 审核拒绝（需要退款，因为申请时已扣款）
        
        // 1. 查询当前钱包余额并锁定
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
        $stmt->execute([$walletId]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$wallet) {
            $db->rollBack();
            echo json_encode(['code' => 1007, 'message' => '钱包不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $beforeBalance = (int)$wallet['balance'];
        $afterBalance = $beforeBalance + $amount; // 退款
        
        // 2. 退款到钱包
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$afterBalance, $walletId]);
        
        // 3. 插入退款wallet_log记录
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, remark, created_at
            ) VALUES (?, ?, ?, ?, 1, ?, ?, ?, 'withdraw', ?, ?, NOW())
        ");
        $stmt->execute([
            $walletId,
            (int)$request['user_id'],
            $request['username'],
            (int)$request['user_type'],
            $amount,
            $beforeBalance,
            $afterBalance,
            $id,
            "提现申请被拒绝，退款：¥" . number_format($amount / 100, 2)
        ]);
        
        // 4. 记录C端任务统计（仅当用户类型为C端时）
        if ((int)$request['user_type'] === 1) {
            try {
                $stmt = $db->prepare(" 
                    INSERT INTO c_task_statistics (
                        c_user_id, username, flow_type, amount, before_balance, after_balance, 
                        related_type, related_id, task_types, task_types_text, remark
                    ) VALUES (?, ?, 1, ?, ?, ?, 'withdraw', ?, NULL, NULL, ?)
                ");
                $stmt->execute([
                    (int)$request['user_id'],
                    $request['username'],
                    $amount,
                    $beforeBalance,
                    $afterBalance,
                    $id,
                    "提现申请被拒绝，退款：¥" . number_format($amount / 100, 2)
                ]);
            } catch (Exception $e) {
                // 记录插入失败时的错误日志，但不影响主流程
                error_log('插入c_task_statistics失败: ' . $e->getMessage());
            }
        }
        
        // 4. 更新申请记录
        $stmt = $db->prepare("
            UPDATE withdraw_requests 
            SET status = 2, reject_reason = ?, reviewed_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$rejectReason, $id]);
        
        // 5. 提交事务（先完成主业务）
        $db->commit();
        
        // 6. 发送通知给用户（事务外，避免嵌套事务）
        $notificationTitle = '提现审核未通过';
        $notificationContent = "很抱歉，您的提现申请未通过审核。\n\n拒绝原因：{$rejectReason}\n\n如有疑问，请联系客服。";
        Notification::send(
            $db,
            $notificationTitle,
            $notificationContent,
            Notification::TARGET_USER,
            (int)$request['user_id'],
            (int)$request['user_type'],
            Notification::SENDER_SYSTEM
        );
        
        echo json_encode(['code' => 0, 'message' => '已拒绝申请', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    }
    
} catch (PDOException $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '审核失败：' . $e->getMessage(), 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
