<?php
/**
 * C端获取任务池列表接口
 *
 * GET /api/c/v1/tasks
 *
 * 请求头：
 * X-Token: <token> (C端)
 *
 * 查询参数：
 * - page: 页码（默认1）
 * - limit: 每页数量（默认20）
 * - status: 状态筛选（1=进行中，2=已完成，默认1）
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "获取成功",
 *   "data": {
 *     "list": [
 *       {
 *         "id": 1,
 *         "template_id": 1,
 *         "title": "上评评论任务",
 *         "is_combo": false,
 *         "stage": 0,
 *         "stage_text": "单任务",
 *         "video_url": "https://...",
 *         "deadline": 1736582400,
 *         "task_count": 100,
 *         "task_done": 50,
 *         "task_doing": 10,
 *         "task_reviewing": 5,
 *         "remain_count": 35,
 *         "unit_price": "4.00",
 *         "reward_amount": "2.28",
 *         "commission": "2.28",
 *         "total_price": "400.00",
 *         "status": 1,
 *         "has_accepted": false,
 *         "created_at": "2026-01-11 12:00:00"
 *       }
 *     ],
 *     "pagination": {
 *       "page": 1,
 *       "limit": 20,
 *       "total": 100,
 *       "total_pages": 5
 *     }
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 错误码说明：
 * 1001 - 请求方法错误
 * 1002 - 数据库错误
 * 2001 - Token无效
 * 2002 - Token过期
 * 4003 - 权限不足
 * 5000 - 系统错误
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/tasks');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C端获取任务池列表请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户获取任务列表失败：请求方法错误', [
        'reason' => '请求方法错误',
    ]);

    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$requestLogger->debug('读取请求体');
$requestBody = file_get_contents('php://input');
$requestLogger->debug('请求体内容', ['body' => $requestBody]);

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C端用户获取任务列表失败：数据库连接失败', [
        'exception' => $e->getMessage(),
        'reason' => '数据库连接失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => $errorCodes['DATABASE_ERROR'] ?? 1002,
        'message' => '数据库连接失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token认证失败', ['exception' => $e->getMessage()]);

    $auditLogger->warning('C端用户获取任务列表失败：Token认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token认证失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => $errorCodes['AUTH_TOKEN_INVALID'] ?? 2001,
        'message' => '认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$page = max(1, (int)($_GET['page'] ?? 1));
$limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
$statusFilter = (int)($_GET['status'] ?? 1);
$offset = ($page - 1) * $limit;

$requestLogger->debug('请求参数', [
    'user_id' => $currentUser['user_id'],
    'page' => $page,
    'limit' => $limit,
    'status' => $statusFilter,
]);

try {
    $taskTable = 'b_tasks';
    $requestLogger->debug('从b_tasks表查询任务');

    $requestLogger->debug('查询任务列表');
    $stmt = $db->prepare("
        SELECT
            t.id,
            t.combo_task_id,
            t.stage,
            t.stage_status,
            t.parent_task_id,
            t.template_id,
            t.video_url,
            t.deadline,
            t.task_count,
            t.task_done,
            t.task_doing,
            t.task_reviewing,
            t.unit_price,
            t.total_price,
            t.status,
            t.created_at,
            tm.id AS template_id,
            tm.title AS template_title,
            tm.type AS template_type,
            tm.stage1_title,
            tm.stage2_title,
            tm.c_user_commission,
            tm.stage1_c_user_commission,
            tm.stage2_c_user_commission
        FROM $taskTable t
        LEFT JOIN task_templates tm ON t.template_id = tm.id
        WHERE t.stage_status = 1
          AND t.status = ?
          AND t.deadline > ?
          AND (t.task_count - t.task_done - t.task_doing - t.task_reviewing) > 0
        ORDER BY t.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$statusFilter, time(), $limit, $offset]);
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('任务列表查询成功', ['count' => count($tasks)]);

    $acceptedTaskIds = [];
    if (!empty($tasks)) {
        $taskIds = array_column($tasks, 'id');
        $placeholders = implode(',', array_fill(0, count($taskIds), '?'));
        $acceptedStmt = $db->prepare("
            SELECT DISTINCT b_task_id FROM c_task_records
            WHERE c_user_id = ? AND b_task_id IN ({$placeholders})
        ");
        $acceptedStmt->execute(array_merge([$currentUser['user_id']], $taskIds));
        $acceptedTaskIds = array_column($acceptedStmt->fetchAll(PDO::FETCH_ASSOC), 'b_task_id');
    }
    $requestLogger->debug('用户已接任务ID', ['count' => count($acceptedTaskIds)]);

    $requestLogger->debug('统计总数');
    $stmt = $db->prepare("
        SELECT COUNT(*) AS total
        FROM $taskTable
        WHERE stage_status = 1
          AND status = ?
          AND deadline > ?
          AND (task_count - task_done - task_doing - task_reviewing) > 0
    ");
    $stmt->execute([$statusFilter, time()]);
    $total = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('总数查询成功', ['total' => $total]);

    $taskList = [];
    foreach ($tasks as $task) {
        $isCombo = !empty($task['combo_task_id']);
        $stage = (int)$task['stage'];

        $taskTitle = $task['template_title'];
        if ($isCombo && $stage == 1 && $task['stage1_title']) {
            $taskTitle = $task['stage1_title'];
        } elseif ($isCombo && $stage == 2 && $task['stage2_title']) {
            $taskTitle = $task['stage2_title'];
        }

        $remainCount = (int)$task['task_count'] - (int)$task['task_done'] - (int)$task['task_doing'] - (int)$task['task_reviewing'];

        $unitPrice = (float)$task['unit_price'];
        if ($stage === 1) {
            $rewardAmount = (int)($task['stage1_c_user_commission'] ?? 0);
        } elseif ($stage === 2) {
            $rewardAmount = (int)($task['stage2_c_user_commission'] ?? 0);
        } else {
            $rewardAmount = (int)($task['c_user_commission'] ?? 0);
        }
        $rewardAmountYuan = number_format($rewardAmount / 100, 2);

        $taskList[] = [
            'id' => (int)$task['id'],
            'template_id' => (int)$task['template_id'],
            'title' => $taskTitle,
            'is_combo' => $isCombo,
            'stage' => $stage,
            'stage_text' => $stage == 0 ? '单任务' : ($stage == 1 ? '阶段1' : '阶段2'),
            'video_url' => $task['video_url'],
            'deadline' => (int)$task['deadline'],
            'deadline_text' => date('Y-m-d H:i:s', $task['deadline']),
            'task_count' => (int)$task['task_count'],
            'task_done' => (int)$task['task_done'],
            'task_doing' => (int)$task['task_doing'],
            'task_reviewing' => (int)$task['task_reviewing'],
            'remain_count' => max(0, $remainCount),
            'unit_price' => number_format($unitPrice, 2),
            'reward_amount' => $rewardAmountYuan,
            'commission' => $rewardAmountYuan,
            'total_price' => number_format((float)$task['total_price'], 2),
            'status' => (int)$task['status'],
            'has_accepted' => in_array($task['id'], $acceptedTaskIds),
            'created_at' => $task['created_at']
        ];
    }
    $requestLogger->debug('任务列表格式化完成', ['count' => count($taskList)]);

    $auditLogger->notice('C端用户获取任务列表成功', [
        'user_id' => $currentUser['user_id'],
        'total' => $total,
        'returned_count' => count($taskList),
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    $requestLogger->info('C端获取任务列表成功', [
        'total' => $total,
        'returned_count' => count($taskList),
    ]);

    Response::success([
        'list' => $taskList,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);

} catch (PDOException $e) {
    $errorLogger->error('查询失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户获取任务列表失败：数据库异常', [
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('查询失败', $errorCodes['DATABASE_ERROR'] ?? 1002, 500);
} catch (Exception $e) {
    $errorLogger->error('查询失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户获取任务列表失败：系统异常', [
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('查询失败', $errorCodes['SYSTEM_ERROR'] ?? 5000, 500);
}