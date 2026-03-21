<?php

/**
 * 新手任务池保障脚本
 * 每30分钟执行一次，检查新手任务池任务数量，不足时自动创建平台自营任务
 */

require_once __DIR__ . '/../core/Database.php';

// 数据库连接
$db = Database::connect();
if (!$db) {
    echo "数据库连接失败\n";
    exit;
}

echo "开始执行新手任务池保障脚本\n";

try {
    // 1. 查询当前新手任务池中的有效任务数量
    $stmt = $db->prepare("SELECT COUNT(*) as task_count FROM newbie_tasks WHERE status = 1 AND (expire_at IS NULL OR expire_at > NOW())");
    $stmt->execute();
    $taskCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['task_count'];
    
    echo "当前新手任务池有效任务数量: {$taskCount}\n";
    
    // 2. 检查是否需要补充任务（目标数量为5个）
    $targetTaskCount = 5;
    $needToCreate = max(0, $targetTaskCount - $taskCount);
    
    if ($needToCreate > 0) {
        echo "需要创建 {$needToCreate} 个新手任务\n";
        
        // 3. 任务模板库（用于自动创建任务）
        $taskTemplates = [
            [
                'title' => '复制视频链接并评论',
                'reward' => 1.00,
                'steps' => [
                    [
                        'step' => 1,
                        'content' => '复制下方视频链接',
                        'action' => 'copy',
                        'value' => 'https://www.douyin.com/video/1234567890'
                    ],
                    [
                        'step' => 2,
                        'content' => '复制评论内容',
                        'action' => 'copy',
                        'value' => '这个视频真不错！'
                    ],
                    [
                        'step' => 3,
                        'content' => '提交任务',
                        'action' => 'submit'
                    ]
                ]
            ],
            [
                'title' => '关注账号并点赞',
                'reward' => 1.50,
                'steps' => [
                    [
                        'step' => 1,
                        'content' => '复制账号链接并关注',
                        'action' => 'copy',
                        'value' => 'https://www.douyin.com/user/1234567890'
                    ],
                    [
                        'step' => 2,
                        'content' => '点赞最近一条视频',
                        'action' => 'action',
                        'value' => '点赞'
                    ],
                    [
                        'step' => 3,
                        'content' => '提交任务',
                        'action' => 'submit'
                    ]
                ]
            ],
            [
                'title' => '分享视频到朋友圈',
                'reward' => 2.00,
                'steps' => [
                    [
                        'step' => 1,
                        'content' => '复制视频链接',
                        'action' => 'copy',
                        'value' => 'https://www.douyin.com/video/1234567890'
                    ],
                    [
                        'step' => 2,
                        'content' => '分享到朋友圈',
                        'action' => 'action',
                        'value' => '分享'
                    ],
                    [
                        'step' => 3,
                        'content' => '提交任务',
                        'action' => 'submit'
                    ]
                ]
            ],
            [
                'title' => '完成简单问卷',
                'reward' => 0.50,
                'steps' => [
                    [
                        'step' => 1,
                        'content' => '点击链接进入问卷',
                        'action' => 'copy',
                        'value' => 'https://example.com/survey'
                    ],
                    [
                        'step' => 2,
                        'content' => '完成问卷并提交',
                        'action' => 'action',
                        'value' => '完成问卷'
                    ],
                    [
                        'step' => 3,
                        'content' => '提交任务',
                        'action' => 'submit'
                    ]
                ]
            ],
            [
                'title' => '收藏视频并评论',
                'reward' => 1.20,
                'steps' => [
                    [
                        'step' => 1,
                        'content' => '复制视频链接',
                        'action' => 'copy',
                        'value' => 'https://www.douyin.com/video/1234567890'
                    ],
                    [
                        'step' => 2,
                        'content' => '收藏视频并评论',
                        'action' => 'action',
                        'value' => '收藏并评论'
                    ],
                    [
                        'step' => 3,
                        'content' => '提交任务',
                        'action' => 'submit'
                    ]
                ]
            ]
        ];
        
        // 4. 随机选择模板创建任务
        $createdCount = 0;
        $shuffledTemplates = $taskTemplates;
        shuffle($shuffledTemplates);
        
        foreach ($shuffledTemplates as $template) {
            if ($createdCount >= $needToCreate) {
                break;
            }
            
            // 插入新手任务
            $stmt = $db->prepare("INSERT INTO newbie_tasks (title, reward, steps, status, priority, created_by) VALUES (?, ?, ?, ?, ?, ?)");
            
            $title = $template['title'];
            $reward = $template['reward'];
            $steps = json_encode($template['steps'], JSON_UNESCAPED_UNICODE);
            $status = 1; // 发布状态
            $priority = 10; // 平台任务优先级较高
            $createdBy = 1; // 系统管理员ID
            
            $stmt->execute([$title, $reward, $steps, $status, $priority, $createdBy]);
            
            if ($stmt->rowCount() > 0) {
                $createdCount++;
                echo "创建新手任务成功: {$title}\n";
            }
        }
        
        echo "成功创建 {$createdCount} 个新手任务\n";
    } else {
        echo "新手任务池任务数量充足，无需补充\n";
    }
    
} catch (PDOException $e) {
    echo "执行失败: " . $e->getMessage() . "\n";
}

echo "新手任务池保障脚本执行完成\n";