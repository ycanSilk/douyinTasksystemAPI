<?php
/**
 * C端提交任务接口
 *
 * POST /api/c/v1/tasks/submit
 *
 * 请求头：
 * X-Token: <token> (C端)
 *
 * 请求体：
 * {
 *   "b_task_id": 123,
 *   "record_id": 456,
 *   "comment_url": "https://douyin.com/comment/",
 *   "screenshots": [
 *     "http://example.com/img/screenshot1.jpg",
 *     "http://example.com/img/screenshot2.jpg",
 *     "http://example.com/img/screenshot3.jpg"
 *   ]
 * }
 *
 * 返回数据：
 * {
 *   "code": 0,
 *   "message": "任务提交成功，等待审核",
 *   "data": {
 *     "record_id": 123,
 *     "status": 2,
 *     "status_text": "待审核",
 *     "submitted_at": "2026-01-11 12:00:00"
 *   },
 *   "timestamp": 1736582400
 * }
 *
 * 提交规则：
 * 1. 只能提交 status=1(doing) 的任务
 * 2. 接单后超时未提交，自动释放（配置：task_submit_timeout，默认10分钟）
 * 3. 提交图片最多3张（数组URL）
 * 4. 提交成功后：
 *    - c_task_records.status: 1 → 2
 *    - b_tasks.task_doing -1, task_reviewing +1
 *    - c_user_daily_stats.submit_count +1
 *    - 用户可以继续接其他任务
 *
 * 错误码说明：
 * 1001 - 请求方法错误
 * 1002 - 数据库错误
 * 2001 - Token无效
 * 2002 - Token过期
 * 4003 - 权限不足
 * 5000 - 系统错误
 * 9006 - 任务记录不存在或参数不匹配
 * 9007 - 任务状态无效
 * 9008 - 接单后超过N分钟未提交，任务已超时
 * 9009 - 截图必须是数组格式
 * 9010 - 截图最多3张
 * 9011 - 至少需要提交1张截图
 * 9012 - 任务提交失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('c/v1/tasks/submit');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== C端提交任务接口请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('C端用户提交任务失败：请求方法错误', [
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

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';
$appConfig = require __DIR__ . '/../../../../config/app.php';

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('C端用户提交任务失败：数据库连接失败', [
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

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateC();
    $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token认证失败', ['exception' => $e->getMessage()]);

    $auditLogger->warning('C端用户提交任务失败：Token认证失败', [
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

// 获取请求参数
$requestLogger->debug('获取请求参数');
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$commentUrl = trim($input['comment_url'] ?? '');
$screenshots = $input['screenshots'] ?? [];

$requestLogger->debug('请求参数', [
    'b_task_id' => $bTaskId,
    'record_id' => $recordId,
    'has_comment_url' => !empty($commentUrl),
    'screenshots_count' => count($screenshots),
]);

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    $requestLogger->warning('任务ID为空或无效', ['b_task_id' => $bTaskId]);

    $auditLogger->warning('C端用户提交任务失败：任务ID无效', [
        'user_id' => $currentUser['user_id'],
        'b_task_id' => $bTaskId,
        'reason' => '任务ID为空或无效',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($recordId) || !is_numeric($recordId)) {
    $requestLogger->warning('任务记录ID为空或无效', ['record_id' => $recordId]);

    $auditLogger->warning('C端用户提交任务失败：任务记录ID无效', [
        'user_id' => $currentUser['user_id'],
        'record_id' => $recordId,
        'reason' => '任务记录ID为空或无效',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('任务记录ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($commentUrl)) {
    $requestLogger->warning('评论链接为空');

    $auditLogger->warning('C端用户提交任务失败：评论链接为空', [
        'user_id' => $currentUser['user_id'],
        'reason' => '评论链接为空',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('评论链接不能为空', $errorCodes['INVALID_PARAMS']);
}

// 校验截图
if (!is_array($screenshots)) {
    $requestLogger->warning('截图格式无效', ['screenshots_type' => gettype($screenshots)]);

    $auditLogger->warning('C端用户提交任务失败：截图格式无效', [
        'user_id' => $currentUser['user_id'],
        'reason' => '截图必须是数组格式',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('截图必须是数组格式', $errorCodes['TASK_SUBMIT_SCREENSHOTS_INVALID']);
}

if (count($screenshots) > 3) {
    $requestLogger->warning('截图数量超限', ['screenshots_count' => count($screenshots)]);

    $auditLogger->warning('C端用户提交任务失败：截图数量超限', [
        'user_id' => $currentUser['user_id'],
        'screenshots_count' => count($screenshots),
        'reason' => '截图最多3张',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('截图最多3张', $errorCodes['TASK_SUBMIT_SCREENSHOTS_INVALID']);
}

if (empty($screenshots)) {
    $requestLogger->warning('截图为空');

    $auditLogger->warning('C端用户提交任务失败：截图为空', [
        'user_id' => $currentUser['user_id'],
        'reason' => '至少需要提交1张截图',
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('至少需要提交1张截图', $errorCodes['TASK_SUBMIT_SCREENSHOTS_INVALID']);
}

$requestLogger->debug('参数校验通过');

try {
    // 1. 查询任务记录
    $requestLogger->debug('查询任务记录', [
        'record_id' => $recordId,
        'b_task_id' => $bTaskId,
    ]);
    $stmt = $db->prepare("
        SELECT id, c_user_id, b_task_id, status, created_at
        FROM c_task_records
        WHERE id = ? AND b_task_id = ?
    ");
    $stmt->execute([$recordId, $bTaskId]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$record) {
        $requestLogger->warning('任务记录不存在或参数不匹配', [
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
        ]);

        $auditLogger->warning('C端用户提交任务失败：任务记录不存在', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'reason' => '任务记录不存在或参数不匹配',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('任务记录不存在或参数不匹配', $errorCodes['TASK_SUBMIT_NOT_FOUND']);
    }

    $requestLogger->debug('任务记录查询成功', [
        'record_id' => $record['id'],
        'status' => $record['status'],
    ]);

    // 2. 校验是否是当前用户的任务
    $requestLogger->debug('校验任务归属', [
        'record_user_id' => $record['c_user_id'],
        'current_user_id' => $currentUser['user_id'],
    ]);
    if ((int)$record['c_user_id'] !== $currentUser['user_id']) {
        $requestLogger->warning('无权操作此任务', [
            'record_user_id' => $record['c_user_id'],
            'current_user_id' => $currentUser['user_id'],
        ]);

        $auditLogger->warning('C端用户提交任务失败：无权操作', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'record_user_id' => $record['c_user_id'],
            'reason' => '无权操作此任务',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error('无权操作此任务', $errorCodes['TASK_SUBMIT_NOT_FOUND']);
    }

    $requestLogger->debug('任务归属校验通过');

    // 3. 校验任务状态（只能提交 doing 状态的任务）
    $requestLogger->debug('校验任务状态', ['status' => $record['status']]);
    if ((int)$record['status'] !== 1) {
        $statusTexts = [1 => '进行中', 2 => '待审核', 3 => '已通过', 4 => '已驳回', 5 => '已超时'];
        $currentStatusText = $statusTexts[(int)$record['status']] ?? '未知';

        $requestLogger->warning('任务状态无效', [
            'status' => $record['status'],
            'status_text' => $currentStatusText,
        ]);

        $auditLogger->warning('C端用户提交任务失败：任务状态无效', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'status' => $record['status'],
            'status_text' => $currentStatusText,
            'reason' => '任务状态无效',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("该任务当前状态为：{$currentStatusText}，无法提交", $errorCodes['TASK_SUBMIT_INVALID_STATUS']);
    }

    $requestLogger->debug('任务状态校验通过');

    // 4. 校验是否超时
    $timeout = (int)$appConfig['task_submit_timeout'];
    $acceptTime = strtotime($record['created_at']);
    $currentTime = time();
    $elapsedTime = $currentTime - $acceptTime;

    $requestLogger->debug('校验超时', [
        'timeout' => $timeout,
        'accept_time' => $record['created_at'],
        'elapsed_time' => $elapsedTime,
    ]);

    if ($elapsedTime > $timeout) {
        $requestLogger->warning('任务已超时', [
            'elapsed_time' => $elapsedTime,
            'timeout' => $timeout,
        ]);

        // 超时，更新状态为5（已超时）
        $db->beginTransaction();
        $requestLogger->debug('开启事务（超时处理）');

        // 更新任务记录状态为已超时
        $stmt = $db->prepare("UPDATE c_task_records SET status = 5, update_at = NOW() WHERE id = ?");
        $stmt->execute([$recordId]);
        $requestLogger->debug('任务记录状态更新为已超时', ['record_id' => $recordId]);

        // 更新b_tasks表
        $requestLogger->debug('查询任务当前task_doing', ['b_task_id' => $bTaskId]);
        $stmt = $db->prepare("SELECT task_doing FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
        $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
        $newTaskDoing = max($currentTaskDoing - 1, 0);

        $requestLogger->debug('更新任务task_doing', [
            'b_task_id' => $bTaskId,
            'old_doing' => $currentTaskDoing,
            'new_doing' => $newTaskDoing,
        ]);

        $stmt = $db->prepare("
            UPDATE b_tasks
            SET task_doing = ?
            WHERE id = ?
        ");
        $stmt->execute([$newTaskDoing, $bTaskId]);

        // 更新当日弃单统计
        $today = date('Y-m-d');
        $stmt = $db->prepare("
            INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, submit_count, approved_count, abandon_count, rejected_count)
            VALUES (?, ?, 0, 0, 0, 1, 0)
            ON DUPLICATE KEY UPDATE abandon_count = abandon_count + 1
        ");
        $stmt->execute([$currentUser['user_id'], $today]);
        $requestLogger->debug('当日弃单统计更新成功', ['user_id' => $currentUser['user_id']]);

        $db->commit();
        $requestLogger->debug('事务提交成功（超时处理）');

        $timeoutMinutes = round($timeout / 60);

        $auditLogger->notice('C端用户提交任务失败：任务已超时', [
            'user_id' => $currentUser['user_id'],
            'record_id' => $recordId,
            'b_task_id' => $bTaskId,
            'elapsed_time' => $elapsedTime,
            'timeout' => $timeout,
            'reason' => '任务已超时',
        ]);

        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }

        Response::error("接单后超过{$timeoutMinutes}分钟未提交，任务已超时，无法再次接取此任务", $errorCodes['TASK_SUBMIT_TIMEOUT']);
    }

    $requestLogger->debug('任务未超时，继续处理');

    // 5. 查询或创建当日统计记录
    $today = date('Y-m-d');
    $stmt = $db->prepare("
        INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, submit_count, approved_count, abandon_count, rejected_count)
        VALUES (?, ?, 0, 1, 0, 0, 0)
        ON DUPLICATE KEY UPDATE submit_count = submit_count + 1
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $requestLogger->debug('当日提交统计更新成功', ['user_id' => $currentUser['user_id']]);

    // 6. 开启事务
    $db->beginTransaction();
    $requestLogger->debug('开启事务（正常提交）');

    // 7. 更新任务记录
    $submittedAt = date('Y-m-d H:i:s');
    $screenshotsJson = json_encode($screenshots, JSON_UNESCAPED_UNICODE);

    $stmt = $db->prepare("
        UPDATE c_task_records
        SET status = 2,
            comment_url = ?,
            screenshot_url = ?,
            submitted_at = ?
        WHERE id = ?
    ");
    $stmt->execute([$commentUrl, $screenshotsJson, $submittedAt, $recordId]);
    $requestLogger->debug('任务记录更新成功', [
        'record_id' => $recordId,
        'status' => 2,
        'submitted_at' => $submittedAt,
    ]);

    // 8. 更新 B 端任务统计
    $requestLogger->debug('查询任务当前task_doing', ['b_task_id' => $bTaskId]);
    $stmt = $db->prepare("SELECT task_doing FROM b_tasks WHERE id = ?");
    $stmt->execute([$bTaskId]);
    $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
    $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
    $newTaskDoing = max($currentTaskDoing - 1, 0);

    $requestLogger->debug('更新任务统计', [
        'b_task_id' => $bTaskId,
        'old_doing' => $currentTaskDoing,
        'new_doing' => $newTaskDoing,
        'task_reviewing' => '+1',
    ]);

    $stmt = $db->prepare("
        UPDATE b_tasks
        SET task_doing = ?,
            task_reviewing = task_reviewing + 1
        WHERE id = ?
    ");
    $stmt->execute([$newTaskDoing, $bTaskId]);

    // 9. 提交事务
    $db->commit();
    $requestLogger->debug('事务提交成功（正常提交）');

    $auditLogger->notice('C端用户提交任务成功', [
        'user_id' => $currentUser['user_id'],
        'record_id' => $recordId,
        'b_task_id' => $bTaskId,
        'submitted_at' => $submittedAt,
    ]);

    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }

    $requestLogger->info('C端提交任务成功', [
        'user_id' => $currentUser['user_id'],
        'record_id' => $recordId,
        'b_task_id' => $bTaskId,
    ]);

    Response::success([
        'record_id' => (int)$recordId,
        'status' => 2,
        'status_text' => '待审核',
        'submitted_at' => $submittedAt
    ], '任务提交成功，等待审核');

} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
        $requestLogger->debug('事务回滚成功');
    }

    $errorLogger->error('PDO异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户提交任务失败：数据库异常', [
        'user_id' => $currentUser['user_id'] ?? null,
        'record_id' => $recordId ?? null,
        'b_task_id' => $bTaskId ?? null,
        'message' => $e->getMessage(),
        'reason' => '数据库异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('任务提交失败', $errorCodes['TASK_SUBMIT_FAILED'], 500);
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
        $requestLogger->debug('事务回滚成功');
    }

    $errorLogger->error('系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    $auditLogger->error('C端用户提交任务失败：系统异常', [
        'user_id' => $currentUser['user_id'] ?? null,
        'record_id' => $recordId ?? null,
        'b_task_id' => $bTaskId ?? null,
        'message' => $e->getMessage(),
        'reason' => '系统异常',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    Response::error('任务提交失败', $errorCodes['TASK_SUBMIT_FAILED'], 500);
}
