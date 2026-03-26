<?php
/**
 * C端用户申请成为高级团长接口
 * 
 * POST /api/c/v1/agent/apply-senior
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * Content-Type: application/json
 * 
 * 申请条件：
 * - 必须已经是普通团长（is_agent=1）
 * - 无待审核的高级团长申请
 * - 邀请的有效活跃用户数达标（默认30个）
 * - 高级团长总数未达上限（默认100个）
 *
 * 有效邀请人数条件判断逻辑：
 * 1. 从 app_config 表读取配置：
 *    - senior_agent_required_active_users：需要的有效活跃用户数（默认30个）
 *    - senior_agent_active_user_task_count：下线用户需要完成的任务数（默认8个）
 * 2. 统计邀请的有效活跃用户数：
 *    - 从 c_users 表获取 parent_id = 当前用户ID的下线用户
 *    - 关联 c_user_task_records_static 表
 *    - 下线用户完成任务数 >= 配置值 个
 * 3. 有效活跃用户数 >= 配置值时满足条件
 * 
 * 请求示例：
 * {
 *   "action": "apply-senior"
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "高级团长申请提交成功，等待管理员审核",
 *   "data": {
 *     "application_id": 123,
 *     "active_users": 35,
 *     "required_active_users": 30,
 *     "total_invites": 100,
 *     "status": 0,
 *     "status_text": "待审核",
 *     "created_at": "2026-01-11 15:00:00"
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 11011,
 *   "message": "有效活跃用户数不足，当前25个，需要30个",
 *   "data": [],
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 3003 - 用户信息不存在
 * 11010 - 您还不是团长，请先申请成为普通团长
 * 11012 - 您已经是高级团长，无需重复申请
 * 11013 - 您已有待审核的高级团长申请
 * 11014 - 高级团长名额已满
 * 11011 - 有效活跃用户数不足
 * 11015 - 申请失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('c/v1/agent/apply-senior');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== C端用户申请成为高级团长接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    echo json_encode(['code' => 1001, 'message' => '请求方法错误', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

$db = Database::connect();

$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 1. 查询用户信息
    $requestLogger->debug('步骤1: 查询用户信息，用户ID: ' . $currentUser['user_id']);
    $stmt = $db->prepare("SELECT id, username, invite_code, is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        $errorLogger->error('用户信息不存在', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 3003,
            'message' => '用户信息不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('用户信息查询成功', ['user_id' => $user['id'], 'username' => $user['username'], 'is_agent' => $user['is_agent']]);

    // 2. 必须是普通团长才能申请高级团长
    $requestLogger->debug('步骤2: 检查用户团长状态，当前状态: ' . $user['is_agent']);
    if ((int)$user['is_agent'] === 0) {
        $requestLogger->warning('用户不是团长，不能申请高级团长', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11010,
            'message' => '您还不是团长，请先申请成为普通团长',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ((int)$user['is_agent'] === 2) {
        $requestLogger->warning('用户已经是高级团长，无需重复申请', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11012,
            'message' => '您已经是高级团长，无需重复申请',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    if ((int)$user['is_agent'] === 3) {
        $requestLogger->warning('用户已经是大团团长，无需重复申请', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11012,
            'message' => '您已经是大团团长，无需重复申请',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    if ((int)$user['is_agent'] > 3) {
        $requestLogger->warning('你已经是最高级代理，无需重复申请', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11012,
            'message' => '您已经是最高级代理，无需重复申请',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 3. 检查是否有待审核的高级团长申请
    $requestLogger->debug('步骤3: 检查是否有待审核的高级团长申请，用户ID: ' . $user['id']);
    $stmt = $db->prepare("SELECT id FROM agent_applications WHERE c_user_id = ? AND apply_type = 2 AND status = 0 LIMIT 1");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        $requestLogger->warning('用户已有待审核的高级团长申请', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11013,
            'message' => '您已有待审核的高级团长申请，请耐心等待',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('检查通过，用户没有待审核的高级团长申请');

    // 4. 检查高级团长数量上限
    $requestLogger->debug('步骤4: 检查高级团长数量上限');
    $maxCount = AppConfig::get('senior_agent_max_count', 100);
    $stmt = $db->prepare("SELECT COUNT(*) as cnt FROM c_users WHERE is_agent = 2");
    $stmt->execute();
    $currentCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['cnt'];
    $requestLogger->debug('高级团长数量检查', ['current' => $currentCount, 'max' => $maxCount]);

    if ($currentCount >= $maxCount) {
        $requestLogger->warning('高级团长名额已满', ['current' => $currentCount, 'max' => $maxCount]);
        echo json_encode([
            'code' => 11014,
            'message' => "高级团长名额已满（上限{$maxCount}个）",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('高级团长数量检查通过');

    // 5. 读取配置
    $requestLogger->debug('步骤5: 读取高级团长申请配置');
    $requiredActiveUsers = AppConfig::get('senior_agent_required_active_users', 30);
    $taskCount = AppConfig::get('senior_agent_active_user_task_count', 8);
    $requestLogger->debug('高级团长申请配置', ['required_active_users' => $requiredActiveUsers, 'task_count' => $taskCount]);

    // 6. 统计有效活跃用户数
    // 有效活跃用户 = 被当前用户邀请的下线，完成任务数 >= 配置值 个
    // 使用c_users表的parent_id字段来判定邀请关系
    $requestLogger->debug('步骤6: 统计有效活跃用户数，用户ID: ' . $user['id']);
    $stmt = $db->prepare("
        SELECT COUNT(*) as active_count
        FROM c_users u
        INNER JOIN c_user_task_records_static s ON s.user_id = u.id
        WHERE u.parent_id = ?
          AND s.completed_task_count >= ?
    ");
    $stmt->execute([$currentUser['user_id'], $taskCount]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $activeUsers = (int)$result['active_count'];
    $requestLogger->debug('有效活跃用户数: ' . $activeUsers);

    // 7. 检查是否满足条件
    $requestLogger->debug('步骤7: 检查是否满足条件，当前有效活跃用户数: ' . $activeUsers . '，需要: ' . $requiredActiveUsers);
    if ($activeUsers < $requiredActiveUsers) {
        $requestLogger->warning('有效活跃用户数不足', [
            'user_id' => $user['id'],
            'current' => $activeUsers,
            'required' => $requiredActiveUsers
        ]);
        echo json_encode([
            'code' => 11011,
            'message' => "有效活跃用户数不足，当前{$activeUsers}个，需要{$requiredActiveUsers}个",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('检查通过，有效活跃用户数满足条件');

    // 8. 查询总邀请人数
    $requestLogger->debug('步骤8: 查询总邀请人数，用户ID: ' . $user['id']);
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_users WHERE parent_id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $totalInvites = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('总邀请人数: ' . $totalInvites);

    // 9. 创建申请记录
    $requestLogger->debug('步骤9: 创建高级团长申请记录，用户ID: ' . $user['id']);
    $stmt = $db->prepare("
        INSERT INTO agent_applications (
            c_user_id, username, invite_code, apply_type, valid_invites, total_invites, status
        ) VALUES (?, ?, ?, 2, ?, ?, 0)
    ");
    $stmt->execute([
        $currentUser['user_id'],
        $user['username'],
        $user['invite_code'],
        $activeUsers,
        $totalInvites
    ]);

    $applicationId = $db->lastInsertId();
    $createdAt = date('Y-m-d H:i:s');
    $requestLogger->info('高级团长申请记录创建成功', ['application_id' => $applicationId, 'user_id' => $user['id']]);
    
    // 记录审计日志
    $auditLogger->notice('C端用户申请成为高级团长', [
        'user_id' => $user['id'],
        'username' => $user['username'],
        'application_id' => $applicationId,
        'active_users' => $activeUsers,
        'required_active_users' => $requiredActiveUsers,
        'total_invites' => $totalInvites
    ]);

    // 10. 返回成功响应
    $requestLogger->debug('步骤10: 返回成功响应，申请ID: ' . $applicationId . ', 用户ID: ' . $user['id']);
    echo json_encode([
        'code' => 0,
        'message' => '高级团长申请提交成功，等待管理员审核',
        'data' => [
            'application_id' => (int)$applicationId,
            'active_users' => $activeUsers,
            'required_active_users' => $requiredActiveUsers,
            'total_invites' => $totalInvites,
            'status' => 0,
            'status_text' => '待审核',
            'created_at' => $createdAt
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    $errorLogger->error('申请失败', [
        'user_id' => $currentUser['user_id'],
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 11015,
        'message' => '申请失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    $errorLogger->error('申请失败', [
        'user_id' => $currentUser['user_id'],
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 11015,
        'message' => '申请失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
