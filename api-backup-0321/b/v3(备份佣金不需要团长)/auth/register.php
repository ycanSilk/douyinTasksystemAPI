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

// 日志函数
function logDebug($message) {
    $timestamp = date('Y-m-d H:i:s');
    error_log("[{$timestamp}] [DEBUG] {$message}");
}

header('Content-Type: application/json; charset=utf-8');

// 记录请求开始
logDebug('=== B端用户注册请求开始 ===');
logDebug('请求地址: ' . $_SERVER['REQUEST_URI']);
logDebug('请求方法: ' . $_SERVER['REQUEST_METHOD']);
logDebug('客户端IP: ' . ($_SERVER['REMOTE_ADDR'] ?? '未知'));

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
$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true);
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$password = trim($input['password'] ?? '');
$organizationName = trim($input['organization_name'] ?? '');
$organizationLeader = trim($input['organization_leader'] ?? '');

// 记录请求参数
logDebug('请求体: ' . $rawInput);
logDebug('用户名: ' . $username);
logDebug('邮箱: ' . $email);
logDebug('手机号: ' . $phone);
logDebug('组织名称: ' . $organizationName);
logDebug('组织负责人: ' . $organizationLeader);

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
logDebug('数据库连接成功');

try {
    // 检查用户名是否已存在
    logDebug('检查用户名是否已存在');
    $stmt = $db->prepare("SELECT id FROM b_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        logDebug('用户名已被占用: ' . $username);
        Response::error('用户名已被占用', $errorCodes['USER_USERNAME_EXISTS']);
    }
    logDebug('用户名可用: ' . $username);
    
    // 检查邮箱是否已存在
    logDebug('检查邮箱是否已存在');
    $stmt = $db->prepare("SELECT id FROM b_users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        logDebug('邮箱已被注册: ' . $email);
        Response::error('邮箱已被注册', $errorCodes['USER_EMAIL_EXISTS']);
    }
    logDebug('邮箱可用: ' . $email);
    
    // 检查手机号是否已存在（如果提供了手机号）
    if (!empty($phone)) {
        logDebug('检查手机号是否已存在');
        $stmt = $db->prepare("SELECT id FROM b_users WHERE phone = ?");
        $stmt->execute([$phone]);
        if ($stmt->fetch()) {
            logDebug('手机号已被注册: ' . $phone);
            Response::error('手机号已被注册', $errorCodes['USER_PHONE_EXISTS']);
        }
        logDebug('手机号可用: ' . $phone);
    }
    
    // 开启事务
    logDebug('开启事务');
    $db->beginTransaction();
    
    // 1. 密码哈希
    logDebug('生成密码哈希');
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    // 2. 先创建 B端用户记录（wallet_id设置为null）
    logDebug('创建B端用户记录');
    $stmt = $db->prepare("INSERT INTO b_users (username, email, phone, password_hash, organization_name, organization_leader, wallet_id, create_ip, status) VALUES (?, ?, ?, ?, ?, ?, NULL, ?, 1)");
    $result = $stmt->execute([$username, $email, $phone ?: null, $passwordHash, $organizationName, $organizationLeader, $createIp]);
    logDebug('创建B端用户结果: ' . ($result ? '成功' : '失败'));
    $userId = $db->lastInsertId();
    logDebug('生成的用户ID: ' . $userId);
    
    // 3. 创建钱包记录（此时用户已存在，可以直接使用正确的user_id）
    logDebug('创建钱包记录');
    $stmt = $db->prepare("INSERT INTO wallets (balance, username, user_id, user_type) VALUES (0, ?, ?, 2)");
    $result = $stmt->execute([$username, $userId]);
    logDebug('创建钱包结果: ' . ($result ? '成功' : '失败'));
    $walletId = $db->lastInsertId();
    logDebug('生成的钱包ID: ' . $walletId);
    
    // 4. 更新用户记录的钱包ID
    logDebug('更新用户记录的钱包ID');
    $stmt = $db->prepare("UPDATE b_users SET wallet_id = ? WHERE id = ?");
    $result = $stmt->execute([$walletId, $userId]);
    logDebug('更新钱包ID结果: ' . ($result ? '成功' : '失败'));
    
    // 5. 生成 Token
    logDebug('生成Token');
    $tokenData = Token::generate($userId, Token::TYPE_B);
    logDebug('Token生成成功: ' . $tokenData['token']);
    logDebug('Token过期时间: ' . $tokenData['expired_at']);
    
    // 6. 更新用户表的 token 字段
    logDebug('更新用户表的token字段');
    $stmt = $db->prepare("UPDATE b_users SET token = ?, token_expired_at = ? WHERE id = ?");
    $result = $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $userId]);
    logDebug('更新token结果: ' . ($result ? '成功' : '失败'));
    
    // 7. 插入快捷派单配置记录
    logDebug('插入快捷派单配置记录');
    $stmt = $db->prepare("INSERT INTO quick_task_info_config (b_user_id, username, config_info) VALUES (?, ?, ?)");
    $result = $stmt->execute([$userId, $username, NULL]);
    logDebug('插入配置记录结果: ' . ($result ? '成功' : '失败'));
    
    // 提交事务
    logDebug('提交事务');
    $db->commit();
    logDebug('事务提交成功');
    
    // 8. 返回成功响应
    logDebug('返回成功响应');
    $responseData = [
        'token' => $tokenData['token'],
        'user_id' => $userId,
        'username' => $username,
        'email' => $email,
        'phone' => $phone,
        'organization_name' => $organizationName,
        'organization_leader' => $organizationLeader,
        'wallet_id' => $walletId
    ];
    logDebug('响应数据: ' . json_encode($responseData));
    Response::success($responseData, '注册成功');
    logDebug('=== B端用户注册请求结束 ===');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        logDebug('回滚事务');
        $db->rollBack();
    }
    logDebug('数据库错误: ' . $e->getMessage());
    logDebug('SQL状态: ' . $e->getCode());
    logDebug('=== B端用户注册请求结束 ===');
    Response::error('注册失败', $errorCodes['DATABASE_ERROR'], 500);
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        logDebug('回滚事务');
        $db->rollBack();
    }
    logDebug('系统错误: ' . $e->getMessage());
    logDebug('=== B端用户注册请求结束 ===');
    Response::error('注册失败', $errorCodes['SYSTEM_ERROR'], 500);
}

