<?php
/**
 * 更新权限模板
 * POST /task_admin/api/system_permission_template/update.php
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

if (!$data || !isset($data['id'])) {
    echo json_encode([
        'code' => 1002,
        'message' => '参数缺失',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查记录是否存在
    $stmt = $db->prepare("SELECT id FROM system_permission_template WHERE id = ?");
    $stmt->execute([$data['id']]);
    if (!$stmt->fetch()) {
        echo json_encode([
            'code' => 1003,
            'message' => '导航面板不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 构建更新语句
    $updateFields = [];
    $updateValues = [];
    
    if (isset($data['name'])) {
        $updateFields[] = 'name = ?';
        $updateValues[] = $data['name'];
    }
    
    if (isset($data['code'])) {
        // 检查代码是否已被其他记录使用
        $stmt = $db->prepare("SELECT id FROM system_permission_template WHERE code = ? AND id != ?");
        $stmt->execute([$data['code'], $data['id']]);
        if ($stmt->fetch()) {
            echo json_encode([
                'code' => 1004,
                'message' => '导航代码已存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        $updateFields[] = 'code = ?';
        $updateValues[] = $data['code'];
    }
    
    if (isset($data['icon'])) {
        $updateFields[] = 'icon = ?';
        $updateValues[] = $data['icon'];
    }
    
    if (isset($data['sort_order'])) {
        $updateFields[] = 'sort_order = ?';
        $updateValues[] = $data['sort_order'];
    }
    
    if (isset($data['status'])) {
        $updateFields[] = 'status = ?';
        $updateValues[] = $data['status'];
    }
    
    if (isset($data['description'])) {
        $updateFields[] = 'description = ?';
        $updateValues[] = $data['description'];
    }
    
    if (empty($updateFields)) {
        echo json_encode([
            'code' => 1005,
            'message' => '没有需要更新的字段',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $updateValues[] = $data['id'];
    $sql = "UPDATE system_permission_template SET " . implode(', ', $updateFields) . " WHERE id = ?";
    
    $stmt = $db->prepare($sql);
    $result = $stmt->execute($updateValues);
    
    if ($result) {
        echo json_encode([
            'code' => 0,
            'message' => '更新成功',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'code' => 5000,
            'message' => '更新失败',
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