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

// 日志文件路径
$logFile = 'd:\github\douyinTasksystemAPI\apierr-log.log';

// 确保日志目录存在
$logDir = dirname($logFile);
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
}

// 自定义日志函数
function customLog($message) {
    global $logFile;
    $timestamp = date('[Y-m-d H:i:s]');
    $logMessage = "{$timestamp} {$message}\n";
    // 输出到终端
    error_log($message);
    // 输出到文件
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}

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

// 输出详细日志
customLog('=== C端提交任务接口调用开始 ===');
customLog('请求方法: ' . $_SERVER['REQUEST_METHOD']);
customLog('请求IP: ' . ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知'));
customLog('请求时间: ' . date('Y-m-d H:i:s'));

// 获取请求参数
customLog('步骤1: 获取请求参数...');
$input = json_decode(file_get_contents('php://input'), true);
$bTaskId = $input['b_task_id'] ?? 0;
$recordId = $input['record_id'] ?? 0;
$commentUrl = trim($input['comment_url'] ?? '');
$screenshots = $input['screenshots'] ?? [];
customLog('请求参数: b_task_id=' . $bTaskId . ', record_id=' . $recordId);

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
    customLog('步骤2: 查询任务记录，记录ID: ' . $recordId . ', 任务ID: ' . $bTaskId);
    $stmt = $db->prepare(" 
        SELECT id, c_user_id, b_task_id, status, created_at
        FROM c_task_records 
        WHERE id = ? AND b_task_id = ?
    ");
    $stmt->execute([$recordId, $bTaskId]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$record) {
        customLog('任务记录不存在或参数不匹配');
        Response::error('任务记录不存在或参数不匹配', $errorCodes['TASK_SUBMIT_NOT_FOUND']);
    }
    
    customLog('任务记录查询成功，记录ID: ' . $record['id'] . ', 状态: ' . $record['status']);
    
    // 2. 校验是否是当前用户的任务
    customLog('步骤3: 校验是否是当前用户的任务，任务用户ID: ' . $record['c_user_id'] . ', 当前用户ID: ' . $currentUser['user_id']);
    if ((int)$record['c_user_id'] !== $currentUser['user_id']) {
        customLog('无权操作此任务');
        Response::error('无权操作此任务', $errorCodes['TASK_SUBMIT_NOT_FOUND']);
    }
    
    customLog('校验通过，是当前用户的任务');
    
    // 3. 校验任务状态（只能提交 doing 状态的任务）
    customLog('步骤4: 校验任务状态，当前状态: ' . $record['status']);
    if ((int)$record['status'] !== 1) {
        $statusTexts = [1 => '进行中', 2 => '待审核', 3 => '已通过', 4 => '已驳回', 5 => '已超时'];
        $currentStatusText = $statusTexts[(int)$record['status']] ?? '未知';
        customLog('任务状态无效，当前状态: ' . $currentStatusText);
        Response::error("该任务当前状态为：{$currentStatusText}，无法提交", $errorCodes['TASK_SUBMIT_INVALID_STATUS']);
    }
    
    customLog('任务状态校验通过，状态为进行中');
    
    // 4. 校验是否超时
    customLog('步骤5: 校验是否超时');
    $timeout = (int)$appConfig['task_submit_timeout'];
    $acceptTime = strtotime($record['created_at']);
    $currentTime = time();
    $elapsedTime = $currentTime - $acceptTime;
    
    if ($elapsedTime > $timeout) {
        customLog('任务已超时，开始处理超时逻辑');
        // 超时，更新状态为5（已超时）
        $db->beginTransaction();
        customLog('事务开启成功');

        // 更新任务记录状态为已超时
        customLog('步骤6: 更新任务记录状态为已超时，记录ID: ' . $recordId);
        $stmt = $db->prepare("UPDATE c_task_records SET status = 5 WHERE id = ?");
        $stmt->execute([$recordId]);
        customLog('任务记录状态更新为已超时');

        // 先检查是普通任务还是新手任务
        customLog('步骤7: 检查任务类型，任务ID: ' . $bTaskId);
        $stmt = $db->prepare("SELECT id FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $isNormalTask = $stmt->fetch(PDO::FETCH_ASSOC) !== false;
        customLog('任务类型: ' . ($isNormalTask ? '普通任务' : '新手任务'));
        
        // 更新对应表的 task_doing（先查询再计算，避免 UNSIGNED 溢出）
        if ($isNormalTask) {
            // 更新普通任务
            customLog('查询普通任务当前 task_doing 值');
            $stmt = $db->prepare("SELECT task_doing FROM b_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
            $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
            $newTaskDoing = max($currentTaskDoing - 1, 0);
            customLog('当前 task_doing=' . $currentTaskDoing . ', 更新为=' . $newTaskDoing);
            
            customLog('更新普通任务 task_doing=' . $newTaskDoing);
            $stmt = $db->prepare(" 
                UPDATE b_tasks
                SET task_doing = ?
                WHERE id = ?
            ");
            $stmt->execute([$newTaskDoing, $bTaskId]);
        } else {
            // 更新新手任务
            customLog('查询新手任务当前 task_doing 值');
            $stmt = $db->prepare("SELECT task_doing FROM b_newbie_tasks WHERE id = ?");
            $stmt->execute([$bTaskId]);
            $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
            $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
            $newTaskDoing = max($currentTaskDoing - 1, 0);
            customLog('当前 task_doing=' . $currentTaskDoing . ', 更新为=' . $newTaskDoing);
            
            customLog('更新新手任务 task_doing=' . $newTaskDoing);
            $stmt = $db->prepare(" 
                UPDATE b_newbie_tasks
                SET task_doing = ?
                WHERE id = ?
            ");
            $stmt->execute([$newTaskDoing, $bTaskId]);
        }

        // 更新当日弃单统计
        customLog('步骤8: 更新当日弃单统计，用户ID: ' . $currentUser['user_id']);
        $today = date('Y-m-d');
        $stmt = $db->prepare(" 
            INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, submit_count, approved_count, abandon_count, rejected_count)
            VALUES (?, ?, 0, 0, 0, 1, 0)
            ON DUPLICATE KEY UPDATE abandon_count = abandon_count + 1
        ");
        $stmt->execute([$currentUser['user_id'], $today]);
        customLog('当日弃单统计更新成功');

        $db->commit();
        customLog('事务提交成功');

        $timeoutMinutes = round($timeout / 60);
        customLog('任务超时，用户ID: ' . $currentUser['user_id'] . ', 超时时间: ' . $timeoutMinutes . '分钟');
        Response::error("接单后超过{$timeoutMinutes}分钟未提交，任务已超时，无法再次接取此任务", $errorCodes['TASK_SUBMIT_TIMEOUT']);
    }
    
    customLog('任务未超时，继续处理');
    
    // 5. 查询或创建当日统计记录
    customLog('步骤6: 查询或创建当日统计记录，用户ID: ' . $currentUser['user_id']);
    $today = date('Y-m-d');
    // 使用 INSERT INTO ... ON DUPLICATE KEY UPDATE 语句，确保记录存在且更新 submit_count
    $stmt = $db->prepare(" 
        INSERT INTO c_user_daily_stats (c_user_id, stat_date, accept_count, submit_count, approved_count, abandon_count, rejected_count)
        VALUES (?, ?, 0, 1, 0, 0, 0)
        ON DUPLICATE KEY UPDATE submit_count = submit_count + 1
    ");
    $stmt->execute([$currentUser['user_id'], $today]);
    $dailyStatsId = $db->lastInsertId();
    // 如果是更新，lastInsertId() 会返回0，需要重新查询获取ID
    if ($dailyStatsId === 0) {
        customLog('当日统计记录已存在，重新查询ID');
        $stmt = $db->prepare("SELECT id FROM c_user_daily_stats WHERE c_user_id = ? AND stat_date = ?");
        $stmt->execute([$currentUser['user_id'], $today]);
        $dailyStats = $stmt->fetch(PDO::FETCH_ASSOC);
        $dailyStatsId = $dailyStats['id'];
        customLog('当日统计记录已存在，ID: ' . $dailyStatsId);
    } else {
        customLog('当日统计记录创建成功，ID: ' . $dailyStatsId);
    }
    
    // 6. 开启事务
    customLog('步骤7: 开启事务');
    $db->beginTransaction();
    customLog('事务开启成功');
    
    // 7. 更新任务记录
    customLog('步骤8: 更新任务记录，记录ID: ' . $recordId);
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
    customLog('任务记录状态更新为待审核，记录ID: ' . $recordId);
    
    // 8. 更新 B 端任务统计
    customLog('步骤 9: 更新 B 端任务统计，任务 ID: ' . $bTaskId);
    // 先检查是普通任务还是新手任务
    $stmt = $db->prepare("SELECT id FROM b_tasks WHERE id = ?");
    $stmt->execute([$bTaskId]);
    $isNormalTask = $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    customLog('任务类型：' . ($isNormalTask ? '普通任务' : '新手任务'));
    
    // 更新对应表的统计（先查询再计算，避免 UNSIGNED 溢出）
    if ($isNormalTask) {
        // 更新普通任务
        customLog('查询普通任务当前 task_doing 值');
        $stmt = $db->prepare("SELECT task_doing FROM b_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
        $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
        $newTaskDoing = max($currentTaskDoing - 1, 0);
        customLog('当前 task_doing=' . $currentTaskDoing . ', 更新为=' . $newTaskDoing);
        
        customLog('更新普通任务统计：task_doing=' . $newTaskDoing . ', task_reviewing + 1');
        $stmt = $db->prepare(" 
            UPDATE b_tasks 
            SET task_doing = ?,
                task_reviewing = task_reviewing + 1
            WHERE id = ?
        ");
        $stmt->execute([$newTaskDoing, $bTaskId]);
    } else {
        // 更新新手任务
        customLog('查询新手任务当前 task_doing 值');
        $stmt = $db->prepare("SELECT task_doing FROM b_newbie_tasks WHERE id = ?");
        $stmt->execute([$bTaskId]);
        $taskData = $stmt->fetch(PDO::FETCH_ASSOC);
        $currentTaskDoing = (int)($taskData['task_doing'] ?? 0);
        $newTaskDoing = max($currentTaskDoing - 1, 0);
        customLog('当前 task_doing=' . $currentTaskDoing . ', 更新为=' . $newTaskDoing);
        
        customLog('更新新手任务统计：task_doing=' . $newTaskDoing . ', task_reviewing + 1');
        $stmt = $db->prepare(" 
            UPDATE b_newbie_tasks 
            SET task_doing = ?,
                task_reviewing = task_reviewing + 1
            WHERE id = ?
        ");
        $stmt->execute([$newTaskDoing, $bTaskId]);
    }
    customLog('B 端任务统计更新成功');
    
    // 9. 当日提交统计已在前面的 INSERT/UPDATE 语句中处理
    
    // 10. 提交事务
    customLog('步骤10: 提交事务');
    $db->commit();
    customLog('事务提交成功');
    
    // 11. 返回成功响应
    customLog('任务提交成功，记录ID: ' . $recordId . ', 用户ID: ' . $currentUser['user_id']);
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
        customLog('事务回滚成功');
    }
    
    customLog('任务提交失败: ' . $e->getMessage());
    Response::error('任务提交失败', $errorCodes['TASK_SUBMIT_FAILED'], 500);
}
