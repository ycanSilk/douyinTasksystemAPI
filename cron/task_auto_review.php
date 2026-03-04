<?php
/**
 * 自动审核任务脚本
 * 每1分钟执行一次，检查提交时间超过10分钟的待审核任务
 */

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 定义自动审核时间阈值（10分钟）
$autoReviewThreshold = 10 * 60; // 秒
$currentTime = time();
$thresholdTime = $currentTime - $autoReviewThreshold;

try {
    // 查询超过10分钟未审核的任务
    $stmt = $db->prepare("
        SELECT 
            c.id, c.c_user_id, c.b_user_id, c.b_task_id, 
            c.status, c.reward_amount, c.comment_url, c.submitted_at
        FROM c_task_records c
        WHERE c.status = 2 // 待审核状态
          AND UNIX_TIMESTAMP(c.submitted_at) < ?
    ");
    $stmt->execute([$thresholdTime]);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($records)) {
        echo "没有需要自动审核的任务\n";
        exit;
    }
    
    echo "找到 " . count($records) . " 个需要自动审核的任务\n";
    
    foreach ($records as $record) {
        echo "处理任务记录ID: " . $record['id'] . "，任务ID: " . $record['b_task_id'] . "\n";
        
        // 执行自动审核通过逻辑
        autoApproveTask($db, $record, $errorCodes);
    }
    
} catch (PDOException $e) {
    echo "自动审核失败: " . $e->getMessage() . "\n";
}

/**
 * 自动审核通过任务
 */
