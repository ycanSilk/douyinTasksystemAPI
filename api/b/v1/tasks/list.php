<?php
/**
 * B 端任务列表接口
 * 
 * GET /api/b/v1/tasks/list
 * 
 * 请求头：
 * X-Token: <token> (B 端)
 * 
 * 请求参数：
 * - status (可选): 任务状态筛选 0=已过期 1=进行中 2=已完成 3=已取消
 * - page (可选): 页码，默认 1
 * - page_size (可选): 每页数量，默认 20
 * 
 * 请求示例：
 * GET /api/b/v1/tasks/list?status=1&page=1&page_size=20
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "获取成功",
 *   "data": {
 *     "tasks": [
 *       {
 *         "task_id": 1,
 *         "template_id": 5,
 *         "template_title": "抖音点赞任务",
 *         "template_type": 0,
 *         "template_type_text": "单任务",
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
 *         "is_combo": false,
 *         "stage": 0,
 *         "stage_text": "单任务",
 *         "stage_status": 1,
 *         "stage_status_text": "已开放",
 *         "combo_task_id": null,
 *         "parent_task_id": null,
 *         "is_newbie": false,
 *         "is_newbie_text": "普通任务",
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
 * 
 * 响应示例（失败）：
 * {
 *   "code": 5001,
 *   "message": "数据库连接失败",
 *   "data": []
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4012 - 用户认证失败
 * 5001 - 数据库错误
 * 5002 - 获取任务列表失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/tasks/list');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');

// 记录请求开始
$requestLogger->info('=== B 端任务列表请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';

// 记录请求体
try {
    $rawInput = file_get_contents('php://input');
    $requestLogger->debug('请求体内容', ['body' => $rawInput]);
} catch (Exception $e) {
    $errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()]);
    $rawInput = '';
}

// 记录 GET 参数
$requestLogger->debug('查询参数', ['get_params' => $_GET]);

try {
    // 数据库连接
    try {
        $db = Database::connect();
        $requestLogger->debug('数据库连接成功');
    } catch (Exception $e) {
        $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);
        echo json_encode([
            'code' => 5001,
            'message' => '数据库连接失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // Token 认证
    try {
        $auth = new AuthMiddleware($db);
        $currentUser = $auth->authenticateB(); // B 端专用认证
        $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
    } catch (Exception $e) {
        $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);
        echo json_encode([
            'code' => 4012,
            'message' => '用户认证失败',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 获取请求参数
    $status = isset($_GET['status']) ? intval($_GET['status']) : null;
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $pageSize = isset($_GET['page_size']) ? max(1, min(100, intval($_GET['page_size']))) : 20;
    $offset = ($page - 1) * $pageSize;
    
    // 记录请求参数
    $requestLogger->debug('请求参数', [
        'status' => $status,
        'page' => $page,
        'page_size' => $pageSize,
        'offset' => $offset
    ]);
    
    // 构建查询条件
    $whereClause = "bt.b_user_id = ?";
    $params = [$currentUser['user_id']];
    
    if ($status !== null && in_array($status, [0, 1, 2, 3], true)) {
        $whereClause .= " AND bt.status = ?";
        $params[] = $status;
        $requestLogger->debug('添加状态筛选条件', ['status' => $status]);
    }
    
    // 1. 查询 b_tasks 表的总数
    $countStmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM b_tasks bt
        WHERE {$whereClause}
    ");
    $countStmt->execute($params);
    $totalBTasks = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('b_tasks 表查询结果', ['total' => $totalBTasks]);
    
    // 2. 查询 b_newbie_tasks 表的总数
    $countStmtNewbie = $db->prepare("
        SELECT COUNT(*) as total
        FROM b_newbie_tasks bt
        WHERE {$whereClause}
    ");
    $countStmtNewbie->execute($params);
    $totalNewbieTasks = $countStmtNewbie->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('b_newbie_tasks 表查询结果', ['total' => $totalNewbieTasks]);
    
    // 3. 计算总数
    $total = $totalBTasks + $totalNewbieTasks;
    
    // 4. 查询 b_tasks 表任务列表（分页）
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
            0 AS is_newbie
        FROM b_tasks bt
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        WHERE {$whereClause}
        ORDER BY bt.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $bTasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('b_tasks 表任务列表查询成功', ['count' => count($bTasks)]);
    
    // 5. 查询 b_newbie_tasks 表任务列表（分页）
    $stmtNewbie = $db->prepare("
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
            1 AS is_newbie
        FROM b_newbie_tasks bt
        INNER JOIN task_templates tt ON bt.template_id = tt.id
        WHERE {$whereClause}
        ORDER BY bt.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $paramsNewbie = $params;
    $stmtNewbie->execute($paramsNewbie);
    $newbieTasks = $stmtNewbie->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('b_newbie_tasks 表任务列表查询成功', ['count' => count($newbieTasks)]);
    
    // 6. 合并两个表的结果
    $tasks = array_merge($bTasks, $newbieTasks);
    
    // 7. 对合并后的结果按 created_at 降序排序
    usort($tasks, function($a, $b) {
        return strtotime($b['created_at']) - strtotime($a['created_at']);
    });
    
    // 8. 对排序后的结果进行分页
    $tasks = array_slice($tasks, $offset, $pageSize);
    
    // 9. 格式化任务列表
    $statusTexts = [
        0 => '已过期',
        1 => '进行中',
        2 => '已完成',
        3 => '已取消'
    ];
    
    $stageTexts = [
        0 => '单任务',
        1 => '阶段 1',
        2 => '阶段 2'
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
        $isNewbie = (int)($task['is_newbie'] ?? 0);
        
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
            'parent_task_id' => $task['parent_task_id'] ? (int)$task['parent_task_id'] : null,
            'is_newbie' => $isNewbie === 1,
            'is_newbie_text' => $isNewbie === 1 ? '新手任务' : '普通任务'
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
    
    $requestLogger->debug('任务列表格式化完成', ['formatted_count' => count($formattedTasks)]);
    
    // 10. 返回结果
    $requestLogger->info('任务列表获取成功', [
        'total' => $total,
        'page' => $page,
        'page_size' => $pageSize,
        'returned_count' => count($formattedTasks)
    ]);
    
    echo json_encode([
        'code' => 0,
        'message' => '获取成功',
        'data' => [
            'tasks' => $formattedTasks,
            'pagination' => [
                'current_page' => $page,
                'page_size' => $pageSize,
                'total' => (int)$total,
                'total_pages' => ceil($total / $pageSize)
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // 回滚事务（如果有）
    if (isset($db) && $db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('获取任务列表失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    echo json_encode([
        'code' => 5002,
        'message' => '获取任务列表失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
