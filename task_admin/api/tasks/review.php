<?php
/**
 * 任务审核接口
 * POST /task_admin/api/tasks/review.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$action = trim($input['action'] ?? '');
$rejectReason = trim($input['reject_reason'] ?? '');

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    echo json_encode(['code' => 1001, 'message' => '任务ID不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($recordId) || !is_numeric($recordId)) {
    echo json_encode(['code' => 1001, 'message' => '任务记录ID不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($action, ['approve', 'reject'])) {
    echo json_encode(['code' => 1002, 'message' => '审核操作无效，必须是 approve 或 reject', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'reject' && empty($rejectReason)) {
    echo json_encode(['code' => 1003, 'message' => '驳回时必须填写驳回原因', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
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
        echo json_encode(['code' => 1004, 'message' => '任务记录不存在或参数不匹配', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 3. 校验任务状态（只能审核待审核状态的任务）
    if ((int)$record['status'] !== 2) {
        $statusTexts = [1 => '进行中', 2 => '待审核', 3 => '已通过', 4 => '已驳回', 5 => '已超时'];
        $currentStatusText = $statusTexts[(int)$record['status']] ?? '未知';
        echo json_encode(['code' => 1005, 'message' => "该任务当前状态为：{$currentStatusText}，无法审核", 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
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
        echo json_encode(['code' => 1006, 'message' => 'C端用户不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
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
        // 查询b_task获取template_id和stage
        $stmt = $db->prepare("SELECT template_id, stage FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$bTaskInfo) {
            $db->rollBack();
            echo json_encode(['code' => 1007, 'message' => '任务信息不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }

        // 查询模板佣金配置
        $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
        $stmt->execute([$bTaskInfo['template_id']]);
        $template = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$template) {
            $db->rollBack();
            echo json_encode(['code' => 1008, 'message' => '任务模板不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
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
        
        // 11. 查询C端用户钱包
        if (empty($cUser['wallet_id'])) {
            $db->rollBack();
            echo json_encode(['code' => 1009, 'message' => 'C端用户钱包不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$cUser['wallet_id']]);
        $cWallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cWallet) {
            $db->rollBack();
            echo json_encode(['code' => 1009, 'message' => 'C端用户钱包不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $cBeforeBalance = (int)$cWallet['balance'];
        $cAfterBalance = $cBeforeBalance + $cUserCommission;
        
        // 12. 更新C端用户钱包
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$cAfterBalance, $cUser['wallet_id']]);
        
        // 13. 记录C端用户钱包流水
        $cRemark = "完成任务获得佣金，任务ID：{$bTaskId}";
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
            $bTaskId,
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
                // 高级团长(2)用senior_agent佣金，普通团长(1)用agent佣金
                if ($parentAgentLevel === 2) {
                    $agentCommission = $seniorAgentCommissionAmount;
                } else {
                    $agentCommission = $agentCommissionAmount;
                }
                $agentUserId = $parentUser['id'];
                $agentUsername = $parentUser['username'];
                
                // 查询团长钱包
                if (!empty($parentUser['wallet_id'])) {
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
                            $bTaskId,
                            $agentRemark
                        ]);
                    }
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
                        // 高级团长(2)用second_senior_agent佣金，普通团长(1)用second_agent佣金
                        if ($secondParentAgentLevel === 2) {
                            $secondAgentCommission = $secondSeniorAgentCommissionAmount;
                        } else {
                            $secondAgentCommission = $secondAgentCommissionAmount;
                        }
                        $secondAgentUserId = $secondParentUser['id'];
                        $secondAgentUsername = $secondParentUser['username'];
                        
                        // 查询二级团长钱包
                        if (!empty($secondParentUser['wallet_id'])) {
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
                                $stmt = $db->prepare(
                                    "INSERT INTO wallets_log (
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
                                    $bTaskId,
                                    $secondAgentRemark
                                ]);
                            }
                        }
                    }
                }
            }
        }
        
        // 15. 提交事务
        $db->commit();
        
        // 16. 返回成功响应
        echo json_encode([
            'code' => 0,
            'message' => '审核通过，佣金已发放',
            'data' => [
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
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        
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
        echo json_encode([
            'code' => 0,
            'message' => '已驳回任务',
            'data' => [
                'record_id' => (int)$recordId,
                'b_task_id' => (int)$bTaskId,
                'action' => 'rejected',
                'reject_reason' => $rejectReason,
                'reviewed_at' => $reviewedAt
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    }
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '审核失败', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}