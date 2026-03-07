<?php
/**
 * B端获取任务模板列表接口
 * 
 * GET /api/b/v1/task-templates
 * 
 * 请求头：
 * X-Token: <token> (B端/C端/Admin端均可访问)
 */

header('Content-Type: application/json; charset=utf-8');

// 只允许 GET 请求
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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

// Token 认证（B端/C端/Admin端均可访问）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateAny();

try {
    // 查询所有启用的任务模板
    $stmt = $db->prepare("
        SELECT 
            id,
            type,
            title,
            price,
            description1,
            description2,
            stage1_title,
            stage1_price,
            stage2_title,
            stage2_price,
            default_stage1_count,
            default_stage2_count,
            created_at
        FROM task_templates
        WHERE status = 1
        ORDER BY id ASC
    ");
    $stmt->execute();
    $templates = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 格式化返回数据
    $result = [];
    foreach ($templates as $template) {
        $isCombo = (int)$template['type'] === 1;
        
        $item = [
            'id' => (int)$template['id'],
            'type' => (int)$template['type'],
            'type_text' => $isCombo ? '组合任务' : '单任务',
            'title' => $template['title'],
            'price' => (float)$template['price'],
            'description1' => $template['description1'],
            'description2' => $template['description2'],
            'created_at' => $template['created_at']
        ];
        
        // 组合任务额外字段
        if ($isCombo) {
            $item['stage1'] = [
                'title' => $template['stage1_title'],
                'price' => (float)$template['stage1_price'],
                'default_count' => (int)$template['default_stage1_count']
            ];
            $item['stage2'] = [
                'title' => $template['stage2_title'],
                'price' => (float)$template['stage2_price'],
                'default_count' => (int)$template['default_stage2_count']
            ];
            $item['default_total_price'] = (float)$template['stage1_price'] * (int)$template['default_stage1_count'] 
                                         + (float)$template['stage2_price'] * (int)$template['default_stage2_count'];
        } else if ((int)$template['id'] === 1 || (int)$template['id'] === 2) {
            // 为模板ID为1和2的单任务添加stage1字段
            $item['stage1'] = [
                'title' => $template['title'],
                'price' => (float)$template['price'],
                'default_count' => (int)$template['default_stage1_count'] > 0 ? (int)$template['default_stage1_count'] : 1
            ];
        }
        
        $result[] = $item;
    }
    
    Response::success($result);
    
} catch (PDOException $e) {
    Response::error('查询失败', $errorCodes['DATABASE_ERROR'], 500);
}

