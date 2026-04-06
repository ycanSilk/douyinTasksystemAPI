<?php
/**
 * 保存前端 WebSocket 连接日志
 * 用于接收前端发送的 WebSocket 连接相关日志并保存到文件
 */

// 允许所有跨域请求
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// 如果是 OPTIONS 请求，直接返回
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 检查请求方法
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['code' => 405, 'message' => 'Method Not Allowed']);
    exit();
}

// 读取请求数据
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// 检查数据格式
if (!isset($data['logs']) || !is_array($data['logs'])) {
    http_response_code(400);
    echo json_encode(['code' => 400, 'message' => 'Invalid data format']);
    exit();
}

// 日志目录
$logDir = __DIR__ . '/../../../ws/connect';

// 确保日志目录存在
if (!is_dir($logDir)) {
    mkdir($logDir, 0777, true);
}

// 获取当前日期，格式为 YYYYMMDD
$date = date('Ymd');

// 日志文件路径
$logFile = $logDir . "/$date.log";

// 打开日志文件
$file = fopen($logFile, 'a');
if (!$file) {
    http_response_code(500);
    echo json_encode(['code' => 500, 'message' => 'Failed to open log file']);
    exit();
}

// 写入日志
foreach ($data['logs'] as $log) {
    $timestamp = $log['timestamp'] ?? date('Y-m-d H:i:s');
    $level = $log['level'] ?? 'info';
    $message = $log['message'] ?? '';
    $userAgent = $log['userAgent'] ?? '';
    $url = $log['url'] ?? '';
    
    $logMessage = "[$timestamp] [$level] $message | User-Agent: $userAgent | URL: $url\n";
    fwrite($file, $logMessage);
}

// 关闭日志文件
fclose($file);

// 返回成功响应
echo json_encode(['code' => 0, 'message' => 'Logs saved successfully']);
?>