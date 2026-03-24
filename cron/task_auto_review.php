<?php

/**
 * 自动审核任务脚本
 * 每1分钟执行一次，检查提交时间超过10分钟的待审核任务
 */

// 日志文件路径
$logFile = 'd:\github\douyinTasksystemAPI\apierr-log.log';

// 确保日志目录存在
$logDir = dirname($logFile);
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
}

// 自定义日志函数
function customLog($message) {
    global $logFile;
    $timestamp = date('[Y-m-d H:i:s]');
    $logMessage = "{$timestamp} {$message}\n";
    // 输出到终端
    error_log($message);
    // 输出到文件
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}

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

// 脚本开始
customLog('=== 自动审核任务脚本开始 ===');
customLog('当前时间: ' . date('Y-m-d H:i:s'));

// 定义自动审核时间阈值（1分钟，用于测试）
$autoReviewThreshold = 1 * 10; // 秒
$currentTime = time();
$thresholdTime = $currentTime - $autoReviewThreshold;
customLog('自动审核时间阈值: ' . $autoReviewThreshold . '秒');
customLog('阈值时间: ' . date('Y-m-d H:i:s', $thresholdTime));

// 数据库连接
customLog('步骤1: 连接数据库');
$db = Database::connect();
if (!$db) {
    customLog('数据库连接失败，退出脚本');
    exit;
}
customLog('数据库连接成功');

