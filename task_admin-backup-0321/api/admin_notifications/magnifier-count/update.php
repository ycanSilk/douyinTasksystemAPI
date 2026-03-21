<?php
// 更新放大镜任务数量接口

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Database.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

// 获取请求数据
$input = json_decode(file_get_contents('php://input'), true);
$currentCount = isset($input['current_count']) ? intval($input['current_count']) : 0;

if ($currentCount < 0) {
    echo json_encode([
        'code' => 400,
        'message' => '任务数量不能为负数',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 获取最新的放大镜任务数量记录，作为previous_count
    $stmt = $db->query("SELECT current_count FROM admin_system_notification_magnifier_count ORDER BY id DESC LIMIT 1");
    $countData = $stmt->fetch(PDO::FETCH_ASSOC);
    $previousCount = $countData['current_count'] ?? 0;
    
    // 插入新记录
    $stmt = $db->prepare("INSERT INTO admin_system_notification_magnifier_count (current_count, previous_count) VALUES (?, ?)");
    $stmt->execute([$currentCount, $previousCount]);
    
    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'updated' => true
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '更新放大镜任务数量失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>