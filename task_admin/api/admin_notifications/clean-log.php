<?php
// 日志清理API接口

// 引入必要的文件
require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../middleware/AdminAuthMiddleware.php';

// 权限验证
AdminAuthMiddleware::authenticate();

// 获取请求数据
$input = json_decode(file_get_contents('php://input'), true);
$days = isset($input['days']) ? intval($input['days']) : 2; // 默认清理2天前的日志

// 连接数据库
try {
    $pdo = new PDO(
        "mysql:host={$config['db_host']};dbname={$config['db_name']};charset=utf8mb4",
        $config['db_user'],
        $config['db_pass'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );

    // 计算清理时间
    $clean_time = date('Y-m-d H:i:s', strtotime("-{$days} days"));

    // 执行清理操作
    $stmt = $pdo->prepare("DELETE FROM admin_system_notification_log WHERE detection_time < :clean_time");
    $stmt->bindParam(':clean_time', $clean_time, PDO::PARAM_STR);
    $stmt->execute();

    $deleted_count = $stmt->rowCount();

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'deleted_count' => $deleted_count
        ]
    ]);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '清理日志失败: ' . $e->getMessage()
    ]);
    exit;
}
?>
