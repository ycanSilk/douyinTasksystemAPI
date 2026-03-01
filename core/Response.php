<?php
/**
 * 统一响应格式类
 * 
 * 格式：
 * {
 *   "code": 0,
 *   "message": "ok",
 *   "data": {},
 *   "timestamp": 1705420800
 * }
 */

class Response
{
    /**
     * 成功响应
     * 
     * @param mixed $data 返回数据
     * @param string $message 提示信息
     */
    public static function success($data = [], $message = 'ok')
    {
        self::output([
            'code' => 0,
            'message' => $message,
            'data' => $data,
            'timestamp' => time()
        ]);
    }

    /**
     * 错误响应
     * 
     * @param string $message 错误信息
     * @param int $code 错误码（非0）
     * @param int $httpCode HTTP状态码
     */
    public static function error($message = '请求失败', $code = 1, $httpCode = 400)
    {
        http_response_code($httpCode);
        self::output([
            'code' => $code,
            'message' => $message,
            'data' => [],
            'timestamp' => time()
        ]);
    }

    /**
     * 输出 JSON 并终止脚本
     * 
     * @param array $data
     */
    private static function output($data)
    {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
        exit;
    }
}

