#!/usr/bin/env php
<?php
/**
 * 日志配置管理工具
 * 
 * 用于读取、验证和管理 api_log_mapping.json 配置
 * 
 * 使用方法：
 * php config/manage_log_config.php list        # 列出所有接口
 * php config/manage_log_config.php validate    # 验证配置
 * php config/manage_log_config.php export      # 导出为其他格式
 */

$configFile = __DIR__ . '/api_log_mapping.json';

// 检查配置文件是否存在
if (!file_exists($configFile)) {
    echo "错误：配置文件不存在：$configFile\n";
    exit(1);
}

// 读取配置
$configJson = file_get_contents($configFile);
$config = json_decode($configJson, true);

// 检查 JSON 是否有效
if (json_last_error() !== JSON_ERROR_NONE) {
    echo "错误：JSON 格式无效：" . json_last_error_msg() . "\n";
    exit(1);
}

// 命令行参数
$action = $argv[1] ?? 'list';

switch ($action) {
    case 'list':
        listInterfaces($config);
        break;
    case 'validate':
        validateConfig($config);
        break;
    case 'export':
        exportConfig($config);
        break;
    case 'search':
        $keyword = $argv[2] ?? '';
        if (empty($keyword)) {
            echo "使用方法：php manage_log_config.php search <关键词>\n";
            exit(1);
        }
        searchInterface($config, $keyword);
        break;
    default:
        showHelp();
}

/**
 * 列出所有接口
 */
function listInterfaces($config) {
    echo "\n";
    echo "========================================\n";
    echo "  接口日志映射配置\n";
    echo "========================================\n";
    echo "\n";
    
    $apiRoutes = $config['api_routes'] ?? [];
    $total = 0;
    
    foreach ($apiRoutes as $category => $interfaces) {
        echo "\033[36m[$category]\033[0m\n";
        
        foreach ($interfaces as $path => $info) {
            $prefix = $info['log_prefix'] ?? 'unknown';
            $desc = $info['description'] ?? '';
            $file = $info['file'] ?? '';
            
            echo "  \033[33m$path\033[0m\n";
            echo "    描述：$desc\n";
            echo "    日志前缀：$prefix\n";
            echo "    文件：$file\n";
            echo "\n";
            
            $total++;
        }
    }
    
    echo "========================================\n";
    echo "总计：$total 个接口\n";
    echo "========================================\n\n";
}

/**
 * 验证配置
 */
function validateConfig($config) {
    echo "\n";
    echo "========================================\n";
    echo "  验证配置文件\n";
    echo "========================================\n";
    echo "\n";
    
    $errors = [];
    $warnings = [];
    
    // 检查必需字段
    if (empty($config['api_routes'])) {
        $errors[] = "缺少 'api_routes' 字段";
    }
    
    if (empty($config['log_types'])) {
        $warnings[] = "缺少 'log_types' 字段（可选）";
    }
    
    // 验证每个接口配置
    $apiRoutes = $config['api_routes'] ?? [];
    $prefixes = [];
    
    foreach ($apiRoutes as $category => $interfaces) {
        foreach ($interfaces as $path => $info) {
            // 检查必需字段
            if (empty($info['log_prefix'])) {
                $errors[] = "接口 '$path' 缺少 'log_prefix' 字段";
            } else {
                // 检查前缀是否重复
                if (in_array($info['log_prefix'], $prefixes)) {
                    $warnings[] = "接口 '$path' 的日志前缀 '{$info['log_prefix']}' 重复";
                }
                $prefixes[] = $info['log_prefix'];
            }
            
            // 检查路径格式
            if (empty($path)) {
                $errors[] = "发现空的路径键名";
            }
        }
    }
    
    // 输出结果
    if (empty($errors) && empty($warnings)) {
        echo "\033[32m✓ 配置验证通过！\033[0m\n";
    } else {
        if (!empty($errors)) {
            echo "\033[31m错误：\033[0m\n";
            foreach ($errors as $error) {
                echo "  ✗ $error\n";
            }
        }
        
        if (!empty($warnings)) {
            echo "\033[33m警告：\033[0m\n";
            foreach ($warnings as $warning) {
                echo "  ! $warning\n";
            }
        }
    }
    
    echo "\n";
}

