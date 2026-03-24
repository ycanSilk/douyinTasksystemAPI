<?php
/**
 * 调试日志系统
 */

require_once __DIR__ . '/core/Autoloader.php';

use Core\Logger\LoggerRouter;
use Core\Logger\LoggerFactory;

echo "========================================\n";
echo "  调试日志系统\n";
echo "========================================\n\n";

// 设置上下文
LoggerRouter::setContext('b/v1/tasks/list');
echo "✓ 已设置上下文\n\n";

// 获取日志前缀
$logPrefix = LoggerRouter::getLogPrefix();
echo "日志前缀：$logPrefix\n\n";

// 获取日志基础路径
$reflection = new ReflectionClass(LoggerFactory::class);
$method = $reflection->getMethod('getLogBasePath');
$method->setAccessible(true);
$logBasePath = $method->invoke(null);
echo "日志基础路径：$logBasePath\n\n";

// 构建日志文件路径
$requestLogPath = $logBasePath . '/request/' . str_replace('/', '-', $logPrefix) . '/log.log';
$errorLogPath = $logBasePath . '/error/' . str_replace('/', '-', $logPrefix) . '/log.log';

echo "请求日志路径：$requestLogPath\n";
echo "错误日志路径：$errorLogPath\n\n";

// 检查目录是否存在
$requestLogDir = dirname($requestLogPath);
echo "请求日志目录：$requestLogDir\n";
echo "目录是否存在：" . (is_dir($requestLogDir) ? '是' : '否') . "\n\n";

// 尝试手动创建目录
if (!is_dir($requestLogDir)) {
    echo "尝试创建目录...\n";
    if (@mkdir($requestLogDir, 0755, true)) {
        echo "✓ 目录创建成功\n";
    } else {
        echo "✗ 目录创建失败\n";
    }
}

// 获取日志实例
echo "\n获取日志实例...\n";
$requestLogger = LoggerFactory::getLogger('request');
echo "✓ request logger 已获取\n";

// 记录日志
echo "\n记录日志...\n";
$requestLogger->info('测试日志', ['test' => 'data']);
echo "✓ 日志已记录\n";

// 等待异步处理器完成
echo "\n等待异步处理器完成...\n";
sleep(1);

// 检查日志文件
echo "\n检查日志文件...\n";
if (file_exists($requestLogPath)) {
    echo "✓ 日志文件已创建：$requestLogPath\n";
    $content = file_get_contents($requestLogPath);
    echo "日志内容:\n$content\n";
} else {
    echo "✗ 日志文件未创建\n";
    
    // 检查父目录
    $parentDir = dirname($requestLogPath);
    echo "\n检查父目录：$parentDir\n";
    if (is_dir($parentDir)) {
        echo "父目录存在\n";
        $files = scandir($parentDir);
        echo "目录内容：" . json_encode($files) . "\n";
    } else {
        echo "父目录不存在\n";
    }
}
