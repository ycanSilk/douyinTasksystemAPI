<?php
/**
 * 系统权限模板列表接口
 * GET /task_admin/api/system_permission_template/list.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// Token 认证
AdminAuthMiddleware::authenticate();

// 数据库连接
$db = Database::connect();

// 检查是否需要获取所有模板（包括禁用的）
$all = isset($_GET['all']) && $_GET['all'] == 1;

try {
    // 构建查询语句
    if ($all) {
        // 获取所有模板
        $stmt = $db->query("SELECT * FROM system_permission_template ORDER BY sort_order ASC, id ASC");
    } else {
        // 只获取启用的模板
        $stmt = $db->query("SELECT * FROM system_permission_template WHERE status = 1 ORDER BY sort_order ASC, id ASC");
    }
    
    $templates = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 转换时间格式
    foreach ($templates as &$template) {
        $template['created_at'] = date('Y-m-d H:i:s', strtotime($template['created_at']));
        $template['updated_at'] = date('Y-m-d H:i:s', strtotime($template['updated_at']));
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => $templates,
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库查询失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
