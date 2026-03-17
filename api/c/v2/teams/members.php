<?php
/**
 * 团队成员管理接口
 * 
 * GET /api/c/v2/teams/members - 获取团队成员列表
 * POST /api/c/v2/teams/members - 添加团队成员
 * DELETE /api/c/v2/teams/members - 移除团队成员
 * 
 * 请求头：
 * X-Token: <token> (C端)
 * 
 * GET 请求参数：
 * - team_id: 团队ID（必填）
 * 
 * POST 请求体：
 * {
 *   "team_id": "uuid",
 *   "user_id": 123
 * }
 * 
 * DELETE 请求体：
 * {
 *   "team_id": "uuid",
 *   "user_id": 123
 * }
 * 
 * 返回结果：
 * {
 *   "code": 0,
 *   "message": "成功",
 *   "data": {
 *     "members": [
 *       {
 *         "user_id": 1,
 *         "username": "用户名",
 *         "role": 1,
 *         "role_text": "团长",
 *         "joined_at": "2026-03-16 12:00:00"
 *       }
 *     ]
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
        // 获取团队成员列表
        getTeamMembers($db, $currentUser, $errorCodes);
        break;
    case 'POST':
        // 添加团队成员
        addTeamMember($db, $currentUser, $errorCodes);
        break;
    case 'DELETE':
        // 移除团队成员
        removeTeamMember($db, $currentUser, $errorCodes);
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

// 获取团队成员列表
function getTeamMembers($db, $currentUser, $errorCodes) {
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
    
    // 查询团队成员列表
    $stmt = $db->prepare("SELECT
        c.id as user_id,
        c.username,
        utr.role,
        CASE utr.role WHEN 1 THEN '团长' WHEN 2 THEN '成员' END as role_text,
        utr.joined_at
    FROM user_team_relations utr
    JOIN c_users c ON utr.user_id = c.id
    WHERE utr.team_id = ? AND utr.status = 1
    ORDER BY utr.role DESC, utr.joined_at ASC");
    
    $stmt->execute([$teamId]);
    $members = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    Response::success(['members' => $members], '团队成员列表查询成功');
}

// 添加团队成员
function addTeamMember($db, $currentUser, $errorCodes) {
    $input = json_decode(file_get_contents('php://input'), true);
    $teamId = $input['team_id'] ?? '';
    $userId = $input['user_id'] ?? 0;
    
    if (empty($teamId) || $userId <= 0) {
        Response::error('团队ID和用户ID不能为空', $errorCodes['INVALID_PARAMS']);
    }
    
    // 检查当前用户是否是团队团长
    $stmt = $db->prepare("SELECT role FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$currentUser['user_id'], $teamId]);
    $userRole = $stmt->fetchColumn();
    
    if ($userRole != 1) {
        Response::error('只有团长可以添加成员', $errorCodes['PERMISSION_DENIED']);
    }
    
    // 检查目标用户是否存在
    $stmt = $db->prepare("SELECT id FROM c_users WHERE id = ?");
    $stmt->execute([$userId]);
    if (!$stmt->fetch()) {
        Response::error('目标用户不存在', $errorCodes['USER_NOT_FOUND']);
    }
    
    // 检查目标用户是否已经是团队成员
    $stmt = $db->prepare("SELECT id FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$userId, $teamId]);
    if ($stmt->fetch()) {
        Response::error('该用户已经是团队成员', $errorCodes['USER_ALREADY_IN_TEAM']);
    }
    
    // 开启事务
    $db->beginTransaction();
    
    try {
        // 添加团队成员
        $stmt = $db->prepare("INSERT INTO user_team_relations (user_id, team_id, role, status) VALUES (?, ?, 2, 1)");
        $stmt->execute([$userId, $teamId]);
        
        // 更新用户表中的团队信息
        $stmt = $db->prepare("UPDATE c_users SET team_id = ?, team_role = 2 WHERE id = ?");
        $stmt->execute([$teamId, $userId]);
        
        $db->commit();
        Response::success([], '添加团队成员成功');
    } catch (PDOException $e) {
        $db->rollBack();
        Response::error('添加团队成员失败', $errorCodes['SERVER_ERROR'], 500);
    }
}

// 移除团队成员
function removeTeamMember($db, $currentUser, $errorCodes) {
    $input = json_decode(file_get_contents('php://input'), true);
    $teamId = $input['team_id'] ?? '';
    $userId = $input['user_id'] ?? 0;
    
    if (empty($teamId) || $userId <= 0) {
        Response::error('团队ID和用户ID不能为空', $errorCodes['INVALID_PARAMS']);
    }
    
    // 检查当前用户是否是团队团长
    $stmt = $db->prepare("SELECT role FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$currentUser['user_id'], $teamId]);
    $userRole = $stmt->fetchColumn();
    
    if ($userRole != 1) {
        Response::error('只有团长可以移除成员', $errorCodes['PERMISSION_DENIED']);
    }
    
    // 检查目标用户是否是团队成员
    $stmt = $db->prepare("SELECT role FROM user_team_relations WHERE user_id = ? AND team_id = ? AND status = 1");
    $stmt->execute([$userId, $teamId]);
    $targetRole = $stmt->fetchColumn();
    
    if (!$targetRole) {
        Response::error('该用户不是团队成员', $errorCodes['USER_NOT_IN_TEAM']);
    }
    
    // 团长不能移除自己
    if ($userId == $currentUser['user_id']) {
        Response::error('团长不能移除自己', $errorCodes['INVALID_OPERATION']);
    }
    
    // 开启事务
    $db->beginTransaction();
    
    try {
        // 移除团队成员
        $stmt = $db->prepare("UPDATE user_team_relations SET status = 0 WHERE user_id = ? AND team_id = ?");
        $stmt->execute([$userId, $teamId]);
        
        // 更新用户表中的团队信息
        $stmt = $db->prepare("UPDATE c_users SET team_id = NULL, team_role = NULL WHERE id = ?");
        $stmt->execute([$userId]);
        
        $db->commit();
        Response::success([], '移除团队成员成功');
    } catch (PDOException $e) {
        $db->rollBack();
        Response::error('移除团队成员失败', $errorCodes['SERVER_ERROR'], 500);
    }
}