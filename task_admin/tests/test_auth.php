<?php
/**
 * 认证模块测试
 */

require_once __DIR__ . '/../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../core/Database.php';

class AuthTest {
    public function testTokenAuthentication() {
        echo "=== 测试Token认证 ===\n";
        
        // 模拟请求头
        $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer invalid_token';
        
        try {
            AdminAuthMiddleware::authenticate();
            echo "❌ Token认证测试失败：应该返回未授权错误\n";
        } catch (Exception $e) {
            echo "✅ Token认证测试通过：正确处理了无效Token\n";
        }
        
        echo "\n";
    }
    
    public function testSessionAuthentication() {
        echo "=== 测试Session认证 ===\n";
        
        // 模拟Session
        session_start();
        $_SESSION['admin_token'] = 'test_token';
        $_SESSION['admin_expired_at'] = time() + 3600; // 1小时后过期
        $_SESSION['admin_username'] = 'test_admin';
        
        try {
            $user = AdminAuthMiddleware::authenticate();
            echo "✅ Session认证测试通过：成功获取用户信息\n";
            echo "用户名: " . $user['username'] . "\n";
        } catch (Exception $e) {
            echo "❌ Session认证测试失败：" . $e->getMessage() . "\n";
        }
        
        echo "\n";
    }
    
    public function testExpiredSession() {
        echo "=== 测试过期Session ===\n";
        
        // 模拟过期Session
        session_start();
        $_SESSION['admin_token'] = 'test_token';
        $_SESSION['admin_expired_at'] = time() - 3600; // 1小时前过期
        $_SESSION['admin_username'] = 'test_admin';
        
        try {
            AdminAuthMiddleware::authenticate();
            echo "❌ 过期Session测试失败：应该返回未授权错误\n";
        } catch (Exception $e) {
            echo "✅ 过期Session测试通过：正确处理了过期Session\n";
        }
        
        echo "\n";
    }
}

// 运行测试
$test = new AuthTest();
$test->testTokenAuthentication();
$test->testSessionAuthentication();
$test->testExpiredSession();

echo "=== 认证模块测试完成 ===\n";
?>