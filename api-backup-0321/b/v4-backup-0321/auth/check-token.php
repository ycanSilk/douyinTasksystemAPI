<?php
/**
 * B端Token校验接口
 * 
 * GET /api/b/v1/auth/check-token
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
 *     "user_id": 123,
 *     "username": "merchant01",
 *     "email": "merchant01@example.com",
 *     "organization_name": "示例商家",
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

// 调试日志
error_log('[B端Token校验] 请求开始 - ' . $_SERVER['REQUEST_URI']);
error_log('[B端Token校验] 请求头: ' . json_encode(getallheaders(), JSON_UNESCAPED_UNICODE));
error_log('[B端Token校验] 查询参数: ' . json_encode($_GET, JSON_UNESCAPED_UNICODE));

// 获取设备ID
$deviceId = trim($_GET['device_id'] ?? '');
error_log('[B端Token校验] 设备ID: ' . $deviceId);

if (empty($deviceId)) {
    error_log('[B端Token校验] 设备ID为空');
    http_response_code(401);
    echo json_encode([
        'code' => 401,
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
try {
    $db = Database::connect();
    error_log('[B端Token校验] 数据库连接成功');
} catch (Exception $e) {
    error_log('[B端Token校验] 数据库连接失败: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'code' => 500,
        'message' => '服务器错误',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 1. 获取 Token
    $token = Token::getFromRequest();
    error_log('[B端Token校验] 获取Token: ' . ($token ? '成功' : '失败'));
    
    if (!$token) {
        error_log('[B端Token校验] Token不存在');
        http_response_code(401);
        echo json_encode([
            'code' => 401,
            'message' => '未提供认证Token',
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 2. 校验 Token（B端） - 包含完整的token和设备ID校验
    error_log('[B端Token校验] 开始校验Token和设备ID');
    $result = Token::verify($token, Token::TYPE_B, $db, $deviceId);
    error_log('[B端Token校验] Token校验结果: ' . json_encode($result, JSON_UNESCAPED_UNICODE));
    
    if (!$result['valid']) {
        error_log('[B端Token校验] Token或设备ID无效: ' . $result['error']);
        http_response_code(401);
        echo json_encode([
            'code' => $result['code'] ?? 401,
            'message' => $result['error'],
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 3. Token和设备ID都有效，查询用户详细信息
    error_log('[B端Token校验] Token和设备ID都有效，用户ID: ' . $result['user_id']);
    $stmt = $db->prepare("
        SELECT 
            id, username, email, organization_name, 
            organization_leader, status, token_expired_at
        FROM b_users 
        WHERE id = ?
    ");
    $stmt->execute([$result['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    error_log('[B端Token校验] 查询用户结果: ' . ($user ? '成功' : '失败'));
    
    if (!$user) {
        error_log('[B端Token校验] 用户不存在');
        http_response_code(401);
        echo json_encode([
            'code' => 401,
            'message' => '用户不存在',
            'data' => ['valid' => false],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 4. 计算Token剩余有效时间（秒）
    $tokenExpiredAt = strtotime($user['token_expired_at']);
    $currentTime = time();
    $expiresIn = max(0, $tokenExpiredAt - $currentTime);
    error_log('[B端Token校验] Token剩余有效时间: ' . $expiresIn . '秒');
    
    // 5. 返回成功响应
    Response::success([
        'valid' => true,
        'user_id' => (int)$user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
        'organization_name' => $user['organization_name'],
        'organization_leader' => $user['organization_leader'],
        'token_expired_at' => $user['token_expired_at'],
        'expires_in' => $expiresIn
    ], 'Token有效');
    
} catch (PDOException $e) {
    error_log('[B端Token校验] 数据库错误: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'code' => 500,
        'message' => '服务器错误',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    error_log('[B端Token校验] 系统错误: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'code' => 500,
        'message' => '服务器错误',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
