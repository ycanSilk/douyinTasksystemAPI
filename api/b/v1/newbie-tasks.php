<?php
/**
 * B 端发布新手任务接口
 * 
 * POST /api/b/v1/newbie-tasks
 * 
 * 请求头：
 * X-Token: <token> (B 端)
 * Content-Type: application/json
 * 
 * 请求体：
 * {
 *   "template_id": 1,                          // 任务模板 ID (必填)
 *   "video_url": "https://example.com/video.mp4",  // 视频链接 (必填)
 *   "deadline": 1705420800,                    // 到期时间戳 (必填)
 *   "task_count": 2,                           // 任务数量 (单任务必填)
 *   "total_price": 8.00,                       // 总价格 (必填)
 *   "is_newbie": 1,                            // 是否新手任务：1=是，0=否 (默认 0)
 *   "recommend_marks": [                       // 推荐评论数组 (必填)
 *     {
 *       "comment": "这个产品真不错，质量很好",
 *       "image_url": "http://example.com/img/abc123.jpg"
 *     }
 *   ]
 * }
 * 
 * 请求示例（单任务）：
 * {
 *   "template_id": 1,
 *   "video_url": "https://douyin.com/video/123456",
 *   "deadline": 1736524800,
 *   "task_count": 2,
 *   "total_price": 8.00,
 *   "is_newbie": 1,
 *   "recommend_marks": [
 *     {"comment": "很好用，值得购买", "image_url": "http://xxx.jpg"},
 *     {"comment": "非常满意", "image_url": ""}
 *   ]
 * }
 * 
 * 请求示例（组合任务）：
 * {
 *   "template_id": 4,
 *   "video_url": "https://douyin.com/video/123456",
 *   "deadline": 1736524800,
 *   "stage1_count": 1,
 *   "stage2_count": 3,
 *   "total_price": 10.00,
 *   "is_newbie": 1,
 *   "recommend_marks": [
 *     {"comment": "阶段 1 上评评论", "image_url": "http://xxx.jpg"},
 *     {"comment": "阶段 2 中评回复 1", "image_url": "http://xxx.jpg"},
 *     {"comment": "阶段 2 中评回复 2", "image_url": "http://xxx.jpg"},
 *     {"comment": "阶段 2 中评回复 3", "image_url": "http://xxx.jpg"}
 *   ]
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "任务发布成功",
 *   "data": {
 *     "task_id": 123,
 *     "is_combo": false,
 *     "template_id": 1,
 *     "video_url": "https://...",
 *     "task_count": 2,
 *     "total_price": 8.00,
 *     "wallet": {
 *       "before_balance": "100.00",
 *       "after_balance": "92.00",
 *       "deducted": "8.00"
 *     }
 *   }
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 4006,
 *   "message": "任务模板不存在",
 *   "data": []
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4001 - 请求体不能为空
 * 4002 - 任务模板 ID 不能为空
 * 4003 - 视频链接不能为空
 * 4004 - 到期时间不能为空
 * 4005 - 到期时间不能早于当前时间
 * 4006 - 任务模板不存在
 * 4007 - 任务模板已禁用
 * 4008 - 任务数量必须大于 0
 * 4009 - 推荐评论格式错误
 * 4010 - 推荐评论数量不匹配
 * 4011 - 总价计算错误
 * 4012 - 组合任务阶段 1 固定为 1 个任务
 * 4013 - 阶段 2 数量必须大于 0
 * 4014 - 用户信息异常
 * 4015 - 钱包不存在
 * 4016 - 余额不足
 * 5001 - 数据库错误
 * 5002 - 任务发布失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/newbie-tasks');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== B 端发布新手任务请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 记录请求体
try {
    $rawInput = file_get_contents('php://input');
    $requestLogger->debug('请求体内容', ['body' => $rawInput]);
} catch (Exception $e) {
    $errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()]);
    $rawInput = '';
}

require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/AuthMiddleware.php';

// 获取请求参数
$input = json_decode($rawInput, true);

// 检查请求体是否为空
if ($input === null) {
    $requestLogger->warning('请求体为空');
    echo json_encode([
        'code' => 4001,
        'message' => '请求体不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

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

// 是否为新手任务
$isNewbie = (int)($input['is_newbie'] ?? 0);

// 记录请求参数
$requestLogger->debug('请求参数', [
    'template_id' => $templateId,
    'video_url' => $videoUrl,
    'deadline' => $deadline,
    'total_price' => $totalPrice,
    'task_count' => $taskCount,
    'stage1_count' => $stage1Count,
    'stage2_count' => $stage2Count,
    'is_newbie' => $isNewbie,
    'recommend_marks_count' => count($recommendMarks),
]);

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

// Token 认证（必须是 B 端用户）
try {
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateB();
    $requestLogger->debug('Token 认证成功', ['user_id' => $currentUser['user_id']]);
} catch (Exception $e) {
    $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);
    echo json_encode([
        'code' => 4014,
        'message' => '用户认证失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 参数校验
if (empty($templateId)) {
    $requestLogger->warning('参数校验失败：任务模板 ID 为空', ['template_id' => $templateId]);
    echo json_encode([
        'code' => 4002,
        'message' => '任务模板 ID 不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($videoUrl)) {
    $requestLogger->warning('参数校验失败：视频链接为空', ['video_url' => $videoUrl]);
    echo json_encode([
        'code' => 4003,
        'message' => '视频链接不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($deadline) || !is_numeric($deadline)) {
    $requestLogger->warning('参数校验失败：到期时间无效', ['deadline' => $deadline]);
    echo json_encode([
        'code' => 4004,
        'message' => '到期时间不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($deadline < time()) {
    $requestLogger->warning('参数校验失败：到期时间早于当前时间', [
        'deadline' => $deadline,
        'current_time' => time()
    ]);
    echo json_encode([
        'code' => 4005,
        'message' => '到期时间不能早于当前时间',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 查询任务模板
    $requestLogger->debug('开始查询任务模板', ['template_id' => $templateId]);
    $stmt = $db->prepare("
        SELECT id, type, title, price, status,
               stage1_title, stage1_price, stage2_title, stage2_price
        FROM task_templates 
        WHERE id = ?
    ");
    $stmt->execute([$templateId]);
    $template = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$template) {
        $requestLogger->warning('任务模板不存在', ['template_id' => $templateId]);
        echo json_encode([
            'code' => 4006,
            'message' => '任务模板不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if ($template['status'] != 1) {
        $requestLogger->warning('任务模板已禁用', [
            'template_id' => $templateId,
            'status' => $template['status']
        ]);
        echo json_encode([
            'code' => 4007,
            'message' => '任务模板已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $requestLogger->debug('任务模板查询成功', [
        'template_id' => $template['id'],
        'type' => $template['type'],
        'title' => $template['title']
    ]);
    
    // 判断是单任务还是组合任务
    $isCombo = (int)$template['type'] === 1;
    $requestLogger->debug('任务类型判断', ['is_combo' => $isCombo]);
    
    if (!$isCombo) {
        // 单任务校验
        if (empty($taskCount) || !is_numeric($taskCount) || $taskCount <= 0) {
            $requestLogger->warning('参数校验失败：任务数量无效', ['task_count' => $taskCount]);
            echo json_encode([
                'code' => 4008,
                'message' => '任务数量必须大于 0',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        // 校验 recommend_marks 数量
        if (!is_array($recommendMarks)) {
            $requestLogger->warning('参数校验失败：推荐评论格式错误', ['recommend_marks' => $recommendMarks]);
            echo json_encode([
                'code' => 4009,
                'message' => '推荐评论格式错误',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        if (count($recommendMarks) !== (int)$taskCount) {
            $requestLogger->warning('参数校验失败：推荐评论数量不匹配', [
                'expected' => $taskCount,
                'actual' => count($recommendMarks)
            ]);
            echo json_encode([
                'code' => 4010,
                'message' => "推荐评论数量不匹配，应为 {$taskCount} 组",
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        // 校验每组数据格式
        foreach ($recommendMarks as $index => $mark) {
            if (!is_array($mark)) {
                $requestLogger->warning('参数校验失败：推荐评论格式错误', ['index' => $index]);
                echo json_encode([
                    'code' => 4009,
                    'message' => '推荐评论格式错误',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            
            // 校验 comment 字段必须存在且不能为空
            if (!array_key_exists('comment', $mark)) {
                $requestLogger->warning('参数校验失败：缺少 comment 字段', ['index' => $index]);
                echo json_encode([
                    'code' => 4009,
                    'message' => '第 ' . ($index + 1) . ' 个推荐评论必须包含 comment 字段',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            if (empty(trim($mark['comment']))) {
                $requestLogger->warning('参数校验失败：comment 字段为空', ['index' => $index]);
                echo json_encode([
                    'code' => 4009,
                    'message' => '第 ' . ($index + 1) . ' 个推荐评论的 comment 字段不能为空',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            
            // 只验证 image_url 字段格式（如果存在）
            if (array_key_exists('image_url', $mark) && !empty($mark['image_url'])) {
                $imageUrl = trim($mark['image_url']);
                // 验证图片格式
                $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
                $urlPath = parse_url($imageUrl, PHP_URL_PATH);
                if ($urlPath) {
                    $extension = strtolower(pathinfo($urlPath, PATHINFO_EXTENSION));
                    if (!in_array($extension, $allowedExtensions)) {
                        $requestLogger->warning('参数校验失败：图片链接格式错误', ['index' => $index, 'url' => $imageUrl]);
                        echo json_encode([
                            'code' => 4009,
                            'message' => '第 ' . ($index + 1) . ' 个推荐评论的图片链接格式错误',
                            'data' => [],
                            'timestamp' => time()
                        ], JSON_UNESCAPED_UNICODE);
                        exit;
                    }
                }
            }
        }
        
        $unitPrice = (float)$template['price'];
        $calculatedTotalPrice = $unitPrice * $taskCount;
        
        // 校验总价
        if (abs($calculatedTotalPrice - (float)$totalPrice) > 0.01) {
            $requestLogger->warning('参数校验失败：总价计算错误', [
                'expected' => $calculatedTotalPrice,
                'provided' => $totalPrice
            ]);
            echo json_encode([
                'code' => 4011,
                'message' => '总价计算错误，应为 ' . number_format($calculatedTotalPrice, 2),
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    } else {
        // 组合任务校验
        if ($stage1Count !== 1) {
            $requestLogger->warning('参数校验失败：组合任务阶段 1 数量必须为 1', ['stage1_count' => $stage1Count]);
            echo json_encode([
                'code' => 4012,
                'message' => '组合任务阶段 1 固定为 1 个任务',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        if (empty($stage2Count) || $stage2Count <= 0) {
            $requestLogger->warning('参数校验失败：阶段 2 数量无效', ['stage2_count' => $stage2Count]);
            echo json_encode([
                'code' => 4013,
                'message' => '阶段 2 数量必须大于 0',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        $stage1Price = (float)$template['stage1_price'];
        $stage2Price = (float)$template['stage2_price'];
        $calculatedTotalPrice = ($stage1Price * $stage1Count) + ($stage2Price * $stage2Count);
        
        // 校验总价
        if (abs($calculatedTotalPrice - (float)$totalPrice) > 0.01) {
            $requestLogger->warning('参数校验失败：总价计算错误', [
                'expected' => $calculatedTotalPrice,
                'provided' => $totalPrice
            ]);
            echo json_encode([
                'code' => 4011,
                'message' => '总价计算错误，应为 ' . number_format($calculatedTotalPrice, 2),
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }
    
    // 查询 B 端用户信息（获取钱包 ID 和用户名）
    $stmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        $errorLogger->error('B 端用户信息不存在', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 4014,
            'message' => '用户信息异常',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 查询钱包余额
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$bUser['wallet_id']]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$wallet) {
        $errorLogger->error('B 端用户钱包不存在', ['wallet_id' => $bUser['wallet_id']]);
        echo json_encode([
            'code' => 4015,
            'message' => '钱包不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 将总价转换为分（元 -> 分）
    $totalPriceInCents = (int)round($calculatedTotalPrice * 100);
    $beforeBalance = (int)$wallet['balance'];
    
    // 校验余额是否足够
    if ($beforeBalance < $totalPriceInCents) {
        $requestLogger->warning('B 端用户余额不足', [
            'user_id' => $currentUser['user_id'],
            'before_balance' => $beforeBalance,
            'need_balance' => $totalPriceInCents
        ]);
        echo json_encode([
            'code' => 4016,
            'message' => "余额不足，当前余额：¥" . number_format($beforeBalance / 100, 2) . "，需要：¥" . number_format($totalPriceInCents / 100, 2),
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 开启事务
    $db->beginTransaction();
    
    // 根据is_newbie决定插入的表
    $taskTable = $isNewbie ? 'b_newbie_tasks' : 'b_tasks';
    
    if (!$isCombo) {
        // ========== 单任务 ==========
        $stmt = $db->prepare("
            INSERT INTO $taskTable (
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
            $requestLogger->warning('参数校验失败：推荐评论格式错误', ['recommend_marks' => $recommendMarks]);
            echo json_encode([
                'code' => 4009,
                'message' => '推荐评论格式错误',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        if (count($recommendMarks) !== $totalCount) {
            $requestLogger->warning('参数校验失败：推荐评论数量不匹配', [
                'expected' => $totalCount,
                'actual' => count($recommendMarks)
            ]);
            echo json_encode([
                'code' => 4010,
                'message' => "推荐评论数量不匹配，应为 {$totalCount} 组（{$stage1Count}个阶段 1 + {$stage2Count}个阶段 2）",
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        
        // 校验每组数据格式
        foreach ($recommendMarks as $index => $mark) {
            if (!is_array($mark)) {
                $requestLogger->warning('参数校验失败：推荐评论格式错误', ['index' => $index]);
                echo json_encode([
                    'code' => 4009,
                    'message' => '推荐评论格式错误',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            
            // 校验 comment 字段必须存在且不能为空
            if (!array_key_exists('comment', $mark)) {
                $requestLogger->warning('参数校验失败：缺少 comment 字段', ['index' => $index]);
                echo json_encode([
                    'code' => 4009,
                    'message' => '第 ' . ($index + 1) . ' 个推荐评论必须包含 comment 字段',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            if (empty(trim($mark['comment']))) {
                $requestLogger->warning('参数校验失败：comment 字段为空', ['index' => $index]);
                echo json_encode([
                    'code' => 4009,
                    'message' => '第 ' . ($index + 1) . ' 个推荐评论的 comment 字段不能为空',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            
            // 只验证 image_url 字段格式（如果存在）
            if (array_key_exists('image_url', $mark) && !empty($mark['image_url'])) {
                $imageUrl = trim($mark['image_url']);
                // 验证图片格式
                $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
                $urlPath = parse_url($imageUrl, PHP_URL_PATH);
                if ($urlPath) {
                    $extension = strtolower(pathinfo($urlPath, PATHINFO_EXTENSION));
                    if (!in_array($extension, $allowedExtensions)) {
                        $requestLogger->warning('参数校验失败：图片链接格式错误', ['index' => $index, 'url' => $imageUrl]);
                        echo json_encode([
                            'code' => 4009,
                            'message' => '第 ' . ($index + 1) . ' 个推荐评论的图片链接格式错误',
                            'data' => [],
                            'timestamp' => time()
                        ], JSON_UNESCAPED_UNICODE);
                        exit;
                    }
                }
            }
        }
        
        // 分配评论：前N个给阶段1，后M个给阶段2
        $stage1Marks = array_slice($recommendMarks, 0, $stage1Count);
        $stage2Marks = array_slice($recommendMarks, $stage1Count, $stage2Count);
        
        // 生成组合任务标识
        $comboTaskId = 'COMBO_' . time() . '_' . $currentUser['user_id'];
        
        // 1. 创建阶段1任务（已开放）
        $stmt = $db->prepare("
            INSERT INTO $taskTable (
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
            INSERT INTO $taskTable (
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
        $errorLogger->error('插入 b_task_statistics 失败', ['exception' => $e->getMessage()]);
    }
    
    // 提交事务
    $requestLogger->debug('提交数据库事务');
    $db->commit();
    
    // 记录审计日志
    $auditLogger->notice('B 端发布新手任务成功', [
        'user_id' => $currentUser['user_id'],
        'username' => $bUser['username'],
        'task_id' => $taskId,
        'is_combo' => $isCombo,
        'is_newbie' => $isNewbie,
        'total_price' => $calculatedTotalPrice,
    ]);
    
    $requestLogger->info('新手任务发布成功', [
        'task_id' => $taskId,
        'is_combo' => $isCombo,
        'is_newbie' => $isNewbie,
        'total_price' => $calculatedTotalPrice,
    ]);
    
    // 返回成功响应
    if (!$isCombo) {
        echo json_encode([
            'code' => 0,
            'message' => '任务发布成功',
            'data' => [
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
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'code' => 0,
            'message' => '组合任务发布成功',
            'data' => [
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
                    'status' => '未开放（等待阶段 1 完成）'
                ],
                'total_price' => $calculatedTotalPrice,
                'wallet' => [
                    'before_balance' => number_format($beforeBalance / 100, 2),
                    'after_balance' => number_format($afterBalance / 100, 2),
                    'deducted' => number_format($totalPriceInCents / 100, 2)
                ]
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
    }
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('新手任务发布失败：数据库异常', [
        'message' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    echo json_encode([
        'code' => 5002,
        'message' => '任务发布失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('新手任务发布失败：系统异常', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    
    echo json_encode([
        'code' => 5002,
        'message' => '任务发布失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}

