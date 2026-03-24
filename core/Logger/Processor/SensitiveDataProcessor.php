<?php
namespace Core\Logger\Processor;

/**
 * 敏感信息脱敏处理器
 * 
 * 自动过滤日志中的敏感信息（密码、Token、手机号等）
 * 
 * @package Core\Logger\Processor
 */
class SensitiveDataProcessor
{
    /**
     * @var array 敏感键名列表
     */
    private static array $sensitiveKeys = [
        'password',
        'passwd',
        'secret',
        'token',
        'access_token',
        'refresh_token',
        'api_key',
        'api_secret',
        'credit_card',
        'id_card',
        'id_card_no',
        'phone',
        'mobile',
        'tel',
        'email',
        'bank_card',
        'card_no',
    ];
    
    /**
     * 处理敏感数据
     * 
     * @param array $record 日志记录
     * @return array 脱敏后的日志记录
     */
    public function __invoke(array $record): array
    {
        try {
            if (isset($record['context'])) {
                $record['context'] = $this->sanitize($record['context']);
            }
            
            if (isset($record['extra'])) {
                $record['extra'] = $this->sanitize($record['extra']);
            }
            
            return $record;
        } catch (\Throwable $e) {
            error_log('SensitiveDataProcessor failed: ' . $e->getMessage());
            // 处理器失败时返回原始数据，不影响日志记录
            return $record;
        }
    }
    
    /**
     * 递归清理敏感信息
     * 
     * @param array $data 原始数据
     * @return array 脱敏后的数据
     */
    private function sanitize(array $data): array
    {
        try {
            foreach ($data as $key => $value) {
                // 检查键名是否敏感
                if (in_array(strtolower($key), self::$sensitiveKeys, true)) {
                    $data[$key] = $this->maskValue($value, $key);
                } elseif (is_array($value)) {
                    // 递归处理数组
                    $data[$key] = $this->sanitize($value);
                }
            }
            
            return $data;
        } catch (\Throwable $e) {
            error_log('SensitiveDataProcessor sanitize failed: ' . $e->getMessage());
            // 失败时返回原始数据
            return $data;
        }
    }
    
    /**
     * 根据类型脱敏值
     * 
     * @param mixed $value 原始值
     * @param string $key 键名
     * @return string 脱敏后的值
     */
    private function maskValue($value, string $key): string
    {
        $value = (string)$value;
        
        // 手机号：138****1234
        if (in_array(strtolower($key), ['phone', 'mobile', 'tel'], true)) {
            if (strlen($value) === 11 && ctype_digit($value)) {
                return substr($value, 0, 3) . '****' . substr($value, -4);
            }
        }
        
        // 身份证：110101********1234
        if (in_array(strtolower($key), ['id_card', 'id_card_no'], true)) {
            if (strlen($value) >= 18) {
                return substr($value, 0, 6) . '********' . substr($value, -4);
            }
        }
        
        // 邮箱：t***@example.com
        if (strtolower($key) === 'email' && strpos($value, '@') !== false) {
            $parts = explode('@', $value);
            $username = $parts[0];
            $domain = $parts[1];
            if (strlen($username) > 2) {
                return $username[0] . '***' . substr($username, -1) . '@' . $domain;
            }
        }
        
        // 其他敏感信息：全部用 *** 代替
        return '***';
    }
}
