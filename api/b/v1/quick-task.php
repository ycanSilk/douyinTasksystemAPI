<?php
/**
 * B 端快捷派单接口
 * 
 * POST /api/b/v1/quick-task
 * 
 * 请求头：
 * X-Token: <token> (B 端)
 * Content-Type: application/json
 * 
 * 请求体：
 * {
 *   "template_id": 4,                          // 任务模板 ID (必填，仅支持组合任务)
 *   "video_url": [                             // 视频链接数组 (必填)
 *     "https://example.com/video1.mp4",
 *     "https://example.com/video2.mp4"
 *   ],
 *   "deadline": 1796058061,                    // 到期时间戳 (必填)
 *   "releases_number": 2,                      // 发布次数 (必填，范围 1-100)
 *   "stage1_count": 1,                         // 阶段 1 任务数量 (必填，固定为 1)
 *   "stage2_count": 2,                         // 阶段 2 任务数量 (必填)
 *   "total_price": 15.00,                      // 总价格 (必填)
 *   "recommend_marks": [                       // 推荐评论数组 (必填，数量=releases_number*(stage1_count+stage2_count))
 *     {"comment": "阶段1上评评论1", "image_url": "http://example.com/image1.jpg"},
 *     {"comment": "阶段2中评回复1-1", "image_url": "http://example.com/image2.jpg"},
 *     {"comment": "阶段2中评回复1-2", "image_url": "http://example.com/image3.jpg"},
 *     {"comment": "阶段1上评评论2", "image_url": "http://example.com/image4.jpg"},
 *     {"comment": "阶段2中评回复2-1", "image_url": "http://example.com/image5.jpg"},
 *     {"comment": "阶段2中评回复2-2", "image_url": "http://example.com/image6.jpg"}
 *   ]
 * }
 * 
 * 请求示例：
 * {
 *   "template_id": 4,
 *   "video_url": [
 *     "https://douyin.com/video/123456",
 *     "https://douyin.com/video/789012"
 *   ],
 *   "deadline": 1736524800,
 *   "releases_number": 2,
 *   "stage1_count": 1,
 *   "stage2_count": 1,
 *   "total_price": 10.00,
 *   "recommend_marks": [
 *     {"comment": "很好用，值得购买", "image_url": "http://xxx.jpg"},
 *     {"comment": "非常满意，客服态度好", "image_url": ""},
 *     {"comment": "质量不错，物流很快", "image_url": "http://xxx.jpg"},
 *     {"comment": "性价比高，推荐购买", "image_url": ""}
 *   ]
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "快捷派单成功",
 *   "data": {
 *     "releases_number": 2,
 *     "total_price": 10.00,
 *     "tasks": [
 *       {
 *         "combo_task_id": "COMBO_1705420800_1_1",
 *         "stage1_task_id": 123,
 *         "stage2_task_id": 124
 *       },
 *       {
 *         "combo_task_id": "COMBO_1705420800_1_2",
 *         "stage1_task_id": 125,
 *         "stage2_task_id": 126
 *       }
 *     ],
 *     "wallet": {
 *       "before_balance": "100.00",
 *       "after_balance": "90.00",
 *       "deducted": "10.00"
 *     }
 *   }
 * }
 * 
 * 响应示例（失败）：
 * {
 *   "code": 4009,
 *   "message": "任务模板不存在",
 *   "data": []
 * }
 * 
 * 错误码说明：
 * 1001 - 请求方法错误
 * 4001 - 请求体不能为空
 * 4002 - 任务模板 ID 不能为空
 * 4003 - 视频链接不能为空
 * 4004 - 视频链接数量必须与发布次数一致
 * 4005 - 到期时间不能为空
 * 4006 - 到期时间不能早于当前时间
 * 4007 - 发布次数必须大于 0
 * 4008 - 发布次数不能超过 100
 * 4009 - 任务模板不存在
 * 4010 - 任务模板已禁用
 * 4011 - 快捷派单仅支持组合任务模板
 * 4012 - 组合任务阶段 1 固定为 1 个任务
 * 4013 - 阶段 2 数量必须大于 0
 * 4014 - 推荐评论格式错误
 * 4015 - 推荐评论数量不匹配
 * 4016 - 总价计算错误
 * 4017 - 用户信息异常
 * 4018 - 钱包不存在
 * 4019 - 余额不足
 * 5001 - 数据库错误
 * 5002 - 任务发布失败
 */

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文（必须！）
LoggerRouter::setContext('b/v1/quick-task');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== B 端快捷派单请求开始 ===', [
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
$videoUrls = $input['video_url'] ?? [];
$deadline = $input['deadline'] ?? 0;
$releasesNumber = $input['releases_number'] ?? 0;
$totalPrice = $input['total_price'] ?? 0;
$recommendMarks = $input['recommend_marks'] ?? [];

