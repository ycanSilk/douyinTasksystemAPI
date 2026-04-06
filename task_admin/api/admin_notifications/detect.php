<?php
/**
 * 通知检测API接口
 * GET /task_admin/api/admin_notifications/detect.php
 * 
 * 功能：检测各种通知类型的待处理数量
 */

// 确保输出缓冲开启
ob_start();

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    ob_end_clean();
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';

// 记录查询日志
function logQuery($message) {
    $logFile = __DIR__ . '/../../../logs/detect_query.log';
    $logMessage = date('Y-m-d H:i:s') . ' ' . $message . '\n';
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}

// 记录WebSocket服务器调用
if (isset($_GET['ws_server']) && $_GET['ws_server'] === 'true') {
    logQuery('WebSocket服务器调用detect.php');
}

// 初始化数据库连接
try {
    $db = Database::connect();
    logQuery('数据库连接成功');
} catch (Exception $e) {
    // 清除之前的输出缓冲
    ob_clean();
    
    // 错误处理
    logQuery('数据库连接失败: ' . $e->getMessage());
    echo json_encode([
        'code' => 1002,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 初始化检测结果
    $detection_result = [];
    
    // 1. 查询 withdraw_requests 表 status=0 的记录数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM withdraw_requests WHERE status = ?");
    $stmt->execute([0]);
    $withdraw_count = (int)$stmt->fetchColumn();
    $detection_result['withdraw'] = $withdraw_count;
    logQuery('查询 withdraw_requests 表，status=0，数量: ' . $withdraw_count);
    
    // 2. 查询 recharge_requests 表 status=0 的记录数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM recharge_requests WHERE status = ?");
    $stmt->execute([0]);
    $recharge_count = (int)$stmt->fetchColumn();
    $detection_result['recharge'] = $recharge_count;
    logQuery('查询 recharge_requests 表，status=0，数量: ' . $recharge_count);
    
    // 3. 查询 magnifying_glass_tasks 表 view_status=0 的记录数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM magnifying_glass_tasks WHERE view_status = ?");
    $stmt->execute([0]);
    $magnifier_count = (int)$stmt->fetchColumn();
    $detection_result['magnifier'] = $magnifier_count;
    logQuery('查询 magnifying_glass_tasks 表，view_status=0，数量: ' . $magnifier_count);
    
    // 4. 查询 rental_orders 表 status=1 的记录数量
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM rental_orders WHERE status = ?");
    $stmt->execute([1]);
    $rental_count = (int)$stmt->fetchColumn();
    $detection_result['rental'] = $rental_count;
    logQuery('查询 rental_orders 表，status=1，数量: ' . $rental_count);
    
    // 清除之前的输出缓冲
    ob_clean();

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'detection_result' => $detection_result
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // 清除之前的输出缓冲
    ob_clean();
    
    // 错误处理
    logQuery('检测通知失败: ' . $e->getMessage());
    echo json_encode([
        'code' => 500,
        'message' => '检测通知失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 刷新输出缓冲
ob_end_flush();
?>
