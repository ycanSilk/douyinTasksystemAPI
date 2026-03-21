<?php
/**
 * 任务模板创建
 * POST /task_admin/api/tasks/create.php
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../../core/Database.php';

AdminAuthMiddleware::authenticate();
$db = Database::connect();

$input = json_decode(file_get_contents('php://input'), true);

$type = (int)($input['type'] ?? 0);
$title = trim($input['title'] ?? '');
$price = (float)($input['price'] ?? 0);
$description1 = trim($input['description1'] ?? '');
$description2 = trim($input['description2'] ?? '');
$status = (int)($input['status'] ?? 1);

if (empty($title)) {
    echo json_encode(['code' => 1002, 'message' => '标题不能为空', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($price <= 0) {
    echo json_encode(['code' => 1003, 'message' => '单价必须大于0', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 佣金字段（通用）
    $cUserCommission = (int)($input['c_user_commission'] ?? 0);
    $agentCommission = (int)($input['agent_commission'] ?? 0);
    $seniorAgentCommission = (int)($input['senior_agent_commission'] ?? 0);

    if ($type === 0) {
        // 单任务
        $stmt = $db->prepare("
            INSERT INTO task_templates (type, title, price, description1, description2,
                c_user_commission, agent_commission, senior_agent_commission, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([0, $title, $price, $description1, $description2,
            $cUserCommission, $agentCommission, $seniorAgentCommission, $status]);
    } else {
        // 组合任务
        $stage1Title = trim($input['stage1_title'] ?? '');
        $stage1Price = (float)($input['stage1_price'] ?? 0);
        $stage2Title = trim($input['stage2_title'] ?? '');
        $stage2Price = (float)($input['stage2_price'] ?? 0);
        $defaultStage1Count = (int)($input['default_stage1_count'] ?? 1);
        $defaultStage2Count = (int)($input['default_stage2_count'] ?? 3);

        // 组合任务阶段佣金
        $stage1CUserCommission = isset($input['stage1_c_user_commission']) ? (int)$input['stage1_c_user_commission'] : null;
        $stage1AgentCommission = isset($input['stage1_agent_commission']) ? (int)$input['stage1_agent_commission'] : null;
        $stage1SeniorAgentCommission = isset($input['stage1_senior_agent_commission']) ? (int)$input['stage1_senior_agent_commission'] : null;
        $stage2CUserCommission = isset($input['stage2_c_user_commission']) ? (int)$input['stage2_c_user_commission'] : null;
        $stage2AgentCommission = isset($input['stage2_agent_commission']) ? (int)$input['stage2_agent_commission'] : null;
        $stage2SeniorAgentCommission = isset($input['stage2_senior_agent_commission']) ? (int)$input['stage2_senior_agent_commission'] : null;

        $stmt = $db->prepare("
            INSERT INTO task_templates (
                type, title, price, description1, description2,
                stage1_title, stage1_price, stage2_title, stage2_price,
                default_stage1_count, default_stage2_count,
                c_user_commission, agent_commission, senior_agent_commission,
                stage1_c_user_commission, stage1_agent_commission, stage1_senior_agent_commission,
                stage2_c_user_commission, stage2_agent_commission, stage2_senior_agent_commission,
                status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            1, $title, $price, $description1, $description2,
            $stage1Title, $stage1Price, $stage2Title, $stage2Price,
            $defaultStage1Count, $defaultStage2Count,
            $cUserCommission, $agentCommission, $seniorAgentCommission,
            $stage1CUserCommission, $stage1AgentCommission, $stage1SeniorAgentCommission,
            $stage2CUserCommission, $stage2AgentCommission, $stage2SeniorAgentCommission,
            $status
        ]);
    }
    
    $newId = $db->lastInsertId();
    
    echo json_encode([
        'code' => 0,
        'message' => '创建成功',
        'data' => ['id' => (int)$newId],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['code' => 5000, 'message' => '创建失败：' . $e->getMessage(), 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);
}
