<?php
require_once 'core/Database.php';
try {
    $db = Database::connect();
    // 检查b_task_statistics表中的数据
    $stmt = $db->query("SELECT * FROM b_task_statistics LIMIT 10");
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo 'b_task_statistics表中的数据: ' . "\n";
    echo '记录数: ' . count($data) . "\n";
    
    if (count($data) > 0) {
        echo '前10条记录: ' . "\n";
        foreach ($data as $index => $row) {
            echo '记录 ' . ($index + 1) . ': ' . "\n";
            echo 'ID: ' . $row['id'] . "\n";
            echo 'B端用户ID: ' . $row['b_user_id'] . "\n";
            echo '用户名: ' . $row['username'] . "\n";
            echo '流水类型: ' . $row['flow_type'] . "\n";
            echo '金额: ' . $row['amount'] . "\n";
            echo '关联类型: ' . $row['related_type'] . "\n";
            echo '任务类型: ' . $row['task_types'] . "\n";
            echo '任务类型文本: ' . $row['task_types_text'] . "\n";
            echo '备注: ' . $row['remark'] . "\n";
            echo '创建时间: ' . $row['created_at'] . "\n";
            echo '----------------------------------------' . "\n";
        }
    }
} catch (Exception $e) {
    echo '错误: ' . $e->getMessage();
}
?>