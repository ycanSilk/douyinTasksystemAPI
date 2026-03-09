<?php
/**
 * 系统用户创建接口
 * POST /task_admin/api/system_users/create.php
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
$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? ''); // 前端已MD5
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$role_id = (int)($input['role_id'] ?? 0);

// 参数校验
if (empty($username)) {
    echo json_encode([
        'code' => 1002,
        'message' => '用户名不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($password)) {
    echo json_encode([
        'code' => 1003,
        'message' => '密码不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 邮箱非必填，但如果填写了需要检查格式
if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'code' => 1004,
        'message' => '邮箱格式不正确',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($role_id)) {
    echo json_encode([
        'code' => 1005,
        'message' => '角色不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查用户名是否已存在
    $stmt = $db->prepare("SELECT id FROM system_users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        echo json_encode([
            'code' => 1006,
            'message' => '用户名已存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查邮箱是否已存在（仅当邮箱不为空时）
    if (!empty($email)) {
        $stmt = $db->prepare("SELECT id FROM system_users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            echo json_encode([
                'code' => 1007,
                'message' => '邮箱已存在',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }
    
    // 检查角色是否存在
    $stmt = $db->prepare("SELECT id FROM system_roles WHERE id = ? AND status = 1");
    $stmt->execute([$role_id]);
    if (!$stmt->fetch()) {
        echo json_encode([
            'code' => 1008,
            'message' => '角色不存在或已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 创建用户
    $stmt = $db->prepare("INSERT INTO system_users (username, password_hash, email, phone, role_id, status) VALUES (?, ?, ?, ?, ?, 1)");
    $stmt->execute([$username, $password, $email, $phone, $role_id]);
    
    $user_id = $db->lastInsertId();
    
    echo json_encode([
        'code' => 0,
        'message' => '用户创建成功',
        'data' => [
            'user_id' => (int)$user_id
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