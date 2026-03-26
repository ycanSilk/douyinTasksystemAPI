<?php
/**
 * B 端用户注册接口
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
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 2001 - 用户名不能为空
 * 2002 - 邮箱不能为空
 * 2003 - 邮箱格式不正确
 * 2004 - 密码不能为空
 * 2005 - 组织名称不能为空
 * 2006 - 组织负责人名称不能为空
 * 2007 - 用户名已被占用
 * 2008 - 邮箱已被注册
 * 2009 - 手机号已被注册
 * 5001 - 数据库错误
 * 5002 - 系统错误
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/auth/register');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');


// 记录请求开始
$requestLogger->info('=== B 端用户注册请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);


header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：请求方法错误', [
        'method' => $_SERVER['REQUEST_METHOD'],
        'reason' => '请求方法错误',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
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
    $rawInput = file_get_contents('php://input');
    $requestLogger->debug('请求体内容', ['body' => $rawInput]);
} catch (Exception $e) {
    $errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户注册失败：读取请求体失败', [
        'exception' => $e->getMessage(),
        'reason' => '读取请求体失败',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    $rawInput = '';
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户注册失败：数据库连接失败', [
        'exception' => $e->getMessage(),
        'reason' => '数据库连接失败',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 5001,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 获取请求参数
$input = json_decode($rawInput, true);
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$password = trim($input['password'] ?? '');
$organizationName = trim($input['organization_name'] ?? '');
$organizationLeader = trim($input['organization_leader'] ?? '');

// 记录请求参数（敏感信息脱敏）
$requestLogger->debug('请求参数', [
    'username' => $username,
    'email' => $email,
    'phone' => $phone,
    'organization_name' => $organizationName,
    'organization_leader' => $organizationLeader,
]);

// 参数校验
if (empty($username)) {
    $requestLogger->warning('用户名为空', ['username' => $username]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：用户名为空', [
        'username' => $username,
        'reason' => '用户名不能为空',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 2001,
        'message' => '用户名不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($email)) {
    $requestLogger->warning('邮箱为空', ['email' => $email]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：邮箱为空', [
        'email' => $email,
        'reason' => '邮箱不能为空',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 2002,
        'message' => '邮箱不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $requestLogger->warning('邮箱格式无效', ['email' => $email]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：邮箱格式无效', [
        'email' => $email,
        'reason' => '邮箱格式不正确',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 2003,
        'message' => '邮箱格式不正确',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($password)) {
    $requestLogger->warning('密码为空', ['password' => $password]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：密码为空', [
        'reason' => '密码不能为空',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 2004,
        'message' => '密码不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($organizationName)) {
    $requestLogger->warning('组织名称为空', ['organization_name' => $organizationName]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：组织名称为空', [
        'organization_name' => $organizationName,
        'reason' => '组织名称不能为空',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 2005,
        'message' => '组织名称不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($organizationLeader)) {
    $requestLogger->warning('组织负责人名称为空', ['organization_leader' => $organizationLeader]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户注册失败：组织负责人名称为空', [
        'organization_leader' => $organizationLeader,
        'reason' => '组织负责人名称不能为空',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 2006,
        'message' => '组织负责人名称不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 获取客户端 IP
$createIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';

try {
    // 检查用户名是否已存在
    $requestLogger->debug('检查用户名是否已存在', ['username' => $username]);
    $stmt = $db->prepare("SELECT id FROM b_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        $requestLogger->warning('用户名已被占用', ['username' => $username]);
        
        // 记录审计日志
        $auditLogger->warning('B 端用户注册失败：用户名已被占用', [
            'username' => $username,
            'email' => $email,
            'reason' => '用户名已被占用',
        ]);
        
        // 手动刷新异步队列
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        
        echo json_encode(['code' => 2007, 'message' => '用户名已被占用', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('用户名可用', ['username' => $username]);
    
    // 检查邮箱是否已存在
    $requestLogger->debug('检查邮箱是否已存在', ['email' => $email]);
    $stmt = $db->prepare("SELECT id FROM b_users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $requestLogger->warning('邮箱已被注册', ['email' => $email]);
        
        // 记录审计日志
        $auditLogger->warning('B 端用户注册失败：邮箱已被注册', [
            'username' => $username,
            'email' => $email,
            'reason' => '邮箱已被注册',
        ]);
        
        // 手动刷新异步队列
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        
        echo json_encode(['code' => 2008, 'message' => '邮箱已被注册', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $requestLogger->debug('邮箱可用', ['email' => $email]);
    
    // 检查手机号是否已存在（如果提供了手机号）
    if (!empty($phone)) {
        $requestLogger->debug('检查手机号是否已存在', ['phone' => $phone]);
        $stmt = $db->prepare("SELECT id FROM b_users WHERE phone = ?");
        $stmt->execute([$phone]);
        if ($stmt->fetch()) {
            $requestLogger->warning('手机号已被注册', ['phone' => $phone]);
            
            // 记录审计日志
            $auditLogger->warning('B 端用户注册失败：手机号已被注册', [
                'username' => $username,
                'email' => $email,
                'phone' => $phone,
                'reason' => '手机号已被注册',
            ]);
            
            // 手动刷新异步队列
            if (method_exists($requestLogger, 'flush')) {
                $requestLogger->flush();
            }
            if (method_exists($auditLogger, 'flush')) {
                $auditLogger->flush();
            }
            
            echo json_encode(['code' => 2009, 'message' => '手机号已被注册', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }
        $requestLogger->debug('手机号可用', ['phone' => $phone]);
    }
    
    // 开启事务
    $requestLogger->debug('开启数据库事务');
    $db->beginTransaction();
    
    // 1. 密码哈希
    $requestLogger->debug('生成密码哈希');
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    // 查询 B端用户最大登录设备数配置
    $requestLogger->debug('查询 B 端用户最大登录设备数配置');
    $stmt = $db->prepare("SELECT config_value FROM app_config WHERE config_key = 'b_user_login_max_devices'");
    $stmt->execute();
    $maxDevicesConfig = $stmt->fetchColumn();
    $maxDevices = $maxDevicesConfig ? (int)$maxDevicesConfig : 1; // 默认值为1
    $requestLogger->debug('B 端用户最大登录设备数', ['max_devices' => $maxDevices]);
    
    // 2. 先创建 B端用户记录（wallet_id设置为null）
    $requestLogger->debug('创建 B 端用户记录');
    $stmt = $db->prepare("INSERT INTO b_users (username, email, phone, password_hash, organization_name, organization_leader, wallet_id, create_ip, status, max_devices) VALUES (?, ?, ?, ?, ?, ?, NULL, ?, 1, ?)");
    $result = $stmt->execute([$username, $email, $phone ?: null, $passwordHash, $organizationName, $organizationLeader, $createIp, $maxDevices]);
    $requestLogger->debug('创建 B 端用户结果', ['success' => $result]);
    $userId = $db->lastInsertId();
    $requestLogger->debug('生成的用户 ID', ['user_id' => $userId]);
    
    // 3. 创建钱包记录（此时用户已存在，可以直接使用正确的user_id）
    $requestLogger->debug('创建钱包记录');
    $stmt = $db->prepare("INSERT INTO wallets (balance, username, user_id, user_type) VALUES (0, ?, ?, 2)");
    $result = $stmt->execute([$username, $userId]);
    $requestLogger->debug('创建钱包结果', ['success' => $result]);
    $walletId = $db->lastInsertId();
    $requestLogger->debug('生成的钱包 ID', ['wallet_id' => $walletId]);
    
    // 4. 更新用户记录的钱包ID
    $requestLogger->debug('更新用户记录的钱包 ID');
    $stmt = $db->prepare("UPDATE b_users SET wallet_id = ? WHERE id = ?");
    $result = $stmt->execute([$walletId, $userId]);
    $requestLogger->debug('更新钱包 ID 结果', ['success' => $result]);
    
    // 5. 生成 Token
    $requestLogger->debug('生成 Token');
    $tokenData = Token::generate($userId, Token::TYPE_B);
    $requestLogger->debug('Token 生成成功', ['token' => $tokenData['token']]);
    $requestLogger->debug('Token 过期时间', ['expired_at' => $tokenData['expired_at']]);
    
    // 6. 更新用户表的 token 字段
    $requestLogger->debug('更新用户表的 token 字段');
    $stmt = $db->prepare("UPDATE b_users SET token = ?, token_expired_at = ? WHERE id = ?");
    $result = $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $userId]);
    $requestLogger->debug('更新 token 结果', ['success' => $result]);
    
    // 7. 插入快捷派单配置记录
    $requestLogger->debug('插入快捷派单配置记录');
    $stmt = $db->prepare("INSERT INTO quick_task_info_config (b_user_id, username, config_info) VALUES (?, ?, ?)");
    $result = $stmt->execute([$userId, $username, NULL]);
    $requestLogger->debug('插入配置记录结果', ['success' => $result]);
    
    // 提交事务
    $requestLogger->debug('提交数据库事务');
    $db->commit();
    $requestLogger->debug('事务提交成功');
    
    // 8. 记录审计日志
    $auditLogger->notice('B 端用户注册成功', [
        'user_id' => $userId,
        'username' => $username,
        'email' => $email,
        'phone' => $phone,
        'organization_name' => $organizationName,
        'organization_leader' => $organizationLeader,
        'wallet_id' => $walletId,
        'create_ip' => $createIp,
    ]);
    echo "\n";
    
    // 手动刷新异步队列
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    
    // 9. 返回成功响应
    $requestLogger->info('B 端用户注册成功', ['user_id' => $userId, 'username' => $username]);
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
    
    echo json_encode([
        'code' => 0,
        'message' => '注册成功',
        'data' => $responseData,
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('注册失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户注册失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'reason' => '数据库异常',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 5001,
        'message' => '注册失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('注册失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户注册失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'reason' => '系统异常',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 5002,
        'message' => '注册失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}