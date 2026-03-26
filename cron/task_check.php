<?php
/**
 * 任务系统定时检测脚本
 *
 * 功能：
 * 1. 检测过期的B端任务，自动下架
 * 2. 检测C端超时未提交的任务，自动释放回任务池
 *
 * 执行频率：建议每分钟执行一次
 *
 * Crontab 示例：
 * * * * * * /usr/bin/php /path/to/cron/task_check.php >> /path/to/logs/task_check.log 2>&1
 */

// 设置时区
date_default_timezone_set('Asia/Shanghai');

// 引入必要的文件
require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/Notification.php';
require_once __DIR__ . '/../core/AppConfig.php';

// 日志函数
function log_message($message) {
    echo '[' . date('Y-m-d H:i:s') . '] ' . $message . PHP_EOL;
}

try {
    log_message('=== 任务系统定时检测开始 ===');
    
    $db = Database::connect();
    $currentTime = time();
    
    // ============================================
    // 1. 检测过期的B端任务
    // ============================================
    log_message('正在检测过期的B端任务...');
    
    // 查询所有进行中且已过期的任务
    $stmt = $db->prepare("
        SELECT 
            bt.id,
            bt.b_user_id,
            bt.template_id,
            bt.task_count,
            bt.task_done,
            bt.task_doing,
            bt.task_reviewing,
            bt.deadline,
            bt.combo_task_id,
            bt.stage,
            tt.title as template_title,
            bu.username as b_username
        FROM b_tasks bt
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        INNER JOIN b_users bu ON bt.b_user_id = bu.id
        WHERE bt.status = 1 
        AND bt.deadline < ?
    ");
    $stmt->execute([$currentTime]);
    $expiredTasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $successCount = 0;
    $failCount = 0;
    $notifications = []; // 收集通知，批量发送
    
    foreach ($expiredTasks as $task) {
        try {
            $db->beginTransaction();
            
            $taskId = $task['id'];
            $bUserId = $task['b_user_id'];
            $templateTitle = $task['template_title'];
            $taskCount = $task['task_count'];
            $taskDone = $task['task_done'];
            $taskDoing = $task['task_doing'];
            $taskReviewing = $task['task_reviewing'];
            $deadlineText = date('Y-m-d H:i:s', $task['deadline']);
            
            // 1. 更新任务状态为已过期 (status=0)
            $updateStmt = $db->prepare("
                UPDATE b_tasks 
                SET status = 0, updated_at = NOW()
                WHERE id = ? AND status = 1
            ");
            $updateStmt->execute([$taskId]);
            
            // 2. 检查是否有正在进行或待审核的C端记录
            $hasActiveRecords = ($taskDoing > 0 || $taskReviewing > 0);
            
            if ($hasActiveRecords) {
                // 如果有进行中或待审核的记录，记录日志但不取消这些记录
                // C端用户可以继续完成并提交，B端需要审核
                log_message("任务 #{$taskId} 已过期并下架，但仍有 {$taskDoing} 个进行中、{$taskReviewing} 个待审核的记录");
            }
            
            // 3. 计算未完成任务数量和退款金额
            $unfinishedCount = $taskCount - $taskDone;
            log_message("任务 #{$taskId} 未完成数量：{$unfinishedCount}");
            if ($unfinishedCount > 0) {
                // 查询任务的单位价格
                $priceStmt = $db->prepare("SELECT unit_price FROM b_tasks WHERE id = ?");
                $priceStmt->execute([$taskId]);
                $priceInfo = $priceStmt->fetch(PDO::FETCH_ASSOC);
                
                if ($priceInfo && isset($priceInfo['unit_price'])) {
                    $unitPrice = (float)$priceInfo['unit_price'];
                    log_message("任务 #{$taskId} 单价：¥" . number_format($unitPrice, 2));
                    $refundAmount = $unfinishedCount * $unitPrice;
                    $refundAmountInCents = (int)round($refundAmount * 100);
                    log_message("任务 #{$taskId} 退款金额：¥" . number_format($refundAmount, 2) . " (" . $refundAmountInCents . "分)");
                    
                    // 查询B端用户的钱包ID
                    $walletStmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
                    $walletStmt->execute([$bUserId]);
                    $bUserInfo = $walletStmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($bUserInfo && isset($bUserInfo['wallet_id'])) {
                        $walletId = $bUserInfo['wallet_id'];
                        $username = $bUserInfo['username'];
                        log_message("用户 #{$bUserId} ({$username}) 钱包ID：{$walletId}");
                        
                        // 查询当前钱包余额
                        $balanceStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                        $balanceStmt->execute([$walletId]);
                        $balanceInfo = $balanceStmt->fetch(PDO::FETCH_ASSOC);
                        
                        if ($balanceInfo) {
                            $beforeBalance = (int)$balanceInfo['balance'];
                            $afterBalance = $beforeBalance + $refundAmountInCents;
                            log_message("钱包余额：¥" . number_format($beforeBalance / 100, 2) . " -> ¥" . number_format($afterBalance / 100, 2));
                            
                            // 更新钱包余额
                            $updateBalanceStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                            $updateBalanceStmt->execute([$afterBalance, $walletId]);
                            log_message("钱包余额更新成功");
                            
                            // 记录钱包流水
                            $remark = "任务过期退款【{$templateTitle}】，未完成 {$unfinishedCount} 个任务，退款 ¥" . number_format($refundAmount, 2);
                            $flowStmt = $db->prepare(" 
                                INSERT INTO wallets_log (
                                    wallet_id, user_id, username, user_type, type, 
                                    amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, remark
                                ) VALUES (?, ?, ?, 2, 1, ?, ?, ?, 'refund', ?, 0, '', ?)
                            ");
                            $flowStmt->execute([
                                $walletId,
                                $bUserId,
                                $username,
                                $refundAmountInCents,
                                $beforeBalance,
                                $afterBalance,
                                $taskId,
                                $remark
                            ]);
                            log_message("钱包流水记录成功");
                            
                            // 插入任务统计记录
                            try {
                                $statStmt = $db->prepare(" 
                                    INSERT INTO b_task_statistics (
                                        b_user_id, username, flow_type, amount, before_balance, after_balance, 
                                        related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                                    ) VALUES (?, ?, 1, ?, ?, ?, 'refund', ?, 0, '', 9, '任务过期退款记录，已完成', ?)
                                ");
                                $statStmt->execute([
                                    $bUserId,
                                    $username,
                                    $refundAmountInCents,
                                    $beforeBalance,
                                    $afterBalance,
                                    $taskId,
                                    $remark
                                ]);
                                log_message("任务统计记录成功");
                            } catch (Exception $e) {
                                // 记录插入失败时的错误日志，但不影响主流程
                                error_log('插入b_task_statistics失败: ' . $e->getMessage());
                                log_message("任务统计记录失败: " . $e->getMessage());
                            }
                            
                            log_message("退款成功：任务 #{$taskId}，退款金额 ¥" . number_format($refundAmount, 2));
                        } else {
                            log_message("未找到钱包信息");
                        }
                    } else {
                        log_message("未找到用户信息");
                    }
                } else {
                    log_message("未找到任务单价信息");
                }
            }
            
            // 4. 准备通知B端用户
            $completionRate = $taskCount > 0 ? round(($taskDone / $taskCount) * 100, 2) : 0;
            $notificationContent = "您发布的任务「{$templateTitle}」已到期自动下架。\n";
            $notificationContent .= "任务进度：{$taskDone}/{$taskCount}（{$completionRate}%）\n";
            $notificationContent .= "截止时间：{$deadlineText}\n";
            
            // 如果有未完成任务且已退款，添加退款信息
            if ($unfinishedCount > 0) {
                $priceStmt = $db->prepare("SELECT unit_price FROM b_tasks WHERE id = ?");
                $priceStmt->execute([$taskId]);
                $priceInfo = $priceStmt->fetch(PDO::FETCH_ASSOC);
                
                if ($priceInfo && isset($priceInfo['unit_price'])) {
                    $unitPrice = (float)$priceInfo['unit_price'];
                    $refundAmount = $unfinishedCount * $unitPrice;
                    $notificationContent .= "\n退款信息：\n";
                    $notificationContent .= "未完成任务数量：{$unfinishedCount}个\n";
                    $notificationContent .= "退款金额：¥" . number_format($refundAmount, 2) . "\n";
                    $notificationContent .= "退款时间：" . date('Y-m-d H:i:s') . "\n";
                    $notificationContent .= "\n提示：退款已自动原路退回您的账户余额。";
                }
            }
            
            if ($hasActiveRecords) {
                $notificationContent .= "\n\n提示：仍有 {$taskDoing} 个进行中、{$taskReviewing} 个待审核的记录，请及时处理。";
            }
            
            $notifications[] = [
                'user_id' => $bUserId,
                'user_type' => 2, // B端
                'title' => '任务已到期下架',
                'content' => $notificationContent,
                'related_type' => 'task',
                'related_id' => $taskId
            ];
            
            $db->commit();
            $successCount++;
            
            log_message("成功：任务 #{$taskId} ({$templateTitle}) 已过期下架，完成率 {$completionRate}%");
            
        } catch (Exception $e) {
            $db->rollBack();
            $failCount++;
            log_message("失败：任务 #{$taskId} 处理失败 - " . $e->getMessage());
        }
    }
    
    log_message("过期任务检测完成: 共 " . count($expiredTasks) . " 个，成功 {$successCount} 个，失败 {$failCount} 个");

    // ============================================
    // 2. 检测C端超时未提交的任务，自动释放
    // ============================================
    log_message('正在检测C端超时未提交的任务...');

    // 获取超时配置（单位：秒，默认 600 秒=10 分钟）
    $taskSubmitTimeout = AppConfig::get('task_submit_timeout', 600);
    $timeoutThreshold = date('Y-m-d H:i:s', $currentTime - $taskSubmitTimeout);

    // 查询所有超时的进行中任务记录（status=1 表示进行中）
    $stmt = $db->prepare("
        SELECT
            ctr.id as record_id,
            ctr.c_user_id,
            ctr.b_task_id,
            ctr.created_at as accepted_at,
            cu.username as c_username,
            bt.template_id,
            tt.title as template_title
        FROM c_task_records ctr
        INNER JOIN c_users cu ON ctr.c_user_id = cu.id
        INNER JOIN b_tasks bt ON ctr.b_task_id = bt.id
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        WHERE ctr.status = 1
        AND ctr.created_at < ?
    ");
    $stmt->execute([$timeoutThreshold]);
    $timeoutRecords = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $releaseSuccessCount = 0;
    $releaseFailCount = 0;

    foreach ($timeoutRecords as $record) {
        try {
            $db->beginTransaction();

            $recordId = $record['record_id'];
            $bTaskId = $record['b_task_id'];
            $cUserId = $record['c_user_id'];
            $templateTitle = $record['template_title'];
            $acceptedAt = $record['accepted_at'];

            // 1. 更新超时任务记录状态为5（已超时）
            $updateStmt = $db->prepare("UPDATE c_task_records SET status = 5, update_at = NOW() WHERE id = ? AND status = 1");
            $updateStmt->execute([$recordId]);

            if ($updateStmt->rowCount() > 0) {
                // 2. 更新 B 端任务统计：task_doing - 1（使用 CASE 避免 UNSIGNED 溢出）
                $updateStmt = $db->prepare("
                    UPDATE b_tasks
                    SET task_doing = CASE 
                        WHEN task_doing > 0 THEN task_doing - 1 
                        ELSE 0 
                    END
                    WHERE id = ?
                ");
                $updateStmt->execute([$bTaskId]);
                
                // 3. 更新C端用户每日统计：abandon_count + 1
                $today = date('Y-m-d');
                $stmt = $db->prepare("SELECT id FROM c_user_daily_stats WHERE c_user_id = ? AND stat_date = ?");
                $stmt->execute([$cUserId, $today]);
                $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$dailyStats) {
                    // 创建当日统计记录
                    $stmt = $db->prepare("INSERT INTO c_user_daily_stats (c_user_id, stat_date, abandon_count) VALUES (?, ?, 1)");
                    $stmt->execute([$cUserId, $today]);
                } else {
                    // 更新当日统计记录
                    $stmt = $db->prepare("UPDATE c_user_daily_stats SET abandon_count = abandon_count + 1 WHERE id = ?");
                    $stmt->execute([$dailyStats['id']]);
                }
                
                // 4. 更新 c_user_task_records_static 表中的已弃单任务数量
                $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, abandoned_task_count) VALUES (?, 1) ON DUPLICATE KEY UPDATE abandoned_task_count = abandoned_task_count + 1");
                $stmt->execute([$cUserId]);

                $db->commit();
                $releaseSuccessCount++;

                // 3. 添加通知给C端用户
                $notifications[] = [
                    'user_id' => $cUserId,
                    'user_type' => 1, // C端
                    'title' => '任务已超时',
                    'content' => "您接取的任务「{$templateTitle}」已超时未提交，任务已自动取消。\n\n接单时间：{$acceptedAt}\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。",
                    'related_type' => 'task',
                    'related_id' => $bTaskId
                ];

                log_message("释放：记录 #{$recordId}，任务「{$templateTitle}」，用户 #{$cUserId}，接单时间 {$acceptedAt}");
            } else {
                $db->rollBack();
            }

        } catch (Exception $e) {
            $db->rollBack();
            $releaseFailCount++;
            log_message("释放失败：记录 #{$recordId} - " . $e->getMessage());
        }
    }

    $timeoutMinutes = round($taskSubmitTimeout / 60);
    log_message("超时任务释放完成: 超时阈值 {$timeoutMinutes} 分钟，共 " . count($timeoutRecords) . " 个，成功 {$releaseSuccessCount} 个，失败 {$releaseFailCount} 个");

    // ============================================
    // 3. 批量发送通知（在所有事务完成后）
    // ============================================
    if (!empty($notifications)) {
        log_message("正在发送 " . count($notifications) . " 条通知...");
        foreach ($notifications as $notif) {
            try {
                Notification::sendToUser(
                    $db,
                    $notif['user_id'],
                    $notif['user_type'],
                    $notif['title'],
                    $notif['content'],
                    $notif['related_type'],
                    $notif['related_id']
                );
            } catch (Exception $e) {
                log_message("发送通知失败: " . $e->getMessage());
            }
        }
        log_message("通知发送完成");
    }
    
    log_message('=== 任务系统定时检测结束 ===');
    log_message('');
    
} catch (Exception $e) {
    log_message('严重错误: ' . $e->getMessage());
    log_message('堆栈跟踪: ' . $e->getTraceAsString());
    exit(1);
}

// 成功退出
exit(0);
