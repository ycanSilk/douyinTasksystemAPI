<?php
/**
 * Admin统计面板API
 * GET /task_admin/api/stats/dashboard.php
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

// 处理OPTIONS预检请求
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';
require_once __DIR__ . '/../../../config/error_codes.php';

// Token 认证
AdminAuthMiddleware::authenticate();

// 加载错误码
$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// 加载佣金配置
$config = require __DIR__ . '/../../../config/app.php';
$commissionCUser = $config['commission_c_user'] ?? 57; // 57%
$commissionAgent = $config['commission_agent'] ?? 8; // 8%

// 处理时间范围参数
$today = date('Y-m-d');
$period = isset($_GET['period']) ? (int)$_GET['period'] : 7;
$startDate = isset($_GET['startDate']) ? $_GET['startDate'] : date('Y-m-d', strtotime("-$period days"));
$endDate = isset($_GET['endDate']) ? $_GET['endDate'] : $today;
$timeRange = isset($_GET['timeRange']) ? $_GET['timeRange'] : $period . 'd'; // 可选值：7d, 15d, 30d, custom

// 计算默认时间范围
if (isset($_GET['period'])) {
    // 如果有period参数，优先使用它来设置时间范围
    $startDate = date('Y-m-d', strtotime("-$period days"));
} else {
    switch ($timeRange) {
        case '7d':
            $startDate = date('Y-m-d', strtotime('-7 days'));
            break;
        case '15d':
            $startDate = date('Y-m-d', strtotime('-15 days'));
            break;
        case '30d':
            $startDate = date('Y-m-d', strtotime('-30 days'));
            break;
        case '90d':
            $startDate = date('Y-m-d', strtotime('-90 days'));
            break;
        case 'custom':
            // 使用传入的startDate和endDate
            break;
        default:
            $startDate = date('Y-m-d', strtotime("-$period days"));
    }
}

// 计算7天、15天和30天前的日期
$date7DaysAgo = date('Y-m-d', strtotime('-7 days'));
$date15DaysAgo = date('Y-m-d', strtotime('-15 days'));
$date30DaysAgo = date('Y-m-d', strtotime('-30 days'));

try {
    // 记录开始执行
    error_log('Dashboard API started at ' . date('Y-m-d H:i:s'));
    
    // 检查配置文件
    if (!isset($config['commission_c_user']) || !isset($config['commission_agent'])) {
        throw new Exception('Commission config not found');
    }
    
    error_log('Config loaded successfully');
    
    // 检查数据库连接
    if (!$db) {
        throw new Exception('Database connection failed');
    }
    
    error_log('Database connected successfully');
    
    // ========== 任务统计 ==========
    
    // 参考 tasks/list.php 的实现方式
    // 1. 总单数（已通过的任务）
    error_log('Executing task count query');
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_task_records WHERE status = 3");
    $totalTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    error_log('Task count query completed: ' . $totalTasks);
    
    // 2. 当日总单数（今天创建的任务，不限状态）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 3. 当日待审核（status = 2）- 参考 pending.php 接口的实现
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE status = 2");
    $stmt->execute();
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
    
    // 7.1 派单任务数（从b_tasks表）- 仅包含状态为1(进行中)、2(已完成)、3(已取消)的任务，排除状态为0(已过期)的任务
    $stmt = $db->query("SELECT COALESCE(SUM(task_count), 0) as task_count FROM b_tasks WHERE status IN (1, 2, 3)");
    $totalSendTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['task_count'];
    error_log('统计任务数量 ' . $totalSendTasks);

    // 7.2 派单已过期任务数（从b_tasks表）- 仅包含状态为1(进行中)、2(已完成)、3(已取消)的任务，排除状态为0(已过期)的任务
    $stmt = $db->query("SELECT COALESCE(SUM(task_count), 0) as task_count FROM b_tasks WHERE status IN (0)");
    $totalExpiredTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['task_count'];
    error_log('统计任务数量 ' . $totalExpiredTasks);
    
    // 8. 当日派单任务数
    $stmt = $db->prepare("SELECT COALESCE(SUM(task_count), 0) as total FROM b_tasks WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todaySendTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 9. 接单任务数（从c_task_records表）- 合并统计进行中、已完成、待审核三种状态的任务数量总和
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_task_records WHERE status IN (1, 2, 3)");
    $totalReceiveTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 10. 当日接单任务数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_task_records WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayReceiveTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 11. 任务模板统计
    try {
        $stmt = $db->query("SELECT COUNT(*) as total FROM task_templates");
        $totalTaskTemplates = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        $stmt = $db->query("SELECT type, COUNT(*) as count FROM task_templates GROUP BY type");
        $taskTemplateTypeCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $taskTemplateTypes = [
            'single' => 0,
            'combo' => 0
        ];
        
        foreach ($taskTemplateTypeCounts as $item) {
            if ((int)$item['type'] === 0) {
                $taskTemplateTypes['single'] = (int)$item['count'];
            } elseif ((int)$item['type'] === 1) {
                $taskTemplateTypes['combo'] = (int)$item['count'];
            }
        }
    } catch (PDOException $e) {
        error_log('Task template statistics failed: ' . $e->getMessage());
        $totalTaskTemplates = 0;
        $taskTemplateTypes = [
            'single' => 0,
            'combo' => 0
        ];
    }
    
    // ========== 放大镜任务统计 ==========
    
    // 1. 总放大镜任务数
    $stmt = $db->query("SELECT COUNT(*) as total FROM magnifying_glass_tasks");
    $totalMagnifierTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 当日新增放大镜任务数
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM magnifying_glass_tasks WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayMagnifierTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 3. 放大镜任务状态统计
    $stmt = $db->query("SELECT status, COUNT(*) as count FROM magnifying_glass_tasks GROUP BY status");
    $magnifierStatusCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 整理放大镜任务状态统计
    $magnifierTasksByStatus = [
        'published' => 0,  // 已发布
        'ongoing' => 0,    // 进行中
        'completed' => 0,  // 已完成
        'cancelled' => 0   // 已取消
    ];
    
    foreach ($magnifierStatusCounts as $item) {
        switch ($item['status']) {
            case 0:
                $magnifierTasksByStatus['published'] = (int)$item['count'];
                break;
            case 1:
                $magnifierTasksByStatus['ongoing'] = (int)$item['count'];
                break;
            case 2:
                $magnifierTasksByStatus['completed'] = (int)$item['count'];
                break;
            case 3:
                $magnifierTasksByStatus['cancelled'] = (int)$item['count'];
                break;
        }
    }
    
    // ========== 多维度分类统计 ==========
    
    // 初始化分类统计数据
    $rentalTotal = 0;
    $rentalToday = 0;
    $singleTaskTotal = 0;
    $singleTaskToday = 0;
    $comboTaskTotal = 0;
    $comboTaskToday = 0;
    
    // 账号租赁任务统计
    try {
        // 总账号租赁任务数
        $stmt = $db->query("SELECT COUNT(*) as total FROM rental_orders");
        $totalRentalTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 当日新增账号租赁任务数
        $stmt = $db->prepare("SELECT COUNT(*) as total FROM rental_orders WHERE DATE(created_at) = ?");
        $stmt->execute([$today]);
        $todayRentalTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 活跃账号租赁任务数（状态为进行中）
        $stmt = $db->query("SELECT COUNT(*) as total FROM rental_orders WHERE status = 1");
        $activeRentalTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
    } catch (PDOException $e) {
        error_log('Rental tasks statistics failed: ' . $e->getMessage());
        $totalRentalTasks = 0;
        $todayRentalTasks = 0;
        $activeRentalTasks = 0;
    }
    
    // 评论类型统计，根据template_id字段判断
    // 1：上评评论，2：中评评论，4：上中评评论，5：中下评评论
    $commentStats = [
        'positive' => 0,          // 上评评论 (template_id = 1)
        'neutral' => 0,           // 中评评论 (template_id = 2)
        'positive_neutral' => 0,  // 上中评评论 (template_id = 4)
        'neutral_negative' => 0   // 中下评评论 (template_id = 5)
    ];
    
    try {
        // 根据template_id字段判断评论类型
        // 1：上评评论，2：中评评论，4：上中评评论，5：中下评评论
        $stmt = $db->query("
            SELECT 
                CASE 
                    WHEN t.id = 1 THEN 'positive'
                    WHEN t.id = 2 THEN 'neutral'
                    WHEN t.id = 4 THEN 'positive_neutral'
                    WHEN t.id = 5 THEN 'neutral_negative'
                    ELSE 'other'
                END as comment_type,
                COUNT(*) as count
            FROM b_tasks b
            INNER JOIN task_templates t ON b.template_id = t.id
            GROUP BY comment_type
        ");
        $commentTypeCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($commentTypeCounts as $item) {
            switch ($item['comment_type']) {
                case 'positive':
                    $commentStats['positive'] = (int)$item['count'];
                    break;
                case 'neutral':
                    $commentStats['neutral'] = (int)$item['count'];
                    break;
                case 'positive_neutral':
                    $commentStats['positive_neutral'] = (int)$item['count'];
                    break;
                case 'neutral_negative':
                    $commentStats['neutral_negative'] = (int)$item['count'];
                    break;
            }
        }
        error_log('评论类型统计完成: ' . json_encode($commentStats));
    } catch (Exception $e) {
        error_log('Comment type statistics failed: ' . $e->getMessage());
    }
    
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
    
    // 10. 15日内流水
    $stmt = $db->prepare("
        SELECT COALESCE(SUM(b.unit_price), 0) as total
        FROM c_task_records c
        INNER JOIN b_tasks b ON c.b_task_id = b.id
        WHERE DATE(c.reviewed_at) >= ? AND c.status = 3
    ");
    $stmt->execute([$date15DaysAgo]);
    $revenue15Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 11. 30日内流水
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
    
    // 初始化利润相关变量
    $totalProfit = 0;
    
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
    
    // 14. 15日内平台利润
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
    $stmt->execute([$date15DaysAgo]);
    $tasks15Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $profit15Days = 0;
    foreach ($tasks15Days as $task) {
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        $profit15Days += $profit;
    }
    
    // 15. 30日内平台利润
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
    // 优化后的查询：根据用户建议，使用更准确的查询条件
    $stmt = $db->query("
        SELECT 
            COALESCE(SUM(CASE WHEN related_type = 'agent_commission' THEN amount ELSE 0 END), 0) as normal_total,
            COALESCE(SUM(CASE WHEN related_type = 'second_agent_commission' THEN amount ELSE 0 END), 0) as senior_total
        FROM wallets_log
        WHERE (related_type = 'agent_commission' OR related_type = 'second_agent_commission') 
            AND user_type = 1 
            AND type = 1
    ");
    $commissionResult = $stmt->fetch(PDO::FETCH_ASSOC);
    $totalNormalAgentCommission = (int)$commissionResult['normal_total'];
    $totalSeniorAgentCommission = (int)$commissionResult['senior_total'];
    $totalAgentCommission = $totalNormalAgentCommission + $totalSeniorAgentCommission;
    
    // 16. 7日内团长佣金支出（区分普通和高级）
    $stmt = $db->prepare("
        SELECT 
            COALESCE(SUM(CASE WHEN related_type = 'agent_commission' THEN amount ELSE 0 END), 0) as normal_total,
            COALESCE(SUM(CASE WHEN related_type = 'second_agent_commission' THEN amount ELSE 0 END), 0) as senior_total
        FROM wallets_log
        WHERE (related_type = 'agent_commission' OR related_type = 'second_agent_commission') 
            AND user_type = 1 
            AND type = 1
            AND DATE(created_at) >= ?
    ");
    $stmt->execute([$date7DaysAgo]);
    $commission7DaysResult = $stmt->fetch(PDO::FETCH_ASSOC);
    $normalAgentCommission7Days = (int)$commission7DaysResult['normal_total'];
    $seniorAgentCommission7Days = (int)$commission7DaysResult['senior_total'];
    $agentCommission7Days = $normalAgentCommission7Days + $seniorAgentCommission7Days;
    
    // 17. 15日内团长佣金支出（区分普通和高级）
    $stmt = $db->prepare("
        SELECT 
            COALESCE(SUM(CASE WHEN related_type = 'agent_commission' THEN amount ELSE 0 END), 0) as normal_total,
            COALESCE(SUM(CASE WHEN related_type = 'second_agent_commission' THEN amount ELSE 0 END), 0) as senior_total
        FROM wallets_log
        WHERE (related_type = 'agent_commission' OR related_type = 'second_agent_commission') 
            AND user_type = 1 
            AND type = 1
            AND DATE(created_at) >= ?
    ");
    $stmt->execute([$date15DaysAgo]);
    $commission15DaysResult = $stmt->fetch(PDO::FETCH_ASSOC);
    $normalAgentCommission15Days = (int)$commission15DaysResult['normal_total'];
    $seniorAgentCommission15Days = (int)$commission15DaysResult['senior_total'];
    $agentCommission15Days = $normalAgentCommission15Days + $seniorAgentCommission15Days;
    
    // 18. 30日内团长佣金支出（区分普通和高级）
    $stmt = $db->prepare("
        SELECT 
            COALESCE(SUM(CASE WHEN related_type = 'agent_commission' THEN amount ELSE 0 END), 0) as normal_total,
            COALESCE(SUM(CASE WHEN related_type = 'second_agent_commission' THEN amount ELSE 0 END), 0) as senior_total
        FROM wallets_log
        WHERE (related_type = 'agent_commission' OR related_type = 'second_agent_commission') 
            AND user_type = 1 
            AND type = 1
            AND DATE(created_at) >= ?
    ");
    $stmt->execute([$date30DaysAgo]);
    $commission30DaysResult = $stmt->fetch(PDO::FETCH_ASSOC);
    $normalAgentCommission30Days = (int)$commission30DaysResult['normal_total'];
    $seniorAgentCommission30Days = (int)$commission30DaysResult['senior_total'];
    $agentCommission30Days = $normalAgentCommission30Days + $seniorAgentCommission30Days;
    
    // 18. 自定义时间范围内的流水
    $stmt = $db->prepare("SELECT COALESCE(SUM(b.unit_price), 0) as total FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id WHERE DATE(c.reviewed_at) BETWEEN ? AND ? AND c.status = 3");
    $stmt->execute([$startDate, $endDate]);
    $revenueCustomRange = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 19. 自定义时间范围内的利润
    $stmt = $db->prepare("SELECT c.id, b.unit_price, cu.parent_id, pu.is_agent FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id INNER JOIN c_users cu ON c.c_user_id = cu.id LEFT JOIN c_users pu ON cu.parent_id = pu.id WHERE DATE(c.reviewed_at) BETWEEN ? AND ? AND c.status = 3");
    $stmt->execute([$startDate, $endDate]);
    $tasksForCustomProfit = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $profitCustomRange = 0;
    foreach ($tasksForCustomProfit as $task) {
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        $profitCustomRange += $profit;
    }
    
    // 20. 自定义时间范围内的团长佣金支出（区分普通和高级）
    $stmt = $db->prepare("
        SELECT 
            COALESCE(SUM(CASE WHEN related_type = 'agent_commission' THEN amount ELSE 0 END), 0) as normal_total,
            COALESCE(SUM(CASE WHEN related_type = 'second_agent_commission' THEN amount ELSE 0 END), 0) as senior_total
        FROM wallets_log
        WHERE (related_type = 'agent_commission' OR related_type = 'second_agent_commission') 
            AND user_type = 1 
            AND type = 1
            AND DATE(created_at) BETWEEN ? AND ?
    ");
    $stmt->execute([$startDate, $endDate]);
    $commissionCustomRangeResult = $stmt->fetch(PDO::FETCH_ASSOC);
    $normalAgentCommissionCustomRange = (int)$commissionCustomRangeResult['normal_total'];
    $seniorAgentCommissionCustomRange = (int)$commissionCustomRangeResult['senior_total'];
    $agentCommissionCustomRange = $normalAgentCommissionCustomRange + $seniorAgentCommissionCustomRange;
    
    // ========== 财务收支统计 ==========
    
    // 从 wallets_log 表查询所有财务数据
    $stmt = $db->prepare("SELECT * FROM wallets_log WHERE DATE(created_at) BETWEEN ? AND ? ORDER BY created_at DESC");
    $stmt->execute([$startDate, $endDate]);
    $walletLogs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 初始化财务变量
    $totalRecharge = 0; // 充值总数
    $totalWithdraw = 0; // 提现金额
    $taskRewardExpense = 0; // 任务奖励佣金
    $normalAgentCommission = 0; // 普通团长佣金
    $seniorAgentCommission = 0; // 高级团长佣金（二级团长）
    $accountRentalReward = 0; // 账号租赁奖励金额
    $accountPurchaseExpense = 0; // 账号购买支出
    
    // 遍历钱包流水记录
    foreach ($walletLogs as $log) {
        // 注意：数据库中的金额是以分为单位存储的，需要转换为元
        $amountInCents = (int)$log['amount'];
        $amount = (float)($amountInCents / 100); // 转换为元
        $type = (int)$log['type']; // 1=收入, 2=支出
        $userType = (int)$log['user_type']; // 1=C端, 2=B端, 3=Admin端
        $relatedType = $log['related_type'];
        
       
        // 处理收入项
        if ($type == 1) {
            switch ($relatedType) {
                case 'recharge':
                    $totalRecharge += $amount;
                   
                    break;
            }
            
            // C端用户的收入是平台的支出
            if ($userType == 1) {
              
                switch ($relatedType) {
                    // 任务奖励佣金
                    case 'commission':
                        $taskRewardExpense += $amount;
                      
                        break;
                    // 普通团长佣金支出（一级团长）
                    case 'agent_commission':
                        $normalAgentCommission += $amount;
                        
                        break;
         
                    // 二级团长佣金支出
                    case 'second_agent_commission':
                        // 二级团长佣金应该计入高级团长佣金
                        $seniorAgentCommission += $amount;
                      
                        break;
               
                   
                    // 任务佣金
                    case 'task':
                        $taskRewardExpense += $amount;
                        break;
                    // 账号租赁奖励金额
                    case 'rental_freeze':
                        $accountRentalReward += $amount;
                        break;
                    // 账号购买支出
                    case 'rental_unfreeze':
                        $accountPurchaseExpense += $amount;
                        break;
                    default:
                        break;
                }
            }
        }
        // 处理支出项
        else if ($type == 2) {
            switch ($relatedType) {
                case 'withdraw':
                    $totalWithdraw += $amount;
                    break;
                // 处理其他支出项
                case 'rental_freeze':
                    // 这是B端用户的支出，不是平台支出
                    error_log('B端用户支出: rental_freeze, amount=' . $amount);
                    break;
                case 'task':
                    // 这是B端用户的支出，不是平台支出
                    error_log('B端用户支出: task, amount=' . $amount);
                    break;
                default:
                    error_log('Unhandled related_type for 支出项: ' . $relatedType);
                    break;
            }
        }
    }
    
    // 3. 今日充值
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM recharge_requests WHERE status = 1 AND DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayRecharge = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 4. 今日提现
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM withdraw_requests WHERE status = 1 AND DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayWithdraw = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 5. 7日充值
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM recharge_requests WHERE status = 1 AND DATE(created_at) >= ?");
    $stmt->execute([$date7DaysAgo]);
    $recharge7Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 6. 7日提现
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM withdraw_requests WHERE status = 1 AND DATE(created_at) >= ?");
    $stmt->execute([$date7DaysAgo]);
    $withdraw7Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 7. 15日充值
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM recharge_requests WHERE status = 1 AND DATE(created_at) >= ?");
    $stmt->execute([$date15DaysAgo]);
    $recharge15Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 8. 15日提现
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM withdraw_requests WHERE status = 1 AND DATE(created_at) >= ?");
    $stmt->execute([$date15DaysAgo]);
    $withdraw15Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 9. 30日充值
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM recharge_requests WHERE status = 1 AND DATE(created_at) >= ?");
    $stmt->execute([$date30DaysAgo]);
    $recharge30Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 10. 30日提现
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM withdraw_requests WHERE status = 1 AND DATE(created_at) >= ?");
    $stmt->execute([$date30DaysAgo]);
    $withdraw30Days = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 17. 利润率 - 基于财务收支计算
    $profitMargin = 0;
    
    // 重新计算总支出（包含所有平台支出项）
    $totalExpenses = $taskRewardExpense + $totalNormalAgentCommission + $totalSeniorAgentCommission + $accountRentalReward + $accountPurchaseExpense + $totalWithdraw;
    
    // 重新计算总利润和利润率
    $totalProfit = $totalRecharge - $totalExpenses;
    
    // 计算利润率
    if ($totalRecharge > 0) {
        $profitMargin = (($totalRecharge - $totalExpenses) / $totalRecharge) * 100;
    }
    
    // 18. 转化率（接单任务数 / 派单任务数）
    $conversionRate = 0;
    if ($totalSendTasks > 0) {
        $conversionRate = ($totalReceiveTasks / $totalSendTasks) * 100;
    }
    
    // 不再重复初始化已经计算过的变量，保持之前的计算结果
    
    // 19. 钱包流水统计（根据时间范围）
    try {
        // 总收入
        $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE type = 1 AND DATE(created_at) BETWEEN ? AND ?");
        $stmt->execute([$startDate, $endDate]);
        $totalIncome = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
        
        // 总支出
        $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE type = 2 AND DATE(created_at) BETWEEN ? AND ?");
        $stmt->execute([$startDate, $endDate]);
        $totalExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
        
        // 按类型统计
        $stmt = $db->prepare("SELECT related_type, type, COALESCE(SUM(amount), 0) as total FROM wallets_log WHERE DATE(created_at) BETWEEN ? AND ? GROUP BY related_type, type");
        $stmt->execute([$startDate, $endDate]);
        $walletLogStats = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $walletStats = [
            'income' => $totalIncome,
            'expense' => $totalExpense,
            'by_type' => []
        ];
        
        foreach ($walletLogStats as $item) {
            $type = $item['related_type'];
            $isIncome = (int)$item['type'] === 1;
            $amount = (float)$item['total'] / 100;
            
            if (!isset($walletStats['by_type'][$type])) {
                $walletStats['by_type'][$type] = [
                    'income' => 0,
                    'expense' => 0
                ];
            }
            
            if ($isIncome) {
                $walletStats['by_type'][$type]['income'] = $amount;
            } else {
                $walletStats['by_type'][$type]['expense'] = $amount;
            }
        }
    } catch (PDOException $e) {
        $totalIncome = 0;
        $totalExpense = 0;
        $walletStats = [
            'income' => 0,
            'expense' => 0,
            'by_type' => []
        ];
    }
    
    // ========== 用户分析统计 ==========
    
    // 参考 c_users/list.php 和 b_users/list.php 的实现方式
    // 1. 总用户数
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_users");
    $totalUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 2. 新增用户（今日）
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_users WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayNewUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 3. 活跃用户（最近7天有任务记录的用户）
    $stmt = $db->prepare("SELECT COUNT(DISTINCT c_user_id) as total FROM c_task_records WHERE DATE(created_at) >= ?");
    $stmt->execute([$date7DaysAgo]);
    $activeUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 4. 派单用户（B端用户）
    try {
        $stmt = $db->query("SELECT COUNT(*) as total FROM b_users");
        $totalBUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 活跃派单用户（最近30天有发布任务的用户）
        $stmt = $db->prepare("SELECT COUNT(DISTINCT b_user_id) as total FROM b_tasks WHERE DATE(created_at) >= ?");
        $stmt->execute([$date30DaysAgo]);
        $activeBUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    } catch (PDOException $e) {
        $totalBUsers = 0;
        $activeBUsers = 0;
    }
    
    // 5. 接单用户（C端用户）
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_users");
    $totalCUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 活跃接单用户（最近30天有接取任务的用户）
    $stmt = $db->prepare("SELECT COUNT(DISTINCT c_user_id) as total FROM c_task_records WHERE DATE(created_at) >= ?");
    $stmt->execute([$date30DaysAgo]);
    $activeCUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 6. 派单用户（发布过任务的用户）

    try {
        // 尝试查询 b_tasks 表的结构，查看是否有 user_id 字段
        $stmt = $db->query("DESCRIBE b_tasks");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $columnNames = array_column($columns, 'Field');
        
        // 检查是否有 user_id 字段
        if (in_array('user_id', $columnNames)) {
            $stmt = $db->query("SELECT COUNT(DISTINCT user_id) as total FROM b_tasks");
            $totalSendUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        } elseif (in_array('b_user_id', $columnNames)) {
            // 检查是否有 b_user_id 字段
            $stmt = $db->query("SELECT COUNT(DISTINCT b_user_id) as total FROM b_tasks");
            $totalSendUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        } else {
            // 如果没有相关字段，设置为 0
            $totalSendUsers = 0;
        }
    } catch (PDOException $e) {
        $totalSendUsers = 0;
    }
    
    // 7.3 活跃用户数量 - 统计实际接取过任务的用户总数
    $stmt = $db->query("SELECT COUNT(DISTINCT c_user_id) as total FROM c_task_records");
    $activeUsersCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 7.4 今日新增用户数量 - 统计当天新注册的用户数量
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM c_users WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayNewUsersCount = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 7.5 今日充值总收入 - 统计当天所有充值金额总和(无论审核状态)
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM recharge_requests WHERE DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayTotalRecharge = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 7.6 今日提现总支出 - 统计当天已审核通过的提现金额总和
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM withdraw_requests WHERE status = 1 AND DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayTotalWithdraw = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 7.7 今日待提现金额 - 统计当天提交但未审核的提现金额总和
    $stmt = $db->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM withdraw_requests WHERE status = 0 AND DATE(created_at) = ?");
    $stmt->execute([$today]);
    $todayPendingWithdraw = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'] / 100;
    
    // 7.1 接单用户（C端所有用户）- 统计所有C端用户数量，而非仅接取过任务的用户
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_users");
    $totalReceiveUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];

    // 7.2 活跃用户（接取过任务的用户）
    $stmt = $db->query("SELECT COUNT(DISTINCT c_user_id) as total FROM c_task_records");
    $totalActiveUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 8. 用户状态统计
    try {
        // C端用户状态
        $stmt = $db->query("SELECT status, COUNT(*) as count FROM c_users GROUP BY status");
        $cUserStatusCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $cUserStatus = [
            'active' => 0,
            'inactive' => 0
        ];
        
        foreach ($cUserStatusCounts as $item) {
            if ((int)$item['status'] === 1) {
                $cUserStatus['active'] = (int)$item['count'];
            } else {
                $cUserStatus['inactive'] = (int)$item['count'];
            }
        }
        
        // B端用户状态
        $stmt = $db->query("SELECT status, COUNT(*) as count FROM b_users GROUP BY status");
        $bUserStatusCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $bUserStatus = [
            'active' => 0,
            'inactive' => 0
        ];
        
        foreach ($bUserStatusCounts as $item) {
            if ((int)$item['status'] === 1) {
                $bUserStatus['active'] = (int)$item['count'];
            } else {
                $bUserStatus['inactive'] = (int)$item['count'];
            }
        }
    } catch (PDOException $e) {
        $cUserStatus = [
            'active' => 0,
            'inactive' => 0
        ];
        $bUserStatus = [
            'active' => 0,
            'inactive' => 0
        ];
    }
    
    // ========== 任务支出细分 ==========
    
    // 1. 发布单任务支出（支持自定义时间范围）
    error_log('Executing single task expense query');
    try {
        // 从 b_tasks 表中查询单任务支出，使用 stage = 0 表示单任务，支持时间范围
        $stmt = $db->prepare("SELECT COALESCE(SUM(unit_price), 0) as total FROM b_tasks WHERE stage = 0 AND DATE(created_at) BETWEEN ? AND ?");
        $stmt->execute([$startDate, $endDate]);
        $singleTaskExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        error_log('Single task expense query completed: ' . $singleTaskExpense);
    } catch (PDOException $e) {
        error_log('Single task expense query failed: ' . $e->getMessage());
        $singleTaskExpense = 0;
    }
    
    // 2. 组合任务支出（支持自定义时间范围）
    error_log('Executing combo task expense query');
    try {
        // 从 b_tasks 表中查询组合任务支出，使用 combo_task_id IS NOT NULL 表示组合任务，支持时间范围
        $stmt = $db->prepare("SELECT COALESCE(SUM(unit_price), 0) as total FROM b_tasks WHERE combo_task_id IS NOT NULL AND DATE(created_at) BETWEEN ? AND ?");
        $stmt->execute([$startDate, $endDate]);
        $comboTaskExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        error_log('Combo task expense query completed: ' . $comboTaskExpense);
    } catch (PDOException $e) {
        error_log('Combo task expense query failed: ' . $e->getMessage());
        $comboTaskExpense = 0;
    }
    
    // 评论类型统计，根据template_id字段判断
    // 1：上评评论，2：中评评论，4：上中评评论，5：中下评评论
    $positiveCommentExpense = 0;      // 上评评论
    $neutralCommentExpense = 0;       // 中评评论  
    $positiveNeutralExpense = 0;      // 上中评评论
    $neutralNegativeExpense = 0;      // 中下评评论
    
    try {
        // 上评评论 (template_id = 1)
        $stmt = $db->prepare("
            SELECT COALESCE(SUM(b.unit_price), 0) as total 
            FROM b_tasks b
            INNER JOIN task_templates t ON b.template_id = t.id
            WHERE t.title = '上评评论' AND DATE(b.created_at) BETWEEN ? AND ?
        ");
        $stmt->execute([$startDate, $endDate]);
        $positiveCommentExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 中评评论 (template_id = 2)
        $stmt = $db->prepare("
            SELECT COALESCE(SUM(b.unit_price), 0) as total 
            FROM b_tasks b
            INNER JOIN task_templates t ON b.template_id = t.id
            WHERE t.title = '中评评论' AND DATE(b.created_at) BETWEEN ? AND ?
        ");
        $stmt->execute([$startDate, $endDate]);
        $neutralCommentExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 上中评评论 (template_id = 4)
        $stmt = $db->prepare("
            SELECT COALESCE(SUM(b.unit_price), 0) as total 
            FROM b_tasks b
            INNER JOIN task_templates t ON b.template_id = t.id
            WHERE t.title = '上中评评论' AND DATE(b.created_at) BETWEEN ? AND ?
        ");
        $stmt->execute([$startDate, $endDate]);
        $positiveNeutralExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 中下评评论 (template_id = 5)
        $stmt = $db->prepare("
            SELECT COALESCE(SUM(b.unit_price), 0) as total 
            FROM b_tasks b
            INNER JOIN task_templates t ON b.template_id = t.id
            WHERE t.title = '中下评评论' AND DATE(b.created_at) BETWEEN ? AND ?
        ");
        $stmt->execute([$startDate, $endDate]);
        $neutralNegativeExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        error_log("评论类型统计完成 - 上评:¥{$positiveCommentExpense}, 中评:¥{$neutralCommentExpense}, 上中评:¥{$positiveNeutralExpense}, 中下评:¥{$neutralNegativeExpense}");
        
    } catch (PDOException $e) {
        error_log('评论类型统计失败: ' . $e->getMessage());
        $positiveCommentExpense = 0;
        $neutralCommentExpense = 0;
        $positiveNeutralExpense = 0;
        $neutralNegativeExpense = 0;
    }
    
    // 7. 放大镜任务支出（支持自定义时间范围）
    error_log('Executing magnifier task expense query');
    try {
        $stmt = $db->prepare("SELECT COALESCE(SUM(unit_price), 0) as total FROM magnifying_glass_tasks WHERE DATE(created_at) BETWEEN ? AND ?");
        $stmt->execute([$startDate, $endDate]);
        $magnifierTaskExpense = (float)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        error_log('Magnifier task expense query completed: ' . $magnifierTaskExpense);
    } catch (PDOException $e) {
        error_log('Magnifier task expense query failed: ' . $e->getMessage());
        $magnifierTaskExpense = 0;
    }
    
    // ========== 工单管理统计 ==========
    
    // 参考 rental_tickets/list.php 的实现方式
    // 1. 支持工单统计
    error_log('Executing support tickets query');
    try {
        $stmt = $db->query("SELECT COUNT(*) as total FROM support_tickets");
        $totalSupportTickets = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 2. 关闭工单
        $stmt = $db->query("SELECT COUNT(*) as total FROM support_tickets WHERE status = 'closed'");
        $closedSupportTickets = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 3. 已完结工单
        $stmt = $db->query("SELECT COUNT(*) as total FROM support_tickets WHERE status = 'completed'");
        $completedSupportTickets = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 4. 进行中工单
        $stmt = $db->query("SELECT COUNT(*) as total FROM support_tickets WHERE status = 'in_progress'");
        $inProgressSupportTickets = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 5. 待处理工单
        $stmt = $db->query("SELECT COUNT(*) as total FROM support_tickets WHERE status = 'pending'");
        $pendingSupportTickets = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        error_log('Support tickets query completed');
    } catch (PDOException $e) {
        error_log('Support tickets query failed: ' . $e->getMessage());
        $totalSupportTickets = 0;
        $closedSupportTickets = 0;
        $completedSupportTickets = 0;
        $inProgressSupportTickets = 0;
        $pendingSupportTickets = 0;
    }
    
    // 6. 租赁工单统计
    error_log('Executing rental tickets query');
    try {
        $stmt = $db->query("SELECT COUNT(*) as total FROM rental_tickets");
        $totalRentalTickets = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // 按状态统计租赁工单
        $stmt = $db->query("SELECT status, COUNT(*) as count FROM rental_tickets GROUP BY status");
        $rentalTicketStatusCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $rentalTicketStatus = [
            'pending' => 0,    // 待处理
            'in_progress' => 0, // 处理中
            'closed' => 0      // 已关闭
        ];
        
        foreach ($rentalTicketStatusCounts as $item) {
            $status = (int)$item['status'];
            switch ($status) {
                case 0:
                    $rentalTicketStatus['pending'] = (int)$item['count'];
                    break;
                case 1:
                    $rentalTicketStatus['in_progress'] = (int)$item['count'];
                    break;
                case 2:
                    $rentalTicketStatus['closed'] = (int)$item['count'];
                    break;
            }
        }
        
        error_log('Rental tickets query completed');
    } catch (PDOException $e) {
        error_log('Rental tickets query failed: ' . $e->getMessage());
        $totalRentalTickets = 0;
        $rentalTicketStatus = [
            'pending' => 0,
            'in_progress' => 0,
            'closed' => 0
        ];
    }
    
    // 7. 总工单统计
    $totalTickets = $totalSupportTickets + $totalRentalTickets;
    $closedTickets = $closedSupportTickets + $rentalTicketStatus['closed'];
    $completedTickets = $completedSupportTickets;
    $inProgressTickets = $inProgressSupportTickets + $rentalTicketStatus['in_progress'];
    $pendingTickets = $pendingSupportTickets + $rentalTicketStatus['pending'];
    
    // ========== 趋势分析数据 ==========
    
    // 生成日期范围的辅助函数
    function generateDateRange($startDate, $endDate) {
        $dates = [];
        $currentDate = strtotime($startDate);
        $endDate = strtotime($endDate);
        
        while ($currentDate <= $endDate) {
            $dates[] = date('Y-m-d', $currentDate);
            $currentDate = strtotime('+1 day', $currentDate);
        }
        
        return $dates;
    }
    
    // 填充缺失日期数据的辅助函数
    function fillMissingDates($data, $dateRange, $valueKey) {
        $filledData = [];
        $dataMap = [];
        
        // 将现有数据转换为键值对
        foreach ($data as $item) {
            $dataMap[$item['date']] = $item[$valueKey];
        }
        
        // 填充所有日期
        foreach ($dateRange as $date) {
            $filledData[] = [
                'date' => $date,
                $valueKey => isset($dataMap[$date]) ? $dataMap[$date] : 0
            ];
        }
        
        return $filledData;
    }
    
    // 1. 每日任务完成数趋势
    $stmt = $db->prepare("SELECT DATE(reviewed_at) as date, COUNT(*) as count FROM c_task_records WHERE status = 3 AND DATE(reviewed_at) BETWEEN ? AND ? GROUP BY DATE(reviewed_at) ORDER BY date");
    $stmt->execute([$startDate, $endDate]);
    $dailyTasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 2. 每日流水趋势
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, COALESCE(SUM(b.unit_price), 0) as amount FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ? GROUP BY DATE(c.reviewed_at) ORDER BY date");
    $stmt->execute([$startDate, $endDate]);
    $dailyRevenue = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. 每日利润趋势
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, c.id, b.unit_price, cu.parent_id, pu.is_agent FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id INNER JOIN c_users cu ON c.c_user_id = cu.id LEFT JOIN c_users pu ON cu.parent_id = pu.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ?");
    $stmt->execute([$startDate, $endDate]);
    $tasksForProfitTrend = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 按日期计算利润
    $dailyProfit = [];
    foreach ($tasksForProfitTrend as $task) {
        $date = $task['date'];
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        
        if (!isset($dailyProfit[$date])) {
            $dailyProfit[$date] = 0;
        }
        $dailyProfit[$date] += $profit;
    }
    
    // 转换为数组格式
    $dailyProfitArray = [];
    foreach ($dailyProfit as $date => $amount) {
        $dailyProfitArray[] = ['date' => $date, 'amount' => $amount];
    }
    
    // 4. 充值提现趋势
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM recharge_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$startDate, $endDate]);
    $dailyRecharge = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元
    foreach ($dailyRecharge as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM withdraw_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$startDate, $endDate]);
    $dailyWithdraw = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元
    foreach ($dailyWithdraw as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    
    // 5. 7天数据
    $dateRange7Days = generateDateRange($date7DaysAgo, $today);
    
    $stmt = $db->prepare("SELECT DATE(reviewed_at) as date, COUNT(*) as count FROM c_task_records WHERE status = 3 AND DATE(reviewed_at) BETWEEN ? AND ? GROUP BY DATE(reviewed_at) ORDER BY date");
    $stmt->execute([$date7DaysAgo, $today]);
    $dailyTasks7Days = fillMissingDates($stmt->fetchAll(PDO::FETCH_ASSOC), $dateRange7Days, 'count');
    
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, COALESCE(SUM(b.unit_price), 0) as amount FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ? GROUP BY DATE(c.reviewed_at) ORDER BY date");
    $stmt->execute([$date7DaysAgo, $today]);
    $dailyRevenue7Days = fillMissingDates($stmt->fetchAll(PDO::FETCH_ASSOC), $dateRange7Days, 'amount');
    
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, c.id, b.unit_price, cu.parent_id, pu.is_agent FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id INNER JOIN c_users cu ON c.c_user_id = cu.id LEFT JOIN c_users pu ON cu.parent_id = pu.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ?");
    $stmt->execute([$date7DaysAgo, $today]);
    $tasksForProfitTrend7Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $dailyProfit7Days = [];
    foreach ($tasksForProfitTrend7Days as $task) {
        $date = $task['date'];
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        
        if (!isset($dailyProfit7Days[$date])) {
            $dailyProfit7Days[$date] = 0;
        }
        $dailyProfit7Days[$date] += $profit;
    }
    
    // 填充缺失日期的利润数据
    $dailyProfitArray7Days = [];
    foreach ($dateRange7Days as $date) {
        $dailyProfitArray7Days[] = [
            'date' => $date,
            'amount' => isset($dailyProfit7Days[$date]) ? $dailyProfit7Days[$date] : 0
        ];
    }
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM recharge_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$date7DaysAgo, $today]);
    $rechargeData7Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元并填充缺失日期
    foreach ($rechargeData7Days as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    $dailyRecharge7Days = fillMissingDates($rechargeData7Days, $dateRange7Days, 'amount');
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM withdraw_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$date7DaysAgo, $today]);
    $withdrawData7Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元并填充缺失日期
    foreach ($withdrawData7Days as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    $dailyWithdraw7Days = fillMissingDates($withdrawData7Days, $dateRange7Days, 'amount');
    
    // 6. 15天数据
    $dateRange15Days = generateDateRange($date15DaysAgo, $today);
    
    $stmt = $db->prepare("SELECT DATE(reviewed_at) as date, COUNT(*) as count FROM c_task_records WHERE status = 3 AND DATE(reviewed_at) BETWEEN ? AND ? GROUP BY DATE(reviewed_at) ORDER BY date");
    $stmt->execute([$date15DaysAgo, $today]);
    $dailyTasks15Days = fillMissingDates($stmt->fetchAll(PDO::FETCH_ASSOC), $dateRange15Days, 'count');
    
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, COALESCE(SUM(b.unit_price), 0) as amount FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ? GROUP BY DATE(c.reviewed_at) ORDER BY date");
    $stmt->execute([$date15DaysAgo, $today]);
    $dailyRevenue15Days = fillMissingDates($stmt->fetchAll(PDO::FETCH_ASSOC), $dateRange15Days, 'amount');
    
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, c.id, b.unit_price, cu.parent_id, pu.is_agent FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id INNER JOIN c_users cu ON c.c_user_id = cu.id LEFT JOIN c_users pu ON cu.parent_id = pu.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ?");
    $stmt->execute([$date15DaysAgo, $today]);
    $tasksForProfitTrend15Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $dailyProfit15Days = [];
    foreach ($tasksForProfitTrend15Days as $task) {
        $date = $task['date'];
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        
        if (!isset($dailyProfit15Days[$date])) {
            $dailyProfit15Days[$date] = 0;
        }
        $dailyProfit15Days[$date] += $profit;
    }
    
    // 填充缺失日期的利润数据
    $dailyProfitArray15Days = [];
    foreach ($dateRange15Days as $date) {
        $dailyProfitArray15Days[] = [
            'date' => $date,
            'amount' => isset($dailyProfit15Days[$date]) ? $dailyProfit15Days[$date] : 0
        ];
    }
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM recharge_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$date15DaysAgo, $today]);
    $rechargeData15Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元并填充缺失日期
    foreach ($rechargeData15Days as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    $dailyRecharge15Days = fillMissingDates($rechargeData15Days, $dateRange15Days, 'amount');
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM withdraw_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$date15DaysAgo, $today]);
    $withdrawData15Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元并填充缺失日期
    foreach ($withdrawData15Days as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    $dailyWithdraw15Days = fillMissingDates($withdrawData15Days, $dateRange15Days, 'amount');
    
    // 7. 30天数据
    $dateRange30Days = generateDateRange($date30DaysAgo, $today);
    
    $stmt = $db->prepare("SELECT DATE(reviewed_at) as date, COUNT(*) as count FROM c_task_records WHERE status = 3 AND DATE(reviewed_at) BETWEEN ? AND ? GROUP BY DATE(reviewed_at) ORDER BY date");
    $stmt->execute([$date30DaysAgo, $today]);
    $dailyTasks30Days = fillMissingDates($stmt->fetchAll(PDO::FETCH_ASSOC), $dateRange30Days, 'count');
    
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, COALESCE(SUM(b.unit_price), 0) as amount FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ? GROUP BY DATE(c.reviewed_at) ORDER BY date");
    $stmt->execute([$date30DaysAgo, $today]);
    $dailyRevenue30Days = fillMissingDates($stmt->fetchAll(PDO::FETCH_ASSOC), $dateRange30Days, 'amount');
    
    $stmt = $db->prepare("SELECT DATE(c.reviewed_at) as date, c.id, b.unit_price, cu.parent_id, pu.is_agent FROM c_task_records c INNER JOIN b_tasks b ON c.b_task_id = b.id INNER JOIN c_users cu ON c.c_user_id = cu.id LEFT JOIN c_users pu ON cu.parent_id = pu.id WHERE c.status = 3 AND DATE(c.reviewed_at) BETWEEN ? AND ?");
    $stmt->execute([$date30DaysAgo, $today]);
    $tasksForProfitTrend30Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $dailyProfit30Days = [];
    foreach ($tasksForProfitTrend30Days as $task) {
        $date = $task['date'];
        $price = (float)$task['unit_price'];
        $cUserCommission = $price * ($commissionCUser / 100);
        $agentCommission = 0;
        
        if ($task['parent_id'] && (int)$task['is_agent'] === 1) {
            $agentCommission = $price * ($commissionAgent / 100);
        }
        
        $profit = $price - $cUserCommission - $agentCommission;
        
        if (!isset($dailyProfit30Days[$date])) {
            $dailyProfit30Days[$date] = 0;
        }
        $dailyProfit30Days[$date] += $profit;
    }
    
    // 填充缺失日期的利润数据
    $dailyProfitArray30Days = [];
    foreach ($dateRange30Days as $date) {
        $dailyProfitArray30Days[] = [
            'date' => $date,
            'amount' => isset($dailyProfit30Days[$date]) ? $dailyProfit30Days[$date] : 0
        ];
    }
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM recharge_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$date30DaysAgo, $today]);
    $rechargeData30Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元并填充缺失日期
    foreach ($rechargeData30Days as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    $dailyRecharge30Days = fillMissingDates($rechargeData30Days, $dateRange30Days, 'amount');
    
    $stmt = $db->prepare("SELECT DATE(created_at) as date, SUM(amount) as amount FROM withdraw_requests WHERE status = 1 AND DATE(created_at) BETWEEN ? AND ? GROUP BY DATE(created_at) ORDER BY date");
    $stmt->execute([$date30DaysAgo, $today]);
    $withdrawData30Days = $stmt->fetchAll(PDO::FETCH_ASSOC);
    // 转换为元并填充缺失日期
    foreach ($withdrawData30Days as &$item) {
        $item['amount'] = (float)$item['amount'] / 100;
    }
    $dailyWithdraw30Days = fillMissingDates($withdrawData30Days, $dateRange30Days, 'amount');
    
    // ========== 返回统计数据 ==========
    
    // 计算待领取任务总数 - 统计所有待领取状态的任务总数量
    $stmt = $db->query("SELECT COUNT(*) as total FROM b_tasks WHERE status = 1 AND task_done < task_count");
    $totalPendingTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 计算单任务数量
    $stmt = $db->query("SELECT COUNT(*) as total FROM b_tasks WHERE stage = 0");
    $singleTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 计算组合任务数量
    $stmt = $db->query("SELECT COUNT(DISTINCT combo_task_id) as total FROM b_tasks WHERE combo_task_id IS NOT NULL");
    $comboTasks = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 计算高级团长用户总数
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_users WHERE is_agent = 2");
    $seniorAgents = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 计算普通团长用户总数
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_users WHERE is_agent = 1");
    $normalAgents = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 计算普通用户总数
    $stmt = $db->query("SELECT COUNT(*) as total FROM c_users WHERE is_agent = 0");
    $normalUsers = (int)$stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 计算用户占比
    $totalUserCount = $seniorAgents + $normalAgents + $normalUsers;
    $seniorAgentRatio = $totalUserCount > 0 ? ($seniorAgents / $totalUserCount) * 100 : 0;
    $normalAgentRatio = $totalUserCount > 0 ? ($normalAgents / $totalUserCount) * 100 : 0;
    $normalUserRatio = $totalUserCount > 0 ? ($normalUsers / $totalUserCount) * 100 : 0;
    
    // 利润和利润率已经在前面计算完成，这里仅输出调试信息
    

    
    // 构建响应数据
    $responseData = [
        // 时间范围
        'time_range' => [
            'start_date' => $startDate,
            'end_date' => $endDate,
            'range_type' => $timeRange
        ],
        // 今日运营数据
        'today_operation' => [
            'today_new_users' => $todayNewUsersCount,
            'today_recharge' => number_format($todayTotalRecharge, 2),
            'today_withdraw' => number_format($todayTotalWithdraw, 2),
            'today_pending_withdraw' => number_format($todayPendingWithdraw, 2),
            'active_users' => $activeUsersCount
        ],
        // 任务核心
        'task_core' => [
            'total_send_tasks' => $totalSendTasks,
            'total_expired_tasks' => $totalExpiredTasks,
            'total_receive_tasks' => $totalReceiveTasks,
            'total_pending_tasks' => $totalPendingTasks,
            'total_completed_tasks' => $totalTasks,
            'today_doing_tasks' => $todayDoing,
            'today_reviewing_tasks' => $todayReviewing,
            'single_tasks' => $singleTasks,
            'combo_tasks' => $comboTasks,
            'magnifier_tasks' => $totalMagnifierTasks,
            'task_templates' => [
                'total' => $totalTaskTemplates,
                'single' => $taskTemplateTypes['single'],
                'combo' => $taskTemplateTypes['combo']
            ],
            'rental_tasks' => [
                'total' => $totalRentalTasks,
                'today' => $todayRentalTasks,
                'active' => $activeRentalTasks
            ]
        ],
        // 财务收支
        'finance' => [
            'total_recharge' => number_format($totalRecharge, 2),
            'total_withdraw' => number_format($totalWithdraw, 2),
            // 高级团长佣金支出
            'second_agent_commission' => number_format($seniorAgentCommission, 2),
            // 普通团长佣金支出
            'normal_agent_commission' => number_format($normalAgentCommission, 2),
            'task_reward_expense' => number_format($taskRewardExpense, 2),
            'account_purchase_expense' => number_format($accountPurchaseExpense, 2),
            'account_rental_reward' => number_format($accountRentalReward, 2),
            'total_profit' => number_format($totalProfit, 2),
            'profit_margin' => number_format($profitMargin, 2),
            'conversion_rate' => number_format($conversionRate, 2),
            'wallet_stats' => $walletStats,
            // 财务收支图表专用数据
            'chart_data' => [
                'revenue' => [
                    'total_recharge' => number_format($totalRecharge, 2),
                    'total_withdraw' => number_format($totalWithdraw, 2)
                ],
                'expenses' => [
                    'agent_commission_total' => number_format($totalNormalAgentCommission + $totalSeniorAgentCommission, 2),
                    'task_reward' => number_format($taskRewardExpense, 2),
                    'account_rental' => number_format($accountRentalReward, 2),
                    'account_purchase' => number_format($accountPurchaseExpense, 2),
                    'other_expenses' => number_format(0, 2) // 其他支出
                ],
                'profit' => number_format($totalProfit, 2),
                'profit_margin' => number_format($profitMargin, 2)
            ]
        ],
        // 用户分析
        'user_analysis' => [
            'total_send_users' => $totalSendUsers,
            'total_receive_users' => $totalReceiveUsers,
            'senior_agents' => $seniorAgents,
            'normal_agents' => $normalAgents,
            'normal_users' => $normalUsers,
            'senior_agent_ratio' => number_format($seniorAgentRatio, 2),
            'normal_agent_ratio' => number_format($normalAgentRatio, 2),
            'normal_user_ratio' => number_format($normalUserRatio, 2),
            'active_users' => $activeUsersCount,
            'today_new_users' => $todayNewUsersCount,
            'b_users' => [
                'total' => $totalBUsers,
                'active' => $activeBUsers
            ],
            'c_users' => [
                'total' => $totalCUsers,
                'active' => $activeCUsers
            ],
            'status' => [
                'b_users' => $bUserStatus,
                'c_users' => $cUserStatus
            ]
        ],
        // 工单处理
        'ticket_handling' => [
            'total_tickets' => $totalTickets,
            'closed_tickets' => $closedTickets,
            'completed_tickets' => $completedTickets,
            'in_progress_tickets' => $inProgressTickets,
            'pending_tickets' => $pendingTickets,
            'support_tickets' => [
                'total' => $totalSupportTickets,
                'closed' => $closedSupportTickets,
                'completed' => $completedSupportTickets,
                'in_progress' => $inProgressSupportTickets,
                'pending' => $pendingSupportTickets
            ],
            'rental_tickets' => [
                'total' => $totalRentalTickets,
                'status' => $rentalTicketStatus
            ]
        ],
        // 任务支出细分
        'task_expense' => [
            'single_task_expense' => number_format($singleTaskExpense, 2),
            'combo_task_expense' => number_format($comboTaskExpense, 2),
            'positive_comment_expense' => number_format($positiveCommentExpense, 2),
            'neutral_comment_expense' => number_format($neutralCommentExpense, 2),
            'positive_neutral_expense' => number_format($positiveNeutralExpense, 2),
            'neutral_negative_expense' => number_format($neutralNegativeExpense, 2),
            'magnifier_task_expense' => number_format($magnifierTaskExpense, 2)
        ],
        // 放大镜任务统计
        'magnifier_tasks' => [
            'total' => $totalMagnifierTasks,
            'today_total' => $todayMagnifierTasks,
            'by_status' => $magnifierTasksByStatus
        ],
        // 多维度分类统计
        'category_stats' => [
            'rental' => [
                'total' => $rentalTotal,
                'today' => $rentalToday
            ],
            'single_task' => [
                'total' => $singleTaskTotal,
                'today' => $singleTaskToday
            ],
            'combo_task' => [
                'total' => $comboTaskTotal,
                'today' => $comboTaskToday
            ],
            'magnifier' => [
                'total' => $totalMagnifierTasks,
                'today' => $todayMagnifierTasks
            ],
            'comments' => $commentStats
        ],
        // 流水统计
        'revenue' => [
            'total' => number_format($totalRevenue, 2),
            'today' => number_format($todayRevenue, 2),
            '7_days' => number_format($revenue7Days, 2),
            '15_days' => number_format($revenue15Days, 2),
            '30_days' => number_format($revenue30Days, 2),
            'custom_range' => number_format($revenueCustomRange, 2)
        ],
        // 利润统计
        'profit' => [
            'total' => number_format($totalProfit, 2),
            'today' => number_format($todayProfit, 2),
            '7_days' => number_format($profit7Days, 2),
            '15_days' => number_format($profit15Days, 2),
            '30_days' => number_format($profit30Days, 2),
            'custom_range' => number_format($profitCustomRange, 2)
        ],
        // 团长佣金统计
        'agent_commission' => [
            'total' => number_format($totalAgentCommission / 100, 2),
            'normal' => number_format($totalNormalAgentCommission / 100, 2), // 普通团长佣金
            'senior' => number_format($totalSeniorAgentCommission / 100, 2), // 高级团长佣金
            'second' => number_format($totalSeniorAgentCommission / 100, 2), // 二级团长佣金与高级团长佣金相同
            '7_days' => [
                'total' => number_format($agentCommission7Days / 100, 2),
                'normal' => number_format($normalAgentCommission7Days / 100, 2),
                'senior' => number_format($seniorAgentCommission7Days / 100, 2)
            ],
            '15_days' => [
                'total' => number_format($agentCommission15Days / 100, 2),
                'normal' => number_format($normalAgentCommission15Days / 100, 2),
                'senior' => number_format($seniorAgentCommission15Days / 100, 2)
            ],
            '30_days' => [
                'total' => number_format($agentCommission30Days / 100, 2),
                'normal' => number_format($normalAgentCommission30Days / 100, 2),
                'senior' => number_format($seniorAgentCommission30Days / 100, 2)
            ],
            'custom_range' => [
                'total' => number_format($agentCommissionCustomRange / 100, 2),
                'normal' => number_format($normalAgentCommissionCustomRange / 100, 2),
                'senior' => number_format($seniorAgentCommissionCustomRange / 100, 2)
            ]
        ],
        // 充值提现统计
        'recharge_withdraw' => [
            'total_recharge' => number_format($totalRecharge, 2),
            'total_withdraw' => number_format($totalWithdraw, 2),
            'today_recharge' => number_format($todayRecharge, 2),
            'today_withdraw' => number_format($todayWithdraw, 2),
            'today_total_recharge' => number_format($todayTotalRecharge, 2),
            'today_total_withdraw' => number_format($todayTotalWithdraw, 2),
            'today_pending_withdraw' => number_format($todayPendingWithdraw, 2),
            '7_days_recharge' => number_format($recharge7Days, 2),
            '7_days_withdraw' => number_format($withdraw7Days, 2),
            '15_days_recharge' => number_format($recharge15Days, 2),
            '15_days_withdraw' => number_format($withdraw15Days, 2),
            '30_days_recharge' => number_format($recharge30Days, 2),
            '30_days_withdraw' => number_format($withdraw30Days, 2)
        ],
        // 趋势分析
        'trends' => [
            'daily_tasks' => $dailyTasks,
            'daily_revenue' => $dailyRevenue,
            'daily_profit' => $dailyProfitArray,
            'daily_recharge' => $dailyRecharge,
            'daily_withdraw' => $dailyWithdraw,
            // 7天、15天、30天每一天的数据
            '7_days_daily' => [
                'tasks' => $dailyTasks7Days,
                'revenue' => $dailyRevenue7Days,
                'profit' => $dailyProfitArray7Days,
                'recharge' => $dailyRecharge7Days,
                'withdraw' => $dailyWithdraw7Days
            ],
            '15_days_daily' => [
                'tasks' => $dailyTasks15Days,
                'revenue' => $dailyRevenue15Days,
                'profit' => $dailyProfitArray15Days,
                'recharge' => $dailyRecharge15Days,
                'withdraw' => $dailyWithdraw15Days
            ],
            '30_days_daily' => [
                'tasks' => $dailyTasks30Days,
                'revenue' => $dailyRevenue30Days,
                'profit' => $dailyProfitArray30Days,
                'recharge' => $dailyRecharge30Days,
                'withdraw' => $dailyWithdraw30Days
            ]
        ]
    ];
    
    // 返回成功响应
    Response::success($responseData, '获取统计数据成功');
    
} catch (PDOException $e) {
    error_log('Admin统计面板数据库错误: ' . $e->getMessage());
    Response::error('数据库查询失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
} catch (Exception $e) {
    error_log('Admin统计面板系统错误: ' . $e->getMessage());
    Response::error('系统错误: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'] ?? 5000);
}
