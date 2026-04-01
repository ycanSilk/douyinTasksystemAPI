<?php
/**
 * B 端用户登录接口
 * 
 * POST /api/b/v1/auth/login
 * 
 * 请求体：
 * {
 *   "account": "string (必填，支持邮箱或手机号)",
 *   "password": "string (必填)"
 * }
 * 
 * 请求示例：
 * {
 *   "account": "test@example.com",
 *   "password": "123456"
 * }
 * 
 * 成功响应示例：
 * {
 *   "code": 0,
 *   "message": "登录成功",
 *   "data": {
 *     "token": "eyJ1c2VyX2lkIjoxLCJ0eXBlIjoyLCJleHAiOjE3NzQ4ODYzNjN9...",
 *     "user_id": 1,
 *     "username": "testuser",
 *     "email": "test@example.com",
 *     "phone": "13800138000",
 *     "organization_name": "测试组织",
 *     "organization_leader": "张三",
 *     "wallet_id": 1
 *   },
 *   "timestamp": 1711267200
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4002 - 账号不能为空
 * 4003 - 密码不能为空
 * 4004 - 账号或密码错误
 * 4005 - 账号已被禁用
 * 5001 - 数据库错误
 * 5002 - 系统错误
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/auth/login');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');



// 记录请求开始
$requestLogger->info('=== B 端用户登录请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);


header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
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
    $rawInput = '';
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

// 获取请求参数
$input = json_decode($rawInput, true);
$account = trim($input['account'] ?? '');
$password = trim($input['password'] ?? '');

// 记录请求参数（敏感信息会自动脱敏）
$requestLogger->debug('请求参数', [
    'account' => $account,
    'password' => $password,
]);

// 参数校验
if (empty($account)) {
    $requestLogger->warning('账号为空', ['account' => $account]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户登录失败：账号为空', [
        'account' => $account,
        'reason' => '账号不能为空',
    ]);
    
    // 手动刷新异步队列
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    echo json_encode([
        'code' => 4002,
        'message' => '账号不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($password)) {
    $requestLogger->warning('密码为空', ['password' => $password]);
    
    // 记录审计日志
    $auditLogger->warning('B 端用户登录失败：密码为空', [
        'account' => $account,
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
        'code' => 4003,
        'message' => '密码不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户登录失败：数据库连接失败', [
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

try {
    // 查询 B 端用户（支持用户名、邮箱或手机号登录）
    $requestLogger->debug('开始查询用户信息', ['account' => $account]);
    $stmt = $db->prepare(" 
        SELECT id, username, email, phone, password_hash, organization_name, 
               organization_leader, wallet_id, status, reason
        FROM b_users 
        WHERE username = ? OR email = ? OR phone = ?
    ");
    $stmt->execute([$account, $account, $account]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $requestLogger->debug('用户查询结果', ['found' => $user ? true : false]);
    if ($user) {
        $requestLogger->debug('用户基本信息', [
            'user_id' => $user['id'],
            'username' => $user['username'],
            'status' => $user['status'],
        ]);
    }
    
    // 用户不存在或密码错误
    if (!$user || !password_verify($password, $user['password_hash'])) {
        $requestLogger->warning('登录失败：账号或密码错误', ['account' => $account]);
        
        // 记录审计日志
        $auditLogger->warning('B 端用户登录失败：账号或密码错误', [
            'account' => $account,
            'reason' => '账号或密码错误',
        ]);
        
        // 手动刷新异步队列
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        
        echo json_encode([
            'code' => 4004,
            'message' => '账号或密码错误',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查用户状态
    if ($user['status'] != 1) {
        $reason = $user['reason'] ?: '违规操作';
        $requestLogger->warning('登录失败：账号已被禁用', [
            'user_id' => $user['id'],
            'username' => $user['username'],
            'reason' => $reason,
        ]);
        
        // 记录审计日志
        $auditLogger->warning('B 端用户登录失败：账号已被禁用', [
            'user_id' => $user['id'],
            'username' => $user['username'],
            'reason' => $reason,
        ]);
        
        // 手动刷新异步队列
        if (method_exists($requestLogger, 'flush')) {
            $requestLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        
        echo json_encode([
            'code' => 4005,
            'message' => '账号已被禁用：' . $reason,
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 生成新 Token（覆盖旧 Token，实现踢下线）
    $requestLogger->debug('开始生成 Token');
    $tokenData = Token::generate($user['id'], Token::TYPE_B);
    $requestLogger->debug('Token 生成成功', ['expired_at' => $tokenData['expired_at']]);
    
    // 更新数据库中的 token 和过期时间
    $requestLogger->debug('开始更新用户信息到数据库', ['user_id' => $user['id']]);
    $stmt = $db->prepare(" 
        UPDATE b_users 
        SET token = ?, token_expired_at = ?
        WHERE id = ?
    ");
    $result = $stmt->execute([
        $tokenData['token'], 
        $tokenData['expired_at'],
        $user['id']
    ]);
    
    $requestLogger->debug('数据库更新结果', ['success' => $result ? true : false]);
    
    // 记录审计日志
    $auditLogger->notice('B 端用户登录成功', [
        'user_id' => $user['id'],
        'username' => $user['username'],
    ]);
    echo "\n";
    
    // 手动刷新异步队列
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    
    // 构建成功响应
    $successResponse = [
        'code' => 0,
        'message' => '登录成功',
        'data' => [
            'token' => $tokenData['token'],
            'user_id' => $user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'phone' => $user['phone'],
            'organization_name' => $user['organization_name'],
            'organization_leader' => $user['organization_leader'],
            'wallet_id' => $user['wallet_id']
        ]
    ];
    
    $requestLogger->info('登录成功', ['user_id' => $user['id'], 'username' => $user['username']]);
    echo json_encode($successResponse, JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('登录失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户登录失败：数据库异常', [
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
        'message' => '登录失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('登录失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    // 记录审计日志
    $auditLogger->error('B 端用户登录失败：系统异常', [
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
        'message' => '登录失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}

