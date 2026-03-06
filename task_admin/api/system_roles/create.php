<?php
/**
 * 系统角色创建接口
 * POST /task_admin/api/system_roles/create.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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
$name = trim($input['name'] ?? '');
$description = trim($input['description'] ?? '');

// 参数校验
if (empty($name)) {
    echo json_encode([
        'code' => 1002,
        'message' => '角色名称不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查角色名称是否已存在
    $stmt = $db->prepare("SELECT id FROM system_roles WHERE name = ?");
    $stmt->execute([$name]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1003,
            'message' => '角色名称已存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 创建角色
    $stmt = $db->prepare("INSERT INTO system_roles (name, description, status) VALUES (?, ?, 1)");
    $stmt->execute([$name, $description]);
    
    $role_id = $db->lastInsertId();
    
    echo json_encode([
        'code' => 0,
        'message' => '角色创建成功',
        'data' => [
            'role_id' => (int)$role_id
        ],
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