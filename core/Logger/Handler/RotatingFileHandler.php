<?php
namespace Core\Logger\Handler;

/**
 * 轮转文件处理器
 * 
 * 按日期自动轮转日志文件，支持保留指定数量的文件
 * 
 * @package Core\Logger\Handler
 */
class RotatingFileHandler extends FileHandler
{
    /**
     * @var int 最大保留文件数量
     */
    private int $maxFiles;
    
    /**
     * @var string 日期格式
     */
    private string $dateFormat;
    
    /**
     * 构造函数
     * 
     * @param string $filename 日志文件名（不含日期）
     * @param int $maxFiles 最大保留文件数量（天数）
     * @param int $filePermission 文件权限
     * @param bool $useLocking 是否使用文件锁
     */
    public function __construct(
        string $filename,
        int $maxFiles = 30,
        int $filePermission = 0644,
        bool $useLocking = true
    ) {
        $this->maxFiles = $maxFiles;
        $this->dateFormat = 'Y-m-d';
        
        // 生成带日期的文件名
        $filename = $this->getTimedFilename($filename);
        parent::__construct($filename, $filePermission, $useLocking);
        
        // 清理过期日志
        $this->rotate();
    }
    
    /**
     * 获取带时间戳的文件名
     * 
     * 新目录结构：logs/20260324/request/b-v1-auth-register/log.log
     * 日期放在第二层，方便按日期管理和清理
     * 
     * @param string $filename 原始文件名
     * @return string 带日期的完整路径
     */
    private function getTimedFilename(string $filename): string
    {
        try {
            // 解析路径：logs/request/b-v1-auth-register/log.log
            $parts = explode('/', str_replace('\\', '/', $filename));
            
            if (count($parts) >= 4) {
                // logs/request/b-v1-auth-register/log.log
                $logType = $parts[0] ?? 'logs';
                $subType = $parts[1] ?? 'request';
                $apiName = $parts[2] ?? 'default';
                
                // 使用新结构：logs/日期/类型/API 名称/log.log
                // 日期格式：20260324（无横杠，更简洁）
                $date = date('Ymd');
                $path = $logType . '/' . $date . '/' . $subType . '/' . $apiName;
                
                // 使用项目根目录作为基础路径
                $isWindowsPath = (strlen($path) >= 3 && $path[1] === ':');
                $isUnixPath = (strlen($path) >= 1 && $path[0] === '/');
                
                if (!$isWindowsPath && !$isUnixPath) {
                    $path = dirname(__DIR__, 3) . '/' . $path;
                }
                
                if (!is_dir($path)) {
                    if (!@mkdir($path, 0755, true)) {
                        $error = error_get_last();
                        error_log('Failed to create log directory: ' . $path . ' - Error: ' . ($error['message'] ?? 'Unknown'));
                        return $filename;
                    }
                }
                
                // 日志文件名固定为 log.log
                return $path . '/log.log';
            }
            
            // 兼容旧结构
            return $filename;
        } catch (\Throwable $e) {
            error_log('RotatingFileHandler getTimedFilename failed: ' . $e->getMessage());
            return $filename;
        }
    }
    
    /**
     * 检查字符串是否是日期格式
     * 
     * @param string $str 待检查的字符串
     * @return bool
     */
    private function isDateFormat(string $str): bool
    {
        // 检查是否符合 Y-m-d 格式（如 2026-03-24）
        return preg_match('/^\d{4}-\d{2}-\d{2}$/', $str) === 1;
    }
    
    /**
     * 轮转日志（删除过期文件）
     * 
     * 新结构：logs/20260324/request/b-v1-auth-register/log.log
     * 按日期目录删除，保留最近 N 天的日志
     * 
     * @return void
     */
    private function rotate(): void
    {
        try {
            // 新结构：logs/20260324/request/b-v1-auth-register/log.log
            // 获取日志类型目录：logs/request
            $parts = explode('/', str_replace('\\', '/', $this->filePath));
            
            if (count($parts) >= 5) {
                // logs/20260324/request/b-v1-auth-register
                $logType = $parts[0] ?? 'logs';
                $subType = $parts[2] ?? 'request';
                
                // 日志类型根目录：logs/request
                $typeRootDir = dirname(__DIR__, 3) . '/' . $logType;
                
                if (!is_dir($typeRootDir)) {
                    return;
                }
                
                // 获取所有日期目录
                $dateDirs = @glob($typeRootDir . '/*', GLOB_ONLYDIR);
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
                    // 删除目录及其内容
                    try {
                        $this->deleteDir($dir);
                    } catch (\Throwable $e) {
                        error_log('Failed to delete old log directory: ' . $dir . ' - ' . $e->getMessage());
                    }
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
        if (!is_dir($dir)) {
            return;
        }
        
        $files = array_diff(scandir($dir), ['.', '..']);
        foreach ($files as $file) {
            $path = $dir . '/' . $file;
            is_dir($path) ? $this->deleteDir($path) : @unlink($path);
        }
        @rmdir($dir);
    }
}
