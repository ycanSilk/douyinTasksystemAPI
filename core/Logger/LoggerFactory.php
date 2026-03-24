<?php
namespace Core\Logger;

use Core\Logger\Handler\FileHandler;
use Core\Logger\Handler\RotatingFileHandler;
use Core\Logger\Handler\AsyncHandler;
use Core\Logger\Processor\SensitiveDataProcessor;

/**
 * 日志工厂
 * 
 * 单例模式，负责创建和管理各种日志通道的 Logger 实例
 * 
 * @package Core\Logger
 */
class LoggerFactory
{
    /**
     * @var array Logger 实例缓存
     */
    private static array $loggers = [];
    
    /**
     * @var string|null 日志基础路径
     */
    private static ?string $logBasePath = null;
    
    /**
     * @var bool 是否已初始化
     */
    private static bool $initialized = false;
    
    /**
     * @var array 日志配置
     */
    private static array $logConfig = [];
    
    /**
     * 获取日志基础路径（自动检测环境）
     * 
     * @return string 日志基础路径
     */
    private static function getLogBasePath(): string
    {
        if (self::$logBasePath === null) {
            // 尝试从配置文件加载
            self::loadConfig();
            
            // 如果配置文件中设置了路径，就使用配置的路径
            if (isset(self::$logConfig['base_path'])) {
                $basePathConfig = self::$logConfig['base_path'];
                
                // 如果启用了自动检测
                if (!empty($basePathConfig['auto_detect'])) {
                    // 根据操作系统选择路径
                    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
                        self::$logBasePath = $basePathConfig['windows'] ?? __DIR__ . '/../../logs';
                    } else {
                        self::$logBasePath = $basePathConfig['linux'] ?? '/www/wwwlogs';
                    }
                } else {
                    // 使用默认路径（不区分系统）
                    self::$logBasePath = $basePathConfig['default'] ?? __DIR__ . '/../../logs';
                }
            } else {
                // 没有配置文件，自动检测
                if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
                    self::$logBasePath = __DIR__ . '/../../logs';
                } else {
                    self::$logBasePath = '/www/wwwlogs';
                }
            }
        }
        
        return self::$logBasePath;
    }
    
    /**
     * 加载日志配置文件
     * 
     * @return void
     */
    private static function loadConfig(): void
    {
        if (!empty(self::$logConfig)) {
            return;
        }
        
        try {
            $configFile = __DIR__ . '/../../config/api_log_mapping.json';
            if (file_exists($configFile)) {
                $config = json_decode(file_get_contents($configFile), true);
                if (json_last_error() === JSON_ERROR_NONE && isset($config['_log_config'])) {
                    self::$logConfig = $config['_log_config'];
                }
            }
        } catch (\Throwable $e) {
            // 配置加载失败不影响日志系统
            error_log('LoggerFactory loadConfig failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 设置日志基础路径
     * 
     * @param string $path 日志基础路径
     * @return void
     */
    public static function setLogBasePath(string $path): void
    {
        self::$logBasePath = $path;
    }
    
    /**
     * 获取日志实例
     * 
     * @param string $channel 日志通道（audit, request, error, sql, operation, access）
     * @return Logger Logger 实例
     */
    public static function getLogger(string $channel): Logger
    {
        try {
            if (isset(self::$loggers[$channel])) {
                return self::$loggers[$channel];
            }
            
            $logger = new Logger($channel, self::getLogBasePath());
            
            // 添加敏感信息脱敏处理器
            try {
                $logger->pushProcessor(new SensitiveDataProcessor());
            } catch (\Throwable $e) {
                error_log('LoggerFactory processor init failed: ' . $e->getMessage());
            }
            
            // 获取当前接口上下文
            $apiContext = '';
            try {
                $fullPrefix = LoggerRouter::getLogPrefix();
                // 提取 apiContext（去掉第一个部分）
                $parts = explode('/', $fullPrefix);
                if (count($parts) >= 2) {
                    $apiContext = implode('/', array_slice($parts, 1));
                } else {
                    $apiContext = $fullPrefix;
                }
            } catch (\Throwable $e) {
                error_log('LoggerRouter getContext failed: ' . $e->getMessage());
            }
            
            // 根据通道配置处理器
            switch ($channel) {
                case 'audit':
                    $logPath = $apiContext ? 
                        'logs/audit/' . $apiContext . '/log.log' :
                        'logs/audit/audit.log';
                    try {
                        $handler = new RotatingFileHandler(
                            $logPath,
                            365,
                            0644,
                            true
                        );
                        $logger->pushHandler(new AsyncHandler($handler, 50));
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory audit handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                case 'request':
                    $logPath = $apiContext ? 
                        'logs/request/' . $apiContext . '/log.log' :
                        'logs/request/request.log';
                    try {
                        $handler = new RotatingFileHandler(
                            $logPath,
                            30,
                            0644,
                            true
                        );
                        $logger->pushHandler(new AsyncHandler($handler, 100));
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory request handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                case 'error':
                    $logPath = $apiContext ? 
                        'logs/error/' . $apiContext . '/log.log' :
                        'logs/error/error.log';
                    try {
                        $handler = new RotatingFileHandler(
                            $logPath,
                            90,
                            0644,
                            true
                        );
                        $logger->pushHandler($handler);
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory error handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                case 'sql':
                    if (self::isDevelopment()) {
                        $logPath = $apiContext ? 
                            'logs/sql/' . $apiContext . '/log.log' :
                            'logs/sql/sql.log';
                        try {
                            $handler = new RotatingFileHandler(
                                $logPath,
                                7,
                                0644,
                                true
                            );
                            $logger->pushHandler(new AsyncHandler($handler, 200));
                        } catch (\Throwable $e) {
                            error_log('LoggerFactory sql handler init failed: ' . $e->getMessage());
                        }
                    }
                    break;
                    
                case 'operation':
                    $logPath = $apiContext ? 
                        'logs/operation/' . $apiContext . '/log.log' :
                        'logs/operation/operation.log';
                    try {
                        $handler = new RotatingFileHandler(
                            $logPath,
                            90,
                            0644,
                            true
                        );
                        $logger->pushHandler(new AsyncHandler($handler, 50));
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory operation handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                case 'access':
                    $logPath = $apiContext ? 
                        'logs/access/' . $apiContext . '/log.log' :
                        'logs/access/access.log';
                    try {
                        $handler = new RotatingFileHandler(
                            $logPath,
                            30,
                            0644,
                            true
                        );
                        $logger->pushHandler(new AsyncHandler($handler, 100));
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory access handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                default:
                    try {
                        $handler = new RotatingFileHandler(
                            'logs/error/default.log',
                            30,
                            0644,
                            true
                        );
                        $logger->pushHandler($handler);
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory default handler init failed: ' . $e->getMessage());
                    }
            }
            
            self::$loggers[$channel] = $logger;
            return $logger;
        } catch (\Throwable $e) {
            // 极端情况下，返回一个空的 Logger 避免接口崩溃
            error_log('LoggerFactory getLogger failed: ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine());
            return new Logger($channel, self::getLogBasePath());
        }
    }
    
    /**
     * 判断是否开发环境
     * 
     * @return bool
     */
    private static function isDevelopment(): bool
    {
        // 通过环境变量或服务器地址判断
        return ($_ENV['APP_ENV'] ?? '') === 'development'
            || ($_SERVER['SERVER_ADDR'] ?? '') === '127.0.0.1'
            || ($_SERVER['HTTP_HOST'] ?? '') === 'localhost';
    }
    
    /**
     * 初始化日志系统
     * 
     * @param string|null $logBasePath 日志基础路径（可选，不传则从配置文件加载）
     * @return void
     */
    public static function init(?string $logBasePath = null): void
    {
        if (self::$initialized) {
            return;
        }
        
        if ($logBasePath !== null) {
            self::$logBasePath = $logBasePath;
        }
        self::$initialized = true;
    }
    
    /**
     * 获取所有已创建的 Logger 实例
     * 
     * @return array
     */
    public static function getAllLoggers(): array
    {
        return self::$loggers;
    }
    
    /**
     * 清空所有 Logger 实例（用于测试）
     * 
     * @return void
     */
    public static function clearLoggers(): void
    {
        self::$loggers = [];
        self::$initialized = false;
        self::$logBasePath = null;
        self::$logConfig = [];
    }
    
    /**
     * 获取当前日志配置
     * 
     * @return array
     */
    public static function getLogConfig(): array
    {
        return self::$logConfig;
    }
}
