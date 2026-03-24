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
 *     "newbie_info": {
 *       "is_newbie": true,
 *       "completed_tasks": 5,
 *       "is_promoted": true
 *     },
 *     "reviewed_at": "2026-03-23 10:30:00"
 *   }
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
 *     "reviewed_at": "2026-03-23 10:30:00"
 *   }
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 4001,
 *   "message": "任务 ID 不能为空",
 *   "data": []
 * }
 * 
 * 审核规则：
 * 
 * 通过 (approve)：
 * - c_task_records.status = 3 (approved)
 * - b_tasks.task_reviewing -1, task_done +1
 * - c_user_daily_stats.approved_count +1
 * - 发放佣金给 C 端用户（单价 * 57%）
 * - 如果 C 端用户有团长上级，额外发放（单价 * 8%）给上级
 * - 更新钱包和钱包流水
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

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 记录请求体
try {
    $rawInput = file_get_contents('php://input');
    $requestLogger->debug('请求体内容', ['body' => $rawInput]);
} catch (Exception $e) {
    $errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()]);
    $rawInput = '';
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

// 获取请求参数
$input = json_decode($rawInput, true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$action = trim($input['action'] ?? '');
$rejectReason = trim($input['reject_reason'] ?? '');

// 记录请求参数
$requestLogger->debug('请求参数', [
    'b_task_id' => $bTaskId,
    'record_id' => $recordId,
    'action' => $action,
    'has_reject_reason' => !empty($rejectReason),
]);

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

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
    echo json_encode([
        'code' => 5001,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Token 认证（必须是 B 端用户）
try {
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateB();
    $requestLogger->debug('Token 认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);
    echo json_encode([
        'code' => 4012,
        'message' => '用户认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 查询 C 端用户的上级代理中是否有大团团长
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

try {
    // 1. 查询任务记录
    $requestLogger->debug('查询任务记录', ['record_id' => $recordId, 'b_task_id' => $bTaskId]);
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
    
    // 2. 校验是否是当前 B 端用户发布的任务
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
    
    // 3. 校验任务状态（只能审核待审核状态的任务）
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
    
    // 4. 查询 C 端用户信息
    $stmt = $db->prepare("
        SELECT id, username, wallet_id, parent_id, is_agent
        FROM c_users 
        WHERE id = ?
    ");
    $stmt->execute([$record['c_user_id']]);
    $cUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$cUser) {
        $errorLogger->error('C 端用户不存在', ['c_user_id' => $record['c_user_id']]);
        echo json_encode([
            'code' => 4008,
            'message' => 'C 端用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
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
        $requestLogger->info('开始审核通过处理', ['record_id' => $recordId, 'b_task_id' => $bTaskId]);
        
        // 7. 更新任务记录状态
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 3, reviewed_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$reviewedAt, $recordId]);
        
        // 8. 更新 B 端任务统计
        $stmt = $db->prepare("SELECT id FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $isNormalTask = $stmt->fetch(PDO::FETCH_ASSOC) !== false;
        
        if ($isNormalTask) {
            // 更新普通任务统计
            $stmt = $db->prepare("SELECT task_reviewing, task_done FROM b_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
            $newTaskDone = (int)$taskInfo['task_done'] + 1;
            
            $stmt = $db->prepare("
                UPDATE b_tasks 
                SET task_reviewing = ?, task_done = ?
                WHERE id = ?
            ");
            $stmt->execute([$newTaskReviewing, $newTaskDone, $bTaskId]);
            
            // 8.1 检查任务是否全部完成
            $stmt = $db->prepare("
                SELECT task_count, task_done
                FROM b_tasks 
                WHERE id = ?
            ");
            $stmt->execute([$bTaskId]);
            $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
                $stmt = $db->prepare("
                    UPDATE b_tasks 
                    SET status = 2, stage_status = 2, completed_at = ?
                    WHERE id = ?
                ");
                $stmt->execute([$reviewedAt, $bTaskId]);
            }
        } else {
            // 更新新手任务统计
            $stmt = $db->prepare("SELECT task_reviewing FROM b_newbie_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
            
            $stmt = $db->prepare("
                UPDATE b_newbie_tasks 
                SET task_reviewing = ?, task_done = task_done + 1
                WHERE id = ?
            ");
            $stmt->execute([$newTaskReviewing, $bTaskId]);
            
            // 8.1 检查任务是否全部完成
            $stmt = $db->prepare("
                SELECT task_count, task_done
                FROM b_newbie_tasks 
                WHERE id = ?
            ");
            $stmt->execute([$bTaskId]);
            $taskProgress = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($taskProgress && (int)$taskProgress['task_done'] >= (int)$taskProgress['task_count']) {
                $stmt = $db->prepare("
                    UPDATE b_newbie_tasks 
                    SET status = 2, stage_status = 2, completed_at = ?
                    WHERE id = ?
                ");
                $stmt->execute([$reviewedAt, $bTaskId]);
            }
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
            if ((int)$bTask['task_done'] === (int)$bTask['task_count']) {
                $commentUrl = $record['comment_url'] ?? '';
                
                if (!empty($commentUrl)) {
                    $stmt = $db->prepare("
                        UPDATE b_tasks 
                        SET stage_status = 1, video_url = ?
                        WHERE combo_task_id = ? AND stage = 2
                    ");
                    $stmt->execute([$commentUrl, $bTask['combo_task_id']]);
                } else {
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
        $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$bTaskInfo) {
            $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_newbie_tasks WHERE id = ?");
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
        }

        $taskUnitPrice = (float)($bTaskInfo['unit_price'] ?? 0);

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

        $stage = (int)$bTaskInfo['stage'];
        if ($stage === 1) {
            $cUserCommission = (int)($template['stage1_c_user_commission'] ?? 0);
            $agentCommissionAmount = (int)($template['stage1_agent_commission'] ?? 0);
            $seniorAgentCommissionAmount = (int)($template['stage1_senior_agent_commission'] ?? 0);
            $secondAgentCommissionAmount = $agentCommissionAmount;
            $secondSeniorAgentCommissionAmount = $seniorAgentCommissionAmount;
        } elseif ($stage === 2) {
            $cUserCommission = (int)($template['stage2_c_user_commission'] ?? 0);
            $agentCommissionAmount = (int)($template['stage2_agent_commission'] ?? 0);
            $seniorAgentCommissionAmount = (int)($template['stage2_senior_agent_commission'] ?? 0);
            $secondAgentCommissionAmount = $agentCommissionAmount;
            $secondSeniorAgentCommissionAmount = $seniorAgentCommissionAmount;
        } else {
            $cUserCommission = (int)($template['c_user_commission'] ?? 0);
            $agentCommissionAmount = (int)($template['agent_commission'] ?? 0);
            $seniorAgentCommissionAmount = (int)($template['senior_agent_commission'] ?? 0);
            $secondAgentCommissionAmount = $agentCommissionAmount;
            $secondSeniorAgentCommissionAmount = $seniorAgentCommissionAmount;
        }

        // 11. 查询 C 端用户钱包
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$cUser['wallet_id']]);
        $cWallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$cWallet) {
            $db->rollBack();
            $errorLogger->error('C 端用户钱包不存在', ['wallet_id' => $cUser['wallet_id']]);
            echo json_encode([
                'code' => 4011,
                'message' => 'C 端用户钱包不存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $cBeforeBalance = (int)$cWallet['balance'];
        $cAfterBalance = $cBeforeBalance + $cUserCommission;
        
        // 12. 更新 C 端用户钱包
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$cAfterBalance, $cUser['wallet_id']]);
        
        // 13. 记录 C 端用户钱包流水
        $cRemark = "完成任务获得佣金，任务 ID：{$bTaskId}";
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
                    $taskTypeText = '上中评快捷派单';
                    break;
                case 6:
                    $taskType = 6;
                    $taskTypeText = '中下评快捷派单';
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
        
        // 14. 检查是否有团长上级，向上查找直到找到大团团长或达到最大层级
        $agentCommission = 0;
        $agentUserId = null;
        $agentUsername = null;
        $secondAgentCommission = 0;
        $secondAgentUserId = null;
        $secondAgentUsername = null;
        
        $agentBeforeBalance = 0;
        $agentAfterBalance = 0;
        $secondAgentBeforeBalance = 0;
        $secondAgentAfterBalance = 0;

        $currentUserId = $cUser['parent_id'];
        $level = 0;
        $maxLevel = 2;
        
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
            
            $agentLevel = $user['is_agent'] ?? 0;
            if ($level === 0) {
                $agentUserId = $user['id'];
                $agentUsername = $user['username'];
                
                if ($agentLevel > 0) {
                    if ($agentLevel === 1) {
                        $agentCommission = $agentCommissionAmount;
                    } elseif ($agentLevel === 2) {
                        $agentCommission = $seniorAgentCommissionAmount;
                    } elseif ($agentLevel === 3) {
                        $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = ?");
                        $stmt->execute(['large_group_agent']);
                        $config = $stmt->fetch(PDO::FETCH_ASSOC);
                        $largeGroupAgentRate = $config ? (float)$config['config_value'] : 0.8;
                        $taskAmount = $taskUnitPrice * 100;
                        $agentCommission = (int)round($taskAmount * $largeGroupAgentRate);
                    } else {
                        $agentCommission = $agentCommissionAmount;
                    }
                        
                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $stmt->execute([$user['wallet_id']]);
                    $agentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($agentWallet) {
                        $agentBeforeBalance = (int)$agentWallet['balance'];
                        $agentAfterBalance = $agentBeforeBalance + $agentCommission;
                        
                        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $stmt->execute([$agentAfterBalance, $user['wallet_id']]);
                        
                        $agentRemark = "下级用户 {$cUser['username']} 完成任务，获得团长佣金，任务 ID：{$bTaskId}";
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
                            $bTaskId,
                            $taskType,
                            $taskTypeText,
                            $agentRemark
                        ]);
                    }
                }
            } elseif ($level === 1) {
                $secondAgentUserId = $user['id'];
                $secondAgentUsername = $user['username'];
                
                if ($agentLevel > 0) {
                    if ($agentLevel === 1) {
                        $secondAgentCommission = $agentCommissionAmount;
                    } elseif ($agentLevel === 2) {
                        $secondAgentCommission = $seniorAgentCommissionAmount;
                    } elseif ($agentLevel === 3) {
                        $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = ?");
                        $stmt->execute(['large_group_agent']);
                        $config = $stmt->fetch(PDO::FETCH_ASSOC);
                        $largeGroupAgentRate = $config ? (float)$config['config_value'] : 0.8;
                        $taskAmount = $taskUnitPrice * 100;
                        $secondAgentCommission = (int)round($taskAmount * $largeGroupAgentRate);
                    } else {
                        $secondAgentCommission = $seniorAgentCommissionAmount;
                    }
                        
                    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
                    $stmt->execute([$user['wallet_id']]);
                    $secondAgentWallet = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($secondAgentWallet) {
                        $secondAgentBeforeBalance = (int)$secondAgentWallet['balance'];
                        $secondAgentAfterBalance = $secondAgentBeforeBalance + $secondAgentCommission;
                        
                        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
                        $stmt->execute([$secondAgentAfterBalance, $user['wallet_id']]);
                        
                        $secondAgentRemark = "团队成员 {$cUser['username']} 完成任务，获得二级团长佣金，任务 ID：{$bTaskId}";
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
                            $bTaskId,
                            $taskType,
                            $taskTypeText,
                            $secondAgentRemark
                        ]);
                    }
                }
            }
            
            $currentUserId = $user['parent_id'];
            $level++;
        }
        
        // 15. 检查并处理新手转正
        $isNewbie = false;
        $hasCompletedTasks = 0;
        $isPromoted = false;
        
        $stmt = $db->prepare("SELECT is_newbie FROM c_users WHERE id = ?");
        $stmt->execute([$cUser['id']]);
        $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($userInfo && (int)$userInfo['is_newbie'] === 1) {
            $isNewbie = true;
            
            $stmt = $db->prepare("SELECT COUNT(*) as completed_count FROM c_task_records WHERE c_user_id = ? AND status = 3");
            $stmt->execute([$cUser['id']]);
            $completedInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            $hasCompletedTasks = (int)$completedInfo['completed_count'];
            
            if ($hasCompletedTasks >= 5) {
                $stmt = $db->prepare("UPDATE c_users SET is_newbie = 0 WHERE id = ?");
                $stmt->execute([$cUser['id']]);
                $isPromoted = true;
            }
        }

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
            'is_promoted' => $isPromoted,
        ]);
        
        $requestLogger->info('审核通过处理完成', [
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'c_user_commission' => $cUserCommission,
            'is_promoted' => $isPromoted,
        ]);
        
        // 返回成功响应
        echo json_encode([
            'code' => 0,
            'message' => $isPromoted ? '审核通过，佣金已发放，用户已转正' : '审核通过，佣金已发放',
            'data' => [
                'record_id' => (int)$recordId,
                'b_task_id' => (int)$bTaskId,
                'action' => 'approved',
                'c_user_commission' => number_format($cUserCommission / 100, 2),
                'agent_commission' => $agentCommission > 0 ? number_format($agentCommission / 100, 2) : '0.00',
                'agent_user_id' => $agentUserId ?? null,
                'agent_username' => $agentUsername ?? null,
                'second_agent_commission' => $secondAgentCommission > 0 ? number_format($secondAgentCommission / 100, 2) : '0.00',
                'second_agent_user_id' => $secondAgentUserId ?? null,
                'second_agent_username' => $secondAgentUsername ?? null,
                'team_revenue' => [
                    'c_user_amount' => number_format($cUserCommission / 100, 2),
                    'agent_amount' => $agentUserId ? number_format($cUserCommission / 100, 2) : '0.00',
                    'second_agent_amount' => $secondAgentUserId ? number_format($cUserCommission / 100, 2) : '0.00'
                ],
                'newbie_info' => [
                    'is_newbie' => $isNewbie,
                    'completed_tasks' => $hasCompletedTasks,
                    'is_promoted' => $isPromoted
                ],
                'reviewed_at' => $reviewedAt
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        
    } else {
        // ========== 审核驳回 ==========
        $requestLogger->info('开始审核驳回处理', ['record_id' => $recordId, 'b_task_id' => $bTaskId, 'reject_reason' => $rejectReason]);
        
        // 7. 更新任务记录状态
        $stmt = $db->prepare("
            UPDATE c_task_records 
            SET status = 4, reject_reason = ?, reviewed_at = ?
            WHERE id = ?
        ");
        $stmt->execute([$rejectReason, $reviewedAt, $recordId]);
        
        // 8. 更新 B 端任务统计（释放名额）
        $stmt = $db->prepare("SELECT id FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $isNormalTask = $stmt->fetch(PDO::FETCH_ASSOC) !== false;
        
        if ($isNormalTask) {
            $stmt = $db->prepare("SELECT task_reviewing FROM b_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
            
            $stmt = $db->prepare("
                UPDATE b_tasks 
                SET task_reviewing = ?
                WHERE id = ?
            ");
            $stmt->execute([$newTaskReviewing, $bTaskId]);
        } else {
            $stmt = $db->prepare("SELECT task_reviewing FROM b_newbie_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $taskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
            
            $newTaskReviewing = max((int)$taskInfo['task_reviewing'] - 1, 0);
            
            $stmt = $db->prepare("
                UPDATE b_newbie_tasks 
                SET task_reviewing = ?
                WHERE id = ?
            ");
            $stmt->execute([$newTaskReviewing, $bTaskId]);
        }
        
        // 9. 更新当日统计
        $stmt = $db->prepare("SELECT rejected_count FROM c_user_daily_stats WHERE id = ?");
        $stmt->execute([$dailyStatsId]);
        $currentStats = $stmt->fetch(PDO::FETCH_ASSOC);
        $currentRejectedCount = $currentStats ? (int)$currentStats['rejected_count'] : 0;
        $newRejectedCount = $currentRejectedCount + 1;
        
        $stmt = $db->prepare("
            UPDATE c_user_daily_stats 
            SET rejected_count = ? 
            WHERE id = ?
        ");
        $stmt->execute([$newRejectedCount, $dailyStatsId]);
        
        // 10. 记录 C 端任务统计（审核驳回）
        $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$bTaskInfo) {
            $stmt = $db->prepare("SELECT template_id, stage, unit_price FROM b_newbie_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $bTaskInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        }

        $taskType = 0;
        $taskTypeText = '';
        $taskStageText = '';
        $stage = 0;

        if ($bTaskInfo) {
            $stage = (int)$bTaskInfo['stage'];
            $stmt = $db->prepare("SELECT * FROM task_templates WHERE id = ?");
            $stmt->execute([$bTaskInfo['template_id']]);
            $template = $stmt->fetch(PDO::FETCH_ASSOC);

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

                if ($stage === 0) {
                    $taskStageText = $template['title'] ?? '';
                } elseif ($stage === 1) {
                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage1_title'] ?? '');
                } elseif ($stage === 2) {
                    $taskStageText = ($template['title'] ?? '') . '，' . ($template['stage2_title'] ?? '');
                }
            }
        }

        $cRemark = "用户 {$cUser['username']} 任务被驳回，任务 ID：{$bTaskId}，驳回原因：{$rejectReason}";
        
        $stmt = $db->prepare(" 
            INSERT INTO c_task_statistics (
                c_user_id, username, flow_type, amount, before_balance, after_balance, 
                related_type, related_id, task_types, task_types_text, task_stage, task_stage_text, 
                record_status, record_status_text, remark
            ) VALUES (?, ?, 0, 0, 0, 0, 'commission', ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $cUser['id'],
            $cUser['username'],
            $bTaskId,
            $taskType,
            $taskTypeText,
            $stage,
            $taskStageText,
            6,
            '审核拒绝',
            $cRemark
        ]);
        
        // 11. 检查并处理新手转正
        $isNewbie = false;
        
        $stmt = $db->prepare("SELECT is_newbie FROM c_users WHERE id = ?");
        $stmt->execute([$cUser['id']]);
        $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($userInfo && (int)$userInfo['is_newbie'] === 1) {
            $isNewbie = true;
        }

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
        
        // 返回成功响应
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
