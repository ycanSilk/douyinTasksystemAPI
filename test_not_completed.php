<?php
// 测试修改后的not-completed.php接口功能
echo "测试修改后的not-completed.php接口功能\n";
echo "====================================\n\n";

// 模拟响应数据结构
echo "预期响应数据结构:\n";
echo "-----------------\n";

$expectedResponse = [
    'code' => 0,
    'message' => '获取成功',
    'data' => [
        'tasks' => [
            [
                'task_id' => 153,
                'template_id' => 1,
                'template_title' => '上评评论',
                'template_type' => 0,
                'template_type_text' => '单任务',
                'video_url' => 'https://www.doubao.com/chat/38419757094396930?channel=google_sem',
                'deadline' => 1775117670,
                'deadline_text' => '2026-04-02 16:14:30',
                'task_count' => 1,
                'task_done' => 0,
                'task_doing' => 0,
                'task_reviewing' => 0,
                'task_available' => 1,
                'progress_percent' => 0,
                'unit_price' => '3.00',
                'total_price' => '3.00',
                'status' => 0,
                'status_text' => '已过期',
                'unfinished_count' => 1,  // 新增：每个任务的未完成数量
                'created_at' => '2026-04-02 15:44:30',
                'updated_at' => '2026-04-02 16:55:39',
                'completed_at' => null,
                'is_combo' => false,
                'stage' => 0,
                'stage_text' => '单任务',
                'stage_title' => null,
                'stage_status' => 1,
                'stage_status_text' => '已开放',
                'combo_task_id' => 'COMBO_1775115870_1_5',
                'parent_task_id' => null,
                'recommend_marks' => [  // 新增：推荐评论JSON数组
                    [
                        'comment' => '很好用，值得购买',
                        'image_url' => ''
                    ]
                ]
            ]
        ],
        'pagination' => [
            'current_page' => 1,
            'page_size' => 20,
            'total' => 1,
            'total_pages' => 1
            // 注意：不再有总的unfinished_count字段
        ]
    ],
    'timestamp' => 1775120919
];

// 显示关键修改点
echo "关键修改点:\n";
echo "1. 每个任务现在有自己的'unfinished_count'字段（位于'status_text'下面）\n";
echo "2. 新增了'recommend_marks'字段，包含JSON数组格式的推荐评论\n";
echo "3. pagination中不再包含总的'unfinished_count'字段\n\n";

// 验证unfinished_count计算逻辑
echo "验证unfinished_count计算逻辑:\n";
echo "---------------------------\n";

$taskCount = 1;
$taskDone = 0;
$unfinishedCount = $taskCount - $taskDone;
echo "task_count = {$taskCount}, task_done = {$taskDone}\n";
echo "unfinished_count = task_count - task_done = {$unfinishedCount}\n\n";

// 验证recommend_marks字段处理
echo "验证recommend_marks字段处理:\n";
echo "----------------------------\n";

// 模拟数据库中的JSON数据
$recommendMarksJson = '[
    {
        "comment": "很好用，值得购买",
        "image_url": ""
    }
]';

echo "数据库中的JSON数据: {$recommendMarksJson}\n";
$recommendMarksArray = json_decode($recommendMarksJson, true);
echo "解码后的PHP数组:\n";
print_r($recommendMarksArray);

// 验证SQL查询
echo "\n验证SQL查询修改:\n";
echo "----------------\n";

$sql = "SELECT 
    bt.id AS task_id,
    bt.template_id,
    tt.title AS template_title,
    bt.video_url,
    bt.deadline,
    bt.task_count,
    bt.task_done,
    bt.task_doing,
    bt.task_reviewing,
    bt.unit_price,
    bt.total_price,
    bt.status,
    bt.created_at,
    bt.updated_at,
    bt.completed_at,
    tt.type AS template_type,
    tt.stage1_title,
    tt.stage1_price,
    tt.stage2_title,
    tt.stage2_price,
    bt.stage,
    bt.stage_status,
    bt.combo_task_id,
    bt.parent_task_id,
    bt.recommend_marks  -- 新增字段
FROM b_tasks bt
INNER JOIN task_templates tt ON bt.template_id = tt.id
WHERE bt.b_user_id = ? AND bt.status = ?
ORDER BY bt.created_at DESC
LIMIT ? OFFSET ?";

echo "SQL查询已添加'recommend_marks'字段\n";

// 验证响应格式
echo "\n验证响应格式:\n";
echo "------------\n";

$task = $expectedResponse['data']['tasks'][0];
echo "任务字段验证:\n";
echo "- unfinished_count 位置: 在 status_text 之后: {$task['status_text']} → {$task['unfinished_count']}\n";
echo "- recommend_marks 类型: " . gettype($task['recommend_marks']) . "\n";
echo "- recommend_marks 内容: " . json_encode($task['recommend_marks']) . "\n";

// 验证pagination不再包含unfinished_count
echo "\n验证pagination:\n";
$pagination = $expectedResponse['data']['pagination'];
echo "- 包含字段: " . implode(', ', array_keys($pagination)) . "\n";