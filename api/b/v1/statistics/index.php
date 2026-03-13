<?php
/**
 * B端数据统计接口
 * 
 * GET /api/b/v1/statistics/index.php
 * 
 * 请求头：
 * X-Token: <token> (B端)
 * 
 * 返回数据：
 * {
 *   "task_stats": {
 *     "total": 10,              // 发布任务总数量
 *     "by_type": {             // 按任务类型统计
 *       "normal": 5,           // 普通任务数量
 *       "magnifier": 3,        // 放大镜任务数量
 *       "combo": 2             // 组合任务数量
 *     },
 *     "by_status": {           // 按状态统计
 *       "published": 0,        // 已发布
 *       "ongoing": 5,         // 进行中
 *       "completed": 3,        // 已完成
 *       "cancelled": 2         // 已取消
 *     }
 *   },
 *   "financial_stats": {
 *     "total_recharge": 5000,       // 充值总额（分）
 *     "total_expenditure": 3000,    // 支出总额（分）
 *     "total_income": 0,           // 收入总额（分）
 *     "current_balance": 2000,      // 当前余额（分）
 *     "today_expenditure": 500,     // 今日支出（分）
 *     "today_recharge": 1000        // 今日充值（分）
 *   },
 *   "transaction_stats": {
 *     "total_transactions": 50,     // 总交易笔数
 *     "recharge_count": 10,         // 充值次数
 *     "task_publish_count": 20,     // 任务发布次数
 *     "rental_freeze_count": 5     // 租赁冻结次数
 *   }
 * }
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: X-Token, Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

$db = Database::connect();

// 测试模式：如果传入test参数，则使用默认用户ID
$testMode = isset($_GET['test']) && $_GET['test'] === '1';

if ($testMode) {
    // 使用默认B端用户ID 1
    $userId = 1;
    $userType = 2;
} else {
    $auth = new AuthMiddleware($db);
    $currentUser = $auth->authenticateB();
    
    $userId = $currentUser['user_id'];
    $userType = 2;
}

try {
    // 查询B端用户信息和钱包
    $stmt = $db->prepare("SELECT wallet_id FROM b_users WHERE id = ?");
    $stmt->execute([$userId]);
    $bUser = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$bUser) {
        Response::error('用户信息异常', $errorCodes['USER_NOT_FOUND']);
    }
    
    $walletId = $bUser['wallet_id'];
    
    // 获取当前钱包余额
    $stmt = $db->prepare("SELECT balance FROM wallets WHERE id = ?");
    $stmt->execute([$walletId]);
    $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
    $currentBalance = $wallet ? (int)$wallet['balance'] : 0;
    
    // ========== 任务统计 ==========
    
    // 发布任务总数量（从b_tasks表）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM b_tasks WHERE b_user_id = ?");
    $stmt->execute([$userId]);
    $totalTasks = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 按任务类型统计（combo_task_id不为空的是组合任务）
    $stmt = $db->prepare("
        SELECT 
            SUM(CASE WHEN combo_task_id IS NULL OR combo_task_id = 0 THEN 1 ELSE 0 END) as normal,
            SUM(CASE WHEN template_id = 3 THEN 1 ELSE 0 END) as magnifier,
            SUM(CASE WHEN combo_task_id IS NOT NULL AND combo_task_id > 0 AND stage = 1 THEN 1 ELSE 0 END) as combo
        FROM b_tasks 
        WHERE b_user_id = ?
    ");
    $stmt->execute([$userId]);
    $tasksByType = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 按状态统计
    $stmt = $db->prepare("
        SELECT 
            SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) as published,
            SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as ongoing,
            SUM(CASE WHEN status = 2 THEN 1 ELSE 0 END) as completed,
            SUM(CASE WHEN status = 3 THEN 1 ELSE 0 END) as cancelled
        FROM b_tasks 
        WHERE b_user_id = ?
    ");
    $stmt->execute([$userId]);
    $tasksByStatus = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // ========== 财务统计 ==========
    
    // 充值总额（type=1表示收入，related_type=recharge表示充值）
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND type = 1 AND related_type = 'recharge'
    ");
    $stmt->execute([$userId, $userType]);
    $totalRecharge = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 支出总额（type=2表示支出，包括任务发布、租赁冻结等）
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND type = 2
    ");
    $stmt->execute([$userId, $userType]);
    $totalExpenditure = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 收入总额（type=1表示收入，排除充值）
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND type = 1 AND related_type != 'recharge'
    ");
    $stmt->execute([$userId, $userType]);
    $totalIncome = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 今日支出
    $today = date('Y-m-d');
    $todayStart = $today . ' 00:00:00';
    $todayEnd = $today . ' 23:59:59';
    
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND type = 2 
        AND created_at BETWEEN ? AND ?
    ");
    $stmt->execute([$userId, $userType, $todayStart, $todayEnd]);
    $todayExpenditure = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 今日充值
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND type = 1 AND related_type = 'recharge'
        AND created_at BETWEEN ? AND ?
    ");
    $stmt->execute([$userId, $userType, $todayStart, $todayEnd]);
    $todayRecharge = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // ========== 交易统计 ==========
    
    // 总交易笔数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ?
    ");
    $stmt->execute([$userId, $userType]);
    $totalTransactions = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 充值次数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND related_type = 'recharge'
    ");
    $stmt->execute([$userId, $userType]);
    $rechargeCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 任务发布次数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND related_type = 'task'
    ");
    $stmt->execute([$userId, $userType]);
    $taskPublishCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 租赁冻结次数
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND related_type = 'rental_freeze'
    ");
    $stmt->execute([$userId, $userType]);
    $rentalFreezeCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 按任务类型统计发布任务数量
    $stmt = $db->prepare("
        SELECT task_types, task_types_text, COUNT(*) as count 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND related_type = 'task' AND task_types IS NOT NULL
        GROUP BY task_types, task_types_text
    ");
    $stmt->execute([$userId, $userType]);
    $tasksByTaskType = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $tasksByTaskType[] = [
            'task_types' => (int)$row['task_types'],
            'task_types_text' => $row['task_types_text'] ?? '',
            'count' => (int)$row['count']
        ];
    }
    
    // 租赁订单相关统计
    $stmt = $db->prepare("
        SELECT COUNT(*) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND (related_type LIKE 'rental_%' OR task_types = 6 OR task_types = 7)
    ");
    $stmt->execute([$userId, $userType]);
    $rentalOrderCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // 租赁订单支出总额
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total 
        FROM wallets_log 
        WHERE user_id = ? AND user_type = ? AND type = 2 AND (related_type LIKE 'rental_%' OR task_types = 6 OR task_types = 7)
    ");
    $stmt->execute([$userId, $userType]);
    $rentalOrderExpenditure = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // ========== 放大镜任务统计 ==========
    
    // 放大镜任务总数量
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM magnifying_glass_tasks WHERE b_user_id = ?");
    $stmt->execute([$userId]);
    $totalMagnifierTasks = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
    
    // ========== 时间周期统计 ==========
    
    // 1. 当天数据详细统计
    $todayStats = [
        'date' => $today,
        'expenditure' => (int)$todayExpenditure,
        'expenditure_yuan' => number_format($todayExpenditure / 100, 2),
        'recharge' => (int)$todayRecharge,
        'recharge_yuan' => number_format($todayRecharge / 100, 2),
        'tasks' => 0,
        'magnifier_tasks' => 0
    ];
    
    // 当天发布的任务数量
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM b_tasks WHERE b_user_id = ? AND created_at BETWEEN ? AND ?");
    $stmt->execute([$userId, $todayStart, $todayEnd]);
    $todayStats['tasks'] = (int)($stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0);
    
    // 当天发布的放大镜任务数量
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM magnifying_glass_tasks WHERE b_user_id = ? AND created_at BETWEEN ? AND ?");
    $stmt->execute([$userId, $todayStart, $todayEnd]);
    $todayStats['magnifier_tasks'] = (int)($stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0);
    
    // 2. 7天内每天数据统计
    $sevenDaysAgo = date('Y-m-d', strtotime("-6 day"));
    $sevenDaysStart = $sevenDaysAgo . ' 00:00:00';
    
    // 预初始化7天数据
    $sevenDayStats = [];
    for ($i = 6; $i >= 0; $i--) {
        $date = date('Y-m-d', strtotime("-$i day"));
        $sevenDayStats[$date] = [
            'date' => $date,
            'expenditure' => 0,
            'expenditure_yuan' => '0.00',
            'recharge' => 0,
            'recharge_yuan' => '0.00',
            'tasks' => 0,
            'magnifier_tasks' => 0
        ];
    }
    
    // 一次性查询7天内的支出数据
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE user_id = ? AND user_type = ? AND type = 2 AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $userType, $sevenDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($sevenDayStats[$date])) {
            $expenditure = (int)$row['total'];
            $sevenDayStats[$date]['expenditure'] = $expenditure;
            $sevenDayStats[$date]['expenditure_yuan'] = number_format($expenditure / 100, 2);
        }
    }
    
    // 一次性查询7天内的充值数据
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE user_id = ? AND user_type = ? AND type = 1 AND related_type = 'recharge' AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $userType, $sevenDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($sevenDayStats[$date])) {
            $recharge = (int)$row['total'];
            $sevenDayStats[$date]['recharge'] = $recharge;
            $sevenDayStats[$date]['recharge_yuan'] = number_format($recharge / 100, 2);
        }
    }
    
    // 一次性查询7天内的任务数量
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COUNT(*) as total FROM b_tasks WHERE b_user_id = ? AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $sevenDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($sevenDayStats[$date])) {
            $sevenDayStats[$date]['tasks'] = (int)$row['total'];
        }
    }
    
    // 一次性查询7天内的放大镜任务数量
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COUNT(*) as total FROM magnifying_glass_tasks WHERE b_user_id = ? AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $sevenDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($sevenDayStats[$date])) {
            $sevenDayStats[$date]['magnifier_tasks'] = (int)$row['total'];
        }
    }
    
    // 转换为数组格式
    $sevenDayStats = array_values($sevenDayStats);
    
    // 3. 30天内每天数据统计
    $thirtyDaysAgo = date('Y-m-d', strtotime("-29 day"));
    $thirtyDaysStart = $thirtyDaysAgo . ' 00:00:00';
    
    // 预初始化30天数据
    $thirtyDayStats = [];
    for ($i = 29; $i >= 0; $i--) {
        $date = date('Y-m-d', strtotime("-$i day"));
        $thirtyDayStats[$date] = [
            'date' => $date,
            'expenditure' => 0,
            'expenditure_yuan' => '0.00',
            'recharge' => 0,
            'recharge_yuan' => '0.00',
            'tasks' => 0,
            'magnifier_tasks' => 0
        ];
    }
    
    // 一次性查询30天内的支出数据
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE user_id = ? AND user_type = ? AND type = 2 AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $userType, $thirtyDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($thirtyDayStats[$date])) {
            $expenditure = (int)$row['total'];
            $thirtyDayStats[$date]['expenditure'] = $expenditure;
            $thirtyDayStats[$date]['expenditure_yuan'] = number_format($expenditure / 100, 2);
        }
    }
    
    // 一次性查询30天内的充值数据
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE user_id = ? AND user_type = ? AND type = 1 AND related_type = 'recharge' AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $userType, $thirtyDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($thirtyDayStats[$date])) {
            $recharge = (int)$row['total'];
            $thirtyDayStats[$date]['recharge'] = $recharge;
            $thirtyDayStats[$date]['recharge_yuan'] = number_format($recharge / 100, 2);
        }
    }
    
    // 一次性查询30天内的任务数量
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COUNT(*) as total FROM b_tasks WHERE b_user_id = ? AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $thirtyDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($thirtyDayStats[$date])) {
            $thirtyDayStats[$date]['tasks'] = (int)$row['total'];
        }
    }
    
    // 一次性查询30天内的放大镜任务数量
    $stmt = $db->prepare("SELECT DATE(created_at) as date, COUNT(*) as total FROM magnifying_glass_tasks WHERE b_user_id = ? AND created_at BETWEEN ? AND ? GROUP BY DATE(created_at)");
    $stmt->execute([$userId, $thirtyDaysStart, $todayEnd]);
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $date = $row['date'];
        if (isset($thirtyDayStats[$date])) {
            $thirtyDayStats[$date]['magnifier_tasks'] = (int)$row['total'];
        }
    }
    
    // 转换为数组格式
    $thirtyDayStats = array_values($thirtyDayStats);
    
    // 返回统计数据
    Response::success([
        'task_stats' => [
            'total' => (int)$totalTasks,
            'magnifier_total' => (int)$totalMagnifierTasks,
            'by_type' => [
                'normal' => (int)($tasksByType['normal'] ?? 0),
                'magnifier' => (int)($tasksByType['magnifier'] ?? 0),
                'combo' => (int)($tasksByType['combo'] ?? 0)
            ],
            'by_status' => [
                'published' => (int)($tasksByStatus['published'] ?? 0),
                'ongoing' => (int)($tasksByStatus['ongoing'] ?? 0),
                'completed' => (int)($tasksByStatus['completed'] ?? 0),
                'cancelled' => (int)($tasksByStatus['cancelled'] ?? 0)
            ],
            'by_task_types' => $tasksByTaskType
        ],
        'financial_stats' => [
            'total_recharge' => (int)$totalRecharge,
            'total_recharge_yuan' => number_format($totalRecharge / 100, 2),
            'total_expenditure' => (int)$totalExpenditure,
            'total_expenditure_yuan' => number_format($totalExpenditure / 100, 2),
            'total_income' => (int)$totalIncome,
            'total_income_yuan' => number_format($totalIncome / 100, 2),
            'current_balance' => (int)$currentBalance,
            'current_balance_yuan' => number_format($currentBalance / 100, 2),
            'today_expenditure' => (int)$todayExpenditure,
            'today_expenditure_yuan' => number_format($todayExpenditure / 100, 2),
            'today_recharge' => (int)$todayRecharge,
            'today_recharge_yuan' => number_format($todayRecharge / 100, 2)
        ],
        'transaction_stats' => [
            'total_transactions' => (int)$totalTransactions,
            'recharge_count' => (int)$rechargeCount,
            'task_publish_count' => (int)$taskPublishCount,
            'rental_freeze_count' => (int)$rentalFreezeCount
        ],
        'rental_stats' => [
            'order_count' => (int)$rentalOrderCount,
            'expenditure' => (int)$rentalOrderExpenditure,
            'expenditure_yuan' => number_format($rentalOrderExpenditure / 100, 2)
        ],
        'period_stats' => [
            'today' => $todayStats,
            'seven_days' => $sevenDayStats,
            'thirty_days' => $thirtyDayStats
        ]
    ], '获取统计数据成功');
    
} catch (PDOException $e) {
    Response::error('获取统计数据失败: ' . $e->getMessage(), $errorCodes['STATISTICS_QUERY_FAILED'], 500);
} catch (Exception $e) {
    Response::error('获取统计数据失败: ' . $e->getMessage(), $errorCodes['STATISTICS_QUERY_FAILED'], 500);
}
?>