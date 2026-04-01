<?php
/**
 * C端用户退出登录接口
 * 
 * POST /api/c/v1/auth/logout
 * 
 * 请求头：
 * X-Token: <token>
 * 
 * 功能：
 * - 清除数据库中的token
 * - 使当前token失效
 * - 清空设备相关字段（device_id, device_name, last_login_device, device_list）
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
    
    // Token 认证（必须是 C 端用户）
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateC();
    
    // 清除数据库中的 Token
    $result = Token::clearFromDatabase($currentUser['user_id'], Token::TYPE_C, $db);
    
    if ($result) {
        // 清空设备相关字段
        $updateStmt = $db->prepare("
            UPDATE c_users 
            SET device_id = NULL,
                device_name = NULL,
                last_login_device = NULL,
                device_list = '[]'
            WHERE id = ?
        ");
        $updateStmt->execute([$currentUser['user_id']]);
        
        Response::success([
            'user_id' => $currentUser['user_id'],
            'logout_at' => date('Y-m-d H:i:s')
        ], '退出登录成功');
    } else {
        Response::error('退出登录失败', $errorCodes['SYSTEM_ERROR']);
    }
    
} catch (Exception $e) {
    error_log('C 端退出登录错误：' . $e->getMessage());
    Response::error('退出登录失败：' . $e->getMessage(), $errorCodes['SYSTEM_ERROR']);
}
