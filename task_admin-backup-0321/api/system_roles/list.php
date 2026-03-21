<?php
/**
 * 系统角色列表接口
 * GET /task_admin/api/system_roles/list.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



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
    // 查询角色列表
    $stmt = $db->query("SELECT * FROM system_roles ORDER BY id ASC");
    $roles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 转换时间格式
    foreach ($roles as &$role) {
        $role['created_at'] = date('Y-m-d H:i:s', strtotime($role['created_at']));
        $role['updated_at'] = date('Y-m-d H:i:s', strtotime($role['updated_at']));
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => $roles,
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