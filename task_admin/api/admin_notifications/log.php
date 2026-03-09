<?php
// 通知检测日志API接口

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

// 获取请求参数
$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 100)));
$has_new_notification = isset($_GET['has_new_notification']) ? (int)$_GET['has_new_notification'] : -1;

// 计算偏移量
$offset = ($page - 1) * $pageSize;

try {
    // 构建SQL语句
    $where = [];
    $params = [];

    if ($has_new_notification >= 0) {
        $where[] = "has_new_notification = :has_new_notification";
        $params[':has_new_notification'] = $has_new_notification;
    }

    $where_clause = !empty($where) ? "WHERE " . implode(" AND ", $where) : "";

    // 获取总记录数
    $count_sql = "SELECT COUNT(*) as total FROM admin_system_notification_log {$where_clause}";
    $stmt = $db->prepare($count_sql);
    $stmt->execute($params);
    $total = $stmt->fetch()['total'];

    // 获取日志列表
    $list_sql = "SELECT * FROM admin_system_notification_log {$where_clause} ORDER BY detection_time DESC LIMIT :offset, :pageSize";
    $stmt = $db->prepare($list_sql);

    // 绑定参数
    foreach ($params as $key => $value) {
        $stmt->bindParam($key, $value);
    }
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->bindParam(':pageSize', $pageSize, PDO::PARAM_INT);

    $stmt->execute();
    $list = $stmt->fetchAll();

    // 处理detection_result字段，确保完整记录各类型新增数量
    foreach ($list as &$item) {
        if (!empty($item['detection_result'])) {
            $item['detection_result'] = json_decode($item['detection_result'], true);
        }
        // 确保id字段为整数
        $item['id'] = (int)$item['id'];
        // 确保has_new_notification字段为整数
        $item['has_new_notification'] = (int)$item['has_new_notification'];
        // 确保notification_count字段为整数
        $item['notification_count'] = (int)$item['notification_count'];
    }

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'list' => $list,
            'page' => $page,
            'pageSize' => $pageSize,
            'total' => $total,
            'total_pages' => $total > 0 ? (int)ceil($total / $pageSize) : 0
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '获取通知检测日志失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>
