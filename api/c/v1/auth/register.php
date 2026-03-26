<?php
/**
 * C端用户注册接口
 * 
 * POST /api/c/v1/auth/register
 * 
 * 请求头：
 * Content-Type: application/json
 * 
 * 请求体：
 * {
 *   "username": "string (必填)",
 *   "email": "string (选填)",
 *   "phone": "string (必填)",
 *   "password": "string (必填)",
 *   "captain_invite_code": "string (必填，6位邀请码，团长邀请码)",
 *   "develop_invite_code": "string (选填，6位邀请码，发展人邀请码)"
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "注册成功",
 *   "data": {
 *     "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
 *     "user_id": 123,
 *     "username": "testuser",
 *     "email": "test@example.com",
 *     "phone": "13800138000",
 *     "invite_code": "ABC123",
 *     "captain_id": 456,
 *     "developer_id": 789,
 *     "is_agent": 0,
 *     "wallet_id": 321
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 3005,
 *   "message": "用户名不能为空",
 *   "data": [],
 *   "timestamp": 1736582400
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 1002 - 注册失败
 * 3000 - 用户名已被占用
 * 3001 - 邮箱已被注册
 * 3002 - 手机号已被注册
 * 3005 - 用户名不能为空
 * 3006 - 手机号不能为空
 * 3007 - 手机号格式不正确
 * 3008 - 密码不能为空
 * 3009 - 团长邀请码不能为空
 * 6000 - 邀请码格式错误
 * 6001 - 邀请码不存在
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('c/v1/auth/register');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== C端用户注册接口调用开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 记录请求体
try {
    $requestBody = file_get_contents('php://input');
    $requestLogger->debug('请求体', ['body' => $requestBody]);
} catch (Exception $e) {
    $errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()]);
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
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
$requestLogger->debug('开始参数校验');
if (empty($username)) {
    $requestLogger->warning('用户名不能为空');
    echo json_encode([
        'code' => 3005,
        'message' => '用户名不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 手机号必填且格式校验
if (empty($phone)) {
    $requestLogger->warning('手机号不能为空');
    echo json_encode([
        'code' => 3006,
        'message' => '手机号不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 简单的手机号格式校验（11位数字）
if (!preg_match('/^1[3-9]\d{9}$/', $phone)) {
    $requestLogger->warning('手机号格式不正确', ['phone' => $phone]);
    echo json_encode([
        'code' => 3007,
        'message' => '手机号格式不正确',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($password)) {
    $requestLogger->warning('密码不能为空');
    echo json_encode([
        'code' => 3008,
        'message' => '密码不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 校验团长邀请码（必填）
$parentId = null;
if (empty($captainInviteCode)) {
    $requestLogger->warning('团长邀请码不能为空');
    echo json_encode([
        'code' => 3009,
        'message' => '团长邀请码不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 校验邀请码格式
if (!InviteCode::validate($captainInviteCode)) {
    $requestLogger->warning('团长邀请码格式错误', ['code' => $captainInviteCode]);
    echo json_encode([
        'code' => 6000,
        'message' => '团长邀请码错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
$requestLogger->debug('团长邀请码格式校验通过', ['code' => $captainInviteCode]);

// 校验发展人邀请码（如果提供）
$developerId = null;
$developerUsername = null;
if (!empty($developInviteCode)) {
    // 校验邀请码格式
    if (!InviteCode::validate($developInviteCode)) {
        $requestLogger->warning('发展人邀请码格式错误', ['code' => $developInviteCode]);
        echo json_encode([
            'code' => 6000,
            'message' => '发展人邀请码错误',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('发展人邀请码格式校验通过', ['code' => $developInviteCode]);
}

// 获取客户端 IP
$createIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';
$requestLogger->debug('客户端IP: ' . $createIp);

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
    echo json_encode([
        'code' => 1002,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查用户名是否已存在
    $requestLogger->debug('检查用户名是否已存在', ['username' => $username]);
    $stmt = $db->prepare("SELECT id FROM c_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        $requestLogger->warning('用户名已被占用', ['username' => $username]);
        echo json_encode([
            'code' => 3000,
            'message' => '用户名已被占用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('用户名可用', ['username' => $username]);
    
    // 检查邮箱是否已存在（如果提供了邮箱）
    if (!empty($email)) {
        $requestLogger->debug('检查邮箱是否已存在', ['email' => $email]);
        $stmt = $db->prepare("SELECT id FROM c_users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            $requestLogger->warning('邮箱已被注册', ['email' => $email]);
            echo json_encode([
                'code' => 3001,
                'message' => '邮箱已被注册',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        $requestLogger->debug('邮箱可用', ['email' => $email]);
    }
    
    // 检查手机号是否已存在
    $requestLogger->debug('检查手机号是否已存在', ['phone' => $phone]);
    $stmt = $db->prepare("SELECT id FROM c_users WHERE phone = ?");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) {
        $requestLogger->warning('手机号已被注册', ['phone' => $phone]);
        echo json_encode([
            'code' => 3002,
            'message' => '手机号已被注册',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('手机号可用', ['phone' => $phone]);
    
    // 校验并查找团长用户（如果提供了团长邀请码）
    if (!empty($captainInviteCode)) {
        $requestLogger->debug('查找团长用户', ['invite_code' => $captainInviteCode]);
        $stmt = $db->prepare("SELECT id FROM c_users WHERE invite_code = ?");
        $stmt->execute([$captainInviteCode]);
        $captain = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$captain) {
            $requestLogger->warning('团长邀请码不存在', ['invite_code' => $captainInviteCode]);
            echo json_encode([
                'code' => 6001,
                'message' => '团长邀请码不存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $parentId = $captain['id'];
        $requestLogger->debug('团长用户找到', ['captain_id' => $parentId]);
    }
    
    // 校验并查找发展人用户（如果提供了发展人邀请码）
    if (!empty($developInviteCode)) {
        $requestLogger->debug('查找发展人用户', ['invite_code' => $developInviteCode]);
        $stmt = $db->prepare("SELECT id, username FROM c_users WHERE invite_code = ?");
        $stmt->execute([$developInviteCode]);
        $developer = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$developer) {
            $requestLogger->warning('发展人邀请码不存在', ['invite_code' => $developInviteCode]);
            echo json_encode([
                'code' => 6001,
                'message' => '发展人邀请码不存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $developerId = $developer['id'];
        $developerUsername = $developer['username'];
        $requestLogger->debug('发展人用户找到', ['developer_id' => $developerId, 'developer_username' => $developerUsername]);
    }
    
    // 开启事务
    $requestLogger->debug('开启事务');
    $db->beginTransaction();
    
    // 1. 密码哈希
    $requestLogger->debug('生成密码哈希');
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    $requestLogger->debug('密码哈希生成成功');
    
    // 2. 生成唯一邀请码
    $requestLogger->debug('生成唯一邀请码');
    $inviteCode = InviteCode::generate($db);
    $requestLogger->debug('邀请码生成成功', ['invite_code' => $inviteCode]);
    
    // 查询 C端用户最大登录设备数配置
    $requestLogger->debug('查询 C端用户最大登录设备数配置');
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'c_user_login_max_devices'");
    $stmt->execute();
    $maxDevicesConfig = $stmt->fetchColumn();
    $maxDevices = $maxDevicesConfig ? (int)$maxDevicesConfig : 1; // 默认值为1
    $requestLogger->debug('C端用户最大登录设备数', ['max_devices' => $maxDevices]);
    
    // 3. 先创建 C端用户记录（不关联钱包，因为钱包还没创建）
    $requestLogger->debug('创建 C端用户记录');
    $stmt = $db->prepare("
        INSERT INTO c_users (
            username, email, phone, password_hash, invite_code, 
            parent_id, is_agent, wallet_id, create_ip, status, max_devices
        ) 
        VALUES (?, ?, ?, ?, ?, ?, 0, NULL, ?, 1, ?)
    ");
    $requestLogger->debug('执行用户插入', [
        'username' => $username,
        'email' => $email, 
        'phone' => $phone, 
        'invite_code' => $inviteCode,
        'parent_id' => $parentId,
        'create_ip' => $createIp,
        'max_devices' => $maxDevices
    ]);
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
    $requestLogger->info('用户创建成功', ['user_id' => $userId]);
    
    // 4. 创建钱包记录（此时用户已存在，可以直接使用正确的user_id）
    $requestLogger->debug('创建钱包记录');
    $stmt = $db->prepare("INSERT INTO wallets (balance, username, user_id, user_type) VALUES (0, ?, ?, 1)");
    $stmt->execute([$username, $userId]);
    $walletId = $db->lastInsertId();
    $requestLogger->debug('钱包创建成功', ['wallet_id' => $walletId]);
    
    // 5. 更新用户记录的钱包ID
    $stmt = $db->prepare("UPDATE c_users SET wallet_id = ? WHERE id = ?");
    $stmt->execute([$walletId, $userId]);
    $requestLogger->debug('用户钱包ID更新成功', ['wallet_id' => $walletId]);
    
    // 5. 生成 Token
    $requestLogger->debug('生成 Token');
    $tokenData = Token::generate($userId, Token::TYPE_C);
    $requestLogger->debug('Token生成成功', ['token' => $tokenData['token']]);
    
    // 6. 更新用户表的 token 字段
    $requestLogger->debug('更新用户表的 token 字段');
    $stmt = $db->prepare("
        UPDATE c_users 
        SET token = ?, token_expired_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $userId]);
    $requestLogger->debug('Token更新成功');
    
    // 7. 创建团队关系
    if ($parentId) {
        $requestLogger->debug('创建团队关系', ['user_id' => $userId, 'parent_id' => $parentId]);
        // 插入一级代理关系
        $stmt = $db->prepare("INSERT INTO c_user_relations (user_id, agent_id, level) VALUES (?, ?, 1)");
        $stmt->execute([$userId, $parentId]);
        $requestLogger->debug('一级代理关系创建成功');
        
        // 查询祖父ID
        $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
        $stmt->execute([$parentId]);
        $grandparentId = $stmt->fetchColumn();
        
        // 插入二级代理关系
        if ($grandparentId) {
            $requestLogger->debug('创建二级代理关系', ['user_id' => $userId, 'grandparent_id' => $grandparentId]);
            $stmt = $db->prepare("INSERT INTO c_user_relations (user_id, agent_id, level) VALUES (?, ?, 2)");
            $stmt->execute([$userId, $grandparentId]);
            $requestLogger->debug('二级代理关系创建成功');
        }
    }
    
    // 8. 创建发展下线关系（如果提供了发展人邀请码）
    if ($developerId) {
        $requestLogger->debug('创建发展下线关系', ['developer_id' => $developerId, 'user_id' => $userId]);
        $stmt = $db->prepare("INSERT INTO develop_downline_users_count (developer_user_id, developer_username, developer_invite_code, downline_user_id, downline_username, downline_invite_code) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$developerId, $developerUsername, $developInviteCode, $userId, $username, $inviteCode]);
        $requestLogger->debug('发展下线关系创建成功');
    }
    
    // 8. 插入用户任务静态记录
    $requestLogger->debug('插入用户任务静态记录', ['user_id' => $userId]);
    $stmt = $db->prepare("INSERT INTO c_user_task_records_static (user_id, completed_task_count, rejected_task_count, abandoned_task_count, appeal_task_count) VALUES (?, 0, 0, 0, 0)");
    $stmt->execute([$userId]);
    $requestLogger->debug('用户任务静态记录创建成功');
    
    // 9. 插入用户当日统计记录
    $requestLogger->debug('插入用户当日统计记录', ['user_id' => $userId]);
    $today = date('Y-m-d');
    $stmt = $db->prepare("INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, approved_count, rejected_count, abandon_count) VALUES (?, ?, 0, 0, 0, 0)");
    $stmt->execute([$userId, $today]);
    $requestLogger->debug('用户当日统计记录创建成功');
    
    // 提交事务
    $requestLogger->debug('提交事务');
    $db->commit();
    $requestLogger->debug('事务提交成功');
    
    // 记录审计日志
    $auditLogger->notice('C端用户注册成功', [
        'user_id' => $userId,
        'username' => $username,
        'phone' => $phone,
        'email' => $email,
        'invite_code' => $inviteCode,
        'captain_id' => $parentId,
        'developer_id' => $developerId
    ]);
    
    // 7. 返回成功响应
    $requestLogger->debug('注册成功，返回响应');
    echo json_encode([
        'code' => 0,
        'message' => '注册成功',
        'data' => [
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
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('发生异常，回滚事务');
        $db->rollBack();
    }
    
    $errorLogger->error('PDO异常', [
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 1002,
        'message' => '注册失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    // 回滚事务
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('发生异常，回滚事务');
        $db->rollBack();
    }
    
    $errorLogger->error('注册失败', [
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    echo json_encode([
        'code' => 1002,
        'message' => '注册失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}

