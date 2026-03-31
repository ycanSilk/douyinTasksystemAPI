<?php
/**
 * C端用户注销接口
 * POST /task_admin/api/c_users/delete.php
 *
 * 功能：
 * 1. 注销C端用户账号（无视钱包余额，直接清零）
 * 2. 清除关联的钱包数据
 * 3. 记录注销日志到 user_deletion_logs 表
 *
 * 请求参数：
 * - id: 用户ID（必填）
 *
 * 错误码说明：
 * - 1001: 请求方法错误
 * - 1002: 用户ID不能为空
 * - 1003: 用户不存在
 * - 1004: 查询用户信息失败
 * - 5000: 服务器内部错误
 *
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "用户注销成功",
 *   "data": {
 *     "user_id": 123,
 *     "username": "testuser",
 *     "wallet_id": 456,
 *     "wallet_balance_cleared": 10000
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 响应示例（失败）：
 * {
 *   "code": 1002,
 *   "message": "用户ID不能为空",
 *   "data": [],
 *   "timestamp": 1736582400
 * }
 */

// 硬编码错误码
const ERROR_CODES = [
    'SUCCESS' => 0,
    'METHOD_NOT_ALLOWED' => 1001,
    'USER_ID_EMPTY' => 1002,
    'USER_NOT_FOUND' => 1003,
    'QUERY_USER_FAILED' => 1004,
    'SERVER_ERROR' => 5000,
];

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('task_admin/c_users/delete');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== C端用户注销请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: ' . 
       'Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    http_response_code(405);
    echo json_encode([
        'code' => ERROR_CODES['METHOD_NOT_ALLOWED'],
        'message' => '请求方法错误，只允许POST请求',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// 获取当前操作人信息（管理员）
$operatorId = null;
$operatorUsername = null;
$operatorType = 3; // Admin端

try {
    $authResult = AdminAuthMiddleware::authenticate();
    if ($authResult && isset($authResult['user_id'])) {
        $operatorId = $authResult['user_id'];
        $operatorUsername = $authResult['username'] ?? null;
    }
} catch (Exception $e) {
    $requestLogger->warning('管理员认证失败', ['error' => $e->getMessage()]);
}

$db = Database::connect();

// 首先确保日志表存在（在独立连接中执行，避免影响后续事务）
ensureDeletionLogTableExists();

$input = json_decode(file_get_contents('php://input'), true);
$userId = (int)($input['id'] ?? 0);

// 记录请求参数
$requestLogger->debug('请求参数', [
    'user_id' => $userId,
    'operator_id' => $operatorId,
    'operator_username' => $operatorUsername,
]);

// 参数校验
if (!$userId) {
    $requestLogger->warning('参数校验失败：用户ID为空', ['user_id' => $userId]);
    
    // 记录注销失败日志
        recordDeletionLog([
            'user_id' => $userId,
            'user_type' => 1,
            'username' => null,
            'wallet_id' => null,
            'wallet_balance_before' => 0,
            'operator_id' => $operatorId,
            'operator_type' => $operatorType,
            'operator_username' => $operatorUsername,
            'operation_ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
            'status' => 0,
            'error_code' => ERROR_CODES['USER_ID_EMPTY'],
            'error_message' => '用户ID不能为空',
        ]);
    
    echo json_encode([
        'code' => ERROR_CODES['USER_ID_EMPTY'],
        'message' => '用户ID不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 检查并创建用户注销日志表（在独立连接中执行，避免事务冲突）
function ensureDeletionLogTableExists() {
    try {
        // 使用新的数据库连接（不在事务中）
        $db = Database::connect();
        
        // 检查表是否存在
        $stmt = $db->prepare("
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = DATABASE() 
            AND table_name = 'user_deletion_logs'
        ");
        $stmt->execute();
        
        if (!$stmt->fetch()) {
            // 表不存在，创建表
            $db->exec("
                CREATE TABLE IF NOT EXISTS `user_deletion_logs` (
                    `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
                    `user_id` bigint UNSIGNED NOT NULL COMMENT '被注销用户ID',
                    `user_type` tinyint NOT NULL DEFAULT 1 COMMENT '用户类型：1=C端，2=B端，3=Admin端',
                    `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户名',
                    `wallet_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联钱包ID',
                    `wallet_balance_before` bigint NOT NULL DEFAULT 0 COMMENT '注销前钱包余额（单位：分）',
                    `operator_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '操作人ID（管理员ID）',
                    `operator_type` tinyint NOT NULL DEFAULT 3 COMMENT '操作人类型：1=C端，2=B端，3=Admin端',
                    `operator_username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人用户名',
                    `operation_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作IP地址',
                    `status` tinyint NOT NULL DEFAULT 1 COMMENT '注销状态：1=成功，0=失败',
                    `error_code` int NULL DEFAULT NULL COMMENT '错误码（失败时记录）',
                    `error_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '错误信息（失败时记录）',
                    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                    PRIMARY KEY (`id`) USING BTREE,
                    INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
                    INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
                    INDEX `idx_operator_id`(`operator_id` ASC) USING BTREE,
                    INDEX `idx_status`(`status` ASC) USING BTREE,
                    INDEX `idx_created_at`(`created_at` ASC) USING BTREE
                ) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户注销日志记录表' ROW_FORMAT = DYNAMIC
            ");
            error_log('自动创建 user_deletion_logs 表成功');
        }
    } catch (Exception $e) {
        error_log('检查/创建 user_deletion_logs 表失败: ' . $e->getMessage());
    }
}

// 记录注销日志的函数（使用独立连接，避免事务冲突）
function recordDeletionLog($logData) {
    try {
        // 使用新的数据库连接（不在事务中）
        $db = Database::connect();
        
        $stmt = $db->prepare("
            INSERT INTO user_deletion_logs (
                user_id, user_type, username, wallet_id, wallet_balance_before,
                operator_id, operator_type, operator_username, operation_ip,
                status, error_code, error_message, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([
            $logData['user_id'],
            $logData['user_type'],
            $logData['username'],
            $logData['wallet_id'],
            $logData['wallet_balance_before'],
            $logData['operator_id'],
            $logData['operator_type'],
            $logData['operator_username'],
            $logData['operation_ip'],
            $logData['status'],
            $logData['error_code'],
            $logData['error_message'],
        ]);
    } catch (Exception $e) {
        // 日志记录失败不影响主流程
        error_log('记录用户注销日志失败: ' . $e->getMessage());
    }
}

$walletBalanceBefore = 0;

// 查询用户信息（在事务外查询，用于记录日志）
try {
    $stmt = $db->prepare("SELECT id, username, wallet_id FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        $requestLogger->warning('用户不存在', ['user_id' => $userId]);
        
        // 记录注销失败日志
        recordDeletionLog([
            'user_id' => $userId,
            'user_type' => 1,
            'username' => null,
            'wallet_id' => null,
            'wallet_balance_before' => 0,
            'operator_id' => $operatorId,
            'operator_type' => $operatorType,
            'operator_username' => $operatorUsername,
            'operation_ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
            'status' => 0,
            'error_code' => ERROR_CODES['USER_NOT_FOUND'],
            'error_message' => '用户不存在',
        ]);
        
        echo json_encode([
            'code' => ERROR_CODES['USER_NOT_FOUND'],
            'message' => '用户不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $walletId = $user['wallet_id'];
    $username = $user['username'];

    $requestLogger->debug('用户信息查询成功', [
        'user_id' => $userId,
        'username' => $username,
        'wallet_id' => $walletId,
    ]);

} catch (PDOException $e) {
    $errorLogger->error('查询用户信息失败', [
        'user_id' => $userId,
        'message' => $e->getMessage(),
    ]);
    
    // 记录注销失败日志
    recordDeletionLog([
        'user_id' => $userId,
        'user_type' => 1,
        'username' => null,
        'wallet_id' => null,
        'wallet_balance_before' => 0,
        'operator_id' => $operatorId,
        'operator_type' => $operatorType,
        'operator_username' => $operatorUsername,
        'operation_ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
        'status' => 0,
        'error_code' => ERROR_CODES['QUERY_USER_FAILED'],
        'error_message' => '查询用户信息失败：' . $e->getMessage(),
    ]);
    
    echo json_encode([
        'code' => ERROR_CODES['QUERY_USER_FAILED'],
        'message' => '查询用户信息失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 开启事务
    $db->beginTransaction();
    $requestLogger->debug('数据库事务已开启');

    // 1. 处理钱包余额（直接清零）
    if ($walletId) {
        $requestLogger->debug('查询钱包余额', ['wallet_id' => $walletId]);
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
        $stmt->execute([$walletId]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($wallet) {
            $walletBalanceBefore = (int)$wallet['balance'];
            $requestLogger->debug('钱包余额查询成功', [
                'wallet_id' => $walletId,
                'balance' => $walletBalanceBefore,
            ]);

            // 如果钱包有余额，直接清零
            if ($walletBalanceBefore > 0) {
                $requestLogger->info('钱包有余额，准备清零', [
                    'wallet_id' => $walletId,
                    'balance' => $walletBalanceBefore,
                ]);

                // 更新钱包余额为0
                $stmt = $db->prepare("UPDATE wallets SET balance = 0 WHERE id = ?");
                $stmt->execute([$walletId]);

                // 记录钱包清零流水
                $stmt = $db->prepare("
                    INSERT INTO wallets_log (
                        wallet_id, user_id, username, user_type, type,
                        amount, before_balance, after_balance,
                        related_type, related_id, task_types, task_types_text, remark
                    ) VALUES (?, ?, ?, 1, 2, ?, ?, ?, 'user_deletion', ?, 0, '', '用户注销，钱包余额清零')
                ");
                $stmt->execute([
                    $walletId,
                    $userId,
                    $username,
                    $walletBalanceBefore,
                    $walletBalanceBefore,
                    0,
                    $userId,
                ]);

                $requestLogger->info('钱包余额已清零', [
                    'wallet_id' => $walletId,
                    'cleared_amount' => $walletBalanceBefore,
                ]);
            }
        }

        // 2. 删除钱包记录
        $stmt = $db->prepare("DELETE FROM wallets WHERE id = ?");
        $stmt->execute([$walletId]);
        $requestLogger->debug('钱包记录已删除', ['wallet_id' => $walletId]);
    }

    // 3. 清除用户设备信息
    $requestLogger->debug('清除用户设备信息', ['user_id' => $userId]);
    $stmt = $db->prepare("
        UPDATE c_users
        SET token = NULL,
            token_expired_at = NULL,
            device_id = NULL,
            device_name = NULL,
            last_login_device = NULL,
            device_list = NULL
        WHERE id = ?
    ");
    $stmt->execute([$userId]);
    $requestLogger->debug('用户设备信息已清除', ['user_id' => $userId]);

    // 4. 删除用户关联表记录（处理外键约束）
    $requestLogger->debug('删除用户关联表记录', ['user_id' => $userId]);
    
    // 删除 c_user_relations 表中的记录（只删除 user_id 匹配的记录）
    $stmt = $db->prepare("DELETE FROM c_user_relations WHERE user_id = ?");
    $stmt->execute([$userId]);
    $requestLogger->debug('c_user_relations 关联记录已删除', ['user_id' => $userId, 'deleted_rows' => $stmt->rowCount()]);
    
    // 5. 删除用户账号
    $requestLogger->debug('删除用户账号', ['user_id' => $userId]);
    $stmt = $db->prepare("DELETE FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    $requestLogger->debug('用户账号已删除', ['user_id' => $userId]);

    // 提交事务
    $db->commit();
    $requestLogger->debug('数据库事务已提交');

    // 记录注销成功日志
    recordDeletionLog([
        'user_id' => $userId,
        'user_type' => 1,
        'username' => $username,
        'wallet_id' => $walletId,
        'wallet_balance_before' => $walletBalanceBefore,
        'operator_id' => $operatorId,
        'operator_type' => $operatorType,
        'operator_username' => $operatorUsername,
        'operation_ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
        'status' => 1,
        'error_code' => null,
        'error_message' => null,
    ]);

    // 记录审计日志
    $auditLogger->notice('C端用户注销成功', [
        'user_id' => $userId,
        'username' => $username,
        'wallet_id' => $walletId,
        'wallet_balance_cleared' => $walletBalanceBefore,
        'operator_id' => $operatorId,
        'operator_username' => $operatorUsername,
    ]);

    $requestLogger->info('C端用户注销成功', [
        'user_id' => $userId,
        'username' => $username,
        'wallet_balance_cleared' => $walletBalanceBefore,
    ]);

    echo json_encode([
        'code' => ERROR_CODES['SUCCESS'],
        'message' => '用户注销成功',
        'data' => [
            'user_id' => $userId,
            'username' => $username,
            'wallet_id' => $walletId,
            'wallet_balance_cleared' => $walletBalanceBefore
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
        $requestLogger->debug('数据库事务已回滚');
    }

    // 记录错误日志
    $errorLogger->error('C端用户注销失败：数据库异常', [
        'user_id' => $userId,
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    // 记录注销失败日志
    recordDeletionLog([
        'user_id' => $userId,
        'user_type' => 1,
        'username' => $username ?? null,
        'wallet_id' => $walletId ?? null,
        'wallet_balance_before' => $walletBalanceBefore,
        'operator_id' => $operatorId,
        'operator_type' => $operatorType,
        'operator_username' => $operatorUsername,
        'operation_ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? null,
        'status' => 0,
        'error_code' => ERROR_CODES['SERVER_ERROR'],
        'error_message' => '数据库异常：' . $e->getMessage(),
    ]);

    http_response_code(500);
    echo json_encode([
        'code' => ERROR_CODES['SERVER_ERROR'],
        'message' => '注销失败：' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