// 组合任务参数
$stage1Count = $input['stage1_count'] ?? 0;
$stage2Count = $input['stage2_count'] ?? 0;

// 记录请求参数
$requestLogger->debug('请求参数', [
    'template_id' => $templateId,
    'video_urls_count' => count($videoUrls),
    'deadline' => $deadline,
    'releases_number' => $releasesNumber,
    'total_price' => $totalPrice,
    'stage1_count' => $stage1Count,
    'stage2_count' => $stage2Count,
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
        'code' => 4017,
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

if (!is_array($videoUrls) || empty($videoUrls)) {
    $requestLogger->warning('参数校验失败：视频链接为空', ['video_urls' => $videoUrls]);
    echo json_encode([
        'code' => 4003,
        'message' => '视频链接不能为空，必须是数组格式',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (count($videoUrls) !== $releasesNumber) {
    $requestLogger->warning('参数校验失败：视频链接数量与发布次数不一致', [
        'video_count' => count($videoUrls),
        'releases_number' => $releasesNumber
    ]);
    echo json_encode([
        'code' => 4004,
        'message' => '视频链接数量必须与发布次数一致',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 校验每个视频链接
foreach ($videoUrls as $index => $url) {
    if (empty(trim($url))) {
        $requestLogger->warning('参数校验失败：第 ' . ($index + 1) . ' 个视频链接为空', ['index' => $index]);
        echo json_encode([
            'code' => 4003,
            'message' => '第 ' . ($index + 1) . ' 个视频链接不能为空',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

if (empty($deadline) || !is_numeric($deadline)) {
    $requestLogger->warning('参数校验失败：到期时间无效', ['deadline' => $deadline]);
    echo json_encode([
        'code' => 4005,
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
        'code' => 4006,
        'message' => '到期时间不能早于当前时间',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty($releasesNumber) || !is_numeric($releasesNumber) || $releasesNumber <= 0) {
    $requestLogger->warning('参数校验失败：发布次数无效', ['releases_number' => $releasesNumber]);
    echo json_encode([
        'code' => 4007,
        'message' => '发布次数必须大于 0',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 限制最大发布次数
if ($releasesNumber > 100) {
    $requestLogger->warning('参数校验失败：发布次数超过限制', ['releases_number' => $releasesNumber]);
    echo json_encode([
        'code' => 4008,
        'message' => '发布次数不能超过 100',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 查询任务模板
    $requestLogger->debug('开始查询任务模板', ['template_id' => $templateId]);
    $stmt = $db->prepare("SELECT id, type, title, stage1_title, stage1_price, stage2_title, stage2_price, status FROM task_templates WHERE id = ?");
    $stmt->execute([$templateId]);
    $template = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$template) {
        $requestLogger->warning('任务模板不存在', ['template_id' => $templateId]);
        echo json_encode([
            'code' => 4009,
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
            'code' => 4010,
            'message' => '任务模板已禁用',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $requestLogger->debug('任务模板查询成功', [
        'template_id' => $template['id'],
        'type' => $template['type'],
        'title' => $template['title'],
        'stage1_price' => $template['stage1_price'],
        'stage2_price' => $template['stage2_price']
    ]);
    
    // 验证是否为组合任务
    if ((int)$template['type'] !== 1) {
        $requestLogger->warning('快捷派单仅支持组合任务模板', ['template_type' => $template['type']]);
        echo json_encode([
            'code' => 4011,
            'message' => '快捷派单仅支持组合任务模板',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
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
    
    // 校验 recommend_marks 数量
    $totalCountPerTask = $stage1Count + $stage2Count;
    $requiredTotalCount = $releasesNumber * $totalCountPerTask;
    if (!is_array($recommendMarks)) {
        $requestLogger->warning('参数校验失败：推荐评论格式错误', ['recommend_marks' => $recommendMarks]);
        echo json_encode([
            'code' => 4014,
            'message' => '推荐评论格式错误',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    if (count($recommendMarks) !== $requiredTotalCount) {
        $requestLogger->warning('参数校验失败：推荐评论数量不匹配', [
            'expected' => $requiredTotalCount,
            'actual' => count($recommendMarks),
            'releases_number' => $releasesNumber,
            'total_per_task' => $totalCountPerTask
        ]);
        echo json_encode([
            'code' => 4015,
            'message' => "推荐评论数量不匹配，应为 {$requiredTotalCount} 组（{$releasesNumber}次发布 × 每组{$totalCountPerTask}条评论）",
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
                'code' => 4014,
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
                'code' => 4014,
                'message' => '第 ' . ($index + 1) . ' 个推荐评论必须包含 comment 字段',
                'data' => [],
                'timestamp' => time()
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        if (empty(trim($mark['comment']))) {
            $requestLogger->warning('参数校验失败：comment 字段为空', ['index' => $index]);
            echo json_encode([
                'code' => 4014,
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
                        'code' => 4014,
                        'message' => '第 ' . ($index + 1) . ' 个推荐评论的图片链接格式错误',
                        'data' => [],
                        'timestamp' => time()
                    ], JSON_UNESCAPED_UNICODE);
                    exit;
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
    
    $requestLogger->debug('价格计算', [
        'stage1_price' => $stage1Price,
        'stage1_count' => $stage1Count,
        'stage1_subtotal' => $stage1Price * $stage1Count,
        'stage2_price' => $stage2Price,
        'stage2_count' => $stage2Count,
        'stage2_subtotal' => $stage2Price * $stage2Count,
        'unit_total_price' => $unitTotalPrice,
        'releases_number' => $releasesNumber,
        'total_amount' => $totalAmount
    ]);
    
    // 校验总价
    if (abs($totalAmount - (float)$totalPrice) > 0.01) {
        $requestLogger->warning('参数校验失败：总价计算错误', [
            'expected' => $totalAmount,
            'provided' => $totalPrice
        ]);
        echo json_encode([
            'code' => 4016,
            'message' => '总价计算错误，应为 ' . number_format($totalAmount, 2) . '（计算方式：(阶段1单价×' . $stage1Count . ' + 阶段2单价×' . $stage2Count . ') × ' . $releasesNumber . ' = ' . number_format($stage1Price, 2) . '×' . $stage1Count . ' + ' . number_format($stage2Price, 2) . '×' . $stage2Count . ') × ' . $releasesNumber . ' = ' . number_format($unitTotalPrice, 2) . ' × ' . $releasesNumber . ' = ' . number_format($totalAmount, 2) . '）',
            'data' => [
                'expected_total_price' => $totalAmount,
                'provided_total_price' => $totalPrice,
                'stage1_price' => $stage1Price,
                'stage1_count' => $stage1Count,
                'stage2_price' => $stage2Price,
                'stage2_count' => $stage2Count,
                'releases_number' => $releasesNumber,
                'calculation' => [
                    'stage1_subtotal' => $stage1Price * $stage1Count,
                    'stage2_subtotal' => $stage2Price * $stage2Count,
                    'unit_total' => $unitTotalPrice,
                    'final_total' => $totalAmount
                ]
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 查询 B 端用户信息（获取钱包 ID 和用户名）
    $stmt = $db->prepare("SELECT wallet_id, username FROM b_users WHERE id = ?");
    $stmt->execute([$currentUser['user_id']]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        $errorLogger->error('B 端用户信息不存在', ['user_id' => $currentUser['user_id']]);
        echo json_encode([
            'code' => 4017,
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
            'code' => 4018,
            'message' => '钱包不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 将总价转换为分（元 -> 分）
    $totalAmountInCents = (int)round($totalAmount * 100);
    $beforeBalance = (int)$wallet['balance'];
    
    // 校验余额是否足够
    if ($beforeBalance < $totalAmountInCents) {
        $requestLogger->warning('B 端用户余额不足', [
            'user_id' => $currentUser['user_id'],
            'before_balance' => $beforeBalance,
            'need_balance' => $totalAmountInCents
        ]);
        echo json_encode([
            'code' => 4019,
            'message' => "余额不足，当前余额：¥" . number_format($beforeBalance / 100, 2) . "，需要：¥" . number_format($totalAmountInCents / 100, 2),
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    $requestLogger->debug('开始发布任务', [
        'releases_number' => $releasesNumber,
        'total_amount' => $totalAmount,
        'total_amount_cents' => $totalAmountInCents
    ]);
    
    // 开启事务
    $db->beginTransaction();
    
    // 记录创建的任务
    $createdTasks = [];
    
    // 循环发布任务
    for ($i = 0; $i < $releasesNumber; $i++) {
        $requestLogger->debug('循环发布任务', ['iteration' => $i + 1, 'total' => $releasesNumber]);
        
        // 获取当前视频链接
        $currentVideoUrl = trim($videoUrls[$i]);
        $requestLogger->debug('使用视频链接', ['video_url' => $currentVideoUrl]);
        
        // 生成唯一的组合任务标识
        $comboTaskId = 'COMBO_' . time() . '_' . $currentUser['user_id'] . '_' . ($i + 1);
        $requestLogger->debug('生成 combo_task_id', ['combo_task_id' => $comboTaskId]);
        
        // 分配评论：每条任务使用不同的评论组
        $taskCommentStart = $i * $totalCountPerTask;
        $taskComments = array_slice($recommendMarks, $taskCommentStart, $totalCountPerTask);
        $stage1Marks = array_slice($taskComments, 0, $stage1Count);
        $stage2Marks = array_slice($taskComments, $stage1Count, $stage2Count);
        $requestLogger->debug('分配评论', [
            'task_index' => $i + 1,
            'comment_start' => $taskCommentStart,
            'comment_end' => $taskCommentStart + $totalCountPerTask - 1,
            'stage1_marks_count' => count($stage1Marks),
            'stage2_marks_count' => count($stage2Marks)
        ]);
        
        // 1. 创建阶段 1 任务（已开放）
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
        $requestLogger->debug('创建阶段 1 任务成功', ['task_id' => $stage1TaskId]);
        
        // 2. 创建阶段 2 任务（未开放，video_url 暂时为 NULL）
        $stmt = $db->prepare("INSERT INTO b_tasks (b_user_id, combo_task_id, stage, stage_status, parent_task_id, template_id, video_url, deadline, recommend_marks, task_count, task_done, task_doing, task_reviewing, unit_price, total_price, status) VALUES (?, ?, 2, 0, ?, ?, NULL, ?, ?, ?, 0, 0, 0, ?, ?, 1)");
        
        $stage2TotalPrice = $stage2Price * $stage2Count;
        $stmt->execute([
            $currentUser['user_id'],
            $comboTaskId,
            $stage1TaskId,  // 父任务 ID
            $templateId,
            $deadline,
            json_encode($stage2Marks, JSON_UNESCAPED_UNICODE),
            $stage2Count,
            $stage2Price,
            $stage2TotalPrice
        ]);
        
        $stage2TaskId = $db->lastInsertId();
        $requestLogger->debug('创建阶段 2 任务成功', ['task_id' => $stage2TaskId]);
        
        // 记录任务信息
        $createdTasks[] = [
            'combo_task_id' => $comboTaskId,
            'stage1_task_id' => (int)$stage1TaskId,
            'stage2_task_id' => (int)$stage2TaskId
        ];
    }
    
    $requestLogger->debug('任务创建完成', ['created_count' => count($createdTasks)]);
    
    // 2. 扣除钱包余额
    $afterBalance = $beforeBalance - $totalAmountInCents;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE id = ?");
    $stmt->execute([$afterBalance, $bUser['wallet_id']]);
    
    // 3. 记录钱包流水
    $remark = "快捷派单【{$template['title']}】{$releasesNumber}组任务，每组{$stage1Count}+{$stage2Count}个任务，扣除 ¥" . number_format($totalAmount, 2);
    // 根据任务模板 ID 确定任务类型
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
        $createdTasks[0]['stage1_task_id'], // 使用第一个任务 ID 作为关联 ID
        $taskType,
        $taskTypeText,
        $remark
    ]);
    
    // 插入 B 端任务统计记录
    try {
        $stmt = $db->prepare("INSERT INTO b_task_statistics (b_user_id, username, flow_type, amount, before_balance, after_balance, related_type, related_id, task_types, task_types_text, record_status, record_status_text, remark) VALUES (?, ?, 2, ?, ?, ?, 'task_publish', ?, ?, ?, 0, '任务发布记录，当前状态已发布，待领取', ?)");
        $stmt->execute([
            $currentUser['user_id'],
            $bUser['username'],
            $totalAmountInCents,
            $beforeBalance,
            $afterBalance,
            $createdTasks[0]['stage1_task_id'], // 使用第一个任务 ID 作为关联 ID
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
    $auditLogger->notice('B 端快捷派单成功', [
        'user_id' => $currentUser['user_id'],
        'username' => $bUser['username'],
        'releases_number' => $releasesNumber,
        'total_amount' => $totalAmount,
        'created_tasks_count' => count($createdTasks),
    ]);
    
    $requestLogger->info('快捷派单成功', [
        'releases_number' => $releasesNumber,
        'total_amount' => $totalAmount,
        'created_tasks_count' => count($createdTasks),
    ]);
    
    // 返回成功响应
    echo json_encode([
        'code' => 0,
        'message' => '快捷派单成功',
        'data' => [
            'releases_number' => (int)$releasesNumber,
            'total_price' => $totalAmount,
            'tasks' => $createdTasks,
            'wallet' => [
                'before_balance' => number_format($beforeBalance / 100, 2),
                'after_balance' => number_format($afterBalance / 100, 2),
                'deducted' => number_format($totalAmountInCents / 100, 2)
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    // 回滚事务
    if ($db->inTransaction()) {
        $requestLogger->debug('回滚数据库事务');
        $db->rollBack();
    }
    
    // 记录错误
    $errorLogger->error('快捷派单失败：数据库异常', [
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
    $errorLogger->error('快捷派单失败：系统异常', [
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
