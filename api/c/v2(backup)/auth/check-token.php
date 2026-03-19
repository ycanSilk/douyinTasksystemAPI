<?php
/**
 * C端Token校验接口
 * 
 * GET /api/c/v1/auth/check-token
 * 
 * 请求头：
 * X-Token: <token>
 * 
 * 响应示例（Token有效）：
 * {
 *   "code": 0,
 *   "message": "Token有效",
 *   "data": {
 *     "valid": true,
 *     "user_id": 456,
 *     "username": "user123",
 *     "email": "user123@example.com",
 *     "invite_code": "ABC123",
 *     "is_agent": 0,
 *     "token_expired_at": "2026-01-21 12:30:00",
 *     "expires_in": 604800
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 响应示例（Token无效）：
 * {
 *   "code": 401,
 *   "message": "Token已过期",
 *   "data": {
 *     "valid": false
 *   },
 *   "timestamp": 1736582400
 * }
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 获取设备ID
$deviceId = trim($_GET['device_id'] ?? '');
if (empty($deviceId)) {
    http_response_code(401);
    echo json_encode([
        'code' => $errorCodes['AUTH_DEVICE_ID_MISSING'] ?? 401,
        'message' => '设备ID不能为空',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

try {
    // 1. 获取 Token
    $token = Token::getFromRequest();
    
    if (!$token) {
        http_response_code(401);
        echo json_encode([
            'code' => $errorCodes['AUTH_TOKEN_MISSING'],
            'message' => '未提供认证Token',
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 2. 校验 Token（C端）
    $result = Token::verify($token, Token::TYPE_C, $db, $deviceId);
    
    if (!$result['valid']) {
        http_response_code(401);
        echo json_encode([
            'code' => $result['code'] ?? $errorCodes['AUTH_TOKEN_INVALID'],
            'message' => $result['error'],
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 3. Token有效，查询用户详细信息
    $stmt = $db->prepare(" 
        SELECT 
            id, username, email, invite_code, 
            parent_id, is_agent, status, token_expired_at,
            device_id, device_name, max_devices, device_list
        FROM c_users 
        WHERE id = ?
    ");
    $stmt->execute([$result['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'code' => $errorCodes['USER_NOT_FOUND'],
            'message' => '用户不存在',
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 4. 检查用户状态
    if ((int)$user['status'] !== 1) {
        http_response_code(401);
        echo json_encode([
            'code' => $errorCodes['AUTH_ACCOUNT_DISABLED'],
            'message' => '账号已被禁用',
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 5. 检查设备ID是否匹配
    if (!empty($user['device_id']) && $user['device_id'] !== $deviceId) {
        // 检查设备是否在设备列表中
        $deviceList = [];
        if (!empty($user['device_list'])) {
            $deviceList = json_decode($user['device_list'], true) ?: [];
        }
        
        $deviceExists = false;
        foreach ($deviceList as $device) {
            if ($device['device_id'] == $deviceId) {
                $deviceExists = true;
                break;
            }
        }
        
        if (!$deviceExists) {
            http_response_code(401);
            echo json_encode([
                'code' => $errorCodes['AUTH_DEVICE_ID_MISMATCH'] ?? 401,
                'message' => '设备ID不匹配',
                'data' => ['valid' => false],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }
    
    // 5. 计算Token剩余有效时间（秒）
    $tokenExpiredAt = strtotime($user['token_expired_at']);
    $currentTime = time();
    $expiresIn = max(0, $tokenExpiredAt - $currentTime);
    
    // 6. 返回成功响应
    Response::success([
        'valid' => true,
        'user_id' => (int)$user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
        'invite_code' => $user['invite_code'],
        'parent_id' => $user['parent_id'] ? (int)$user['parent_id'] : null,
        'is_agent' => (int)$user['is_agent'],
        'token_expired_at' => $user['token_expired_at'],
        'expires_in' => $expiresIn,
        'device_id' => $user['device_id'] ?? null,
        'device_name' => $user['device_name'] ?? null,
        'max_devices' => $user['max_devices'] ?? 1,
        'device_list' => json_decode($user['device_list'], true) ?: []
    ], 'Token有效');
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => $errorCodes['SYSTEM_ERROR'],
        'message' => '服务器错误',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
