<?php
/**
 * B端用户快捷派单配置更新接口
 * 
 * POST /api/c/v1/users/quick-task-config/update
 * 
 * 请求体：
 * {
 *   "config_info": {"key": "value"} // JSON格式的配置信息
 * }
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: X-Token, Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../../core/Database.php';
require_once __DIR__ . '/../../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../../config/error_codes.php';

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
    // 更新配置信息
    $input = json_decode(file_get_contents('php://input'), true);
    $configInfo = $input['config_info'] ?? [];
    
    if (!is_array($configInfo)) {
        Response::error('配置信息必须是JSON对象格式', $errorCodes['PARAMETER_ERROR']);
    }
    
    $configJson = json_encode($configInfo, JSON_UNESCAPED_UNICODE);
    
    // 检查是否存在配置
    $stmt = $db->prepare("SELECT id FROM quick_task_info_config WHERE b_user_id = ?");
    $stmt->execute([$currentUserId]);
    $exists = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($exists) {
        // 更新配置
        $updateStmt = $db->prepare("UPDATE quick_task_info_config SET config_info = ?, updated_at = NOW() WHERE b_user_id = ?");
        $updateStmt->execute([$configJson, $currentUserId]);
    } else {
        // 插入新配置
        $insertStmt = $db->prepare("INSERT INTO quick_task_info_config (b_user_id, username, config_info) VALUES (?, ?, ?)");
        $insertStmt->execute([$currentUserId, $currentUsername, $configJson]);
    }
    
    Response::success(['config_info' => $configInfo], '更新快捷派单配置成功');
} catch (PDOException $e) {
    Response::error('操作失败: ' . $e->getMessage(), $errorCodes['DATABASE_ERROR'], 500);
} catch (Exception $e) {
    Response::error('操作失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'], 500);
}
?>