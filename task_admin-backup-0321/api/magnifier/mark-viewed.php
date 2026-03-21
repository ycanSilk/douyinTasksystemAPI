<?php
/**
 * 标记放大镜任务为已查看状态
 * POST /task_admin/api/magnifier/mark-viewed.php
 * 
 * 功能：将放大镜任务标记为已查看状态，避免重复生成通知
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

// 认证中间件
AdminAuthMiddleware::authenticate();

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

try {
    $db = Database::connect();
    
    // 获取请求数据
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['task_id'])) {
        Response::error('缺少任务ID', $errorCodes['PARAMETER_ERROR'] ?? 4000);
    }
    
    $taskId = $data['task_id'];
    
    // 检查任务是否存在
    $stmt = $db->prepare("SELECT id FROM magnifying_glass_tasks WHERE id = ?");
    $stmt->execute([$taskId]);
    if ($stmt->rowCount() === 0) {
        Response::error('任务不存在', $errorCodes['NOT_FOUND'] ?? 4040);
    }
    
    // 标记任务为已查看
    $stmt = $db->prepare("UPDATE magnifying_glass_tasks SET view_status = 1, updated_at = NOW() WHERE id = ?");
    $stmt->execute([$taskId]);
    
    // 更新放大镜任务数量记录
    $stmt = $db->query("SELECT current_count FROM admin_system_notification_magnifier_count ORDER BY id DESC LIMIT 1");
    $countData = $stmt->fetch(PDO::FETCH_ASSOC);
    $currentCount = $countData['current_count'] ?? 0;
    
    $stmt = $db->prepare("INSERT INTO admin_system_notification_magnifier_count (current_count, previous_count, last_viewed_count) VALUES (?, ?, ?)");
    $stmt->execute([$currentCount, $currentCount, $currentCount]);
    
    Response::success(['task_id' => $taskId, 'status' => 'viewed'], '标记成功');
    
} catch (Exception $e) {
    error_log("标记放大镜任务已查看错误: " . $e->getMessage());
    Response::error('标记失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
?>