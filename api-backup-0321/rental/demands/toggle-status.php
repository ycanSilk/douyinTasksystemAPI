<?php
/**
 * 上架/下架求租信息接口
 * 
 * POST /api/rental/demands/toggle-status
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体：
 * {
 *   "demand_id": 1,
 *   "status": 0
 * }
 * 
 * status 说明：
 * 0 = 已下架
 * 1 = 发布中（上架）
 * 
 * 规则：
 * - 上架时（1->0）：检测 deadline 是否大于当前时间至少24小时
 * - 下架时（0->1）：退回冻结预算到钱包
 * - 已成交（status=2）或已过期（status=3）的求租不能修改状态
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 认证（B/C端共用）
$auth = new AuthMiddleware($db);
$user = $auth->authenticateAny();
$userId = $user['user_id'];
$userType = $user['type']; // 1=C端 2=B端

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$demandId = intval($input['demand_id'] ?? 0);
$targetStatus = intval($input['status'] ?? -1);

// 参数校验
if ($demandId <= 0) {
    Response::error('求租信息ID无效', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
}

    // 用户只能设置 0（下架）或 1（上架）
    if (!in_array($targetStatus, [0, 1])) {
        Response::error('状态参数无效', $errorCodes['RENTAL_DEMAND_STATUS_INVALID']);
    }

try {
    // 检查求租信息是否存在，并校验权限
    $stmt = $db->prepare("
        SELECT 
            rd.id,
            rd.user_id,
            rd.user_type,
            rd.wallet_id,
            rd.title,
            rd.budget_amount,
            rd.days_needed,
            rd.deadline,
            rd.status,
            CASE 
                WHEN rd.user_type = 1 THEN cu.username
                WHEN rd.user_type = 2 THEN bu.username
            END as username
        FROM rental_demands rd
        LEFT JOIN c_users cu ON rd.user_type = 1 AND rd.user_id = cu.id
        LEFT JOIN b_users bu ON rd.user_type = 2 AND rd.user_id = bu.id
        WHERE rd.id = ?
    ");
    $stmt->execute([$demandId]);
    $demand = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$demand) {
        Response::error('求租信息不存在', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
    }

    // 权限检查：只有发布者本人可以修改
    if ($demand['user_id'] != $userId || $demand['user_type'] != $userType) {
        Response::error('无权修改此求租信息', $errorCodes['RENTAL_DEMAND_NO_PERMISSION']);
    }

    $currentStatus = $demand['status'];
    $walletId = $demand['wallet_id'];
    $budgetAmount = $demand['budget_amount']; // 日预算
    $daysNeeded = $demand['days_needed']; // 租期天数
    $totalAmount = $budgetAmount * $daysNeeded; // 总冻结金额
    $username = $demand['username'];
    $title = $demand['title'];
    $deadline = strtotime($demand['deadline']);

    // 已成交或已过期的求租不能修改状态
    if ($currentStatus == 2) {
        Response::error('该求租信息已成交，无法修改状态', $errorCodes['RENTAL_DEMAND_ALREADY_TRADED']);
    }

    if ($currentStatus == 3) {
        Response::error('该求租信息已过期，无法修改状态', $errorCodes['RENTAL_DEMAND_ALREADY_EXPIRED']);
    }

    // 如果当前状态和目标状态相同，直接返回成功
    if ($currentStatus == $targetStatus) {
        $statusText = $targetStatus == 1 ? '发布中' : '已下架';
        Response::success([
            'demand_id' => $demandId,
            'status' => $targetStatus,
            'status_text' => $statusText
        ], '状态未变更');
    }

    $db->beginTransaction();

    // 上架操作（0 -> 1）
    if ($targetStatus == 1 && $currentStatus == 0) {
        // 检测 deadline 是否至少大于当前时间24小时
        $minDeadline = time() + (24 * 3600);
        if ($deadline < $minDeadline) {
            $db->rollBack();
            Response::error('上架失败：截止时间必须至少大于当前时间24小时', $errorCodes['RENTAL_DEMAND_DEADLINE_TOO_SOON']);
        }

        // 检查钱包余额是否足够（重新冻结）
        $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $walletStmt->execute([$walletId]);
        $currentBalance = $walletStmt->fetchColumn();

        if ($currentBalance < $totalAmount) {
            $db->rollBack();
            Response::error('钱包余额不足，无法重新上架', $errorCodes['RENTAL_DEMAND_INSUFFICIENT_BALANCE']);
        }

        // 扣减钱包余额（重新冻结总金额 = 日预算×天数）
        $newBalance = $currentBalance - $totalAmount;
        $updateWalletStmt = $db->prepare("
            UPDATE wallets 
            SET balance = ? 
            WHERE id = ?
        ");
        $updateWalletStmt->execute([$newBalance, $walletId]);

        // 插入钱包流水记录（冻结）
        $insertLogStmt = $db->prepare("
            INSERT INTO wallets_log 
            (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
            VALUES 
            (?, ?, ?, ?, 2, ?, ?, ?, 'rental_freeze', ?, ?, NOW())
        ");
        $insertLogStmt->execute([
            $walletId,
            $userId,
            $username,
            $userType,
            $totalAmount,
            $currentBalance,
            $newBalance,
            $demandId,
            "求租信息重新上架冻结预算（{$budgetAmount}分/天×{$daysNeeded}天）：{$title}"
        ]);
    }

    // 下架操作（1 -> 0）
    if ($targetStatus == 0 && $currentStatus == 1) {
        // 获取当前钱包余额
        $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $walletStmt->execute([$walletId]);
        $currentBalance = $walletStmt->fetchColumn();

        // 退回冻结金额到钱包（总金额 = 日预算×天数）
        $newBalance = $currentBalance + $totalAmount;
        $updateWalletStmt = $db->prepare("
            UPDATE wallets 
            SET balance = ? 
            WHERE id = ?
        ");
        $updateWalletStmt->execute([$newBalance, $walletId]);

        // 插入钱包流水记录（解冻）
        $insertLogStmt = $db->prepare("
            INSERT INTO wallets_log 
            (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
            VALUES 
            (?, ?, ?, ?, 1, ?, ?, ?, 'rental_unfreeze', ?, ?, NOW())
        ");
        $insertLogStmt->execute([
            $walletId,
            $userId,
            $username,
            $userType,
            $totalAmount,
            $currentBalance,
            $newBalance,
            $demandId,
            "求租信息手动下架退回预算（{$budgetAmount}分/天×{$daysNeeded}天）：{$title}"
        ]);
    }

    // 更新求租信息状态
    $updateDemandStmt = $db->prepare("
        UPDATE rental_demands 
        SET status = ?, updated_at = NOW()
        WHERE id = ?
    ");
    $updateDemandStmt->execute([$targetStatus, $demandId]);

    $db->commit();

    $statusText = $targetStatus == 1 ? '发布中' : '已下架';

    Response::success([
        'demand_id' => $demandId,
        'status' => $targetStatus,
        'status_text' => $statusText,
        'budget_amount' => $budgetAmount,
        'days_needed' => $daysNeeded,
        'total_amount' => $totalAmount,
        'budget_frozen' => $targetStatus == 1 ? $totalAmount : 0,
        'budget_returned' => $targetStatus == 0 ? $totalAmount : 0
    ], '状态修改成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log('Rental demand toggle status failed: ' . $e->getMessage());
    Response::error('状态修改失败，请稍后重试', $errorCodes['RENTAL_DEMAND_CREATE_FAILED']);
}
