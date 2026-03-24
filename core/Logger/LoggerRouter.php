<?php
/**
 * 日志路由器
 * 
 * 根据接口路径自动将日志输出到对应的日志文件
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
     * 接口与日志文件的映射关系
     */
    private static array $routeMap = [
        // B 端认证
        'b/auth/register' => 'request/b_auth_register',
        'b/auth/login' => 'request/b_auth_login',
        'b/auth/logout' => 'request/b_auth_logout',
        
        // C 端认证
        'c/auth/register' => 'request/c_auth_register',
        'c/auth/login' => 'request/c_auth_login',
        'c/auth/logout' => 'request/c_auth_logout',
        
        // C 端任务
        'c/tasks/accept' => 'request/c_tasks_accept',
        'c/tasks/submit' => 'request/c_tasks_submit',
        'c/tasks/review' => 'request/c_tasks_review',
        'c/tasks/list' => 'request/c_tasks_list',
        
        // B 端任务
        'b/tasks/create' => 'request/b_tasks_create',
        'b/tasks/review' => 'request/b_tasks_review',
        'b/tasks/list' => 'request/b_tasks_list',
        'b/v1/tasks/list' => 'request/b-v1-tasks-list',
        'b/v1/tasks/review' => 'request/b-v1-tasks-review',
        
        // 定时任务
        'cron/task_check' => 'cron/task_check',
        'cron/task_auto_review' => 'cron/task_auto_review',
        'cron/supply_newbie_tasks' => 'cron/supply_newbie_tasks',
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
     * 获取当前上下文对应的日志文件前缀
     * 
     * @return string 日志文件前缀
     */
    public static function getLogPrefix(): string
    {
        if (empty(self::$currentContext)) {
            return '';
        }
        
        // 精确匹配
        if (isset(self::$routeMap[self::$currentContext])) {
            return self::$routeMap[self::$currentContext];
        }
        
        // 模糊匹配（支持通配符）
        foreach (self::$routeMap as $pattern => $prefix) {
            if (strpos(self::$currentContext, $pattern) === 0) {
                return $prefix;
            }
        }
        
        // 默认返回接口路径作为日志前缀
        return 'request/' . str_replace('/', '_', self::$currentContext);
    }
    
    /**
     * 注册新的路由规则
     * 
     * @param string $apiPattern API 路径模式
     * @param string $logPrefix 日志文件前缀
     */
    public static function register(string $apiPattern, string $logPrefix): void
    {
        self::$routeMap[$apiPattern] = $logPrefix;
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
