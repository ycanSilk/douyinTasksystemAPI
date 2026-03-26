<?php
namespace Core\Logger\Handler;

/**
 * 文件处理器
 * 
 * 将日志写入到文件
 * 默认使用行内输出格式
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
     * @param bool $useJsonFormat 是否使用 JSON 格式（默认 false，使用行内格式）
     * @return void
     */
    public function handle(array $record, bool $useJsonFormat = false): void
    {
        if ($useJsonFormat) {
            // JSON 格式：数据日志（有 context）
            $formatted = $this->formatJson($record);
        } else {
            // 行内格式：信息日志（默认）
            $formatted = $this->formatLine($record);
        }
        
        $this->write($formatted);
    }
    
    /**
     * 格式化为行内输出格式
     * 
     * 示例格式：
     * [2026-03-24 11:20:23.411] POST_SUCCESS /b/v1/auth/login.php - {"code":0,"message":"登录成功"}
     * [Tue Mar 24 14:00:27 2026] [B端通知列表] 请求开始 - /api/b/v1/notifications/list.php
     * 
     * @param array $record 日志记录
     * @return string 行内格式的日志
     */
    protected function formatLine(array $record): string
    {
        try {
            // 获取时间戳（带毫秒）
            $timestamp = $this->getTimestamp($record);
            
            // 获取日志级别名称
            $levelName = $this->getLevelName($record['level'] ?? 200);
            
            // 获取消息
            $message = $record['message'] ?? '';
            
            // 获取通道名称
            $channel = $record['channel'] ?? '';
            
            // 构建基础格式：[timestamp] [channel] [level] message
            $formatted = "[{$timestamp}]";
            
            // 如果有通道名称，添加通道
            if (!empty($channel)) {
                $formatted .= " [{$channel}]";
            }
            
            // 添加日志级别
            $formatted .= " {$levelName} {$message}";
            
            // 如果有 context 数据，添加到行尾
            if (!empty($record['context'] ?? [])) {
                $contextJson = json_encode($record['context'], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
                if ($contextJson !== false) {
                    $formatted .= " - {$contextJson}";
                }
            }
            
            // 如果有 extra 信息，添加到行尾
            if (!empty($record['extra'] ?? [])) {
                $extraParts = [];
                foreach ($record['extra'] as $key => $value) {
                    if ($key !== 'memory_usage' && $key !== 'server') {
                        $extraParts[] = "{$key}: {$value}";
                    }
                }
                if (!empty($extraParts)) {
                    $formatted .= ' - ' . implode(', ', $extraParts);
                }
            }
            
            return $formatted . PHP_EOL;
        } catch (\Throwable $e) {
            error_log('FileHandler formatLine failed: ' . $e->getMessage());
            return date('Y-m-d H:i:s') . ' [ERROR] Failed to format log record: ' . $e->getMessage() . PHP_EOL;
        }
    }
    
    /**
     * 获取时间戳（带毫秒）
     * 
     * @param array $record 日志记录
     * @return string 时间戳字符串
     */
    protected function getTimestamp(array $record): string
    {
        try {
            // 尝试从 record 中获取 datetime 对象
            if (isset($record['datetime']) && $record['datetime'] instanceof \DateTimeInterface) {
                return $record['datetime']->format('Y-m-d H:i:s.v');
            }
            
            // 尝试从 record 中获取 timestamp
            if (isset($record['timestamp'])) {
                $timestamp = $record['timestamp'];
                if (is_numeric($timestamp)) {
                    // 毫秒时间戳
                    if ($timestamp > 1000000000000) {
                        $microseconds = $timestamp % 1000;
                        $seconds = floor($timestamp / 1000);
                        return date('Y-m-d H:i:s', $seconds) . '.' . sprintf('%03d', $microseconds);
                    }
                    // 秒时间戳
                    return date('Y-m-d H:i:s.v', $timestamp);
                }
                // 字符串时间戳
                return $timestamp;
            }
            
            // 默认使用当前时间
            $microtime = microtime(true);
            $microseconds = sprintf('%03d', ($microtime - floor($microtime)) * 1000);
            return date('Y-m-d H:i:s', (int)$microtime) . '.' . $microseconds;
        } catch (\Throwable $e) {
            return date('Y-m-d H:i:s');
        }
    }
    
    /**
     * 获取日志级别名称
     * 
     * @param int $level 日志级别
     * @return string
     */
    protected function getLevelName(int $level): string
    {
        $levels = [
            10 => 'DEBUG',
            20 => 'INFO',
            30 => 'NOTICE',
            40 => 'WARNING',
            50 => 'ERROR',
            60 => 'CRITICAL',
            70 => 'ALERT',
            80 => 'EMERGENCY',
        ];
        return $levels[$level] ?? 'UNKNOWN';
    }
    
    /**
     * 格式化日志记录为 JSON
     * 
     * @param array $record 日志记录
     * @return string JSON 格式的日志
     */
    protected function formatJson(array $record): string
    {
        try {
            // 标准化数据（移除不能序列化的对象）
            $record = $this->normalize($record);
            
            // 移除 datetime 对象（已经转换为 timestamp）
            unset($record['datetime']);
            
            // 格式化为 JSON
            $json = json_encode($record, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
            
            if ($json === false) {
                error_log('Failed to encode log record: ' . json_last_error_msg());
                return json_encode([
                    'timestamp' => date('c'),
                    'channel' => $record['channel'] ?? 'unknown',
                    'level' => $record['level'] ?? 200,
                    'level_name' => $record['level_name'] ?? 'UNKNOWN',
                    'message' => 'Failed to encode log record',
                ], JSON_UNESCAPED_UNICODE);
            }
            
            return $json . PHP_EOL;
        } catch (\Throwable $e) {
            error_log('FileHandler formatJson failed: ' . $e->getMessage());
            return json_encode([
                'timestamp' => date('c'),
                'channel' => 'error',
                'level' => 500,
                'level_name' => 'ERROR',
                'message' => 'Failed to format log record: ' . $e->getMessage(),
            ], JSON_UNESCAPED_UNICODE) . PHP_EOL;
        }
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