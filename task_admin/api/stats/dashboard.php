<?php
/**
 * Admin统计面板API
 * GET /task_admin/api/stats/dashboard.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

// Token 认证
AdminAuthMiddleware::authenticate();

// 数据库连接
$db = Database::connect();

// 加载佣金配置
$config = require __DIR__ . '/../../../config/app.php';
$commissionCUser = $config['commission_c_user']; // 57%
$commissionAgent = $config['commission_agent']; // 8%

$today = date('Y-m-d');
$date7DaysAgo = date('Y-m-d', strtotime('-7 days'));
$date30DaysAgo = date('Y-m-d', strtotime('-30 days'));

try {
    // ========== 任务统计 ==========
    
    // 1. 总单数（已通过的任务）
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_task_records WHERE status = 3");
    $totalTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 当日总单数（今天创建的任务，不限状态）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 3. 当日待审核（status = 2）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(created_at) = ? AND status = 2");
    $stmt->execute([$today]);
    $todayReviewing = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 4. 当日进行中（status = 1）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(created_at) = ? AND status = 1");
    $stmt->execute([$today]);
    $todayDoing = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 5. 当日完成数（status = 3，今天审核通过的）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(reviewed_at) = ? AND status = 3");
    $stmt->execute([$today]);
    $todayCompleted = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 6. 当日驳回数（status = 4，今天审核驳回的）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(reviewed_at) = ? AND status = 4");
    $stmt->execute([$today]);
    $todayRejected = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // ========== 流水统计 ==========
    
    // 7. 总流水（所有已完成任务的总价，从 b_tasks 单价 * 完成数量）
    $stmt = $db->query("
        SELECT COALESCE(SUM(b.unit_price * (SELECT COUNT(*) FROM c_task_records c WHERE c.b_task_id = b.id AND c.status = 3)), 0) as total
        FROM b_tasks b
    ");
    $totalRevenue = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 8. 当日流水（今天审核通过的任务的总价）
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(b.unit_price), 0) as total
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        WHERE DATE(c.reviewed_at) = ? AND c.status = 3
    ");
    $stmt->execute([$today]);
    $todayRevenue = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 9. 7日内流水
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(b.unit_price), 0) as total
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        WHERE DATE(c.reviewed_at) >= ? AND c.status = 3
    ");
    $stmt->execute([$date7DaysAgo]);
    $revenue7Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 10. 30日内流水
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(b.unit_price), 0) as total
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        WHERE DATE(c.reviewed_at) >= ? AND c.status = 3
    ");
    $stmt->execute([$date30DaysAgo]);
    $revenue30Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // ========== 利润统计 ==========
    // 利润 = 任务单价 - C端佣金(57%) - 团长佣金(如果有，8%)
    
    // 11. 总利润
    $stmt = $db->query("
        SELECT 
            c.id,
            b.unit_price,
            cu.parent_id,
            pu.is_agent
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        INNER JOIN c_users cu ON c.c_user_id = cu.id
        LEFT JOIN c_users pu ON cu.parent_id = pu.id
        WHERE c.status = 3
    ");
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $totalProfit = 0;
    foreach ($tasks as $task) {
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        // 如果有上级且上级是团长
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        $totalProfit += $profit;
    }
    
    // 12. 当日利润
    $stmt = $db->prepare("
        SELECT 
            c.id,
            b.unit_price,
            cu.parent_id,
            pu.is_agent
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        INNER JOIN c_users cu ON c.c_user_id = cu.id
        LEFT JOIN c_users pu ON cu.parent_id = pu.id
        WHERE DATE(c.reviewed_at) = ? AND c.status = 3
    ");
    $stmt->execute([$today]);
    $todayTasksForProfit = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $todayProfit = 0;
    foreach ($todayTasksForProfit as $task) {
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        $todayProfit += $profit;
    }
    
    // 13. 7日内平台利润
    $stmt = $db->prepare("
        SELECT 
            c.id,
            b.unit_price,
            cu.parent_id,
            pu.is_agent
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        INNER JOIN c_users cu ON c.c_user_id = cu.id
        LEFT JOIN c_users pu ON cu.parent_id = pu.id
        WHERE DATE(c.reviewed_at) >= ? AND c.status = 3
    ");
    $stmt->execute([$date7DaysAgo]);
    $tasks7Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $profit7Days = 0;
    foreach ($tasks7Days as $task) {
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        $profit7Days += $profit;
    }
    
    // 14. 30日内平台利润
    $stmt = $db->prepare("
        SELECT 
            c.id,
            b.unit_price,
            cu.parent_id,
            pu.is_agent
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        INNER JOIN c_users cu ON c.c_user_id = cu.id
        LEFT JOIN c_users pu ON cu.parent_id = pu.id
        WHERE DATE(c.reviewed_at) >= ? AND c.status = 3
    ");
    $stmt->execute([$date30DaysAgo]);
    $tasks30Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $profit30Days = 0;
    foreach ($tasks30Days as $task) {
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        $profit30Days += $profit;
    }
    
    // ========== 团长佣金统计 ==========
    // 从 wallets_log 表中查询 related_type = 'agent_commission' 的记录
    
    // 15. 团长佣金支出总额
    $stmt = $db->query("
        SELECT COALESCE(SUM(amount), 0) as total
        FROM wallets_log
        WHERE related_type = 'agent_commission'
    ");
    $totalAgentCommission = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 16. 7日内团长佣金支出
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total
        FROM wallets_log
        WHERE related_type = 'agent_commission' AND DATE(created_at) >= ?
    ");
    $stmt->execute([$date7DaysAgo]);
    $agentCommission7Days = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 17. 30日内团长佣金支出
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(amount), 0) as total
        FROM wallets_log
        WHERE related_type = 'agent_commission' AND DATE(created_at) >= ?
    ");
    $stmt->execute([$date30DaysAgo]);
    $agentCommission30Days = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // ========== 返回统计数据 ==========
    
    echo json_encode([
        'code' => 0,
        'message' => 'ok',
        'data' => [
            // 任务统计
            'tasks' => [
                'total' => $totalTasks,
                'today_total' => $todayTasks,
                'today_reviewing' => $todayReviewing,
                'today_doing' => $todayDoing,
                'today_completed' => $todayCompleted,
                'today_rejected' => $todayRejected
            ],
            // 流水统计
            'revenue' => [
                'total' => number_format($totalRevenue, 2),
                'today' => number_format($todayRevenue, 2),
                '7_days' => number_format($revenue7Days, 2),
                '30_days' => number_format($revenue30Days, 2)
            ],
            // 利润统计
            'profit' => [
                'total' => number_format($totalProfit, 2),
                'today' => number_format($todayProfit, 2),
                '7_days' => number_format($profit7Days, 2),
                '30_days' => number_format($profit30Days, 2)
            ],
            // 团长佣金统计
            'agent_commission' => [
                'total' => number_format($totalAgentCommission / 100, 2),
                '7_days' => number_format($agentCommission7Days / 100, 2),
                '30_days' => number_format($agentCommission30Days / 100, 2)
            ]
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '数据库查询失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
}
