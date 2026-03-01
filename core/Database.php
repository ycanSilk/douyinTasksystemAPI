<?php
/**
 * 数据库连接类
 */

class Database
{
    private static $instance = null;

    /**
     * 获取数据库连接（单例模式）
     * 
     * @return PDO
     */
    public static function connect()
    {
        if (self::$instance === null) {
            $config = require __DIR__ . '/../config/database.php';
            
            $dsn = sprintf(
                'mysql:host=%s;port=%d;dbname=%s;charset=%s',
                $config['host'],
                $config['port'],
                $config['database'],
                $config['charset']
            );
            
            try {
                self::$instance = new PDO($dsn, $config['username'], $config['password'], $config['options']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode([
                    'code' => 1002,
                    'message' => '数据库连接失败',
                    'data' => []
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
        }
        
        return self::$instance;
    }
}

