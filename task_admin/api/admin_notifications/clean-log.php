<?php
// 日志清理API接口

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 引入必要的文件
require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// 权限验证
AdminAuthMiddleware::authenticate();
$db = Database::connect();

// 获取请求数据
$input = json_decode(file_get_contents('php://input'), true);
$days = isset($input['days']) ? intval($input['days']) : 2; // 默认清理2天前的日志

try {
    // 输出调试信息
    error_log("=== 日志清理操作 ===");
    error_log("清理天数: {$days}");
    
    // 检查当前服务器时间和时区
    error_log("当前服务器时间: " . date('Y-m-d H:i:s'));
    error_log("当前服务器时区: " . date_default_timezone_get());
    
    // 设置时区为中国北京时间
    date_default_timezone_set('Asia/Shanghai');
    error_log("设置后时区: " . date_default_timezone_get());
    error_log("设置后当前时间: " . date('Y-m-d H:i:s'));
    
    // 计算清理时间
    $clean_time = date('Y-m-d H:i:s', strtotime("-{$days} days"));
    error_log("清理时间: {$clean_time}");

    // 先查询符合条件的记录数量
    $countStmt = $db->prepare("SELECT COUNT(*) as count FROM admin_system_notification_log WHERE detection_time < :clean_time");
    $countStmt->bindParam(':clean_time', $clean_time, PDO::PARAM_STR);
    $countStmt->execute();
    $count = $countStmt->fetch()['count'];
    error_log("符合条件的记录数量: {$count}");
    
    // 查询所有记录，用于调试
    $allStmt = $db->prepare("SELECT id, detection_time FROM admin_system_notification_log ORDER BY detection_time DESC LIMIT 10");
    $allStmt->execute();
    $allRecords = $allStmt->fetchAll();
    error_log("数据库中前10条记录:");
    foreach ($allRecords as $record) {
        error_log("ID: {$record['id']}, detection_time: {$record['detection_time']}");
    }

    // 执行清理操作
    $stmt = $db->prepare("DELETE FROM admin_system_notification_log WHERE detection_time < :clean_time");
    $stmt->bindParam(':clean_time', $clean_time, PDO::PARAM_STR);
    $stmt->execute();

    $deleted_count = $stmt->rowCount();
    error_log("实际删除的记录数量: {$deleted_count}");

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => "已清理{$deleted_count}条日志记录",
        'data' => [
            'deleted_count' => $deleted_count,
            'clean_time' => $clean_time,
            'current_time' => date('Y-m-d H:i:s'),
            'timezone' => date_default_timezone_get()
        ]
    ]);

} catch (Exception $e) {
    // 输出错误信息
    error_log("清理日志失败: " . $e->getMessage());
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '清理日志失败: ' . $e->getMessage()
    ]);
    exit;
}
?>
