<?php
/**
 * C端提现申请接口
 * 
 * POST /api/c/v1/withdraw
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * 请求体：
 * {
 *   "amount": 100.00,
 *   "withdraw_method": "alipay",
 *   "withdraw_account": "13800138000",
 *   "account_name": "张三",
 *   "pswd": "e10adc3949ba59abbe56e057f20f883e"
 * }
 * 
 * 收款方式：不限制，传什么保存什么（如：alipay、wechat、bank、usdt等）
 * 金额限制：最低1元，无上限
 * 收款账号：必须提供（支付宝账号、微信号、银行卡号、USDT地址等）
 * 收款人姓名：必须提供，用于支付宝/银行卡转账时的姓名验证
 * 支付密码：必须提供，用于安全验证
 * 
 * 注意：
 * - 提现申请创建后不立即扣款
 * - 需等待管理员审核通过后才实际扣除余额
 * - 提现金额不能超过当前余额
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
require_once __DIR__ . '/../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 检查用户的一级和二级邀请人是否是大团团长
// 返回值：true表示不允许提现（一级或二级邀请人中有大团团长），false表示允许提现
function hasLargeGroupAgentInUpperChain($db, $userId) {
    // 查询当前用户信息，获取一级邀请人
    $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    $currentUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$currentUser || !$currentUser['parent_id']) {
        return false; // 没有一级邀请人，允许提现
    }
    
    // 查询一级邀请人信息
    $stmt = $db->prepare("SELECT id, username, is_agent, parent_id FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['parent_id']]);
    $firstLevelUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$firstLevelUser) {
        return false; // 一级邀请人不存在，允许提现
    }
    
    // 检查一级邀请人是否是大团团长
    if ($firstLevelUser['is_agent'] == 3) {
        return true; // 一级邀请人是大团团长，不允许提现
    }
    
    // 查询二级邀请人信息
    if (!$firstLevelUser['parent_id']) {
        return false; // 没有二级邀请人，允许提现
    }
    
    $stmt = $db->prepare("SELECT id, username, is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$firstLevelUser['parent_id']]);
    $secondLevelUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$secondLevelUser) {
        return false; // 二级邀请人不存在，允许提现
    }
    
    // 检查二级邀请人是否是大团团长
    if ($secondLevelUser['is_agent'] == 3) {
        return true; // 二级邀请人是大团团长，不允许提现
    }
    
    return false; // 一级和二级邀请人都不是大团团长，允许提现
}

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$amount = $input['amount'] ?? 0;
$withdrawMethod = trim($input['withdraw_method'] ?? '');
$withdrawAccount = trim($input['withdraw_account'] ?? '');
$accountName = trim($input['account_name'] ?? ''); // 收款人姓名

// 参数校验
if (empty($amount) || !is_numeric($amount) || $amount <= 0) {
    Response::error('提现金额必须大于0', $errorCodes['WITHDRAW_AMOUNT_INVALID']);
}

// 清除配置缓存，确保读取最新的配置值
AppConfig::clearCache();

// 获取提现限制配置
$minAmount = AppConfig::get('c_withdraw_min_amount', 100);
$maxAmount = AppConfig::get('c_withdraw_max_amount', 500);
$amountMultiple = AppConfig::get('c_withdraw_amount_multiple', 100);
$dailyLimit = AppConfig::get('c_withdraw_daily_limit', 1000);
$allowedWeekdays = AppConfig::get('c_withdraw_allowed_weekdays', ['4']);



// 限制1：金额必须是整数倍
if ($amount != floor($amount / $amountMultiple) * $amountMultiple) {
    Response::error("提现金额必须是{$amountMultiple}元的整数倍", $errorCodes['WITHDRAW_AMOUNT_INVALID']);
}

// 限制2：最低/最高金额限制
if ($amount < $minAmount) {
    Response::error("提现金额最低{$minAmount}元", $errorCodes['WITHDRAW_AMOUNT_INVALID']);
}

if ($amount > $maxAmount) {
    Response::error("单次提现金额不能超过{$maxAmount}元", $errorCodes['WITHDRAW_AMOUNT_INVALID']);
}

if (empty($withdrawMethod)) {
    Response::error('收款方式不能为空', $errorCodes['WITHDRAW_METHOD_INVALID']);
}

if (empty($withdrawAccount)) {
    Response::error('收款账号不能为空', $errorCodes['WITHDRAW_ACCOUNT_EMPTY']);
}

if (empty($accountName)) {
    Response::error('收款人姓名不能为空', $errorCodes['WITHDRAW_ACCOUNT_NAME_EMPTY']);
}

try {
    // 限制3：星期几限制
    $currentWeekday = date('w'); // 0=周日, 1-6=周一至周六
    $currentWeekdayStr = strval($currentWeekday); // 转换为字符串，与配置值类型匹配

    
    if (!in_array($currentWeekdayStr, $allowedWeekdays)) {
        $weekdayNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
        $allowedNames = array_map(function($day) use ($weekdayNames) {
            return $weekdayNames[intval($day)];
        }, $allowedWeekdays);
        $allowedStr = implode('、', $allowedNames);
        error_log("星期几检查失败，返回错误: 只能在{$allowedStr}提现");
        Response::error("只能在{$allowedStr}提现", $errorCodes['WITHDRAW_TIME_NOT_ALLOWED']);
    }
    
    error_log("星期几检查通过，继续检查大团团长");
    
    // 查询C端用户信息
    $stmt = $db->prepare("SELECT wallet_id, username, is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $cUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$cUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 检查用户是否在大团团长的2级邀请链中
    // 业务规则：
    // 1. 大团团长本人可以提现
    // 2. 大团团长直接邀请的一级用户无法提现
    // 3. 大团团长间接邀请的二级用户无法提现
    // 4. 三级及以上邀请用户（其一级和二级邀请人都不是大团团长）可以正常提现
    $userAgentLevel = (int)($cUser['is_agent'] ?? 0);
    

    
    // 判断用户是否是大团团长
    $isLargeGroupAgent = ($userAgentLevel == 3);
    error_log("是否为大团团长: " . ($isLargeGroupAgent ? '是' : '否'));
    
    if ($isLargeGroupAgent) {
        error_log("大团团长本人，允许提现");
        error_log("=== 提现权限检查结束 ===");
    } else {
        // 检查一级和二级邀请人中是否有大团团长
        $hasLargeGroupInUpperChain = hasLargeGroupAgentInUpperChain($db, $currentUser['user_id']);
        error_log("一级或二级邀请人中是否有大团团长: " . ($hasLargeGroupInUpperChain ? '是' : '否'));
        
        // 如果一级或二级邀请人中有大团团长，则不允许提现
        if ($hasLargeGroupInUpperChain) {
            error_log("一级或二级邀请人中有大团团长，不允许提现");
            error_log("=== 提现权限检查结束 ===");
            Response::error('您的一级或二级邀请人中有大团团长，不允许提现', $errorCodes['WITHDRAW_NOT_ALLOWED']);
        } else {
            error_log("一级和二级邀请人中都没有大团团长，允许提现");
            error_log("=== 提现权限检查结束 ===");
        }
    }
    
    // 查询钱包当前余额
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$cUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }
    
    // 将金额转换为分
    $amountInCents = (int)round($amount * 100);
    $currentBalance = (int)$wallet['balance'];

    // 计算提现手续费
    $feeRate = (float)AppConfig::get('c_withdraw_fee_rate', 0.03);
    $feeAmountInCents = (int)round($amountInCents * $feeRate);
    $actualAmountInCents = $amountInCents - $feeAmountInCents;
    
    // 限制4：检查当天提现总额
    $todayStart = date('Y-m-d 00:00:00');
    $todayEnd = date('Y-m-d 23:59:59');
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as today_total
        FROM withdraw_requests
        WHERE user_id = ? AND user_type = 1 
        AND status IN (0, 1)
        AND created_at BETWEEN ? AND ?
    ");
    $stmt->execute([$currentUser['user_id'], $todayStart, $todayEnd]);
    $todayTotal = $stmt->fetch(PDO::FETCH_ASSOC)['today_total'];
    $todayTotalYuan = $todayTotal / 100;
    
    if (($todayTotalYuan + $amount) > $dailyLimit) {
        $remaining = $dailyLimit - $todayTotalYuan;
        Response::error("今日提现额度不足，今日已提现¥{$todayTotalYuan}，剩余额度¥{$remaining}，每日限额¥{$dailyLimit}", $errorCodes['WITHDRAW_DAILY_LIMIT_EXCEEDED']);
    }
    
    // 校验余额是否足够
    if ($currentBalance < $amountInCents) {
        $needAmount = number_format($amountInCents / 100, 2);
        $availableAmount = number_format($currentBalance / 100, 2);
        Response::error("余额不足，当前可用余额：¥{$availableAmount}，提现金额：¥{$needAmount}", $errorCodes['WITHDRAW_INSUFFICIENT_BALANCE']);
    }
    
    // 开启事务
    $db->beginTransaction();
    
    // 1. 立即扣除钱包余额
    $newBalance = $currentBalance - $amountInCents;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $stmt->execute([$newBalance, $cUser['wallet_id']]);
    
    // 2. 创建钱包流水记录（真实扣款）
    $remark = "提现申请 ¥" . number_format($amount, 2) . "，手续费 ¥" . number_format($feeAmountInCents / 100, 2) . "，实到 ¥" . number_format($actualAmountInCents / 100, 2) . "，收款方式：{$withdrawMethod}，审核中";
    $stmt = $db->prepare("
        INSERT INTO wallets_log (
            wallet_id, user_id, username, user_type, type, 
            amount, before_balance, after_balance, 
            related_type, related_id, remark
        ) VALUES (?, ?, ?, 1, 2, ?, ?, ?, 'withdraw', 0, ?)
    ");
    
    $stmt->execute([
        $cUser['wallet_id'],
        $currentUser['user_id'],
        $cUser['username'],
        $amountInCents,
        $currentBalance,
        $newBalance, // 扣款后的余额
        $remark
    ]);
    
    // 3. 记录C端任务统计
    try {
        $stmt = $db->prepare(" 
            INSERT INTO c_task_statistics (
                c_user_id, username, flow_type, amount, before_balance, after_balance, 
                related_type, related_id, task_types, task_types_text, remark
            ) VALUES (?, ?, 2, ?, ?, ?, 'withdraw', 0, NULL, NULL, ?)
        ");
        $stmt->execute([
            $currentUser['user_id'],
            $cUser['username'],
            $amountInCents,
            $currentBalance,
            $newBalance,
            $remark
        ]);
    } catch (Exception $e) {
        // 记录插入失败时的错误日志，但不影响主流程
        error_log('插入c_task_statistics失败: ' . $e->getMessage());
    }
    $logId = $db->lastInsertId();
    
    // 3. 创建提现申请记录（保存流水ID和手续费信息）
    $stmt = $db->prepare("
        INSERT INTO withdraw_requests (
            user_id, username, user_type, wallet_id,
            amount, fee_rate, fee_amount, actual_amount,
            withdraw_method, withdraw_account, account_name, log_id, status
        ) VALUES (?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
    ");

    $stmt->execute([
        $currentUser['user_id'],
        $cUser['username'],
        $cUser['wallet_id'],
        $amountInCents,
        $feeRate,
        $feeAmountInCents,
        $actualAmountInCents,
        $withdrawMethod,
        $withdrawAccount,
        $accountName,
        $logId
    ]);
    
    $withdrawId = $db->lastInsertId();
    
    // 4. 更新流水记录的 related_id 为提现申请ID
    $stmt = $db->prepare("UPDATE wallets_log SET related_id = ? WHERE id = ?");
    $stmt->execute([$withdrawId, $logId]);
    
    // 提交事务
    $db->commit();
    
    // 返回成功响应
    Response::success([
        'withdraw_id' => (int)$withdrawId,
        'amount' => number_format($amount, 2),
        'fee_rate' => $feeRate,
        'fee_amount' => number_format($feeAmountInCents / 100, 2),
        'actual_amount' => number_format($actualAmountInCents / 100, 2),
        'withdraw_method' => $withdrawMethod,
        'withdraw_account' => $withdrawAccount,
        'status' => 0,
        'status_text' => '待审核',
        'current_balance' => number_format($newBalance / 100, 2)
    ], '提现申请提交成功，请等待审核');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('提现申请失败', $errorCodes['WITHDRAW_REQUEST_FAILED'], 500);
}
