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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

try {
    $db = Database::connect();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'code' => $errorCodes['SYSTEM_ERROR'],
        'message' => '服务器错误',
        'data' => ['valid' => false],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
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

    $result = Token::verify($token, Token::TYPE_C, $db);

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

    $stmt = $db->prepare("
        SELECT
            id, username, email, invite_code,
            parent_id, is_agent, status, token_expired_at
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

    $tokenExpiredAt = strtotime($user['token_expired_at']);
    $currentTime = time();
    $expiresIn = max(0, $tokenExpiredAt - $currentTime);

    Response::success([
        'valid' => true,
        'user_id' => (int)$user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
        'invite_code' => $user['invite_code'],
        'parent_id' => $user['parent_id'] ? (int)$user['parent_id'] : null,
        'is_agent' => (int)$user['is_agent'],
        'token_expired_at' => $user['token_expired_at'],
        'expires_in' => $expiresIn
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