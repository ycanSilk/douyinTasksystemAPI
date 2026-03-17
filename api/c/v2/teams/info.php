<?php
/**
 * 团队信息管理接口
 * 
 * GET /api/c/v2/teams/info - 获取团队信息
 * PUT /api/c/v2/teams/info - 修改团队信息
 * DELETE /api/c/v2/teams/info - 解散团队
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * GET 请求参数：
 * - team_id: 团队ID（必填）
 * 
 * PUT 请求体：
 * {
 *   "team_id": "uuid",
 *   "team_name": "新团队名称"
 * }
 * 
 * DELETE 请求体：
 * {
 *   "team_id": "uuid"
 * }
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "成功",
 *   "data": {
 *     "team_id": "uuid",
 *     "team_name": "团队名称",
 *     "creator_id": 1,
 *     "creator_name": "创建者名称",
 *     "member_count": 10,
 *     "status": 1,
 *     "created_at": "2026-03-16 12:00:00",
 *     "updated_at": "2026-03-16 12:00:00"
 *   },
 *   "timestamp": 1620000000
 * }
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../../../core/Database.php';
require_once __DIR__ . '/../../../../core/AuthMiddleware.php';
require_once __DIR__ . '/../../../../core/Response.php';

$errorCodes = require __DIR__ . '/../../../../config/error_codes.php';

// 数据库连接
$db = Database::connect();

// Token 认证（必须是 C端用户）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateC();

// 根据请求方法处理不同逻辑
switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        // 获取团队信息
        getTeamInfo($db, $currentUser, $errorCodes);
        break;
    case 'PUT':
        // 修改团队信息
        updateTeamInfo($db, $currentUser, $errorCodes);
        break;
    case 'DELETE':
        // 解散团队
        dissolveTeam($db, $currentUser, $errorCodes);
        break;
    default:
        http_response_code(405);
        echo json_encode([
            'code' => 1001,
            'message' => '请求方法错误',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
}

// 获取团队信息
function getTeamInfo($db, $currentUser, $errorCodes) {
    $teamId = $_GET['team_id'] ?? '';
    
    if (empty($teamId)) {
        Response::error('团队ID不能为空', $errorCodes['INVALID_PARAMS']);
    }
    
    // 检查用户是否是团队成员
    $stmt = $db->prepare("SELECT role FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$currentUser['user_id'], $teamId]);
    $userRole = $stmt->fetchColumn();
    
    if (!$userRole) {
        Response::error('您不是该团队的成员', $errorCodes['PERMISSION_DENIED']);
    }
    
    // 查询团队信息
    $stmt = $db->prepare("SELECT
        t.id as team_id,
        t.team_name,
        t.creator_id,
        c.username as creator_name,
        (SELECT COUNT(*) FROM user_team_relations WHERE team_id = t.id AND status = 1) as member_count,
        t.status,
        t.created_at,
        t.updated_at
    FROM teams t
    JOIN c_users c ON t.creator_id = c.id
    WHERE t.id = ?");
    
    $stmt->execute([$teamId]);
    $teamInfo = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$teamInfo) {
        Response::error('团队不存在', $errorCodes['TEAM_NOT_FOUND']);
    }
    
    Response::success($teamInfo, '团队信息查询成功');
}

// 修改团队信息
function updateTeamInfo($db, $currentUser, $errorCodes) {
    $input = json_decode(file_get_contents('php://input'), true);
    $teamId = $input['team_id'] ?? '';
    $teamName = trim($input['team_name'] ?? '');
    
    if (empty($teamId) || empty($teamName)) {
        Response::error('团队ID和团队名称不能为空', $errorCodes['INVALID_PARAMS']);
    }
    
    // 检查当前用户是否是团队团长
    $stmt = $db->prepare("SELECT role FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$currentUser['user_id'], $teamId]);
    $userRole = $stmt->fetchColumn();
    
    if ($userRole != 1) {
        Response::error('只有团长可以修改团队信息', $errorCodes['PERMISSION_DENIED']);
    }
    
    // 检查团队是否存在
    $stmt = $db->prepare("SELECT id FROM teams WHERE id = ?");
    $stmt->execute([$teamId]);
    if (!$stmt->fetch()) {
        Response::error('团队不存在', $errorCodes['TEAM_NOT_FOUND']);
    }
    
    // 修改团队信息
    $stmt = $db->prepare("UPDATE teams SET team_name = ? WHERE id = ?");
    if ($stmt->execute([$teamName, $teamId])) {
        Response::success([], '修改团队信息成功');
    } else {
        Response::error('修改团队信息失败', $errorCodes['SERVER_ERROR'], 500);
    }
}

// 解散团队
function dissolveTeam($db, $currentUser, $errorCodes) {
    $input = json_decode(file_get_contents('php://input'), true);
    $teamId = $input['team_id'] ?? '';
    
    if (empty($teamId)) {
        Response::error('团队ID不能为空', $errorCodes['INVALID_PARAMS']);
    }
    
    // 检查当前用户是否是团队团长
    $stmt = $db->prepare("SELECT role FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$currentUser['user_id'], $teamId]);
    $userRole = $stmt->fetchColumn();
    
    if ($userRole != 1) {
        Response::error('只有团长可以解散团队', $errorCodes['PERMISSION_DENIED']);
    }
    
    // 检查团队是否存在
    $stmt = $db->prepare("SELECT id FROM teams WHERE id = ?");
    $stmt->execute([$teamId]);
    if (!$stmt->fetch()) {
        Response::error('团队不存在', $errorCodes['TEAM_NOT_FOUND']);
    }
    
    // 开启事务
    $db->beginTransaction();
    
    try {
        // 标记团队为解散状态
        $stmt = $db->prepare("UPDATE teams SET status = 0 WHERE id = ?");
        $stmt->execute([$teamId]);
        
        // 标记所有团队成员为退出状态
        $stmt = $db->prepare("UPDATE user_team_relations SET status = 0 WHERE team_id = ?");
        $stmt->execute([$teamId]);
        
        // 清空所有团队成员的团队信息
        $stmt = $db->prepare("UPDATE c_users SET team_id = NULL, team_role = NULL WHERE team_id = ?");
        $stmt->execute([$teamId]);
        
        $db->commit();
        Response::success([], '解散团队成功');
    } catch (PDOException $e) {
        $db->rollBack();
        Response::error('解散团队失败', $errorCodes['SERVER_ERROR'], 500);
    }
}