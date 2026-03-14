<?php
/**
 * C端周期统计接口
 * 
 * GET /task_admin/api/c_users_static/summary.php
 * 
 * 请求参数：
 * - c_user_id: C端用户ID或用户名（可选）
 * - period: 统计周期：today, 7days, 15days, 30days, 12months（默认：7days）
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

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';
require_once __DIR__ . '/../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../config/error_codes.php';

// 验证管理员身份
AdminAuthMiddleware::authenticate();
$db = Database::connect();

// 测试模式：如果传入test参数，则使用默认用户ID
$testMode = isset($_GET['test']) && $_GET['test'] === '1';

// 获取URL参数中的c_user_id
$urlCUserId = isset($_GET['c_user_id']) ? $_GET['c_user_id'] : '';

// 测试模式下，如果URL中有c_user_id，则使用它；否则使用默认值1
$cUserId = $urlCUserId ? $urlCUserId : 0;

// 获取请求参数，默认7天
$period = isset($_GET['period']) ? $_GET['period'] : '7days';
// 获取分页参数
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 100;

// 验证周期参数
$validPeriods = ['today', '7days', '15days', '30days', '12months'];
if (!in_array($period, $validPeriods)) {
    Response::error('无效的统计周期', $errorCodes['INVALID_PARAMS']);
}

// 根据周期计算日期范围
switch ($period) {
    case 'today':
        $startDate = date('Y-m-d');
        $endDate = date('Y-m-d');
        break;
    case '7days':
        $startDate = date('Y-m-d', strtotime('-6 days'));
        $endDate = date('Y-m-d');
        break;
    case '15days':
        $startDate = date('Y-m-d', strtotime('-14 days'));
        $endDate = date('Y-m-d');
        break;
    case '30days':
        $startDate = date('Y-m-d', strtotime('-29 days'));
        $endDate = date('Y-m-d');
        break;
    case '12months':
        $startDate = date('Y-m-d', strtotime('-11 months'));
        $endDate = date('Y-m-d');
        break;
}

try {
    // 构建查询条件
    if (!empty($cUserId)) {
        if (is_numeric($cUserId)) {
            // 如果是数字，按用户ID搜索
            $whereClause = "WHERE c_user_id = ? AND DATE(created_at) BETWEEN ? AND ?";
            $params = [(int)$cUserId, $startDate, $endDate];
        } else {
            // 如果是字符串，按用户名搜索
            $whereClause = "WHERE username LIKE ? AND DATE(created_at) BETWEEN ? AND ?";
            $params = ['%' . $cUserId . '%', $startDate, $endDate];
        }
    } else {
        // 没有指定c_user_id，统计整个表的数据
        $whereClause = "WHERE DATE(created_at) BETWEEN ? AND ?";
        $params = [$startDate, $endDate];
    }
    
    // 计算偏移量
    $offset = ($page - 1) * $limit;
    
    // 查询每日数据总数
    $countStmt = $db->prepare(" 
        SELECT COUNT(DISTINCT DATE(created_at)) as total
        FROM c_task_statistics 
        $whereClause
    ");
    $countStmt->execute($params);
    $total = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // 查询每日数据（带分页）
    $stmt = $db->prepare(" 
        SELECT 
            DATE(created_at) as date,
            SUM(CASE WHEN flow_type = 1 THEN amount ELSE 0 END) as income,
            SUM(CASE WHEN flow_type = 2 THEN amount ELSE 0 END) as expenditure
        FROM c_task_statistics 
        $whereClause
        GROUP BY DATE(created_at)
        ORDER BY date
        LIMIT ? OFFSET ?
    ");
    // 添加分页参数
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $dailyData = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 计算汇总数据（使用不包含分页参数的原始参数）
    $summaryParams = array_slice($params, 0, -2); // 移除分页参数
    $stmt = $db->prepare(" 
        SELECT 
            SUM(CASE WHEN flow_type = 1 THEN amount ELSE 0 END) as total_income,
            SUM(CASE WHEN flow_type = 2 THEN amount ELSE 0 END) as total_expenditure
        FROM c_task_statistics 
        $whereClause
    ");
    $stmt->execute($summaryParams);
    $summary = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 格式化每日数据
    $formattedDailyData = [];
    foreach ($dailyData as $item) {
        $income = ($item['income'] ?? 0) / 100;
        $expenditure = ($item['expenditure'] ?? 0) / 100;
        $netChange = $income - $expenditure;
        $formattedDailyData[] = [
            'date' => $item['date'],
            'income' => $income,
            'expenditure' => $expenditure,
            'net_change' => $netChange
        ];
    }
    
    // 计算净变动
    $totalIncome = ($summary['total_income'] ?? 0) / 100;
    $totalExpenditure = ($summary['total_expenditure'] ?? 0) / 100;
    $netChange = $totalIncome - $totalExpenditure;
    
    // 构建汇总数据
    $formattedSummary = [
        'total_income' => $totalIncome,
        'total_expenditure' => $totalExpenditure,
        'net_change' => $netChange
    ];
    
    // 计算总页数
    $totalPages = ceil($total / $limit);
    
    // 返回结果
    Response::success([
        'period' => $period,
        'summary' => $formattedSummary,
        'daily_data' => $formattedDailyData,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => $totalPages
        ]
    ], '获取周期统计成功');
    
} catch (PDOException $e) {
    Response::error('获取周期统计失败: ' . $e->getMessage(), $errorCodes['DATABASE_ERROR'], 500);
} catch (Exception $e) {
    Response::error('获取周期统计失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'], 500);
}
?>