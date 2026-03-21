<?php
// 通知配置API接口

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

try {
    // 获取通知配置列表
    $stmt = $db->query("SELECT * FROM admin_system_notification_config ORDER BY id ASC");
    $configs = $stmt->fetchAll();

    // 处理notification_template字段
    foreach ($configs as &$config) {
        if (!empty($config['notification_template'])) {
            $config['notification_template'] = json_decode($config['notification_template'], true);
        }
    }

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => $configs
    ]);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '获取通知配置失败: ' . $e->getMessage()
    ]);
    exit;
}
?>