/**
 * 导出配置
 */
function exportConfig($config) {
    echo "\n";
    echo "========================================\n";
    echo "  导出配置\n";
    echo "========================================\n";
    echo "\n";
    
    $format = $argv[2] ?? 'shell';
    
    switch ($format) {
        case 'shell':
            exportAsShell($config);
            break;
        case 'php':
            exportAsPHP($config);
            break;
        case 'csv':
            exportAsCSV($config);
            break;
        default:
            echo "不支持的格式：$format\n";
            echo "支持的格式：shell, php, csv\n";
    }
}

/**
 * 导出为 Shell 关联数组
 */
function exportAsShell($config) {
    echo "# Shell 关联数组格式\n";
    echo "# 可在 view_logs.sh 中使用\n\n";
    echo "declare -A API_LOG_MAP=(\n";
    
    $apiRoutes = $config['api_routes'] ?? [];
    foreach ($apiRoutes as $category => $interfaces) {
        foreach ($interfaces as $path => $info) {
            $prefix = $info['log_prefix'] ?? '';
            echo "    [\"$path\"]=\"$prefix\"\n";
        }
    }
    
    echo ")\n";
}

/**
 * 导出为 PHP 数组
 */
function exportAsPHP($config) {
    echo "<?php\n";
    echo "// PHP 数组格式\n";
    echo "// 可在 LoggerRouter.php 中使用\n\n";
    echo "return " . var_export($config['api_routes'] ?? [], true) . ";\n";
}

/**
 * 导出为 CSV
 */
function exportAsCSV($config) {
    echo "category,path,log_prefix,description,file\n";
    
    $apiRoutes = $config['api_routes'] ?? [];
    foreach ($apiRoutes as $category => $interfaces) {
        foreach ($interfaces as $path => $info) {
            $prefix = $info['log_prefix'] ?? '';
            $desc = $info['description'] ?? '';
            $file = $info['file'] ?? '';
            
            echo "\"$category\",\"$path\",\"$prefix\",\"$desc\",\"$file\"\n";
        }
    }
}

/**
 * 搜索接口
 */
function searchInterface($config, $keyword) {
    echo "\n";
    echo "========================================\n";
    echo "  搜索接口：$keyword\n";
    echo "========================================\n";
    echo "\n";
    
    $found = false;
    $apiRoutes = $config['api_routes'] ?? [];
    
    foreach ($apiRoutes as $category => $interfaces) {
        foreach ($interfaces as $path => $info) {
            $desc = $info['description'] ?? '';
            $file = $info['file'] ?? '';
            $prefix = $info['log_prefix'] ?? '';
            
            // 搜索路径、描述、文件名
            if (strpos($path, $keyword) !== false ||
                strpos($desc, $keyword) !== false ||
                strpos($file, $keyword) !== false ||
                strpos($prefix, $keyword) !== false) {
                
                echo "\033[36m[$category]\033[0m\n";
                echo "  \033[33m$path\033[0m\n";
                echo "    描述：$desc\n";
                echo "    日志前缀：$prefix\n";
                echo "    文件：$file\n";
                echo "\n";
                
                $found = true;
            }
        }
    }
    
    if (!$found) {
        echo "\033[33m未找到匹配的接口\033[0m\n";
    }
    
    echo "\n";
}

/**
 * 显示帮助
 */
function showHelp() {
    echo "\n";
    echo "日志配置管理工具\n";
    echo "\n";
    echo "使用方法：\n";
    echo "  php manage_log_config.php list       列出所有接口\n";
    echo "  php manage_log_config.php validate   验证配置\n";
    echo "  php manage_log_config.php export     导出配置\n";
    echo "  php manage_log_config.php search     搜索接口\n";
    echo "\n";
    echo "示例：\n";
    echo "  php manage_log_config.php list\n";
    echo "  php manage_log_config.php validate\n";
    echo "  php manage_log_config.php export shell\n";
    echo "  php manage_log_config.php search accept\n";
    echo "\n";
}
