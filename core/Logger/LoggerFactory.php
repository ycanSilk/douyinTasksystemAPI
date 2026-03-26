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
 * 新目录结构：logs/{log_type}/{date}/{log_type}.log
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
    public static function getLogBasePath(): string
    {
        if (self::$logBasePath === null) {
            // 尝试从配置文件加载
            self::loadConfig();
            
            // 如果配置文件中设置了路径，就使用配置的路径
            if (isset(self::$logConfig['base_path'])) {
                $basePathConfig = self::$logConfig['base_path'];
                
                // 根据配置的 system_type 选择路径
                $systemType = self::$logConfig['system_type'] ?? 'windows';
                
                if ($systemType === 'windows') {
                    self::$logBasePath = $basePathConfig['windows'] ?? __DIR__ . '/../../logs';
                } elseif ($systemType === 'linux') {
                    self::$logBasePath = $basePathConfig['linux'] ?? '/www/wwwroot/logs';
                } else {
                    // 使用默认路径
                    self::$logBasePath = $basePathConfig['default'] ?? __DIR__ . '/../../logs';
                }
            } else {
                // 没有配置文件，使用默认路径
                self::$logBasePath = __DIR__ . '/../../logs';
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
     * @param string $channel 日志通道（audit, request, error, sql, operation, access, cron）
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
            
            // 根据通道配置处理器
            switch ($channel) {
                case 'audit':
                    try {
                        // 新结构：logs/audit/{date}/audit.log
                        $handler = new RotatingFileHandler(
                            'audit',
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
                    try {
                        // 新结构：logs/request/{date}/request.log
                        $handler = new RotatingFileHandler(
                            'request',
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
                    try {
                        // 新结构：logs/error/{date}/error.log
                        $handler = new RotatingFileHandler(
                            'error',
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
                        try {
                            // 新结构：logs/sql/{date}/sql.log
                            $handler = new RotatingFileHandler(
                                'sql',
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
                    try {
                        // 新结构：logs/operation/{date}/operation.log
                        $handler = new RotatingFileHandler(
                            'operation',
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
                    try {
                        // 新结构：logs/access/{date}/access.log
                        $handler = new RotatingFileHandler(
                            'access',
                            30,
                            0644,
                            true
                        );
                        $logger->pushHandler(new AsyncHandler($handler, 100));
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory access handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                case 'cron':
                    try {
                        // 新结构：logs/cron/{date}/cron.log
                        $handler = new RotatingFileHandler(
                            'cron',
                            30,
                            0644,
                            true
                        );
                        $logger->pushHandler(new AsyncHandler($handler, 100));
                    } catch (\Throwable $e) {
                        error_log('LoggerFactory cron handler init failed: ' . $e->getMessage());
                    }
                    break;
                    
                default:
                    try {
                        // 默认：logs/error/default.log
                        $handler = new RotatingFileHandler(
                            'error',
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