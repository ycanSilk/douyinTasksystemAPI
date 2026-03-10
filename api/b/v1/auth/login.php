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
$account = trim($input['account'] ?? '');
$password = trim($input['password'] ?? '');
$deviceId = trim($input['device_id'] ?? '');
$deviceName = trim($input['device_name'] ?? '');

// 设备ID不能为空
if (empty($deviceId)) {
    Response::error('设备ID不能为空', $errorCodes['AUTH_DEVICE_ID_MISSING'] ?? 401);
}

// 参数校验
if (empty($account)) {
    Response::error('账号不能为空', $errorCodes['USER_EMAIL_EMPTY']);
}

if (empty($password)) {
    Response::error('密码不能为空', $errorCodes['USER_PASSWORD_EMPTY']);
}

// 数据库连接
$db = Database::connect();

try {
    // 查询 B端用户（支持用户名、邮箱或手机号登录）
    $stmt = $db->prepare("
        SELECT id, username, email, phone, password_hash, organization_name, 
               organization_leader, wallet_id, status, reason 
        FROM b_users 
        WHERE username = ? OR email = ? OR phone = ?
    ");
    $stmt->execute([$account, $account, $account]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 用户不存在或密码错误
    if (!$user || !password_verify($password, $user['password_hash'])) {
        Response::error('账号或密码错误', $errorCodes['USER_PASSWORD_WRONG']);
    }
    
    // 检查用户状态
    if ($user['status'] != 1) {
        $reason = $user['reason'] ?: '违规操作';
        Response::error('账号已被禁用：' . $reason, $errorCodes['AUTH_ACCOUNT_DISABLED']);
    }
    
    // 检查设备限制
    $maxDevices = isset($user['max_devices']) ? (int)$user['max_devices'] : 1;
    $deviceList = [];
    if (!empty($user['device_list'])) {
        $deviceList = json_decode($user['device_list'], true) ?: [];
    }
    
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
        
        if (!$deviceExists) {
            Response::error('登录设备数量已达到限制', $errorCodes['AUTH_DEVICE_LIMIT_REACHED'] ?? 401);
        }
    }
    
    // 更新设备列表
    $deviceInfo = [
        'device_id' => $deviceId,
        'device_name' => $deviceName,
        'login_time' => date('Y-m-d H:i:s'),
        'last_activity' => date('Y-m-d H:i:s')
    ];
    
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
    
    // 生成新 Token（覆盖旧 Token，实现踢下线）
    $tokenData = Token::generate($user['id'], Token::TYPE_B);
    
    // 更新数据库中的 token、过期时间和设备信息
    $stmt = $db->prepare(" 
        UPDATE b_users 
        SET token = ?, token_expired_at = ?, device_id = ?, device_name = ?, last_login_device = ?, device_list = ? 
        WHERE id = ?
    ");
    $stmt->execute([
        $tokenData['token'], 
        $tokenData['expired_at'],
        $deviceId,
        $deviceName,
        json_encode($deviceInfo),
        json_encode($deviceList),
        $user['id']
    ]);
    
    // 返回成功响应
    Response::success([
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
    ], '登录成功');
    
} catch (PDOException $e) {
    Response::error('登录失败', $errorCodes['DATABASE_ERROR'], 500);
}

