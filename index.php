<?php
/**
 * API 路由入口文件
 * 处理所有 API 请求的路由，支持无 .php 后缀的 URL
 */

// 开启调试模式
$debug = true;

// 获取请求路径
$requestUri = $_SERVER['REQUEST_URI'];

// 移除查询字符串
$path = parse_url($requestUri, PHP_URL_PATH);

// 调试日志：输出请求信息
if ($debug) {
    error_log('Index.php - Request URI: ' . $requestUri);
    error_log('Index.php - Parsed path: ' . $path);
}

// 路由映射
$routes = [
    // C端认证相关路由
    '/api/c/v1/auth/register' => 'api/c/v1/auth/register.php',
    '/api/c/v1/auth/login' => 'api/c/v1/auth/login.php',
    '/api/c/v1/auth/logout' => 'api/c/v1/auth/logout.php',
    '/api/c/v1/auth/refresh' => 'api/c/v1/auth/refresh.php',
    '/api/c/v1/auth/change-password' => 'api/c/v1/auth/change-password.php',
    '/api/c/v1/auth/reset-password' => 'api/c/v1/auth/reset-password.php',
    
    // B端认证相关路由
    '/api/b/v1/auth/register' => 'api/b/v1/auth/register.php',
    '/api/b/v1/auth/login' => 'api/b/v1/auth/login.php',
    '/api/b/v1/auth/logout' => 'api/b/v1/auth/logout.php',
    '/api/b/v1/auth/refresh' => 'api/b/v1/auth/refresh.php',
    '/api/b/v1/auth/change-password' => 'api/b/v1/auth/change-password.php',
    '/api/b/v1/auth/reset-password' => 'api/b/v1/auth/reset-password.php',
];

// 检查是否匹配路由
if (isset($routes[$path])) {
    // 调试日志：路由匹配成功
    if ($debug) {
        error_log('Index.php - Route matched: ' . $path . ' -> ' . $routes[$path]);
    }
    // 包含对应的 PHP 文件
    require_once $routes[$path];
} else {
    // 调试日志：路由匹配失败
    if ($debug) {
        error_log('Index.php - Route not matched: ' . $path);
        error_log('Index.php - Available routes: ' . print_r(array_keys($routes), true));
    }
    // 检查是否是真实文件
    $filePath = __DIR__ . $path;
    if ($debug) {
        error_log('Index.php - Checking real file: ' . $filePath);
    }
    if (file_exists($filePath) && is_file($filePath)) {
        // 调试日志：真实文件存在
        if ($debug) {
            error_log('Index.php - Real file exists: ' . $filePath);
        }
        // 直接返回文件
        return false; // 让 PHP 内置服务器处理静态文件
    } else {
        // 检查是否是带 .php 后缀的路径
        $phpPath = $path . '.php';
        $phpFilePath = __DIR__ . $phpPath;
        if ($debug) {
            error_log('Index.php - Checking PHP file: ' . $phpFilePath);
        }
        if (file_exists($phpFilePath) && is_file($phpFilePath)) {
            // 调试日志：PHP 文件存在
            if ($debug) {
                error_log('Index.php - PHP file exists: ' . $phpFilePath);
            }
            // 包含对应的 PHP 文件
            require_once $phpFilePath;
        } else {
            // 调试日志：返回 404 错误
            if ($debug) {
                error_log('Index.php - Returning 404 for: ' . $path);
            }
            
            // 检查是否是task_admin路径
            if (strpos($path, '/task_admin/') === 0) {
                // 重定向到task_admin的404页面
                header('Location: /task_admin/404.html');
                exit;
            } else {
                // 返回 404 错误
                http_response_code(404);
                echo json_encode([
                    'code' => 404,
                    'message' => '接口不存在',
                    'data' => [],
                    'timestamp' => time()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
        }
    }
}