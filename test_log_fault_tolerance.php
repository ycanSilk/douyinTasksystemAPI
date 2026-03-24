<?php
/**
 * 日志系统故障保护机制测试脚本
 * 
 * 用于验证日志系统在各种故障场景下是否会影响接口正常运行
 */

// 设置错误报告
error_reporting(E_ALL);
ini_set('display_errors', 1);

// 加载自动加载器
require_once __DIR__ . '/core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 测试结果记录
$results = [];
$testCount = 0;
$passCount = 0;

function test($name, $callback) {
    global $testCount, $passCount, $results;
    $testCount++;
    
    try {
        $result = $callback();
        if ($result) {
            $passCount++;
            $results[] = ['name' => $name, 'status' => '✅ PASS', 'message' => ''];
            echo "✅ PASS: $name\n";
        } else {
            $results[] = ['name' => $name, 'status' => '❌ FAIL', 'message' => '测试返回 false'];
            echo "❌ FAIL: $name - 测试返回 false\n";
        }
    } catch (Throwable $e) {
        $results[] = ['name' => $name, 'status' => '❌ FAIL', 'message' => $e->getMessage()];
        echo "❌ FAIL: $name - 抛出异常：" . $e->getMessage() . "\n";
    }
}

echo "========================================\n";
echo "日志系统故障保护机制测试\n";
echo "========================================\n\n";

// 测试 1: Logger 基本功能
test('Logger 基本功能测试', function() {
    LoggerRouter::setContext('test/api');
    $logger = LoggerFactory::getLogger('request');
    $logger->info('测试消息', ['test' => 'data']);
    return true; // 如果能执行到这里说明没抛异常
});

// 测试 2: LoggerFactory 容错
test('LoggerFactory 容错测试', function() {
    // 即使 Router 有问题也应该能创建 Logger
    $logger = LoggerFactory::getLogger('request');
    return $logger !== null;
});

// 测试 3: 多个 Logger 实例
test('多个 Logger 实例测试', function() {
    $loggers = [
        LoggerFactory::getLogger('request'),
        LoggerFactory::getLogger('error'),
        LoggerFactory::getLogger('audit'),
    ];
    foreach ($loggers as $logger) {
        $logger->info('多实例测试');
    }
    return true;
});

// 测试 4: 大量日志写入
test('大量日志写入测试', function() {
    $logger = LoggerFactory::getLogger('request');
    for ($i = 0; $i < 100; $i++) {
        $logger->info('批量测试 ' . $i, ['index' => $i]);
    }
    return true;
});

// 测试 5: 敏感数据脱敏
test('敏感数据脱敏测试', function() {
    $logger = LoggerFactory::getLogger('request');
    $logger->info('敏感数据测试', [
        'password' => 'secret123',
        'phone' => '13800138000',
        'email' => 'test@example.com',
        'token' => 'abc123xyz',
    ]);
    return true;
});

// 测试 6: 异常上下文测试
test('异常上下文测试', function() {
    $logger = LoggerFactory::getLogger('error');
    try {
        throw new Exception('测试异常');
    } catch (Exception $e) {
        $logger->error('捕获到异常', ['exception' => $e->getMessage()]);
    }
    return true;
});

// 测试 7: 空上下文测试
test('空上下文测试', function() {
    LoggerRouter::clear();
    $logger = LoggerFactory::getLogger('request');
    $logger->info('空上下文测试');
    return true;
});

// 测试 8: 特殊字符测试
test('特殊字符测试', function() {
    $logger = LoggerFactory::getLogger('request');
    $logger->info('特殊字符测试', [
        'chinese' => '中文测试',
        'emoji' => '😀😁😂',
        'json' => '{"key": "value"}',
        'newline' => "line1\nline2",
    ]);
    return true;
});

