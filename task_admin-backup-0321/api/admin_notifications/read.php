<?php
// 标记通知已读API接口

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
$notification_id = isset($input['notification_id']) ? intval($input['notification_id']) : 0;

if ($notification_id <= 0) {
    echo json_encode([
        'code' => 400,
        'message' => '通知ID不能为空'
    ]);
    exit;
}

try {
    // 先检查通知是否存在以及状态
    $stmt = $db->prepare("SELECT status FROM admin_system_notification WHERE id = :id");
    $stmt->bindParam(':id', $notification_id, PDO::PARAM_INT);
    $stmt->execute();
    $notification = $stmt->fetch();
    
    if (!$notification) {
        echo json_encode([
            'code' => 404,
            'message' => '通知不存在'
        ]);
        exit;
    }
    
    // 检查是否已经是已读状态
    if ($notification['status'] === 1) {
        echo json_encode([
            'code' => 0,
            'message' => '通知已经是已读状态'
        ]);
        exit;
    }
    
    // 标记通知为已读
    $stmt = $db->prepare("UPDATE admin_system_notification SET status = 1 WHERE id = :id");
    $stmt->bindParam(':id', $notification_id, PDO::PARAM_INT);
    $stmt->execute();

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => '已标记通知为已读'
    ]);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '标记通知已读失败: ' . $e->getMessage()
    ]);
    exit;
}
?>
