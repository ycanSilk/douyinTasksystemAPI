<?php
/**
 * C端我的任务列表接口
 *
 * GET /api/c/v1/tasks/my-tasks
 *
 * 请求头：
 * X-Token: <token> (C端)
 *
 * 查询参数（可选）：
 * - status: 状态筛选（1=进行中，2=待审核，3=已通过，4=已驳回，不传=全部）
 * - page: 页码（默认1）
 * - page_size: 每页数量（默认20）
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {
 *     "list": [
 *       {
 *         "record_id": 1,
 *         "b_task_id": 123,
 *         "template_title": "上评评论",
 *         "video_url": "https://...",
 *         "recommend_mark": {...},
 *         "comment_url": "https://...",
 *         "screenshot_url": ["http://..."],
 *         "reward_amount": "4.00",
 *         "status": 1,
 *         "status_text": "进行中",
 *         "reject_reason": null,
 *         "created_at": "2026-01-11 11:00:00",
 *         "submitted_at": null,
 *         "reviewed_at": null,
 *         "deadline": 1736524800,
 *         "time_remaining": 540
 *       }
 *     ],
 *     "pagination": {...}
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 错误码说明：
 * 1001 - 请求方法错误
 * 1002 - 数据库错误
 * 2001 - Token无效
 * 2002 - Token过期
 * 3003 - 用户不存在
 * 5000 - 系统错误
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/tasks/my-tasks');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C端我的任务列表请求开始 ===', [
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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';
$appConfig = require __DIR__ . '/../../../../config/app.php';

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

$statusFilter = isset($_GET['status']) && $_GET['status'] !== '' ? (int)$_GET['status'] : null;
$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = min(100, max(1, (int)($_GET['page_size'] ?? 20)));
$offset = ($page - 1) * $pageSize;

$requestLogger->debug('请求参数', [
    'user_id' => $currentUser['user_id'],
    'status' => $statusFilter,
    'page' => $page,
    'page_size' => $pageSize,
]);

try {
    $whereConditions = ["c.c_user_id = ?"];
    $params = [$currentUser['user_id']];

    if ($statusFilter !== null) {
        $whereConditions[] = "c.status = ?";
        $params[] = $statusFilter;
    }

    $whereClause = implode(' AND ', $whereConditions);

    $requestLogger->debug('查询总记录数');
    $stmt = $db->prepare("
        SELECT COUNT(*) as total
        FROM c_task_records c
        WHERE {$whereClause}
    ");
    $stmt->execute($params);
    $totalCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $requestLogger->debug('总记录数查询成功', ['total' => $totalCount]);

    $requestLogger->debug('查询任务记录列表');
    $stmt = $db->prepare("
        SELECT
            c.id as record_id,
            c.b_task_id,
            c.template_id,
            c.video_url,
            c.recommend_mark,
            c.comment_url,
            c.screenshot_url,
            c.status,
            c.reject_reason,
            c.reward_amount,
            c.created_at,
            c.submitted_at,
            c.reviewed_at,
            c.task_stage,
            c.task_stage_text,
            t.deadline,
            t.task_count,
            t.task_done,
            t.task_doing,
            t.task_reviewing,
            tm.title as template_title,
            c.update_at as update_at
        FROM c_task_records c
        LEFT JOIN b_tasks t ON c.b_task_id = t.id
        LEFT JOIN task_templates tm ON c.template_id = tm.id
        WHERE {$whereClause}
        ORDER BY c.created_at DESC
        LIMIT ? OFFSET ?
    ");

    $params[] = $pageSize;
    $params[] = $offset;
    $stmt->execute($params);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $requestLogger->debug('任务记录列表查询成功', ['count' => count($records)]);

    $statusTexts = [
        1 => '进行中',
        2 => '待审核',
        3 => '已通过',
        4 => '已驳回',
        5 => '已超时'
    ];

    $taskSubmitTimeout = (int)$appConfig['task_submit_timeout'];
    $currentTime = time();

    $formattedRecords = [];
    foreach ($records as $record) {
        $status = (int)$record['status'];
        $createdAt = strtotime($record['created_at']);
        $deadline = (int)$record['deadline'];

        $timeRemaining = null;
        $isTimeout = false;
        if ($status === 1) {
            $timeElapsed = $currentTime - $createdAt;
            $timeRemaining = max(0, $taskSubmitTimeout - $timeElapsed);
            $isTimeout = $timeRemaining <= 0;
        }

        $screenshots = null;
        if (!empty($record['screenshot_url'])) {
            $screenshots = json_decode($record['screenshot_url'], true);
        }

        $recommendMark = null;
        if (!empty($record['recommend_mark'])) {
            $recommendMark = json_decode($record['recommend_mark'], true);
        }

        $taskCount = (int)$record['task_count'];
        $taskDone = (int)$record['task_done'];
        $progressPercent = $taskCount > 0 ? round(($taskDone / $taskCount) * 100, 2) : 0;

        $formattedRecords[] = [
            'record_id' => (int)$record['record_id'],
            'b_task_id' => (int)$record['b_task_id'],
            'template_id' => (int)$record['template_id'],
            'template_title' => $record['template_title'],
            'video_url' => $record['video_url'],
            'recommend_mark' => $recommendMark,
            'comment_url' => $record['comment_url'],
            'screenshots' => $screenshots,
            'reward_amount' => number_format($record['reward_amount'] / 100, 2),
            'status' => $status,
            'status_text' => $statusTexts[$status] ?? '未知',
            'task_stage' => $record['task_stage'],
            'task_stage_text' => $record['task_stage_text'],
            'reject_reason' => $record['reject_reason'],
            'created_at' => $record['created_at'],
            'submitted_at' => $record['submitted_at'],
            'update_at' => $record['update_at'],
            'reviewed_at' => $record['reviewed_at'],
            'deadline' => $deadline,
            'deadline_text' => date('Y-m-d H:i:s', $deadline),
            'time_remaining' => $timeRemaining,
            'is_timeout' => $isTimeout,
            'task_progress' => [
                'task_count' => $taskCount,
                'task_done' => $taskDone,
                'task_doing' => (int)$record['task_doing'],
                'task_reviewing' => (int)$record['task_reviewing'],
                'task_available' => $taskCount - $taskDone - (int)$record['task_doing'] - (int)$record['task_reviewing'],
                'progress_percent' => $progressPercent
            ]
        ];
    }
    $requestLogger->debug('任务列表格式化完成', ['count' => count($formattedRecords)]);

    $totalPages = $totalCount > 0 ? (int)ceil($totalCount / $pageSize) : 0;

    $auditLogger->notice('C端用户获取任务列表成功', [
        'user_id' => $currentUser['user_id'],
        'total' => $totalCount,
        'status_filter' => $statusFilter,
        'page' => $page,
        'page_size' => $pageSize,
        'returned_count' => count($formattedRecords),
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    $requestLogger->info('C端获取任务列表成功', [
        'total' => $totalCount,
        'returned_count' => count($formattedRecords),
    ]);

    Response::success([
        'list' => $formattedRecords,
        'pagination' => [
            'page' => $page,
            'page_size' => $pageSize,
            'total' => $totalCount,
            'total_pages' => $totalPages
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