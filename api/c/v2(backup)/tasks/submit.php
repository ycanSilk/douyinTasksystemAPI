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
 *   "comment_url": "https://douyin.com/comment/xxx",
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
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
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
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$commentUrl = trim($input['comment_url'] ?? '');
$screenshots = $input['screenshots'] ?? [];

// 参数校验
if (empty($bTaskId) || !is_numeric($bTaskId)) {
    Response::error('任务ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($recordId) || !is_numeric($recordId)) {
    Response::error('任务记录ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($commentUrl)) {
    Response::error('评论链接不能为空', $errorCodes['INVALID_PARAMS']);
}

// 校验截图
if (!is_array($screenshots)) {
    Response::error('截图必须是数组格式', $errorCodes['TASK_SUBMIT_SCREENSHOTS_INVALID']);
}

if (count($screenshots) > 3) {
    Response::error('截图最多3张', $errorCodes['TASK_SUBMIT_SCREENSHOTS_INVALID']);
}

if (empty($screenshots)) {
    Response::error('至少需要提交1张截图', $errorCodes['TASK_SUBMIT_SCREENSHOTS_INVALID']);
}

try {
    // 1. 查询任务记录（同时校验 b_task_id 和 record_id）
    $stmt = $db->prepare("
        SELECT id, c_user_id, b_task_id, status, created_at
        FROM c_task_records 
        WHERE id = ? AND b_task_id = ?
    ");
    $stmt->execute([$recordId, $bTaskId]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$record) {
        Response::error('任务记录不存在或参数不匹配', $errorCodes['TASK_SUBMIT_NOT_FOUND']);
    }
    
    // 2. 校验是否是当前用户的任务
    if ((int)$record['c_user_id'] !== $currentUser['user_id']) {
        Response::error('无权操作此任务', $errorCodes['TASK_SUBMIT_NOT_FOUND']);
    }
    
    // 3. 校验任务状态（只能提交 doing 状态的任务）
    if ((int)$record['status'] !== 1) {
        $statusTexts = [1 => '进行中', 2 => '待审核', 3 => '已通过', 4 => '已驳回', 5 => '已超时'];
        $currentStatusText = $statusTexts[(int)$record['status']] ?? '未知';
        Response::error("该任务当前状态为：{$currentStatusText}，无法提交", $errorCodes['TASK_SUBMIT_INVALID_STATUS']);
    }
    
    // 4. 校验是否超时
    $timeout = (int)$appConfig['task_submit_timeout'];
    $acceptTime = strtotime($record['created_at']);
    $currentTime = time();
    $elapsedTime = $currentTime - $acceptTime;
    
    if ($elapsedTime > $timeout) {
        // 超时，更新状态为5（已超时）
        $db->beginTransaction();

        // 更新任务记录状态为已超时
        $stmt = $db->prepare("UPDATE c_task_records SET status = 5 WHERE id = ?");
        $stmt->execute([$recordId]);

        // b_tasks.task_doing -1
        $stmt = $db->prepare("
            UPDATE b_tasks
            SET task_doing = GREATEST(task_doing - 1, 0)
            WHERE id = ?
        ");
        $stmt->execute([$bTaskId]);

        $db->commit();

        $timeoutMinutes = round($timeout / 60);
        Response::error("接单后超过{$timeoutMinutes}分钟未提交，任务已超时，无法再次接取此任务", $errorCodes['TASK_SUBMIT_TIMEOUT']);
    }
    
    // 5. 查询或创建当日统计记录
    $today = date('Y-m-d');
    $stmt = $db->prepare("
        SELECT id 
        FROM c_user_daily_stats 
        WHERE c_user_id = ? AND stat_date = ?
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$dailyStats) {
        $stmt = $db->prepare("
            INSERT INTO c_user_daily_stats (c_user_id, stat_date)
            VALUES (?, ?)
        ");
        $stmt->execute([$currentUser['user_id'], $today]);
        $dailyStatsId = $db->lastInsertId();
    } else {
        $dailyStatsId = $dailyStats['id'];
    }
    
    // 6. 开启事务
    $db->beginTransaction();
    
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
    
    // 8. 更新B端任务统计
    $stmt = $db->prepare("
        UPDATE b_tasks 
        SET task_doing = task_doing - 1,
            task_reviewing = task_reviewing + 1
        WHERE id = ?
    ");
    $stmt->execute([$bTaskId]);
    
    // 9. 更新当日提交统计
    $stmt = $db->prepare("
        UPDATE c_user_daily_stats 
        SET submit_count = submit_count + 1 
        WHERE id = ?
    ");
    $stmt->execute([$dailyStatsId]);
    
    // 10. 提交事务
    $db->commit();
    
    // 11. 返回成功响应
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
    }
    
    Response::error('任务提交失败', $errorCodes['TASK_SUBMIT_FAILED'], 500);
}
