<?php
/**
 * B端重置密码接口
 * 
 * POST /api/b/v1/auth/reset-password
 * 
 * 请求体：
 * {
 *   "username": "string (必填)",
 *   "phone": "string (必填)",
 *   "new_password": "string (必填)",
 *   "confirm_password": "string (必填)"
 * }
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
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$username = trim($input['username'] ?? '');
$phone = trim($input['phone'] ?? '');
$newPassword = trim($input['new_password'] ?? '');
$confirmPassword = trim($input['confirm_password'] ?? '');

// 参数校验
if (empty($username)) {
    Response::error('用户名不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($phone)) {
    Response::error('手机号不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($newPassword)) {
    Response::error('新密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

if (empty($confirmPassword)) {
    Response::error('确认密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

if ($newPassword !== $confirmPassword) {
    Response::error('两次输入的密码不一致', $errorCodes['INVALID_PARAMS']);
}

try {
    // 查询用户信息（通过用户名和手机号）
    $stmt = $db->prepare("
        SELECT id, username, email, phone, password_hash, 
               organization_name, organization_leader, wallet_id 
        FROM b_users 
        WHERE username = ? AND phone = ?
    ");
    $stmt->execute([$username, $phone]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        Response::error('用户名或手机号错误', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 生成新密码哈希
    $newPasswordHash = password_hash($newPassword, PASSWORD_BCRYPT);
    
    // 生成新 Token
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
        'organization_leader' => $user['organization_leader']
    ], '密码重置成功');

    
} catch (PDOException $e) {
    Response::error('密码重置失败', $errorCodes['DATABASE_ERROR'], 500);
}