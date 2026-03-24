<?php
/**
 * C端用户申请成为团长接口
 * 
 * POST /api/c/v1/agent/apply
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 申请条件：
 * - 未激活团长身份
 * - 无待审核的申请
 * - 邀请的有效活跃用户数达标（默认5个）
 *
 * 有效活跃用户定义：
 * - 注册后24小时内完成5个任务（均可配置）
 * 
 * 返回数据：
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

// 记录接口调用开始
error_log('=== C端用户申请成为团长接口调用开始 ===');
error_log('请求方法: ' . $_SERVER['REQUEST_METHOD']);
error_log('请求IP: ' . $_SERVER['REMOTE_ADDR']);
error_log('请求时间: ' . date('Y-m-d H:i:s'));

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 1. 查询用户信息
    error_log('步骤1: 查询用户信息，用户ID: ' . $currentUser['user_id']);
    $stmt = $db->prepare(" 
        SELECT id, username, invite_code, is_agent
        FROM c_users
        WHERE id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        error_log('用户信息不存在，用户ID: ' . $currentUser['user_id']);
        Response::error('用户信息不存在', 3003);
    }
    error_log('用户信息查询成功，用户ID: ' . $user['id'] . ', 用户名: ' . $user['username'] . ', 团长状态: ' . $user['is_agent']);
    
    // 2. 检查是否已经是团长
    error_log('步骤2: 检查是否已经是团长，当前状态: ' . $user['is_agent']);
    if ((int)$user['is_agent'] >= 1) {
        $text = (int)$user['is_agent'] === 2 ? '高级团长' : '团长';
        error_log('用户已经是' . $text . '，无需重复申请，用户ID: ' . $user['id']);
        Response::error("您已经是{$text}，无需重复申请", 11000);
    }
    error_log('检查通过，用户不是团长');
    
    $stmt = $db->prepare(" 
        SELECT id FROM agent_applications
        WHERE c_user_id = ? AND status = 0
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        error_log('用户已有待审核的申请，用户ID: ' . $user['id']);
        Response::error('您已有待审核的申请，请耐心等待', 11002);
    }
    error_log('检查通过，用户没有待审核的申请');
    
    // 4. 从 app_config 表读取有效活跃用户数量配置
    error_log('步骤4: 从 app_config 表读取有效活跃用户数量配置');
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'agent_required_active_users'");
    $stmt->execute();
    $configValue = $stmt->fetchColumn();
    $requiredActiveUsers = $configValue ? (int)$configValue : 5; // 默认值为5
    error_log('有效活跃用户数量配置: ' . $requiredActiveUsers);

    // 5. 统计有效活跃用户数（完成至少8个任务）
    error_log('步骤5: 统计有效活跃用户数（完成至少8个任务），用户ID: ' . $user['id']);
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
    error_log('有效活跃用户数: ' . $validInvites);

    // 6. 检查是否满足条件
    error_log('步骤6: 检查是否满足条件，当前有效活跃用户数: ' . $validInvites . '，需要: ' . $requiredActiveUsers);
    if ($validInvites < $requiredActiveUsers) {
        error_log('有效活跃用户数不足，当前' . $validInvites . '个，需要' . $requiredActiveUsers . '个，用户ID: ' . $user['id']);
        Response::error("有效活跃用户数不足，当前{$validInvites}个，需要{$requiredActiveUsers}个", 11001);
    }
    error_log('检查通过，有效活跃用户数满足条件');

    // 7. 查询总邀请人数（从 develop_downline_users_count 表获取）
    error_log('步骤7: 查询总邀请人数（从 develop_downline_users_count 表获取），用户ID: ' . $user['id']);
    $stmt = $db->prepare(" 
        SELECT COUNT(*) as total
        FROM develop_downline_users_count
        WHERE developer_user_id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $totalInvites = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    error_log('总邀请人数: ' . $totalInvites);

    // 8. 创建申请记录
    error_log('步骤8: 创建申请记录，用户ID: ' . $user['id']);
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
    error_log('申请记录创建成功，申请ID: ' . $applicationId . ', 用户ID: ' . $user['id']);
    
    // 8. 返回成功响应
    error_log('步骤9: 返回成功响应，申请ID: ' . $applicationId . ', 用户ID: ' . $user['id']);
    Response::success([
        'application_id' => (int)$applicationId,
        'valid_invites' => $validInvites,
        'total_invites' => $totalInvites,
        'status' => 0,
        'status_text' => '待审核',
        'created_at' => $createdAt
    ], '申请提交成功，等待管理员审核');
    
} catch (PDOException $e) {
    error_log('申请失败，用户ID: ' . $user['id'] . ', 错误信息: ' . $e->getMessage());
    Response::error('申请失败', 11003, 500);
}
