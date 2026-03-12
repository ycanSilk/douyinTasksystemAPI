<?php
/**
 * 通知检测API接口
 * GET /task_admin/api/admin_notifications/detect.php
 * 
 * 功能：检测各种通知类型的待处理数量，生成新通知并记录检测日志
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

// 直接跳过认证，因为这是后端内部调用的接口

// 初始化数据库连接
$db = Database::connect();

try {

    // 获取通知配置
    $stmt = $db->query("SELECT * FROM admin_system_notification_config WHERE enabled = 1");
    $configs = $stmt->fetchAll();

    $notifications = [];
    $detection_result = [];
    $has_new_notification = 0;
    $notification_count = 0;

    // 需要检测的项目类型配置
    // 只保留：团长审核、充值提醒、提现提醒、放大镜任务
    $auditTypes = [
        'recharge' => [
            'name' => '充值审核',
            'path' => __DIR__ . '/../recharge/list.php',
            'status' => 0,
            'message' => '新增了N条充值审核任务待处理'
        ],
        'withdraw' => [
            'name' => '提现审核',
            'path' => __DIR__ . '/../withdraw/list.php',
            'status' => 0,
            'message' => '新增了N条提现审核任务待处理'
        ],
        'agent' => [
            'name' => '团长审核',
            'path' => __DIR__ . '/../agent/list.php',
            'status' => 0,
            'message' => '新增了N条团长审核任务待处理'
        ]
    ];

    // 定义需要排除的检测类型
    $excludedCodes = ['ticket', 'rental', 'notification_list', 'system_message'];

    // 遍历配置，执行检测
    foreach ($configs as $config) {
        $code = $config['code'];
        
        // 跳过需要排除的检测类型
        if (in_array($code, $excludedCodes)) {
            continue;
        }
        
        $judgment_condition = $config['judgment_condition'];
        $template = json_decode($config['notification_template'], true);
        $priority = $config['priority'];

        // 检测逻辑
        $count = 0;
        
        // 放大镜任务特殊处理
        if ($code == 'magnifier') {
            // 直接执行数据库查询获取待处理数量（只统计未查看的任务）
            // 注意：放大镜任务的status=2表示待处理，0表示已完成
            $stmt = $db->prepare("SELECT COUNT(*) as count FROM magnifying_glass_tasks WHERE status = ? AND view_status = ?");
            $stmt->execute([2, 0]);
            $currentCount = (int)$stmt->fetchColumn();
            
            // 从数据库获取上次数量
            $stmt = $db->query("SELECT current_count, previous_count, last_viewed_count FROM admin_system_notification_magnifier_count ORDER BY id DESC LIMIT 1");
            $countData = $stmt->fetch(PDO::FETCH_ASSOC);
            $previousCount = $countData['current_count'] ?? 0;
            $lastViewedCount = $countData['last_viewed_count'] ?? 0;
            
            // 计算新增数量
            $count = $currentCount - $previousCount;
            
            // 如果是第一次检测，或者有新增任务，都应该生成通知
            if ($countData === false || $currentCount > 0) {
                $count = $currentCount;
            }
            
            // 更新数据库
            $stmt = $db->prepare("INSERT INTO admin_system_notification_magnifier_count (current_count, previous_count, last_viewed_count) VALUES (?, ?, ?)");
            $stmt->execute([$currentCount, $previousCount, $currentCount]);
        } 
        // 审核通知处理
        elseif (isset($auditTypes[$code])) {
            $config = $auditTypes[$code];
            
            // 直接执行数据库查询获取待处理数量
            switch ($code) {
                case 'recharge':
                    $stmt = $db->prepare("SELECT COUNT(*) as count FROM recharge_requests WHERE status = ?");
                    $stmt->execute([$config['status']]);
                    $count = (int)$stmt->fetchColumn();
                    break;
                case 'withdraw':
                    $stmt = $db->prepare("SELECT COUNT(*) as count FROM withdraw_requests WHERE status = ?");
                    $stmt->execute([$config['status']]);
                    $count = (int)$stmt->fetchColumn();
                    break;
                case 'agent':
                    $stmt = $db->prepare("SELECT COUNT(*) as count FROM agent_applications WHERE status = ?");
                    $stmt->execute([$config['status']]);
                    $count = (int)$stmt->fetchColumn();
                    break;
                default:
                    $count = 0;
            }
        }

        $detection_result[$code] = $count;

        // 判断是否需要生成通知
        // 安全处理判断条件，使用变量替换
        $safe_condition = str_replace('count', '$count', $judgment_condition);
        if (eval("return {$safe_condition};")) {
            // 检查是否已经存在未读通知
            $stmt = $db->prepare("SELECT COUNT(*) as count FROM admin_system_notification WHERE type = :type AND status = 0");
            $stmt->bindParam(':type', $code, PDO::PARAM_STR);
            $stmt->execute();
            $existing_count = $stmt->fetch()['count'];

            if ($existing_count == 0) {
                // 生成通知内容
                $title = str_replace('{count}', $count, $template['title']);
                $content = str_replace('{count}', $count, $template['content']);

                // 存储通知
                $dataJson = json_encode(['count' => $count]);
                $stmt = $db->prepare("INSERT INTO admin_system_notification (type, title, content, priority, data) VALUES (:type, :title, :content, :priority, :data)");
                $stmt->bindParam(':type', $code, PDO::PARAM_STR);
                $stmt->bindParam(':title', $title, PDO::PARAM_STR);
                $stmt->bindParam(':content', $content, PDO::PARAM_STR);
                $stmt->bindParam(':priority', $priority, PDO::PARAM_INT);
                $stmt->bindParam(':data', $dataJson, PDO::PARAM_STR);
                $stmt->execute();

                $notification_id = $db->lastInsertId();

                // 添加到通知列表
                $notifications[] = [
                    'id' => $notification_id,
                    'type' => $code,
                    'title' => $title,
                    'content' => $content,
                    'status' => 0,
                    'priority' => $priority,
                    'data' => ['count' => $count],
                    'created_at' => date('Y-m-d H:i:s')
                ];

                $has_new_notification = 1;
                $notification_count++;
            }
        }
    }

    // 记录检测日志
    if ($has_new_notification) {
        $stmt = $db->prepare("INSERT INTO admin_system_notification_log (has_new_notification, notification_count, detection_result) VALUES (:has_new_notification, :notification_count, :detection_result)");
        $stmt->bindParam(':has_new_notification', $has_new_notification, PDO::PARAM_INT);
        $stmt->bindParam(':notification_count', $notification_count, PDO::PARAM_INT);
        $stmt->bindParam(':detection_result', json_encode($detection_result), PDO::PARAM_STR);
        $stmt->execute();
    }

    // 获取未读通知数量（排除系统通知 type=system）
    $stmt = $db->query("SELECT COUNT(*) as count FROM admin_system_notification WHERE status = 0 AND type != 'system'");
    $unread_count = $stmt->fetch()['count'];

    // 清除之前的输出缓冲
    ob_clean();

    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => 'success',
        'data' => [
            'notifications' => $notifications,
            'unread_count' => $unread_count,
            'detection_result' => $detection_result
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    // 清除之前的输出缓冲
    ob_clean();
    
    // 错误处理
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
