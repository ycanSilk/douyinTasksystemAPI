<?php
/**
 * 系统用户列表接口
 * GET /task_admin/api/system_users/list.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// Token 认证
AdminAuthMiddleware::authenticate();

// 数据库连接
$db = Database::connect();

try {
    // 查询用户列表
    $stmt = $db->query("SELECT su.*, sr.name as role_name FROM system_users su LEFT JOIN system_roles sr ON su.role_id = sr.id ORDER BY su.created_at DESC");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 转换时间格式
    foreach ($users as &$user) {
        $user['created_at'] = date('Y-m-d H:i:s', strtotime($user['created_at']));
        $user['updated_at'] = date('Y-m-d H:i:s', strtotime($user['updated_at']));
        if ($user['last_login_at']) {
            $user['last_login_at'] = date('Y-m-d H:i:s', strtotime($user['last_login_at']));
        }
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => $users,
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库查询失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}