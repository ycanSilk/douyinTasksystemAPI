<?php
/**
 * B端发布派单接口
 * 
 * POST /api/b/v1/tasks
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 请求体：
 * {
 *   "template_id": 1,
 *   "video_url": "https://example.com/video.mp4",
 *   "deadline": 1705420800,
 *   "task_count": 2,
 *   "total_price": 8.00,
 *   "recommend_marks": [
 *     {
 *       "comment": "这个产品真不错，质量很好",
 *       "image_url": "http://134.122.136.221:31810/img/abc123.jpg"
 *     },
 *     {
 *       "comment": "非常满意，值得购买",
 *       "image_url": ""
 *     }
 *   ]
 * }
 * 
 * 测试数据示例（单任务）：
 * {
 *   "template_id": 1,
 *   "video_url": "https://douyin.com/video/123456",
 *   "deadline": 1736524800,
 *   "task_count": 2,
 *   "total_price": 8.00,
 *   "recommend_marks": [...]
 * }
 * 
 * 测试数据示例（组合任务）：
 * 注意：组合任务阶段1固定为1个任务，阶段2可变
 * {
 *   "template_id": 4,
 *   "video_url": "https://douyin.com/video/123456",
 *   "deadline": 1736524800,
 *   "stage1_count": 1,
 *   "stage2_count": 3,
 *   "total_price": 10.00,
 *   "recommend_marks": [
 *     {"comment": "阶段1上评评论", "image_url": "http://xxx.jpg"},
 *     {"comment": "阶段2中评回复1", "image_url": "http://xxx.jpg"},
 *     {"comment": "阶段2中评回复2", "image_url": "http://xxx.jpg"},
 *     {"comment": "阶段2中评回复3", "image_url": "http://xxx.jpg"}
 *   ]
 * }
 * 
 * 组合任务逻辑：
 * - 阶段1：固定1个任务，C端用户完成后提交评论链接
 * - 阶段1审核通过后：自动开放阶段2，并将阶段1的评论链接作为阶段2的video_url
 * - 阶段2：M个任务，都在阶段1的评论下进行回复
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

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 B端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateB();

// 获取请求参数
$input = json_decode(file_get_contents('php://input'), true);
$templateId = $input['template_id'] ?? 0;
$videoUrl = trim($input['video_url'] ?? '');
$deadline = $input['deadline'] ?? 0;
$totalPrice = $input['total_price'] ?? 0;
$recommendMarks = $input['recommend_marks'] ?? [];

// 单任务参数
$taskCount = $input['task_count'] ?? 0;

// 组合任务参数
$stage1Count = $input['stage1_count'] ?? 0;
$stage2Count = $input['stage2_count'] ?? 0;

// 参数校验
if (empty($templateId)) {
    Response::error('任务模板ID不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($videoUrl)) {
    Response::error('视频链接不能为空', $errorCodes['INVALID_PARAMS']);
}

if (empty($deadline) || !is_numeric($deadline)) {
    Response::error('到期时间不能为空', $errorCodes['INVALID_PARAMS']);
}

if ($deadline < time()) {
    Response::error('到期时间不能早于当前时间', $errorCodes['INVALID_PARAMS']);
}

try {
    // 查询任务模板
    $stmt = $db->prepare("
        SELECT id, type, title, price, status,
               stage1_title, stage1_price, stage2_title, stage2_price
        FROM task_templates 
        WHERE id = ?
    ");
    $stmt->execute([$templateId]);
    $template = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$template) {
        Response::error('任务模板不存在', $errorCodes['TASK_TEMPLATE_NOT_FOUND']);
    }
    
    if ($template['status'] != 1) {
        Response::error('任务模板已禁用', $errorCodes['TASK_TEMPLATE_NOT_FOUND']);
    }
    
    // 判断是单任务还是组合任务
    $isCombo = (int)$template['type'] === 1;
    
    if (!$isCombo) {
        // 单任务校验
        if (empty($taskCount) || !is_numeric($taskCount) || $taskCount <= 0) {
            Response::error('任务数量必须大于0', $errorCodes['INVALID_PARAMS']);
        }
        
        // 校验 recommend_marks 数量
        if (!is_array($recommendMarks)) {
            Response::error('推荐评论格式错误', $errorCodes['INVALID_PARAMS']);
        }
        
        if (count($recommendMarks) !== (int)$taskCount) {
            Response::error("推荐评论数量不匹配，应为 {$taskCount} 组", $errorCodes['INVALID_PARAMS']);
        }
        
        // 校验每组数据格式
        foreach ($recommendMarks as $index => $mark) {
            if (!is_array($mark)) {
                Response::error('推荐评论格式错误', $errorCodes['INVALID_PARAMS']);
            }
            
            if (!array_key_exists('comment', $mark) || !array_key_exists('image_url', $mark)) {
                Response::error('推荐评论必须包含 comment 和 image_url 字段', $errorCodes['INVALID_PARAMS']);
            }
        }
        
        $unitPrice = (float)$template['price'];
        $calculatedTotalPrice = $unitPrice * $taskCount;
        
        // 校验总价
        if (abs($calculatedTotalPrice - (float)$totalPrice) > 0.01) {
            Response::error('总价计算错误，应为 ' . number_format($calculatedTotalPrice, 2), $errorCodes['INVALID_PARAMS']);
        }
    } else {
        // 组合任务校验
        if ($stage1Count !== 1) {
            Response::error('组合任务阶段1固定为1个任务', $errorCodes['INVALID_PARAMS']);
        }
        
        if (empty($stage2Count) || $stage2Count <= 0) {
            Response::error('阶段2数量必须大于0', $errorCodes['INVALID_PARAMS']);
        }
        
        $stage1Price = (float)$template['stage1_price'];
        $stage2Price = (float)$template['stage2_price'];
        $calculatedTotalPrice = ($stage1Price * $stage1Count) + ($stage2Price * $stage2Count);
        
        // 校验总价
        if (abs($calculatedTotalPrice - (float)$totalPrice) > 0.01) {
            Response::error('总价计算错误，应为 ' . number_format($calculatedTotalPrice, 2), $errorCodes['INVALID_PARAMS']);
        }
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
    $totalPriceInCents = (int)round($calculatedTotalPrice * 100);
    $beforeBalance = (int)$wallet['balance'];
    
    // 校验余额是否足够
    if ($beforeBalance < $totalPriceInCents) {
        $needAmount = number_format($totalPriceInCents / 100, 2);
        $currentAmount = number_format($beforeBalance / 100, 2);
        Response::error("余额不足，当前余额：¥{$currentAmount}，需要：¥{$needAmount}", $errorCodes['WALLET_INSUFFICIENT_BALANCE']);
    }
    
    // 开启事务
    $db->beginTransaction();
    
    if (!$isCombo) {
        // ========== 单任务 ==========
        $stmt = $db->prepare("
            INSERT INTO b_tasks (
                b_user_id, combo_task_id, stage, stage_status, parent_task_id,
                template_id, video_url, deadline, recommend_marks,
                task_count, task_done, task_doing, task_reviewing, 
                unit_price, total_price, status
            ) VALUES (?, NULL, 0, 1, NULL, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, 1)
        ");
        
        $stmt->execute([
            $currentUser['user_id'],
            $templateId,
            $videoUrl,
            $deadline,
            json_encode($recommendMarks, JSON_UNESCAPED_UNICODE),
            $taskCount,
            $unitPrice,
            $calculatedTotalPrice
        ]);
        
        $taskId = $db->lastInsertId();
        $taskCountForRemark = $taskCount;
        
    } else {
        // ========== 组合任务 ==========
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
            
            if (!array_key_exists('comment', $mark) || !array_key_exists('image_url', $mark)) {
                Response::error('推荐评论必须包含 comment 和 image_url 字段', $errorCodes['INVALID_PARAMS']);
            }
        }
        
        // 分配评论：前N个给阶段1，后M个给阶段2
        $stage1Marks = array_slice($recommendMarks, 0, $stage1Count);
        $stage2Marks = array_slice($recommendMarks, $stage1Count, $stage2Count);
        
        // 生成组合任务标识
        $comboTaskId = 'COMBO_' . time() . '_' . $currentUser['user_id'];
        
        // 1. 创建阶段1任务（已开放）
        $stmt = $db->prepare("
            INSERT INTO b_tasks (
                b_user_id, combo_task_id, stage, stage_status, parent_task_id,
                template_id, video_url, deadline, recommend_marks,
                task_count, task_done, task_doing, task_reviewing, 
                unit_price, total_price, status
            ) VALUES (?, ?, 1, 1, NULL, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, 1)
        ");
        
        $stage1TotalPrice = $stage1Price * $stage1Count;
        $stmt->execute([
            $currentUser['user_id'],
            $comboTaskId,
            $templateId,
            $videoUrl,
            $deadline,
            json_encode($stage1Marks, JSON_UNESCAPED_UNICODE),
            $stage1Count,
            $stage1Price,
            $stage1TotalPrice
        ]);
        
        $stage1TaskId = $db->lastInsertId();
        
        // 2. 创建阶段2任务（未开放，video_url暂时为NULL）
        $stmt = $db->prepare("
            INSERT INTO b_tasks (
                b_user_id, combo_task_id, stage, stage_status, parent_task_id,
                template_id, video_url, deadline, recommend_marks,
                task_count, task_done, task_doing, task_reviewing, 
                unit_price, total_price, status
            ) VALUES (?, ?, 2, 0, ?, ?, NULL, ?, ?, ?, 0, 0, 0, ?, ?, 1)
        ");
        
        $stage2TotalPrice = $stage2Price * $stage2Count;
        $stmt->execute([
            $currentUser['user_id'],
            $comboTaskId,
            $stage1TaskId,  // 父任务ID
            $templateId,
            // video_url 为 NULL，等阶段1完成后分配
            $deadline,
            json_encode($stage2Marks, JSON_UNESCAPED_UNICODE),
            $stage2Count,
            $stage2Price,
            $stage2TotalPrice
        ]);
        
        $stage2TaskId = $db->lastInsertId();
        $taskId = $stage1TaskId;  // 返回阶段1的任务ID
        $taskCountForRemark = $stage1Count + $stage2Count;
    }
    
    // 2. 扣除钱包余额
    $afterBalance = $beforeBalance - $totalPriceInCents;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $stmt->execute([$afterBalance, $bUser['wallet_id']]);
    
    // 3. 记录钱包流水
    $remark = "发布任务【{$template['title']}】{$taskCountForRemark}个任务，扣除 ¥" . number_format($calculatedTotalPrice, 2);
    // 根据任务模板ID确定任务类型
    $taskType = 0;
    $taskTypeText = '';
    if ($template) {
        $templateId = (int)($template['id'] ?? 0);
        switch ($templateId) {
            case 1:
                $taskType = 1;
                $taskTypeText = '上评评论';
                break;
            case 2:
                $taskType = 2;
                $taskTypeText = '中评评论';
                break;
            case 3:
                $taskType = 3;
                $taskTypeText = '放大镜搜索词';
                break;
            case 4:
                $taskType = 4;
                $taskTypeText = '上中评评论';
                break;
            case 5:
                $taskType = 5;
                $taskTypeText = '中下评评论';
                break;
        }
    }
    $stmt = $db->prepare(" 
        INSERT INTO wallets_log (
            wallet_id, user_id, username, user_type, type, 
            amount, before_balance, after_balance, 
            related_type, related_id, task_types, task_types_text, remark
        ) VALUES (?, ?, ?, 2, 2, ?, ?, ?, 'task', ?, ?, ?, ?)
    ");
    $stmt->execute([
        $bUser['wallet_id'],
        $currentUser['user_id'],
        $bUser['username'],
        $totalPriceInCents,
        $beforeBalance,
        $afterBalance,
        $taskId,
        $taskType,
        $taskTypeText,
        $remark
    ]);
    
    // 插入B端任务统计记录
    try {
        $stmt = $db->prepare(" 
            INSERT INTO b_task_statistics (
                b_user_id, username, flow_type, amount, before_balance, after_balance, 
                related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark
            ) VALUES (?, ?, 2, ?, ?, ?, 'task_publish', ?, ?, ?, 0, '任务发布记录，当前状态已发布，待领取', ?)
        ");
        $stmt->execute([
            $currentUser['user_id'],
            $bUser['username'],
            $totalPriceInCents,
            $beforeBalance,
            $afterBalance,
            $taskId,
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
    
    // 返回成功响应
    if (!$isCombo) {
        Response::success([
            'task_id' => (int)$taskId,
            'is_combo' => false,
            'template_id' => (int)$templateId,
            'template_title' => $template['title'],
            'video_url' => $videoUrl,
            'deadline' => (int)$deadline,
            'task_count' => (int)$taskCount,
            'task_done' => 0,
            'task_doing' => 0,
            'task_reviewing' => 0,
            'unit_price' => $unitPrice,
            'total_price' => $calculatedTotalPrice,
            'recommend_marks' => $recommendMarks,
            'status' => 1,
            'wallet' => [
                'before_balance' => number_format($beforeBalance / 100, 2),
                'after_balance' => number_format($afterBalance / 100, 2),
                'deducted' => number_format($totalPriceInCents / 100, 2)
            ]
        ], '任务发布成功');
    } else {
        Response::success([
            'combo_task_id' => $comboTaskId,
            'is_combo' => true,
            'template_id' => (int)$templateId,
            'template_title' => $template['title'],
            'video_url' => $videoUrl,
            'deadline' => (int)$deadline,
            'stage1' => [
                'task_id' => (int)$stage1TaskId,
                'title' => $template['stage1_title'],
                'count' => (int)$stage1Count,
                'price' => $stage1Price,
                'total_price' => $stage1TotalPrice,
                'status' => '已开放'
            ],
            'stage2' => [
                'task_id' => (int)$stage2TaskId,
                'title' => $template['stage2_title'],
                'count' => (int)$stage2Count,
                'price' => $stage2Price,
                'total_price' => $stage2TotalPrice,
                'status' => '未开放（等待阶段1完成）'
            ],
            'total_price' => $calculatedTotalPrice,
            'wallet' => [
                'before_balance' => number_format($beforeBalance / 100, 2),
                'after_balance' => number_format($afterBalance / 100, 2),
                'deducted' => number_format($totalPriceInCents / 100, 2)
            ]
        ], '组合任务发布成功');
    }
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    Response::error('任务发布失败', $errorCodes['TASK_CREATE_FAILED'], 500);
}

