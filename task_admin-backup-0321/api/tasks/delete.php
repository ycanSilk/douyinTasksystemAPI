<?php
/**
 * 任务模板删除
 * POST /task_admin/api/tasks/delete.php
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

AdminAuthMiddleware::authenticate();
$db = Database::connect();

$input = json_decode(file_get_contents('php://input'), true);
$id = (int)($input['id'] ?? 0);

if (!$id) {
    echo json_encode(['code' => 1002, 'message' => '模板ID不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查是否被使用
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM b_tasks WHERE template_id = ?");
    $stmt->execute([$id]);
    $count = (int)$stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    if ($count > 0) {
        echo json_encode(['code' => 1003, 'message' => '该模板已被使用，无法删除', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $stmt = $db->prepare("DELETE FROM task_templates WHERE id = ?");
    $stmt->execute([$id]);
    
    echo json_encode(['code' => 0, 'message' => '删除成功', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '删除失败：' . $e->getMessage(), 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
