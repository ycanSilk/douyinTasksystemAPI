<?php
/**
 * C端用户登录接口
 * 
 * POST /api/c/v1/auth/login
 * 
 * 请求体：
 * {
 *   "account": "string (必填，支持用户名、邮箱或手机号)",
 *   "password": "string (必填)"
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

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$account = trim($input['account'] ?? '');
$password = trim($input['password'] ?? '');

// 参数校验
if (empty($account)) {
    Response::error('账号不能为空', $errorCodes['USER_EMAIL_EMPTY']);
}

if (empty($password)) {
    Response::error('密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

// 数据库连接
$db = Database::connect();

try {
    // 查询 C端用户（支持用户名、邮箱或手机号登录）
    $stmt = $db->prepare(" 
        SELECT id, username, email, phone, password_hash, 
               invite_code, parent_id, is_agent, wallet_id, status, reason, 
               blocked_status, blocked_start_time, blocked_duration, blocked_end_time 
        FROM c_users 
        WHERE username = ? OR email = ? OR phone = ?
    ");
    $stmt->execute([$account, $account, $account]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 用户不存在或密码错误
    if (!$user || !password_verify($password, $user['password_hash'])) {
        Response::error('账号或密码错误', $errorCodes['USER_PASSWORD_WRONG']);
    }
    
    // 检查用户状态
    if ($user['status'] != 1) {
        $reason = $user['reason'] ?: '违规操作';
        Response::error('账号已被禁用：' . $reason, $errorCodes['AUTH_ACCOUNT_DISABLED']);
    }
    
    // 检查封禁状态
    if (isset($user['blocked_status']) && $user['blocked_status'] == 2) {
        $endTime = $user['blocked_end_time'] ?? null;
        $message = '账号已被禁止登录';
        if ($endTime) {
            $message .= '，解禁时间：' . $endTime;
        }
        Response::error($message, $errorCodes['AUTH_ACCOUNT_BLOCKED']);
    }
    
    // 生成新 Token（覆盖旧 Token，实现踢下线）
    $tokenData = Token::generate($user['id'], Token::TYPE_C);
    
    // 更新数据库中的 token 和过期时间
    $stmt = $db->prepare("
        UPDATE c_users 
        SET token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([
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
        'invite_code' => $user['invite_code'],
        'parent_id' => $user['parent_id'],
        'is_agent' => (int)$user['is_agent'],
        'wallet_id' => $user['wallet_id']
    ], '登录成功');
    
} catch (PDOException $e) {
    Response::error('登录失败', $errorCodes['DATABASE_ERROR'], 500);
}

