<?php
// 通知配置更新API接口

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 引入必要的文件
require_once __DIR__ . '/../../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Database.php';

// 权限验证
AdminAuthMiddleware::authenticate();
$db = Database::connect();

// 获取请求数据
$input = json_decode(file_get_contents('php://input'), true);

// 验证必要参数
if (!isset($input['id']) || !isset($input['code']) || !isset($input['name']) || !isset($input['enabled']) || !isset($input['detection_interval']) || !isset($input['judgment_condition']) || !isset($input['priority']) || !isset($input['notification_template'])) {
    echo json_encode([
        'code' => 400,
        'message' => '缺少必要参数'
    ]);
    exit;
}

$id = intval($input['id']);
$code = $input['code'];
$name = $input['name'];
$description = isset($input['description']) ? $input['description'] : '';
$enabled = intval($input['enabled']);
$detection_interval = intval($input['detection_interval']);
$judgment_condition = $input['judgment_condition'];
$priority = intval($input['priority']);
$notification_template = json_encode($input['notification_template']);

try {
    // 检查配置是否存在
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM admin_system_notification_config WHERE id = :id");
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    if ($stmt->fetch()['count'] === 0) {
        echo json_encode([
            'code' => 404,
            'message' => '配置不存在'
        ]);
        exit;
    }

    // 检查编码是否已被其他配置使用
    $stmt = $db->prepare("SELECT COUNT(*) as count FROM admin_system_notification_config WHERE code = :code AND id != :id");
    $stmt->bindParam(':code', $code, PDO::PARAM_STR);
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    if ($stmt->fetch()['count'] > 0) {
        echo json_encode([
            'code' => 400,
            'message' => '编码已被使用'
        ]);
        exit;
    }

    // 更新配置
    $stmt = $db->prepare("UPDATE admin_system_notification_config SET code = :code, name = :name, description = :description, enabled = :enabled, detection_interval = :detection_interval, judgment_condition = :judgment_condition, priority = :priority, notification_template = :notification_template WHERE id = :id");
    $stmt->bindParam(':code', $code, PDO::PARAM_STR);
    $stmt->bindParam(':name', $name, PDO::PARAM_STR);
    $stmt->bindParam(':description', $description, PDO::PARAM_STR);
    $stmt->bindParam(':enabled', $enabled, PDO::PARAM_INT);
    $stmt->bindParam(':detection_interval', $detection_interval, PDO::PARAM_INT);
    $stmt->bindParam(':judgment_condition', $judgment_condition, PDO::PARAM_STR);
    $stmt->bindParam(':priority', $priority, PDO::PARAM_INT);
    $stmt->bindParam(':notification_template', $notification_template, PDO::PARAM_STR);
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success'
    ]);

} catch (Exception $e) {
    // 错误处理
    echo json_encode([
        'code' => 500,
        'message' => '更新通知配置失败: ' . $e->getMessage()
    ]);
    exit;
}
?>
