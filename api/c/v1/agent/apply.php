<?php
/**
 * C端用户申请成为团长接口
 * 
 * POST /api/c/v1/agent/apply
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * Content-Type: application/json
 * 
 * 申请条件：
 * - 未激活团长身份（is_agent < 1）
 * - 无待审核的申请（agent_applications表中无status=0的记录）
 * - 邀请的有效活跃用户数达标（默认5个）
 *
 * 有效邀请人数条件判断逻辑：
 * 1. 从 app_config 表读取 agent_required_active_users 配置（默认5个）
 * 2. 统计邀请的有效活跃用户数：
 *    - 从 develop_downline_users_count 表获取下线用户
 *    - 关联 c_user_task_records_static 表
 *    - 下线用户完成任务数 >= 8 个
 * 3. 有效活跃用户数 >= 配置值时满足条件
 * 
 * 请求示例：
 * {
 *   "action": "apply"
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "申请提交成功，等待管理员审核",
 *   "data": {
 *     "application_id": 123,
 *     "valid_invites": 6,
 *     "total_invites": 10,
 *     "status": 0,
 *     "status_text": "待审核",
 *     "created_at": "2026-01-11 15:00:00"
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 11001,
 *   "message": "有效活跃用户数不足，当前3个，需要5个",
 *   "data": [],
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 3003 - 用户信息不存在
 * 11000 - 用户已经是团长，无需重复申请
 * 11001 - 有效活跃用户数不足
 * 11002 - 用户已有待审核的申请
 * 11003 - 申请失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('c/v1/agent/apply');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== C端用户申请成为团长接口调用开始 ===', [
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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 1. 查询用户信息
    $requestLogger->debug('步骤1: 查询用户信息，用户ID: ' . $currentUser['user_id']);
    $stmt = $db->prepare(" 
        SELECT id, username, invite_code, is_agent
        FROM c_users
        WHERE id = ?
    ");
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
    
    // 2. 检查是否已经是团长
    $requestLogger->debug('步骤2: 检查是否已经是团长，当前状态: ' . $user['is_agent']);
    if ((int)$user['is_agent'] >= 1) {
        if((int)$user['is_agent'] >= 2){
            $text = (int)$user['is_agent'] === 3 ? '大团团长' : '高级团长';
            $requestLogger->warning('用户已经是' . $text . '，无需重复申请', ['user_id' => $user['id']]);
            echo json_encode([
                'code' => 11000,
                'message' => "您已经是{$text}，无需重复申请",
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        $text = (int)$user['is_agent'] === 2 ? '高级团长' : '团长';
        $requestLogger->warning('用户已经是' . $text . '，无需重复申请', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11000,
            'message' => "您已经是{$text}，无需重复申请",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('检查通过，用户不是团长');
    
    $stmt = $db->prepare(" 
        SELECT id FROM agent_applications
        WHERE c_user_id = ? AND status = 0
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        $requestLogger->warning('用户已有待审核的申请', ['user_id' => $user['id']]);
        echo json_encode([
            'code' => 11002,
            'message' => '您已有待审核的申请，请耐心等待',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('检查通过，用户没有待审核的申请');
    
    // 4. 从 app_config 表读取有效活跃用户数量配置
    $requestLogger->debug('步骤4: 从 app_config 表读取有效活跃用户数量配置');
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'agent_required_active_users'");
    $stmt->execute();
    $configValue = $stmt->fetchColumn();
    $requiredActiveUsers = $configValue ? (int)$configValue : 5; // 默认值为5
    $requestLogger->debug('有效活跃用户数量配置: ' . $requiredActiveUsers);

    // 5. 统计有效活跃用户数（完成至少8个任务）
    $requestLogger->debug('步骤5: 统计有效活跃用户数（完成至少8个任务），用户ID: ' . $user['id']);
    $stmt = $db->prepare(" 
        SELECT COUNT(*) as active_count
        FROM develop_downline_users_count d
        INNER JOIN c_user_task_records_static s ON s.user_id = d.downline_user_id
        WHERE d.developer_user_id = ?
          AND s.completed_task_count >= 8
    ");
    $stmt->execute([$currentUser['user_id']]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $validInvites = (int)$result['active_count'];
    $requestLogger->debug('有效活跃用户数: ' . $validInvites);

    // 6. 检查是否满足条件
    $requestLogger->debug('步骤6: 检查是否满足条件，当前有效活跃用户数: ' . $validInvites . '，需要: ' . $requiredActiveUsers);
    if ($validInvites < $requiredActiveUsers) {
        $requestLogger->warning('有效活跃用户数不足', [
            'user_id' => $user['id'],
            'current' => $validInvites,
            'required' => $requiredActiveUsers
        ]);
        echo json_encode([
            'code' => 11001,
            'message' => "有效活跃用户数不足，当前{$validInvites}个，需要{$requiredActiveUsers}个",
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('检查通过，有效活跃用户数满足条件');

    // 7. 查询总邀请人数（从 develop_downline_users_count 表获取）
    $requestLogger->debug('步骤7: 查询总邀请人数（从 develop_downline_users_count 表获取），用户ID: ' . $user['id']);
    $stmt = $db->prepare(" 
        SELECT COUNT(*) as total
        FROM develop_downline_users_count
        WHERE developer_user_id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $totalInvites = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('总邀请人数: ' . $totalInvites);

    // 8. 创建申请记录
    $requestLogger->debug('步骤8: 创建申请记录，用户ID: ' . $user['id']);
    $stmt = $db->prepare(" 
        INSERT INTO agent_applications (
            c_user_id, username, invite_code, apply_type, valid_invites, total_invites, status
        ) VALUES (?, ?, ?, 1, ?, ?, 0)
    ");
    $stmt->execute([
        $currentUser['user_id'],
        $user['username'],
        $user['invite_code'],
        $validInvites,
        $totalInvites
    ]);
    
    $applicationId = $db->lastInsertId();
    $createdAt = date('Y-m-d H:i:s');
    $requestLogger->info('申请记录创建成功', ['application_id' => $applicationId, 'user_id' => $user['id']]);
    
    // 记录审计日志
    $auditLogger->notice('C端用户申请成为团长', [
        'user_id' => $user['id'],
        'username' => $user['username'],
        'application_id' => $applicationId,
        'valid_invites' => $validInvites,
        'total_invites' => $totalInvites
    ]);
    
    // 8. 返回成功响应
    $requestLogger->debug('步骤9: 返回成功响应，申请ID: ' . $applicationId . ', 用户ID: ' . $user['id']);
    echo json_encode([
        'code' => 0,
        'message' => '申请提交成功，等待管理员审核',
        'data' => [
            'application_id' => (int)$applicationId,
            'valid_invites' => $validInvites,
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
        'code' => 11003,
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
        'code' => 11003,
        'message' => '申请失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
