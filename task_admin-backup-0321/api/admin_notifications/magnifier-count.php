<?php
// 放大镜任务数量管理接口

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

try {
    // 获取最新的放大镜任务数量记录
    $stmt = $db->query("SELECT current_count, previous_count, last_viewed_count FROM admin_system_notification_magnifier_count ORDER BY id DESC LIMIT 1");
    $countData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($countData) {
        $currentCount = $countData['current_count'];
        $previousCount = $countData['previous_count'];
        $lastViewedCount = $countData['last_viewed_count'];
        $newCount = $currentCount - $previousCount;
    } else {
        $currentCount = 0;
        $previousCount = 0;
        $lastViewedCount = 0;
        $newCount = 0;
    }
    
    // 获取未查看和已查看的任务数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM magnifying_glass_tasks WHERE status = ? AND view_status = ?");
    $stmt->execute([0, 0]);
    $unviewedCount = (int)$stmt->fetchColumn();
    
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM magnifying_glass_tasks WHERE status = ? AND view_status = ?");
    $stmt->execute([0, 1]);
    $viewedCount = (int)$stmt->fetchColumn();
    
    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'current_count' => $currentCount,
            'previous_count' => $previousCount,
            'last_viewed_count' => $lastViewedCount,
            'new_count' => $newCount,
            'unviewed_count' => $unviewedCount,
            'viewed_count' => $viewedCount
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '获取放大镜任务数量失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>