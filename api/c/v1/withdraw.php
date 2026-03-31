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
 *   "account_name": "张三"
 * }
 *
 * 收款方式：不限制，传什么保存什么（如：alipay、wechat、bank、usdt等）
 * 金额限制：最低1元，无上限
 * 收款账号：必须提供（支付宝账号、微信号、银行卡号、USDT地址等）
 * 收款人姓名：必须提供，用于支付宝/银行卡转账时的姓名验证
 *
 * 注意：
 * - 提现申请创建后不立即扣款
 * - 需等待管理员审核通过后才实际扣除余额
 * - 提现金额不能超过当前余额
 *
 * 错误码说明：
 * 1001 - 请求方法错误
 * 1002 - 数据库错误
 * 2001 - Token无效
 * 2002 - Token过期
 * 3003 - 用户不存在
 * 5000 - 系统错误
 * 8000 - 提现金额无效
 * 8001 - 收款方式无效
 * 8002 - 收款账号为空
 * 8003 - 提现申请失败
 * 8004 - 余额不足
 * 8005 - 不在允许提现的时间段
 * 8006 - 每日提现限额超限
 * 8007 - 收款人姓名为空
 * 8008 - 不允许提现（一级或二级邀请人中有大团团长）
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/withdraw');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C端提现申请请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户提现申请失败：请求方法错误', [
        'reason' => '请求方法错误',
    ]);

    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$requestLogger->debug('读取请求体');
