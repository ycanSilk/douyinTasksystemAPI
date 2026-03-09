<?php
/**
 * Admin认证中间件
 */

require_once __DIR__ . '/../../core/Database.php';
require_once __DIR__ . '/../../core/Token.php';
require_once __DIR__ . '/../../core/Response.php';

class AdminAuthMiddleware {
    private $db;

    public function __construct() {
        $this->db = Database::connect();
    }
    
    /**
     * 验证Admin Token
     * @param bool $returnUserId 是否只返回用户ID
     * @return mixed 用户信息数组或用户ID
     */
    private function verifyToken($returnUserId = false) {
        // 获取Token
        $token = $this->getTokenFromRequest();
        if (!$token) {
            Response::error('未提供认证Token', 401);
        }
        
        // 完整校验Token
        $result = Token::verify($token, Token::TYPE_ADMIN, $this->db);
        
        if (!$result['valid']) {
            Response::error($result['error'], 401);
        }
        
        // 查询用户详细信息
        $stmt = $this->db->prepare("SELECT su.*, sr.name as role_name FROM system_users su LEFT JOIN system_roles sr ON su.role_id = sr.id WHERE su.id = ?");
        $stmt->execute([$result['user_id']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            Response::error('用户不存在', 401);
        }
        
        // 检查角色状态
        $stmt = $this->db->prepare("SELECT status FROM system_roles WHERE id = ?");
        $stmt->execute([$user['role_id']]);
        $role = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$role || $role['status'] !== 1) {
            Response::error('角色已禁用', 401);
        }
        
        // 记录认证日志
        $this->logAuth($user['id'], $user['username'], 'token_auth', 'success');
        
        // 如果只需要返回用户ID
        if ($returnUserId) {
            return $user['id'];
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
     * 从请求头获取Token（兼容各种格式）
     */
    private function getTokenFromRequest() {
        // 方式1：直接检查所有可能的HTTP头变体
        $possibleHeaders = [
            'HTTP_X_TOKEN',
            'HTTP_X_TOKEN',
            'HTTP_X-TOKEN',
            'HTTP_TOKEN',
            'HTTP_AUTHORIZATION',
            'HTTP_X_TOKEN'
        ];
        
        foreach ($possibleHeaders as $header) {
            if (!empty($_SERVER[$header])) {
                $value = $_SERVER[$header];
                // 处理Bearer格式
                if (preg_match('/^Bearer\s+(.+)$/i', $value, $matches)) {
                    return $matches[1];
                }
                // 直接返回token值
                return $value;
            }
        }
        
        // 方式2：从所有请求头中获取（不区分大小写）
        $headers = $this->getAllHeaders();
        foreach ($headers as $name => $value) {
            $lowerName = strtolower($name);
            if (strpos($lowerName, 'token') !== false || strpos($lowerName, 'authorization') !== false) {
                // 处理Bearer格式
                if (preg_match('/^Bearer\s+(.+)$/i', $value, $matches)) {
                    return $matches[1];
                }
                // 直接返回token值
                return $value;
            }
        }
        
        // 方式3：直接从请求参数中获取token（备用方案）
        if (!empty($_GET['token'])) {
            return $_GET['token'];
        }
        
        // 方式4：检查POST请求体中的token
        if (!empty($_POST['token'])) {
            return $_POST['token'];
        }
        
        return null;
    }
    
    /**
     * 兼容获取所有请求头的函数
     */
    private function getAllHeaders() {
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
     * 静态方法：向后兼容
     */
    public static function authenticate($returnUserId = false) {
        $middleware = new self();
        return $middleware->verifyToken($returnUserId);
    }
    
    /**
     * 记录认证日志
     */
    private function logAuth($userId, $username, $type, $message) {
        // 日志记录已移除
    }
}
