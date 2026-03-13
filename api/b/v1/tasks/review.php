<?php
/**
 * B端任务审核接口
 * 
 * POST /api/b/v1/tasks/review
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "b_task_id": 123,
 *   "record_id": 456,
 *   "action": "approve",  // approve=通过, reject=驳回
 *   "reject_reason": "截图不清晰"  // action=reject时必填
 * }
 * 
 * 审核规则：
 * 
 * 通过(approve)：
 * - c_task_records.status = 3 (approved)
 * - b_tasks.task_reviewing -1, task_done +1
 * - c_user_daily_stats.approved_count +1
 * - 发放佣金给C端用户（单价 * 57%）
 * - 如果C端用户有团长上级，额外发放（单价 * 8%）给上级
 * - 更新钱包和钱包流水
 * 
 * 驳回(reject)：
 * - c_task_records.status = 4 (rejected)
 * - b_tasks.task_reviewing -1 （释放名额，任务重新可被接）
 * - c_user_daily_stats.rejected_count +1
 * - 不发放佣金
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$action = trim($input['action'] ?? '');
$rejectReason = trim($input['reject_reason'] ?? '');

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($recordId) || !is_numeric($recordId)) {
    Response::error('任务记录ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (!in_array($action, ['approve', 'reject'])) {
    Response::error('审核操作无效，必须是 approve 或 reject', $errorCodes['TASK_REVIEW_INVALID_ACTION']);
}

if ($action === 'reject' && empty($rejectReason)) {
    Response::error('驳回时必须填写驳回原因', $errorCodes['TASK_REVIEW_REJECT_REASON_REQUIRED']);
}

try {
    // 1. 查询任务记录
    $stmt = $db->prepare("
        SELECT 
            c.id, c.c_user_id, c.b_user_id, c.b_task_id, 
            c.status, c.reward_amount, c.comment_url
        FROM c_task_records c
        WHERE c.id = ? AND c.b_task_id = ?
    ");
    $stmt->execute([$recordId, $bTaskId]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$record) {
        Response::error('任务记录不存在或参数不匹配', $errorCodes['TASK_REVIEW_NOT_FOUND']);
    }
    
    // 2. 校验是否是当前B端用户发布的任务
    if ((int)$record['b_user_id'] !== $currentUser['user_id']) {
        Response::error('无权审核此任务', $errorCodes['TASK_REVIEW_NOT_FOUND']);
    }
    
    // 3. 校验任务状态（只能审核待审核状态的任务）
    if ((int)$record['status'] !== 2) {
        $statusTexts = [1 => '进行中', 2 => '待审核', 3 => '已通过', 4 => '已驳回', 5 => '已超时'];
        $currentStatusText = $statusTexts[(int)$record['status']] ?? '未知';
        Response::error("该任务当前状态为：{$currentStatusText}，无法审核", $errorCodes['TASK_REVIEW_INVALID_STATUS']);
    }
    
    // 4. 查询C端用户信息
    $stmt = $db->prepare("
        SELECT id, username, wallet_id, parent_id, is_agent
        FROM c_users 
        WHERE id = ?
    ");
    $stmt->execute([$record['c_user_id']]);
    $cUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$cUser) {
        Response::error('C端用户不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 5. 查询或创建当日统计记录
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
    
    // 6. 开启事务
    $db->beginTransaction();
    
    $reviewedAt = date('Y-m-d H:i:s');
    
    if ($action === 'approve') {
        // ========== 审核通过 ==========
        
        // 7. 更新任务记录状态
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 3, reviewed_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$reviewedAt, $recordId]);
        
        // 8. 更新B端任务统计
        $stmt = $db->prepare("
            UPDATE b_tasks 
            SET task_reviewing = task_reviewing - 1,
                task_done = task_done + 1
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);
        
        // 8.1 检查任务是否全部完成，如果完成则更新状态为"已完成"
        $stmt = $db->prepare("
            SELECT task_count, task_done
            FROM b_tasks 
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);
        $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
            // 任务全部完成，更新状态为已完成(status=2)
            $stmt = $db->prepare("
                UPDATE b_tasks 
                SET status = 2, stage_status = 2, completed_at = ?
                WHERE id = ?
            ");
            $stmt->execute([$reviewedAt, $bTaskId]);
        }
        
        // 8.5 检查组合任务是否需要开放第二阶段
        $stmt = $db->prepare("
            SELECT 
                id, combo_task_id, stage, task_count, task_done
            FROM b_tasks 
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);
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
        
        // 9. 更新当日统计
        $stmt = $db->prepare("
            UPDATE c_user_daily_stats 
            SET approved_count = approved_count + 1 
            WHERE id = ?
        ");
        $stmt->execute([$dailyStatsId]);
        
        // 10. 计算佣金（从模板读取固定金额）
        // 查询b_task获取template_id、stage和unit_price
        $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$bTaskInfo) {
            $db->rollBack();
            Response::error('任务信息不存在', $errorCodes['TASK_NOT_FOUND']);
        }

        // 获取派单单价
        $taskUnitPrice = (float)($bTaskInfo['unit_price'] ?? 0);

        // 检查用户的上级代理中是否有大团团长
        function hasLargeGroupAgent($db, $userId, $maxLevel = 2) {
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

        // 查询模板佣金配置
        $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
        $stmt->execute([$bTaskInfo['template_id']]);
        $template = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$template) {
            $db->rollBack();
            Response::error('任务模板不存在', $errorCodes['TASK_NOT_FOUND']);
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

        // 大团团长佣金计算逻辑
        $userAgentLevel = (int)($cUser['is_agent'] ?? 0);
        if ($userAgentLevel == 3) {
            // 当前用户是大团团长，使用大团佣金比例
            $largeGroupAgentRatio = (float)AppConfig::get('large_group_agent', 0.8);
            $cUserCommission = (int)($taskUnitPrice * $largeGroupAgentRatio * 100); // 转换为分
        }
        
        // 11. 查询C端用户钱包
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$cUser['wallet_id']]);
        $cWallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cWallet) {
            $db->rollBack();
            Response::error('C端用户钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
        }
        
        $cBeforeBalance = (int)$cWallet['balance'];
        $cAfterBalance = $cBeforeBalance + $cUserCommission;
        
        // 12. 更新C端用户钱包
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$cAfterBalance, $cUser['wallet_id']]);
        
        // 13. 记录C端用户钱包流水
        $cRemark = "完成任务获得佣金，任务ID：{$bTaskId}";
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
            $bTaskId,
            $taskType,
            $taskTypeText,
            $cRemark
        ]);
        
        // 14. 检查是否有团长上级
        $agentCommission = 0;
        $agentUserId = null;
        $agentUsername = null;
        $secondAgentCommission = 0;
        $secondAgentUserId = null;
        $secondAgentUsername = null;

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
                // 检查是否有大团团长
                $hasLargeGroupAgent = hasLargeGroupAgent($db, $cUser['id']);
                
                // 大团团长(3)用大团佣金比例，高级团长(2)用senior_agent佣金，普通团长(1)用agent佣金
                if ($parentAgentLevel === 3) {
                    // 一级上级是大团团长，使用大团佣金比例
                    $largeGroupAgentRatio = (float)AppConfig::get('large_group_agent', 0.8);
                    $agentCommission = (int)($taskUnitPrice * $largeGroupAgentRatio * 100); // 转换为分
                } elseif ($parentAgentLevel === 2) {
                    $agentCommission = $seniorAgentCommissionAmount;
                } else {
                    $agentCommission = $agentCommissionAmount;
                }
                $agentUserId = $parentUser['id'];
                $agentUsername = $parentUser['username'];
                
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
                    $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得一级团长佣金，任务ID：{$bTaskId}";
                    $stmt = $db->prepare(" 
                        INSERT INTO wallets_log (
                            wallet_id, user_id, username, user_type, type, 
                            amount, before_balance, after_balance, 
                            related_type, related_id, task_types, task_types_text, remark
                        ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'agent_commission', ?, ?, ?, ?)
                    ");
                    $stmt->execute([
                        $parentUser['wallet_id'],
                        $parentUser['id'],
                        $parentUser['username'],
                        $agentCommission,
                        $agentBeforeBalance,
                        $agentAfterBalance,
                        $bTaskId,
                        $taskType,
                        $taskTypeText,
                        $agentRemark
                    ]);
                }
                
                // 新增：查询二级上级用户
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
                        // 大团团长(3)用大团佣金比例，高级团长(2)用second_senior_agent佣金，普通团长(1)用second_agent佣金
                        if ($secondParentAgentLevel === 3) {
                            // 二级上级是大团团长，使用大团佣金比例
                            $largeGroupAgentRatio = (float)AppConfig::get('large_group_agent', 0.8);
                            $secondAgentCommission = (int)($taskUnitPrice * $largeGroupAgentRatio * 100); // 转换为分
                        } elseif ($secondParentAgentLevel === 2) {
                            $secondAgentCommission = $secondSeniorAgentCommissionAmount;
                        } else {
                            $secondAgentCommission = $secondAgentCommissionAmount;
                        }
                        $secondAgentUserId = $secondParentUser['id'];
                        $secondAgentUsername = $secondParentUser['username'];
                        
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
                            $secondAgentRemark = "下级用户 {$parentUser['username']} 的团队成员完成任务，获得二级团长佣金，任务ID：{$bTaskId}";
                            $stmt = $db->prepare(" 
                                INSERT INTO wallets_log (
                                    wallet_id, user_id, username, user_type, type, 
                                    amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, remark
                                ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, 'second_agent_commission', ?, ?, ?, ?)
                            ");
                            $stmt->execute([
                                $secondParentUser['wallet_id'],
                                $secondParentUser['id'],
                                $secondParentUser['username'],
                                $secondAgentCommission,
                                $secondAgentBeforeBalance,
                                $secondAgentAfterBalance,
                                $bTaskId,
                                $taskType,
                                $taskTypeText,
                                $secondAgentRemark
                            ]);
                        }
                    }
                }
            }
        }
        
        // 15. 提交事务
        $db->commit();
        
        // 16. 返回成功响应
        Response::success([
            'record_id' => (int)$recordId,
            'b_task_id' => (int)$bTaskId,
            'action' => 'approved',
            'c_user_commission' => number_format($cUserCommission / 100, 2),
            'agent_commission' => $agentCommission > 0 ? number_format($agentCommission / 100, 2) : '0.00',
            'agent_user_id' => $agentUserId,
            'agent_username' => $agentUsername,
            // 新增：二级代理佣金信息
            'second_agent_commission' => $secondAgentCommission > 0 ? number_format($secondAgentCommission / 100, 2) : '0.00',
            'second_agent_user_id' => $secondAgentUserId,
            'second_agent_username' => $secondAgentUsername,
            'reviewed_at' => $reviewedAt
        ], '审核通过，佣金已发放');
        
    } else {
        // ========== 审核驳回 ==========
        
        // 7. 更新任务记录状态
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 4, reject_reason = ?, reviewed_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$rejectReason, $reviewedAt, $recordId]);
        
        // 8. 更新B端任务统计（释放名额）
        $stmt = $db->prepare("
            UPDATE b_tasks 
            SET task_reviewing = task_reviewing - 1
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);
        
        // 9. 更新当日统计
        $stmt = $db->prepare("
            UPDATE c_user_daily_stats 
            SET rejected_count = rejected_count + 1 
            WHERE id = ?
        ");
        $stmt->execute([$dailyStatsId]);
        
        // 10. 提交事务
        $db->commit();
        
        // 11. 返回成功响应
        Response::success([
            'record_id' => (int)$recordId,
            'b_task_id' => (int)$bTaskId,
            'action' => 'rejected',
            'reject_reason' => $rejectReason,
            'reviewed_at' => $reviewedAt
        ], '已驳回任务');
    }
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('审核失败', $errorCodes['TASK_REVIEW_FAILED'], 500);
}
