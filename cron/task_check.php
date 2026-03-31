<?php
/**
 * 任务系统定时检测脚本
 *
 * 功能：
 * 1. 检测过期的 B 端任务，自动下架
 * 2. 检测 C 端超时未提交的任务，自动释放回任务池
 *
 * 执行频率：建议每分钟执行一次
 *
 * Crontab 示例：
 * * * * * /usr/bin/php /path/to/cron/task_check.php >> /path/to/logs/task_check.log 2>&1
 */

// 设置时区
date_default_timezone_set('Asia/Shanghai');

// 引入必要的文件
require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/Notification.php';
require_once __DIR__ . '/../core/AppConfig.php';

// 引入统一日志系统
require_once __DIR__ . '/../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前脚本上下文
LoggerRouter::setContext('cron/task_check');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 日志函数（保留终端输出）
function log_message($message) {
    echo '[' . date('Y-m-d H:i:s') . '] ' . $message . PHP_EOL;
}

try {
    // 记录脚本开始信息
    $startTime = microtime(true);
    $startMemory = memory_get_usage();
    
    log_message('=== 任务系统定时检测开始 ===');
    $requestLogger->info('=== 任务系统定时检测开始 ===', [
        'script' => 'task_check.php',
        'start_time' => date('Y-m-d H:i:s'),
        'timestamp' => time(),
        'memory_start' => round($startMemory / 1024 / 1024, 2) . 'MB'
    ]);
    
    $db = Database::connect();
    $currentTime = time();
    
    $requestLogger->debug('数据库连接成功', ['current_time' => date('Y-m-d H:i:s', $currentTime)]);
    
    // ============================================
    // 1. 检测过期的 B 端任务
    // ============================================
    log_message('正在检测过期的 B 端任务...');
    $requestLogger->info('开始检测过期 B 端任务');
    
    // 1.1 查询所有进行中且已过期的任务
    $requestLogger->debug('执行过期任务查询 SQL');
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
            bt.unit_price,
            tt.title as template_title,
            bu.username as b_username,
            bu.wallet_id
        FROM b_tasks bt
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        INNER JOIN b_users bu ON bt.b_user_id = bu.id
        WHERE bt.status = 1 
        AND bt.deadline < ?
    ");
    $stmt->execute([$currentTime]);
    $expiredTasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $requestLogger->info('过期任务查询完成', [
        'expired_count' => count($expiredTasks),
        'current_time' => date('Y-m-d H:i:s', $currentTime)
    ]);
    log_message("发现过期任务：" . count($expiredTasks) . " 个");
    
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
            $deadlineTimestamp = $task['deadline'];
            $deadlineText = date('Y-m-d H:i:s', $deadlineTimestamp);
            $unitPrice = (float)$task['unit_price'];
            $walletId = $task['wallet_id'] ?? null;
            $bUsername = $task['b_username'];
            
            $requestLogger->debug('开始处理过期任务', [
                'task_id' => $taskId,
                'template_title' => $templateTitle,
                'b_user_id' => $bUserId,
                'b_username' => $bUsername,
                'task_count' => $taskCount,
                'task_done' => $taskDone,
                'task_doing' => $taskDoing,
                'task_reviewing' => $taskReviewing,
                'deadline' => $deadlineText,
                'unit_price' => $unitPrice
            ]);
            
            // 1. 更新任务状态为已过期 (status=0)
            $requestLogger->debug('更新任务状态为已过期', ['task_id' => $taskId]);
            $updateStmt = $db->prepare("
                UPDATE b_tasks 
                SET status = 0, updated_at = NOW()
                WHERE id = ? AND status = 1
            ");
            $updateStmt->execute([$taskId]);
            $affectedRows = $updateStmt->rowCount();
            $requestLogger->debug('任务状态更新完成', [
                'task_id' => $taskId,
                'affected_rows' => $affectedRows
            ]);
            
            // 2. 检查是否有正在进行或待审核的 C 端记录
            $hasActiveRecords = ($taskDoing > 0 || $taskReviewing > 0);
            
            if ($hasActiveRecords) {
                $requestLogger->warning('过期任务仍有活跃记录', [
                    'task_id' => $taskId,
                    'task_doing' => $taskDoing,
                    'task_reviewing' => $taskReviewing
                ]);
                log_message("任务 #{$taskId} 已过期并下架，但仍有 {$taskDoing} 个进行中、{$taskReviewing} 个待审核的记录");
            }
            
            // 3. 计算未完成任务数量和退款金额
            $unfinishedCount = $taskCount - $taskDone;
            $requestLogger->debug('计算退款金额', [
                'task_id' => $taskId,
                'unfinished_count' => $unfinishedCount,
                'unit_price' => $unitPrice
            ]);
            
            if ($unfinishedCount > 0) {
                $refundAmount = $unfinishedCount * $unitPrice;
                $refundAmountInCents = (int)round($refundAmount * 100);
                
                $requestLogger->info('任务退款计算', [
                    'task_id' => $taskId,
                    'unfinished_count' => $unfinishedCount,
                    'unit_price_yuan' => number_format($unitPrice, 2),
                    'refund_amount_yuan' => number_format($refundAmount, 2),
                    'refund_amount_cents' => $refundAmountInCents
                ]);
                
                log_message("任务 #{$taskId} 未完成数量：{$unfinishedCount}");
                log_message("任务 #{$taskId} 单价：¥" . number_format($unitPrice, 2));
                log_message("任务 #{$taskId} 退款金额：¥" . number_format($refundAmount, 2) . " (" . $refundAmountInCents . "分)");
                
                if ($walletId) {
                    $requestLogger->debug('查询 B 端用户钱包信息', [
                        'b_user_id' => $bUserId,
                        'wallet_id' => $walletId
                    ]);
                    
                    // 查询当前钱包余额
                    $balanceStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $balanceStmt->execute([$walletId]);
                    $balanceInfo = $balanceStmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($balanceInfo) {
                        $beforeBalance = (int)$balanceInfo['balance'];
                        $afterBalance = $beforeBalance + $refundAmountInCents;
                        
                        $requestLogger->debug('钱包余额变动', [
                            'wallet_id' => $walletId,
                            'before_balance' => $beforeBalance,
                            'after_balance' => $afterBalance,
                            'change_amount' => $refundAmountInCents
                        ]);
                        
                        log_message("用户 #{$bUserId} ({$bUsername}) 钱包 ID：{$walletId}");
                        log_message("钱包余额：¥" . number_format($beforeBalance / 100, 2) . " -> ¥" . number_format($afterBalance / 100, 2));
                        
                        // 更新钱包余额
                        $updateBalanceStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $updateBalanceStmt->execute([$afterBalance, $walletId]);
                        $requestLogger->info('钱包余额更新成功', ['wallet_id' => $walletId]);
                        log_message("钱包余额更新成功");
                        
                        // 记录钱包流水
                        $remark = "任务过期退款【{$templateTitle}】，未完成 {$unfinishedCount} 个任务，退款 ¥" . number_format($refundAmount, 2);
                        $requestLogger->debug('插入钱包流水记录', [
                            'wallet_id' => $walletId,
                            'b_user_id' => $bUserId,
                            'amount' => $refundAmountInCents,
                            'remark' => $remark
                        ]);
                        
                        $flowStmt = $db->prepare(" 
                            INSERT INTO wallets_log (
                                wallet_id, user_id, username, user_type, type, 
                                amount, before_balance, after_balance, 
                                related_type, related_id, task_types, task_types_text, remark
                            ) VALUES (?, ?, ?, 2, 1, ?, ?, ?, '任务过期退款', ?, 0, '', ?)
                        ");
                        $flowStmt->execute([
                            $walletId,
                            $bUserId,
                            $bUsername,
                            $refundAmountInCents,
                            $beforeBalance,
                            $afterBalance,
                            $taskId,
                            $remark
                        ]);
                        $requestLogger->info('钱包流水记录成功', [
                            'wallet_id' => $walletId,
                            'flow_id' => $db->lastInsertId()
                        ]);
                        log_message("钱包流水记录成功");
                        
                        // 插入任务统计记录
                        try {
                            $requestLogger->debug('插入 B 端任务统计记录', [
                                'b_user_id' => $bUserId,
                                'task_id' => $taskId,
                                'amount' => $refundAmountInCents
                            ]);
                            
                            $statStmt = $db->prepare(" 
                                INSERT INTO b_task_statistics (
                                    b_user_id, username, flow_type, amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                                ) VALUES (?, ?, 1, ?, ?, ?, 'refund', ?, 0, '', 9, '任务过期退款记录，已完成', ?)
                            ");
                            $statStmt->execute([
                                $bUserId,
                                $bUsername,
                                $refundAmountInCents,
                                $beforeBalance,
                                $afterBalance,
                                $taskId,
                                $remark
                            ]);
                            $requestLogger->info('任务统计记录成功', ['b_user_id' => $bUserId]);
                            log_message("任务统计记录成功");
                        } catch (Exception $e) {
                            $errorLogger->error('插入 b_task_statistics 失败', [
                                'b_user_id' => $bUserId,
                                'task_id' => $taskId,
                                'exception' => $e->getMessage(),
                                'trace' => $e->getTraceAsString()
                            ]);
                            log_message("任务统计记录失败：" . $e->getMessage());
                        }
                        
                        $requestLogger->info('退款处理完成', [
                            'task_id' => $taskId,
                            'b_user_id' => $bUserId,
                            'refund_amount' => $refundAmountInCents
                        ]);
                        log_message("退款成功：任务 #{$taskId}，退款金额 ¥" . number_format($refundAmount, 2));
                    } else {
                        $errorLogger->error('未找到钱包余额信息', ['wallet_id' => $walletId]);
                        log_message("未找到钱包信息");
                    }
                } else {
                    $errorLogger->error('未找到钱包 ID', ['b_user_id' => $bUserId]);
                    log_message("未找到钱包 ID");
                }
            }
            
            // 4. 准备通知 B 端用户
            $completionRate = $taskCount > 0 ? round(($taskDone / $taskCount) * 100, 2) : 0;
            $notificationContent = "您发布的任务「{$templateTitle}」已到期自动下架。\n";
            $notificationContent .= "任务进度：{$taskDone}/{$taskCount}（{$completionRate}%）\n";
            $notificationContent .= "截止时间：{$deadlineText}\n";
            
            // 如果有未完成任务且已退款，添加退款信息
            if ($unfinishedCount > 0 && isset($unitPrice)) {
                $refundAmount = $unfinishedCount * $unitPrice;
                $notificationContent .= "\n退款信息：\n";
                $notificationContent .= "未完成任务数量：{$unfinishedCount}个\n";
                $notificationContent .= "退款金额：¥" . number_format($refundAmount, 2) . "\n";
                $notificationContent .= "退款时间：" . date('Y-m-d H:i:s') . "\n";
                $notificationContent .= "\n提示：退款已自动原路退回您的账户余额。";
            }
            
            if ($hasActiveRecords) {
                $notificationContent .= "\n\n提示：仍有 {$taskDoing} 个进行中、{$taskReviewing} 个待审核的记录，请及时处理。";
            }
            
            $notifications[] = [
                'user_id' => $bUserId,
                'user_type' => 2, // B 端
                'title' => '任务已到期下架',
                'content' => $notificationContent,
                'related_type' => 'task',
                'related_id' => $taskId
            ];
            
            $db->commit();
            $successCount++;
            
            $requestLogger->info('过期任务处理成功', [
                'task_id' => $taskId,
                'template_title' => $templateTitle,
                'completion_rate' => $completionRate . '%',
                'has_refund' => $unfinishedCount > 0,
                'has_active_records' => $hasActiveRecords
            ]);
            log_message("成功：任务 #{$taskId} ({$templateTitle}) 已过期下架，完成率 {$completionRate}%");
            
        } catch (Exception $e) {
            $db->rollBack();
            $failCount++;
            $errorLogger->error('过期任务处理失败', [
                'task_id' => $task['id'] ?? 'unknown',
                'exception' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            log_message("失败：任务 #{$taskId} 处理失败 - " . $e->getMessage());
        }
    }
    
    $requestLogger->info('过期任务检测阶段完成', [
        'total' => count($expiredTasks),
        'success' => $successCount,
        'fail' => $failCount
    ]);
    log_message("过期任务检测完成：共 " . count($expiredTasks) . " 个，成功 {$successCount} 个，失败 {$failCount} 个");

    // ============================================
    // 2. 检测 C 端超时未提交的任务，自动释放
    // ============================================
    log_message('正在检测 C 端超时未提交的任务...');
    $requestLogger->info('开始检测 C 端超时任务');

    // 获取超时配置（单位：秒，默认 600 秒=10 分钟）
    $taskSubmitTimeout = AppConfig::get('task_submit_timeout', 600);
    $timeoutThreshold = date('Y-m-d H:i:s', $currentTime - $taskSubmitTimeout);
    
    $requestLogger->debug('超时配置', [
        'timeout_seconds' => $taskSubmitTimeout,
        'timeout_minutes' => round($taskSubmitTimeout / 60),
        'threshold_time' => $timeoutThreshold
    ]);

    // 2.1 查询超时的任务记录
    $requestLogger->debug('执行超时任务查询 SQL');
    $stmt = $db->prepare("
        SELECT
            ctr.id as record_id,
            ctr.c_user_id,
            ctr.b_task_id,
            ctr.created_at as accepted_at,
            cu.username as c_username,
            bt.template_id,
            bt.unit_price,
            tt.title as template_title
        FROM c_task_records ctr
        INNER JOIN c_users cu ON ctr.c_user_id = cu.id
        INNER JOIN b_tasks bt ON ctr.b_task_id = bt.id
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        WHERE ctr.status = 1
        AND ctr.b_task_id > 0
        AND ctr.created_at < ?
    ");
    $stmt->execute([$timeoutThreshold]);
    $timeoutRecords = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $requestLogger->info('超时任务查询完成', [
        'timeout_count' => count($timeoutRecords),
        'threshold_time' => $timeoutThreshold
    ]);
    log_message("发现超时记录：" . count($timeoutRecords) . " 个");

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
            $cUsername = $record['c_username'];
            $unitPrice = (float)$record['unit_price'];
            
            $requestLogger->debug('开始处理超时任务记录', [
                'record_id' => $recordId,
                'b_task_id' => $bTaskId,
                'c_user_id' => $cUserId,
                'c_username' => $cUsername,
                'template_title' => $templateTitle,
                'accepted_at' => $acceptedAt
            ]);

            // 1. 更新超时任务记录状态为 5（已超时）
            $requestLogger->debug('更新任务记录状态为已超时', ['record_id' => $recordId]);
            $updateStmt = $db->prepare("UPDATE c_task_records SET status = 5, update_at = NOW() WHERE id = ? AND status = 1");
            $updateStmt->execute([$recordId]);
            $affectedRows = $updateStmt->rowCount();
            $requestLogger->debug('任务记录状态更新完成', [
                'record_id' => $recordId,
                'affected_rows' => $affectedRows
            ]);

            if ($affectedRows > 0) {
                // 2. 更新 b_tasks 表统计
                $requestLogger->debug('更新 b_tasks 表 task_doing 字段', ['b_task_id' => $bTaskId]);
                $updateStmt = $db->prepare("
                    UPDATE b_tasks
                    SET task_doing = CASE 
                        WHEN task_doing > 0 THEN task_doing - 1 
                        ELSE 0 
                    END
                    WHERE id = ?
                ");
                $updateStmt->execute([$bTaskId]);
                $requestLogger->info('b_tasks 表统计更新成功', ['b_task_id' => $bTaskId]);
                log_message("更新任务 task_doing: b_task_id={$bTaskId}");
                
                // 3. 更新 C 端用户每日统计：abandon_count + 1
                $today = date('Y-m-d');
                $requestLogger->debug('查询 C 端用户当日统计', [
                    'c_user_id' => $cUserId,
                    'stat_date' => $today
                ]);
                
                $stmt = $db->prepare("SELECT id FROM c_user_daily_stats WHERE c_user_id = ? AND stat_date = ?");
                $stmt->execute([$cUserId, $today]);
                $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$dailyStats) {
                    // 创建当日统计记录
                    $requestLogger->debug('创建当日统计记录', ['c_user_id' => $cUserId]);
                    $stmt = $db->prepare("INSERT INTO c_user_daily_stats (c_user_id, stat_date, abandon_count) VALUES (?, ?, 1)");
                    $stmt->execute([$cUserId, $today]);
                    $requestLogger->info('当日统计记录创建成功', [
                        'c_user_id' => $cUserId,
                        'daily_stats_id' => $db->lastInsertId()
                    ]);
                } else {
                    // 更新当日统计记录
                    $requestLogger->debug('更新当日统计记录', [
                        'c_user_id' => $cUserId,
                        'daily_stats_id' => $dailyStats['id']
                    ]);
                    $stmt = $db->prepare("UPDATE c_user_daily_stats SET abandon_count = abandon_count + 1 WHERE id = ?");
                    $stmt->execute([$dailyStats['id']]);
                    $requestLogger->info('当日统计记录更新成功', ['daily_stats_id' => $dailyStats['id']]);
                }
                
                // 4. 更新 c_user_task_records_static 表中的已弃单任务数量
                $requestLogger->debug('更新用户已弃单任务统计', ['c_user_id' => $cUserId]);
                $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, abandoned_task_count) VALUES (?, 1) ON DUPLICATE KEY UPDATE abandoned_task_count = abandoned_task_count + 1");
                $stmt->execute([$cUserId]);
                $requestLogger->info('用户已弃单任务统计更新成功', ['c_user_id' => $cUserId]);

                $db->commit();
                $releaseSuccessCount++;

                // 5. 添加通知给 C 端用户
                $notifications[] = [
                    'user_id' => $cUserId,
                    'user_type' => 1, // C 端
                    'title' => '任务已超时',
                    'content' => "您接取的任务「{$templateTitle}」已超时未提交，任务已自动取消。\n\n接单时间：{$acceptedAt}\n\n提示：接单后请在规定时间内完成并提交，超时的任务无法再次接取。",
                    'related_type' => 'task',
                    'related_id' => $bTaskId
                ];

                $requestLogger->info('超时任务释放成功', [
                    'record_id' => $recordId,
                    'b_task_id' => $bTaskId,
                    'c_user_id' => $cUserId,
                    'template_title' => $templateTitle
                ]);
                log_message("释放：记录 #{$recordId}，任务「{$templateTitle}」，用户 #{$cUserId}，接单时间 {$acceptedAt}");
            } else {
                $db->rollBack();
                $requestLogger->warning('超时任务记录更新失败，可能已被其他进程处理', [
                    'record_id' => $recordId
                ]);
            }

        } catch (Exception $e) {
            $db->rollBack();
            $releaseFailCount++;
            $errorLogger->error('超时任务释放失败', [
                'record_id' => $record['record_id'] ?? 'unknown',
                'exception' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            log_message("释放失败：记录 #{$recordId} - " . $e->getMessage());
        }
    }

    $timeoutMinutes = round($taskSubmitTimeout / 60);
    $requestLogger->info('超时任务释放阶段完成', [
        'timeout_minutes' => $timeoutMinutes,
        'total' => count($timeoutRecords),
        'success' => $releaseSuccessCount,
        'fail' => $releaseFailCount
    ]);
    log_message("超时任务释放完成：超时阈值 {$timeoutMinutes} 分钟，共 " . count($timeoutRecords) . " 个，成功 {$releaseSuccessCount} 个，失败 {$releaseFailCount} 个");

    // ============================================
    // 3. 批量发送通知（在所有事务完成后）
    // ============================================
    if (!empty($notifications)) {
        $requestLogger->info('开始发送通知', ['notification_count' => count($notifications)]);
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
                $requestLogger->debug('通知发送成功', [
                    'user_id' => $notif['user_id'],
                    'user_type' => $notif['user_type'],
                    'title' => $notif['title']
                ]);
            } catch (Exception $e) {
                $errorLogger->error('发送通知失败', [
                    'user_id' => $notif['user_id'],
                    'user_type' => $notif['user_type'],
                    'exception' => $e->getMessage()
                ]);
                log_message("发送通知失败：" . $e->getMessage());
            }
        }
        $requestLogger->info('通知发送完成', ['total_sent' => count($notifications)]);
        log_message("通知发送完成");
    }
    
    // 记录脚本执行统计
    $endTime = microtime(true);
    $endMemory = memory_get_usage();
    $executionTime = round($endTime - $startTime, 3);
    $memoryUsed = round(($endMemory - $startMemory) / 1024 / 1024, 2);
    
    $requestLogger->info('=== 任务系统定时检测结束 ===', [
        'end_time' => date('Y-m-d H:i:s'),
        'execution_time_seconds' => $executionTime,
        'memory_used_mb' => $memoryUsed,
        'expired_tasks' => [
            'total' => count($expiredTasks),
            'success' => $successCount,
            'fail' => $failCount
        ],
        'timeout_tasks' => [
            'total' => count($timeoutRecords),
            'success' => $releaseSuccessCount,
            'fail' => $releaseFailCount
        ],
        'notifications_sent' => count($notifications)
    ]);
    
    log_message('=== 任务系统定时检测结束 ===');
    log_message("执行时间：{$executionTime} 秒");
    log_message("内存使用：{$memoryUsed} MB");
    log_message('');
    
} catch (Exception $e) {
    $errorLogger->error('任务系统检测严重错误', [
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'trace' => $e->getTraceAsString()
    ]);
    log_message('严重错误：' . $e->getMessage());
    log_message('堆栈跟踪：' . $e->getTraceAsString());
    exit(1);
}

// 成功退出
exit(0);
