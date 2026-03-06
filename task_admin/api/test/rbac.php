<?php
/**
 * RBAC测试接口
 * GET /task_admin/api/test/rbac.php
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

require_once __DIR__ . '/../../auth/RBACMiddleware.php';

// 测试无权限访问
// $user = RBACMiddleware::authenticate('test_permission');

// 测试无权限限制访问
$user = RBACMiddleware::authenticate();

// 获取用户权限列表
$permissions = RBACMiddleware::getUserPermissions($user['id']);

echo json_encode([
    'code' => 0,
    'message' => 'RBAC测试成功',
    'data' => [
        'user' => $user,
        'permissions' => $permissions
    ],
    'timestamp' => time()
], JSON_UNESCAPED_UNICODE);