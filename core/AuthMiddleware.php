<?php
/**
 * 认证中间件（Token 校验 + 跨端防护）
 * 
 * 功能：
 * - 自动识别 API 端（/api/b/v1、/api/c/v1、/api/admin/v1）
 * - 校验 Token 有效性
 * - 防止跨端访问
 * - 统一错误响应
 */

require_once __DIR__ . '/Token.php';
require_once __DIR__ . '/Response.php';

class AuthMiddleware
{
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
    }

    /**
     * Token 认证中间件（主入口）
     * 
     * @return array ['user_id' => xxx, 'type' => xxx] 或直接退出并返回错误
     */
    public function authenticate()
    {
        // 1. 识别当前 API 端
        $apiType = $this->detectApiType();
        if ($apiType === null) {
            Response::error('API 路径不合法', 400);
        }

        // 2. 获取 Token
        $token = Token::getFromRequest();
        if (!$token) {
            Response::error('未提供认证 Token', 401);
        }

        // 3. 完整校验 Token
        $result = Token::verify($token, $apiType, $this->db);

        // 4. 校验失败，返回错误
        if (!$result['valid']) {
            Response::error($result['error'], 401);
        }

        // 5. 校验成功，返回用户信息
        return [
            'user_id' => $result['user_id'],
            'type' => $result['type']
        ];
    }

    /**
     * 根据请求路径自动识别 API 端
     * 
     * @return int|null 1=C端 2=B端 3=Admin端
     */
    private function detectApiType()
    {
        $requestUri = $_SERVER['REQUEST_URI'] ?? '';
        $path = parse_url($requestUri, PHP_URL_PATH);

        // 匹配 /api/c/v1/*
        if (preg_match('#^/api/c/v1/#', $path)) {
            return Token::TYPE_C;
        }

        // 匹配 /api/b/v1/*
        if (preg_match('#^/api/b/v1/#', $path)) {
            return Token::TYPE_B;
        }

        // 匹配 /api/admin/v1/*
        if (preg_match('#^/api/admin/v1/#', $path)) {
            return Token::TYPE_ADMIN;
        }

        return null;
    }

    /**
     * 快捷方法：B端认证
     */
    public function authenticateB()
    {
        $token = Token::getFromRequest();
        if (!$token) {
            Response::error('未提供认证 Token', 401);
        }

        $result = Token::verify($token, Token::TYPE_B, $this->db);
        if (!$result['valid']) {
            Response::error($result['error'], 401);
        }

        return [
            'user_id' => $result['user_id'],
            'type' => $result['type']
        ];
    }

    /**
     * 快捷方法：C端认证
     */
    public function authenticateC()
    {
        $token = Token::getFromRequest();
        if (!$token) {
            Response::error('未提供认证 Token', 401);
        }

        $result = Token::verify($token, Token::TYPE_C, $this->db);
        if (!$result['valid']) {
            Response::error($result['error'], 401);
        }

        return [
            'user_id' => $result['user_id'],
            'type' => $result['type']
        ];
    }

    /**
     * 快捷方法：Admin端认证
     */
    public function authenticateAdmin()
    {
        $token = Token::getFromRequest();
        if (!$token) {
            Response::error('未提供认证 Token', 401);
        }

        $result = Token::verify($token, Token::TYPE_ADMIN, $this->db);
        if (!$result['valid']) {
            Response::error($result['error'], 401);
        }

        return [
            'user_id' => $result['user_id'],
            'type' => $result['type']
        ];
    }

    /**
     * 通用认证（三端均可）
     * 用于通用接口，不校验 type 类型
     * 
     * @return array ['user_id' => xxx, 'type' => xxx]
     */
    public function authenticateAny()
    {
        $token = Token::getFromRequest();
        if (!$token) {
            Response::error('未提供认证 Token', 401);
        }

        // 解析 token
        $payload = Token::decode($token);
        if (!$payload) {
            Response::error('Token 格式无效', 401);
        }

        // 校验过期时间
        if ($payload['exp'] < time()) {
            Response::error('Token 已过期', 401);
        }

        // 根据 type 获取表名并校验
        $result = Token::verify($token, $payload['type'], $this->db);
        if (!$result['valid']) {
            Response::error($result['error'], 401);
        }

        return [
            'user_id' => $result['user_id'],
            'type' => $result['type']
        ];
    }
}

