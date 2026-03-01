<?php
/**
 * 应用配置管理类
 * 从数据库读取配置，带缓存机制
 */

class AppConfig {
    private static $cache = null;
    private static $cacheTime = 0;
    private static $cacheTTL = 300; // 缓存5分钟

    /**
     * 获取所有配置
     */
    public static function getAll() {
        // 检查缓存
        if (self::$cache !== null && (time() - self::$cacheTime) < self::$cacheTTL) {
            return self::$cache;
        }

        try {
            $db = Database::connect();
            $stmt = $db->query("SELECT config_key, config_value, config_type FROM app_config");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $config = [];
            foreach ($rows as $row) {
                $value = self::parseValue($row['config_value'], $row['config_type']);
                $config[$row['config_key']] = $value;
            }

            // 更新缓存
            self::$cache = $config;
            self::$cacheTime = time();

            return $config;
        } catch (Exception $e) {
            error_log("读取配置失败: " . $e->getMessage());
            // 返回默认配置
            return self::getDefaultConfig();
        }
    }

    /**
     * 获取单个配置
     */
    public static function get($key, $default = null) {
        $config = self::getAll();
        return $config[$key] ?? $default;
    }

    /**
     * 更新配置
     */
    public static function set($key, $value) {
        try {
            $db = Database::connect();
            
            // 获取配置类型
            $stmt = $db->prepare("SELECT config_type FROM app_config WHERE config_key = ?");
            $stmt->execute([$key]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$row) {
                return false;
            }

            $configType = $row['config_type'];
            $valueStr = self::stringifyValue($value, $configType);

            // 更新配置
            $updateStmt = $db->prepare("UPDATE app_config SET config_value = ? WHERE config_key = ?");
            $result = $updateStmt->execute([$valueStr, $key]);

            // 清除缓存
            self::clearCache();

            return $result;
        } catch (Exception $e) {
            error_log("更新配置失败: " . $e->getMessage());
            return false;
        }
    }

    /**
     * 清除缓存
     */
    public static function clearCache() {
        self::$cache = null;
        self::$cacheTime = 0;
    }

    /**
     * 解析配置值
     */
    private static function parseValue($value, $type) {
        switch ($type) {
            case 'int':
                return intval($value);
            case 'float':
                return floatval($value);
            case 'boolean':
                return filter_var($value, FILTER_VALIDATE_BOOLEAN);
            case 'json':
                return json_decode($value, true);
            case 'array':
                // 数组用逗号分隔
                return array_filter(array_map('trim', explode(',', $value)));
            default:
                return $value;
        }
    }

    /**
     * 将值转换为字符串
     */
    private static function stringifyValue($value, $type) {
        switch ($type) {
            case 'boolean':
                return $value ? '1' : '0';
            case 'json':
                return json_encode($value, JSON_UNESCAPED_UNICODE);
            case 'array':
                return is_array($value) ? implode(',', $value) : $value;
            default:
                return strval($value);
        }
    }

    /**
     * 默认配置（数据库不可用时使用）
     */
    private static function getDefaultConfig() {
        return [
            'website' => 'http://134.122.136.221:4667',
            'upload_path' => './img',
            'platform_fee_rate' => 0.25,
            'task_submit_timeout' => 600,
            'agent_required_active_users' => 5,
            'agent_active_user_task_count' => 5,
            'agent_active_user_hours' => 24,
            'senior_agent_required_active_users' => 30,
            'senior_agent_active_user_task_count' => 10,
            'senior_agent_active_user_hours' => 48,
            'senior_agent_max_count' => 100,
            'c_withdraw_min_amount' => 100,
            'c_withdraw_max_amount' => 500,
            'c_withdraw_amount_multiple' => 100,
            'c_withdraw_daily_limit' => 1000,
            'c_withdraw_allowed_weekdays' => ['4'], // 仅周四
            'c_withdraw_fee_rate' => 0.03, // 提现手续费3%
            'b_withdraw_min_amount' => 100,
            'b_withdraw_max_amount' => 5000,
            'b_withdraw_daily_limit' => 10000,
            'rental_platform_rate' => 25,
            'rental_platform_fee_rate' => 0.25,
            'rental_seller_rate' => 70,
            'rental_agent_rate' => 10,
            'rental_senior_agent_rate' => 10,
            'agent_incentive_enabled' => 1,
            'agent_incentive_end_time' => '2099-12-31 23:59:59',
            'agent_incentive_amount' => 1000,
            'agent_incentive_min_withdraw' => 10000,
            'agent_incentive_limit_enabled' => 0,
            'agent_incentive_limit_count' => 10
        ];
    }
}
