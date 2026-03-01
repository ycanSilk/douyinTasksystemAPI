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
            
            // 3. 准备通知B端用户
            $completionRate = $taskCount > 0 ? round(($taskDone / $taskCount) * 100, 2) : 0;
            $notificationContent = "您发布的任务「{$templateTitle}」已到期自动下架。\n";
            $notificationContent .= "任务进度：{$taskDone}/{$taskCount}（{$completionRate}%）\n";
            $notificationContent .= "截止时间：{$deadlineText}\n";
            
            if ($hasActiveRecords) {
                $notificationContent .= "\n提示：仍有 {$taskDoing} 个进行中、{$taskReviewing} 个待审核的记录，请及时处理。";
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

    // 获取超时配置（默认600秒=10分钟）
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
            $updateStmt = $db->prepare("UPDATE c_task_records SET status = 5 WHERE id = ? AND status = 1");
            $updateStmt->execute([$recordId]);

            if ($updateStmt->rowCount() > 0) {
                // 2. 更新B端任务统计：task_doing - 1
                $updateStmt = $db->prepare("
                    UPDATE b_tasks
                    SET task_doing = GREATEST(task_doing - 1, 0)
                    WHERE id = ?
                ");
                $updateStmt->execute([$bTaskId]);

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
