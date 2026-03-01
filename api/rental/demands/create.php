<?php
/**
 * 发布求租信息接口
 * 
 * POST /api/rental/demands/create
 * 
 * 请求头：
 * X-Token: <token> (B端或C端)
 * 
 * 请求体：
 * {
 *   "title": "求租抖音高等级账号",
 *   "budget_amount": 150000,
 *   "days_needed": 7,
 *   "deadline": 1737388799,
 *   "requirements_json": {
 *     "account_requirements": "粉丝10万+，权重高",
 *     "login_requirements": "扫码登录",
 *     "other_requirements": "需要实名认证"
 *   }
 * }
 * 
 * 说明：
 * - budget_amount: 预算金额（单位：分），发布时从钱包扣除并冻结
 * - deadline: 截止时间（10位时间戳，北京时间），最多30天
 * - 发布成功后，钱包余额减少，生成冻结记录
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
$title = trim($input['title'] ?? '');
$budgetAmount = intval($input['budget_amount'] ?? 0);
$daysNeeded = intval($input['days_needed'] ?? 1);
$deadline = intval($input['deadline'] ?? 0);
$requirementsJson = $input['requirements_json'] ?? null;

// 参数校验
if (empty($title)) {
    Response::error('标题不能为空', $errorCodes['RENTAL_DEMAND_TITLE_EMPTY']);
}

if ($budgetAmount <= 0) {
    Response::error('预算金额必须大于0', $errorCodes['RENTAL_DEMAND_BUDGET_INVALID']);
}

if ($daysNeeded < 1 || $daysNeeded > 365) {
    Response::error('租赁天数必须在1-365天之间', $errorCodes['RENTAL_DEMAND_DAYS_INVALID']);
}

// 校验截止时间（10位时间戳）
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

// JSON数据处理
$requirementsJsonStr = null;
if ($requirementsJson !== null) {
    $requirementsJsonStr = json_encode($requirementsJson, JSON_UNESCAPED_UNICODE);
}

try {
    $db->beginTransaction();

    // 1. 获取用户信息和钱包ID
    $tableName = $userType == 1 ? 'c_users' : 'b_users';
    $userStmt = $db->prepare("SELECT username, wallet_id FROM {$tableName} WHERE id = ?");
    $userStmt->execute([$userId]);
    $userInfo = $userStmt->fetch(PDO::FETCH_ASSOC);

    if (!$userInfo) {
        Response::error('用户不存在', $errorCodes['USER_NOT_FOUND']);
    }

    $username = $userInfo['username'];
    $walletId = $userInfo['wallet_id'];

    // 2. 获取钱包余额
    $walletStmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $walletStmt->execute([$walletId]);
    $currentBalance = $walletStmt->fetchColumn();

    if ($currentBalance === false) {
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }

    // 3. 计算总冻结金额（日预算 × 天数）
    $totalFreezeAmount = $budgetAmount * $daysNeeded;
    
    // 4. 检查余额是否足够
    if ($currentBalance < $totalFreezeAmount) {
        $db->rollBack();
        Response::error('钱包余额不足', $errorCodes['RENTAL_DEMAND_INSUFFICIENT_BALANCE']);
    }

    // 5. 扣减钱包余额（冻结）
    $newBalance = $currentBalance - $totalFreezeAmount;
    $updateWalletStmt = $db->prepare("
        UPDATE wallets 
        SET balance = ? 
        WHERE id = ?
    ");
    $updateWalletStmt->execute([$newBalance, $walletId]);

    // 5. 插入钱包流水记录（冻结）
    $insertLogStmt = $db->prepare("
        INSERT INTO wallets_log 
        (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, remark, created_at) 
        VALUES 
        (?, ?, ?, ?, 2, ?, ?, ?, 'rental_freeze', NULL, ?, NOW())
    ");
    $insertLogStmt->execute([
        $walletId,
        $userId,
        $username,
        $userType,
        $totalFreezeAmount,
        $currentBalance,
        $newBalance,
        "求租信息冻结预算（{$budgetAmount}分/天×{$daysNeeded}天）：{$title}"
    ]);

    $logId = $db->lastInsertId();

    // 6. 插入求租信息
    $insertDemandStmt = $db->prepare("
        INSERT INTO rental_demands 
        (user_id, user_type, wallet_id, title, budget_amount, days_needed, deadline, requirements_json, status, created_at, updated_at) 
        VALUES 
        (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())
    ");
    
    $insertDemandStmt->execute([
        $userId,
        $userType,
        $walletId,
        $title,
        $budgetAmount,
        $daysNeeded,
        date('Y-m-d H:i:s', $deadline),
        $requirementsJsonStr
    ]);

    $demandId = $db->lastInsertId();

    // 7. 更新 wallet_log 的 related_id
    $updateLogStmt = $db->prepare("
        UPDATE wallets_log 
        SET related_id = ? 
        WHERE id = ?
    ");
    $updateLogStmt->execute([$demandId, $logId]);

    $db->commit();

    Response::success([
        'demand_id' => $demandId,
        'title' => $title,
        'budget_amount' => $budgetAmount,
        'budget_amount_yuan' => number_format($budgetAmount / 100, 2),
        'days_needed' => $daysNeeded,
        'deadline' => $deadline,
        'deadline_datetime' => date('Y-m-d H:i:s', $deadline),
        'status' => 1,
        'status_text' => '发布中',
        'wallet_frozen' => $budgetAmount,
        'wallet_balance' => $newBalance,
        'log_id' => $logId
    ], '发布成功，预算已冻结');

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log('Rental demand create failed: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    
    // 开发环境下显示详细错误信息（生产环境请注释掉）
    if (isset($_GET['debug'])) {
        Response::error('发布失败：' . $e->getMessage(), $errorCodes['RENTAL_DEMAND_CREATE_FAILED']);
    }
    
    Response::error('发布失败，请稍后重试', $errorCodes['RENTAL_DEMAND_CREATE_FAILED']);
}
