<?php
/**
 * Admin登出接口
 * POST /task_admin/auth/logout.php
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

session_start();
session_destroy();

echo json_encode([
    'code' => 0,
    'message' => '登出成功',
    'data' => [],
    'timestamp' => time()
], JSON_UNESCAPED_UNICODE);
