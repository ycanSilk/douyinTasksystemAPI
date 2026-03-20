<?php
/**
 * B端任务列表
 * GET /api/b/v1/tasks/list
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求参数：
 * - status (可选): 任务状态筛选 0=已过期 1=进行中 2=已完成 3=已取消
 * - page (可选): 页码，默认1
 * - page_size (可选): 每页数量，默认20
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "获取成功",
 *   "data": {
 *     "tasks": [
 *       {
 *         "task_id": 1,
 *         "template_id": 5,
 *         "template_title": "抖音点赞任务",
 *         "video_url": "https://...",
 *         "deadline": 1737388799,
 *         "deadline_text": "2026-01-20 23:59:59",
 *         "task_count": 100,
 *         "task_done": 45,
 *         "task_doing": 20,
 *         "task_reviewing": 10,
 *         "task_available": 25,
 *         "progress_percent": 45.00,
 *         "unit_price": "5.00",
 *         "total_price": "500.00",
 *         "status": 1,
 *         "status_text": "进行中",
 *         "created_at": "2026-01-14 10:00:00",
 *         "updated_at": "2026-01-14 12:00:00",
 *         "completed_at": null
 *       }
 *     ],
 *     "pagination": {
 *       "current_page": 1,
 *       "page_size": 20,
 *       "total": 50,
 *       "total_pages": 3
 *     }
 *   },
 *   "timestamp": 1737123456
 * }
 */

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../config/error_codes.php';

// 调试日志
error_log('[B端任务列表] 请求开始 - ' . $_SERVER['REQUEST_URI']);
error_log('[B端任务列表] 请求头: ' . json_encode(getallheaders(), JSON_UNESCAPED_UNICODE));
error_log('[B端任务列表] 查询参数: ' . json_encode($_GET, JSON_UNESCAPED_UNICODE));

try {
    // 数据库连接
    try {
        $db = Database::connect();
        error_log('[B端任务列表] 数据库连接成功');
    } catch (Exception $e) {
        error_log('[B端任务列表] 数据库连接失败: ' . $e->getMessage());
        throw $e;
    }
    
    // Token 认证
    try {
        $auth = new AuthMiddleware($db);
        $currentUser = $auth->authenticateB(); // B端专用认证
        error_log('[B端任务列表] 认证成功，用户ID: ' . $currentUser['user_id']);
    } catch (Exception $e) {
        error_log('[B端任务列表] 认证失败: ' . $e->getMessage());
        throw $e;
    }
    
    $errorCodes = require __DIR__ . '/../../../../config/error_codes.php';
    
    // 获取请求参数
    $status = isset($_GET['status']) ? intval($_GET['status']) : null;
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $pageSize = isset($_GET['page_size']) ? max(1, min(100, intval($_GET['page_size']))) : 20;
    $offset = ($page - 1) * $pageSize;
    
    error_log('[B端任务列表] 处理参数 - status: ' . ($status ?? 'null') . ', page: ' . $page . ', page_size: ' . $pageSize);
    
    // 构建查询条件
    $whereClause = "bt.b_user_id = ?";
    $params = [$currentUser['user_id']];
    
    if ($status !== null && in_array($status, [0, 1, 2, 3], true)) {
        $whereClause .= " AND bt.status = ?";
        $params[] = $status;
    }
    
    // 1. 查询总数
    $countStmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM b_tasks bt
        WHERE {$whereClause}
    ");
    $countStmt->execute($params);
    $total = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 查询任务列表（分页）
    $stmt = $db->prepare("
        SELECT 
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
            bt.parent_task_id
        FROM b_tasks bt
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        WHERE {$whereClause}
        ORDER BY bt.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 格式化任务列表
    $statusTexts = [
        0 => '已过期',
        1 => '进行中',
        2 => '已完成',
        3 => '已取消'
    ];
    
    $stageTexts = [
        0 => '单任务',
        1 => '阶段1',
        2 => '阶段2'
    ];
    
    $stageStatusTexts = [
        0 => '未开放',
        1 => '已开放',
        2 => '已完成'
    ];
    
    $formattedTasks = [];
    foreach ($tasks as $task) {
        $status = (int)$task['status'];
        $taskCount = (int)$task['task_count'];
        $taskDone = (int)$task['task_done'];
        $taskDoing = (int)$task['task_doing'];
        $taskReviewing = (int)$task['task_reviewing'];
        $stage = (int)$task['stage'];
        $stageStatus = (int)$task['stage_status'];
        $templateType = (int)$task['template_type'];
        
        // 计算可接任务数和进度百分比
        $taskAvailable = max(0, $taskCount - $taskDone - $taskDoing - $taskReviewing);
        $progressPercent = $taskCount > 0 ? round(($taskDone / $taskCount) * 100, 2) : 0;
        
        // 判断是否是组合任务
        $isCombo = $templateType === 1;
        
        // 获取阶段标题
        $stageTitle = null;
        if ($isCombo) {
            if ($stage === 1) {
                $stageTitle = $task['stage1_title'];
            } elseif ($stage === 2) {
                $stageTitle = $task['stage2_title'];
            }
        }
        
        $formattedTask = [
            'task_id' => (int)$task['task_id'],
            'template_id' => (int)$task['template_id'],
            'template_title' => $task['template_title'],
            'template_type' => $templateType,
            'template_type_text' => $isCombo ? '组合任务' : '单任务',
            'video_url' => $task['video_url'],
            'deadline' => (int)$task['deadline'],
            'deadline_text' => date('Y-m-d H:i:s', $task['deadline']),
            'task_count' => $taskCount,
            'task_done' => $taskDone,
            'task_doing' => $taskDoing,
            'task_reviewing' => $taskReviewing,
            'task_available' => $taskAvailable,
            'progress_percent' => $progressPercent,
            'unit_price' => number_format($task['unit_price'], 2),
            'total_price' => number_format($task['total_price'], 2),
            'status' => $status,
            'status_text' => $statusTexts[$status] ?? '未知',
            'created_at' => $task['created_at'],
            'updated_at' => $task['updated_at'],
            'completed_at' => $task['completed_at'],
            'is_combo' => $isCombo,
            'stage' => $stage,
            'stage_text' => $stageTexts[$stage] ?? '未知',
            'stage_title' => $stageTitle,
            'stage_status' => $stageStatus,
            'stage_status_text' => $stageStatusTexts[$stageStatus] ?? '未知',
            'combo_task_id' => $task['combo_task_id'],
            'parent_task_id' => $task['parent_task_id'] ? (int)$task['parent_task_id'] : null
        ];
        
        // 如果是组合任务，添加阶段价格信息
        if ($isCombo) {
            $formattedTask['combo_info'] = [
                'stage1_title' => $task['stage1_title'],
                'stage1_price' => $task['stage1_price'] ? number_format($task['stage1_price'], 2) : null,
                'stage2_title' => $task['stage2_title'],
                'stage2_price' => $task['stage2_price'] ? number_format($task['stage2_price'], 2) : null
            ];
        }
        
        $formattedTasks[] = $formattedTask;
    }
    
    // 4. 返回结果
    Response::success([
        'tasks' => $formattedTasks,
        'pagination' => [
            'current_page' => $page,
            'page_size' => $pageSize,
            'total' => (int)$total,
            'total_pages' => ceil($total / $pageSize)
        ]
    ], '获取成功');
    
} catch (Exception $e) {
    error_log("B端任务列表错误: " . $e->getMessage());
    Response::error('获取任务列表失败', $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
