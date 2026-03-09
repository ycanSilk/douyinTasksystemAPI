<?php
/**
 * 任务模板更新
 * POST /task_admin/api/tasks/update.php
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
    // 构建更新字段
    $updates = [];
    $params = [];
    
    if (isset($input['title'])) {
        $updates[] = 'title = ?';
        $params[] = trim($input['title']);
    }
    if (isset($input['price'])) {
        $updates[] = 'price = ?';
        $params[] = (float)$input['price'];
    }
    if (isset($input['description1'])) {
        $updates[] = 'description1 = ?';
        $params[] = trim($input['description1']);
    }
    if (isset($input['description2'])) {
        $updates[] = 'description2 = ?';
        $params[] = trim($input['description2']);
    }
    if (isset($input['status'])) {
        $updates[] = 'status = ?';
        $params[] = (int)$input['status'];
    }
    
    // 组合任务字段
    if (isset($input['stage1_title'])) {
        $updates[] = 'stage1_title = ?';
        $params[] = trim($input['stage1_title']);
    }
    if (isset($input['stage1_price'])) {
        $updates[] = 'stage1_price = ?';
        $params[] = (float)$input['stage1_price'];
    }
    if (isset($input['stage2_title'])) {
        $updates[] = 'stage2_title = ?';
        $params[] = trim($input['stage2_title']);
    }
    if (isset($input['stage2_price'])) {
        $updates[] = 'stage2_price = ?';
        $params[] = (float)$input['stage2_price'];
    }
    if (isset($input['default_stage1_count'])) {
        $updates[] = 'default_stage1_count = ?';
        $params[] = (int)$input['default_stage1_count'];
    }
    if (isset($input['default_stage2_count'])) {
        $updates[] = 'default_stage2_count = ?';
        $params[] = (int)$input['default_stage2_count'];
    }

    // 佣金字段
    if (isset($input['c_user_commission'])) {
        $updates[] = 'c_user_commission = ?';
        $params[] = (int)$input['c_user_commission'];
    }
    if (isset($input['agent_commission'])) {
        $updates[] = 'agent_commission = ?';
        $params[] = (int)$input['agent_commission'];
    }
    if (isset($input['senior_agent_commission'])) {
        $updates[] = 'senior_agent_commission = ?';
        $params[] = (int)$input['senior_agent_commission'];
    }
    if (array_key_exists('stage1_c_user_commission', $input)) {
        $updates[] = 'stage1_c_user_commission = ?';
        $params[] = $input['stage1_c_user_commission'] !== null ? (int)$input['stage1_c_user_commission'] : null;
    }
    if (array_key_exists('stage1_agent_commission', $input)) {
        $updates[] = 'stage1_agent_commission = ?';
        $params[] = $input['stage1_agent_commission'] !== null ? (int)$input['stage1_agent_commission'] : null;
    }
    if (array_key_exists('stage1_senior_agent_commission', $input)) {
        $updates[] = 'stage1_senior_agent_commission = ?';
        $params[] = $input['stage1_senior_agent_commission'] !== null ? (int)$input['stage1_senior_agent_commission'] : null;
    }
    if (array_key_exists('stage2_c_user_commission', $input)) {
        $updates[] = 'stage2_c_user_commission = ?';
        $params[] = $input['stage2_c_user_commission'] !== null ? (int)$input['stage2_c_user_commission'] : null;
    }
    if (array_key_exists('stage2_agent_commission', $input)) {
        $updates[] = 'stage2_agent_commission = ?';
        $params[] = $input['stage2_agent_commission'] !== null ? (int)$input['stage2_agent_commission'] : null;
    }
    if (array_key_exists('stage2_senior_agent_commission', $input)) {
        $updates[] = 'stage2_senior_agent_commission = ?';
        $params[] = $input['stage2_senior_agent_commission'] !== null ? (int)$input['stage2_senior_agent_commission'] : null;
    }
    
    if (empty($updates)) {
        echo json_encode(['code' => 1003, 'message' => '没有可更新的字段', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $params[] = $id;
    $sql = "UPDATE task_templates SET " . implode(', ', $updates) . " WHERE id = ?";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    
    echo json_encode(['code' => 0, 'message' => '更新成功', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '更新失败：' . $e->getMessage(), 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
