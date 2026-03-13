<?php
require_once 'core/Database.php';

try {
    $db = Database::connect();
    
    // 插入测试数据
    $testData = [
        [
            'b_user_id' => 3,
            'username' => 'test_user',
            'flow_type' => 1,
            'amount' => 1000,
            'before_balance' => 0,
            'after_balance' => 1000,
            'related_type' => 'recharge',
            'related_id' => null,
            'task_types' => null,
            'task_types_text' => null,
            'remark' => '用户充值'
        ],
        [
            'b_user_id' => 3,
            'username' => 'test_user',
            'flow_type' => 2,
            'amount' => 500,
            'before_balance' => 1000,
            'after_balance' => 500,
            'related_type' => 'task_publish',
            'related_id' => 1,
            'task_types' => 1,
            'task_types_text' => '上评评论',
            'remark' => '发布任务'
        ],
        [
            'b_user_id' => 3,
            'username' => 'test_user',
            'flow_type' => 2,
            'amount' => 300,
            'before_balance' => 500,
            'after_balance' => 200,
            'related_type' => 'account_rental',
            'related_id' => 1,
            'task_types' => 6,
            'task_types_text' => '出租订单',
            'remark' => '租赁账号'
        ]
    ];
    
    foreach ($testData as $data) {
        $stmt = $db->prepare("
            INSERT INTO b_task_statistics 
            (b_user_id, username, flow_type, amount, before_balance, after_balance, related_type, related_id, task_types, task_types_text, remark)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $data['b_user_id'],
            $data['username'],
            $data['flow_type'],
            $data['amount'],
            $data['before_balance'],
            $data['after_balance'],
            $data['related_type'],
            $data['related_id'],
            $data['task_types'],
            $data['task_types_text'],
            $data['remark']
        ]);
    }
    
    echo '测试数据插入成功！';
    
} catch (Exception $e) {
    echo '错误: ' . $e->getMessage();
}
?>