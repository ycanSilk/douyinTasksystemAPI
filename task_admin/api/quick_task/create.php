<?php
/**
 * Admin 端快捷派单接口（刷单任务，直接已完成状态，不扣款）
 * 
 * POST /task_admin/api/quick_task/create.php
 * 
 * 请求头：
 * X-Token: <token> (Admin 端)
 * Content-Type: application/json
 * 
 * 请求体：
 * {
 *   "template_id": 1,                          // 任务模板 ID (必填，固定为 1)
 *   "video_url": "https://example.com/video.mp4",  // 单条视频链接 (必填)
 *   "releases_number": 5,                      // 发布次数 (必填，上限 999 次)
 *   "comment": "很好用，值得购买"              // 评论内容 (必填)
 * }
 * 
 * 请求示例：
 * {
 *   "template_id": 1,
 *   "video_url": "https://douyin.com/video/123456",
 *   "releases_number": 5,
 *   "comment": "很好用，值得购买"
 * }
 * 
 * 响应示例（成功）：
 * {
 *   "code": 0,
 *   "message": "快捷派单成功",
 *   "data": {
 *     "releases_number": 5,
 *     "total_price": 15.00,
 *     "tasks": [
 *       {"task_id": 123, "combo_task_id": "COMBO_1705420800_1_1"},
 *       {"task_id": 124, "combo_task_id": "COMBO_1705420800_1_2"}
 *     ]
 *   }
 * }
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// 加载统一日志系统
require_once __DIR__ . '/../../../core/Autoloader.php';
use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

// 设置当前接口上下文
LoggerRouter::setContext('task_admin/api/quick_task/create');

// 获取日志实例
$requestLogger = LoggerFactory::getLogger('request');
$errorLogger = LoggerFactory::getLogger('error');
$auditLogger = LoggerFactory::getLogger('audit');

// 记录请求开始
$requestLogger->info('=== Admin 端快捷派单请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
]);

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

// Token 认证
$requestLogger->debug('开始 Token 认证');
try {
    $currentUser = AdminAuthMiddleware::authenticate();
    $requestLogger->debug('Token 认证成功', ['user_id' => $currentUser['user_id'], 'username' => $currentUser['username']]);
} catch (Exception $e) {
    $errorLogger->error('Token 认证失败', ['exception' => $e->getMessage()]);
    echo json_encode([
        'code' => 4017,
        'message' => '用户认证失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

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

// 获取请求参数
$rawInput = file_get_contents('php://input');
$requestLogger->debug('请求体内容', ['body' => $rawInput]);

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
$videoUrl = $input['video_url'] ?? '';
$releasesNumber = $input['releases_number'] ?? 0;
$comment = $input['comment'] ?? '';

// 截止时间自动设置为当前时间 +30 分钟
$deadline = time() + 1800; // 30 分钟 = 1800 秒

// 记录请求参数
$requestLogger->debug('请求参数', [
    'template_id' => $templateId,
    'video_url' => $videoUrl,
    'deadline' => $deadline,
    'deadline_text' => date('Y-m-d H:i:s', $deadline),
    'releases_number' => $releasesNumber,
    'comment' => $comment,
]);

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

if (empty(trim($videoUrl))) {
    $requestLogger->warning('参数校验失败：视频链接为空', ['video_url' => $videoUrl]);
    echo json_encode([
        'code' => 4003,
        'message' => '视频链接不能为空',
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

// 校验发布次数上限
if ($releasesNumber > 999) {
    $requestLogger->warning('参数校验失败：发布次数超过上限', ['releases_number' => $releasesNumber]);
    echo json_encode([
        'code' => 4008,
        'message' => '发布次数不能超过 999 次',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (empty(trim($comment))) {
    $requestLogger->warning('参数校验失败：评论内容为空', ['comment' => $comment]);
    echo json_encode([
        'code' => 4014,
        'message' => '评论内容不能为空',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $requestLogger->debug('开始查询任务模板', ['template_id' => $templateId]);
    $stmt = $db->prepare("SELECT id, type, title, stage1_price, status FROM task_templates WHERE id = ?");
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
        'stage1_price' => $template['stage1_price']
    ]);
    
    // 验证是否为单任务模板（type=0）
    if ((int)$template['type'] !== 0) {
        $requestLogger->warning('快捷派单仅支持单任务模板', ['template_type' => $template['type']]);
        echo json_encode([
            'code' => 4011,
            'message' => '快捷派单仅支持单任务模板',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 计算价格
    $unitPrice = (float)$template['stage1_price'];
    
    // 如果模板单价为 0，使用固定单价 3 元
    if ($unitPrice <= 0) {
        $unitPrice = 3.00;
        $requestLogger->info('模板单价为 0，使用固定单价 3 元');
    }
    
    // 计算总金额（单价 * 发布次数）
    $totalAmount = $unitPrice * $releasesNumber;
    
    $requestLogger->debug('价格计算', [
        'unit_price' => $unitPrice,
        'releases_number' => $releasesNumber,
        'total_amount' => $totalAmount
    ]);
    
    $requestLogger->debug('开始发布任务', [
        'releases_number' => $releasesNumber,
        'total_amount' => $totalAmount
    ]);
    
    // 开启事务
    $db->beginTransaction();
    $requestLogger->debug('数据库事务已开启');
    
    // 记录创建的任务
    $createdTasks = [];
    
    // 循环发布任务
    for ($i = 0; $i < $releasesNumber; $i++) {
        $requestLogger->debug('循环发布任务', ['iteration' => $i + 1, 'total' => $releasesNumber]);
        
        // 生成唯一的组合任务标识（保持兼容）
        $comboTaskId = 'COMBO_' . time() . '_' . $currentUser['user_id'] . '_' . ($i + 1);
        $requestLogger->debug('生成 combo_task_id', ['combo_task_id' => $comboTaskId]);
        
        // 创建单任务（状态直接为已完成）
        // b_tasks 表字段: b_user_id, combo_task_id, stage, stage_status, parent_task_id, template_id, video_url, deadline, recommend_marks, task_count, task_done, task_doing, task_reviewing, unit_price, total_price, status
        // 单任务：stage=0, stage_status=1(已开放), status=2(已完成)
        $stmt = $db->prepare("INSERT INTO b_tasks (b_user_id, combo_task_id, stage, stage_status, parent_task_id, template_id, video_url, deadline, recommend_marks, task_count, task_done, task_doing, task_reviewing, unit_price, total_price, status) 
        VALUES (?, ?, 0, 1, NULL, ?, ?, ?, ?, 1, 0, 0, 0, ?, ?, 5)");
        
        $stmt->execute([
            $currentUser['user_id'],
            $comboTaskId,
            $templateId,
            $videoUrl,
            $deadline,
            json_encode([['comment' => $comment, 'image_url' => '']], JSON_UNESCAPED_UNICODE),
            $unitPrice,
            $unitPrice
        ]);
        
        $taskId = $db->lastInsertId();
        $requestLogger->debug('创建任务成功', ['task_id' => $taskId]);
        
        // 记录任务信息
        $createdTasks[] = [
            'task_id' => (int)$taskId,
            'combo_task_id' => $comboTaskId
        ];
    }
    
    $requestLogger->debug('任务创建完成', ['created_count' => count($createdTasks)]);
    
    // 提交事务
    $requestLogger->debug('提交数据库事务');
    $db->commit();
    $requestLogger->debug('事务提交成功');
    
    // 记录审计日志
    $auditLogger->notice('Admin 端快捷派单成功', [
        'user_id' => $currentUser['user_id'],
        'username' => $currentUser['username'],
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
            'tasks' => $createdTasks
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
        'message' => '任务发布失败: ' . $e->getMessage(),
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
        'message' => '任务发布失败: ' . $e->getMessage(),
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
