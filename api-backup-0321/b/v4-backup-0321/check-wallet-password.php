<?php
/**
 * B端检查是否设置支付密码接口
 * 
 * GET /api/b/v1/check-wallet-password
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "has_password": true
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

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

try {
    // 1. 查询B端用户钱包信息
    $stmt = $db->prepare("SELECT wallet_id FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 2. 查询是否已设置支付密码
    $stmt = $db->prepare("SELECT id FROM wallet_password WHERE wallet_id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $existingPassword = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 3. 返回结果
    Response::success([
        'has_password' => $existingPassword ? true : false
    ]);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}
