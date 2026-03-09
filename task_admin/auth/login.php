<?php
/**
 * Admin登录接口
 * POST /task_admin/auth/login.php
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

require_once __DIR__ . '/../../core/Database.php';
require_once __DIR__ . '/../../core/Token.php';

// 数据库连接
$db = Database::connect();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? ''); // 前端已MD5

// 检查密码是否为MD5格式（32位十六进制），如果不是则自动加密
if (!preg_match('/^[a-f0-9]{32}$/i', $password)) {
    $originalPassword = $password;
    $password = md5($password);
    // 写入日志文件
    $logMessage = "[" . date('Y-m-d H:i:s') . "] === 密码加密日志 ===\n";
    $logMessage .= "[" . date('Y-m-d H:i:s') . "] 原始密码: " . $originalPassword . "\n";
    $logMessage .= "[" . date('Y-m-d H:i:s') . "] MD5加密后: " . $password . "\n\n";
    file_put_contents(__DIR__ . '/login.log', $logMessage, FILE_APPEND);
}

// 写入日志文件
$logMessage = "[" . date('Y-m-d H:i:s') . "] === 登录请求日志 ===\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 请求时间: " . date('Y-m-d H:i:s') . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 请求IP: " . ($_SERVER['REMOTE_ADDR'] ?? '未知') . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 用户名: " . $username . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 密码哈希: " . $password . "\n\n";
file_put_contents(__DIR__ . '/login.log', $logMessage, FILE_APPEND);

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

try {
    // 查询用户信息
    $stmt = $db->prepare("SELECT su.*, sr.name as role_name FROM system_users su LEFT JOIN system_roles sr ON su.role_id = sr.id WHERE su.username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        echo json_encode([
            'code' => 1004,
            'message' => '用户名或密码错误',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查用户状态
    if ($user['status'] !== 1) {
        echo json_encode([
            'code' => 1005,
            'message' => '账号已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查密码
    if ($user['password_hash'] !== $password) {
        echo json_encode([
            'code' => 1004,
            'message' => '用户名或密码错误',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 检查角色状态
    $stmt = $db->prepare("SELECT status FROM system_roles WHERE id = ?");
    $stmt->execute([$user['role_id']]);
    $role = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$role || $role['status'] !== 1) {
        echo json_encode([
            'code' => 1006,
            'message' => '角色已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 生成Token（使用Token类）
    $tokenData = Token::generate($user['id'], Token::TYPE_ADMIN);
    
    // 更新用户Token和最后登录时间
    $stmt = $db->prepare("UPDATE system_users SET token = ?, token_expired_at = ?, last_login_at = NOW() WHERE id = ?");
    $stmt->execute([$tokenData['token'], $tokenData['expired_at'], $user['id']]);
    
    // 写入成功登录日志到文件
    $logMessage = "[" . date('Y-m-d H:i:s') . "] === 登录成功日志 ===\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 用户ID: " . $user['id'] . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 角色ID: " . $user['role_id'] . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 角色名称: " . $user['role_name'] . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] 生成的Token: " . $tokenData['token'] . "\n";
$logMessage .= "[" . date('Y-m-d H:i:s') . "] Token过期时间: " . $tokenData['expired_at'] . "\n\n";
file_put_contents(__DIR__ . '/login.log', $logMessage, FILE_APPEND);

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => '登录成功',
        'data' => [
            'token' => $tokenData['token'],
            'username' => $username,
            'user_id' => $user['id'],
            'role_id' => $user['role_id'],
            'role_name' => $user['role_name'],
            'expired_at' => strtotime($tokenData['expired_at'])
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