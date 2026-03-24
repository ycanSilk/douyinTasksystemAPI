<?php
/**
 * C端用户更新新手指引状态接口
 * 
 * POST /api/c/v1/users/update-guide
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "更新成功",
 *   "data": {
 *     "has_completed_newbie_guide": 1
 *   },
 *   "timestamp": 1736582400
 * }
 */

// 输出详细日志
error_log('=== C端用户更新新手指引状态接口调用开始 ===');
error_log('请求方法: ' . $_SERVER['REQUEST_METHOD']);
error_log('请求IP: ' . ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知'));

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    error_log('请求方法错误: ' . $_SERVER['REQUEST_METHOD']);
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
try {
    $db = Database::connect();
    error_log('数据库连接成功');
} catch (Exception $e) {
    error_log('数据库连接失败: ' . $e->getMessage());
    Response::error('数据库连接失败', $errorCodes['DATABASE_ERROR'], 500);
}

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    error_log('用户认证成功，用户ID: ' . $currentUser['user_id']);
} catch (Exception $e) {
    error_log('用户认证失败: ' . $e->getMessage());
    Response::error('认证失败', $errorCodes['AUTH_FAILED'], 401);
}

// 查询用户当前的新手指引状态
try {
    $stmt = $db->prepare("SELECT has_completed_newbie_guide FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$userInfo) {
        error_log('用户不存在，用户ID: ' . $currentUser['user_id']);
        Response::error('用户不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 判断是否已经完成新手指引
    if ($userInfo['has_completed_newbie_guide'] == 1) {
        error_log('用户已完成新手指引，无需更新，用户ID: ' . $currentUser['user_id']);
        echo json_encode([
            'code' => 0,
            'message' => '已完成新手指引',
            'data' => [
                'has_completed_newbie_guide' => 1
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 更新新手指引状态为已完成
    $stmt = $db->prepare("UPDATE c_users SET has_completed_newbie_guide = 1 WHERE id = ?");
    $result = $stmt->execute([$currentUser['user_id']]);
    
    if ($result) {
        error_log('新手指引状态更新成功，用户ID: ' . $currentUser['user_id']);
        echo json_encode([
            'code' => 0,
            'message' => '更新成功',
            'data' => [
                'has_completed_newbie_guide' => 1
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        error_log('新手指引状态更新失败，用户ID: ' . $currentUser['user_id']);
        Response::error('更新失败', $errorCodes['UNKNOWN_ERROR']);
    }
} catch (Exception $e) {
    error_log('更新新手指引状态异常: ' . $e->getMessage());
    Response::error('更新失败', $errorCodes['UPDATE_FAILED']);
}
