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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 1. 查询用户信息
    $stmt = $db->prepare("
        SELECT id, username, invite_code, is_agent
        FROM c_users
        WHERE id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        Response::error('用户信息不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 2. 检查是否已经是团长
    if ((int)$user['is_agent'] >= 1) {
        $text = (int)$user['is_agent'] === 2 ? '高级团长' : '团长';
        Response::error("您已经是{$text}，无需重复申请", $errorCodes['AGENT_ALREADY_ACTIVATED']);
    }
    
    // 3. 检查是否有待审核的申请
    $stmt = $db->prepare("
        SELECT id FROM agent_applications
        WHERE c_user_id = ? AND status = 0
        LIMIT 1
    ");
    $stmt->execute([$currentUser['user_id']]);
    if ($stmt->fetch()) {
        Response::error('您已有待审核的申请，请耐心等待', $errorCodes['AGENT_APPLICATION_PENDING']);
    }
    
    // 4. 读取配置
    $requiredActiveUsers = AppConfig::get('agent_required_active_users', 5);
    $taskCount = AppConfig::get('agent_active_user_task_count', 5);
    $hours = AppConfig::get('agent_active_user_hours', 24);

    // 5. 统计有效活跃用户数（注册后N小时内完成M个任务）
    $stmt = $db->prepare("
        SELECT COUNT(DISTINCT u.id) as active_count
        FROM c_users u
        INNER JOIN c_task_records r ON r.c_user_id = u.id
        WHERE u.parent_id = ?
          AND r.status = 3
          AND r.reviewed_at <= DATE_ADD(u.created_at, INTERVAL ? HOUR)
        GROUP BY u.id
        HAVING COUNT(r.id) >= ?
    ");
    $stmt->execute([$currentUser['user_id'], $hours, $taskCount]);
    $validInvites = (int)$stmt->rowCount();

    // 6. 检查是否满足条件
    if ($validInvites < $requiredActiveUsers) {
        Response::error("有效活跃用户数不足，当前{$validInvites}个，需要{$requiredActiveUsers}个", $errorCodes['AGENT_INSUFFICIENT_VALID_INVITES']);
    }

    // 7. 查询总邀请人数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_users
        WHERE parent_id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $totalInvites = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];

    // 8. 创建申请记录
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
    
    // 8. 返回成功响应
    Response::success([
        'application_id' => (int)$applicationId,
        'valid_invites' => $validInvites,
        'total_invites' => $totalInvites,
        'status' => 0,
        'status_text' => '待审核',
        'created_at' => $createdAt
    ], '申请提交成功，等待管理员审核');
    
} catch (PDOException $e) {
    Response::error('申请失败', $errorCodes['AGENT_APPLICATION_FAILED'], 500);
}
