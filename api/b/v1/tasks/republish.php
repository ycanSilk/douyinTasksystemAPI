<?php
/**
 * B 端重新发布未完成任务接口
 * 
 * POST /api/b/v1/tasks/republish
 * 
 * 请求头：
 * X-Token: <token> (B 端)
 * 
 * 请求体：
 * {
 *   "b_task_id": 123,          // 原任务ID
 *   "deadline": 1736582400      // 新任务截止时间
 * }
 * 
 * 响应示例：
 * {
 *   "code": 0,
 *   "message": "重新发布成功",
 *   "data": {
 *     "new_task_id": 456,
 *     "original_task_id": 123,
 *     "unfinished_count": 2,
 *     "deadline": 1736582400
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4001 - 任务ID不能为空
 * 4002 - 任务不存在
 * 4003 - 权限不足
 * 4004 - 任务未过期
 * 4005 - 任务已全部完成
 * 4006 - 任务已重新发布，不能重复发布
 * 4014 - 用户信息异常
 * 4015 - 钱包不存在
 * 4016 - 余额不足
 * 5001 - 数据库错误
 * 5002 - 重新发布失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文
LoggerRouter::setContext('b/v1/tasks/republish');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== B 端重新发布任务请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    
    $auditLogger->warning('B 端用户重新发布任务失败：请求方法错误', [
        'method' => $_SERVER['REQUEST_METHOD'],
        'reason' => '请求方法错误',
    ]);
    
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
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

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
    
    $auditLogger->error('B 端用户重新发布任务失败：数据库连接失败', [
        'exception' => $e->getMessage(),
        'reason' => '数据库连接失败',
    ]);
    
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 5001,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Token 认证（必须是 B端用户）
try {
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateB();
    $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);
    
    $auditLogger->warning('B 端用户重新发布任务失败：Token 认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token 认证失败',
    ]);
    
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 4003,
        'message' => '认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$deadline = $input['deadline'] ?? 0;

$requestLogger->debug('请求参数', [
    'b_task_id' => $bTaskId,
    'deadline' => $deadline,
]);

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    $requestLogger->warning('任务ID为空或无效', ['b_task_id' => $bTaskId]);
    echo json_encode([
        'code' => 4001,
        'message' => '任务ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($deadline) || !is_numeric($deadline)) {
    $requestLogger->warning('截止时间为空或无效', ['deadline' => $deadline]);
    echo json_encode([
        'code' => 4001,
        'message' => '截止时间不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 检查截止时间是否有效
if ($deadline <= time()) {
    $requestLogger->warning('截止时间无效', ['deadline' => $deadline]);
    echo json_encode([
        'code' => 4001,
        'message' => '截止时间必须大于当前时间',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 1. 查询原任务信息
    $requestLogger->debug('查询原任务信息', ['b_task_id' => $bTaskId]);
    $stmt = $db->prepare("
        SELECT * FROM b_tasks 
        WHERE id = ? AND b_user_id = ?
    ");
    $stmt->execute([$bTaskId, $currentUser['user_id']]);
    $task = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$task) {
        $requestLogger->warning('任务不存在或无权限', ['b_task_id' => $bTaskId]);
        echo json_encode([
            'code' => 4002,
            'message' => '任务不存在或无权限',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $requestLogger->debug('原任务信息', [
        'id' => $task['id'],
        'task_count' => $task['task_count'],
        'task_done' => $task['task_done'],
        'status' => $task['status'],
        'deadline' => $task['deadline'],
        'is_republish' => $task['is_republish']
    ]);
    
    // 3. 计算未完成任务数量
    $unfinishedCount = $task['task_count'] - $task['task_done'];
    
    // 2. 检查任务是否已过期（四重校验）
    if ($task['deadline'] > time() || $task['status'] != 0 || $unfinishedCount <= 0 || $task['is_republish'] == 1) {
        $requestLogger->warning('任务未过期、状态异常、已全部完成或已重新发布', [
            'deadline' => $task['deadline'],
            'current_time' => time(),
            'status' => $task['status'],
            'task_count' => $task['task_count'],
            'task_done' => $task['task_done'],
            'unfinished_count' => $unfinishedCount,
            'is_republish' => $task['is_republish']
        ]);
        
        if ($task['is_republish'] == 1) {
            echo json_encode([
                'code' => 4006,
                'message' => '任务已重新发布，不能重复发布',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
        } elseif ($unfinishedCount <= 0) {
            echo json_encode([
                'code' => 4005,
                'message' => '任务已全部完成，无需重新发布',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode([
                'code' => 4004,
                'message' => '任务未过期或状态异常，无法重新发布',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
        }
        exit;
    }
    
    $requestLogger->debug('计算未完成数量', [
        'unfinished_count' => $unfinishedCount
    ]);
    
    // 4. 处理推荐评论
    $recommendMarks = json_decode($task['recommend_marks'], true);
    if (!is_array($recommendMarks)) {
        $recommendMarks = [];
    }
    
    // 过滤出未使用的推荐评论
    $unfinishedMarks = array_slice($recommendMarks, $task['task_done']);
    $requestLogger->debug('处理推荐评论', [
        'total_marks' => count($recommendMarks),
        'used_marks' => $task['task_done'],
        'unfinished_marks' => count($unfinishedMarks)
    ]);
    
    // 5. 计算新的总价
    $newTotalPrice = $task['unit_price'] * $unfinishedCount;
    
    // 6. 查询 B 端用户信息（获取钱包 ID 和用户名）
    $requestLogger->debug('开始查询用户信息', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        $requestLogger->warning('用户信息不存在', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 4014,
            'message' => '用户信息异常',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 7. 查询钱包余额
    $requestLogger->debug('开始查询钱包余额', ['wallet_id' => $bUser['wallet_id']]);
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        $requestLogger->warning('钱包不存在', ['wallet_id' => $bUser['wallet_id']]);
        echo json_encode([
            'code' => 4015,
            'message' => '钱包不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 8. 将总价转换为分（元 -> 分）
    $totalPriceInCents = (int)round($newTotalPrice * 100);
    $beforeBalance = (int)$wallet['balance'];
    
    $requestLogger->debug('余额校验信息', [
        'total_price_cents' => $totalPriceInCents,
        'before_balance' => $beforeBalance,
    ]);
    
    // 9. 校验余额是否足够
    if ($beforeBalance < $totalPriceInCents) {
        $needAmount = number_format($totalPriceInCents / 100, 2);
        $currentAmount = number_format($beforeBalance / 100, 2);
        $requestLogger->warning('余额不足', [
            'current_balance' => $currentAmount,
            'need_amount' => $needAmount,
        ]);
        echo json_encode([
            'code' => 4016,
            'message' => "余额不足，当前余额：¥{$currentAmount}，需要：¥{$needAmount}",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 10. 开启事务
    $db->beginTransaction();
    $requestLogger->debug('开启事务');
    
    try {
        // 11. 创建新任务
        $requestLogger->debug('创建新任务');
        $stmt = $db->prepare("
            INSERT INTO b_tasks (
                b_user_id, template_id, video_url, deadline, 
                recommend_marks, task_count, task_done, task_doing, task_reviewing,
                unit_price, total_price, status, stage, stage_status,
                combo_task_id, parent_task_id
            ) VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, 1, ?, 1, ?, ?)
        ");
        
        $result = $stmt->execute([
            $task['b_user_id'],
            $task['template_id'],
            $task['video_url'],
            $deadline,
            json_encode($unfinishedMarks, JSON_UNESCAPED_UNICODE),
            $unfinishedCount,
            $task['unit_price'],
            $newTotalPrice,
            $task['stage'],
            $task['combo_task_id'],
            $task['parent_task_id']
        ]);
        
        if (!$result) {
            throw new Exception('创建新任务失败');
        }
        
        $newTaskId = $db->lastInsertId();
        $requestLogger->debug('新任务创建成功', ['new_task_id' => $newTaskId]);
        
        // 11.1 更新原任务的is_republish字段为1，标记已重新发布
        $stmt = $db->prepare("UPDATE b_tasks SET is_republish = 1 WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $requestLogger->debug('更新原任务is_republish字段为1', ['b_task_id' => $bTaskId]);
        
        // 12. 扣除钱包余额
        $afterBalance = $beforeBalance - $totalPriceInCents;
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$afterBalance, $bUser['wallet_id']]);
        
        // 13. 记录钱包流水
        $remark = "重新发布任务【任务ID:{$bTaskId}】{$unfinishedCount}个未完成任务，扣除 ¥" . number_format($newTotalPrice, 2);
        // 根据任务模板ID确定任务类型
        $taskType = 0;
        $taskTypeText = '';
        $templateId = (int)($task['template_id'] ?? 0);
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
        $stmt = $db->prepare(" 
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, task_types, task_types_text, remark
            ) VALUES (?, ?, ?, 2, 2, ?, ?, ?, '任务发布', ?, ?, ?, ?)
        ");
        $stmt->execute([
            $bUser['wallet_id'],
            $currentUser['user_id'],
            $bUser['username'],
            $totalPriceInCents,
            $beforeBalance,
            $afterBalance,
            $newTaskId,
            $taskType,
            $taskTypeText,
            $remark
        ]);
        
        // 14. 插入B端任务统计记录
        try {
            $stmt = $db->prepare(" 
                INSERT INTO b_task_statistics (
                    b_user_id, username, flow_type, amount, before_balance, after_balance, 
                    related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
                ) VALUES (?, ?, 2, ?, ?, ?, 'task_republish', ?, ?, ?, 0, '任务重新发布记录，当前状态已发布，待领取', ?)
            ");
            $stmt->execute([
                $currentUser['user_id'],
                $bUser['username'],
                $totalPriceInCents,
                $beforeBalance,
                $afterBalance,
                $newTaskId,
                $taskType,
                $taskTypeText,
                $remark
            ]);
        } catch (Exception $e) {
            // 记录插入失败时的错误日志，但不影响主流程
            error_log('插入b_task_statistics失败: ' . $e->getMessage());
        }
        
        // 15. 提交事务
        $db->commit();
        $requestLogger->debug('事务提交成功');
        
        // 9. 记录审计日志
        $auditLogger->notice('B 端用户重新发布任务成功', [
            'user_id' => $currentUser['user_id'],
            'original_task_id' => $bTaskId,
            'new_task_id' => $newTaskId,
            'unfinished_count' => $unfinishedCount,
            'deadline' => $deadline
        ]);
        
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }
        
        // 10. 返回结果
        echo json_encode([
            'code' => 0,
            'message' => '重新发布成功',
            'data' => [
                'new_task_id' => (int)$newTaskId,
                'original_task_id' => (int)$bTaskId,
                'unfinished_count' => $unfinishedCount,
                'deadline' => (int)$deadline,
                'wallet' => [
                    'before_balance' => number_format($beforeBalance / 100, 2),
                    'after_balance' => number_format($afterBalance / 100, 2),
                    'deducted' => number_format($totalPriceInCents / 100, 2)
                ]
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (Exception $e) {
        // 回滚事务
        if ($db->inTransaction()) {
            $db->rollBack();
            $requestLogger->debug('事务回滚');
        }
        throw $e;
    }
    
} catch (Exception $e) {
    $errorLogger->error('重新发布任务失败', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    $auditLogger->error('B 端用户重新发布任务失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);
    
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 5002,
        'message' => '重新发布失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
?>