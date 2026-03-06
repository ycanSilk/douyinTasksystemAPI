<?php
require_once 'core/Database.php';

try {
    echo "测试数据库连接...\n";
    $db = Database::connect();
    echo "数据库连接成功！\n";
    
    // 检查系统用户表结构
    echo "\n检查系统用户表结构:\n";
    $stmt = $db->query('DESCRIBE system_users');
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($columns as $column) {
        echo "字段: {$column['Field']} | 类型: {$column['Type']} | 空: {$column['Null']} | 默认: {$column['Default']}\n";
    }
    
    // 检查系统角色表结构
    echo "\n检查系统角色表结构:\n";
    $stmt = $db->query('DESCRIBE system_roles');
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($columns as $column) {
        echo "字段: {$column['Field']} | 类型: {$column['Type']} | 空: {$column['Null']} | 默认: {$column['Default']}\n";
    }
    
} catch (Exception $e) {
    echo "错误: " . $e->getMessage() . "\n";
}
?>