try {
    // 查询超过10分钟未审核的任务
    customLog('步骤2: 查询超过时间阈值未审核的任务');
    $stmt = $db->prepare("        SELECT 
            c.id, c.c_user_id, c.b_user_id, c.b_task_id, 
            c.status, c.reward_amount, c.comment_url, c.submitted_at, c.task_stage, c.task_stage_text
        FROM c_task_records c
        WHERE c.status = 2 -- 待审核状态
          AND UNIX_TIMESTAMP(c.submitted_at) < ?
    ");
    
    $stmt->execute([$thresholdTime]);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $recordCount = count($records);
    customLog('查询到的待审核任务数量: ' . $recordCount);

    if (empty($records)) {
        customLog('没有需要自动审核的任务，退出脚本');
        exit;
    }

    customLog('开始执行自动审核逻辑');
    foreach ($records as $record) {
        customLog('处理任务记录ID: ' . $record['id'] . ', 任务ID: ' . $record['b_task_id']);
        // 执行自动审核通过逻辑
        autoApproveTask($db, $record, $errorCodes);
    }
    
    customLog('自动审核任务脚本执行完成');
    customLog('=== 自动审核任务脚本结束 ===');
    
} catch (PDOException $e) {
    customLog('数据库异常: ' . $e->getMessage());
    customLog('=== 自动审核任务脚本异常结束 ===');
}

/**
 * 自动审核通过任务
 */
function autoApproveTask($db, $record, $errorCodes)
{
    try {
        customLog('开始自动审核通过处理，任务记录ID: ' . $record['id'] . '，任务ID: ' . $record['b_task_id']);
        
        // 1. 查询C端用户信息
        customLog('步骤1: 查询C端用户信息，用户ID: ' . $record['c_user_id']);
        $stmt = $db->prepare("
            SELECT id, username, wallet_id, parent_id, is_agent
            FROM c_users 
            WHERE id = ?
        ");
        $stmt->execute([$record['c_user_id']]);
        $cUser = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$cUser) {
            customLog('C端用户不存在，用户ID: ' . $record['c_user_id']);
            return;
        }
        customLog('C端用户信息查询成功，用户ID: ' . $cUser['id'] . ', 用户名: ' . $cUser['username']);
        
        // 2. 查询或创建当日统计记录
        $today = date('Y-m-d');
        customLog('步骤2: 查询或创建当日统计记录，用户ID: ' . $record['c_user_id']);
        
        $stmt = $db->prepare("
            SELECT id 
            FROM c_user_daily_stats 
            WHERE c_user_id = ? AND stat_date = ?
        ");
        $stmt->execute([$record['c_user_id'], $today]);
        $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$dailyStats) {
            customLog('当日统计记录不存在，创建新记录');
            $stmt = $db->prepare("
                INSERT INTO c_user_daily_stats (c_user_id, stat_date)
                VALUES (?, ?)
            ");
            $stmt->execute([$record['c_user_id'], $today]);
            $dailyStatsId = $db->lastInsertId();
            customLog('当日统计记录创建成功，ID: ' . $dailyStatsId);
        } else {
            $dailyStatsId = $dailyStats['id'];
            customLog('当日统计记录已存在，ID: ' . $dailyStatsId);
        }

        // 3. 开启事务
        customLog('步骤3: 开启事务');
        $db->beginTransaction();
        customLog('事务开启成功');

        $reviewedAt = date('Y-m-d H:i:s');

        // 4. 更新任务记录状态
        customLog('步骤4: 更新任务记录状态为已通过，记录ID: ' . $record['id']);
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 3, reviewed_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$reviewedAt, $record['id']]);
        customLog('任务记录状态更新成功');

        // 5. 更新B端任务统计
        customLog('步骤5: 更新B端任务统计，任务ID: ' . $record['b_task_id']);
        // 先检查是普通任务还是新手任务
        $stmt = $db->prepare("SELECT id FROM b_tasks WHERE id = ?");
        $stmt->execute([$record['b_task_id']]);
        $isNormalTask = $stmt->fetch(PDO::FETCH_ASSOC) !== false;
        customLog('任务类型: ' . ($isNormalTask ? '普通任务' : '新手任务'));
        
        if ($isNormalTask) {
            // 更新普通任务统计
            customLog('更新普通任务统计');
            // 先检查当前 task_reviewing 和 task_done 值
            $stmt = $db->prepare("SELECT task_reviewing, task_done FROM b_tasks WHERE id = ?");
            $stmt->execute([$record['b_task_id']]);
            $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // 计算新的 task_reviewing 和 task_done 值
            $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
            $newTaskDone = (int)$taskInfo['task_done'] + 1;
            customLog('当前 task_reviewing: ' . $taskInfo['task_reviewing'] . ', 新值：' . $newTaskReviewing);
            customLog('当前 task_done: ' . $taskInfo['task_done'] . ', 新值：' . $newTaskDone);
            
            // 更新任务统计
            $stmt = $db->prepare("                UPDATE b_tasks 
                SET task_reviewing = ?, task_done = ?
                WHERE id = ?
            ");
            $stmt->execute([$newTaskReviewing, $newTaskDone, $record['b_task_id']]);
            customLog('普通任务统计更新成功');
            
            // 6. 检查任务是否全部完成，如果完成则更新状态为"已完成"
            customLog('检查任务是否全部完成');
            $stmt = $db->prepare("                SELECT task_count, task_done
                FROM b_tasks 
                WHERE id = ?
            ");
            $stmt->execute([$record['b_task_id']]);
            $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
                customLog('任务全部完成，更新状态为已完成');
                // 任务全部完成，更新状态为已完成(status=2)
                $stmt = $db->prepare("                    UPDATE b_tasks 
                    SET status = 2, stage_status = 2, completed_at = ?
                    WHERE id = ?
                ");
                $stmt->execute([$reviewedAt, $record['b_task_id']]);
                customLog('任务状态更新为已完成');
            } else {
                customLog('任务未全部完成，当前完成: ' . ($taskProgress['task_done'] ?? 0) . ', 总任务数: ' . ($taskProgress['task_count'] ?? 0));
            }
            
            // 7. 检查组合任务是否需要开放第二阶段
            customLog('步骤6: 检查组合任务是否需要开放第二阶段，任务ID: ' . $record['b_task_id']);
            $stmt = $db->prepare("                SELECT 
                    id, combo_task_id, stage, task_count, task_done
                FROM b_tasks 
                WHERE id = ?
            ");
            $stmt->execute([$record['b_task_id']]);
            $bTask = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($bTask && !empty($bTask['combo_task_id']) && (int)$bTask['stage'] === 1) {
                customLog('这是组合任务的第一阶段，combo_task_id: ' . $bTask['combo_task_id']);
                // 这是组合任务的第一阶段
                // 检查第一阶段是否全部完成（组合任务阶段1固定为1个任务）
                if ((int)$bTask['task_done'] === (int)$bTask['task_count']) {
                    customLog('第一阶段已全部完成，准备开放第二阶段');
                    // 第一阶段完成，获取C端用户提交的评论链接作为阶段2的video_url
                    $commentUrl = $record['comment_url'] ?? '';
                    
                    if (!empty($commentUrl)) {
                        customLog('获取到评论链接，开放第二阶段并设置video_url');
                        // 开放第二阶段，并设置video_url为阶段1的评论链接
                        $stmt = $db->prepare("                            UPDATE b_tasks 
                            SET stage_status = 1, video_url = ?
                            WHERE combo_task_id = ? AND stage = 2
                        ");
                        $stmt->execute([$commentUrl, $bTask['combo_task_id']]);
                        customLog('第二阶段开放成功，已设置video_url');
                    } else {
                        customLog('评论链接为空，只开放第二阶段');
                        // 如果评论链接为空，只开放不设置video_url（保持为空）
                        $stmt = $db->prepare("                            UPDATE b_tasks 
                            SET stage_status = 1 
                            WHERE combo_task_id = ? AND stage = 2
                        ");
                        $stmt->execute([$bTask['combo_task_id']]);
                        customLog('第二阶段开放成功');
                    }
                } else {
                    customLog('第一阶段未全部完成，当前完成: ' . $bTask['task_done'] . ', 总任务数: ' . $bTask['task_count']);
                }
            } else {
                customLog('不是组合任务的第一阶段，跳过开放第二阶段检查');
            }
        } else {
            // 更新新手任务统计
            customLog('更新新手任务统计');
            // 先检查当前task_reviewing值
            $stmt = $db->prepare("SELECT task_reviewing FROM b_newbie_tasks WHERE id = ?");
            $stmt->execute([$record['b_task_id']]);
            $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // 计算新的task_reviewing值
            $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
            customLog('当前task_reviewing: ' . $taskInfo['task_reviewing'] . ', 新值: ' . $newTaskReviewing);
            
            // 更新任务统计
            $stmt = $db->prepare("                UPDATE b_newbie_tasks 
                SET task_reviewing = ?, task_done = task_done + 1
                WHERE id = ?
            ");
            $stmt->execute([$newTaskReviewing, $record['b_task_id']]);
            customLog('新手任务统计更新成功');
            
            // 6. 检查任务是否全部完成，如果完成则更新状态为"已完成"
            customLog('检查任务是否全部完成');
            $stmt = $db->prepare("                SELECT task_count, task_done
                FROM b_newbie_tasks 
                WHERE id = ?
            ");
            $stmt->execute([$record['b_task_id']]);
            $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
                customLog('任务全部完成，更新状态为已完成');
                // 任务全部完成，更新状态为已完成(status=2)
                $stmt = $db->prepare("                    UPDATE b_newbie_tasks 
                    SET status = 2, stage_status = 2, completed_at = ?
                    WHERE id = ?
                ");
                $stmt->execute([$reviewedAt, $record['b_task_id']]);
                customLog('任务状态更新为已完成');
            } else {
                customLog('任务未全部完成，当前完成: ' . ($taskProgress['task_done'] ?? 0) . ', 总任务数: ' . ($taskProgress['task_count'] ?? 0));
            }
        }

        // 8. 更新当日统计
        customLog('步骤7: 更新当日统计，统计记录ID: ' . $dailyStatsId);
        $stmt = $db->prepare("
            UPDATE c_user_daily_stats 
            SET approved_count = approved_count + 1 
            WHERE id = ?
        ");
        $stmt->execute([$dailyStatsId]);
        
        // 查询更新后的approved_count值
        $stmt = $db->prepare("SELECT approved_count FROM c_user_daily_stats WHERE id = ?");
        $stmt->execute([$dailyStatsId]);
        $newApprovedCount = $stmt->fetchColumn();
        customLog('c_user_daily_stats表已更新，用户ID: ' . $cUser['id'] . '，新的approved_count值: ' . $newApprovedCount);

        // 9. 计算佣金（从模板读取固定金额）
        customLog('步骤8: 计算佣金');
        // 查询b_task获取template_id、stage和unit_price
        $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
        $stmt->execute([$record['b_task_id']]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        // 如果b_tasks表中没有记录，查询b_newbie_tasks表
        if (!$bTaskInfo) {
            $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_newbie_tasks WHERE id = ?");
            $stmt->execute([$record['b_task_id']]);
            $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$bTaskInfo) {
                customLog('任务信息不存在，回滚事务');
                $db->rollBack();
                return;
            }
        }
        customLog('任务信息查询成功，模板ID: ' . $bTaskInfo['template_id'] . ', 阶段: ' . $bTaskInfo['stage'] . ', 单价: ' . $bTaskInfo['unit_price']);

        // 获取派单单价
        $taskUnitPrice = (float)($bTaskInfo['unit_price'] ?? 0);

        // 查询模板佣金配置
        customLog('步骤9: 查询模板佣金配置，模板ID: ' . $bTaskInfo['template_id']);
        $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
        $stmt->execute([$bTaskInfo['template_id']]);
        $template = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$template) {
            customLog('模板配置不存在，回滚事务');
            $db->rollBack();
            return;
        }
        customLog('模板配置查询成功');

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
        customLog('佣金计算完成，C端用户佣金: ' . $cUserCommission . ', 一级代理佣金: ' . $agentCommissionAmount . ', 二级代理佣金: ' . $seniorAgentCommissionAmount);

        // 10. 查询C端用户钱包
        customLog('步骤10: 查询C端用户钱包，钱包ID: ' . $cUser['wallet_id']);
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$cUser['wallet_id']]);
        $cWallet = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$cWallet) {
            customLog('C端用户钱包不存在，回滚事务');
            $db->rollBack();
            return;
        }

        $cBeforeBalance = (int)$cWallet['balance'];
        $cAfterBalance = $cBeforeBalance + $cUserCommission;

        // 11. 更新C端用户钱包
        customLog('步骤10: 更新C端用户钱包，用户ID: ' . $cUser['id'] . ', 钱包ID: ' . $cUser['wallet_id']);
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$cAfterBalance, $cUser['wallet_id']]);
        customLog('C端用户钱包更新成功，原余额: ' . $cBeforeBalance . ', 新余额: ' . $cAfterBalance);

        // 12. 记录C端用户钱包流水
        customLog('步骤11: 记录C端用户钱包流水，用户ID: ' . $cUser['id']);
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
        customLog('步骤12: 记录C端任务统计，用户ID: ' . $cUser['id']);
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
            customLog('C端任务统计记录成功');
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            customLog('记录C端任务统计失败: ' . $e->getMessage());
        }

        // 13. 检查是否有团长上级，向上查找直到找到大团团长或达到最大层级
        customLog('步骤11: 检查是否有团长上级，发放佣金');
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
            customLog('查找代理，当前level: ' . $level . ', currentUserId: ' . $currentUserId);
            $stmt = $db->prepare(" 
                SELECT id, username, wallet_id, is_agent, parent_id
                FROM c_users
                WHERE id = ?
            ");
            $stmt->execute([$currentUserId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                customLog('未找到代理用户，currentUserId: ' . $currentUserId);
                break;
            }
            customLog('找到代理用户，ID: ' . $user['id'] . ', 用户名: ' . $user['username'] . ', is_agent: ' . ($user['is_agent'] ?? 0));
            
            // 移除is_agent判断条件，只要是上级就发放佣金
            // 一级代理使用agentCommissionAmount，二级代理使用seniorAgentCommissionAmount
            if ($level === 0) {
                // 一级代理
                customLog('处理一级代理佣金，代理ID: ' . $user['id']);
                $agentUserId = $user['id'];
                $agentUsername = $user['username'];
                // 一级代理使用agentCommissionAmount
                $agentCommission = $agentCommissionAmount;
                $agentLevel = $user['is_agent'] ?? 0;
                customLog('一级代理佣金: ' . $agentCommission . ', 代理级别: ' . $agentLevel);
                    
                    // 查询团长钱包
                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $stmt->execute([$user['wallet_id']]);
                    $agentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($agentWallet) {
                        $agentBeforeBalance = (int)$agentWallet['balance'];
                        $agentAfterBalance = $agentBeforeBalance + $agentCommission;
                        
                        // 更新团长钱包
                        customLog('更新一级代理钱包，代理ID: ' . $user['id'] . ', 原余额: ' . $agentBeforeBalance . ', 新余额: ' . $agentAfterBalance);
                        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $stmt->execute([$agentAfterBalance, $user['wallet_id']]);
                        customLog('一级代理钱包更新成功');
                        
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
                            }
                    }
            } elseif ($level === 1) {
                // 二级代理
                customLog('处理二级代理佣金，代理ID: ' . $user['id']);
                $secondAgentUserId = $user['id'];
                $secondAgentUsername = $user['username'];
                // 二级代理使用seniorAgentCommissionAmount
                $secondAgentCommission = $seniorAgentCommissionAmount;
                $agentLevel = $user['is_agent'] ?? 0;
                customLog('二级代理佣金: ' . $secondAgentCommission . ', 代理级别: ' . $agentLevel);
                    
                    // 查询二级团长钱包
                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $stmt->execute([$user['wallet_id']]);
                    $secondAgentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($secondAgentWallet) {
                        $secondAgentBeforeBalance = (int)$secondAgentWallet['balance'];
                        $secondAgentAfterBalance = $secondAgentBeforeBalance + $secondAgentCommission;
                        
                        // 更新二级团长钱包
                        customLog('更新二级代理钱包，代理ID: ' . $user['id'] . ', 原余额: ' . $secondAgentBeforeBalance . ', 新余额: ' . $secondAgentAfterBalance);
                        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $stmt->execute([$secondAgentAfterBalance, $user['wallet_id']]);
                        customLog('二级代理钱包更新成功');
                        
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
                            }
                    }
            }
            
            // 继续向上查找
            $currentUserId = $user['parent_id'];
            customLog('继续向上查找，下一级代理ID: ' . ($currentUserId ?? '无'));
            $level++;
        }
        customLog('代理佣金发放循环结束');

        // 14. 记录团队收益统计
        customLog('步骤13: 记录团队收益统计，当前用户ID: ' . $cUser['id'] . ', 一级代理ID: ' . $cUser['parent_id']);
        try {
            // 查询完成任务用户的一级和二级代理
            $currentUserId = $cUser['parent_id'];
            $level = 0;
            $maxLevel = 2; // 最多查找两级
            
            while (!empty($currentUserId) && $level < $maxLevel) {
                customLog('循环开始，当前level: ' . $level . ', currentUserId: ' . $currentUserId);
                $stmt = $db->prepare("SELECT id, username FROM c_users WHERE id = ?");
                $stmt->execute([$currentUserId]);
                $agentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$agentUser) {
                    customLog('未找到代理用户，currentUserId: ' . $currentUserId);
                    break;
                }
                customLog('找到代理用户，ID: ' . $agentUser['id'] . ', 用户名: ' . $agentUser['username'] . ', level: ' . $level);
                
                // 团队收益金额与完成任务用户获得的佣金金额相同
                $agentCommAmount = $cUserCommission;
                
                // 查询当前代理的团队收益汇总记录，获取当前收益总额
                $stmt = $db->prepare("SELECT total_team_revenue FROM team_revenue_statistics_summary WHERE user_id = ?");
                $stmt->execute([$agentUser['id']]);
                $summary = $stmt->fetch(PDO::FETCH_ASSOC);
                
                $agentBeforeAmount = $summary ? (float)$summary['total_team_revenue'] : 0;
                $agentAfterAmount = $agentBeforeAmount + $agentCommAmount;
                
                // 插入团队收益记录
                customLog('准备插入团队收益记录，代理ID: ' . $agentUser['id'] . ', 层级: ' . ($level + 1) . ', 金额: ' . $agentCommAmount);
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
                customLog('插入团队收益记录结果: ' . ($result ? '成功' : '失败') . ', 代理ID: ' . $agentUser['id']);
                
                // 更新团队收益汇总表
                // 先查询是否存在记录
                $stmt = $db->prepare("SELECT id FROM team_revenue_statistics_summary WHERE user_id = ?");
                $stmt->execute([$agentUser['id']]);
                $exists = $stmt->fetch(PDO::FETCH_ASSOC);
                
                $revenueSource = 1; // 任务收益
                $agentLevel = $level + 1;
                $currentTime = date('Y-m-d H:i:s');
                
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
                    customLog('插入团队收益汇总表结果: ' . ($result ? '成功' : '失败') . ', 代理ID: ' . $agentUser['id']);
                } 
                 // 继续向上查找
                $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                $stmt->execute([$agentUser['id']]);
                $nextParent = $stmt->fetch(PDO::FETCH_ASSOC);
                $currentUserId = $nextParent['parent_id'] ?? null;
                customLog('继续向上查找，下一级代理ID: ' . ($currentUserId ?? '无'));
                $level++;
            }
            customLog('团队收益统计循环结束');
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            customLog('插入team_revenue_statistics_breakdown失败: ' . $e->getMessage());
        }

        // 14. 检查并处理新手转正
        $isNewbie = false;
        $hasCompletedTasks = 0;
        $isPromoted = false;
        
        // 查询用户的新手状态
        $stmt = $db->prepare("SELECT is_newbie FROM c_users WHERE id = ?");
        $stmt->execute([$cUser['id']]);
        $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // 自动审核通过时增加完成任务数量计数
        // 先查询是否存在记录
        customLog('步骤14: 查询 c_user_task_records_static 表是否存在用户记录，用户ID: ' . $cUser['id']);
        $stmt = $db->prepare("SELECT id FROM c_user_task_records_static WHERE user_id = ?");
        $stmt->execute([$cUser['id']]);
        $existingRecord = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existingRecord) {
            // 存在记录，更新
            customLog('存在记录，更新 completed_task_count，用户ID: ' . $cUser['id']);
            $stmt = $db->prepare("UPDATE c_user_task_records_static SET completed_task_count = completed_task_count + 1 WHERE user_id = ?");
            $stmt->execute([$cUser['id']]);
            customLog('更新 completed_task_count 成功，用户ID: ' . $cUser['id']);
        } else {
            // 不存在记录，插入
            customLog('不存在记录，插入新记录，用户ID: ' . $cUser['id']);
            $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, completed_task_count) VALUES (?, 1)");
            $stmt->execute([$cUser['id']]);
            customLog('插入新记录成功，用户ID: ' . $cUser['id']);
        }
        
        // 查询更新后的完成任务数量
        $stmt = $db->prepare("SELECT completed_task_count FROM c_user_task_records_static WHERE user_id = ?");
        $stmt->execute([$cUser['id']]);
        $updatedStatic = $stmt->fetch(PDO::FETCH_ASSOC);
        $completedCount = $updatedStatic ? (int)$updatedStatic['completed_task_count'] : 0;
        
        customLog('c_user_task_records_static表已更新，用户ID: ' . $cUser['id'] . '，新的completed_task_count值: ' . $completedCount);
        customLog('自动审核通过，增加完成任务数量计数');
        
        if ($userInfo && (int)$userInfo['is_newbie'] === 1) {
            $isNewbie = true;
            $hasCompletedTasks = $completedCount;
            
            // 如果完成任务数 >= 5，自动转正
            if ($hasCompletedTasks >= 5) {
                customLog('用户完成任务数达到5个，自动转正，用户ID: ' . $cUser['id']);
                $stmt = $db->prepare("UPDATE c_users SET is_newbie = 0 WHERE id = ?");
                $stmt->execute([$cUser['id']]);
                $isPromoted = true;
                customLog('用户已转正，用户ID: ' . $cUser['id'] . '，用户名: ' . $cUser['username']);
            }
        }

        // 15. 提交事务
        customLog('步骤15: 提交事务');
        $db->commit();
        customLog('事务提交成功');
        customLog('自动审核通过处理完成，任务记录ID: ' . $record['id'] . '，任务ID: ' . $record['b_task_id']);
        customLog('C端用户佣金: ' . number_format($cUserCommission / 100, 2) . ' 元');

    } catch (PDOException $e) {
        // 回滚事务
        if ($db->inTransaction()) {
            $db->rollBack();
            customLog('事务回滚成功');
        }
        customLog('自动审核失败: ' . $e->getMessage());
    }
}
