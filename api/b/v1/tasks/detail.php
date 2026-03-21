<?php
/**
 * B端任务详情
 * GET /api/b/v1/tasks/detail
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求参数：
 * - task_id (必填): 任务ID
 * - page (可选): 页码，默认1
 * - page_size (可选): 每页数量，默认10
 * 
 * 响应示例：
 * {
 *   "code": 200,
 *   "message": "获取成功",
 *   "data": {
 *     "task_id": 218,
 *     "template_id": 2,
 *     "template_title": "中评评论",
 *     "template_type": 0,
 *     "template_type_text": "单任务",
 *     "video_url": "https://www.douyin.com/jingxuan?modal_id=7577335582393699638",
 *     "deadline": 1796058061,
 *     "deadline_text": "2026-12-01 01:01:01",
 *     "task_count": 3,
 *     "task_done": 0,
 *     "task_doing": 0,
 *     "task_reviewing": 0,
 *     "task_available": 3,
 *     "progress_percent": 0,
 *     "unit_price": "2.00",
 *     "total_price": "6.00",
 *     "status": 1,
 *     "status_text": "进行中",
 *     "created_at": "2026-03-21 14:43:12",
 *     "updated_at": "2026-03-21 14:43:12",
 *     "completed_at": null,
 *     "is_combo": false,
 *     "stage": 0,
 *     "stage_text": "单任务",
 *     "stage_title": null,
 *     "stage_status": 1,
 *     "stage_status_text": "已开放",
 *     "combo_task_id": null,
 *     "parent_task_id": null,
 *     "task_list": [
 *       {
 *         "b_task_id": 218,
 *         "task_list_id": 1,
 *         "deadline": 1796058061,
 *         "recommend_marks": {
 *           "comment": "测试大团团长的任务奖励和佣金",
 *           "image_url": ""
 *         },
 *         "status": 1,
 *         "unit_price": "2.00",
 *         "video_url": "",
 *         "stage": 0,
 *         "stage_text": "单任务",
 *         "stage_title": null,
 *         "stage_status": 1,
 *         "stage_status_text": "已开放"
 *       }
 *     ],
 *     "pagination": {
 *       "current_page": 1,
 *       "page_size": 10,
 *       "total": 3,
 *       "total_pages": 1
 *     },
 *     "records": []
 *   },
 *   "timestamp": 1774076513
 * }
 */

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';
require_once __DIR__ . '/../../../../config/error_codes.php';

// 调试日志
error_log('[B端任务详情] 请求开始 - ' . $_SERVER['REQUEST_URI']);
error_log('[B端任务详情] 请求头: ' . json_encode(getallheaders(), JSON_UNESCAPED_UNICODE));
error_log('[B端任务详情] 查询参数: ' . json_encode($_GET, JSON_UNESCAPED_UNICODE));

