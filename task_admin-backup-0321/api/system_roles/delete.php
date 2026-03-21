<?php
/**
 * 系统角色删除接口
 * POST /task_admin/api/system_roles/delete.php
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
$role_id = (int)($input['role_id'] ?? 0);

// 参数校验
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
    // 检查角色是否存在
    $stmt = $db->prepare("SELECT id FROM system_roles WHERE id = ?");
    $stmt->execute([$role_id]);
    if (!$stmt->fetch()) {
        echo json_encode([
            'code' => 1003,
            'message' => '角色不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 防止删除超级管理员角色（假设ID为1）
    if ($role_id === 1) {
        echo json_encode([
            'code' => 1004,
            'message' => '超级管理员角色不能删除',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查是否有用户使用该角色
    $stmt = $db->prepare("SELECT id FROM system_users WHERE role_id = ?");
    $stmt->execute([$role_id]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1005,
            'message' => '该角色正在被用户使用，不能删除',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 删除角色关联的权限
    $stmt = $db->prepare("DELETE FROM system_role_permission WHERE role_id = ?");
    $stmt->execute([$role_id]);
    
    // 删除角色
    $stmt = $db->prepare("DELETE FROM system_roles WHERE id = ?");
    $stmt->execute([$role_id]);
    
    echo json_encode([
        'code' => 0,
        'message' => '角色删除成功',
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