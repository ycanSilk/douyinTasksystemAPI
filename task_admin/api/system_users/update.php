<?php
/**
 * 系统用户编辑接口
 * POST /task_admin/api/system_users/update.php
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
$user_id = (int)($input['user_id'] ?? 0);
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$role_id = (int)($input['role_id'] ?? 0);
$status = (int)($input['status'] ?? 1);

// 参数校验
if (empty($user_id)) {
    echo json_encode([
        'code' => 1002,
        'message' => '用户ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($email)) {
    echo json_encode([
        'code' => 1003,
        'message' => '邮箱不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($role_id)) {
    echo json_encode([
        'code' => 1004,
        'message' => '角色不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查用户是否存在
    $stmt = $db->prepare("SELECT id, username FROM system_users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user) {
        echo json_encode([
            'code' => 1005,
            'message' => '用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查邮箱是否已被其他用户使用
    $stmt = $db->prepare("SELECT id FROM system_users WHERE email = ? AND id != ?");
    $stmt->execute([$email, $user_id]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1006,
            'message' => '邮箱已被其他用户使用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查角色是否存在
    $stmt = $db->prepare("SELECT id FROM system_roles WHERE id = ? AND status = 1");
    $stmt->execute([$role_id]);
    if (!$stmt->fetch()) {
        echo json_encode([
            'code' => 1007,
            'message' => '角色不存在或已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 更新用户信息
    $stmt = $db->prepare("UPDATE system_users SET email = ?, phone = ?, role_id = ?, status = ? WHERE id = ?");
    $stmt->execute([$email, $phone, $role_id, $status, $user_id]);
    
    echo json_encode([
        'code' => 0,
        'message' => '用户更新成功',
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