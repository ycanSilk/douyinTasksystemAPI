<?php
/**
 * Admin认证中间件
 */

require_once __DIR__ . '/../../core/Database.php';

class AdminAuthMiddleware {
    
    /**
     * 验证Admin Token
     * @param bool $returnUserId 是否只返回用户ID
     * @return mixed 用户信息数组或用户ID
     */
    public static function authenticate($returnUserId = false) {
        // 尝试从请求头获取Token
        $token = self::getTokenFromHeader();
        
        if ($token) {
            // 使用Token认证
            $userInfo = self::validateToken($token);
        } else {
            // 回退到Session认证
            $userInfo = self::validateSession();
        }
        
        // 如果只需要返回用户ID
        if ($returnUserId) {
            return $userInfo['user_id'];
        }
        
        return $userInfo;
    }
    
    /**
     * 从请求头获取Token
     */
    private static function getTokenFromHeader() {
        $headers = self::getAllHeaders();
        
        // 检查Authorization头
        if (isset($headers['Authorization'])) {
            $authHeader = $headers['Authorization'];
            if (strpos($authHeader, 'Bearer ') === 0) {
                return substr($authHeader, 7);
            }
        }
        
        // 检查X-Token头
        if (isset($headers['X-Token'])) {
            return $headers['X-Token'];
        }
        
        return null;
    }
    
    /**
     * 兼容获取所有请求头的函数
     */
    private static function getAllHeaders() {
        if (function_exists('getallheaders')) {
            return getallheaders();
        }
        
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headerName = substr($name, 5);
                $headerName = str_replace('_', ' ', $headerName);
                $headerName = ucwords(strtolower($headerName));
                $headerName = str_replace(' ', '-', $headerName);
                $headers[$headerName] = $value;
            }
        }
        return $headers;
    }
    
    /**
     * 验证Token
     */
    private static function validateToken($token) {
        $db = Database::connect();
        
        // 查询用户信息
        $stmt = $db->prepare("SELECT su.*, sr.name as role_name FROM system_users su LEFT JOIN system_roles sr ON su.role_id = sr.id WHERE su.token = ?");
        $stmt->execute([$token]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            self::unauthorized('无效的Token');
        }
        
        // 检查用户状态
        if ($user['status'] !== 1) {
            self::unauthorized('账号已禁用');
        }
        
        // 检查角色状态
        $stmt = $db->prepare("SELECT status FROM system_roles WHERE id = ?");
        $stmt->execute([$user['role_id']]);
        $role = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$role || $role['status'] !== 1) {
            self::unauthorized('角色已禁用');
        }
        
        // 检查Token是否过期
        $expiredAt = strtotime($user['token_expired_at']);
        if (time() > $expiredAt) {
            self::unauthorized('Token已过期');
        }
        
        // 返回用户信息
        return [
            'user_id' => $user['id'],
            'username' => $user['username'],
            'role_id' => $user['role_id'],
            'role_name' => $user['role_name'],
            'token' => $token
        ];
    }
    
    /**
     * 验证Session
     */
    private static function validateSession() {
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
            'user_id' => $_SESSION['admin_user_id'] ?? '',
            'username' => $_SESSION['admin_username'] ?? '',
            'role_id' => $_SESSION['admin_role_id'] ?? '',
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
