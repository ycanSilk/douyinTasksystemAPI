<?php
/**
 * 支付密码验证类
 * 
 * 提供支付密码的验证功能
 */

class WalletPassword
{
    /**
     * 验证支付密码
     * 
     * @param PDO $db 数据库连接
     * @param int $walletId 钱包ID
     * @param string $password 用户提交的支付密码
     * @param array $errorCodes 错误码配置
     * @return bool 验证成功返回true，失败则通过Response::error()直接退出
     */
    public static function verify($db, $walletId, $password, $errorCodes)
    {
        require_once __DIR__ . '/Response.php';
        
        // 1. 校验密码是否为空
        if (empty($password)) {
            Response::error('请提供支付密码', $errorCodes['WALLET_PASSWORD_REQUIRED']);
        }
        
        // 2. 查询钱包是否设置了支付密码
        $stmt = $db->prepare("SELECT password_hash FROM wallet_password WHERE wallet_id = ?");
        $stmt->execute([$walletId]);
        $walletPassword = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$walletPassword) {
            Response::error('未设置支付密码，请先设置支付密码', $errorCodes['WALLET_PASSWORD_NOT_SET']);
        }
        
        // 3. 验证密码是否正确
        if ($password !== $walletPassword['password_hash']) {
            Response::error('支付密码错误', $errorCodes['WALLET_PASSWORD_WRONG']);
        }
        
        return true;
    }
}
