<?php
/**
 * 日志路由器
 * 
 * 根据接口路径自动将日志输出到对应的日志文件
 * 新目录结构：logs/{log_type}/{date}/{log_type}.log
 * 例如：logs/audit/20260324/audit.log
 * 
 * 使用方法：
 * 1. 在接口文件顶部添加：
 *    require_once __DIR__ . '/../../../../core/Logger/LoggerRouter.php';
 *    LoggerRouter::setContext('c/tasks/accept');
 * 
 * 2. 正常使用 LoggerFactory：
 *    $logger = LoggerFactory::getLogger('request');
 *    $logger->info('接单成功', ['record_id' => 123]);
 */

namespace Core\Logger;

class LoggerRouter
{
    /**
     * 当前接口的上下文标识
     */
    private static string $currentContext = '';
    
    /**
     * 接口与日志类型的映射关系
     * 所有日志都保存到对应的日志类型文件中，不再按接口分开
     */
    private static array $routeMap = [
        // B 端认证接口 -> request
        'b/auth/register' => 'request',
        'b/v1/auth/register' => 'request',
        'b/auth/login' => 'request',
        'b/v1/auth/login' => 'request',
        'b/auth/logout' => 'request',
        'b/v1/auth/logout' => 'request',
        'b/v1/auth/change-password' => 'request',
        'b/v1/auth/check-token' => 'request',
        'b/v1/auth/refresh' => 'request',
        'b/v1/auth/reset-password' => 'request',
        
        // C 端认证接口 -> request
        'c/auth/register' => 'request',
        'c/v1/auth/register' => 'request',
        'c/auth/login' => 'request',
        'c/v1/auth/login' => 'request',
        'c/auth/logout' => 'request',
        'c/v1/auth/logout' => 'request',
        'c/v1/auth/change-password' => 'request',
        'c/v1/auth/check-token' => 'request',
        'c/v1/auth/refresh' => 'request',
        'c/v1/auth/reset-password' => 'request',
        
        // C 端任务接口 -> request
        'c/tasks/accept' => 'request',
        'c/tasks/submit' => 'request',
        'c/tasks/review' => 'request',
        'c/tasks/list' => 'request',
        'c/v1/tasks' => 'request',
        'c/v1/withdraw-list' => 'request',
        'c/v1/withdraw' => 'request',
        'c/v1/agent/applications' => 'request',
        'c/v1/agent/apply-senior' => 'request',
        'c/v1/agent/apply' => 'request',
        'c/v1/agent/downlines' => 'request',
        'c/v1/agent/info' => 'request',
        'c/v1/tasks/accept-newbie' => 'request',
        'c/v1/tasks/accept' => 'request',
        'c/v1/tasks/my-tasks' => 'request',
        'c/v1/tasks/submit' => 'request',
        
        // B 端任务接口 -> request
        'b/tasks/create' => 'request',
        'b/tasks/review' => 'request',
        'b/tasks/list' => 'request',
        'b/v1/tasks/list' => 'request',
        'b/v1/tasks/review' => 'request',
        'b/v1/newbie-tasks' => 'request',
        'b/v1/quick-task' => 'request',
        'b/v1/recharge' => 'request',
        'b/v1/task-templates' => 'request',
        'b/v1/tasks' => 'request',
        'b/v1/magnify/create' => 'request',
        'b/v1/magnify/detail' => 'request',
        'b/v1/magnify/list' => 'request',
        'b/v1/quick-task-config/get' => 'request',
        'b/v1/quick-task-config/update' => 'request',
        'b/v1/tasks/detail' => 'request',
        'b/v1/tasks/list' => 'request',
        'b/v1/tasks/pending' => 'request',
        'b/v1/tasks/review' => 'request',
        
        // B 端用户接口 -> request
        'b/v1/check-wallet-password' => 'request',
        'b/v1/me' => 'request',
        'b/v1/wallet-password' => 'request',
        'b/v1/wallet' => 'request',
        
        // C 端用户接口 -> request
        'c/v1/check-wallet-password' => 'request',
        'c/v1/me' => 'request',
        'c/v1/wallet-password' => 'request',
        'c/v1/wallet' => 'request',
        
        // B 端统计接口 -> request
        'b/v1/statistics/flows' => 'request',
        'b/v1/statistics/summary' => 'request',
        
        // C 端统计接口 -> request
        'c/v1/agent/stats' => 'request',
        'c/v1/statistics/flows' => 'request',
        'c/v1/statistics/summary' => 'request',
        'c/v1/statistics/team-revenue-details' => 'request',
        'c/v1/statistics/team-revenue' => 'request',
        'c/v1/team-revenue/statistics' => 'request',
        
        // B 端通知接口 -> request
        'b/v1/notifications/details' => 'request',
        'b/v1/notifications/list' => 'request',
        'b/v1/notifications/read' => 'request',
        
        // C 端通知接口 -> request
        'c/v1/notifications/details' => 'request',
        'c/v1/notifications/list' => 'request',
        'c/v1/notifications/read' => 'request',
        
        // 租赁业务接口 -> request
        'rental/applications/apply' => 'request',
        'rental/applications/list' => 'request',
        'rental/applications/review' => 'request',
        'rental/demands/create' => 'request',
        'rental/demands/detail' => 'request',
        'rental/demands/list' => 'request',
        'rental/demands/toggle-status' => 'request',
        'rental/demands/update' => 'request',
        'rental/offers/create' => 'request',
        'rental/offers/detail' => 'request',
        'rental/offers/list' => 'request',
        'rental/offers/toggle-status' => 'request',
        'rental/offers/update' => 'request',
        'rental/orders/create-from-offer' => 'request',
        'rental/orders/my-buyer' => 'request',
        'rental/orders/my-seller' => 'request',
        'rental/orders/renew' => 'request',
        'rental/tickets/close' => 'request',
        'rental/tickets/create' => 'request',
        'rental/tickets/detail' => 'request',
        'rental/tickets/list' => 'request',
        'rental/tickets/messages' => 'request',
        'rental/tickets/send-message' => 'request',
        
        // 短信接口 -> request
        'sms/send-code' => 'request',
        'sms/verify-code' => 'request',
        
        // 其他接口 -> request
        'upload' => 'request',
        
        // 定时任务 -> cron
        'cron/task_check' => 'cron',
        'cron/task_auto_review' => 'cron',
        'cron/supply_newbie_tasks' => 'cron',
    ];
    