try {
    // 数据库连接
    try {
        $db = Database::connect();
        error_log('[B端任务详情] 数据库连接成功');
    } catch (Exception $e) {
        error_log('[B端任务详情] 数据库连接失败: ' . $e->getMessage());
        throw $e;
    }
    
    // Token 认证
    try {
        $auth = new AuthMiddleware($db);
        $currentUser = $auth->authenticateB(); // B端专用认证
        error_log('[B端任务详情] 认证成功，用户ID: ' . $currentUser['user_id']);
    } catch (Exception $e) {
        error_log('[B端任务详情] 认证失败: ' . $e->getMessage());
        throw $e;
    }
    
    $errorCodes = require __DIR__ . '/../../../../config/error_codes.php';
    
    // 获取请求参数
    if (!isset($_GET['task_id']) || empty($_GET['task_id'])) {
        Response::error('任务ID不能为空', $errorCodes['PARAM_ERROR'] ?? 4000);
    }
    
    $taskId = intval($_GET['task_id']);
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $pageSize = isset($_GET['page_size']) ? max(1, min(100, intval($_GET['page_size']))) : 10;
    $offset = ($page - 1) * $pageSize;
    
    error_log('[B端任务详情] 处理参数 - task_id: ' . $taskId . ', page: ' . $page . ', page_size: ' . $pageSize);
    
    // 查询任务详情
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
            bt.parent_task_id,
            bt.recommend_marks
        FROM b_tasks bt
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        WHERE bt.id = ? AND bt.b_user_id = ?
    ");
    
    $stmt->execute([$taskId, $currentUser['user_id']]);
    $task = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$task) {
        Response::error('任务不存在或无权查看', $errorCodes['NOT_FOUND'] ?? 4040);
    }
    
    // 格式化任务信息
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
    
    // 处理推荐评论数据
    $recommendMarks = [];
    if (!empty($task['recommend_marks'])) {
        $recommendMarks = json_decode($task['recommend_marks'], true) ?: [];
    }
    
    // 从数据库查询任务列表（实际数据）
    $taskList = [];
    $totalTaskList = $taskCount;
    $totalPages = ceil($totalTaskList / $pageSize);
    
    // 计算分页范围
    $startIndex = ($page - 1) * $pageSize;
    $endIndex = $startIndex + $pageSize;
    
    // 查询当前任务的C端任务记录，用于匹配到对应的任务列表项
    $taskRecordsMap = [];
    $recordStmt = $db->prepare("
        SELECT 
            cr.id AS record_id,
            cr.b_task_id,
            cr.c_user_id,
            cu.username AS c_username,
            cu.email AS c_email,
            tt.title AS template_title,
            cr.video_url,
            cr.recommend_mark,
            cr.comment_url,
            cr.screenshot_url,
            cr.reward_amount,
            cr.task_stage,
            cr.task_stage_text,
            cr.submitted_at
        FROM c_task_records cr
        LEFT JOIN c_users cu ON cr.c_user_id = cu.id
        LEFT JOIN task_templates tt ON cr.template_id = tt.id
        WHERE cr.b_task_id = ? AND cr.b_user_id = ?
    ");
    $recordStmt->execute([$taskId, $currentUser['user_id']]);
    $records = $recordStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 构建任务记录映射，便于后续匹配
    foreach ($records as $record) {
        // 这里假设任务记录的顺序与任务列表的顺序一致
        $index = count($taskRecordsMap);
        $taskRecordsMap[$index] = $record;
    }
    
    // 从推荐评论数据中获取任务列表
    if (!empty($recommendMarks)) {
        // 按分页获取数据
        $paginatedMarks = array_slice($recommendMarks, $startIndex, $pageSize);
        
        foreach ($paginatedMarks as $index => $mark) {
            $taskListId = $startIndex + $index + 1;
            $taskItem = [
                'b_task_id' => (int)$task['task_id'],
                'task_list_id' => $taskListId,
                'deadline' => (int)$task['deadline'],
                'recommend_marks' => [
                    'comment' => isset($mark['comment']) ? $mark['comment'] : '',
                    'image_url' => isset($mark['image_url']) ? $mark['image_url'] : ''
                ],
                'status' => 0, // 默认状态为0（待领取）
                'unit_price' => number_format($task['unit_price'], 2),
                'video_url' => '',
                'stage' => $stage,
                'stage_text' => $stageTexts[$stage] ?? '未知',
                'stage_title' => $stageTitle,
                'stage_status' => $stageStatus,
                'stage_status_text' => $stageStatusTexts[$stageStatus] ?? '未知'
            ];
            
            // 添加提交任务后的字段信息（如果有对应的记录）
            if (isset($taskRecordsMap[$index])) {
                $record = $taskRecordsMap[$index];
                $screenshots = [];
                if (!empty($record['screenshot_url'])) {
                    $screenshots = json_decode($record['screenshot_url'], true) ?: [];
                }
                $recommendMark = [];
                if (!empty($record['recommend_mark'])) {
                    $recommendMark = json_decode($record['recommend_mark'], true) ?: [];
                }
                
                $taskItem['record_id'] = (int)$record['record_id'];
                $taskItem['c_user_id'] = (int)$record['c_user_id'];
                $taskItem['c_username'] = $record['c_username'];
                $taskItem['c_email'] = $record['c_email'];
                $taskItem['template_title'] = $record['template_title'];
                $taskItem['video_url'] = $record['video_url'];
                $taskItem['recommend_mark'] = $recommendMark;
                $taskItem['comment_url'] = $record['comment_url'];
                $taskItem['screenshots'] = $screenshots;
                $taskItem['reward_amount'] = number_format($record['reward_amount'] / 100, 2); // 转换为元
                $taskItem['task_stage'] = (int)$record['task_stage'];
                $taskItem['task_stage_text'] = $record['task_stage_text'];
                $taskItem['submitted_at'] = $record['submitted_at'];
                $taskItem['status'] = 2; // 已提交待审核状态
            }
            
            $taskList[] = $taskItem;
        }
    }
    
    // 如果没有推荐评论数据，根据task_count生成任务列表
    if (empty($taskList) && $taskCount > 0) {
        $startTaskId = ($page - 1) * $pageSize + 1;
        $endTaskId = min($startTaskId + $pageSize - 1, $taskCount);
        
        for ($i = $startTaskId; $i <= $endTaskId; $i++) {
            $index = $i - $startTaskId;
            $taskItem = [
                'b_task_id' => (int)$task['task_id'],
                'task_list_id' => $i,
                'deadline' => (int)$task['deadline'],
                'recommend_marks' => [
                    'comment' => '',
                    'image_url' => ''
                ],
                'status' => 0, // 默认状态为0（待领取）
                'unit_price' => number_format($task['unit_price'], 2),
                'video_url' => '',
                'stage' => $stage,
                'stage_text' => $stageTexts[$stage] ?? '未知',
                'stage_title' => $stageTitle,
                'stage_status' => $stageStatus,
                'stage_status_text' => $stageStatusTexts[$stageStatus] ?? '未知'
            ];
            
            // 添加提交任务后的字段信息（如果有对应的记录）
            if (isset($taskRecordsMap[$index])) {
                $record = $taskRecordsMap[$index];
                $screenshots = [];
                if (!empty($record['screenshot_url'])) {
                    $screenshots = json_decode($record['screenshot_url'], true) ?: [];
                }
                $recommendMark = [];
                if (!empty($record['recommend_mark'])) {
                    $recommendMark = json_decode($record['recommend_mark'], true) ?: [];
                }
                
                $taskItem['record_id'] = (int)$record['record_id'];
                $taskItem['c_user_id'] = (int)$record['c_user_id'];
                $taskItem['c_username'] = $record['c_username'];
                $taskItem['c_email'] = $record['c_email'];
                $taskItem['template_title'] = $record['template_title'];
                $taskItem['video_url'] = $record['video_url'];
                $taskItem['recommend_mark'] = $recommendMark;
                $taskItem['comment_url'] = $record['comment_url'];
                $taskItem['screenshots'] = $screenshots;
                $taskItem['reward_amount'] = number_format($record['reward_amount'] / 100, 2); // 转换为元
                $taskItem['task_stage'] = (int)$record['task_stage'];
                $taskItem['task_stage_text'] = $record['task_stage_text'];
                $taskItem['submitted_at'] = $record['submitted_at'];
                $taskItem['status'] = 2; // 已提交待审核状态
            }
            
            $taskList[] = $taskItem;
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
        'parent_task_id' => $task['parent_task_id'] ? (int)$task['parent_task_id'] : null,
        'task_list' => $taskList,
        'pagination' => [
            'current_page' => $page,
            'page_size' => $pageSize,
            'total' => $totalTaskList,
            'total_pages' => $totalPages
        ]
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
    
    // 查询当前任务的C端任务记录
    $taskRecords = [];
    $recordStmt = $db->prepare("
        SELECT 
            cr.id AS record_id,
            cr.c_user_id,
            cu.username AS c_username,
            cr.status AS record_status,
            cr.comment_url,
            cr.screenshot_url,
            cr.submitted_at,
            cr.reviewed_at,
            cr.reject_reason
        FROM c_task_records cr
        LEFT JOIN c_users cu ON cr.c_user_id = cu.id
        WHERE cr.b_task_id = ? AND cr.b_user_id = ?
        ORDER BY cr.created_at DESC
    ");
    $recordStmt->execute([$taskId, $currentUser['user_id']]);
    $records = $recordStmt->fetchAll(PDO::FETCH_ASSOC);
    
    $recordStatusTexts = [
        1 => '进行中',
        2 => '待审核',
        3 => '已通过',
        4 => '已驳回',
        5 => '已超时'
    ];
    
    foreach ($records as $record) {
        $recordStatus = (int)$record['record_status'];
        $screenshots = [];
        if (!empty($record['screenshot_url'])) {
            $screenshots = json_decode($record['screenshot_url'], true) ?: [];
        }
        
        $taskRecords[] = [
            'record_id' => (int)$record['record_id'],
            'c_user_id' => (int)$record['c_user_id'],
            'c_username' => $record['c_username'],
            'status' => $recordStatus,
            'status_text' => $recordStatusTexts[$recordStatus] ?? '未知',
            'comment_url' => $record['comment_url'],
            'screenshots' => $screenshots,
            'submitted_at' => $record['submitted_at'],
            'reviewed_at' => $record['reviewed_at'],
            'reject_reason' => $record['reject_reason']
        ];
    }
    
    $formattedTask['records'] = $taskRecords;
    
    // 返回结果
    Response::success($formattedTask, '获取成功');
    
} catch (Exception $e) {
    error_log("B端任务详情错误: " . $e->getMessage());
    Response::error('获取任务详情失败', $errorCodes['SYSTEM_ERROR'] ?? 5000);
}