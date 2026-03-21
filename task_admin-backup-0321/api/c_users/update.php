<?php
/**
 * C端用户更新
 * POST /task_admin/api/c_users/update.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

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
    echo json_encode(['code' => 1002, 'message' => '用户ID不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $updates = [];
    $params = [];
    
    if (isset($input['username'])) {
        $updates[] = 'username = ?';
        $params[] = trim($input['username']);
    }
    if (isset($input['email'])) {
        $updates[] = 'email = ?';
        $params[] = trim($input['email']);
    }
    if (isset($input['phone'])) {
        $updates[] = 'phone = ?';
        $params[] = trim($input['phone']);
    }
    if (isset($input['is_agent'])) {
        $updates[] = 'is_agent = ?';
        $params[] = (int)$input['is_agent'];
    }
    if (isset($input['status'])) {
        $updates[] = 'status = ?';
        $params[] = (int)$input['status'];
    }
    if (isset($input['reason'])) {
        $updates[] = 'reason = ?';
        $params[] = trim($input['reason']);
    }
    if (isset($input['password']) && !empty($input['password'])) {
        $updates[] = 'password_hash = ?';
        $params[] = password_hash($input['password'], PASSWORD_DEFAULT);
    }
    
    if (empty($updates)) {
        echo json_encode(['code' => 1003, 'message' => '没有可更新的字段', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $params[] = $id;
    $sql = "UPDATE c_users SET " . implode(', ', $updates) . " WHERE id = ?";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    
    echo json_encode(['code' => 0, 'message' => '更新成功', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '更新失败：' . $e->getMessage(), 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
