<?php
// 通知详情API接口

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

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $notification_id = $data['notification_id'] ?? null;
    
    if (!$notification_id) {
        echo json_encode([
            'code' => 400,
            'message' => '缺少通知ID参数',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 获取通知详情
    $stmt = $db->prepare("SELECT * FROM admin_system_notification WHERE id = ?");
    $stmt->execute([$notification_id]);
    $notification = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$notification) {
        echo json_encode([
            'code' => 404,
            'message' => '通知不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 处理data字段
    if (!empty($notification['data'])) {
        $notification['data'] = json_decode($notification['data'], true);
    }
    
    // 确保字段类型正确
    $notification['id'] = (int)$notification['id'];
    $notification['status'] = (int)$notification['status'];
    $notification['priority'] = (int)$notification['priority'];
    
    // 处理content字段为{content}的情况
    if ($notification['content'] === '{content}' && !empty($notification['data']) && isset($notification['data']['count'])) {
        $count = $notification['data']['count'];
        switch ($notification['type']) {
            case 'recharge':
                $notification['content'] = $count > 0 ? "有{$count}条充值申请待审核" : "没有新的充值申请待审核";
                break;
            case 'withdraw':
                $notification['content'] = $count > 0 ? "有{$count}条提现申请待审核" : "没有新的提现申请待审核";
                break;
            case 'agent':
                $notification['content'] = $count > 0 ? "有{$count}条团长申请待审核" : "没有新的团长申请待审核";
                break;
            case 'magnifier':
                $notification['content'] = $count > 0 ? "有{$count}个放大镜任务待处理" : "没有新的放大镜任务待处理";
                break;
            case 'rental':
                $notification['content'] = $count > 0 ? "有{$count}个租赁订单待处理" : "没有新的租赁订单待处理";
                break;
            case 'ticket':
                $notification['content'] = $count > 0 ? "有{$count}个工单待处理" : "没有新的工单待处理";
                break;
            case 'system':
                $notification['content'] = $count > 0 ? "系统通知" : "没有新的系统通知";
                break;
            default:
                $notification['content'] = $count > 0 ? "有{$count}个任务待处理" : "没有新的待处理任务";
                break;
        }
    }
    
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => $notification,
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    echo json_encode([
        'code' => 500,
        'message' => '获取通知详情失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}
?>