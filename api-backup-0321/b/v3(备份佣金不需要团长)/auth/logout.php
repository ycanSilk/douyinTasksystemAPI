<?php
/**
 * B端用户退出登录接口
 * 
 * POST /api/b/v1/auth/logout
 * 
 * 请求头：
 * X-Token: <token>
 * 
 * 功能：
 * - 清除数据库中的token
 * - 使当前token失效
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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
require_once __DIR__ . '/../../../../core/Token.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

try {
    // 数据库连接
    $db = Database::connect();
    
    // Token 认证（必须是 B端用户）
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateB();
    
    // 清除数据库中的 Token
    $result = Token::clearFromDatabase($currentUser['user_id'], Token::TYPE_B, $db);
    
    if ($result) {
        Response::success([
            'user_id' => $currentUser['user_id'],
            'logout_at' => date('Y-m-d H:i:s')
        ], '退出登录成功');
    } else {
        Response::error('退出登录失败', $errorCodes['SYSTEM_ERROR']);
    }
    
} catch (Exception $e) {
    error_log('B端退出登录错误: ' . $e->getMessage());
    Response::error('退出登录失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
