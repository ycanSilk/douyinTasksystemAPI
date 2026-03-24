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

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');
$email = empty($email) ? null : $email; // 邮箱为空时设置为null
$phone = trim($input['phone'] ?? '');
$password = trim($input['password'] ?? '');
$captainInviteCode = strtoupper(trim($input['captain_invite_code'] ?? '')); // 团长邀请码
$developInviteCode = strtoupper(trim($input['develop_invite_code'] ?? '')); // 发展人邀请码

// 参数校验
error_log('开始参数校验');
if (empty($username)) {
    error_log('用户名不能为空');
    Response::error('用户名不能为空', 3005);
}

// 手机号必填且格式校验
if (empty($phone)) {
    error_log('手机号不能为空');
    Response::error('手机号不能为空', 3006);
}

// 简单的手机号格式校验（11位数字）
if (!preg_match('/^1[3-9]\d{9}$/', $phone)) {
    error_log('手机号格式不正确: ' . $phone);
    Response::error('手机号格式不正确', 3007);
}

if (empty($password)) {
    error_log('密码不能为空');
    Response::error('密码不能为空', 3008);
}

// 校验团长邀请码（如果提供）
$parentId = null;
if (!empty($captainInviteCode)) {
    // 校验邀请码格式
    if (!InviteCode::validate($captainInviteCode)) {
        error_log('团长邀请码格式错误: ' . $captainInviteCode);
        Response::error('团长邀请码格式错误，必须是6位数字字母组合', 6000);
    }
    error_log('团长邀请码格式校验通过: ' . $captainInviteCode);
}

// 校验发展人邀请码（如果提供）
$developerId = null;
$developerUsername = null;
if (!empty($developInviteCode)) {
    // 校验邀请码格式
    if (!InviteCode::validate($developInviteCode)) {
        error_log('发展人邀请码格式错误: ' . $developInviteCode);
        Response::error('发展人邀请码格式错误，必须是6位数字字母组合', 6000);
    }
    error_log('发展人邀请码格式校验通过: ' . $developInviteCode);
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
    Response::error('数据库连接失败', 1002, 500);
}

