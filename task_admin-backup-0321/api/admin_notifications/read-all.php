<?php
// 批量标记已读API接口

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
$type = isset($input['type']) ? $input['type'] : '';

try {
    // 先检查是否有符合条件的未读通知
    if (!empty($type)) {
        $checkStmt = $db->prepare("SELECT COUNT(*) as count FROM admin_system_notification WHERE type = :type AND status = 0");
        $checkStmt->bindParam(':type', $type, PDO::PARAM_STR);
    } else {
        $checkStmt = $db->prepare("SELECT COUNT(*) as count FROM admin_system_notification WHERE status = 0");
    }
    $checkStmt->execute();
    $unreadCount = $checkStmt->fetch()['count'];
    
    // 如果没有未读通知，直接返回
    if ($unreadCount === 0) {
        echo json_encode([
            'code' => 0,
            'message' => !empty($type) ? "没有未读的{$type}类型通知" : "没有未读通知",
            'data' => [
                'count' => 0
            ]
        ]);
        exit;
    }
    
    // 构建SQL语句
    if (!empty($type)) {
        $stmt = $db->prepare("UPDATE admin_system_notification SET status = 1 WHERE type = :type AND status = 0");
        $stmt->bindParam(':type', $type, PDO::PARAM_STR);
    } else {
        $stmt = $db->prepare("UPDATE admin_system_notification SET status = 1 WHERE status = 0");
    }

    $stmt->execute();
    $count = $stmt->rowCount();

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => !empty($type) ? "已批量标记{$count}条{$type}类型通知为已读" : "已批量标记{$count}条通知为已读",
        'data' => [
            'count' => $count
        ]
    ]);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '批量标记已读失败: ' . $e->getMessage()
    ]);
    exit;
}
?>
