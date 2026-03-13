<?php
/**
 * B端周期统计接口
 * 
 * GET /task_admin/api/b/v1/statistics/summary.php
 * 
 * 请求参数：
 * - b_user_id: B端用户ID（必填）
 * - period: 统计周期：today, 7days, 15days, 30days, 12months
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

// 获取URL参数中的b_user_id
$urlBUserId = isset($_GET['b_user_id']) ? $_GET['b_user_id'] : '';

// 测试模式下，如果URL中有b_user_id，则使用它；否则使用默认值1
$bUserId = $urlBUserId ? $urlBUserId : 0;

// 获取请求参数
$period = isset($_GET['period']) ? $_GET['period'] : '';

// 验证参数
if (empty($period)) {
    Response::error('统计周期不能为空', $errorCodes['INVALID_PARAMS']);
}

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
    if (!empty($bUserId)) {
        if (is_numeric($bUserId)) {
            // 如果是数字，按用户ID搜索
            $whereClause = "WHERE b_user_id = ? AND DATE(created_at) BETWEEN ? AND ?";
            $params = [(int)$bUserId, $startDate, $endDate];
        } else {
            // 如果是字符串，按用户名搜索
            $whereClause = "WHERE username LIKE ? AND DATE(created_at) BETWEEN ? AND ?";
            $params = ['%' . $bUserId . '%', $startDate, $endDate];
        }
    } else {
        // 没有指定b_user_id，统计整个表的数据
        $whereClause = "WHERE DATE(created_at) BETWEEN ? AND ?";
        $params = [$startDate, $endDate];
    }
    
    // 查询每日数据
    $stmt = $db->prepare("
        SELECT 
            DATE(created_at) as date,
            SUM(CASE WHEN flow_type = 1 THEN amount ELSE 0 END) as income,
            SUM(CASE WHEN flow_type = 2 THEN amount ELSE 0 END) as expenditure
        FROM b_task_statistics 
        $whereClause
        GROUP BY DATE(created_at)
        ORDER BY date
    ");
    $stmt->execute($params);
    $dailyData = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 计算汇总数据
    $stmt = $db->prepare("
        SELECT 
            SUM(CASE WHEN flow_type = 1 THEN amount ELSE 0 END) as total_income,
            SUM(CASE WHEN flow_type = 2 THEN amount ELSE 0 END) as total_expenditure
        FROM b_task_statistics 
        $whereClause
    ");
    $stmt->execute($params);
    $summary = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 格式化每日数据
    $formattedDailyData = [];
    foreach ($dailyData as $item) {
        $netChange = $item['income'] - $item['expenditure'];
        $formattedDailyData[] = [
            'date' => $item['date'],
            'income' => $item['income'],
            'income_yuan' => number_format($item['income'] / 100, 2),
            'expenditure' => $item['expenditure'],
            'expenditure_yuan' => number_format($item['expenditure'] / 100, 2),
            'net_change' => $netChange,
            'net_change_yuan' => number_format($netChange / 100, 2)
        ];
    }
    
    // 计算净变动
    $totalIncome = $summary['total_income'] ?? 0;
    $totalExpenditure = $summary['total_expenditure'] ?? 0;
    $netChange = $totalIncome - $totalExpenditure;
    
    // 构建汇总数据
    $formattedSummary = [
        'total_income' => $totalIncome,
        'total_income_yuan' => number_format($totalIncome / 100, 2),
        'total_expenditure' => $totalExpenditure,
        'total_expenditure_yuan' => number_format($totalExpenditure / 100, 2),
        'net_change' => $netChange,
        'net_change_yuan' => number_format($netChange / 100, 2)
    ];
    
    // 返回结果
    Response::success([
        'period' => $period,
        'summary' => $formattedSummary,
        'daily_data' => $formattedDailyData
    ], '获取周期统计成功');
    
} catch (PDOException $e) {
    Response::error('获取周期统计失败: ' . $e->getMessage(), $errorCodes['DATABASE_ERROR'], 500);
} catch (Exception $e) {
    Response::error('获取周期统计失败: ' . $e->getMessage(), $errorCodes['SYSTEM_ERROR'], 500);
}
?>