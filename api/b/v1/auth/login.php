<?php
/**
 * B 端用户登录接口
 * 
 * POST /api/b/v1/auth/login
 * 
 * 请求体：
 * {
 *   "account": "string (必填，支持邮箱或手机号)",
 *   "password": "string (必填)",
 *   "device_id": "string (必填)",
 *   "device_name": "string (选填)"
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4001 - 设备 ID 不能为空
 * 4002 - 账号不能为空
 * 4003 - 密码不能为空
 * 4004 - 账号或密码错误
 * 4005 - 账号已被禁用
 * 4006 - 登录设备数量已达到限制
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
$deviceId = trim($input['device_id'] ?? '');
$deviceName = trim($input['device_name'] ?? '');

// 记录请求参数（敏感信息会自动脱敏）
$requestLogger->debug('请求参数', [
    'account' => $account,
    'password' => $password,
    'device_id' => $deviceId,
    'device_name' => $deviceName,
]);

// 设备 ID 不能为空
if (empty($deviceId)) {
    $requestLogger->warning('设备 ID 为空', ['device_id' => $deviceId]);
    echo json_encode([
        'code' => 4001,
        'message' => '设备 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 参数校验
if (empty($account)) {
    $requestLogger->warning('账号为空', ['account' => $account]);
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
               organization_leader, wallet_id, status, reason, max_devices, device_list
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
        echo json_encode([
            'code' => 4005,
            'message' => '账号已被禁用：' . $reason,
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查设备限制
    $maxDevices = isset($user['max_devices']) ? (int)$user['max_devices'] : 1;
    $deviceList = [];
    if (!empty($user['device_list'])) {
        $deviceList = json_decode($user['device_list'], true) ?: [];
    }
    
    $requestLogger->debug('设备限制信息', [
        'max_devices' => $maxDevices,
        'current_devices' => count($deviceList),
    ]);
    
    // 检查设备数量限制
    if ($maxDevices > 0 && count($deviceList) >= $maxDevices) {
        // 检查当前设备是否已在列表中
        $deviceExists = false;
        foreach ($deviceList as $device) {
            if ($device['device_id'] == $deviceId) {
                $deviceExists = true;
                break;
            }
        }
        
        $requestLogger->debug('设备检查结果', ['exists' => $deviceExists]);
        
        if (!$deviceExists) {
            $requestLogger->warning('登录失败：设备数量超限', [
                'user_id' => $user['id'],
                'max_devices' => $maxDevices,
                'current_devices' => count($deviceList),
            ]);
            echo json_encode([
                'code' => 4006,
                'message' => '登录设备数量已达到限制，最多只能登录' . $maxDevices . '个设备',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }
    
    // 更新设备列表
    $deviceInfo = [
        'device_id' => $deviceId,
        'device_name' => $deviceName,
        'login_time' => date('Y-m-d H:i:s'),
        'last_activity' => date('Y-m-d H:i:s')
    ];
    
    $requestLogger->debug('设备信息', ['device_info' => $deviceInfo]);
    
    // 检查设备是否已存在，存在则更新，不存在则添加
    $deviceExists = false;
    foreach ($deviceList as &$device) {
        if ($device['device_id'] == $deviceId) {
            $device = $deviceInfo;
            $deviceExists = true;
            break;
        }
    }
    
    if (!$deviceExists) {
        $deviceList[] = $deviceInfo;
    }
    
    $requestLogger->debug('更新后设备列表', ['device_list' => $deviceList]);
    
    // 生成新 Token（覆盖旧 Token，实现踢下线）
    $requestLogger->debug('开始生成 Token');
    $tokenData = Token::generate($user['id'], Token::TYPE_B);
    $requestLogger->debug('Token 生成成功', ['expired_at' => $tokenData['expired_at']]);
    
    // 更新数据库中的 token、过期时间和设备信息
    $requestLogger->debug('开始更新用户信息到数据库', ['user_id' => $user['id']]);
    $stmt = $db->prepare(" 
        UPDATE b_users 
        SET token = ?, token_expired_at = ?, device_id = ?, device_name = ?, last_login_device = ?, device_list = ? 
        WHERE id = ?
    ");
    $result = $stmt->execute([
        $tokenData['token'], 
        $tokenData['expired_at'],
        $deviceId,
        $deviceName,
        json_encode($deviceInfo),
        json_encode($deviceList),
        $user['id']
    ]);
    
    $requestLogger->debug('数据库更新结果', ['success' => $result ? true : false]);
    
    // 记录审计日志
    $auditLogger->notice('B 端用户登录成功', [
        'user_id' => $user['id'],
        'username' => $user['username'],
        'device_id' => $deviceId,
        'device_name' => $deviceName,
    ]);
    
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
            'wallet_id' => $user['wallet_id'],
            'device_id' => $deviceId,
            'device_name' => $deviceName,
            'max_devices' => $maxDevices,
            'device_list' => $deviceList
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
    
    echo json_encode([
        'code' => 5002,
        'message' => '登录失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}

