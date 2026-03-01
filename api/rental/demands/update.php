<?php
/**
 * 修改求租信息接口
 * 
 * POST /api/rental/demands/update
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体（除 demand_id 外，其他字段都是可选的）：
 * {
 *   "demand_id": 1,                         // 必填
 *   "title": "求租抖音高等级账号（已修改）",  // 可选
 *   "budget_amount": 180000,                 // 可选
 *   "days_needed": 10,                       // 可选
 *   "deadline": 1737388799,                  // 可选
 *   "requirements_json": {                   // 可选
 *     "account_requirements": "粉丝15万+，权重高",
 *     "login_requirements": "扫码登录"
 *   }
 * }
 * 
 * 规则：
 * - 只能修改本人发布的求租信息
 * - 不能修改已成交（status=2）或已过期（status=3）的求租信息
 * - 未传的字段保持原值不变
 * - 如果传了 deadline，必须至少大于当前时间24小时
 * - 如果是发布中（status=1）且传了 budget_amount 导致金额变化：
 *   - 增加预算：从钱包扣除差额
 *   - 减少预算：退回差额到钱包
 * - 如果是已下架（status=0）：修改 budget_amount 不影响钱包
 * - 如果未传 budget_amount：不处理钱包操作
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

// 获取请求参数（兼容 JSON 和 form-data 两种提交方式）
$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    $input = $_POST;
}
$demandId = intval($input['demand_id'] ?? 0);

// 参数校验：demand_id 必填
if ($demandId <= 0) {
    Response::error('求租信息ID无效', $errorCodes['RENTAL_DEMAND_NOT_FOUND']);
}

// 其他参数都是可选的
$hasTitle = isset($input['title']);
$hasBudgetAmount = isset($input['budget_amount']);
$hasDaysNeeded = isset($input['days_needed']);
$hasDeadline = isset($input['deadline']);
$hasRequirementsJson = isset($input['requirements_json']);

// 如果传了参数，进行校验
if ($hasTitle) {
    $title = trim($input['title']);
    if (empty($title)) {
        Response::error('标题不能为空', $errorCodes['RENTAL_DEMAND_TITLE_EMPTY']);
    }
}

if ($hasBudgetAmount) {
    $budgetAmount = intval($input['budget_amount']);
    if ($budgetAmount <= 0) {
        Response::error('预算金额必须大于0', $errorCodes['RENTAL_DEMAND_BUDGET_INVALID']);
    }
}

if ($hasDaysNeeded) {
    $daysNeeded = intval($input['days_needed']);
    if ($daysNeeded < 1 || $daysNeeded > 365) {
        Response::error('租赁天数必须在1-365天之间', $errorCodes['RENTAL_DEMAND_DAYS_INVALID']);
    }
}

if ($hasDeadline) {
    $deadline = intval($input['deadline']);
    
    if ($deadline <= 0) {
        Response::error('截止时间不能为空', $errorCodes['RENTAL_DEMAND_DEADLINE_INVALID']);
    }
    
    // 截止时间必须至少大于当前时间24小时
    $minDeadline = time() + (24 * 3600);
    if ($deadline < $minDeadline) {
        Response::error('截止时间必须至少大于当前时间24小时', $errorCodes['RENTAL_DEMAND_DEADLINE_TOO_SOON']);
    }
    
    // 截止时间最多30天
    $maxDeadline = time() + (30 * 24 * 3600);
    if ($deadline > $maxDeadline) {
        Response::error('截止时间不能超过30天', $errorCodes['RENTAL_DEMAND_DEADLINE_INVALID']);
    }
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
            rd.requirements_json,
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
    $username = $demand['username'];

    // 已成交或已过期的求租不能修改
    if ($currentStatus == 2) {
        Response::error('该求租信息已成交，无法修改', $errorCodes['RENTAL_DEMAND_ALREADY_TRADED']);
    }

    if ($currentStatus == 3) {
        Response::error('该求租信息已过期，无法修改', $errorCodes['RENTAL_DEMAND_ALREADY_EXPIRED']);
    }

    // 使用新值或保留旧值
    $newTitle = $hasTitle ? $title : $demand['title'];
    $newBudgetAmount = $hasBudgetAmount ? $budgetAmount : $demand['budget_amount'];
    $newDaysNeeded = $hasDaysNeeded ? $daysNeeded : $demand['days_needed'];
    $newDeadline = $hasDeadline ? $deadline : strtotime($demand['deadline']);
    $newRequirementsJson = $hasRequirementsJson ? json_encode($input['requirements_json'], JSON_UNESCAPED_UNICODE) : $demand['requirements_json'];

    $db->beginTransaction();

    // 处理总金额变更（日预算×天数，仅当状态为发布中时）
    $oldTotalAmount = $demand['budget_amount'] * $demand['days_needed'];
    $newTotalAmount = $newBudgetAmount * $newDaysNeeded;
    $totalAmountDiff = $newTotalAmount - $oldTotalAmount;
    
    if ($currentStatus == 1 && $totalAmountDiff != 0) {
        // 获取当前钱包余额
        $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $walletStmt->execute([$walletId]);
        $currentBalance = $walletStmt->fetchColumn();

        if ($totalAmountDiff > 0) {
            // 总金额增加：需要从钱包扣除差额
            if ($currentBalance < $totalAmountDiff) {
                $db->rollBack();
                Response::error('钱包余额不足，无法增加预算', $errorCodes['RENTAL_DEMAND_INSUFFICIENT_BALANCE']);
            }

            $newBalance = $currentBalance - $totalAmountDiff;
            $updateWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
            $updateWalletStmt->execute([$newBalance, $walletId]);

            // 插入钱包流水记录（增加冻结）
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
                $totalAmountDiff,
                $currentBalance,
                $newBalance,
                $demandId,
                "求租信息修改增加预算（{$newBudgetAmount}分/天×{$newDaysNeeded}天）：{$newTitle}（+{$totalAmountDiff}）"
            ]);

        } else {
            // 总金额减少：退回差额到钱包
            $refundAmount = abs($totalAmountDiff);
            $newBalance = $currentBalance + $refundAmount;
            $updateWalletStmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
            $updateWalletStmt->execute([$newBalance, $walletId]);

            // 插入钱包流水记录（减少冻结）
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
                $refundAmount,
                $currentBalance,
                $newBalance,
                $demandId,
                "求租信息修改减少预算（{$newBudgetAmount}分/天×{$newDaysNeeded}天）：{$newTitle}（-{$refundAmount}）"
            ]);
        }
    }

    // 更新求租信息
    $updateDemandStmt = $db->prepare("
        UPDATE rental_demands 
        SET 
            title = ?,
            budget_amount = ?,
            days_needed = ?,
            deadline = ?,
            requirements_json = ?,
            updated_at = NOW()
        WHERE id = ?
    ");
    
    $updateDemandStmt->execute([
        $newTitle,
        $newBudgetAmount,
        $newDaysNeeded,
        date('Y-m-d H:i:s', $newDeadline),
        $newRequirementsJson,
        $demandId
    ]);

    $db->commit();

    Response::success([
        'demand_id' => $demandId,
        'title' => $newTitle,
        'budget_amount' => $newBudgetAmount,
        'budget_amount_yuan' => number_format($newBudgetAmount / 100, 2),
        'days_needed' => $newDaysNeeded,
        'deadline' => $newDeadline,
        'deadline_datetime' => date('Y-m-d H:i:s', $newDeadline),
        'status' => $currentStatus,
        'budget_changed' => $totalAmountDiff != 0,
        'budget_diff' => $totalAmountDiff,
        'budget_diff_text' => $totalAmountDiff > 0 ? "增加{$totalAmountDiff}分" : ($totalAmountDiff < 0 ? "减少" . abs($totalAmountDiff) . "分" : "未变更")
    ], '修改成功');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log('Rental demand update failed: ' . $e->getMessage());
    Response::error('修改失败，请稍后重试', $errorCodes['RENTAL_DEMAND_CREATE_FAILED']);
}
