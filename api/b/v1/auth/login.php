<?php
/**
 * B端用户登录接口
 * 
 * POST /api/b/v1/auth/login
 * 
 * 请求体：
 * {
 *   "account": "string (必填，支持邮箱或手机号)",
 *   "password": "string (必填)"
 * }
 */

// 日志函数
function logDebug($message) {
    $timestamp = date('Y-m-d H:i:s');
    error_log("[{$timestamp}] [DEBUG] {$message}");
}

header('Content-Type: application/json; charset=utf-8');

// 记录请求开始
logDebug('=== B端用户登录请求开始 ===');
logDebug('请求地址: ' . $_SERVER['REQUEST_URI']);
logDebug('请求方法: ' . $_SERVER['REQUEST_METHOD']);
logDebug('客户端IP: ' . ($_SERVER['REMOTE_ADDR'] ?? '未知'));

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $response = [
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ];
    logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    logDebug('=== B端用户登录请求结束 ===');
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 获取请求参数
$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true);
$account = trim($input['account'] ?? '');
$password = trim($input['password'] ?? '');
$deviceId = trim($input['device_id'] ?? '');
$deviceName = trim($input['device_name'] ?? '');

// 记录请求体
logDebug('请求体: ' . $rawInput);
logDebug('账号: ' . $account);
logDebug('设备ID: ' . $deviceId);
logDebug('设备名称: ' . $deviceName);

// 设备ID不能为空
if (empty($deviceId)) {
    $response = [
        'code' => $errorCodes['AUTH_DEVICE_ID_MISSING'] ?? 401,
        'message' => '设备ID不能为空',
        'data' => []
    ];
    logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    logDebug('=== B端用户登录请求结束 ===');
    exit;
}

// 参数校验
if (empty($account)) {
    $response = [
        'code' => $errorCodes['USER_EMAIL_EMPTY'],
        'message' => '账号不能为空',
        'data' => []
    ];
    logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    logDebug('=== B端用户登录请求结束 ===');
    exit;
}

if (empty($password)) {
    $response = [
        'code' => $errorCodes['USER_PASSWORD_EMPTY'],
        'message' => '密码不能为空',
        'data' => []
    ];
    logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    logDebug('=== B端用户登录请求结束 ===');
    exit;
}

// 数据库连接
$db = Database::connect();
logDebug('数据库连接成功');

try {
    // 查询 B端用户（支持用户名、邮箱或手机号登录）
    logDebug('开始查询用户信息');
    $stmt = $db->prepare(" 
        SELECT id, username, email, phone, password_hash, organization_name, 
               organization_leader, wallet_id, status, reason, max_devices, device_list
        FROM b_users 
        WHERE username = ? OR email = ? OR phone = ?
    ");
    $stmt->execute([$account, $account, $account]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    logDebug('用户查询结果: ' . ($user ? '找到用户' : '未找到用户'));
    if ($user) {
        logDebug('用户ID: ' . $user['id']);
        logDebug('用户名: ' . $user['username']);
        logDebug('用户状态: ' . $user['status']);
    }
    
    // 用户不存在或密码错误
    if (!$user || !password_verify($password, $user['password_hash'])) {
        $response = [
            'code' => $errorCodes['USER_PASSWORD_WRONG'],
            'message' => '账号或密码错误',
            'data' => []
        ];
        logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        logDebug('=== B端用户登录请求结束 ===');
        exit;
    }
    
    // 检查用户状态
    if ($user['status'] != 1) {
        $reason = $user['reason'] ?: '违规操作';
        $response = [
            'code' => $errorCodes['AUTH_ACCOUNT_DISABLED'],
            'message' => '账号已被禁用：' . $reason,
            'data' => []
        ];
        logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        logDebug('=== B端用户登录请求结束 ===');
        exit;
    }
    
    // 检查设备限制
    $maxDevices = isset($user['max_devices']) ? (int)$user['max_devices'] : 1;
    $deviceList = [];
    if (!empty($user['device_list'])) {
        $deviceList = json_decode($user['device_list'], true) ?: [];
    }
    
    logDebug('设备限制: ' . $maxDevices);
    logDebug('当前设备数量: ' . count($deviceList));
    logDebug('设备列表: ' . json_encode($deviceList));
    
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
        
        logDebug('设备是否已存在: ' . ($deviceExists ? '是' : '否'));
        
        if (!$deviceExists) {
            $response = [
                'code' => $errorCodes['AUTH_DEVICE_LIMIT_REACHED'] ?? 401,
                'message' => '登录设备数量已达到限制',
                'data' => []
            ];
            logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
            echo json_encode($response, JSON_UNESCAPED_UNICODE);
            logDebug('=== B端用户登录请求结束 ===');
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
    
    logDebug('设备信息: ' . json_encode($deviceInfo));
    
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
    
    logDebug('更新后设备列表: ' . json_encode($deviceList));
    
    // 生成新 Token（覆盖旧 Token，实现踢下线）
    logDebug('生成Token');
    $tokenData = Token::generate($user['id'], Token::TYPE_B);
    logDebug('Token生成成功: ' . $tokenData['token']);
    logDebug('Token过期时间: ' . $tokenData['expired_at']);
    
    // 更新数据库中的 token、过期时间和设备信息
    logDebug('更新用户信息到数据库');
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
    
    logDebug('数据库更新结果: ' . ($result ? '成功' : '失败'));
    
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
    
    logDebug('返回结果: ' . json_encode($successResponse, JSON_UNESCAPED_UNICODE));
    echo json_encode($successResponse, JSON_UNESCAPED_UNICODE);
    logDebug('=== B端用户登录请求结束 ===');
    
} catch (PDOException $e) {
    logDebug('数据库错误: ' . $e->getMessage());
    $response = [
        'code' => $errorCodes['DATABASE_ERROR'],
        'message' => '登录失败',
        'data' => []
    ];
    logDebug('返回结果: ' . json_encode($response, JSON_UNESCAPED_UNICODE));
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    logDebug('=== B端用户登录请求结束 ===');
}

