<?php
/**
 * 系统角色编辑接口
 * POST /task_admin/api/system_roles/update.php
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
$name = trim($input['name'] ?? '');
$description = trim($input['description'] ?? '');
$status = (int)($input['status'] ?? 1);

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

if (empty($name)) {
    echo json_encode([
        'code' => 1003,
        'message' => '角色名称不能为空',
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
            'code' => 1004,
            'message' => '角色不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查角色名称是否已被其他角色使用
    $stmt = $db->prepare("SELECT id FROM system_roles WHERE name = ? AND id != ?");
    $stmt->execute([$name, $role_id]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1005,
            'message' => '角色名称已被使用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 防止禁用超级管理员角色（假设ID为1）
    if ($role_id === 1 && $status === 0) {
        echo json_encode([
            'code' => 1006,
            'message' => '超级管理员角色不能禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 更新角色信息
    $stmt = $db->prepare("UPDATE system_roles SET name = ?, description = ?, status = ? WHERE id = ?");
    $stmt->execute([$name, $description, $status, $role_id]);
    
    echo json_encode([
        'code' => 0,
        'message' => '角色更新成功',
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