try {
    // 检查用户名是否已存在
    error_log('检查用户名是否已存在: ' . $username);
    $stmt = $db->prepare("SELECT id FROM c_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        error_log('用户名已被占用: ' . $username);
        Response::error('用户名已被占用', 3000);
    }
    error_log('用户名可用: ' . $username);
    
    // 检查邮箱是否已存在（如果提供了邮箱）
    if (!empty($email)) {
        error_log('检查邮箱是否已存在: ' . $email);
        $stmt = $db->prepare("SELECT id FROM c_users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            error_log('邮箱已被注册: ' . $email);
            Response::error('邮箱已被注册', 3001);
        }
        error_log('邮箱可用: ' . $email);
    }
    
    // 检查手机号是否已存在
    error_log('检查手机号是否已存在: ' . $phone);
    $stmt = $db->prepare("SELECT id FROM c_users WHERE phone = ?");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) {
        error_log('手机号已被注册: ' . $phone);
        Response::error('手机号已被注册', 3002);
    }
    error_log('手机号可用: ' . $phone);
    
    // 校验并查找团长用户（如果提供了团长邀请码）
    if (!empty($captainInviteCode)) {
        error_log('查找团长用户，邀请码: ' . $captainInviteCode);
        $stmt = $db->prepare("SELECT id FROM c_users WHERE invite_code = ?");
        $stmt->execute([$captainInviteCode]);
        $captain = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$captain) {
            error_log('团长邀请码不存在: ' . $captainInviteCode);
            Response::error('团长邀请码不存在', 6001);
        }
        
        $parentId = $captain['id'];
        error_log('团长用户找到，ID: ' . $parentId);
    }
    
    // 校验并查找发展人用户（如果提供了发展人邀请码）
    if (!empty($developInviteCode)) {
        error_log('查找发展人用户，邀请码: ' . $developInviteCode);
        $stmt = $db->prepare("SELECT id, username FROM c_users WHERE invite_code = ?");
        $stmt->execute([$developInviteCode]);
        $developer = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$developer) {
            error_log('发展人邀请码不存在: ' . $developInviteCode);
            Response::error('发展人邀请码不存在', 6001);
        }
        
        $developerId = $developer['id'];
        $developerUsername = $developer['username'];
        error_log('发展人用户找到，ID: ' . $developerId . ', 用户名: ' . $developerUsername);
    }
    
    // 开启事务
    error_log('开启事务');
    $db->beginTransaction();
    
    // 1. 密码哈希
    error_log('生成密码哈希');
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    error_log('密码哈希生成成功');
    
    // 2. 生成唯一邀请码
    error_log('生成唯一邀请码');
    $inviteCode = InviteCode::generate($db);
    error_log('邀请码生成成功: ' . $inviteCode);
    
    // 查询 C端用户最大登录设备数配置
    error_log('查询 C端用户最大登录设备数配置');
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'c_user_login_max_devices'");
    $stmt->execute();
    $maxDevicesConfig = $stmt->fetchColumn();
    $maxDevices = $maxDevicesConfig ? (int)$maxDevicesConfig : 1; // 默认值为1
    error_log('C端用户最大登录设备数: ' . $maxDevices);
    
    // 3. 先创建 C端用户记录（不关联钱包，因为钱包还没创建）
    error_log('创建 C端用户记录');
    $stmt = $db->prepare("
        INSERT INTO c_users (
            username, email, phone, password_hash, invite_code, 
            parent_id, is_agent, wallet_id, create_ip, status, max_devices
        ) 
        VALUES (?, ?, ?, ?, ?, ?, 0, NULL, ?, 1, ?)
    ");
    error_log('执行用户插入，参数: ' . json_encode([
        $username,
        $email, 
        $phone, 
        '***', // 密码哈希不记录
        $inviteCode,
        $parentId,
        $createIp,
        $maxDevices
    ]));
    $stmt->execute([
        $username,
        $email, 
        $phone, 
        $passwordHash,
        $inviteCode,
        $parentId,
        $createIp,
        $maxDevices
    ]);
    $userId = $db->lastInsertId();
    error_log('用户创建成功，ID: ' . $userId);
    
    // 4. 创建钱包记录（此时用户已存在，可以直接使用正确的user_id）
    error_log('创建钱包记录');
    $stmt = $db->prepare("INSERT INTO wallets (balance, username, user_id, user_type) VALUES (0, ?, ?, 1)");
    $stmt->execute([$username, $userId]);
    $walletId = $db->lastInsertId();
    error_log('钱包创建成功，ID: ' . $walletId);
    
    // 5. 更新用户记录的钱包ID
    $stmt = $db->prepare("UPDATE c_users SET wallet_id = ? WHERE id = ?");
    $stmt->execute([$walletId, $userId]);
    error_log('用户钱包ID更新成功: ' . $walletId);
    
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
    
    // 8. 创建发展下线关系（如果提供了发展人邀请码）
    if ($developerId) {
        error_log('创建发展下线关系，发展人ID: ' . $developerId . ', 下线ID: ' . $userId);
        $stmt = $db->prepare("INSERT INTO develop_downline_users_count (developer_user_id, developer_username, developer_invite_code, downline_user_id, downline_username, downline_invite_code) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$developerId, $developerUsername, $developInviteCode, $userId, $username, $inviteCode]);
        error_log('发展下线关系创建成功');
    }
    
    // 8. 插入用户任务静态记录
    error_log('插入用户任务静态记录，用户ID: ' . $userId);
    $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, completed_task_count, rejected_task_count, abandoned_task_count, appeal_task_count) VALUES (?, 0, 0, 0, 0)");
    $stmt->execute([$userId]);
    error_log('用户任务静态记录创建成功');
    
    // 9. 插入用户当日统计记录
    error_log('插入用户当日统计记录，用户ID: ' . $userId);
    $today = date('Y-m-d');
    $stmt = $db->prepare("INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, approved_count, rejected_count, abandon_count) VALUES (?, ?, 0, 0, 0, 0)");
    $stmt->execute([$userId, $today]);
    error_log('用户当日统计记录创建成功');
    
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
        'captain_id' => $parentId,
        'developer_id' => $developerId,
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
    Response::error('注册失败', 1002, 500);
}

