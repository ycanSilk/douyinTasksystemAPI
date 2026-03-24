<?php
/**
 * 日志系统使用示例
 * 
 * 演示如何使用统一日志系统记录各种类型的日志
 */

// 加载自动加载器
require_once __DIR__ . '/../core/Autoloader.php';

use Core\Logger\LoggerFactory;

// 初始化日志系统（可选，默认使用 /www/wwwlogs）
LoggerFactory::init(__DIR__ . '/../logs');

// 获取不同通道的日志实例
$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');
$sqlLogger = LoggerFactory::getLogger('sql');
$operationLogger = LoggerFactory::getLogger('operation');
$accessLogger = LoggerFactory::getLogger('access');

// ============================================
// 1. 记录请求日志
// ============================================
$requestLogger->info('API 请求', [
    'user_id' => 137,
    'user_type' => 'C',
    'ip' => '34.143.229.197',
    'method' => 'POST',
    'endpoint' => '/api/c/v1/tasks/accept',
    'b_task_id' => 250,
]);

// ============================================
// 2. 记录审计日志（关键业务操作）
// ============================================
$auditLogger->notice('用户接单成功', [
    'user_id' => 137,
    'user_type' => 'C',
    'b_task_id' => 250,
    'record_id' => 120,
    'reward_amount' => 100, // 分
]);

// ============================================
// 3. 记录错误日志
// ============================================
try {
    // 模拟错误
    throw new Exception('数据库连接失败');
} catch (Exception $e) {
    $errorLogger->error('接单失败', [
        'user_id' => 137,
        'b_task_id' => 250,
        'exception' => $e->getMessage(),
        'trace' => $e->getTraceAsString(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
}

// ============================================
// 4. 记录 SQL 日志（仅开发环境）
// ============================================
$sqlLogger->debug('SQL 查询', [
    'sql' => 'SELECT * FROM c_users WHERE id = ?',
    'params' => [137],
    'execution_time' => '0.023s',
]);

// ============================================
// 5. 记录运维日志
// ============================================
$operationLogger->info('定时任务执行', [
    'script' => 'task_check.php',
    'pid' => getmypid(),
    'action' => '检查过期任务',
    'total' => 5,
    'success' => 3,
    'fail' => 2,
]);

// ============================================
// 6. 记录访问日志
// ============================================
$accessLogger->info('用户登录', [
    'user_id' => 137,
    'user_type' => 'C',
    'ip' => '34.143.229.197',
    'device_id' => 'device_abc123',
    'login_result' => 'success',
]);

// ============================================
// 7. 敏感信息自动脱敏
// ============================================
$auditLogger->notice('用户注册', [
    'user_id' => 138,
    'username' => 'testuser',
    'password' => 'secret123', // 会自动脱敏为 ***
    'phone' => '13800138000', // 会自动脱敏为 138****8000
    'email' => 'test@example.com', // 会自动脱敏为 t***@example.com
]);

// ============================================
// 8. 不同级别的日志
// ============================================
$requestLogger->debug('调试信息', ['step' => '开始处理']);
$requestLogger->info('一般信息', ['action' => '处理完成']);
$requestLogger->warning('警告信息', ['issue' => '参数异常']);
$requestLogger->error('错误信息', ['error' => '操作失败']);
$requestLogger->critical('严重错误', ['error' => '系统崩溃']);

echo "日志记录完成！请查看 logs/ 目录下的日志文件。\n";
