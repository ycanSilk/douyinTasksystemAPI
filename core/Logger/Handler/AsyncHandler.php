<?php
namespace Core\Logger\Handler;

/**
 * 异步处理器
 * 
 * 将日志先放入队列，批量写入，提高性能
 * 
 * @package Core\Logger\Handler
 */
class AsyncHandler
{
    /**
     * @var mixed 内部处理器
     */
    private $handler;
    
    /**
     * @var int 队列限制
     */
    private int $queueLimit;
    
    /**
     * @var array 日志队列
     */
    private array $queue = [];
    
    /**
     * @var array 是否使用 JSON 格式的队列
     */
    private array $useJsonFormatQueue = [];
    
    /**
     * 构造函数
     * 
     * @param mixed $handler 内部处理器
     * @param int $queueLimit 队列限制（默认 100）
     */
    public function __construct($handler, int $queueLimit = 100)
    {
        $this->handler = $handler;
        $this->queueLimit = $queueLimit;
        
        // 注册 shutdown 函数，确保脚本结束时刷新队列
        register_shutdown_function([$this, 'flush']);
    }
    
    /**
     * 处理日志记录（先放入队列）
     * 
     * @param array $record 日志记录
     * @param bool $useJsonFormat 是否使用 JSON 格式（默认 true）
     * @return void
     */
    public function handle(array $record, bool $useJsonFormat = true): void
    {
        try {
            $this->queue[] = $record;
            $this->useJsonFormatQueue[] = $useJsonFormat;
            
            // 队列满了就刷新
            if (count($this->queue) >= $this->queueLimit) {
                $this->flush();
            }
        } catch (\Throwable $e) {
            error_log('AsyncHandler handle failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 刷新队列（写入所有日志）
     * 
     * @return void
     */
    public function flush(): void
    {
        if (empty($this->queue)) {
            return;
        }
        
        try {
            foreach ($this->queue as $index => $record) {
                try {
                    $useJsonFormat = $this->useJsonFormatQueue[$index] ?? true;
                    $this->handler->handle($record, $useJsonFormat);
                } catch (\Throwable $e) {
                    error_log('AsyncHandler flush handler failed: ' . $e->getMessage());
                }
            }
            
            $this->queue = [];
            $this->useJsonFormatQueue = [];
        } catch (\Throwable $e) {
            error_log('AsyncHandler flush failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 析构时刷新
     */
    public function __destruct()
    {
        $this->flush();
    }
}
