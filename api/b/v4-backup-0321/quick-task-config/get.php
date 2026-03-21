<?php
/**
 * B端用户快捷派单配置获取接口
 * 
 * GET /api/c/v1/users/quick-task-config/get
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: X-Token, Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();
$currentUserId = $currentUser['user_id'] ?? $currentUser['id'] ?? 0;
$currentUsername = $currentUser['username'] ?? '';

// 如果username为空，从数据库查询
if (empty($currentUsername)) {
    $stmt = $db->prepare("SELECT username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUserId]);
    $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($userInfo) {
        $currentUsername = $userInfo['username'];
    }
}

try {
    // 获取配置信息
    $stmt = $db->prepare("SELECT id, b_user_id, username, config_info, created_at, updated_at FROM quick_task_info_config WHERE b_user_id = ?");
    $stmt->execute([$currentUserId]);
    $config = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($config) {
        $config['config_info'] = json_decode($config['config_info'], true);
    } else {
        $config = [];
    }
    
    Response::success($config, '获取快捷派单配置成功');
} catch (PDOException $e) {
    Response::error('操作失败: ' . $e->getMessage(), $errorCodes['DATABASE_ERROR'], 500);
} catch (Exception $e) {
    Response::error('操作失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'], 500);
}
?>