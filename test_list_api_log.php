<?php
/**
 * 测试 b/v1/tasks/list 接口的日志系统
 */

// 模拟接口调用环境
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['HTTP_X_FORWARDED_FOR'] = '127.0.0.1';
$_SERVER['REQUEST_URI'] = '/api/b/v1/tasks/list?status=1';

// 加载统一日志系统
require_once __DIR__ . '/core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

echo "========================================\n";
echo "  测试 b/v1/tasks/list 接口日志系统\n";
echo "========================================\n\n";

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/tasks/list');
echo "✓ 已设置上下文：b/v1/tasks/list\n";

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
echo "✓ 已获取日志实例：request, error\n\n";

// 记录请求开始
echo "开始记录日志...\n";
$requestLogger->info('=== B 端任务列表请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);
echo "✓ 已记录请求开始日志\n";

// 记录请求参数
$requestLogger->debug('请求参数', [
    'status' => 1,
    'page' => 1,
    'page_size' => 20,
    'offset' => 0
]);
echo "✓ 已记录请求参数日志\n";

// 记录业务操作
$requestLogger->info('任务列表获取成功', [
    'total' => 50,
    'page' => 1,
    'page_size' => 20,
    'returned_count' => 20
]);
echo "✓ 已记录业务操作日志\n\n";

// 测试错误日志
echo "测试错误日志...\n";
$errorLogger->error('这是一个测试错误', [
    'message' => '测试错误信息',
    'file' => __FILE__,
    'line' => __LINE__,
]);
echo "✓ 已记录错误日志\n\n";

// 检查日志文件是否创建
echo "检查日志文件...\n";
$logBasePath = __DIR__ . '/logs';
$requestLogFile = $logBasePath . '/request/b-v1-tasks-list/' . date('Y-m-d') . '/log.log';
$errorLogFile = $logBasePath . '/error/b-v1-tasks-list/' . date('Y-m-d') . '/log.log';

echo "\n请求日志文件：$requestLogFile\n";
if (file_exists($requestLogFile)) {
    echo "✓ 请求日志文件已创建\n";
    $content = file_get_contents($requestLogFile);
    $lines = explode("\n", trim($content));
    echo "✓ 日志条数：" . count($lines) . " 条\n";
    echo "\n最新日志内容（最后 3 条）:\n";
    echo str_repeat("-", 80) . "\n";
    foreach (array_slice($lines, -3) as $line) {
        echo $line . "\n";
    }
    echo str_repeat("-", 80) . "\n";
} else {
    echo "✗ 请求日志文件未创建\n";
}

echo "\n错误日志文件：$errorLogFile\n";
if (file_exists($errorLogFile)) {
    echo "✓ 错误日志文件已创建\n";
    $content = file_get_contents($errorLogFile);
    $lines = explode("\n", trim($content));
    echo "✓ 日志条数：" . count($lines) . " 条\n";
} else {
    echo "✗ 错误日志文件未创建\n";
}

echo "\n";
echo "========================================\n";
echo "  测试完成！\n";
echo "========================================\n";
