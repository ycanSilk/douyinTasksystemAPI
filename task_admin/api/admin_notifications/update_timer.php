<?php
/**
 * 更新计时器状态API接口
 * POST /task_admin/api/admin_notifications/update_timer.php
 * 
 * 功能：更新计时器状态，确保计时器持续运行
 */

// 设置时区为中国北京时间
date_default_timezone_set('Asia/Shanghai');

// 输出调试日志
error_log('=== Update Timer API Called ===');
error_log('Request Method: ' . $_SERVER['REQUEST_METHOD']);
error_log('Request URI: ' . $_SERVER['REQUEST_URI']);
error_log('Server Time: ' . date('Y-m-d H:i:s'));
error_log('Server Timezone: ' . date_default_timezone_get());

// 记录请求体
$requestBody = file_get_contents('php://input');
error_log('Request Body: ' . $requestBody);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');
header('Access-Control-Allow-Methods: POST, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 验证请求方法
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    error_log('请求方法错误: ' . $_SERVER['REQUEST_METHOD']);
    http_response_code(405);
    echo json_encode([
        'code' => 405,
        'message' => '请求方法错误，只支持POST方法',
        'data' => [],
        'timestamp' => time()
    ]);
    exit;
}

// 验证请求体
if (empty($requestBody)) {
    error_log('请求体为空');
    http_response_code(400);
    echo json_encode([
        'code' => 400,
        'message' => '请求体不能为空',
        'data' => [],
        'timestamp' => time()
    ]);
    exit;
}

$data = json_decode($requestBody, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    error_log('请求体JSON格式错误: ' . json_last_error_msg());
    http_response_code(400);
    echo json_encode([
        'code' => 400,
        'message' => '请求体JSON格式错误: ' . json_last_error_msg(),
        'data' => [],
        'timestamp' => time()
    ]);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

$db = Database::connect();
try {
    // 更新计时器状态 - 不需要认证（定时任务接口）
    error_log('定时任务更新计时器状态');
    error_log('当前时区：' . date_default_timezone_get());
    
    // 验证检测间隔
    $detectionInterval = isset($data['detection_interval']) ? intval($data['detection_interval']) : 60;
    if ($detectionInterval <= 0 || $detectionInterval > 3600) {
        error_log('检测间隔参数错误: ' . $detectionInterval);
        http_response_code(400);
        echo json_encode([
            'code' => 400,
            'message' => '检测间隔必须在1-3600秒之间',
            'data' => [],
            'timestamp' => time()
        ]);
        exit;
    }
    
    // 验证时间格式（支持时间戳或YYYY-MM-DD HH:MM:SS格式）
    $lastDetectionTime = isset($data['last_detection_time']) ? $data['last_detection_time'] : time();
    
    // 如果是时间戳，转换为日期时间格式
    if (is_numeric($lastDetectionTime)) {
        $lastDetectionTime = date('Y-m-d H:i:s', intval($lastDetectionTime));
    } else {
        // 验证日期时间格式
        $dateTime = date_create_from_format('Y-m-d H:i:s', $lastDetectionTime);
        if (!$dateTime) {
            error_log('时间格式错误: ' . $lastDetectionTime);
            http_response_code(400);
            echo json_encode([
                'code' => 400,
                'message' => '时间格式错误，应为时间戳或YYYY-MM-DD HH:MM:SS',
                'data' => [],
                'timestamp' => time()
            ]);
            exit;
        }
    }
    
    // 验证时间不能小于当前时间
    $currentTime = date('Y-m-d H:i:s');
    if (strtotime($lastDetectionTime) < strtotime($currentTime)) {
        error_log('时间不能小于当前时间: ' . $lastDetectionTime);
        http_response_code(400);
        echo json_encode([
            'code' => 400,
            'message' => '时间不能小于当前时间',
            'data' => [],
            'timestamp' => time()
        ]);
        exit;
    }
    
    $nextDetectionTime = date('Y-m-d H:i:s', strtotime($lastDetectionTime) + $detectionInterval);
    
    error_log('更新计时器状态: ' . $lastDetectionTime . ' -> ' . $nextDetectionTime . ', 间隔: ' . $detectionInterval . '秒');
    
    // 更新或插入计时器记录
    $stmt = $db->prepare("UPDATE admin_system_notification_timer SET last_detection_time = ?, next_detection_time = ?, detection_interval = ? WHERE status = 1");
    $affectedRows = $stmt->execute([$lastDetectionTime, $nextDetectionTime, $detectionInterval]);
    
    if ($affectedRows === 0) {
        // 插入新记录
        error_log('没有找到现有记录，插入新记录');
        $stmt = $db->prepare("INSERT INTO admin_system_notification_timer (last_detection_time, next_detection_time, detection_interval, status) VALUES (?, ?, ?, 1)");
        $stmt->execute([$lastDetectionTime, $nextDetectionTime, $detectionInterval]);
    }
    
    Response::success([
        'last_detection_time' => $lastDetectionTime,
        'next_detection_time' => $nextDetectionTime,
        'detection_interval' => $detectionInterval
    ], '更新计时器状态成功');
} catch (Exception $e) {
    error_log('操作失败: ' . $e->getMessage());
    Response::error('操作失败: ' . $e->getMessage(), 5000);
}
?>