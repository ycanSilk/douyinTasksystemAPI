<?php
/**
 * C端用户刷新Token接口
 * 
 * POST /api/c/v1/auth/refresh
 * 
 * 请求头：
 * X-Token: <token>
 * 
 * 功能：
 * - 验证当前token
 * - 生成新的token
 * - 延长有效期（7天）
 * - 旧token立即失效
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
    
    // Token 认证（必须是 C端用户）
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateC();
    
    // 生成新的 Token（有效期7天）
    $tokenData = Token::generate($currentUser['user_id'], Token::TYPE_C);
    
    // 更新数据库中的 token
    $result = Token::updateToDatabase(
        $currentUser['user_id'],
        Token::TYPE_C,
        $tokenData['token'],
        $tokenData['expired_at'],
        $db
    );
    
    if ($result) {
        Response::success([
            'token' => $tokenData['token'],
            'expired_at' => $tokenData['expired_at'],
            'refresh_at' => date('Y-m-d H:i:s')
        ], 'Token刷新成功');
    } else {
        Response::error('Token刷新失败', $errorCodes['SYSTEM_ERROR']);
    }
    
} catch (Exception $e) {
    error_log('C端Token刷新错误: ' . $e->getMessage());
    Response::error('Token刷新失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
