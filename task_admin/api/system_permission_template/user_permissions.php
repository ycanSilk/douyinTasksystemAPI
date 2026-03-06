<?php
/**
 * 获取当前用户权限模板接口
 * GET /task_admin/api/system_permission_template/user_permissions.php
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
$user_id = AdminAuthMiddleware::authenticate(true);

// 数据库连接
$db = Database::connect();

try {
    // 查询用户角色
    $stmt = $db->prepare("SELECT role_id FROM system_users WHERE id = ? AND status = 1");
    $stmt->execute([$user_id]);
    $role_id = $stmt->fetchColumn();
    
    if (!$role_id) {
        echo json_encode([
            'code' => 1003,
            'message' => '用户角色不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 查询用户权限模板
    $stmt = $db->prepare("SELECT spt.* FROM system_permission_template spt
                        JOIN system_role_permission_template srpt ON spt.id = srpt.template_id
                        WHERE srpt.role_id = ? AND spt.status = 1
                        ORDER BY spt.sort_order ASC, spt.id ASC");
    $stmt->execute([$role_id]);
    $templates = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 转换时间格式
    foreach ($templates as &$template) {
        $template['created_at'] = date('Y-m-d H:i:s', strtotime($template['created_at']));
        $template['updated_at'] = date('Y-m-d H:i:s', strtotime($template['updated_at']));
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => $templates,
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
