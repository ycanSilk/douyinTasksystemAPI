<?php
/**
 * B端修改密码接口
 * 
 * POST /api/b/v1/auth/change-password
 * 
 * 请求体：
 * {
 *   "old_password": "string (必填)",
 *   "new_password": "string (必填)"
 * }
 * 
 * 请求头：
 * X-Token: <token>
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$oldPassword = trim($input['old_password'] ?? '');
$newPassword = trim($input['new_password'] ?? '');

// 参数校验
if (empty($oldPassword)) {
    Response::error('旧密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

if (empty($newPassword)) {
    Response::error('新密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

if ($oldPassword === $newPassword) {
    Response::error('新密码不能与旧密码相同', $errorCodes['INVALID_PARAMS']);
}

try {
    // 查询当前用户信息
    $stmt = $db->prepare("
        SELECT id, username, email, phone, password_hash, 
               organization_name, organization_leader, wallet_id 
        FROM b_users 
        WHERE id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        Response::error('用户不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 验证旧密码
    if (!password_verify($oldPassword, $user['password_hash'])) {
        Response::error('旧密码错误', $errorCodes['USER_PASSWORD_WRONG']);
    }
    
    // 生成新密码哈希
    $newPasswordHash = password_hash($newPassword, PASSWORD_BCRYPT);
    
    // 生成新 Token（踢掉旧 Token）
    $tokenData = Token::generate($user['id'], Token::TYPE_B);
    
    // 更新密码和 Token
    $stmt = $db->prepare("
        UPDATE b_users 
        SET password_hash = ?, token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([
        $newPasswordHash,
        $tokenData['token'],
        $tokenData['expired_at'],
        $user['id']
    ]);
    
    // 返回成功响应
    Response::success([
        'token' => $tokenData['token'],
        'user_id' => $user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'organization_name' => $user['organization_name'],
        'organization_leader' => $user['organization_leader'],
        'wallet_id' => $user['wallet_id']
    ], '密码修改成功，请使用新 Token');
    
} catch (PDOException $e) {
    Response::error('密码修改失败', $errorCodes['DATABASE_ERROR'], 500);
}

