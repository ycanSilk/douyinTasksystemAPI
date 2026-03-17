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
 *   "phone": "string (必填)",
 *   "password": "string (必填)",
 *   "parent_invite_code": "string (选填，6位邀请码)"
 * }
 */

// 输出详细日志
error_log('=== C端用户注册接口调用开始 ===');
error_log('请求方法: ' . $_SERVER['REQUEST_METHOD']);
error_log('请求IP: ' . ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知'));

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    error_log('请求方法错误: ' . $_SERVER['REQUEST_METHOD']);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 记录请求体
try {
    $requestBody = file_get_contents('php://input');
    error_log('请求体: ' . $requestBody);
} catch (Exception $e) {
    error_log('读取请求体失败: ' . $e->getMessage());
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
$email = empty($email) ? null : $email; // 邮箱为空时设置为null
$phone = trim($input['phone'] ?? '');
$password = trim($input['password'] ?? '');
$parentInviteCode = strtoupper(trim($input['parent_invite_code'] ?? '')); // 转大写

// 参数校验
error_log('开始参数校验');
if (empty($username)) {
    error_log('用户名不能为空');
    Response::error('用户名不能为空', $errorCodes['USER_USERNAME_EMPTY']);
}

// 手机号必填且格式校验
if (empty($phone)) {
    error_log('手机号不能为空');
    Response::error('手机号不能为空', $errorCodes['USER_PHONE_EMPTY']);
}

// 简单的手机号格式校验（11位数字）
if (!preg_match('/^1[3-9]\d{9}$/', $phone)) {
    error_log('手机号格式不正确: ' . $phone);
    Response::error('手机号格式不正确', $errorCodes['USER_PHONE_INVALID']);
}

if (empty($password)) {
    error_log('密码不能为空');
    Response::error('密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

// 校验邀请码（如果提供）
$parentId = null;
if (!empty($parentInviteCode)) {
    // 校验邀请码格式
    if (!InviteCode::validate($parentInviteCode)) {
        error_log('邀请码格式错误: ' . $parentInviteCode);
        Response::error('邀请码格式错误，必须是6位数字字母组合', $errorCodes['INVITE_CODE_INVALID']);
    }
    error_log('邀请码格式校验通过: ' . $parentInviteCode);
}

// 获取客户端 IP
$createIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';
error_log('客户端IP: ' . $createIp);

// 数据库连接
try {
    $db = Database::connect();
    error_log('数据库连接成功');
} catch (Exception $e) {
    error_log('数据库连接失败: ' . $e->getMessage());
    Response::error('数据库连接失败', $errorCodes['DATABASE_ERROR'], 500);
}

try {
    // 检查用户名是否已存在
    error_log('检查用户名是否已存在: ' . $username);
    $stmt = $db->prepare("SELECT id FROM c_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        error_log('用户名已被占用: ' . $username);
        Response::error('用户名已被占用', $errorCodes['USER_USERNAME_EXISTS']);
    }
    error_log('用户名可用: ' . $username);
    
    // 检查邮箱是否已存在（如果提供了邮箱）
    if (!empty($email)) {
        error_log('检查邮箱是否已存在: ' . $email);
        $stmt = $db->prepare("SELECT id FROM c_users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            error_log('邮箱已被注册: ' . $email);
            Response::error('邮箱已被注册', $errorCodes['USER_EMAIL_EXISTS']);
        }
        error_log('邮箱可用: ' . $email);
    }
    
    // 检查手机号是否已存在
    error_log('检查手机号是否已存在: ' . $phone);
    $stmt = $db->prepare("SELECT id FROM c_users WHERE phone = ?");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) {
        error_log('手机号已被注册: ' . $phone);
        Response::error('手机号已被注册', $errorCodes['USER_PHONE_EXISTS']);
    }
    error_log('手机号可用: ' . $phone);
    
    // 校验并查找上级用户（如果提供了邀请码）
    if (!empty($parentInviteCode)) {
        error_log('查找上级用户，邀请码: ' . $parentInviteCode);
        $stmt = $db->prepare("SELECT id FROM c_users WHERE invite_code = ?");
        $stmt->execute([$parentInviteCode]);
        $parent = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$parent) {
            error_log('邀请码不存在: ' . $parentInviteCode);
            Response::error('邀请码不存在', $errorCodes['INVITE_CODE_NOT_FOUND']);
        }
        
        $parentId = $parent['id'];
        error_log('上级用户找到，ID: ' . $parentId);
    }
    
    // 开启事务
    error_log('开启事务');
    $db->beginTransaction();
    
    // 1. 创建钱包记录
    error_log('创建钱包记录');
    $stmt = $db->prepare("INSERT INTO wallets (balance) VALUES (0)");
    $stmt->execute();
    $walletId = $db->lastInsertId();
    error_log('钱包创建成功，ID: ' . $walletId);
    
    // 2. 密码哈希
    error_log('生成密码哈希');
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    error_log('密码哈希生成成功');
    
    // 3. 生成唯一邀请码
    error_log('生成唯一邀请码');
    $inviteCode = InviteCode::generate($db);
    error_log('邀请码生成成功: ' . $inviteCode);
    
    // 4. 创建 C端用户记录（暂不写入 token）
    error_log('创建 C端用户记录');
    $stmt = $db->prepare("
        INSERT INTO c_users (
            username, email, phone, password_hash, invite_code, 
            parent_id, is_agent, wallet_id, create_ip, status
        ) 
        VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, 1)
    ");
    error_log('执行用户插入，参数: ' . json_encode([
        $username,
        $email, 
        $phone, 
        '***', // 密码哈希不记录
        $inviteCode,
        $parentId,
        $walletId, 
        $createIp
    ]));
    $stmt->execute([
        $username,
        $email, 
        $phone, 
        $passwordHash,
        $inviteCode,
        $parentId,
        $walletId, 
        $createIp
    ]);
    $userId = $db->lastInsertId();
    error_log('用户创建成功，ID: ' . $userId);
    
    // 5. 生成 Token
    error_log('生成 Token');
    $tokenData = Token::generate($userId, Token::TYPE_C);
    error_log('Token生成成功: ' . $tokenData['token']);
    
    // 6. 更新用户表的 token 字段
    error_log('更新用户表的 token 字段');
    $stmt = $db->prepare("
        UPDATE c_users 
        SET token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $userId]);
    error_log('Token更新成功');
    
    // 7. 创建团队关系
    if ($parentId) {
        error_log('创建团队关系，用户ID: ' . $userId . ', 上级ID: ' . $parentId);
        // 插入一级代理关系
        $stmt = $db->prepare("INSERT INTO c_user_relations (user_id, agent_id, level) VALUES (?, ?, 1)");
        $stmt->execute([$userId, $parentId]);
        error_log('一级代理关系创建成功');
        
        // 查询祖父ID
        $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
        $stmt->execute([$parentId]);
        $grandparentId = $stmt->fetchColumn();
        
        // 插入二级代理关系
        if ($grandparentId) {
            error_log('创建二级代理关系，用户ID: ' . $userId . ', 祖父ID: ' . $grandparentId);
            $stmt = $db->prepare("INSERT INTO c_user_relations (user_id, agent_id, level) VALUES (?, ?, 2)");
            $stmt->execute([$userId, $grandparentId]);
            error_log('二级代理关系创建成功');
        }
    }
    
    // 提交事务
    error_log('提交事务');
    $db->commit();
    error_log('事务提交成功');
    
    // 7. 返回成功响应
    error_log('注册成功，返回响应');
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
        error_log('发生异常，回滚事务');
        $db->rollBack();
    }
    
    error_log('PDO异常: ' . $e->getMessage());
    error_log('异常文件: ' . $e->getFile());
    error_log('异常行号: ' . $e->getLine());
    Response::error('注册失败', $errorCodes['DATABASE_ERROR'], 500);
}

