<?php
/**
 * 系统用户删除接口
 * POST /task_admin/api/system_users/delete.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 只允许POST请求
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

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// Token 认证
AdminAuthMiddleware::authenticate();

// 数据库连接
$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$user_id = (int)($input['user_id'] ?? 0);

// 参数校验
if (empty($user_id)) {
    echo json_encode([
        'code' => 1002,
        'message' => '用户ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查用户是否存在
    $stmt = $db->prepare("SELECT id, username FROM system_users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user) {
        echo json_encode([
            'code' => 1003,
            'message' => '用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 防止删除超级管理员（假设ID为1）
    if ($user_id === 1) {
        echo json_encode([
            'code' => 1004,
            'message' => '超级管理员不能删除',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 删除用户
    $stmt = $db->prepare("DELETE FROM system_users WHERE id = ?");
    $stmt->execute([$user_id]);
    
    echo json_encode([
        'code' => 0,
        'message' => '用户删除成功',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库操作失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}