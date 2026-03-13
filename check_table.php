<?php
require_once 'core/Database.php';
try {
    $db = Database::connect();
    // 检查b_task_statistics表是否存在
    $stmt = $db->query("SHOW TABLES LIKE 'b_task_statistics'");
    $result = $stmt->fetchAll();
    echo 'b_task_statistics表: ' . (count($result) > 0 ? '存在' : '不存在') . "\n";
    
    // 检查表结构
    if (count($result) > 0) {
        $stmt = $db->query("DESCRIBE b_task_statistics");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo '表结构: ' . "\n";
        foreach ($columns as $column) {
            echo $column['Field'] . ' - ' . $column['Type'] . "\n";
        }
    }
} catch (Exception $e) {
    echo '错误: ' . $e->getMessage();
}
?>