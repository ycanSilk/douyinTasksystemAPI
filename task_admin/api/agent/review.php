<?php
/**
 * 团长申请审核
 * POST /task_admin/api/agent/review.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Notification.php';

$admin = AdminAuthMiddleware::authenticate();
$db = Database::connect();

$input = json_decode(file_get_contents('php://input'), true);
$id = (int)($input['id'] ?? 0);
$action = trim($input['action'] ?? ''); // approve / reject
$rejectReason = trim($input['reject_reason'] ?? '');

if (!$id) {
    echo json_encode(['code' => 1002, 'message' => '申请ID不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!in_array($action, ['approve', 'reject'])) {
    echo json_encode(['code' => 1003, 'message' => '审核操作无效', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'reject' && empty($rejectReason)) {
    echo json_encode(['code' => 1004, 'message' => '拒绝时必须填写原因', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $db->beginTransaction();
    
    // 查询申请记录
    $stmt = $db->prepare("SELECT * FROM agent_applications WHERE id = ? FOR UPDATE");
    $stmt->execute([$id]);
    $application = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$application) {
        $db->rollBack();
        echo json_encode(['code' => 1005, 'message' => '申请记录不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if ((int)$application['status'] !== 0) {
        $db->rollBack();
        echo json_encode(['code' => 1006, 'message' => '该申请已审核，不能重复操作', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $cUserId = (int)$application['c_user_id'];
    $applyType = (int)($application['apply_type'] ?? 1);

    if ($action === 'approve') {
        // 审核通过

        // 1. 更新申请记录为通过
        $stmt = $db->prepare("
            UPDATE agent_applications
            SET status = 1, reviewed_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$id]);

        // 2. 更新C端用户表，根据申请类型设置is_agent
        $newAgentLevel = ($applyType === 2) ? 2 : 1;
        $stmt = $db->prepare("UPDATE c_users SET is_agent = ? WHERE id = ?");
        $stmt->execute([$newAgentLevel, $cUserId]);
        
        // 3. 提交事务（先完成主业务）
        $db->commit();
        
        // 4. 发送通知给用户（事务外，避免嵌套事务）
        if ($applyType === 2) {
            $notificationTitle = '恭喜！高级团长申请已通过';
            $notificationContent = "恭喜您！您的高级团长申请已审核通过。\n\n高级团长权益已生效，佣金将按高级团长标准结算。\n\n邀请码：{$application['invite_code']}";
        } else {
            $notificationTitle = '恭喜！团长申请已通过';
            $notificationContent = "恭喜您！您的团长申请已审核通过。\n\n现在您可以享受以下权益：\n• 推广邀请码，获得下线用户\n• 下线完成任务时，您可获得佣金分成\n\n邀请码：{$application['invite_code']}";
        }
        Notification::send(
            $db,
            $notificationTitle,
            $notificationContent,
            Notification::TARGET_USER,
            $cUserId,
            Notification::USER_TYPE_C,
            Notification::SENDER_SYSTEM
        );
        
        $agentText = ($applyType === 2) ? '高级团长' : '团长';
        echo json_encode(['code' => 0, 'message' => "审核通过，用户已成为{$agentText}", 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        
    } else {
        // 审核拒绝
        
        // 1. 更新申请记录为拒绝
        $stmt = $db->prepare("
            UPDATE agent_applications 
            SET status = 2, reject_reason = ?, reviewed_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$rejectReason, $id]);
        
        // 2. 提交事务（先完成主业务）
        $db->commit();
        
        // 3. 发送通知给用户（事务外，避免嵌套事务）
        $agentText = ($applyType === 2) ? '高级团长' : '团长';
        $notificationTitle = "{$agentText}申请未通过";
        $notificationContent = "很抱歉，您的{$agentText}申请未通过审核。\n\n拒绝原因：{$rejectReason}\n\n如有疑问，请联系客服。";
        Notification::send(
            $db,
            $notificationTitle,
            $notificationContent,
            Notification::TARGET_USER,
            $cUserId,
            Notification::USER_TYPE_C,
            Notification::SENDER_SYSTEM
        );
        
        echo json_encode(['code' => 0, 'message' => '已拒绝申请', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    }
    
} catch (PDOException $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '审核失败：' . $e->getMessage(), 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
