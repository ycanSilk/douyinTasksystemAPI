<?php
/**
 * 获取角色权限模板接口
 * GET /task_admin/api/system_permission_template/role_permissions_get.php?role_id=1
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

// 获取角色ID
$role_id = (int)($_GET['role_id'] ?? 0);

if (empty($role_id)) {
    echo json_encode([
        'code' => 1002,
        'message' => '角色ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 查询角色已分配的权限模板
    $stmt = $db->prepare("SELECT template_id FROM system_role_permission_template WHERE role_id = ?");
    $stmt->execute([$role_id]);
    $template_ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => $template_ids,
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
