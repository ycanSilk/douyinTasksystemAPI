<?php
/**
 * 基于角色的访问控制中间件
 */

require_once __DIR__ . '/../../core/Database.php';

class RBACMiddleware {
    
    /**
     * 验证Admin Token并检查权限
     */
    public static function authenticate($requiredPermission = null) {
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
        
        $username = $_SESSION['admin_username'] ?? '';
        
        // 数据库连接
        $db = Database::connect();
        
        // 查询用户信息
        $stmt = $db->prepare("SELECT su.*, sr.name as role_name FROM system_users su LEFT JOIN system_roles sr ON su.role_id = sr.id WHERE su.username = ? AND su.status = 1");
        $stmt->execute([$username]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            session_destroy();
            self::unauthorized('用户不存在或已禁用');
        }
        
        // 检查角色是否启用
        if ($user['status'] !== 1) {
            session_destroy();
            self::unauthorized('角色已禁用');
        }
        
        // 如果需要特定权限，检查用户是否拥有该权限
        if ($requiredPermission) {
            // 超级管理员（假设角色ID为1）拥有所有权限
            if ($user['role_id'] === 1) {
                return $user;
            }
            
            // 检查角色是否拥有该权限
            $stmt = $db->prepare("SELECT sp.id FROM system_permissions sp INNER JOIN system_role_permission srp ON sp.id = srp.permission_id WHERE srp.role_id = ? AND sp.code = ?");
            $stmt->execute([$user['role_id'], $requiredPermission]);
            if (!$stmt->fetch()) {
                self::unauthorized('没有权限访问此功能');
            }
        }
        
        return $user;
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
    
    /**
     * 获取用户权限列表
     */
    public static function getUserPermissions($userId) {
        $db = Database::connect();
        
        // 查询用户角色
        $stmt = $db->prepare("SELECT role_id FROM system_users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            return [];
        }
        
        // 超级管理员（假设角色ID为1）拥有所有权限
        if ($user['role_id'] === 1) {
            $stmt = $db->query("SELECT code FROM system_permissions");
            $permissions = $stmt->fetchAll(PDO::FETCH_COLUMN);
            return $permissions;
        }
        
        // 查询角色权限
        $stmt = $db->prepare("SELECT sp.code FROM system_permissions sp INNER JOIN system_role_permission srp ON sp.id = srp.permission_id WHERE srp.role_id = ?");
        $stmt->execute([$user['role_id']]);
        $permissions = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        return $permissions;
    }
}