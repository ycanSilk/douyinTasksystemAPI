<?php

/**
 * 自动审核任务脚本
 * 每1分钟执行一次，检查提交时间超过10分钟的待审核任务
 */

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/Response.php';
require_once __DIR__ . '/../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../config/error_codes.php';

// 检查用户的上级代理中是否有大团团长
function hasLargeGroupAgent($db, $userId, $maxLevel = 2)
{
    $currentUserId = $userId;
    $level = 0;

    while ($level < $maxLevel) {
        $stmt = $db->prepare("SELECT parent_id, is_agent FROM c_users WHERE id = ?");
        $stmt->execute([$currentUserId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user || !$user['parent_id']) {
            break;
        }

        if ($user['is_agent'] == 3) {
            return true;
        }

        $currentUserId = $user['parent_id'];
        $level++;
    }

    return false;
}

// 数据库连接
$db = Database::connect();
if ($db) {
    echo "数据库连接成功\n";
} else {
    echo "数据库连接失败\n";
    exit;
}
// 定义自动审核时间阈值（1分钟，用于测试）
$autoReviewThreshold = 1 * 10; // 秒
$currentTime = time();
$thresholdTime = $currentTime - $autoReviewThreshold;

try {
    // 查询超过10分钟未审核的任务
    $stmt = $db->prepare("
        SELECT 
            c.id, c.c_user_id, c.b_user_id, c.b_task_id, 
            c.status, c.reward_amount, c.comment_url, c.submitted_at, c.task_stage, c.task_stage_text
        FROM c_task_records c
        WHERE c.status = 2 -- 待审核状态
          AND UNIX_TIMESTAMP(c.submitted_at) < ?
    ");
    
    echo "开始执行查询\n";
    $stmt->execute([$thresholdTime]);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 查询到的待审核任务数量

    if (empty($records)) {
        echo "没有超过10分钟需要自动审核的任务\n";
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
function autoApproveTask($db, $record, $errorCodes)
{
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
        // 查询b_task获取template_id、stage和unit_price
        $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
        $stmt->execute([$record['b_task_id']]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        // 获取派单单价
        $taskUnitPrice = (float)($bTaskInfo['unit_price'] ?? 0);

        

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

        // 初始化用户代理级别变量
        $userAgentLevel = (int)($cUser['is_agent'] ?? 0);

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
        // 根据任务模板ID确定任务类型
        $taskType = 0;
        $taskTypeText = '';
        if ($template) {
            $templateId = (int)($template['id'] ?? 0);
            switch ($templateId) {
                case 1:
                    $taskType = 1;
                    $taskTypeText = '上评评论';
                    break;
                case 2:
                    $taskType = 2;
                    $taskTypeText = '中评评论';
                    break;
                case 3:
                    $taskType = 3;
                    $taskTypeText = '放大镜搜索词';
                    break;
                case 4:
                    $taskType = 4;
                    $taskTypeText = '上中评评论';
                    break;
                case 5:
                    $taskType = 5;
                    $taskTypeText = '中下评评论';
                    break;
            }
        }
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, task_types, task_types_text, remark
            ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'commission', ?, ?, ?, ?)
        ");
        $stmt->execute([
            $cUser['wallet_id'],
            $cUser['id'],
            $cUser['username'],
            $cUserCommission,
            $cBeforeBalance,
            $cAfterBalance,
            $record['b_task_id'],
            $taskType,
            $taskTypeText,
            $cRemark
        ]);
        
        // 12.1 记录C端任务统计
        try {
            // 优化remark字段
            $userAgentType = '普通用户';
            if ($userAgentLevel === 1) {
                $userAgentType = '普通团长';
            } elseif ($userAgentLevel === 2) {
                $userAgentType = '高级团长';
            } elseif ($userAgentLevel === 3) {
                $userAgentType = '大团团长';
            }
            $cRemark = "用户 {$cUser['username']} 完成任务，{$userAgentType}获得佣金，任务ID：{$record['b_task_id']}，任务类型：{$taskTypeText}，任务阶段：{$record['task_stage_text']}，任务单价：{$taskUnitPrice}元，获得奖励：" . ($cUserCommission / 100) . "元";
            
            // 获取任务阶段文本
            $taskStageText = '';
            if ($template) {
                if ($stage === 0) {
                    $taskStageText = $template['title'] ?? '';
                } elseif ($stage === 1) {
                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage1_title'] ?? '');
                } elseif ($stage === 2) {
                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage2_title'] ?? '');
                }
            }
            
            $stmt = $db->prepare(" 
                INSERT INTO c_task_statistics (
                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                    related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                    record_status, record_status_text, remark
                ) VALUES (?, ?, 1, ?, ?, ?, 'commission', ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $cUser['id'],
                $cUser['username'],
                $cUserCommission,
                $cBeforeBalance,
                $cAfterBalance,
                $record['b_task_id'],
                $taskType,
                $taskTypeText,
                $stage,
                $taskStageText,
                3, // record_status: 审核通过=3
                '审核通过', // record_status_text
                $cRemark
            ]);
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            error_log('插入c_task_statistics失败: ' . $e->getMessage());
        }

        // 13. 检查是否有团长上级，向上查找直到找到大团团长或达到最大层级
        $agentCommission = 0;
        $agentUserId = null;
        $agentUsername = null;
        $secondAgentCommission = 0;
        $secondAgentUserId = null;
        $secondAgentUsername = null;
        
        // 初始化余额相关变量，避免未定义变量错误
        $agentBeforeBalance = 0;
        $agentAfterBalance = 0;
        $secondAgentBeforeBalance = 0;
        $secondAgentAfterBalance = 0;

        $currentUserId = $cUser['parent_id'];
        $level = 0;
        $maxLevel = 2; // 最多查找两级
        
        while (!empty($currentUserId) && $level < $maxLevel) {
            $stmt = $db->prepare(" 
                SELECT id, username, wallet_id, is_agent, parent_id
                FROM c_users
                WHERE id = ?
            ");
            $stmt->execute([$currentUserId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                break;
            }
            
            // 移除is_agent判断条件，只要是上级就发放佣金
            // 一级代理使用agentCommissionAmount，二级代理使用seniorAgentCommissionAmount
            if ($level === 0) {
                // 一级代理
                $agentUserId = $user['id'];
                $agentUsername = $user['username'];
                // 一级代理使用agentCommissionAmount
                $agentCommission = $agentCommissionAmount;
                $agentLevel = $user['is_agent'] ?? 0;
                    
                    // 查询团长钱包
                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $stmt->execute([$user['wallet_id']]);
                    $agentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($agentWallet) {
                        $agentBeforeBalance = (int)$agentWallet['balance'];
                        $agentAfterBalance = $agentBeforeBalance + $agentCommission;
                        
                        // 更新团长钱包
                        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $stmt->execute([$agentAfterBalance, $user['wallet_id']]);
                        
                        // 记录团长钱包流水
                        if ($agentLevel === 3) {
                            // 大团团长佣金记录
                            $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得大团团长佣金，任务ID：{$record['b_task_id']}";
                        } elseif ($agentLevel === 2) {
                            // 高级团长佣金记录
                            $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得高级团长佣金，任务ID：{$record['b_task_id']}";
                        } elseif ($agentLevel === 1) {
                            // 普通团长佣金记录
                            $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得普通团长佣金，任务ID：{$record['b_task_id']}";
                        } else {
                            // 普通用户佣金记录
                            $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得普通用户团队收益，任务ID：{$record['b_task_id']}";
                        }
                        $stmt = $db->prepare(" 
                            INSERT INTO wallets_log (
                                wallet_id, user_id, username, user_type, type, 
                                amount, before_balance, after_balance, 
                                related_type, related_id, task_types, task_types_text, remark
                            ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'agent_commission', ?, ?, ?, ?)
                        ");
                        $stmt->execute([
                            $user['wallet_id'],
                            $user['id'],
                            $user['username'],
                            $agentCommission,
                            $agentBeforeBalance,
                            $agentAfterBalance,
                            $record['b_task_id'],
                            $taskType,
                            $taskTypeText,
                            $agentRemark
                        ]);
                        
                        // 优化remark字段
                        $agentType = '普通用户';
                        if ($agentLevel === 1) {
                            $agentType = '普通团长';
                        } elseif ($agentLevel === 2) {
                            $agentType = '高级团长';
                        } elseif ($agentLevel === 3) {
                            $agentType = '大团团长';
                        }
                        $agentRemark = "当前用户 {$user['username']} 的邀请用户完成任务，{$agentType}获得一级团长佣金，任务ID：{$record['b_task_id']}，任务类型：{$taskTypeText}，任务阶段：{$record['task_stage_text']}，任务单价：{$taskUnitPrice}元，完成任务用户：{$cUser['username']}，用户获得奖励：" . ($cUserCommission / 100) . "元";
                        
                        // 记录一级代理C端任务统计
                        try {
                            // 获取任务阶段文本
                            $taskStageText = '';
                            if ($template) {
                                if ($stage === 0) {
                                    $taskStageText = $template['title'] ?? '';
                                } elseif ($stage === 1) {
                                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage1_title'] ?? '');
                                } elseif ($stage === 2) {
                                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage2_title'] ?? '');
                                }
                            }
                            
                            $stmt = $db->prepare(" 
                                INSERT INTO c_task_statistics (
                                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                                    record_status, record_status_text, remark
                                ) VALUES (?, ?, 1, ?, ?, ?, 'agent_commission', ?, ?, ?, ?, ?, ?, ?, ?)
                            ");
                            $stmt->execute([
                                $user['id'],
                                $user['username'],
                                $agentCommission,
                                $agentBeforeBalance,
                                $agentAfterBalance,
                                $record['b_task_id'],
                                $taskType,
                                $taskTypeText,
                                $stage,
                                $taskStageText,
                                3, // record_status: 3
                                '一级代理佣金', // record_status_text
                                $agentRemark
                            ]);
                        } catch (Exception $e) {
                            // 记录插入失败时的错误日志，但不影响主流程
                            error_log('插入c_task_statistics失败: ' . $e->getMessage());
                        }
                    }
            } elseif ($level === 1) {
                // 二级代理
                $secondAgentUserId = $user['id'];
                $secondAgentUsername = $user['username'];
                // 二级代理使用seniorAgentCommissionAmount
                $secondAgentCommission = $seniorAgentCommissionAmount;
                $agentLevel = $user['is_agent'] ?? 0;
                    
                    // 查询二级团长钱包
                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $stmt->execute([$user['wallet_id']]);
                    $secondAgentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($secondAgentWallet) {
                        $secondAgentBeforeBalance = (int)$secondAgentWallet['balance'];
                        $secondAgentAfterBalance = $secondAgentBeforeBalance + $secondAgentCommission;
                        
                        // 更新二级团长钱包
                        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $stmt->execute([$secondAgentAfterBalance, $user['wallet_id']]);
                        
                        // 记录二级团长钱包流水
                        if ($agentLevel === 3) {
                            $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级大团团长佣金，任务ID：{$record['b_task_id']}";
                        } elseif ($agentLevel === 2) {
                            $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级高级团长佣金，任务ID：{$record['b_task_id']}";
                        } elseif ($agentLevel === 1) {
                            $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级普通团长佣金，任务ID：{$record['b_task_id']}";
                        } else {
                            $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级普通用户团队收益，任务ID：{$record['b_task_id']}";
                        }
                        $stmt = $db->prepare(" 
                            INSERT INTO wallets_log (
                                wallet_id, user_id, username, user_type, type, 
                                amount, before_balance, after_balance, 
                                related_type, related_id, task_types, task_types_text, remark
                            ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'second_agent_commission', ?, ?, ?, ?)
                        ");
                        $stmt->execute([
                            $user['wallet_id'],
                            $user['id'],
                            $user['username'],
                            $secondAgentCommission,
                            $secondAgentBeforeBalance,
                            $secondAgentAfterBalance,
                            $record['b_task_id'],
                            $taskType,
                            $taskTypeText,
                            $secondAgentRemark
                        ]);
                        
                        // 优化remark字段
                        $secondAgentType = '普通用户';
                        if ($agentLevel === 1) {
                            $secondAgentType = '普通团长';
                        } elseif ($agentLevel === 2) {
                            $secondAgentType = '高级团长';
                        } elseif ($agentLevel === 3) {
                            $secondAgentType = '大团团长';
                        }
                        $secondAgentRemark = "当前用户 {$user['username']} 的邀请用户的团队成员完成任务，{$secondAgentType}获得二级团长佣金，任务ID：{$record['b_task_id']}，任务类型：{$taskTypeText}，任务阶段：{$record['task_stage_text']}，任务单价：{$taskUnitPrice}元，完成任务用户：{$cUser['username']}，用户获得奖励：" . ($cUserCommission / 100) . "元";
                        
                        // 记录二级代理C端任务统计
                        try {
                            // 获取任务阶段文本
                            $taskStageText = '';
                            if ($template) {
                                if ($stage === 0) {
                                    $taskStageText = $template['title'] ?? '';
                                } elseif ($stage === 1) {
                                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage1_title'] ?? '');
                                } elseif ($stage === 2) {
                                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage2_title'] ?? '');
                                }
                            }
                            
                            $stmt = $db->prepare(" 
                                INSERT INTO c_task_statistics (
                                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                                    record_status, record_status_text, remark
                                ) VALUES (?, ?, 1, ?, ?, ?, 'second_agent_commission', ?, ?, ?, ?, ?, ?, ?, ?)
                            ");
                            $stmt->execute([
                                $user['id'],
                                $user['username'],
                                $secondAgentCommission,
                                $secondAgentBeforeBalance,
                                $secondAgentAfterBalance,
                                $record['b_task_id'],
                                $taskType,
                                $taskTypeText,
                                $stage,
                                $taskStageText,
                                3, // record_status: 3
                                '二级代理佣金', // record_status_text
                                $secondAgentRemark
                            ]);
                        } catch (Exception $e) {
                            // 记录插入失败时的错误日志，但不影响主流程
                            error_log('插入c_task_statistics失败: ' . $e->getMessage());
                        }
                    }
            }
            
            // 继续向上查找
            $currentUserId = $user['parent_id'];
            $level++;
        }

        // 14. 记录团队收益统计
        try {
            // 查询完成任务用户的一级和二级代理
            $currentUserId = $cUser['parent_id'];
            $level = 0;
            $maxLevel = 2; // 最多查找两级
            
            // 调试日志
            error_log('开始记录团队收益统计，当前用户ID: ' . $cUser['id'] . ', 一级代理ID: ' . $currentUserId);
            
            while (!empty($currentUserId) && $level < $maxLevel) {
                error_log('循环开始，当前level: ' . $level . ', currentUserId: ' . $currentUserId);
                
                $stmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
                $stmt->execute([$currentUserId]);
                $agentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$agentUser) {
                    error_log('未找到代理用户，currentUserId: ' . $currentUserId);
                    break;
                }
                
                error_log('找到代理用户，ID: ' . $agentUser['id'] . ', 用户名: ' . $agentUser['username'] . ', level: ' . $level);
                
                // 团队收益金额与完成任务用户获得的佣金金额相同
                $agentCommAmount = $cUserCommission;
                
                // 查询当前代理的团队收益汇总记录，获取当前收益总额
                $stmt = $db->prepare("SELECT total_team_revenue FROM team_revenue_statistics_summary WHERE user_id = ?");
                $stmt->execute([$agentUser['id']]);
                $summary = $stmt->fetch(PDO::FETCH_ASSOC);
                
                $agentBeforeAmount = $summary ? (float)$summary['total_team_revenue'] : 0;
                $agentAfterAmount = $agentBeforeAmount + $agentCommAmount;
                
                // 插入团队收益记录
                error_log('准备插入团队收益记录，代理ID: ' . $agentUser['id'] . ', 层级: ' . ($level + 1) . ', 金额: ' . $agentCommAmount);
                
                $stmt = $db->prepare("INSERT INTO team_revenue_statistics_breakdown (
                    agent_id, agent_username, agent_level, 
                    downline_user_id, downline_username, downline_user_amount, 
                    team_revenue_amount, agent_before_amount, agent_after_amount, 
                    related_id, revenue_source, revenue_source_text, 
                    task_type, task_type_text, task_stage, task_stage_text
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                
                $result = $stmt->execute([
                    $agentUser['id'],
                    $agentUser['username'],
                    $level + 1, // 代理层级：1=一级代理，2=二级代理
                    $cUser['id'],
                    $cUser['username'],
                    $cUserCommission, // 下线用户获得的金额
                    $agentCommAmount, // 代理获得的团队收益金额
                    $agentBeforeAmount,
                    $agentAfterAmount,
                    $record['b_task_id'],
                    1, // 收益来源：1=任务收益
                    '任务收益',
                    $taskType,
                    $taskTypeText,
                    $stage,
                    $taskStageText
                ]);
                
                error_log('插入团队收益记录结果: ' . ($result ? '成功' : '失败') . ', 代理ID: ' . $agentUser['id']);
                
                // 更新团队收益汇总表
                // 先查询是否存在记录
                $stmt = $db->prepare("SELECT id FROM team_revenue_statistics_summary WHERE user_id = ?");
                $stmt->execute([$agentUser['id']]);
                $exists = $stmt->fetch(PDO::FETCH_ASSOC);
                
                $revenueSource = 1; // 任务收益
                $agentLevel = $level + 1;
                $currentTime = date('Y-m-d H:i:s');
                
                error_log('准备更新团队收益汇总表，代理ID: ' . $agentUser['id'] . ', 层级: ' . $agentLevel . ', 金额: ' . $agentCommAmount);
                
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
                    
                    // 任务收益笔数和金额
                    $updateSql .= "task_revenue_count = task_revenue_count + 1, ";
                    $updateSql .= "task_revenue_amount = task_revenue_amount + ?, ";
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
                        1, 0, // 任务收益笔数和订单收益笔数
                        $agentCommAmount, 0, // 任务收益金额和订单收益金额
                        $agentLevel == 1 ? 1 : 0, // 一级下线收益笔数
                        $agentLevel == 2 ? 1 : 0, // 二级下线收益笔数
                        $currentTime,
                        $agentLevel == 1 ? $currentTime : null,
                        $agentLevel == 2 ? $currentTime : null
                    ];
                    
                    $stmt = $db->prepare($insertSql);
                    $result = $stmt->execute($insertParams);
                }
                
                error_log('更新团队收益汇总表结果: ' . ($result ? '成功' : '失败') . ', 代理ID: ' . $agentUser['id']);
                
                // 继续向上查找
                $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                $stmt->execute([$agentUser['id']]);
                $nextParent = $stmt->fetch(PDO::FETCH_ASSOC);
                $currentUserId = $nextParent['parent_id'] ?? null;
                error_log('继续向上查找，下一级代理ID: ' . $currentUserId);
                $level++;
            }
            
            error_log('团队收益统计循环结束');
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            error_log('插入team_revenue_statistics_breakdown失败: ' . $e->getMessage());
        }

        // 14. 检查并处理新手转正
        $isNewbie = false;
        $hasCompletedTasks = 0;
        $isPromoted = false;
        
        // 查询用户的新手状态
        $stmt = $db->prepare("SELECT is_newbie FROM c_users WHERE id = ?");
        $stmt->execute([$cUser['id']]);
        $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($userInfo && (int)$userInfo['is_newbie'] === 1) {
            $isNewbie = true;
            
            // 自动审核通过时增加完成任务数量计数
            // 更新c_user_task_records_static表中的已完成任务数量
            $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, task_id, task_type, action, status, reward, completed_task_count) VALUES (?, ?, 1, 'complete', 2, ?, 1) ON DUPLICATE KEY UPDATE completed_task_count = completed_task_count + 1");
            $stmt->execute([$cUser['id'], $record['b_task_id'], $cUserCommission / 100]);
            
            // 查询用户已完成的任务数量
            $stmt = $db->prepare("SELECT COUNT(*) as completed_count FROM c_task_records WHERE c_user_id = ? AND status = 3");
            $stmt->execute([$cUser['id']]);
            $completedInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            $hasCompletedTasks = (int)$completedInfo['completed_count'];
            
            // 如果完成任务数 >= 5，自动转正
            if ($hasCompletedTasks >= 5) {
                $stmt = $db->prepare("UPDATE c_users SET is_newbie = 0 WHERE id = ?");
                $stmt->execute([$cUser['id']]);
                $isPromoted = true;
                echo "用户已转正，用户ID: " . $cUser['id'] . "，用户名: " . $cUser['username'] . "\n";
            }
        }

        // 15. 提交事务
        $db->commit();

        // 输出结算详情日志
        echo "查询到的待审核任务详情：\n";
        echo "任务ID: " . $record['b_task_id'] . "\n";
        echo "C端用户（当前任务完成用户）: " . $cUser['username'] . " (ID: " . $cUser['id'] . ")\n";
        
        // 输出一级代理信息
        if (isset($agentUserId) && !empty($agentUserId)) {
            echo "一级代理（当前任务完成用户的一级代理）: " . $agentUsername . " (ID: " . $agentUserId . ")\n";
        } else {
            echo "一级代理（当前任务完成用户的一级代理）: 无\n";
        }
        
        // 输出二级代理信息
        if (isset($secondAgentUserId) && !empty($secondAgentUserId)) {
            echo "二级代理（当前任务完成用户的一级代理的一级代理）: " . $secondAgentUsername . " (ID: " . $secondAgentUserId . ")\n";
        } else {
            echo "二级代理（当前任务完成用户的一级代理的一级代理）: 无\n";
        }
        
        echo "B端任务单价: " . ($taskUnitPrice) . " 元\n";
        echo "用户佣金: " . ($cUserCommission / 100) . " 元\n";

        echo "自动审核通过奖励金额: " . ($record['reward_amount'] / 100) . " 元\n";


        // 输出代理佣金信息
        if (!empty($cUser['parent_id'])) {
            if (isset($agentUserId) && !empty($agentUserId)) {
                echo "（当前任务完成用户）一级代理: " . $agentUsername . " (ID: " . $agentUserId . ")\n";
                echo "（当前任务完成用户）一级代理佣金: " . ($agentCommission / 100) . " 元\n";

                if (isset($secondAgentUserId) && !empty($secondAgentUserId)) {
                    echo "（当前任务完成用户）二级代理: " . $secondAgentUsername . " (ID: " . $secondAgentUserId . ")\n";
                    echo "（当前任务完成用户）二级代理佣金: " . ($secondAgentCommission / 100) . " 元\n";
                }
            }
        }
        
        // 输出团队收益统计信息
        echo "团队收益统计：\n";
        echo "完成任务用户获得: " . ($cUserCommission / 100) . " 元\n";
        if (isset($agentUserId) && !empty($agentUserId)) {
            echo "一级代理团队收益: " . ($cUserCommission / 100) . " 元\n";
        }
        if (isset($secondAgentUserId) && !empty($secondAgentUserId)) {
            echo "二级代理团队收益: " . ($cUserCommission / 100) . " 元\n";
        }

        echo "自动审核通过任务记录ID: " . $record['id'] . "\n";
    } catch (PDOException $e) {
        // 回滚事务
        if ($db->inTransaction()) {
            $db->rollBack();
        }

        echo "自动审核失败，任务记录ID: " . $record['id'] . "，错误: " . $e->getMessage() . "\n";
    }
}
