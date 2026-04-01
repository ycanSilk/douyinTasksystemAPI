<?php
/**
 * B 端任务审核接口
 * 
 * POST /api/b/v1/tasks/review
 * 
 * 请求头：
 * X-Token: <token> (B 端)
 * Content-Type: application/json
 * 
 * 请求体：
 * {
 *   "b_task_id": 123,                          // B 端任务 ID (必填)
 *   "record_id": 456,                          // C 端任务记录 ID (必填)
 *   "action": "approve",                       // 审核操作：approve=通过，reject=驳回 (必填)
 *   "reject_reason": "截图不清晰"              // 驳回原因 (action=reject 时必填)
 * }
 * 
 * 请求示例（审核通过）：
 * {
 *   "b_task_id": 123,
 *   "record_id": 456,
 *   "action": "approve"
 * }
 * 
 * 请求示例（审核驳回）：
 * {
 *   "b_task_id": 123,
 *   "record_id": 456,
 *   "action": "reject",
 *   "reject_reason": "截图不清晰，无法确认任务完成"
 * }
 * 
 * 响应示例（审核通过）：
 * {
 *   "code": 0,
 *   "message": "审核通过，佣金已发放",
 *   "data": {
 *     "record_id": 456,
 *     "b_task_id": 123,
 *     "action": "approved",
 *     "c_user_commission": "1.00",
 *     "agent_commission": "0.50",
 *     "agent_user_id": 789,
 *     "agent_username": "团长用户",
 *     "second_agent_commission": "0.30",
 *     "second_agent_user_id": 790,
 *     "second_agent_username": "高级团长",
 *     "team_revenue": {
 *       "c_user_amount": "1.00",
 *       "agent_amount": "0.50",
 *       "second_agent_amount": "0.30"
 *     },
 *     "reviewed_at": "2026-03-25 10:30:00"
 *   },
 *   "timestamp": 1711267200
 * }
 * 
 * 响应示例（审核驳回）：
 * {
 *   "code": 0,
 *   "message": "已驳回任务",
 *   "data": {
 *     "record_id": 456,
 *     "b_task_id": 123,
 *     "action": "rejected",
 *     "reject_reason": "截图不清晰",
 *     "reviewed_at": "2026-03-25 10:30:00"
 *   },
 *   "timestamp": 1711267200
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 4001,
 *   "message": "任务 ID 不能为空",
 *   "data": [],
 *   "timestamp": 1711267200
 * }
 * 
 * 审核规则：
 * 
 * 通过 (approve)：
 * - c_task_records.status = 3 (approved)
 * - b_tasks.task_reviewing -1, task_done +1
 * - c_user_daily_stats.approved_count +1
 * - 发放佣金给 C 端用户
 * - 如果 C 端用户有团长上级，额外发放佣金给上级
 * - 更新钱包和钱包流水
 * - 记录团队收益统计
 * 
 * 驳回 (reject)：
 * - c_task_records.status = 4 (rejected)
 * - b_tasks.task_reviewing -1（释放名额，任务重新可被接）
 * - c_user_daily_stats.rejected_count +1
 * - 不发放佣金
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4001 - 任务 ID 不能为空
 * 4002 - 任务记录 ID 不能为空
 * 4003 - 审核操作无效
 * 4004 - 驳回原因不能为空
 * 4005 - 任务记录不存在
 * 4006 - 无权审核此任务
 * 4007 - 任务状态无效
 * 4008 - C 端用户不存在
 * 4009 - 任务信息不存在
 * 4010 - 任务模板不存在
 * 4011 - C 端用户钱包不存在
 * 4012 - 用户信息异常
 * 4013 - 钱包不存在
 * 5001 - 数据库错误
 * 5002 - 审核失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/tasks/review');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== B 端任务审核请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

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

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 记录请求参数
$requestLogger->debug('步骤1: 获取请求参数...');
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$action = trim($input['action'] ?? '');
$rejectReason = trim($input['reject_reason'] ?? '');

$requestLogger->debug('请求参数', [
    'b_task_id' => $bTaskId,
    'record_id' => $recordId,
    'action' => $action,
    'has_reject_reason' => !empty($rejectReason),
]);

if ($action === 'reject') {
    $requestLogger->debug('驳回原因', ['reason' => $rejectReason]);
}

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    $requestLogger->warning('参数校验失败：任务 ID 为空', ['b_task_id' => $bTaskId]);
    echo json_encode([
        'code' => 4001,
        'message' => '任务 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($recordId) || !is_numeric($recordId)) {
    $requestLogger->warning('参数校验失败：任务记录 ID 为空', ['record_id' => $recordId]);
    echo json_encode([
        'code' => 4002,
        'message' => '任务记录 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($action, ['approve', 'reject'])) {
    $requestLogger->warning('参数校验失败：审核操作无效', ['action' => $action]);
    echo json_encode([
        'code' => 4003,
        'message' => '审核操作无效，必须是 approve 或 reject',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'reject' && empty($rejectReason)) {
    $requestLogger->warning('参数校验失败：驳回原因为空', ['action' => $action]);
    echo json_encode([
        'code' => 4004,
        'message' => '驳回时必须填写驳回原因',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 1. 查询任务记录
    $requestLogger->debug('步骤1: 查询任务记录，记录ID: ' . $recordId . ', 任务ID: ' . $bTaskId);
    $stmt = $db->prepare("
        SELECT 
            c.id, c.c_user_id, c.b_user_id, c.b_task_id, 
            c.status, c.reward_amount, c.comment_url, c.task_stage, c.task_stage_text
        FROM c_task_records c
        WHERE c.id = ? AND c.b_task_id = ?
    ");
    
    $stmt->execute([$recordId, $bTaskId]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$record) {
        $requestLogger->warning('任务记录不存在或参数不匹配', ['record_id' => $recordId, 'b_task_id' => $bTaskId]);
        echo json_encode([
            'code' => 4005,
            'message' => '任务记录不存在或参数不匹配',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('任务记录查询成功', ['record_id' => $record['id'], 'status' => $record['status']]);
    
    // 2. 校验是否是当前B端用户发布的任务
    $requestLogger->debug('步骤2: 校验是否是当前B端用户发布的任务', [
        'record_b_user_id' => $record['b_user_id'],
        'current_user_id' => $currentUser['user_id']
    ]);
    if ((int)$record['b_user_id'] !== $currentUser['user_id']) {
        $requestLogger->warning('无权审核此任务', [
            'record_b_user_id' => $record['b_user_id'],
            'current_user_id' => $currentUser['user_id']
        ]);
        echo json_encode([
            'code' => 4006,
            'message' => '无权审核此任务',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('校验通过，是当前用户发布的任务');
    
    // 3. 校验任务状态（只能审核待审核状态的任务）
    $requestLogger->debug('步骤3: 校验任务状态，当前状态: ' . $record['status']);
    if ((int)$record['status'] !== 2) {
        $statusTexts = [1 => '进行中', 2 => '待审核', 3 => '已通过', 4 => '已驳回', 5 => '已超时'];
        $currentStatusText = $statusTexts[(int)$record['status']] ?? '未知';
        $requestLogger->warning('任务状态无效', ['current_status' => $currentStatusText]);
        echo json_encode([
            'code' => 4007,
            'message' => "该任务当前状态为：{$currentStatusText}，无法审核",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('任务状态校验通过，状态为待审核');
    
    // 4. 查询C端用户信息
    $requestLogger->debug('步骤4: 查询C端用户信息，用户ID: ' . $record['c_user_id']);
    $stmt = $db->prepare("
        SELECT id, username, wallet_id, parent_id, is_agent
        FROM c_users 
        WHERE id = ?
    ");
    $stmt->execute([$record['c_user_id']]);
    $cUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$cUser) {
        $errorLogger->error('C端用户不存在', ['c_user_id' => $record['c_user_id']]);
        echo json_encode([
            'code' => 4008,
            'message' => 'C端用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('C端用户信息查询成功', ['user_id' => $cUser['id'], 'username' => $cUser['username']]);
    
    // 5. 查询或创建当日统计记录
    $requestLogger->debug('步骤5: 查询或创建当日统计记录，用户ID: ' . $record['c_user_id']);
    $today = date('Y-m-d');
    $stmt = $db->prepare("
        SELECT id 
        FROM c_user_daily_stats 
        WHERE c_user_id = ? AND stat_date = ?
    ");
    $stmt->execute([$record['c_user_id'], $today]);
    $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$dailyStats) {
        $requestLogger->debug('当日统计记录不存在，创建新记录');
        $stmt = $db->prepare("
            INSERT INTO c_user_daily_stats (c_user_id, stat_date)
            VALUES (?, ?)
        ");
        $stmt->execute([$record['c_user_id'], $today]);
        $dailyStatsId = $db->lastInsertId();
        $requestLogger->debug('当日统计记录创建成功', ['id' => $dailyStatsId]);
    } else {
        $dailyStatsId = $dailyStats['id'];
        $requestLogger->debug('当日统计记录已存在', ['id' => $dailyStatsId]);
    }
    
    // 6. 开启事务
    $requestLogger->debug('步骤6: 开启事务');
    $db->beginTransaction();
    $requestLogger->debug('事务开启成功');
    
    $reviewedAt = date('Y-m-d H:i:s');
    
    if ($action === 'approve') {
        // ========== 审核通过 ==========
        $requestLogger->info('开始审核通过处理', ['record_id' => $recordId, 'b_task_id' => $bTaskId]);
        
        // 7. 更新任务记录状态
        $requestLogger->debug('步骤7: 更新任务记录状态为已通过，记录ID: ' . $recordId);
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 3, reviewed_at = ?, update_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$reviewedAt, $reviewedAt, $recordId]);
        $requestLogger->debug('任务记录状态更新成功');
        
        // 8. 更新B端任务统计
        $requestLogger->debug('步骤8: 更新B端任务统计，任务ID: ' . $bTaskId);
        // 先检查当前 task_reviewing 和 task_done 值
        $stmt = $db->prepare("SELECT task_reviewing, task_done FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // 计算新的 task_reviewing 和 task_done 值
        $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
        $newTaskDone = (int)$taskInfo['task_done'] + 1;
        $requestLogger->debug('当前 task_reviewing: ' . $taskInfo['task_reviewing'] . ', 新值：' . $newTaskReviewing);
        $requestLogger->debug('当前 task_done: ' . $taskInfo['task_done'] . ', 新值：' . $newTaskDone);
        
        // 更新任务统计
        $stmt = $db->prepare("
            UPDATE b_tasks 
            SET task_reviewing = ?, task_done = ?
            WHERE id = ?
        ");
        $stmt->execute([$newTaskReviewing, $newTaskDone, $bTaskId]);
        $requestLogger->debug('任务统计更新成功');
        
        // 8.1 检查任务是否全部完成，如果完成则更新状态为"已完成"
        $requestLogger->debug('检查任务是否全部完成');
        $stmt = $db->prepare("
            SELECT task_count, task_done
            FROM b_tasks 
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);
        $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
        $requestLogger->debug('当前任务完成数: ' . $taskProgress['task_done'] . ', 总任务数: ' . $taskProgress['task_count']);
        
        if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
            // 任务全部完成，更新状态为已完成(status=2)
            $requestLogger->debug('任务全部完成，更新状态为已完成');
            $stmt = $db->prepare("
                UPDATE b_tasks 
                SET status = 2, stage_status = 2, completed_at = ?
                WHERE id = ?
            ");
            $stmt->execute([$reviewedAt, $bTaskId]);
            $requestLogger->debug('任务状态更新为已完成');
        } else {
            $requestLogger->debug('任务未全部完成，当前完成: ' . $taskProgress['task_done'] . ', 总任务数: ' . $taskProgress['task_count']);
        }
        
        // 8.5 检查组合任务是否需要开放第二阶段
        $requestLogger->debug('步骤8.5: 检查组合任务是否需要开放第二阶段，任务ID: ' . $bTaskId);
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
            $requestLogger->debug('这是组合任务的第一阶段，combo_task_id: ' . $bTask['combo_task_id']);
            // 检查第一阶段是否全部完成（组合任务阶段1固定为1个任务）
            if ((int)$bTask['task_done'] === (int)$bTask['task_count']) {
                $requestLogger->debug('第一阶段已全部完成，准备开放第二阶段');
                // 第一阶段完成，获取C端用户提交的评论链接作为阶段2的video_url
                $commentUrl = $record['comment_url'] ?? '';
                
                if (!empty($commentUrl)) {
                    $requestLogger->debug('获取到评论链接，开放第二阶段并设置video_url');
                    // 开放第二阶段，并设置video_url为阶段1的评论链接
                    $stmt = $db->prepare("
                        UPDATE b_tasks 
                        SET stage_status = 1, video_url = ?
                        WHERE combo_task_id = ? AND stage = 2
                    ");
                    $stmt->execute([$commentUrl, $bTask['combo_task_id']]);
                    $requestLogger->debug('第二阶段开放成功，已设置video_url');
                } else {
                    $requestLogger->debug('评论链接为空，只开放第二阶段');
                    // 如果评论链接为空，只开放不设置video_url（保持为空）
                    $stmt = $db->prepare("
                        UPDATE b_tasks 
                        SET stage_status = 1 
                        WHERE combo_task_id = ? AND stage = 2
                    ");
                    $stmt->execute([$bTask['combo_task_id']]);
                    $requestLogger->debug('第二阶段开放成功');
                }
            } else {
                $requestLogger->debug('第一阶段未全部完成，当前完成: ' . $bTask['task_done'] . ', 总任务数: ' . $bTask['task_count']);
            }
        } else {
            $requestLogger->debug('不是组合任务的第一阶段，跳过开放第二阶段检查');
        }
        
        // 9. 更新当日统计
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
        $requestLogger->debug('c_user_daily_stats表已更新', ['user_id' => $cUser['id'], 'approved_count' => $newApprovedCount]);
        
        // 10. 计算佣金（从模板读取固定金额）
        // 查询b_task获取template_id、stage和unit_price
        $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$bTaskInfo) {
            $db->rollBack();
            $errorLogger->error('任务信息不存在', ['b_task_id' => $bTaskId]);
            echo json_encode([
                'code' => 4009,
                'message' => '任务信息不存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        // 获取派单单价
        $taskUnitPrice = (float)($bTaskInfo['unit_price'] ?? 0);

        

        // 查询模板佣金配置
        $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
        $stmt->execute([$bTaskInfo['template_id']]);
        $template = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$template) {
            $db->rollBack();
            $errorLogger->error('任务模板不存在', ['template_id' => $bTaskInfo['template_id']]);
            echo json_encode([
                'code' => 4010,
                'message' => '任务模板不存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
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
        
        // 检查完成任务的用户是否是大团团长，如果是，使用任务单价的80%作为佣金
        $userAgentLevel = $cUser['is_agent'] ?? 0;
        if ($userAgentLevel === 3) {
            // 大团团长：任务金额 * 80%
            $largeGroupAgentRate = 0.8;
            // 计算任务金额（单价 * 1），转换为分
            $taskAmount = $taskUnitPrice * 100;
            $cUserCommission = (int)round($taskAmount * $largeGroupAgentRate);
            $requestLogger->debug('大团团长佣金计算', ['user_id' => $cUser['id'], 'username' => $cUser['username'], 'task_unit_price' => $taskUnitPrice, 'commission' => $cUserCommission]);
        }


        
        // 11. 查询C端用户钱包
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$cUser['wallet_id']]);
        $cWallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cWallet) {
            $db->rollBack();
            $errorLogger->error('C端用户钱包不存在', ['c_user_id' => $cUser['id'], 'wallet_id' => $cUser['wallet_id']]);
            echo json_encode([
                'code' => 4011,
                'message' => 'C端用户钱包不存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $cBeforeBalance = (int)$cWallet['balance'];
        $cAfterBalance = $cBeforeBalance + $cUserCommission;
        
        // 12. 更新C端用户钱包
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$cAfterBalance, $cUser['wallet_id']]);
        
        // 13. 记录 C 端用户钱包流水
        $cRemark = "完成任务获得佣金，任务 ID：{$bTaskId}";
        // 根据任务模板获取任务类型信息
        $taskType = 0;
        $taskTypeText = $template['title'] ?? '';
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, task_types, task_types_text, remark
            ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, '任务奖励佣金', ?, ?, ?, ?)
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
        
        // 13.1 记录 C 端任务统计
        try {
            // 优化 remark 字段
            $userAgentType = '普通用户';
            $userAgentLevel = $cUser['is_agent'] ?? 0;
            if ($userAgentLevel === 1) {
                $userAgentType = '普通团长';
            } elseif ($userAgentLevel === 2) {
                $userAgentType = '高级团长';
            } elseif ($userAgentLevel === 3) {
                $userAgentType = '大团团长';
            }
            $cRemark = "当前用户{$cUser['username']}是（{$userAgentType}）：  完成任务，获得任务佣金，任务 ID：{$bTaskId}，任务类型：{$taskTypeText}，任务阶段{$stage}：{$record['task_stage_text']}，任务单价：{$taskUnitPrice}元，获得奖励：" . ($cUserCommission / 100) . "元";
            
            // 获取任务阶段文本
            $taskStageText = '';
            if ($template) {
                if ($stage === 0) {
                    $taskStageText = $template['description1'] ?? '';
                } elseif ($stage === 1) {
                    $taskStageText = $template['stage1_title'] ?? '';
                } elseif ($stage === 2) {
                    $taskStageText = $template['stage2_title'] ?? '';
                }
            }
            
            $stmt = $db->prepare("
                INSERT INTO c_task_statistics (
                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                    related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                    record_status, record_status_text, remark
                ) VALUES (?, ?, 1, ?, ?, ?, '任务佣金', ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $cUser['id'],
                $cUser['username'],
                $cUserCommission,
                $cBeforeBalance,
                $cAfterBalance,
                $bTaskId,
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
        }
        
        // 14. 检查是否有团长上级，向上查找直到找到大团团长或达到最大层级
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
            
            
            // 记录当前代理等级
            $agentLevel = $user['is_agent'] ?? 0;
            if ($level === 0) {
                // 一级代理
                $agentUserId = $user['id'];
                $agentUsername = $user['username'];
                
                // 只有团长或以上等级才发放佣金
                if ($agentLevel > 0) {
                    // 根据代理等级计算佣金
                    if ($agentLevel === 1) {
                        // 普通团长
                        $agentCommission = $agentCommissionAmount;
                    } elseif ($agentLevel === 2) {
                        // 高级团长
                        $agentCommission = $seniorAgentCommissionAmount;
                    } elseif ($agentLevel === 3) {
                        // 大团团长：任务金额 * large_group_agent配置值
                        $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = ?");
                        $stmt->execute(['large_group_agent']);
                        $config = $stmt->fetch(PDO::FETCH_ASSOC);
                        $largeGroupAgentRate = $config ? (float)$config['config_value'] : 0.8;
                        
                        // 计算任务金额（单价 * 1）
                        $taskAmount = $taskUnitPrice * 100; // 转换为分
                        $agentCommission = (int)round($taskAmount * $largeGroupAgentRate);
                    } else {
                        // 其他等级，使用默认佣金
                        $agentCommission = $agentCommissionAmount;
                    }
                        
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
                                $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得大团团长佣金，任务ID：{$bTaskId}";
                            } elseif ($agentLevel === 2) {
                                // 高级团长佣金记录
                                $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得高级团长佣金，任务ID：{$bTaskId}";
                            } elseif ($agentLevel === 1) {
                                // 普通团长佣金记录
                                $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得普通团长佣金，任务ID：{$bTaskId}";
                            }
                            $stmt = $db->prepare("
                                INSERT INTO wallets_log (
                                    wallet_id, user_id, username, user_type, type, 
                                    amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, remark
                                ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, '一级代理佣金奖励', ?, ?, ?, ?)
                            ");
                            $stmt->execute([
                                $user['wallet_id'],
                                $user['id'],
                                $user['username'],
                                $agentCommission,
                                $agentBeforeBalance,
                                $agentAfterBalance,
                                $bTaskId,
                                $taskType,
                                $taskTypeText,
                                $agentRemark
                            ]);
                            
                            // 优化 remark 字段
                            $agentType = '普通用户';
                            if ($agentLevel === 1) {
                                $agentType = '普通团长';
                            } elseif ($agentLevel === 2) {
                                $agentType = '高级团长';
                            } elseif ($agentLevel === 3) {
                                $agentType = '大团团长';
                            }
                            $agentRemark = "当前用户： {$user['username']},用户等级是{$agentType}； 当前用户的邀请用户:{$cUser['username']},完成任务，获得一级团长佣金，任务 ID：{$bTaskId}，任务类型：{$taskTypeText}，当前任务阶段：{$stage}：{$record['task_stage_text']}，任务单价：{$taskUnitPrice}元，完成任务用户：{$cUser['username']}，用户获得奖励：" . ($cUserCommission / 100) . "元";
                            
                            // 记录一级代理 C 端任务统计
                            try {
                                // 只给团长级别以上的代理用户（is_agent >= 1）插入任务统计记录
                                if ($agentLevel >= 1) {
                                    // 获取任务阶段文本
                                    $taskStageText = '';
                                    if ($template) {
                                        if ($stage === 0) {
                                            $taskStageText = $template['description1'] ?? '';
                                        } elseif ($stage === 1) {
                                            $taskStageText = $template['stage1_title'] ?? '';
                                        } elseif ($stage === 2) {
                                            $taskStageText = $template['stage2_title'] ?? '';
                                        }
                                    }
                                    
                                    $stmt = $db->prepare("
                                        INSERT INTO c_task_statistics (
                                            c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                            related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                                            record_status, record_status_text, remark
                                        ) VALUES (?, ?, 1, ?, ?, ?, '一级代理佣金', ?, ?, ?, ?, ?, ?, ?, ?)
                                    ");
                                    $stmt->execute([
                                        $user['id'],
                                        $user['username'],
                                        $agentCommission,
                                        $agentBeforeBalance,
                                        $agentAfterBalance,
                                        $bTaskId,
                                        $taskType,
                                        $taskTypeText,
                                        $stage,
                                        $taskStageText,
                                        3, // record_status: 3
                                        '一级代理佣金', // record_status_text
                                        $agentRemark
                                    ]);
                                }
                            } catch (Exception $e) {
                                // 记录插入失败时的错误日志，但不影响主流程

                            }
                        }
                    }
            } elseif ($level === 1) {
                // 二级代理
                $secondAgentUserId = $user['id'];
                $secondAgentUsername = $user['username'];
                
                // 只有团长或以上等级才发放佣金
                if ($agentLevel > 0) {
                    // 根据代理等级计算佣金
                    if ($agentLevel === 1) {
                        // 普通团长
                        $secondAgentCommission = $agentCommissionAmount;
                    } elseif ($agentLevel === 2) {
                        // 高级团长
                        $secondAgentCommission = $seniorAgentCommissionAmount;
                    } elseif ($agentLevel === 3) {
                        // 大团团长：任务金额 * large_group_agent配置值
                        $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = ?");
                        $stmt->execute(['large_group_agent']);
                        $config = $stmt->fetch(PDO::FETCH_ASSOC);
                        $largeGroupAgentRate = $config ? (float)$config['config_value'] : 0.8;
                        
                        // 计算任务金额（单价 * 1）
                        $taskAmount = $taskUnitPrice * 100; // 转换为分
                        $secondAgentCommission = (int)round($taskAmount * $largeGroupAgentRate);
                    } else {
                        // 其他等级，使用默认佣金
                        $secondAgentCommission = $seniorAgentCommissionAmount;
                    }
                        
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
                                $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级大团团长佣金，任务ID：{$bTaskId}";
                            } elseif ($agentLevel === 2) {
                                $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级高级团长佣金，任务ID：{$bTaskId}";
                            } elseif ($agentLevel === 1) {
                                $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级普通团长佣金，任务ID：{$bTaskId}";
                            }
                            $stmt = $db->prepare("
                                INSERT INTO wallets_log (
                                    wallet_id, user_id, username, user_type, type, 
                                    amount, before_balance, after_balance, 
                                    related_type, related_id, task_types, task_types_text, remark
                                ) VALUES (?, ?, ?, 1, 1, ?, ?, ?, '二级代理佣金奖励', ?, ?, ?, ?)
                            ");
                            $stmt->execute([
                                $user['wallet_id'],
                                $user['id'],
                                $user['username'],
                                $secondAgentCommission,
                                $secondAgentBeforeBalance,
                                $secondAgentAfterBalance,
                                $bTaskId,
                                $taskType,
                                $taskTypeText,
                                $secondAgentRemark
                            ]);
                            
                            // 优化 remark 字段
                            $secondAgentType = '普通用户';
                            if ($agentLevel === 1) {
                                $secondAgentType = '普通团长';
                            } elseif ($agentLevel === 2) {
                                $secondAgentType = '高级团长';
                            } elseif ($agentLevel === 3) {
                                $secondAgentType = '大团团长';
                            }
                            $secondAgentRemark = "当前用户 {$user['username']} 的邀请用户的团队成员完成任务，{$secondAgentType}获得二级团长佣金，任务 ID：{$bTaskId}，任务类型：{$taskTypeText}，任务阶段：{$record['task_stage_text']}，任务单价：{$taskUnitPrice}元，完成任务用户：{$cUser['username']}，用户获得奖励：" . ($cUserCommission / 100) . "元";
                            
                            // 记录二级代理 C 端任务统计
                            try {
                                // 只给团长级别以上的代理用户（is_agent >= 1）插入任务统计记录
                                if ($agentLevel >= 1) {
                                    // 获取任务阶段文本
                                    $taskStageText = '';
                                    if ($template) {
                                        if ($stage === 0) {
                                            $taskStageText = $template['description1'] ?? '';
                                        } elseif ($stage === 1) {
                                            $taskStageText = $template['stage1_title'] ?? '';
                                        } elseif ($stage === 2) {
                                            $taskStageText = $template['stage2_title'] ?? '';
                                        }
                                    }
                                    
                                    $stmt = $db->prepare("
                                        INSERT INTO c_task_statistics (
                                            c_user_id, username, flow_type, amount, before_balance, after_balance, 
                                            related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                                            record_status, record_status_text, remark
                                        ) VALUES (?, ?, 1, ?, ?, ?, '二级代理佣金', ?, ?, ?, ?, ?, ?, ?, ?)
                                    ");
                                    $stmt->execute([
                                        $user['id'],
                                        $user['username'],
                                        $secondAgentCommission,
                                        $secondAgentBeforeBalance,
                                        $secondAgentAfterBalance,
                                        $bTaskId,
                                        $taskType,
                                        $taskTypeText,
                                        $stage,
                                        $taskStageText,
                                        3, // record_status: 3
                                        '二级代理佣金', // record_status_text
                                        $secondAgentRemark
                                    ]);
                                }
                            } catch (Exception $e) {
                                // 记录插入失败时的错误日志，但不影响主流程

                            }
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
            
            $requestLogger->debug('开始记录团队收益统计', ['c_user_id' => $cUser['id'], 'first_agent_id' => $currentUserId]);
            
            while (!empty($currentUserId) && $level < $maxLevel) {
                $requestLogger->debug('团队收益统计循环开始', ['level' => $level, 'current_user_id' => $currentUserId]);
                
                $stmt = $db->prepare("SELECT id, username, is_agent FROM c_users WHERE id = ?");
                $stmt->execute([$currentUserId]);
                $agentUser = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$agentUser) {
                    $requestLogger->debug('未找到代理用户', ['current_user_id' => $currentUserId]);
                    break;
                }
                
                // 只给团长级别以上的代理用户（is_agent >= 1）插入团队收益统计记录
                if ($agentUser['is_agent'] < 1) {
                    $requestLogger->debug('用户不是代理，跳过团队收益统计', ['user_id' => $agentUser['id']]);
                    // 继续向上查找
                    $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                    $stmt->execute([$agentUser['id']]);
                    $nextParent = $stmt->fetch(PDO::FETCH_ASSOC);
                    $currentUserId = $nextParent['parent_id'] ?? null;
                    $requestLogger->debug('继续向上查找', ['next_agent_id' => $currentUserId]);
                    $level++;
                    continue;
                }
                
                $requestLogger->debug('找到代理用户', [
                    'agent_id' => $agentUser['id'],
                    'agent_username' => $agentUser['username'],
                    'level' => $level,
                    'is_agent' => $agentUser['is_agent']
                ]);
                
                // 团队收益金额与完成任务用户获得的佣金金额相同
                $agentCommAmount = $cUserCommission;
                
                // 查询当前代理的团队收益汇总记录，获取当前收益总额
                $stmt = $db->prepare("SELECT total_team_revenue FROM team_revenue_statistics_summary WHERE user_id = ?");
                $stmt->execute([$agentUser['id']]);
                $summary = $stmt->fetch(PDO::FETCH_ASSOC);
                
                $agentBeforeAmount = $summary ? (float)$summary['total_team_revenue'] : 0;
                $agentAfterAmount = $agentBeforeAmount + $agentCommAmount;
                
                // 获取任务阶段文本
                $taskStageText = '';
                if ($template) {
                    if ($stage === 0) {
                        $taskStageText = $template['description1'] ?? '';
                    } elseif ($stage === 1) {
                        $taskStageText = $template['stage1_title'] ?? '';
                    } elseif ($stage === 2) {
                        $taskStageText = $template['stage2_title'] ?? '';
                    }
                }
                
                // 插入团队收益记录
                $requestLogger->debug('准备插入团队收益记录', [
                    'agent_id' => $agentUser['id'],
                    'level' => $level + 1,
                    'amount' => $agentCommAmount
                ]);
                
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
                    $bTaskId,
                    1, // 收益来源：1=任务收益
                    '任务收益',
                    $taskType,
                    $taskTypeText,
                    $stage,
                    $taskStageText
                ]);
                
                $requestLogger->debug('插入团队收益记录结果', [
                    'result' => $result ? '成功' : '失败',
                    'agent_id' => $agentUser['id']
                ]);
                
                // 更新团队收益汇总表
                // 先查询是否存在记录
                $stmt = $db->prepare("SELECT id FROM team_revenue_statistics_summary WHERE user_id = ?");
                $stmt->execute([$agentUser['id']]);
                $exists = $stmt->fetch(PDO::FETCH_ASSOC);
                
                $revenueSource = 1; // 任务收益
                $agentLevel = $level + 1;
                $currentTime = date('Y-m-d H:i:s');
                
                $requestLogger->debug('准备更新团队收益汇总表', [
                    'agent_id' => $agentUser['id'],
                    'level' => $agentLevel,
                    'amount' => $agentCommAmount
                ]);
                
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
                
                $requestLogger->debug('更新团队收益汇总表结果', [
                    'result' => $result ? '成功' : '失败',
                    'agent_id' => $agentUser['id']
                ]);
                
                // 继续向上查找
                $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
                $stmt->execute([$agentUser['id']]);
                $nextParent = $stmt->fetch(PDO::FETCH_ASSOC);
                $currentUserId = $nextParent['parent_id'] ?? null;
                $requestLogger->debug('继续向上查找', ['next_agent_id' => $currentUserId]);
                $level++;
            }
            
            $requestLogger->debug('团队收益统计循环结束');
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            $errorLogger->error('插入team_revenue_statistics_breakdown失败', ['exception' => $e->getMessage()]);
        }

        // 15. 更新用户任务统计
        // 审核通过时增加完成任务数量计数
        // 先查询是否存在记录
        $requestLogger->debug('步骤15: 查询 c_user_task_records_static 表是否存在用户记录', ['user_id' => $cUser['id']]);
        $stmt = $db->prepare("SELECT id FROM c_user_task_records_static WHERE user_id = ?");
        $stmt->execute([$cUser['id']]);
        $existingRecord = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existingRecord) {
            // 存在记录，更新
            $requestLogger->debug('存在记录，更新 completed_task_count', ['user_id' => $cUser['id']]);
            $stmt = $db->prepare("UPDATE c_user_task_records_static SET completed_task_count = completed_task_count + 1 WHERE user_id = ?");
            $stmt->execute([$cUser['id']]);
            $requestLogger->debug('更新 completed_task_count 成功', ['user_id' => $cUser['id']]);
        } else {
            // 不存在记录，插入
            $requestLogger->debug('不存在记录，插入新记录', ['user_id' => $cUser['id']]);
            $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, completed_task_count) VALUES (?, 1)");
            $stmt->execute([$cUser['id']]);
            $requestLogger->debug('插入新记录成功', ['user_id' => $cUser['id']]);
        }
        
        // 查询更新后的完成任务数量
        $stmt = $db->prepare("SELECT completed_task_count FROM c_user_task_records_static WHERE user_id = ?");
        $stmt->execute([$cUser['id']]);
        $updatedStatic = $stmt->fetch(PDO::FETCH_ASSOC);
        $completedCount = $updatedStatic ? (int)$updatedStatic['completed_task_count'] : 0;
        
        $requestLogger->debug('c_user_task_records_static表已更新', ['user_id' => $cUser['id'], 'completed_task_count' => $completedCount]);
        $requestLogger->debug('审核通过，增加完成任务数量计数');

        // 16. 提交事务
        $db->commit();
        
        // 记录审计日志
        $auditLogger->notice('B 端任务审核通过', [
            'b_user_id' => $currentUser['user_id'],
            'c_user_id' => $cUser['id'],
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'c_user_commission' => $cUserCommission,
            'agent_commission' => $agentCommission,
        ]);
        
        $requestLogger->info('审核通过处理完成', [
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'c_user_commission' => $cUserCommission,
        ]);
        
        // 17. 返回成功响应
        echo json_encode([
            'code' => 0,
            'message' => '审核通过，佣金已发放',
            'data' => [
                'record_id' => (int)$recordId,
                'b_task_id' => (int)$bTaskId,
                'action' => 'approved',
                'c_user_commission' => number_format($cUserCommission / 100, 2),
                'agent_commission' => $agentCommission > 0 ? number_format($agentCommission / 100, 2) : '0.00',
                'agent_user_id' => $agentUserId ?? null,
                'agent_username' => $agentUsername ?? null,
                // 新增：二级代理佣金信息
                'second_agent_commission' => $secondAgentCommission > 0 ? number_format($secondAgentCommission / 100, 2) : '0.00',
                'second_agent_user_id' => $secondAgentUserId ?? null,
                'second_agent_username' => $secondAgentUsername ?? null,
                // 新增：团队收益统计信息
                'team_revenue' => [
                    'c_user_amount' => number_format($cUserCommission / 100, 2),
                    'agent_amount' => $agentUserId ? number_format($cUserCommission / 100, 2) : '0.00',
                    'second_agent_amount' => $secondAgentUserId ? number_format($cUserCommission / 100, 2) : '0.00'
                ],
                'reviewed_at' => $reviewedAt
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        
    }else{
        // ========== 审核驳回 ==========
        $requestLogger->info('开始审核驳回处理', ['record_id' => $recordId, 'b_task_id' => $bTaskId, 'reject_reason' => $rejectReason]);
        
        // 7. 更新任务记录状态
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 4, reject_reason = ?, reviewed_at = ?, update_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$rejectReason, $reviewedAt, $reviewedAt, $recordId]);
        $requestLogger->debug('c_task_records表任务记录状态已更新', ['record_id' => $recordId, 'reject_reason' => $rejectReason, 'reviewed_at' => $reviewedAt]);
        
        // 8. 更新B端任务统计（释放名额）
        // 先检查当前task_reviewing值
        $stmt = $db->prepare("SELECT task_reviewing FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // 计算新的task_reviewing值
        $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
        
        // 更新任务统计
        $stmt = $db->prepare("
            UPDATE b_tasks 
            SET task_reviewing = ?
            WHERE id = ?
        ");
        $stmt->execute([$newTaskReviewing, $bTaskId]);
        $requestLogger->debug('b_tasks表任务统计已更新', ['task_id' => $bTaskId, 'new_task_reviewing' => $newTaskReviewing]);
        
        // 9. 更新当日统计
        // 先查询当前的驳回次数
        $stmt = $db->prepare("SELECT rejected_count FROM c_user_daily_stats WHERE id = ?");
        $stmt->execute([$dailyStatsId]);
        $currentStats = $stmt->fetch(PDO::FETCH_ASSOC);
        $currentRejectedCount = $currentStats ? (int)$currentStats['rejected_count'] : 0;
        
        // 计算新的驳回次数
        $newRejectedCount = $currentRejectedCount + 1;
        
        // 更新驳回次数
        $stmt = $db->prepare("
            UPDATE c_user_daily_stats 
            SET rejected_count = ? 
            WHERE id = ?
        ");
        $stmt->execute([$newRejectedCount, $dailyStatsId]);
        
        $requestLogger->debug('c_user_daily_stats表当日统计已更新', ['task_id' => $bTaskId, 'rejected_count' => $newRejectedCount]);
        
        // 10. 记录 C 端任务统计（审核驳回）
        try {
            // 查询 b_task 获取 template_id、stage 和 unit_price
            $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

            $taskType = 0;
            $taskTypeText = '';
            $taskStageText = '';
            $stage = 0;

            if ($bTaskInfo) {
                $stage = (int)$bTaskInfo['stage'];
                // 查询模板信息
                $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
                $stmt->execute([$bTaskInfo['template_id']]);
                $template = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($template) {
                    // 从模板获取任务类型文本
                    $taskTypeText = $template['title'] ?? '';

                    // 获取任务阶段文本
                    if ($stage === 0) {
                        $taskStageText = $template['description1'] ?? '';
                    } elseif ($stage === 1) {
                        $taskStageText = $template['stage1_title'] ?? '';
                    } elseif ($stage === 2) {
                        $taskStageText = $template['stage2_title'] ?? '';
                    }
                }
            }

            $cRemark = "用户 {$cUser['username']} 任务被驳回，任务 ID：{$bTaskId}，驳回原因：{$rejectReason}";
            
            $stmt = $db->prepare("
                INSERT INTO c_task_statistics (
                    c_user_id, username, flow_type, amount, before_balance, after_balance, 
                    related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                    record_status, record_status_text, remark
                ) VALUES (?, ?, 0, 0, 0, 0, '任务佣金', ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $cUser['id'],
                $cUser['username'],
                $bTaskId,
                $taskType,
                $taskTypeText,
                $stage,
                $taskStageText,
                6, // record_status: 审核拒绝=6
                '审核拒绝', // record_status_text
                $cRemark
            ]);
            $requestLogger->debug('c_task_statistics 表任务统计已记录', [
                'task_id' => $bTaskId, 
                'task_type' => $taskTypeText, 
                'task_stage' => $taskStageText, 
                'reject_reason' => $rejectReason,
                'c_user' => $cUser['username'],
                'c_user_id' => $cUser['id']
            ]);
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            $errorLogger->error('插入 c_task_statistics 失败', ['exception' => $e->getMessage()]);
        }

        // 11. 更新用户任务统计（驳回任务时增加驳回任务数量计数）
        // 先查询是否存在记录
        $requestLogger->debug('步骤11: 查询 c_user_task_records_static 表是否存在用户记录，用户ID: ' . $cUser['id']);
        $stmt = $db->prepare("SELECT id FROM c_user_task_records_static WHERE user_id = ?");
        $stmt->execute([$cUser['id']]);
        $existingRecord = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existingRecord) {
            // 存在记录，更新
            $requestLogger->debug('存在记录，更新 rejected_task_count，用户ID: ' . $cUser['id']);
            $stmt = $db->prepare("UPDATE c_user_task_records_static SET rejected_task_count = rejected_task_count + 1 WHERE user_id = ?");
            $stmt->execute([$cUser['id']]);
            $requestLogger->debug('更新 rejected_task_count 成功，用户ID: ' . $cUser['id']);
        } else {
            // 不存在记录，插入
            $requestLogger->debug('不存在记录，插入新记录，用户ID: ' . $cUser['id']);
            $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, rejected_task_count) VALUES (?, 1)");
            $stmt->execute([$cUser['id']]);
            $requestLogger->debug('插入新记录成功，用户ID: ' . $cUser['id']);
        }
        
        // 查询更新后的驳回任务数量
        $stmt = $db->prepare("SELECT rejected_task_count FROM c_user_task_records_static WHERE user_id = ?");
        $stmt->execute([$cUser['id']]);
        $updatedStatic = $stmt->fetch(PDO::FETCH_ASSOC);
        $rejectedCount = $updatedStatic ? (int)$updatedStatic['rejected_task_count'] : 0;
        
        $requestLogger->debug('c_user_task_records_static表已更新', ['user_id' => $cUser['id'], 'rejected_task_count' => $rejectedCount]);

        // 12. 提交事务
        $db->commit();
        
        // 记录审计日志
        $auditLogger->notice('B 端任务审核驳回', [
            'b_user_id' => $currentUser['user_id'],
            'c_user_id' => $cUser['id'],
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'reject_reason' => $rejectReason,
        ]);
        
        $requestLogger->info('审核驳回处理完成', [
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'reject_reason' => $rejectReason,
        ]);
        
        // 13. 返回成功响应
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
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('任务审核失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    echo json_encode([
        'code' => 5002,
        'message' => '审核失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('任务审核失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    echo json_encode([
        'code' => 5002,
        'message' => '审核失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
