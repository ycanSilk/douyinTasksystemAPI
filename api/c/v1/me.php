<?php
/**
 * C端获取当前用户信息接口
 * 
 * GET /api/c/v1/me
 * 
 * 请求头：
 * X-Token: <token>
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

try {
    // 查询 C端用户信息（包含钱包余额）
    $stmt = $db->prepare("
        SELECT 
            u.id,
            u.username,
            u.email,
            u.phone,
            u.invite_code,
            u.parent_id,
            u.is_agent,
            u.wallet_id,
            u.status,
            u.reason,
            u.create_ip,
            u.created_at,
            u.updated_at,
            w.balance
        FROM c_users u
        LEFT JOIN wallets w ON u.wallet_id = w.id
        WHERE u.id = ?
    ");
    $stmt->execute([$currentUser['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        Response::error('用户不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 格式化返回数据
    Response::success([
        'id' => (int)$user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'invite_code' => $user['invite_code'],
        'parent_id' => $user['parent_id'] ? (int)$user['parent_id'] : null,
        'is_agent' => (int)$user['is_agent'],
        'wallet_id' => (int)$user['wallet_id'],
        'wallet' => [
            'balance' => number_format((int)$user['balance'] / 100, 2, '.', '')  // 余额（元，保留两位小数）
        ],
        'status' => (int)$user['status'],
        'reason' => $user['reason'],
        'create_ip' => $user['create_ip'],
        'created_at' => $user['created_at'],
        'updated_at' => $user['updated_at']
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}

