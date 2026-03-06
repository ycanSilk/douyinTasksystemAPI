<?php
require_once 'core/Database.php';

try {
    $db = Database::connect();
    
    $stmt = $db->query('SELECT id, username, password_hash, status FROM system_users');
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "系统用户列表:\n";
    echo "================\n";
    foreach ($users as $user) {
        echo "ID: {$user['id']}\n";
        echo "用户名: {$user['username']}\n";
        echo "密码哈希: {$user['password_hash']}\n";
        echo "状态: {$user['status']}\n";
        echo "----------------\n";
    }
    
    // 检查角色表
    $stmt = $db->query('SELECT id, name, status FROM system_roles');
    $roles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "\n系统角色列表:\n";
    echo "================\n";
    foreach ($roles as $role) {
        echo "ID: {$role['id']}\n";
        echo "角色名称: {$role['name']}\n";
        echo "状态: {$role['status']}\n";
        echo "----------------\n";
    }
    
} catch (Exception $e) {
    echo "错误: " . $e->getMessage() . "\n";
}
?>