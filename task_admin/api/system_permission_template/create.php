<?php
/**
 * 创建权限模板
 * POST /task_admin/api/system_permission_template/create.php
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

// 读取请求数据
$data = json_decode(file_get_contents('php://input'), true);

if (!$data || !isset($data['name']) || !isset($data['code']) || !isset($data['icon'])) {
    echo json_encode([
        'code' => 1002,
        'message' => '参数缺失',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查代码是否已存在
    $stmt = $db->prepare("SELECT id FROM system_permission_template WHERE code = ?");
    $stmt->execute([$data['code']]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1003,
            'message' => '导航代码已存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 插入数据
    $stmt = $db->prepare("INSERT INTO system_permission_template (name, code, icon, sort_order, status, description, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())");
    $result = $stmt->execute([
        $data['name'],
        $data['code'],
        $data['icon'],
        $data['sort_order'] ?? 0,
        $data['status'] ?? 1,
        $data['description'] ?? ''
    ]);
    
    if ($result) {
        echo json_encode([
            'code' => 0,
            'message' => '创建成功',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'code' => 5000,
            'message' => '创建失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库操作失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
?>