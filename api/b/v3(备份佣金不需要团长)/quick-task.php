<?php
/**
 * B端快捷派单接口
 * 
 * POST /api/b/v1/quick-task
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "template_id": 4,
 *   "video_url": [
 *     "https://example.com/video1.mp4",
 *     "https://example.com/video2.mp4"
 *   ],
 *   "deadline": 1796058061,
 *   "releases_number": 2,
 *   "stage1_count": 1,
 *   "stage2_count": 1,
 *   "total_price": 5.00,
 *   "recommend_marks": [
 *     {
 *       "comment": "阶段1上评评论",
 *       "image_url": "http://example.com/image1.jpg"
 *     },
 *     {
 *       "comment": "阶段2中评回复1",
 *       "image_url": "http://example.com/image2.jpg"
 *     }
 *   ]
 * }
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);

// 调试日志
error_log('[快捷派单] 请求参数: ' . json_encode($input, JSON_UNESCAPED_UNICODE));

// 检查请求体是否为空
if ($input === null) {
    error_log('[快捷派单] 请求体为空');
    Response::error('请求体不能为空', $errorCodes['INVALID_PARAMS']);
}

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

$templateId = $input['template_id'] ?? 0;
$videoUrls = $input['video_url'] ?? [];
$deadline = $input['deadline'] ?? 0;
$releasesNumber = $input['releases_number'] ?? 0;
$totalPrice = $input['total_price'] ?? 0;
$recommendMarks = $input['recommend_marks'] ?? [];

// 组合任务参数
$stage1Count = $input['stage1_count'] ?? 0;
$stage2Count = $input['stage2_count'] ?? 0;

// 调试日志
error_log('[快捷派单] 处理参数 - template_id: ' . $templateId . ', releases_number: ' . $releasesNumber . ', stage1_count: ' . $stage1Count . ', stage2_count: ' . $stage2Count . ', videoUrls count: ' . count($videoUrls));

// 参数校验
if (empty($templateId)) {
    Response::error('任务模板ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (!is_array($videoUrls) || empty($videoUrls)) {
    Response::error('视频链接不能为空，必须是数组格式', $errorCodes['INVALID_PARAMS']);
}

if (count($videoUrls) !== $releasesNumber) {
    Response::error('视频链接数量必须与发布次数一致', $errorCodes['INVALID_PARAMS']);
}

// 校验每个视频链接
foreach ($videoUrls as $index => $url) {
    if (empty(trim($url))) {
        Response::error('第 ' . ($index + 1) . ' 个视频链接不能为空', $errorCodes['INVALID_PARAMS']);
    }
}

if (empty($deadline) || !is_numeric($deadline)) {
    Response::error('到期时间不能为空', $errorCodes['INVALID_PARAMS']);
}

if ($deadline < time()) {
    Response::error('到期时间不能早于当前时间', $errorCodes['INVALID_PARAMS']);
}

if (empty($releasesNumber) || !is_numeric($releasesNumber) || $releasesNumber <= 0) {
    Response::error('发布次数必须大于0', $errorCodes['INVALID_PARAMS']);
}

// 限制最大发布次数
if ($releasesNumber > 100) {
    Response::error('发布次数不能超过100', $errorCodes['INVALID_PARAMS']);
}

try {
    // 查询任务模板
    $stmt = $db->prepare("SELECT id, type, title, stage1_title, stage1_price, stage2_title, stage2_price, status FROM task_templates WHERE id = ?");
    $stmt->execute([$templateId]);
    $template = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$template) {
        Response::error('任务模板不存在', $errorCodes['TASK_TEMPLATE_NOT_FOUND']);
    }
    
    if ($template['status'] != 1) {
        Response::error('任务模板已禁用', $errorCodes['TASK_TEMPLATE_NOT_FOUND']);
    }
    
    // 验证是否为组合任务
    if ((int)$template['type'] !== 1) {
        Response::error('快捷派单仅支持组合任务模板', $errorCodes['INVALID_PARAMS']);
    }
    
    // 组合任务校验
    if ($stage1Count !== 1) {
        Response::error('组合任务阶段1固定为1个任务', $errorCodes['INVALID_PARAMS']);
    }
    
    if (empty($stage2Count) || $stage2Count <= 0) {
        Response::error('阶段2数量必须大于0', $errorCodes['INVALID_PARAMS']);
    }
    
    // 校验 recommend_marks 数量
    $totalCount = $stage1Count + $stage2Count;
    if (!is_array($recommendMarks)) {
        Response::error('推荐评论格式错误', $errorCodes['INVALID_PARAMS']);
    }
    
    if (count($recommendMarks) !== $totalCount) {
        Response::error("推荐评论数量不匹配，应为 {$totalCount} 组（{$stage1Count}个阶段1 + {$stage2Count}个阶段2）", $errorCodes['INVALID_PARAMS']);
    }
    
    // 校验每组数据格式
    foreach ($recommendMarks as $index => $mark) {
        if (!is_array($mark)) {
            Response::error('推荐评论格式错误', $errorCodes['INVALID_PARAMS']);
        }
        
        // 校验comment字段必须存在且不能为空
        if (!array_key_exists('comment', $mark)) {
            Response::error('第 ' . ($index + 1) . ' 个推荐评论必须包含 comment 字段', $errorCodes['INVALID_PARAMS']);
        }
        if (empty(trim($mark['comment']))) {
            Response::error('第 ' . ($index + 1) . ' 个推荐评论的 comment 字段不能为空', $errorCodes['INVALID_PARAMS']);
        }
        
        // 只验证image_url字段格式（如果存在）
        if (array_key_exists('image_url', $mark) && !empty($mark['image_url'])) {
            $imageUrl = trim($mark['image_url']);
            // 验证图片格式
            $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
            $urlPath = parse_url($imageUrl, PHP_URL_PATH);
            if ($urlPath) {
                $extension = strtolower(pathinfo($urlPath, PATHINFO_EXTENSION));
                if (!in_array($extension, $allowedExtensions)) {
                    Response::error('第 ' . ($index + 1) . ' 个推荐评论的图片链接格式错误', $errorCodes['INVALID_PARAMS']);
                }
            }
        }
    }
    
    // 计算价格
    $stage1Price = (float)$template['stage1_price'];
    $stage2Price = (float)$template['stage2_price'];
    $unitTotalPrice = ($stage1Price * $stage1Count) + ($stage2Price * $stage2Count);
    
    // 计算总金额
    $totalAmount = $unitTotalPrice * $releasesNumber;
    
    // 校验总价
    if (abs($totalAmount - (float)$totalPrice) > 0.01) {
        Response::error('总价计算错误，应为 ' . number_format($totalAmount, 2), $errorCodes['INVALID_PARAMS']);
    }
    
    // 查询B端用户信息（获取钱包ID和用户名）
    $stmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 查询钱包余额
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        Response::error('钱包不存在', $errorCodes['WALLET_NOT_FOUND']);
    }
    
    // 将总价转换为分（元 -> 分）
    $totalAmountInCents = (int)round($totalAmount * 100);
    $beforeBalance = (int)$wallet['balance'];
    
    // 校验余额是否足够
    if ($beforeBalance < $totalAmountInCents) {
        $needAmount = number_format($totalAmountInCents / 100, 2);
        $currentAmount = number_format($beforeBalance / 100, 2);
        Response::error("余额不足，当前余额：¥{$currentAmount}，需要：¥{$needAmount}", $errorCodes['WALLET_INSUFFICIENT_BALANCE']);
    }
    
    // 调试日志
error_log('[快捷派单] 开始发布任务 - releases_number: ' . $releasesNumber . ', totalAmount: ' . $totalAmount . ', totalAmountInCents: ' . $totalAmountInCents);

    // 开启事务
    $db->beginTransaction();
    
    // 记录创建的任务
    $createdTasks = [];
    
    // 循环发布任务
    for ($i = 0; $i < $releasesNumber; $i++) {
        // 调试日志
        error_log('[快捷派单] 循环发布任务 - 第 ' . ($i + 1) . ' 次');
        
        // 获取当前视频链接
        $currentVideoUrl = trim($videoUrls[$i]);
        error_log('[快捷派单] 使用视频链接: ' . $currentVideoUrl);
        
        // 生成唯一的组合任务标识
        $comboTaskId = 'COMBO_' . time() . '_' . $currentUser['user_id'] . '_' . ($i + 1);
        error_log('[快捷派单] 生成 combo_task_id: ' . $comboTaskId);
        
        // 分配评论：前N个给阶段1，后M个给阶段2
        $stage1Marks = array_slice($recommendMarks, 0, $stage1Count);
        $stage2Marks = array_slice($recommendMarks, $stage1Count, $stage2Count);
        
        // 1. 创建阶段1任务（已开放）
        $stmt = $db->prepare("INSERT INTO b_tasks (b_user_id, combo_task_id, stage, stage_status, parent_task_id, template_id, video_url, deadline, recommend_marks, task_count, task_done, task_doing, task_reviewing, unit_price, total_price, status) VALUES (?, ?, 1, 1, NULL, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, 1)");
        
        $stage1TotalPrice = $stage1Price * $stage1Count;
        $stmt->execute([
            $currentUser['user_id'],
            $comboTaskId,
            $templateId,
            $currentVideoUrl,
            $deadline,
            json_encode($stage1Marks, JSON_UNESCAPED_UNICODE),
            $stage1Count,
            $stage1Price,
            $stage1TotalPrice
        ]);
        
        $stage1TaskId = $db->lastInsertId();
        error_log('[快捷派单] 创建阶段1任务成功，task_id: ' . $stage1TaskId);
        
        // 2. 创建阶段2任务（未开放，video_url暂时为NULL）
        $stmt = $db->prepare("INSERT INTO b_tasks (b_user_id, combo_task_id, stage, stage_status, parent_task_id, template_id, video_url, deadline, recommend_marks, task_count, task_done, task_doing, task_reviewing, unit_price, total_price, status) VALUES (?, ?, 2, 0, ?, ?, NULL, ?, ?, ?, 0, 0, 0, ?, ?, 1)");
        
        $stage2TotalPrice = $stage2Price * $stage2Count;
        $stmt->execute([
            $currentUser['user_id'],
            $comboTaskId,
            $stage1TaskId,  // 父任务ID
            $templateId,
            $deadline,
            json_encode($stage2Marks, JSON_UNESCAPED_UNICODE),
            $stage2Count,
            $stage2Price,
            $stage2TotalPrice
        ]);
        
        $stage2TaskId = $db->lastInsertId();
        error_log('[快捷派单] 创建阶段2任务成功，task_id: ' . $stage2TaskId);
        
        // 记录任务信息
        $createdTasks[] = [
            'combo_task_id' => $comboTaskId,
            'stage1_task_id' => (int)$stage1TaskId,
            'stage2_task_id' => (int)$stage2TaskId
        ];
    }
    
    // 调试日志
    error_log('[快捷派单] 任务创建完成，共创建 ' . count($createdTasks) . ' 组任务');
    error_log('[快捷派单] 创建的任务信息: ' . json_encode($createdTasks, JSON_UNESCAPED_UNICODE));
    
    // 2. 扣除钱包余额
    $afterBalance = $beforeBalance - $totalAmountInCents;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $stmt->execute([$afterBalance, $bUser['wallet_id']]);
    
    // 3. 记录钱包流水
    $remark = "快捷派单【{$template['title']}】{$releasesNumber}组任务，每组{$stage1Count}+{$stage2Count}个任务，扣除 ¥" . number_format($totalAmount, 2);
    // 根据任务模板ID确定任务类型
    $taskType = 4; // 组合任务
    $taskTypeText = '上中评评论';
    $stmt = $db->prepare("INSERT INTO wallets_log (wallet_id, user_id, username, user_type, type, amount, before_balance, after_balance, related_type, related_id, task_types, task_types_text, remark) VALUES (?, ?, ?, 2, 2, ?, ?, ?, 'task', ?, ?, ?, ?)");
    $stmt->execute([
        $bUser['wallet_id'],
        $currentUser['user_id'],
        $bUser['username'],
        $totalAmountInCents,
        $beforeBalance,
        $afterBalance,
        $createdTasks[0]['stage1_task_id'], // 使用第一个任务ID作为关联ID
        $taskType,
        $taskTypeText,
        $remark
    ]);
    
    // 插入B端任务统计记录
    try {
        $stmt = $db->prepare("INSERT INTO b_task_statistics (b_user_id, username, flow_type, amount, before_balance, after_balance, related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark) VALUES (?, ?, 2, ?, ?, ?, 'task_publish', ?, ?, ?, 0, '任务发布记录，当前状态已发布，待领取', ?)");
        $stmt->execute([
            $currentUser['user_id'],
            $bUser['username'],
            $totalAmountInCents,
            $beforeBalance,
            $afterBalance,
            $createdTasks[0]['stage1_task_id'], // 使用第一个任务ID作为关联ID
            $taskType,
            $taskTypeText,
            $remark
        ]);
    } catch (Exception $e) {
        // 记录插入失败时的错误日志，但不影响主流程
        error_log('插入b_task_statistics失败: ' . $e->getMessage());
    }
    
    // 提交事务
    $db->commit();
    
    // 调试日志
    error_log('[快捷派单] 事务提交成功，返回响应');
    
    // 返回成功响应
    Response::success([
        'releases_number' => (int)$releasesNumber,
        'total_price' => $totalAmount,
        'tasks' => $createdTasks,
        'wallet' => [
            'before_balance' => number_format($beforeBalance / 100, 2),
            'after_balance' => number_format($afterBalance / 100, 2),
            'deducted' => number_format($totalAmountInCents / 100, 2)
        ]
    ], '快捷派单成功');
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('任务发布失败: ' . $e->getMessage(), $errorCodes['TASK_CREATE_FAILED'], 500);
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('任务发布失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'], 500);
}
?>