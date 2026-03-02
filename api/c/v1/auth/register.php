<?php
/**
 * C端用户注册接口
 * 
 * POST /api/c/v1/auth/register
 * 
 * 请求体：
 * {
 *   "username": "string (必填)",
 *   "email": "string (选填)",
 *   "phone": "string (选填)",
 *   "password": "string (必填)",
 *   "parent_invite_code": "string (选填，6位邀请码)"
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
require_once __DIR__ . '/../../../../core/InviteCode.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$password = trim($input['password'] ?? '');
$parentInviteCode = strtoupper(trim($input['parent_invite_code'] ?? '')); // 转大写

// 参数校验
if (empty($username)) {
    Response::error('用户名不能为空', $errorCodes['USER_USERNAME_EMPTY']);
}

// 邮箱可选，只在不为空时校验格式
if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('邮箱格式不正确', $errorCodes['USER_EMAIL_INVALID']);
}

if (empty($password)) {
    Response::error('密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

// 校验邀请码（如果提供）
$parentId = null;
if (!empty($parentInviteCode)) {
    // 校验邀请码格式
    if (!InviteCode::validate($parentInviteCode)) {
        Response::error('邀请码格式错误，必须是6位数字字母组合', $errorCodes['INVITE_CODE_INVALID']);
    }
}

// 获取客户端 IP
$createIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';

// 数据库连接
$db = Database::connect();

try {
    // 检查用户名是否已存在
    $stmt = $db->prepare("SELECT id FROM c_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        Response::error('用户名已被占用', $errorCodes['USER_USERNAME_EXISTS']);
    }
    
    // 检查邮箱是否已存在（如果提供了邮箱）
    if (!empty($email)) {
        $stmt = $db->prepare("SELECT id FROM c_users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            Response::error('邮箱已被注册', $errorCodes['USER_EMAIL_EXISTS']);
        }
    }
    
    // 检查手机号是否已存在（如果提供了手机号）
    if (!empty($phone)) {
        $stmt = $db->prepare("SELECT id FROM c_users WHERE phone = ?");
        $stmt->execute([$phone]);
        if ($stmt->fetch()) {
            Response::error('手机号已被注册', $errorCodes['USER_PHONE_EXISTS']);
        }
    }
    
    // 校验并查找上级用户（如果提供了邀请码）
    if (!empty($parentInviteCode)) {
        $stmt = $db->prepare("SELECT id FROM c_users WHERE invite_code = ?");
        $stmt->execute([$parentInviteCode]);
        $parent = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$parent) {
            Response::error('邀请码不存在', $errorCodes['INVITE_CODE_NOT_FOUND']);
        }
        
        $parentId = $parent['id'];
    }
    
    // 开启事务
    $db->beginTransaction();
    
    // 1. 创建钱包记录
    $stmt = $db->prepare("INSERT INTO wallets (balance) VALUES (0)");
    $stmt->execute();
    $walletId = $db->lastInsertId();
    
    // 2. 密码哈希
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    // 3. 生成唯一邀请码
    $inviteCode = InviteCode::generate($db);
    
    // 4. 创建 C端用户记录（暂不写入 token）
    $stmt = $db->prepare("
        INSERT INTO c_users (
            username, email, phone, password_hash, invite_code, 
            parent_id, is_agent, wallet_id, create_ip, status
        ) 
        VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, 1)
    ");
    $stmt->execute([
        $username,
        $email, 
        $phone ?: null, 
        $passwordHash,
        $inviteCode,
        $parentId,
        $walletId, 
        $createIp
    ]);
    $userId = $db->lastInsertId();
    
    // 5. 生成 Token
    $tokenData = Token::generate($userId, Token::TYPE_C);
    
    // 6. 更新用户表的 token 字段
    $stmt = $db->prepare("
        UPDATE c_users 
        SET token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $userId]);
    
    // 提交事务
    $db->commit();
    
    // 7. 返回成功响应
    Response::success([
        'token' => $tokenData['token'],
        'user_id' => $userId,
        'username' => $username,
        'email' => $email,
        'phone' => $phone,
        'invite_code' => $inviteCode,
        'parent_id' => $parentId,
        'is_agent' => 0,
        'wallet_id' => $walletId
    ], '注册成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('注册失败', $errorCodes['DATABASE_ERROR'], 500);
}

