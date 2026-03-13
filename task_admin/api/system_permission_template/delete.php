<?php
/**
 * 删除权限模板
 * POST /task_admin/api/system_permission_template/delete.php
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
    // 开始事务
    $db->beginTransaction();
    
    // 首先获取所有需要删除的模板ID（包括子导航）
    $templateIds = [$data['id']];
    
    // 查找所有子导航项
    $stmt = $db->prepare("SELECT id FROM system_permission_template WHERE parent_id = ?");
    $stmt->execute([$data['id']]);
    $childTemplates = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($childTemplates as $child) {
        $templateIds[] = $child['id'];
    }
    
    // 删除角色关联
    if (!empty($templateIds)) {
        $placeholders = str_repeat('?,', count($templateIds) - 1) . '?';
        $stmt = $db->prepare("DELETE FROM system_role_permission_template WHERE template_id IN ($placeholders)");
        $stmt->execute($templateIds);
        
        // 删除模板
        $stmt = $db->prepare("DELETE FROM system_permission_template WHERE id IN ($placeholders)");
        $result = $stmt->execute($templateIds);
    } else {
        $result = false;
    }
    
    if ($result && $stmt->rowCount() > 0) {
        $db->commit();
        echo json_encode([
            'code' => 0,
            'message' => '删除成功',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        $db->rollBack();
        echo json_encode([
            'code' => 1003,
            'message' => '导航面板不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    }
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库操作失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
?>