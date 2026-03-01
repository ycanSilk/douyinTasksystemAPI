<?php
/**
 * Admin登录接口
 * POST /task_admin/auth/login.php
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

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? ''); // 前端已MD5

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

// 读取管理员账号文件
$adminsFile = __DIR__ . '/admins.txt';
if (!file_exists($adminsFile)) {
    echo json_encode([
        'code' => 5000,
        'message' => '系统配置错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$admins = file($adminsFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$authenticated = false;

foreach ($admins as $line) {
    // 跳过注释行
    if (strpos(trim($line), '#') === 0) {
        continue;
    }
    
    // 解析账号密码
    $parts = explode(':', $line, 2);
    if (count($parts) === 2) {
        $storedUsername = trim($parts[0]);
        $storedPassword = trim($parts[1]);
        
        if ($storedUsername === $username && $storedPassword === $password) {
            $authenticated = true;
            break;
        }
    }
}

if (!$authenticated) {
    echo json_encode([
        'code' => 1004,
        'message' => '用户名或密码错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 生成Token（使用MD5 + 时间戳）
$token = md5($username . time() . rand(1000, 9999));
$expiredAt = time() + 86400; // 24小时

// 启动Session存储Token
session_start();
$_SESSION['admin_token'] = $token;
$_SESSION['admin_username'] = $username;
$_SESSION['admin_expired_at'] = $expiredAt;

// 返回成功响应
echo json_encode([
    'code' => 0,
    'message' => '登录成功',
    'data' => [
        'token' => $token,
        'username' => $username,
        'expired_at' => $expiredAt
    ],
    'timestamp' => time()
], JSON_UNESCAPED_UNICODE);
