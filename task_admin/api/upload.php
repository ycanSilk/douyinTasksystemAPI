<?php
// 确保没有输出任何内容
ob_start();

// 调试日志函数
function debugLog($message) {
    $logFile = __DIR__ . '/upload_debug.log';
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
}

/**
 * Admin 图片上传接口
 * POST /task_admin/api/upload.php
 */
debugLog('===== 开始处理上传请求 =====');
debugLog('请求方法: ' . ($_SERVER['REQUEST_METHOD'] ?? '未知'));
debugLog('请求头: ' . print_r(getallheaders(), true));
debugLog('文件上传: ' . print_r($_FILES, true));
debugLog('POST数据: ' . print_r($_POST, true));

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');

// 清理输出缓冲区
ob_clean();

// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    debugLog('处理OPTIONS请求');
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    debugLog('请求方法错误: ' . ($_SERVER['REQUEST_METHOD'] ?? '未知'));
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    // 检查文件上传是否存在
    if (!isset($_FILES)) {
        debugLog('未检测到文件上传');
        http_response_code(400);
        echo json_encode([
            'code' => 1005,
            'message' => '文件上传失败：未检测到文件',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 尝试加载 AuthMiddleware
    if (!file_exists(__DIR__ . '/../auth/AuthMiddleware.php')) {
        debugLog('AuthMiddleware 文件不存在');
        http_response_code(500);
        echo json_encode([
            'code' => 5001,
            'message' => '服务器内部错误：AuthMiddleware 文件不存在',
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    debugLog('加载 AuthMiddleware');
    require_once __DIR__ . '/../auth/AuthMiddleware.php';
    
    // 验证 Admin 登录
    try {
        debugLog('开始验证 Admin 登录');
        AdminAuthMiddleware::authenticate();
        debugLog('Admin 登录验证成功');
    } catch (Exception $e) {
        debugLog('Admin 登录验证失败: ' . $e->getMessage());
        http_response_code(401);
        echo json_encode([
            'code' => 401,
            'message' => '认证失败: ' . $e->getMessage(),
            'data' => [],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 加载配置文件
    try {
        debugLog('加载配置文件');
        $appConfig = require __DIR__ . '/../../config/app.php';
        debugLog('配置文件加载成功: ' . print_r($appConfig, true));
    } catch (Exception $e) {
        debugLog('配置文件加载失败: ' . $e->getMessage());
        // 使用默认配置
        $appConfig = [
            'website' => 'http://localhost' // 默认网站URL
        ];
        debugLog('使用默认配置: ' . print_r($appConfig, true));
    }
    
    $fileContent = '';
    $fileSize = 0;
    $file = null;
    
    // 支持 multipart/form-data 上传，兼容 'image' 和 'file' 两种字段名
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        debugLog('使用 image 字段上传文件');
        $file = $_FILES['image'];
    } elseif (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
        debugLog('使用 file 字段上传文件');
        $file = $_FILES['file'];
    }
    
    if ($file) {
        debugLog('文件上传信息: ' . print_r($file, true));
        $fileContent = file_get_contents($file['tmp_name']);
        $fileSize = $file['size'];
        debugLog('文件大小: ' . $fileSize . ' 字节');
        
        // 检测 MIME 类型
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_buffer($finfo, $fileContent);
        // finfo_close($finfo); // 在 PHP 8.5+ 中已废弃，finfo 对象会自动释放
        debugLog('文件 MIME 类型: ' . $mimeType);
    } else {
        debugLog('未找到有效文件: ' . print_r($_FILES, true));
        http_response_code(400);
        echo json_encode([
            'code' => 1002,
            'message' => '请上传图片文件（支持字段名：image 或 file）',
            'data' => [
                'files' => $_FILES,
                'error' => isset($_FILES['image']) ? $_FILES['image']['error'] : 'no_file'
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 验证文件类型
    $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (!in_array($mimeType, $allowedTypes)) {
        debugLog('文件类型不允许: ' . $mimeType);
        http_response_code(400);
        echo json_encode([
            'code' => 1003,
            'message' => '只支持上传 JPG、PNG、GIF、WEBP 格式的图片',
            'data' => [
                'mimeType' => $mimeType
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 验证文件大小（限制 5MB）
    $maxSize = 5 * 1024 * 1024;
    if ($fileSize > $maxSize) {
        debugLog('文件大小超过限制: ' . $fileSize . ' > ' . $maxSize);
        http_response_code(400);
        echo json_encode([
            'code' => 1004,
            'message' => '图片大小不能超过 5MB',
            'data' => [
                'fileSize' => $fileSize,
                'maxSize' => $maxSize
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    // 获取文件扩展名
    $extension = '';
    switch ($mimeType) {
        case 'image/jpeg':
        case 'image/jpg':
            $extension = 'jpg';
            break;
        case 'image/png':
            $extension = 'png';
            break;
        case 'image/gif':
            $extension = 'gif';
            break;
        case 'image/webp':
            $extension = 'webp';
            break;
    }
    debugLog('文件扩展名: ' . $extension);
    
    // 生成 MD5 哈希文件名
    $hash = md5($fileContent . time() . rand(1000, 9999));
    debugLog('生成的文件名哈希: ' . $hash);
    
    // 创建上传目录
    $uploadDir = __DIR__ . '/../../img';
    debugLog('上传目录: ' . $uploadDir);
    if (!is_dir($uploadDir)) {
        debugLog('创建上传目录');
        mkdir($uploadDir, 0755, true);
    }
    
    // 目标文件路径
    $filename = $hash . '.' . $extension;
    $targetPath = $uploadDir . '/' . $filename;
    debugLog('目标文件路径: ' . $targetPath);
    
    // 保存文件
    if (file_put_contents($targetPath, $fileContent) === false) {
        debugLog('文件保存失败: ' . $targetPath);
        debugLog('目录可写性: ' . (is_writable($uploadDir) ? '是' : '否'));
        http_response_code(500);
        echo json_encode([
            'code' => 5000,
            'message' => '图片保存失败',
            'data' => [
                'targetPath' => $targetPath,
                'uploadDirWritable' => is_writable($uploadDir)
            ],
            'timestamp' => time()
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    
    debugLog('文件保存成功: ' . $targetPath);
    
    // 生成完整访问 URL
    $website = rtrim($appConfig['website'], '/');
    $imageUrl = $website . '/img/' . $filename;
    debugLog('生成的图片 URL: ' . $imageUrl);
    
    // 返回成功响应
    debugLog('返回成功响应');
    echo json_encode([
        'code' => 0,
        'message' => '图片上传成功',
        'data' => [
            'url' => $imageUrl,
            'filename' => $filename,
            'size' => $fileSize,
            'type' => $mimeType
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    debugLog('捕获到异常: ' . $e->getMessage());
    debugLog('异常文件: ' . $e->getFile());
    debugLog('异常行号: ' . $e->getLine());
    debugLog('异常堆栈: ' . $e->getTraceAsString());
    
    http_response_code(500);
    echo json_encode([
        'code' => 500,
        'message' => '服务器内部错误: ' . $e->getMessage(),
        'data' => [
            'error' => $e->getMessage(),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

debugLog('===== 上传请求处理完成 =====');
?>