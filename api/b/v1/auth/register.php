<?php
/**
 * B端用户注册接口
 * 
 * POST /api/b/v1/auth/register
 * 
 * 请求体：
 * {
 *   "username": "string (必填)",
 *   "email": "string (必填)",
 *   "phone": "string (选填)",
 *   "password": "string (必填)",
 *   "organization_name": "string (必填)",
 *   "organization_leader": "string (必填)"
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
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$password = trim($input['password'] ?? '');
$organizationName = trim($input['organization_name'] ?? '');
$organizationLeader = trim($input['organization_leader'] ?? '');

// 参数校验
if (empty($username)) {
    Response::error('用户名不能为空', $errorCodes['USER_USERNAME_EMPTY']);
}

if (empty($email)) {
    Response::error('邮箱不能为空', $errorCodes['USER_EMAIL_EMPTY']);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('邮箱格式不正确', $errorCodes['USER_EMAIL_INVALID']);
}

if (empty($password)) {
    Response::error('密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

if (empty($organizationName)) {
    Response::error('组织名称不能为空', $errorCodes['USER_ORGANIZATION_NAME_EMPTY']);
}

if (empty($organizationLeader)) {
    Response::error('组织负责人名称不能为空', $errorCodes['USER_ORGANIZATION_LEADER_EMPTY']);
}

// 获取客户端 IP
$createIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';

// 数据库连接
$db = Database::connect();

try {
    // 检查用户名是否已存在
    $stmt = $db->prepare("SELECT id FROM b_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        Response::error('用户名已被占用', $errorCodes['USER_USERNAME_EXISTS']);
    }
    
    // 检查邮箱是否已存在
    $stmt = $db->prepare("SELECT id FROM b_users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        Response::error('邮箱已被注册', $errorCodes['USER_EMAIL_EXISTS']);
    }
    
    // 检查手机号是否已存在（如果提供了手机号）
    if (!empty($phone)) {
        $stmt = $db->prepare("SELECT id FROM b_users WHERE phone = ?");
        $stmt->execute([$phone]);
        if ($stmt->fetch()) {
            Response::error('手机号已被注册', $errorCodes['USER_PHONE_EXISTS']);
        }
    }
    
    // 开启事务
    $db->beginTransaction();
    
    // 1. 创建钱包记录
    $stmt = $db->prepare("INSERT INTO wallets (balance) VALUES (0)");
    $stmt->execute();
    $walletId = $db->lastInsertId();
    
    // 2. 密码哈希
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    // 3. 创建 B端用户记录（暂不写入 token）
    $stmt = $db->prepare("
        INSERT INTO b_users (
            username, email, phone, password_hash, organization_name, 
            organization_leader, wallet_id, create_ip, status
        ) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
    ");
    $stmt->execute([
        $username,
        $email, 
        $phone ?: null, 
        $passwordHash, 
        $organizationName, 
        $organizationLeader, 
        $walletId, 
        $createIp
    ]);
    $userId = $db->lastInsertId();
    
    // 4. 生成 Token
    $tokenData = Token::generate($userId, Token::TYPE_B);
    
    // 5. 更新用户表的 token 字段
    $stmt = $db->prepare("
        UPDATE b_users 
        SET token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $userId]);
    
    // 提交事务
    $db->commit();
    
    // 6. 返回成功响应
    Response::success([
        'token' => $tokenData['token'],
        'user_id' => $userId,
        'username' => $username,
        'email' => $email,
        'phone' => $phone,
        'organization_name' => $organizationName,
        'organization_leader' => $organizationLeader,
        'wallet_id' => $walletId
    ], '注册成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('注册失败', $errorCodes['DATABASE_ERROR'], 500);
}

