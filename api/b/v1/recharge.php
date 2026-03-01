<?php
/**
 * B端充值申请接口
 * 
 * POST /api/b/v1/recharge
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "amount": 100.00,
 *   "payment_method": "alipay",
 *   "payment_voucher": "http://example.com/img/xxx.jpg",
 *   "pswd": "e10adc3949ba59abbe56e057f20f883e"
 * }
 * 
 * 支付方式：不限制，传什么保存什么（如：alipay、wechat、usdt等）
 * 金额限制：最低1元，无上限
 * 支付密码：必须提供，用于安全验证
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

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$amount = $input['amount'] ?? 0;
$paymentMethod = trim($input['payment_method'] ?? '');
$paymentVoucher = trim($input['payment_voucher'] ?? '');
$pswd = trim($input['pswd'] ?? ''); // 支付密码

// 参数校验
if (empty($amount) || !is_numeric($amount) || $amount <= 0) {
    Response::error('充值金额必须大于0', $errorCodes['RECHARGE_AMOUNT_INVALID']);
}

// 金额限制（最低1元）
if ($amount < 1) {
    Response::error('充值金额最低1元', $errorCodes['RECHARGE_AMOUNT_INVALID']);
}

if (empty($paymentMethod)) {
    Response::error('支付方式不能为空', $errorCodes['RECHARGE_PAYMENT_METHOD_INVALID']);
}

if (empty($paymentVoucher)) {
    Response::error('支付凭证不能为空', $errorCodes['RECHARGE_VOUCHER_EMPTY']);
}

try {
    // 查询B端用户信息
    $stmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 查询钱包当前余额
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }
    
    // 将金额转换为分
    $amountInCents = (int)round($amount * 100);
    $currentBalance = (int)$wallet['balance'];
    
    // 验证支付密码
    require_once __DIR__ . '/../../../core/WalletPassword.php';
    WalletPassword::verify($db, $bUser['wallet_id'], $pswd, $errorCodes);
    
    // 开启事务
    $db->beginTransaction();
    
    // 1. 先创建钱包流水记录（related_id暂时为0）
    $remark = "充值 ¥" . number_format($amount, 2) . "（{$paymentMethod}），审核中";
    $stmt = $db->prepare("
        INSERT INTO wallets_log (
            wallet_id, user_id, username, user_type, type, 
            amount, before_balance, after_balance, 
            related_type, related_id, remark
        ) VALUES (?, ?, ?, 2, 1, 0, ?, ?, 'recharge', 0, ?)
    ");
    $stmt->execute([
        $bUser['wallet_id'],
        $currentUser['user_id'],
        $bUser['username'],
        $currentBalance,
        $currentBalance,  // 审核中，余额不变
        $remark
    ]);
    $logId = $db->lastInsertId();
    
    // 2. 创建充值申请记录（保存流水ID）
    $stmt = $db->prepare("
        INSERT INTO recharge_requests (
            user_id, username, user_type, wallet_id, amount, 
            payment_method, payment_voucher, log_id, status
        ) VALUES (?, ?, 2, ?, ?, ?, ?, ?, 0)
    ");
    $stmt->execute([
        $currentUser['user_id'],
        $bUser['username'],
        $bUser['wallet_id'],
        $amountInCents,
        $paymentMethod,
        $paymentVoucher,
        $logId
    ]);
    $rechargeId = $db->lastInsertId();
    
    // 3. 更新流水记录的 related_id 为充值申请ID
    $stmt = $db->prepare("UPDATE wallets_log SET related_id = ? WHERE id = ?");
    $stmt->execute([$rechargeId, $logId]);
    
    // 提交事务
    $db->commit();
    
    // 返回成功响应
    Response::success([
        'recharge_id' => (int)$rechargeId,
        'amount' => number_format($amount, 2),
        'payment_method' => $paymentMethod,
        'payment_voucher' => $paymentVoucher,
        'status' => 0,
        'status_text' => '待审核',
        'current_balance' => number_format($currentBalance / 100, 2),
        'remark' => '充值申请已提交，请等待管理员审核'
    ], '充值申请提交成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('充值申请失败', $errorCodes['RECHARGE_REQUEST_FAILED'], 500);
}
