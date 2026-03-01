<?php
/**
 * Admin认证中间件
 */

class AdminAuthMiddleware {
    
    /**
     * 验证Admin Token
     */
    public static function authenticate() {
        session_start();
        
        // 检查Session中的Token
        if (empty($_SESSION['admin_token'])) {
            self::unauthorized('未登录或登录已过期');
        }
        
        // 检查Token是否过期
        $expiredAt = $_SESSION['admin_expired_at'] ?? 0;
        if (time() > $expiredAt) {
            session_destroy();
            self::unauthorized('登录已过期，请重新登录');
        }
        
        // 返回管理员信息
        return [
            'username' => $_SESSION['admin_username'] ?? '',
            'token' => $_SESSION['admin_token'] ?? ''
        ];
    }
    
    /**
     * 返回未授权错误
     */
    private static function unauthorized($message = '未授权访问') {
        http_response_code(401);
        echo json_encode([
            'code' => 401,
            'message' => $message,
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}
