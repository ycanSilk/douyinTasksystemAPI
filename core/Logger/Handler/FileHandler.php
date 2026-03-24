<?php
namespace Core\Logger\Handler;

/**
 * 文件处理器
 * 
 * 将日志写入到文件
 * 
 * @package Core\Logger\Handler
 */
class FileHandler
{
    /**
     * @var string 日志文件路径
     */
    protected string $filePath;
    
    /**
     * @var int 文件权限
     */
    protected int $filePermission;
    
    /**
     * @var bool 是否使用文件锁
     */
    protected bool $useLocking;
    
    /**
     * 构造函数
     * 
     * @param string $filePath 日志文件路径
     * @param int $filePermission 文件权限（默认 0644）
     * @param bool $useLocking 是否使用文件锁（默认 true）
     */
    public function __construct(
        string $filePath,
        int $filePermission = 0644,
        bool $useLocking = true
    ) {
        $this->filePath = $filePath;
        $this->filePermission = $filePermission;
        $this->useLocking = $useLocking;
        
        // 确保目录存在
        try {
            $dir = dirname($filePath);
            if (!is_dir($dir)) {
                if (!@mkdir($dir, 0755, true)) {
                    error_log('Failed to create log directory: ' . $dir);
                }
            }
        } catch (\Throwable $e) {
            error_log('FileHandler constructor failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 处理日志记录
     * 
     * @param array $record 日志记录
     * @return void
     */
    public function handle(array $record): void
    {
        $formatted = $this->format($record);
        $this->write($formatted);
    }
    
    /**
     * 格式化日志记录为 JSON
     * 
     * @param array $record 日志记录
     * @return string 格式化后的日志
     */
    protected function format(array $record): string
    {
        // 移除不能序列化的对象
        $record = $this->normalize($record);
        
        return json_encode($record, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . PHP_EOL;
    }
    
    /**
     * 写入文件
     * 
     * @param string $formatted 格式化后的日志
     * @return void
     */
    protected function write(string $formatted): void
    {
        try {
            $resource = @fopen($this->filePath, 'a');
            if ($resource === false) {
                error_log('Failed to open log file: ' . $this->filePath);
                return;
            }
            
            if ($this->useLocking) {
                if (!@flock($resource, LOCK_EX)) {
                    error_log('Failed to lock log file: ' . $this->filePath);
                }
            }
            
            if (@fwrite($resource, $formatted) === false) {
                error_log('Failed to write to log file: ' . $this->filePath);
            }
            
            if ($this->useLocking) {
                @flock($resource, LOCK_UN);
            }
            
            @fclose($resource);
        } catch (\Throwable $e) {
            error_log('FileHandler write failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 标准化数据（移除不能序列化的对象）
     * 
     * @param mixed $data 原始数据
     * @return mixed 标准化后的数据
     */
    protected function normalize($data)
    {
        if (is_array($data)) {
            foreach ($data as $key => $value) {
                if (is_object($value) && !$value instanceof \DateTimeInterface) {
                    // 对象转换为字符串
                    $data[$key] = method_exists($value, '__toString') 
                        ? (string)$value 
                        : get_class($value) . ' Object';
                } elseif (is_array($value)) {
                    $data[$key] = $this->normalize($value);
                }
            }
        }
        
        return $data;
    }
}
