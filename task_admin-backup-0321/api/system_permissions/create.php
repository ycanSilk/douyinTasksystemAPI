<?php
/**
 * 系统权限创建接口
 * POST /task_admin/api/system_permissions/create.php
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
$name = trim($input['name'] ?? '');
$code = trim($input['code'] ?? '');
$description = trim($input['description'] ?? '');

// 参数校验
if (empty($name)) {
    echo json_encode([
        'code' => 1002,
        'message' => '权限名称不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($code)) {
    echo json_encode([
        'code' => 1003,
        'message' => '权限代码不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查权限代码是否已存在
    $stmt = $db->prepare("SELECT id FROM system_permissions WHERE code = ?");
    $stmt->execute([$code]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1004,
            'message' => '权限代码已存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 创建权限
    $stmt = $db->prepare("INSERT INTO system_permissions (name, code, description) VALUES (?, ?, ?)");
    $stmt->execute([$name, $code, $description]);
    
    $permission_id = $db->lastInsertId();
    
    echo json_encode([
        'code' => 0,
        'message' => '权限创建成功',
        'data' => [
            'permission_id' => (int)$permission_id
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