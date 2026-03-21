<?php
/**
 * B端设置支付密码接口
 * 
 * POST /api/b/v1/wallet-password
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "password": "e10adc3949ba59abbe56e057f20f883e"  // 前端加密后的密码（不限格式）
 * }
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "支付密码设置成功",
 *   "data": {
 *     "has_password": true
 *   },
 *   "timestamp": 1736582400
 * }
 * 
 * 注意：
 * - 支付密码只能设置一次，不可修改
 * - 如需修改，请联系管理员（Admin端）
 * - 每个钱包ID对应唯一的支付密码
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

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$password = trim($input['password'] ?? '');

// 参数校验
if (empty($password)) {
    Response::error('支付密码不能为空', $errorCodes['INVALID_PARAMS']);
}

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
    
    if ($existingPassword) {
        // 已存在支付密码，不允许修改
        Response::error('支付密码已设置，无法修改（如需修改请联系管理员）', $errorCodes['WALLET_PASSWORD_EXISTS']);
    }
    
    // 新增支付密码
    $stmt = $db->prepare("
        INSERT INTO wallet_password (wallet_id, user_id, user_type, password_hash)
        VALUES (?, ?, 2, ?)
    ");
    $stmt->execute([$bUser['wallet_id'], $currentUser['user_id'], $password]);
    
    Response::success([
        'has_password' => true
    ], '支付密码设置成功');
    
} catch (PDOException $e) {
    Response::error('操作失败', $errorCodes['DATABASE_ERROR'], 500);
}