function autoApproveTask($db, $record, $errorCodes) {
    try {
        // 1. 查询C端用户信息
        $stmt = $db->prepare("
            SELECT id, username, wallet_id, parent_id, is_agent
            FROM c_users 
            WHERE id = ?
        ");
        $stmt->execute([$record['c_user_id']]);
        $cUser = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cUser) {
            echo "C端用户不存在，任务记录ID: " . $record['id'] . "\n";
            return;
        }
        
        // 2. 查询或创建当日统计记录
        $today = date('Y-m-d');
        $stmt = $db->prepare("
            SELECT id 
            FROM c_user_daily_stats 
            WHERE c_user_id = ? AND stat_date = ?
        ");
        $stmt->execute([$record['c_user_id'], $today]);
        $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$dailyStats) {
            $stmt = $db->prepare("
                INSERT INTO c_user_daily_stats (c_user_id, stat_date)
                VALUES (?, ?)
            ");
            $stmt->execute([$record['c_user_id'], $today]);
            $dailyStatsId = $db->lastInsertId();
        } else {
            $dailyStatsId = $dailyStats['id'];
        }
        
        // 3. 开启事务
        $db->beginTransaction();
        
        $reviewedAt = date('Y-m-d H:i:s');
        
        // 4. 更新任务记录状态
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 3, reviewed_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$reviewedAt, $record['id']]);
        
        // 5. 更新B端任务统计
        $stmt = $db->prepare("
            UPDATE b_tasks 
            SET task_reviewing = task_reviewing - 1,
                task_done = task_done + 1
            WHERE id = ?
        ");
        $stmt->execute([$record['b_task_id']]);
        
        // 6. 检查任务是否全部完成，如果完成则更新状态为"已完成"
        $stmt = $db->prepare("
            SELECT task_count, task_done
            FROM b_tasks 
            WHERE id = ?
        ");
        $stmt->execute([$record['b_task_id']]);
        $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
            // 任务全部完成，更新状态为已完成(status=2)
            $stmt = $db->prepare("
                UPDATE b_tasks 
                SET status = 2, stage_status = 2, completed_at = ?
                WHERE id = ?
            ");
            $stmt->execute([$reviewedAt, $record['b_task_id']]);
        }
        
        // 7. 检查组合任务是否需要开放第二阶段
        $stmt = $db->prepare("
            SELECT 
                id, combo_task_id, stage, task_count, task_done
            FROM b_tasks 
            WHERE id = ?
        ");
        $stmt->execute([$record['b_task_id']]);
        $bTask = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($bTask && !empty($bTask['combo_task_id']) && (int)$bTask['stage'] === 1) {
            // 这是组合任务的第一阶段
            // 检查第一阶段是否全部完成（组合任务阶段1固定为1个任务）
            if ((int)$bTask['task_done'] === (int)$bTask['task_count']) {
                // 第一阶段完成，获取C端用户提交的评论链接作为阶段2的video_url
                $commentUrl = $record['comment_url'] ?? '';
                
                if (!empty($commentUrl)) {
                    // 开放第二阶段，并设置video_url为阶段1的评论链接
                    $stmt = $db->prepare("
                        UPDATE b_tasks 
                        SET stage_status = 1, video_url = ?
                        WHERE combo_task_id = ? AND stage = 2
                    ");
                    $stmt->execute([$commentUrl, $bTask['combo_task_id']]);
                } else {
                    // 如果评论链接为空，只开放不设置video_url（保持为空）
                    $stmt = $db->prepare("
                        UPDATE b_tasks 
                        SET stage_status = 1 
                        WHERE combo_task_id = ? AND stage = 2
                    ");
                    $stmt->execute([$bTask['combo_task_id']]);
                }
            }
        }
        
        // 8. 更新当日统计
        $stmt = $db->prepare("
            UPDATE c_user_daily_stats 
            SET approved_count = approved_count + 1 
            WHERE id = ?
        ");
        $stmt->execute([$dailyStatsId]);
        
        // 9. 计算佣金（从模板读取固定金额）
        // 查询b_task获取template_id和stage
        $stmt = $db->prepare("SELECT template_id, stage FROM b_tasks WHERE id = ?");
        $stmt->execute([$record['b_task_id']]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$bTaskInfo) {
            $db->rollBack();
            echo "任务信息不存在，任务记录ID: " . $record['id'] . "\n";
            return;
        }

        // 查询模板佣金配置
        $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
        $stmt->execute([$bTaskInfo['template_id']]);
        $template = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$template) {
            $db->rollBack();
            echo "任务模板不存在，任务记录ID: " . $record['id'] . "\n";
            return;
        }

        // 根据stage选择对应的佣金字段
        $stage = (int)$bTaskInfo['stage'];
        if ($stage === 1) {
            $cUserCommission = (int)($template['stage1_c_user_commission'] ?? 0);
            $agentCommissionAmount = (int)($template['stage1_agent_commission'] ?? 0);
            $seniorAgentCommissionAmount = (int)($template['stage1_senior_agent_commission'] ?? 0);
            // 二级代理佣金复用一级代理佣金字段
            $secondAgentCommissionAmount = $agentCommissionAmount;
            $secondSeniorAgentCommissionAmount = $seniorAgentCommissionAmount;
        } elseif ($stage === 2) {
            $cUserCommission = (int)($template['stage2_c_user_commission'] ?? 0);
            $agentCommissionAmount = (int)($template['stage2_agent_commission'] ?? 0);
            $seniorAgentCommissionAmount = (int)($template['stage2_senior_agent_commission'] ?? 0);
            // 二级代理佣金复用一级代理佣金字段
            $secondAgentCommissionAmount = $agentCommissionAmount;
            $secondSeniorAgentCommissionAmount = $seniorAgentCommissionAmount;
        } else {
            // 单任务 stage=0
            $cUserCommission = (int)($template['c_user_commission'] ?? 0);
            $agentCommissionAmount = (int)($template['agent_commission'] ?? 0);
            $seniorAgentCommissionAmount = (int)($template['senior_agent_commission'] ?? 0);
            // 二级代理佣金复用一级代理佣金字段
            $secondAgentCommissionAmount = $agentCommissionAmount;
            $secondSeniorAgentCommissionAmount = $seniorAgentCommissionAmount;
        }
        
        // 10. 查询C端用户钱包
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$cUser['wallet_id']]);
        $cWallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cWallet) {
            $db->rollBack();
            echo "C端用户钱包不存在，任务记录ID: " . $record['id'] . "\n";
            return;
        }
        
        $cBeforeBalance = (int)$cWallet['balance'];
        $cAfterBalance = $cBeforeBalance + $cUserCommission;
        
        // 11. 更新C端用户钱包
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$cAfterBalance, $cUser['wallet_id']]);
        
        // 12. 记录C端用户钱包流水
        $cRemark = "自动审核通过任务获得佣金，任务ID：{$record['b_task_id']}";
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, remark
            ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'commission', ?, ?)
        ");
        $stmt->execute([
            $cUser['wallet_id'],
            $cUser['id'],
            $cUser['username'],
            $cUserCommission,
            $cBeforeBalance,
            $cAfterBalance,
            $record['b_task_id'],
            $cRemark
        ]);
        
        // 13. 检查是否有团长上级
        if (!empty($cUser['parent_id'])) {
            // 查询一级上级用户
            $stmt = $db->prepare("
                SELECT id, username, wallet_id, is_agent, parent_id
                FROM c_users
                WHERE id = ?
            ");
            $stmt->execute([$cUser['parent_id']]);
            $parentUser = $stmt->fetch(PDO::FETCH_ASSOC);

            $parentAgentLevel = $parentUser ? (int)$parentUser['is_agent'] : 0;

            if ($parentUser && $parentAgentLevel >= 1) {
                // 高级团长(2)用senior_agent佣金，普通团长(1)用agent佣金
                if ($parentAgentLevel === 2) {
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
                    
                    // 更新团长钱包
                    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                    $stmt->execute([$agentAfterBalance, $parentUser['wallet_id']]);
                    
                    // 记录团长钱包流水
                    $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得一级团长佣金，任务ID：{$record['b_task_id']}";
                    $stmt = $db->prepare("
                        INSERT INTO wallets_log (
                            wallet_id, user_id, username, user_type, type, 
                            amount, before_balance, after_balance, 
                            related_type, related_id, remark
                        ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'agent_commission', ?, ?)
                    ");
                    $stmt->execute([
                        $parentUser['wallet_id'],
                        $parentUser['id'],
                        $parentUser['username'],
                        $agentCommission,
                        $agentBeforeBalance,
                        $agentAfterBalance,
                        $record['b_task_id'],
                        $agentRemark
                    ]);
                }
                
                // 查询二级上级用户
                if (!empty($parentUser['parent_id'])) {
                    $stmt = $db->prepare("
                        SELECT id, username, wallet_id, is_agent
                        FROM c_users
                        WHERE id = ?
                    ");
                    $stmt->execute([$parentUser['parent_id']]);
                    $secondParentUser = $stmt->fetch(PDO::FETCH_ASSOC);

                    $secondParentAgentLevel = $secondParentUser ? (int)$secondParentUser['is_agent'] : 0;

                    if ($secondParentUser && $secondParentAgentLevel >= 1) {
                        // 高级团长(2)用second_senior_agent佣金，普通团长(1)用second_agent佣金
                        if ($secondParentAgentLevel === 2) {
                            $secondAgentCommission = $secondSeniorAgentCommissionAmount;
                        } else {
                            $secondAgentCommission = $secondAgentCommissionAmount;
                        }
                        
                        // 查询二级团长钱包
                        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                        $stmt->execute([$secondParentUser['wallet_id']]);
                        $secondAgentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                        
                        if ($secondAgentWallet) {
                            $secondAgentBeforeBalance = (int)$secondAgentWallet['balance'];
                            $secondAgentAfterBalance = $secondAgentBeforeBalance + $secondAgentCommission;
                            
                            // 更新二级团长钱包
                            $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                            $stmt->execute([$secondAgentAfterBalance, $secondParentUser['wallet_id']]);
                            
                            // 记录二级团长钱包流水
                            $secondAgentRemark = "下级用户 {$parentUser['username']} 的团队成员完成任务，获得二级团长佣金，任务ID：{$record['b_task_id']}";
                            $stmt = $db->prepare("
                                INSERT INTO wallets_log (
                                    wallet_id, user_id, username, user_type, type, 
                                    amount, before_balance, after_balance, 
                                    related_type, related_id, remark
                                ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'second_agent_commission', ?, ?)
                            ");
                            $stmt->execute([
                                $secondParentUser['wallet_id'],
                                $secondParentUser['id'],
                                $secondParentUser['username'],
                                $secondAgentCommission,
                                $secondAgentBeforeBalance,
                                $secondAgentAfterBalance,
                                $record['b_task_id'],
                                $secondAgentRemark
                            ]);
                        }
                    }
                }
            }
        }
        
        // 14. 提交事务
        $db->commit();
        
        echo "自动审核通过任务记录ID: " . $record['id'] . "\n";
        
    } catch (PDOException $e) {
        // 回滚事务
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        
        echo "自动审核失败，任务记录ID: " . $record['id'] . "，错误: " . $e->getMessage() . "\n";
    }
}
?>