<?php
/**
 * C端重置密码接口
 * 
 * POST /api/c/v1/auth/reset-password
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

// 开启调试模式
$debug = false;

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

// 调试日志：输出请求方法和路径
if ($debug) {
    error_log('Reset password request: ' . $_SERVER['REQUEST_METHOD'] . ' ' . $_SERVER['REQUEST_URI']);
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 获取请求参数
$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true);
$username = trim($input['username'] ?? '');
$phone = trim($input['phone'] ?? '');
$newPassword = trim($input['new_password'] ?? '');
$confirmPassword = trim($input['confirm_password'] ?? '');

// 调试日志：输出请求参数
if ($debug) {
    error_log('Raw input: ' . $rawInput);
    error_log('Parsed input: ' . print_r($input, true));
    error_log('Username: ' . $username);
    error_log('Phone: ' . $phone);
    error_log('New password: ' . ($newPassword ? '***' : 'empty'));
    error_log('Confirm password: ' . ($confirmPassword ? '***' : 'empty'));
}

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
    // 调试日志：开始数据库操作
    if ($debug) {
        error_log('Starting database operations...');
    }
    
    // 查询用户信息（通过用户名和手机号）
    $stmt = $db->prepare("
        SELECT id, username, phone, password_hash, 
               invite_code, parent_id, is_agent, wallet_id 
        FROM c_users 
        WHERE username = ? AND phone = ?
    ");
    
    // 调试日志：执行查询
    if ($debug) {
        error_log('Executing user query with username: ' . $username . ', phone: ' . $phone);
    }
    
    $stmt->execute([$username, $phone]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 调试日志：查询结果
    if ($debug) {
        error_log('User query result: ' . print_r($user, true));
    }
    
    if (!$user) {
        if ($debug) {
            error_log('User not found');
        }
        Response::error('用户名或手机号错误', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 生成新密码哈希
    $newPasswordHash = password_hash($newPassword, PASSWORD_BCRYPT);
    
    // 生成新 Token
    $tokenData = Token::generate($user['id'], Token::TYPE_C);
    
    // 调试日志：生成的 Token
    if ($debug) {
        error_log('Generated token: ' . $tokenData['token']);
        error_log('Token expired at: ' . $tokenData['expired_at']);
    }
    
    // 更新密码和 Token
    $stmt = $db->prepare("
        UPDATE c_users 
        SET password_hash = ?, token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    
    // 调试日志：执行更新
    if ($debug) {
        error_log('Executing update for user id: ' . $user['id']);
    }
    
    $stmt->execute([
        $newPasswordHash,
        $tokenData['token'],
        $tokenData['expired_at'],
        $user['id']
    ]);
    
    // 调试日志：更新结果
    if ($debug) {
        error_log('Update affected rows: ' . $stmt->rowCount());
    }
    
    // 调试日志：返回成功响应
    if ($debug) {
        error_log('Returning success response');
    }
    
    // 返回成功响应
    Response::success([
        'token' => $tokenData['token'],
        'user_id' => $user['id'],
        'username' => $user['username'],       
        'phone' => $user['phone']
    ], '密码重置成功');

    
} catch (PDOException $e) {
    // 调试日志：数据库异常
    if ($debug) {
        error_log('PDO Exception: ' . $e->getMessage());
        error_log('Exception trace: ' . $e->getTraceAsString());
    }
    Response::error('密码重置失败', $errorCodes['DATABASE_ERROR'], 500);
}