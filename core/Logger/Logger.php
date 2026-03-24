<?php
namespace Core\Logger;

/**
 * 日志记录器实现类
 * 
 * 提供统一的日志记录功能，支持多个处理器和日志级别
 * 
 * @package Core\Logger
 */
class Logger implements LoggerInterface
{
    /**
     * @var string 日志通道名称
     */
    private string $channel;
    
    /**
     * @var array 日志处理器数组
     */
    private array $handlers = [];
    
    /**
     * @var array 日志处理器数组
     */
    private array $processors = [];
    
    /**
     * @var string 日志基础路径
     */
    private string $logBasePath;
    
    /**
     * 构造函数
     * 
     * @param string $channel 日志通道名称（audit, request, error, sql, operation, access）
     * @param string $logBasePath 日志基础路径
     */
    public function __construct(string $channel, string $logBasePath = '/www/wwwlogs')
    {
        $this->channel = $channel;
        $this->logBasePath = $logBasePath;
    }
    
    /**
     * 添加处理器
     * 
     * @param mixed $handler 日志处理器实例
     * @return self
     */
    public function pushHandler($handler): self
    {
        array_unshift($this->handlers, $handler);
        return $this;
    }
    
    /**
     * 移除并返回第一个处理器
     * 
     * @return mixed|null
     */
    public function popHandler()
    {
        return array_shift($this->handlers);
    }
    
    /**
     * 添加处理器
     * 
     * @param callable $processor 处理器回调函数
     * @return self
     */
    public function pushProcessor(callable $processor): self
    {
        array_unshift($this->processors, $processor);
        return $this;
    }
    
    /**
     * 记录日志（实现接口）
     * 
     * @param int $level 日志级别
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function log(int $level, string $message, array $context = []): void
    {
        try {
            if (empty($this->handlers)) {
                return;
            }
            
            $record = [
                'timestamp' => date('c'),
                'datetime' => new \DateTime(),
                'channel' => $this->channel,
                'level' => $level,
                'level_name' => $this->getLevelName($level),
                'message' => $message,
                'context' => $context,
                'extra' => $this->getDefaultExtra(),
            ];
            
            // 应用处理器
            foreach ($this->processors as $processor) {
                try {
                    $record = $processor($record);
                } catch (\Throwable $e) {
                    // 处理器失败不影响主流程
                    error_log('Logger processor failed: ' . $e->getMessage());
                }
            }
            
            // 写入所有处理器
            foreach ($this->handlers as $handler) {
                try {
                    $handler->handle($record);
                } catch (\Throwable $e) {
                    // 单个处理器失败不影响其他处理器
                    error_log('Logger handler failed: ' . $e->getMessage());
                }
            }
        } catch (\Throwable $e) {
            // 日志系统失败绝对不能影响主流程
            // 使用最基础的 error_log 记录日志系统自身错误
            error_log('Logger system failed: ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine());
        }
    }
    
    /**
     * 获取日志级别名称
     * 
     * @param int $level 日志级别
     * @return string
     */
    private function getLevelName(int $level): string
    {
        $levels = [
            self::DEBUG => 'DEBUG',
            self::INFO => 'INFO',
            self::NOTICE => 'NOTICE',
            self::WARNING => 'WARNING',
            self::ERROR => 'ERROR',
            self::CRITICAL => 'CRITICAL',
            self::ALERT => 'ALERT',
            self::EMERGENCY => 'EMERGENCY',
        ];
        return $levels[$level] ?? 'UNKNOWN';
    }
    
    /**
     * 获取默认额外信息
     * 
     * @return array
     */
    private function getDefaultExtra(): array
    {
        $extra = [
            'memory_usage' => round(memory_get_usage(true) / 1024 / 1024, 2) . 'MB',
            'server' => gethostname() ?? 'unknown',
        ];
        
        // 如果在 Web 环境，添加更多上下文
        if (isset($_SERVER['REQUEST_URI'])) {
            $extra['request_uri'] = $_SERVER['REQUEST_URI'] ?? '';
            $extra['request_method'] = $_SERVER['REQUEST_METHOD'] ?? '';
        }
        
        // 添加调用者信息（跳过 Logger 自身）
        $backtrace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 3);
        if (isset($backtrace[2])) {
            $extra['file'] = basename($backtrace[2]['file'] ?? '');
            $extra['line'] = $backtrace[2]['line'] ?? 0;
        }
        
        return $extra;
    }
    
    /**
     * 记录调试日志
     */
    public function debug(string $message, array $context = []): void
    {
        $this->log(self::DEBUG, $message, $context);
    }
    
    /**
     * 记录信息日志
     */
    public function info(string $message, array $context = []): void
    {
        $this->log(self::INFO, $message, $context);
    }
    
    /**
     * 记录通知日志
     */
    public function notice(string $message, array $context = []): void
    {
        $this->log(self::NOTICE, $message, $context);
    }
    
    /**
     * 记录警告日志
     */
    public function warning(string $message, array $context = []): void
    {
        $this->log(self::WARNING, $message, $context);
    }
    
    /**
     * 记录错误日志
     */
    public function error(string $message, array $context = []): void
    {
        $this->log(self::ERROR, $message, $context);
    }
    
    /**
     * 记录严重错误日志
     */
    public function critical(string $message, array $context = []): void
    {
        $this->log(self::CRITICAL, $message, $context);
    }
    
    /**
     * 记录警报日志
     */
    public function alert(string $message, array $context = []): void
    {
        $this->log(self::ALERT, $message, $context);
    }
    
    /**
     * 记录紧急日志
     */
    public function emergency(string $message, array $context = []): void
    {
        $this->log(self::EMERGENCY, $message, $context);
    }
}
