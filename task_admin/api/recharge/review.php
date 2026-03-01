<?php
/**
 * 充值申请审核
 * POST /task_admin/api/recharge/review.php
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
    $stmt = $db->prepare("SELECT * FROM recharge_requests WHERE id = ? FOR UPDATE");
    $stmt->execute([$id]);
    $request = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$request) {
        $db->rollBack();
        echo json_encode(['code' => 1005, 'message' => '申请记录不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if ((int)$request['status'] !== 0) {
        $db->rollBack();
        echo json_encode(['code' => 1006, 'message' => '该申请已审核，不能重复操作', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $walletId = (int)$request['wallet_id'];
    $amount = (int)$request['amount'];
    $logId = (int)$request['log_id'];
    
    if ($action === 'approve') {
        // 审核通过
        
        // 1. 查询钱包余额
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ? FOR UPDATE");
        $stmt->execute([$walletId]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$wallet) {
            $db->rollBack();
            echo json_encode(['code' => 1007, 'message' => '钱包不存在', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $beforeBalance = (int)$wallet['balance'];
        $afterBalance = $beforeBalance + $amount;
        
        // 2. 更新钱包余额
        $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
        $stmt->execute([$afterBalance, $walletId]);
        
        // 3. 插入新的wallet_log记录（真实变动）
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, remark, created_at
            ) VALUES (?, ?, ?, ?, 1, ?, ?, ?, 'recharge', ?, ?, NOW())
        ");
        $stmt->execute([
            $walletId,
            (int)$request['user_id'],
            $request['username'],
            (int)$request['user_type'],
            $amount,
            $beforeBalance,
            $afterBalance,
            $id,
            "充值到账：¥" . number_format($amount / 100, 2)
        ]);
        
        // 4. 更新申请记录
        $stmt = $db->prepare("
            UPDATE recharge_requests 
            SET status = 1, reviewed_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$id]);
        
        // 5. 提交事务（先完成主业务）
        $db->commit();
        
        // 6. 发送通知给用户（事务外，避免嵌套事务）
        $notificationTitle = '充值审核通过';
        $notificationContent = "您的充值申请已审核通过，金额：¥" . number_format($amount / 100, 2) . " 已到账。感谢您的使用！";
        Notification::send(
            $db,
            $notificationTitle,
            $notificationContent,
            Notification::TARGET_USER,
            (int)$request['user_id'],
            (int)$request['user_type'],
            Notification::SENDER_SYSTEM
        );
        
        echo json_encode(['code' => 0, 'message' => '审核通过，已充值到账', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
        
    } else {
        // 审核拒绝
        
        // 1. 查询当前钱包余额（用于记录）
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$walletId]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
        $currentBalance = $wallet ? (int)$wallet['balance'] : 0;
        
        // 2. 更新申请记录
        $stmt = $db->prepare("
            UPDATE recharge_requests 
            SET status = 2, reject_reason = ?, reviewed_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$rejectReason, $id]);
        
        // 3. 插入新的wallet_log记录（拒绝记录，无金额变动）
        $stmt = $db->prepare("
            INSERT INTO wallets_log (
                wallet_id, user_id, username, user_type, type, 
                amount, before_balance, after_balance, 
                related_type, related_id, remark, created_at
            ) VALUES (?, ?, ?, ?, 1, 0, ?, ?, 'recharge', ?, ?, NOW())
        ");
        $stmt->execute([
            $walletId,
            (int)$request['user_id'],
            $request['username'],
            (int)$request['user_type'],
            $currentBalance,
            $currentBalance,
            $id,
            "充值申请被拒绝：¥" . number_format($amount / 100, 2)
        ]);
        
        // 4. 提交事务（先完成主业务）
        $db->commit();
        
        // 5. 发送通知给用户（事务外，避免嵌套事务）
        $notificationTitle = '充值审核未通过';
        $notificationContent = "很抱歉，您的充值申请未通过审核。\n\n拒绝原因：{$rejectReason}\n\n如有疑问，请联系客服。";
        Notification::send(
            $db,
            $notificationTitle,
            $notificationContent,
            Notification::TARGET_USER,
            (int)$request['user_id'],
            (int)$request['user_type'],
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
