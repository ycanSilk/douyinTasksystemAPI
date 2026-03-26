<?php
namespace Core\Logger\Handler;

use Core\Logger\LoggerFactory;

/**
 * 轮转文件处理器
 * 
 * 按日期自动轮转日志文件，支持保留指定数量的文件
 * 新目录结构：logs/{log_type}/{date}/{log_type}.log
 * 例如：logs/audit/20260324/audit.log
 * 
 * @package Core\Logger\Handler
 */
class RotatingFileHandler extends FileHandler
{
    /**
     * @var int 最大保留文件数量（天数）
     */
    private int $maxFiles;
    
    /**
     * @var string 日志类型（audit, request, error, sql, operation, access）
     */
    private string $logType;
    
    /**
     * 构造函数
     * 
     * @param string $logType 日志类型（audit, request, error, sql, operation, access）
     * @param int $maxFiles 最大保留文件数量（天数）
     * @param int $filePermission 文件权限
     * @param bool $useLocking 是否使用文件锁
     */
    public function __construct(
        string $logType,
        int $maxFiles = 30,
        int $filePermission = 0644,
        bool $useLocking = true
    ) {
        $this->maxFiles = $maxFiles;
        $this->logType = $logType;
        
        // 生成带日期的文件名：logs/{log_type}/{date}/{log_type}.log
        $filename = $this->getTimedFilename($logType);
        parent::__construct($filename, $filePermission, $useLocking);
    }
    
    /**
     * 获取带时间戳的文件名
     * 
     * 新目录结构：logs/{log_type}/{date}/{log_type}.log
     * 例如：logs/audit/20260324/audit.log
     * 
     * @param string $logType 日志类型
     * @return string 带日期的完整路径
     */
    private function getTimedFilename(string $logType): string
    {
        try {
            // 获取日志基础路径
            $logBasePath = LoggerFactory::getLogBasePath();
            
            // 日期格式：20260324（无横杠，更简洁）
            $date = date('Ymd');
            
            // 构建路径：logs/{log_type}/{date}/{log_type}.log
            $path = $logBasePath . DIRECTORY_SEPARATOR . $logType . DIRECTORY_SEPARATOR . $date . DIRECTORY_SEPARATOR . $logType . '.log';
            
            // 确保目录存在
            $dir = dirname($path);
            if (!is_dir($dir)) {
                if (!@mkdir($dir, 0755, true)) {
                    $error = error_get_last();
                    error_log('Failed to create log directory: ' . $dir . ' - Error: ' . ($error['message'] ?? 'Unknown'));
                    return $path;
                }
            }
            
            return $path;
        } catch (\Throwable $e) {
            error_log('RotatingFileHandler getTimedFilename failed: ' . $e->getMessage());
            return $logType . '.log';
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
        parent::handle($record, $useJsonFormat);
        
        try {
            // 清理旧日志文件
            $this->rotate();
        } catch (\Throwable $e) {
            error_log('RotatingFileHandler rotate failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 轮转日志文件（删除超过保留天数的旧日志）
     * 
     * @return void
     */
    private function rotate(): void
    {
        try {
            // 获取日志基础路径
            $logBasePath = LoggerFactory::getLogBasePath();
            
            // 日志类型目录：logs/{log_type}
            $typeDir = $logBasePath . DIRECTORY_SEPARATOR . $this->logType;
            
            if (!is_dir($typeDir)) {
                return;
            }
            
            // 获取所有日期目录
            $dateDirs = @glob($typeDir . DIRECTORY_SEPARATOR . '*', GLOB_ONLYDIR);
            if ($dateDirs === false || count($dateDirs) <= $this->maxFiles) {
                return;
            }
            
            // 按目录名（日期）排序
            usort($dateDirs, function($a, $b) {
                return basename($a) <=> basename($b);
            });
            
            // 删除最旧的日期目录
            $dirsToDelete = array_slice($dateDirs, 0, count($dateDirs) - $this->maxFiles);
            foreach ($dirsToDelete as $dir) {
                try {
                    $this->deleteDir($dir);
                } catch (\Throwable $e) {
                    error_log('Failed to delete old log directory: ' . $dir . ' - ' . $e->getMessage());
                }
            }
        } catch (\Throwable $e) {
            error_log('RotatingFileHandler rotate failed: ' . $e->getMessage());
        }
    }
    
    /**
     * 递归删除目录
     * 
     * @param string $dir 目录路径
     * @return void
     */
    private function deleteDir(string $dir): void
    {
        try {
            $files = new \RecursiveIteratorIterator(
                new \RecursiveDirectoryIterator($dir, \RecursiveDirectoryIterator::SKIP_DOTS),
                \RecursiveIteratorIterator::CHILD_FIRST
            );
            
            foreach ($files as $fileInfo) {
                $path = $fileInfo->getPathname();
                
                if ($fileInfo->isDir()) {
                    @rmdir($path);
                } else {
                    @unlink($path);
                }
            }
            
            @rmdir($dir);
        } catch (\Throwable $e) {
            error_log('Failed to delete directory: ' . $dir . ' - ' . $e->getMessage());
        }
    }
}