<?php
// 通知列表API接口

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

$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['pageSize'] ?? 20)));
$type = $_GET['type'] ?? null;
$status = isset($_GET['status']) ? (int)$_GET['status'] : null;
$offset = ($page - 1) * $pageSize;

try {
    // 构建SQL语句
    $where = [];
    $params = [];

    if (!empty($type)) {
        $where[] = "type = :type";
        $params[':type'] = $type;
    }

    if ($status !== null) {
        $where[] = "status = :status";
        $params[':status'] = $status;
    }

    $where_clause = !empty($where) ? "WHERE " . implode(" AND ", $where) : "";

    // 获取总记录数
    $count_sql = "SELECT COUNT(*) as total FROM admin_system_notification {$where_clause}";
    $stmt = $db->prepare($count_sql);
    $stmt->execute($params);
    $total = $stmt->fetch()['total'];

    // 获取通知列表
    $list_sql = "SELECT * FROM admin_system_notification {$where_clause} ORDER BY created_at DESC LIMIT :offset, :pageSize";
    $stmt = $db->prepare($list_sql);

    // 绑定参数
    foreach ($params as $key => $value) {
        $stmt->bindParam($key, $value);
    }
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    $stmt->bindParam(':pageSize', $pageSize, PDO::PARAM_INT);

    $stmt->execute();
    $list = $stmt->fetchAll();

    // 处理data字段，确保仅显示本次通知的新增任务数量
    foreach ($list as &$item) {
        if (!empty($item['data'])) {
            $item['data'] = json_decode($item['data'], true);
        }
        // 确保id字段为整数
        $item['id'] = (int)$item['id'];
        // 确保status字段为整数
        $item['status'] = (int)$item['status'];
        // 确保priority字段为整数
        $item['priority'] = (int)$item['priority'];
        
        // 处理content字段为{content}的情况
        if ($item['content'] === '{content}' && !empty($item['data']) && isset($item['data']['count'])) {
            $count = $item['data']['count'];
            switch ($item['type']) {
                case 'recharge':
                    $item['content'] = $count > 0 ? "有{$count}条充值申请待审核" : "没有新的充值申请待审核";
                    break;
                case 'withdraw':
                    $item['content'] = $count > 0 ? "有{$count}条提现申请待审核" : "没有新的提现申请待审核";
                    break;
                case 'agent':
                    $item['content'] = $count > 0 ? "有{$count}条团长申请待审核" : "没有新的团长申请待审核";
                    break;
                case 'magnifier':
                    $item['content'] = $count > 0 ? "有{$count}个放大镜任务待处理" : "没有新的放大镜任务待处理";
                    break;
                case 'rental':
                    $item['content'] = $count > 0 ? "有{$count}个租赁订单待处理" : "没有新的租赁订单待处理";
                    break;
                case 'ticket':
                    $item['content'] = $count > 0 ? "有{$count}个工单待处理" : "没有新的工单待处理";
                    break;
                case 'system':
                    $item['content'] = $count > 0 ? "系统通知" : "没有新的系统通知";
                    break;
                default:
                    $item['content'] = $count > 0 ? "有{$count}个任务待处理" : "没有新的待处理任务";
                    break;
            }
        }
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
        'message' => '获取通知列表失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>