$requestBody = file_get_contents('php://input');
$requestLogger->debug('请求体内容', ['body' => $requestBody]);

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../core/AppConfig.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C端用户提现申请失败：数据库连接失败', [
        'exception' => $e->getMessage(),
        'reason' => '数据库连接失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => $errorCodes['DATABASE_ERROR'] ?? 1002,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token认证失败', ['exception' => $e->getMessage()]);

    $auditLogger->warning('C端用户提现申请失败：Token认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token认证失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => $errorCodes['AUTH_TOKEN_INVALID'] ?? 2001,
        'message' => '认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$input = json_decode($requestBody, true);
$amount = $input['amount'] ?? 0;
$withdrawMethod = trim($input['withdraw_method'] ?? '');
$withdrawAccount = trim($input['withdraw_account'] ?? '');
$accountName = trim($input['account_name'] ?? '');

$requestLogger->debug('请求参数', [
    'user_id' => $currentUser['user_id'],
    'amount' => $amount,
    'withdraw_method' => $withdrawMethod,
    'withdraw_account' => $withdrawAccount,
    'account_name' => $accountName,
]);

if (empty($amount) || !is_numeric($amount) || $amount <= 0) {
    $requestLogger->warning('提现金额无效', ['amount' => $amount]);

    $auditLogger->warning('C端用户提现申请失败：提现金额无效', [
        'user_id' => $currentUser['user_id'],
        'amount' => $amount,
        'reason' => '提现金额必须大于0',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('提现金额必须大于0', $errorCodes['WITHDRAW_AMOUNT_INVALID'] ?? 8000);
}

AppConfig::clearCache();

$minAmount = AppConfig::get('c_withdraw_min_amount', 100);
$maxAmount = AppConfig::get('c_withdraw_max_amount', 500);
$amountMultiple = AppConfig::get('c_withdraw_amount_multiple', 100);
$dailyLimit = AppConfig::get('c_withdraw_daily_limit', 1000);
$allowedWeekdays = AppConfig::get('c_withdraw_allowed_weekdays', ['4']);

$requestLogger->debug('提现配置', [
    'min_amount' => $minAmount,
    'max_amount' => $maxAmount,
    'amount_multiple' => $amountMultiple,
    'daily_limit' => $dailyLimit,
    'allowed_weekdays' => $allowedWeekdays,
]);

if ($amount != floor($amount / $amountMultiple) * $amountMultiple) {
    $requestLogger->warning('提现金额不是整数倍', ['amount' => $amount, 'multiple' => $amountMultiple]);

    $auditLogger->warning('C端用户提现申请失败：提现金额不是整数倍', [
        'user_id' => $currentUser['user_id'],
        'amount' => $amount,
        'multiple' => $amountMultiple,
        'reason' => '提现金额必须是' . $amountMultiple . '元的整数倍',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error("提现金额必须是{$amountMultiple}元的整数倍", $errorCodes['WITHDRAW_AMOUNT_INVALID'] ?? 8000);
}

if ($amount < $minAmount) {
    $requestLogger->warning('提现金额低于最低限制', ['amount' => $amount, 'min' => $minAmount]);

    $auditLogger->warning('C端用户提现申请失败：提现金额低于最低限制', [
        'user_id' => $currentUser['user_id'],
        'amount' => $amount,
        'min_amount' => $minAmount,
        'reason' => '提现金额最低' . $minAmount . '元',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error("提现金额最低{$minAmount}元", $errorCodes['WITHDRAW_AMOUNT_INVALID'] ?? 8000);
}

if ($amount > $maxAmount) {
    $requestLogger->warning('提现金额超过最高限制', ['amount' => $amount, 'max' => $maxAmount]);

    $auditLogger->warning('C端用户提现申请失败：提现金额超过最高限制', [
        'user_id' => $currentUser['user_id'],
        'amount' => $amount,
        'max_amount' => $maxAmount,
        'reason' => '单次提现金额不能超过' . $maxAmount . '元',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error("单次提现金额不能超过{$maxAmount}元", $errorCodes['WITHDRAW_AMOUNT_INVALID'] ?? 8000);
}

if (empty($withdrawMethod)) {
    $requestLogger->warning('收款方式为空');

    $auditLogger->warning('C端用户提现申请失败：收款方式为空', [
        'user_id' => $currentUser['user_id'],
        'reason' => '收款方式不能为空',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('收款方式不能为空', $errorCodes['WITHDRAW_METHOD_INVALID'] ?? 8001);
}

if (empty($withdrawAccount)) {
    $requestLogger->warning('收款账号为空');

    $auditLogger->warning('C端用户提现申请失败：收款账号为空', [
        'user_id' => $currentUser['user_id'],
        'reason' => '收款账号不能为空',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('收款账号不能为空', $errorCodes['WITHDRAW_ACCOUNT_EMPTY'] ?? 8002);
}

if (empty($accountName)) {
    $requestLogger->warning('收款人姓名为空');

    $auditLogger->warning('C端用户提现申请失败：收款人姓名为空', [
        'user_id' => $currentUser['user_id'],
        'reason' => '收款人姓名不能为空',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('收款人姓名不能为空', $errorCodes['WITHDRAW_ACCOUNT_NAME_EMPTY'] ?? 8007);
}

try {
    $currentWeekday = date('w');
    $currentWeekdayStr = strval($currentWeekday);

    $requestLogger->debug('星期几检查', ['weekday' => $currentWeekday, 'allowed' => $allowedWeekdays]);

    if (!in_array($currentWeekdayStr, $allowedWeekdays)) {
        $weekdayNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
        $allowedNames = array_map(function($day) use ($weekdayNames) {
            return $weekdayNames[intval($day)];
        }, $allowedWeekdays);
        $allowedStr = implode('、', $allowedNames);

        $requestLogger->warning('星期几不允许提现', ['weekday' => $currentWeekday, 'allowed' => $allowedStr]);

        $auditLogger->warning('C端用户提现申请失败：星期几不允许提现', [
            'user_id' => $currentUser['user_id'],
            'weekday' => $currentWeekday,
            'allowed_weekdays' => $allowedStr,
            'reason' => '只能在' . $allowedStr . '提现',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("只能在{$allowedStr}提现", $errorCodes['WITHDRAW_TIME_NOT_ALLOWED'] ?? 8005);
    }

    $requestLogger->debug('查询C端用户信息', ['user_id' => $currentUser['user_id']]);
    $stmt = $db->prepare("SELECT wallet_id, username, is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $cUser = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$cUser) {
        $errorLogger->error('C端用户不存在', ['user_id' => $currentUser['user_id']]);

        $auditLogger->error('C端用户提现申请失败：用户不存在', [
            'user_id' => $currentUser['user_id'],
            'reason' => '用户信息异常',
        ]);

        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND'] ?? 3003);
    }

    $userAgentLevel = (int)($cUser['is_agent'] ?? 0);
    $isLargeGroupAgent = ($userAgentLevel == 3);

    $requestLogger->debug('大团团长检查', [
        'user_id' => $currentUser['user_id'],
        'is_agent' => $userAgentLevel,
        'is_large_group_agent' => $isLargeGroupAgent,
    ]);

    if ($isLargeGroupAgent) {
        $requestLogger->debug('大团团长本人，允许提现');
    } else {
        $hasLargeGroupInUpperChain = hasLargeGroupAgentInUpperChain($db, $currentUser['user_id']);
        $requestLogger->debug('上级链大团团长检查', ['has_large_group' => $hasLargeGroupInUpperChain]);

        if ($hasLargeGroupInUpperChain) {
            $requestLogger->warning('一级或二级邀请人中有大团团长');

            $auditLogger->warning('C端用户提现申请失败：一级或二级邀请人中有大团团长', [
                'user_id' => $currentUser['user_id'],
                'reason' => '您的一级或二级邀请人中有大团团长，不允许提现',
            ]);

            if (method_exists($auditLogger, 'flush')) {
                $auditLogger->flush();
            }

            Response::error('您的一级或二级邀请人中有大团团长，不允许提现', $errorCodes['WITHDRAW_NOT_ALLOWED'] ?? 8008);
        }
    }

    $requestLogger->debug('查询钱包余额', ['wallet_id' => $cUser['wallet_id']]);
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$cUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$wallet) {
        $errorLogger->error('钱包不存在', ['wallet_id' => $cUser['wallet_id']]);

        $auditLogger->error('C端用户提现申请失败：钱包不存在', [
            'user_id' => $currentUser['user_id'],
            'wallet_id' => $cUser['wallet_id'],
            'reason' => '钱包不存在',
        ]);

        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND'] ?? 5001);
    }

    $amountInCents = (int)round($amount * 100);
    $currentBalance = (int)$wallet['balance'];

    $feeRate = (float)AppConfig::get('c_withdraw_fee_rate', 0.03);
    $feeAmountInCents = (int)round($amountInCents * $feeRate);
    $actualAmountInCents = $amountInCents - $feeAmountInCents;

    $requestLogger->debug('提现费用计算', [
        'amount' => $amount,
        'amount_cents' => $amountInCents,
        'fee_rate' => $feeRate,
        'fee_amount' => $feeAmountInCents,
        'actual_amount' => $actualAmountInCents,
    ]);

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

    $requestLogger->debug('当日提现统计', [
        'today_total' => $todayTotalYuan,
        'daily_limit' => $dailyLimit,
        'current_amount' => $amount,
    ]);

    if (($todayTotalYuan + $amount) > $dailyLimit) {
        $remaining = $dailyLimit - $todayTotalYuan;
        $requestLogger->warning('每日提现限额超限', [
            'today_total' => $todayTotalYuan,
            'current_amount' => $amount,
            'daily_limit' => $dailyLimit,
            'remaining' => $remaining,
        ]);

        $auditLogger->warning('C端用户提现申请失败：每日提现限额超限', [
            'user_id' => $currentUser['user_id'],
            'today_total' => $todayTotalYuan,
            'current_amount' => $amount,
            'daily_limit' => $dailyLimit,
            'reason' => '今日提现额度不足',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("今日提现额度不足，今日已提现¥{$todayTotalYuan}，剩余额度¥{$remaining}，每日限额¥{$dailyLimit}", $errorCodes['WITHDRAW_DAILY_LIMIT_EXCEEDED'] ?? 8006);
    }

    if ($currentBalance < $amountInCents) {
        $needAmount = number_format($amountInCents / 100, 2);
        $availableAmount = number_format($currentBalance / 100, 2);
        $requestLogger->warning('余额不足', ['need' => $needAmount, 'available' => $availableAmount]);

        $auditLogger->warning('C端用户提现申请失败：余额不足', [
            'user_id' => $currentUser['user_id'],
            'need_amount' => $needAmount,
            'available_amount' => $availableAmount,
            'reason' => '余额不足',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("余额不足，当前可用余额：¥{$availableAmount}，提现金额：¥{$needAmount}", $errorCodes['WITHDRAW_INSUFFICIENT_BALANCE'] ?? 8004);
    }

    $requestLogger->debug('开启数据库事务');
    $db->beginTransaction();

    $newBalance = $currentBalance - $amountInCents;
    $requestLogger->debug('扣除钱包余额', ['wallet_id' => $cUser['wallet_id'], 'new_balance' => $newBalance]);
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $stmt->execute([$newBalance, $cUser['wallet_id']]);

    $remark = "提现申请 ¥" . number_format($amount, 2) . "，手续费 ¥" . number_format($feeAmountInCents / 100, 2) . "，实到 ¥" . number_format($actualAmountInCents / 100, 2) . "，收款方式：{$withdrawMethod}，审核中";
    $stmt = $db->prepare("
        INSERT INTO wallets_log (
            wallet_id, user_id, username, user_type, type,
            amount, before_balance, after_balance,
            related_type, related_id, remark
        ) VALUES (?, ?, ?, 1, 2, ?, ?, ?, '提现', 0, ?)
    ");

    $stmt->execute([
        $cUser['wallet_id'],
        $currentUser['user_id'],
        $cUser['username'],
        $amountInCents,
        $currentBalance,
        $newBalance,
        $remark
    ]);

    try {
        $stmt = $db->prepare("
            INSERT INTO c_task_statistics (
                c_user_id, username, flow_type, amount, before_balance, after_balance,
                related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
            ) VALUES (?, ?, 2, ?, ?, ?, 'withdraw', 0, NULL, NULL, 2, '提现申请记录，当前状态待审核', ?)
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
        $errorLogger->error('插入c_task_statistics失败', ['exception' => $e->getMessage()]);
    }
    $logId = $db->lastInsertId();

    $requestLogger->debug('创建提现申请记录', ['log_id' => $logId]);
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

    $stmt = $db->prepare("UPDATE wallets_log SET related_id = ? WHERE id = ?");
    $stmt->execute([$withdrawId, $logId]);

    $requestLogger->debug('提交数据库事务');
    $db->commit();

    $auditLogger->notice('C端用户提现申请成功', [
        'user_id' => $currentUser['user_id'],
        'withdraw_id' => $withdrawId,
        'amount' => $amount,
        'fee_amount' => number_format($feeAmountInCents / 100, 2),
        'actual_amount' => number_format($actualAmountInCents / 100, 2),
        'withdraw_method' => $withdrawMethod,
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    $requestLogger->info('C端提现申请成功', [
        'withdraw_id' => $withdrawId,
        'amount' => $amount,
        'fee_amount' => number_format($feeAmountInCents / 100, 2),
        'actual_amount' => number_format($actualAmountInCents / 100, 2),
    ]);

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
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('PDO异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户提现申请失败：数据库异常', [
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('提现申请失败', $errorCodes['WITHDRAW_REQUEST_FAILED'] ?? 8003, 500);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }

    $errorLogger->error('系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户提现申请失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('提现申请失败', $errorCodes['WITHDRAW_REQUEST_FAILED'] ?? 8003, 500);
}

function hasLargeGroupAgentInUpperChain($db, $userId) {
    $stmt = $db->prepare("SELECT parent_id FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    $currentUser = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$currentUser || !$currentUser['parent_id']) {
        return false;
    }

    $stmt = $db->prepare("SELECT id, username, is_agent, parent_id FROM c_users WHERE id = ?");
    $stmt->execute([$currentUser['parent_id']]);
    $firstLevelUser = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$firstLevelUser) {
        return false;
    }

    if ($firstLevelUser['is_agent'] == 3) {
        return true;
    }

    if (!$firstLevelUser['parent_id']) {
        return false;
    }

    $stmt = $db->prepare("SELECT id, username, is_agent FROM c_users WHERE id = ?");
    $stmt->execute([$firstLevelUser['parent_id']]);
    $secondLevelUser = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$secondLevelUser) {
        return false;
    }

    if ($secondLevelUser['is_agent'] == 3) {
        return true;
    }

    return false;
}