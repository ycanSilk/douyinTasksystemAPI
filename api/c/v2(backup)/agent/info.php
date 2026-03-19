<?php
/**
 * C端用户代理基础信息接口
 * 
 * GET /api/c/v1/agent/info
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "user_id": 123,
 *     "username": "user123",
 *     "invite_code": "ABC123",
 *     "is_agent": 1,
 *     "is_agent_text": "团长",
 *     "parent_id": 100,
 *     "parent_username": "parent_user",
 *     "created_at": "2026-01-11 10:00:00"
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
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 查询用户信息
    $stmt = $db->prepare("
        SELECT 
            u.id,
            u.username,
            u.invite_code,
            u.parent_id,
            u.is_agent,
            u.created_at,
            p.username as parent_username
        FROM c_users u
        LEFT JOIN c_users p ON u.parent_id = p.id
        WHERE u.id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        Response::error('用户信息不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 返回成功响应
    Response::success([
        'user_id' => (int)$user['id'],
        'username' => $user['username'],
        'invite_code' => $user['invite_code'],
        'is_agent' => (int)$user['is_agent'],
        'is_agent_text' => [0 => '普通用户', 1 => '团长', 2 => '高级团长'][(int)$user['is_agent']] ?? '普通用户',
        'parent_id' => $user['parent_id'] ? (int)$user['parent_id'] : null,
        'parent_username' => $user['parent_username'],
        'created_at' => $user['created_at']
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
