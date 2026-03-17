<?php
require_once 'core/Database.php';

try {
    $db = Database::connect();
    
    // 检查system_users表是否存在
    $stmt = $db->query('SHOW TABLES LIKE "system_users"');
    if ($stmt->rowCount() > 0) {
        echo "system_users table exists\n";
        
        // 检查是否有管理员用户
        $stmt = $db->query('SELECT * FROM system_users WHERE status = 1');
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Found " . count($users) . " active admin users\n";
        
        if (count($users) > 0) {
            echo "First admin user: " . $users[0]['username'] . " (ID: " . $users[0]['id'] . ")\n";
            echo "Token: " . ($users[0]['token'] ?? 'No token') . "\n";
            echo "Token expired at: " . ($users[0]['token_expired_at'] ?? 'No expiration') . "\n";
        }
    } else {
        echo "system_users table does not exist\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>