<?php
// 日志保存API
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 日志目录
$logDir = __DIR__ . '/../../logs';

// 确保日志目录存在
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
}

// 读取请求数据
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    echo json_encode([
        'code' => 400,
        'message' => '无效的请求数据'
    ]);
    exit;
}

// 生成日志文件名（按日期）
$date = date('Y-m-d');
$logFile = $logDir . "/log_$date.txt";

// 格式化日志内容
$timestamp = $data['timestamp'] ?? date('Y-m-d H:i:s.u');
$level = $data['level'] ?? 'INFO';
$module = $data['module'] ?? 'SYSTEM';
$message = $data['message'] ?? '';

$logLine = "[$timestamp] [$level] [$module] $message\n";

// 写入日志文件
if (file_put_contents($logFile, $logLine, FILE_APPEND | LOCK_EX)) {
    echo json_encode([
        'code' => 0,
        'message' => '日志保存成功',
        'data' => [
            'file' => $logFile,
            'line' => $logLine
        ]
    ]);
} else {
    echo json_encode([
        'code' => 500,
        'message' => '日志保存失败'
    ]);
}
?>