    /**
     * 设置当前接口的上下文
     * 
     * @param string $context 接口路径，如：c/tasks/accept
     */
    public static function setContext(string $context): void
    {
        self::$currentContext = $context;
    }
    
    /**
     * 获取当前上下文对应的日志类型
     * 
     * @return string 日志类型（audit, request, error, sql, operation, access, cron）
     */
    public static function getLogType(): string
    {
        if (empty(self::$currentContext)) {
            return 'request';
        }
        
        // 精确匹配
        if (isset(self::$routeMap[self::$currentContext])) {
            return self::$routeMap[self::$currentContext];
        }
        
        // 模糊匹配（支持通配符）
        foreach (self::$routeMap as $pattern => $logType) {
            if (strpos(self::$currentContext, $pattern) === 0) {
                return $logType;
            }
        }
        
        // 默认返回 request
        return 'request';
    }
    
    /**
     * 获取当前上下文对应的完整日志文件路径
     * 
     * 注意：新结构下，所有日志都保存到对应的日志类型文件中
     * 例如：logs/audit/20260324/audit.log
     * 
     * @param string $channel 日志通道（audit, request, error, sql, operation, access, cron）
     * @return string 日志类型
     */
    public static function getLogFilePath(string $channel = 'request'): string
    {
        // 新结构下，直接返回日志类型，RotatingFileHandler 会根据类型生成路径
        return $channel;
    }
    
    /**
     * 自动检测当前接口上下文
     * 
     * @return string 接口上下文
     */
    private static function autoDetectContext(): string
    {
        // 尝试从 REQUEST_URI 获取
        $uri = $_SERVER['REQUEST_URI'] ?? '';
        
        if (empty($uri)) {
            return '';
        }
        
        // 解析 URI，提取 API 路径
        // 示例：/api/b/v1/auth/login -> b/v1/auth/login
        $uri = parse_url($uri, PHP_URL_PATH);
        
        // 去掉开头的 /api/
        if (strpos($uri, '/api/') === 0) {
            $apiPath = substr($uri, 5); // 去掉 '/api'
            return trim($apiPath, '/');
        }
        
        // 如果不是 /api/ 开头，直接返回去掉开头的斜杠
        return trim($uri, '/');
    }
    
    /**
     * 注册新的路由规则
     * 
     * @param string $apiPattern API 路径模式
     * @param string $logType 日志类型
     */
    public static function register(string $apiPattern, string $logType): void
    {
        self::$routeMap[$apiPattern] = $logType;
    }
    
    /**
     * 获取所有路由规则
     * 
     * @return array 路由规则数组
     */
    public static function getRoutes(): array
    {
        return self::$routeMap;
    }
    
    /**
     * 清除当前上下文
     */
    public static function clear(): void
    {
        self::$currentContext = '';
    }
}