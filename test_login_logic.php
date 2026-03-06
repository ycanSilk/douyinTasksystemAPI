<?php
require_once 'core/Database.php';

// 模拟登录参数
$username = 'task';
$password = '123456';
$hashedPassword = md5($password);

echo "测试登录逻辑:\n";
echo "用户名: $username\n";
echo "原始密码: $password\n";
echo "MD5加密后: $hashedPassword\n";

try {
    $db = Database::connect();
    
    // 查询用户信息
    $stmt = $db->prepare("SELECT su.*, sr.name as role_name FROM system_users su LEFT JOIN system_roles sr ON su.role_id = sr.id WHERE su.username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        echo "错误: 用户名不存在\n";
    } else {
        echo "\n用户信息:\n";
        echo "ID: {$user['id']}\n";
        echo "用户名: {$user['username']}\n";
        echo "密码哈希: {$user['password_hash']}\n";
        echo "状态: {$user['status']}\n";
        echo "角色ID: {$user['role_id']}\n";
        echo "角色名称: {$user['role_name']}\n";
        
        // 检查密码
        if ($user['password_hash'] === $hashedPassword) {
            echo "\n密码验证: 成功！\n";
        } else {
            echo "\n密码验证: 失败！\n";
            echo "数据库中的密码哈希: {$user['password_hash']}\n";
            echo "输入的密码哈希: $hashedPassword\n";
        }
        
        // 检查用户状态
        if ($user['status'] === 1) {
            echo "用户状态: 正常\n";
        } else {
            echo "用户状态: 禁用\n";
        }
        
        // 检查角色状态
        $stmt = $db->prepare("SELECT status FROM system_roles WHERE id = ?");
        $stmt->execute([$user['role_id']]);
        $role = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($role && $role['status'] === 1) {
            echo "角色状态: 正常\n";
        } else {
            echo "角色状态: 禁用\n";
        }
    }
    
} catch (Exception $e) {
    echo "错误: " . $e->getMessage() . "\n";
}
?>