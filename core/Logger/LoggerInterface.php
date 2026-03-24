<?php
namespace Core\Logger;

/**
 * 日志接口定义
 * 
 * 定义了日志记录的标准接口
 * 
 * @package Core\Logger
 */
interface LoggerInterface
{
    /**
     * 日志级别常量
     */
    const DEBUG = 10;
    const INFO = 20;
    const NOTICE = 30;
    const WARNING = 40;
    const ERROR = 50;
    const CRITICAL = 60;
    const ALERT = 70;
    const EMERGENCY = 80;
    
    /**
     * 记录日志
     * 
     * @param int $level 日志级别（使用自定的常量）
     * @param string $message 日志消息
     * @param array $context 上下文信息（用户 ID、IP、请求参数等）
     * @return void
     */
    public function log(int $level, string $message, array $context = []): void;
    
    /**
     * 记录调试日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function debug(string $message, array $context = []): void;
    
    /**
     * 记录信息日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function info(string $message, array $context = []): void;
    
    /**
     * 记录通知日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function notice(string $message, array $context = []): void;
    
    /**
     * 记录警告日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function warning(string $message, array $context = []): void;
    
    /**
     * 记录错误日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function error(string $message, array $context = []): void;
    
    /**
     * 记录严重错误日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function critical(string $message, array $context = []): void;
    
    /**
     * 记录警报日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function alert(string $message, array $context = []): void;
    
    /**
     * 记录紧急日志
     * 
     * @param string $message 日志消息
     * @param array $context 上下文信息
     * @return void
     */
    public function emergency(string $message, array $context = []): void;
}
