<?php
/**
 * 调用远程API更新定时器状态的PHP脚本
 * 功能：通过cURL调用远程API更新定时器时间
 */

// 设置时区
date_default_timezone_set('Asia/Shanghai');

// 定义API URL
$apiUrl = 'http://localhost:28806/task_admin/api/admin_notifications/update_timer.php';

// 使用时间戳格式，避免时区问题
$currentTime = time() + 60; // 当前时间加60秒，确保不小于远程服务器时间

// 定义检测间隔（秒）
$detectionInterval = 60;

// 准备请求数据
$requestData = [
    'last_detection_time' => $currentTime,
    'detection_interval' => $detectionInterval
];

// 初始化cURL
$ch = curl_init($apiUrl);

// 设置cURL选项
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json'
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($requestData));

// 执行请求
$response = curl_exec($ch);

// 检查是否有错误
if (curl_errno($ch)) {
    $error = curl_error($ch);
    echo "cURL错误: $error\n";
} else {
    // 输出响应
    echo "API响应: $response\n";
    
    // 解析响应
    $responseData = json_decode($response, true);
    if ($responseData && isset($responseData['code']) && $responseData['code'] == 0) {
        echo "更新成功！\n";
        echo "上次检测时间: " . $responseData['data']['last_detection_time'] . "\n";
        echo "下次检测时间: " . $responseData['data']['next_detection_time'] . "\n";
        echo "检测间隔: " . $responseData['data']['detection_interval'] . "秒\n";
    } else {
        echo "更新失败: " . ($responseData['message'] ?? '未知错误') . "\n";
    }
}

// 在PHP 8.0+中，curl_close()已经不需要调用

// 输出执行时间
echo "\n执行完成时间: " . date('Y-m-d H:i:s') . "\n";
?>