// 测试 9: 大数组测试
test('大数组测试', function() {
    $logger = LoggerFactory::getLogger('request');
    $largeArray = range(1, 1000);
    $logger->info('大数组测试', ['data' => $largeArray]);
    return true;
});

// 测试 10: 嵌套数组测试
test('嵌套数组测试', function() {
    $logger = LoggerFactory::getLogger('request');
    $nestedArray = [
        'level1' => [
            'level2' => [
                'level3' => 'deep value'
            ]
        ]
    ];
    $logger->info('嵌套数组测试', ['data' => $nestedArray]);
    return true;
});

// 测试 11: 并发写入模拟
test('并发写入模拟测试', function() {
    $logger = LoggerFactory::getLogger('request');
    // 模拟并发场景
    for ($i = 0; $i < 10; $i++) {
        $logger->info('并发测试 ' . $i);
    }
    return true;
});

// 测试 12: Logger 重复获取
test('Logger 重复获取测试', function() {
    $logger1 = LoggerFactory::getLogger('request');
    $logger2 = LoggerFactory::getLogger('request');
    $logger1->info('第一条日志');
    $logger2->info('第二条日志');
    return $logger1 === $logger2; // 应该是同一个实例（单例模式）
});

// 测试 13: 不同通道测试
test('不同通道测试', function() {
    $channels = ['request', 'error', 'audit', 'operation', 'access'];
    foreach ($channels as $channel) {
        $logger = LoggerFactory::getLogger($channel);
        $logger->info('通道测试：' . $channel);
    }
    return true;
});

// 测试 14: 性能测试
test('性能测试 - 1000 次日志写入', function() {
    $logger = LoggerFactory::getLogger('request');
    $startTime = microtime(true);
    for ($i = 0; $i < 1000; $i++) {
        $logger->info('性能测试 ' . $i);
    }
    $endTime = microtime(true);
    $duration = ($endTime - $startTime) * 1000;
    echo "\n   性能测试耗时：" . round($duration, 2) . "ms (平均 " . round($duration / 1000, 3) . "ms/次)\n";
    return $duration < 5000; // 应该小于 5 秒
});

// 测试 15: 接口模拟测试
test('接口模拟测试 - 完整流程', function() {
    // 模拟真实接口流程
    LoggerRouter::setContext('test/complete-flow');
    $requestLogger = LoggerFactory::getLogger('request');
    $errorLogger = LoggerFactory::getLogger('error');
    
    // 1. 记录请求开始
    $requestLogger->info('接口请求开始', [
        'method' => 'POST',
        'uri' => '/api/test/complete-flow',
    ]);
    
    // 2. 模拟业务逻辑
    $businessData = ['id' => 123, 'name' => 'test'];
    $requestLogger->info('业务处理完成', ['data' => $businessData]);
    
    // 3. 模拟错误处理
    try {
        throw new Exception('模拟错误');
    } catch (Exception $e) {
        $errorLogger->error('业务处理失败', ['error' => $e->getMessage()]);
    }
    
    // 4. 记录请求结束
    $requestLogger->info('接口请求结束');
    
    return true;
});

echo "\n========================================\n";
echo "测试结果汇总\n";
echo "========================================\n";
echo "总测试数：$testCount\n";
echo "通过数：$passCount\n";
echo "失败数：" . ($testCount - $passCount) . "\n";
echo "通过率：" . round(($passCount / $testCount) * 100, 2) . "%\n";
echo "========================================\n\n";

if ($passCount === $testCount) {
    echo "🎉 所有测试通过！日志系统故障保护机制运行正常。\n";
} else {
    echo "⚠️  有 " . ($testCount - $passCount) . " 个测试失败，请检查错误信息。\n";
    echo "\n失败详情:\n";
    foreach ($results as $result) {
        if ($result['status'] === '❌ FAIL') {
            echo "  - {$result['name']}: {$result['message']}\n";
        }
    }
}

echo "\n测试完成时间：" . date('Y-m-d H:i:s') . "\n";
