<?php
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
require_once __DIR__ . '/../../../core/Response.php';

// 初始化数据库连接
$pdo = Database::connect();

// 认证中间件
AdminAuthMiddleware::authenticate();

// 处理POST请求
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // 获取请求数据
        $data = json_decode(file_get_contents('php://input'), true);
        
        // 验证必填字段
        if (!isset($data['title']) || empty($data['title'])) {
            Response::error('标题不能为空');
        }
        
        if (!isset($data['content']) || empty($data['content'])) {
            Response::error('内容不能为空');
        }
        
        if (!isset($data['target_type'])) {
            Response::error('目标类型不能为空');
        }
        
        // 验证目标类型
        $targetType = intval($data['target_type']);
        if (!in_array($targetType, [0, 1, 2, 3])) {
            Response::error('无效的目标类型');
        }
        
        // 验证指定用户的情况
        if ($targetType === 3) {
            if (!isset($data['target_user_id']) || empty($data['target_user_id'])) {
                Response::error('指定用户时必须提供用户ID');
            }
            
            if (!isset($data['target_user_type']) || empty($data['target_user_type'])) {
                Response::error('指定用户时必须提供用户类型');
            }
            
            $targetUserType = intval($data['target_user_type']);
            if (!in_array($targetUserType, [1, 2])) {
                Response::error('无效的用户类型');
            }
        }
        
        // 准备数据
        $title = $data['title'];
        $content = $data['content'];
        $targetUserId = isset($data['target_user_id']) ? intval($data['target_user_id']) : null;
        $targetUserType = isset($data['target_user_type']) ? intval($data['target_user_type']) : null;
        $senderType = 3; // Admin发送
        $senderId = null; // 预留字段
        
        // 插入通知
        $sql = "INSERT INTO notifications (title, content, target_type, target_user_id, target_user_type, sender_type, sender_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$title, $content, $targetType, $targetUserId, $targetUserType, $senderType, $senderId]);
        
        $notificationId = $pdo->lastInsertId();
        
        // 返回成功
        Response::success([
            'notification_id' => $notificationId,
            'title' => $title,
            'content' => $content,
            'target_type' => $targetType
        ]);
        
    } catch (Exception $e) {
        Response::error('发送通知失败: ' . $e->getMessage());
    }
} else {
    Response::error('无效的请求方法');
}
?>