<?php
/**
 * 获取计时器状态API接口
 * GET /task_admin/api/admin_notifications/get_timer.php
 * 
 * 功能：获取计时器状态，确保页面刷新时不会重置计时器
 */

// 设置时区为中国北京时间
date_default_timezone_set('Asia/Shanghai');

// 输出调试日志
error_log('=== Get Timer API Called ===');
error_log('Request Method: ' . $_SERVER['REQUEST_METHOD']);
error_log('Request URI: ' . $_SERVER['REQUEST_URI']);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');
header('Access-Control-Allow-Methods: GET, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 验证请求方法
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    error_log('请求方法错误: ' . $_SERVER['REQUEST_METHOD']);
    http_response_code(405);
    echo json_encode([
        'code' => 405,
        'message' => '请求方法错误，只支持GET方法',
        'data' => [],
        'timestamp' => time()
    ]);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

$db = Database::connect();
try {
    // 获取计时器状态 - 不需要认证
    error_log('获取计时器状态');
    $stmt = $db->query("SELECT * FROM admin_system_notification_timer WHERE status = 1 ORDER BY id DESC LIMIT 1");
    $timer = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($timer) {
        $currentTime = time();
        $nextDetectionTime = strtotime($timer['next_detection_time']);
        // 直接计算剩余时间，不添加额外的60秒
        $remainingSeconds = max(0, $nextDetectionTime - $currentTime);
        
        error_log('获取计时器状态: ' . $remainingSeconds . '秒');
        Response::success([
            'timer' => $timer,
            'remaining_seconds' => $remainingSeconds,
            'detection_interval' => $timer['detection_interval'] ?? 60,
            'current_time' => $currentTime
        ], '获取计时器状态成功');
    } else {
        // 如果没有记录，创建默认记录
        error_log('没有计时器记录，创建默认记录');
        $defaultInterval = 60;
        $now = date('Y-m-d H:i:s');
        $nextDetectionTime = date('Y-m-d H:i:s', time() + $defaultInterval);
        
        $stmt = $db->prepare("INSERT INTO admin_system_notification_timer (last_detection_time, next_detection_time, detection_interval, status) VALUES (?, ?, ?, 1)");
        $stmt->execute([$now, $nextDetectionTime, $defaultInterval]);
        
        Response::success([
            'timer' => null,
            'remaining_seconds' => $defaultInterval,
            'detection_interval' => $defaultInterval,
            'current_time' => time()
        ], '获取计时器状态成功');
    }
} catch (Exception $e) {
    error_log('操作失败: ' . $e->getMessage());
    Response::error('操作失败: ' . $e->getMessage(), 5000);
}
?>