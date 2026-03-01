<?php
/**
 * 邀请码生成类
 */

class InviteCode
{
    // 字符集（去除易混淆字符：0/O, 1/I/L）
    const CHARSET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
    
    /**
     * 生成唯一邀请码
     * 
     * @param PDO $db 数据库连接
     * @return string 6位邀请码
     */
    public static function generate($db)
    {
        $maxAttempts = 100; // 最大尝试次数
        
        for ($i = 0; $i < $maxAttempts; $i++) {
            // 生成6位随机码
            $code = self::generateRandomCode(6);
            
            // 检查是否已存在
            $stmt = $db->prepare("SELECT id FROM c_users WHERE invite_code = ?");
            $stmt->execute([$code]);
            
            if (!$stmt->fetch()) {
                return $code;
            }
        }
        
        // 如果100次都冲突，使用时间戳+随机数
        return self::generateRandomCode(6);
    }
    
    /**
     * 生成随机字符串
     * 
     * @param int $length 长度
     * @return string
     */
    private static function generateRandomCode($length = 6)
    {
        $code = '';
        $charsetLength = strlen(self::CHARSET);
        
        for ($i = 0; $i < $length; $i++) {
            $code .= self::CHARSET[random_int(0, $charsetLength - 1)];
        }
        
        return $code;
    }
    
    /**
     * 验证邀请码格式
     * 
     * @param string $code 邀请码
     * @return bool
     */
    public static function validate($code)
    {
        // 必须是6位
        if (strlen($code) !== 6) {
            return false;
        }
        
        // 只能包含允许的字符
        return preg_match('/^[23456789ABCDEFGHJKMNPQRSTUVWXYZ]{6}$/', $code) === 1;
    }
}
