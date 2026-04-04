<?php
/**
 * 通用图片上传接口
 * 
 * POST /api/upload
 * 
 * 支持两种上传方式：
 * 
 * 方式1：multipart/form-data（表单上传）
 * Content-Type: multipart/form-data
 * 请求参数：image=<文件>
 * 
 * 方式2：binary（二进制直接上传）
 * Content-Type: image/jpeg 或 image/png 等
 * Body: <二进制数据>
 * 
 * 请求头：
 * X-Token: <token> (B端/C端/Admin端均可)
 */

// 加载统一日志系统
require_once __DIR__ . '/../core/Autoloader.php';

use Core\Logger\LoggerFactory;
use Core\Logger\LoggerRouter;

LoggerRouter::setContext('api/upload');

$requestLogger = LoggerFactory::getLogger('request');
$auditLogger = LoggerFactory::getLogger('audit');
$errorLogger = LoggerFactory::getLogger('error');

$requestLogger->info('=== 图片上传请求开始 ===', [
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '未知',
    'uri' => $_SERVER['REQUEST_URI'] ?? '',
    'content_type' => $_SERVER['CONTENT_TYPE'] ?? '',
]);

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    $requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']]);

    $auditLogger->warning('图片上传失败：请求方法错误', [
        'reason' => '请求方法错误',
        'method' => $_SERVER['REQUEST_METHOD'],
    ]);

    if (method_exists($requestLogger, 'flush')) {
        $requestLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../core/Database.php';
require_once __DIR__ . '/../core/AuthMiddleware.php';
require_once __DIR__ . '/../core/Response.php';

$errorCodes = require __DIR__ . '/../config/error_codes.php';
$appConfig = require __DIR__ . '/../config/app.php';

// 数据库连接
try {
    $db = Database::connect();
    $requestLogger->debug('数据库连接成功');
} catch (Exception $e) {
    $errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()]);

    $auditLogger->error('图片上传失败：数据库连接失败', [
        'exception' => $e->getMessage(),
        'reason' => '数据库连接失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 1002,
        'message' => '数据库连接失败',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Token 认证（三端通用）
$auth = new AuthMiddleware($db);
try {
    $currentUser = $auth->authenticateAny();
    $username = $currentUser['username'] ?? $currentUser['nickname'] ?? '未知';
    $userType = $currentUser['user_type'] ?? '未知';
    $requestLogger->debug('认证成功', ['user_id' => $currentUser['user_id'], 'user_type' => $userType, 'username' => $username]);
} catch (Exception $e) {
    $errorLogger->error('Token认证失败', ['exception' => $e->getMessage()]);

    $auditLogger->warning('图片上传失败：Token认证失败', [
        'exception' => $e->getMessage(),
        'reason' => 'Token认证失败',
    ]);

    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }

    echo json_encode([
        'code' => 2001,
        'message' => '认证失败',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$fileContent = '';
$fileSize = 0;
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';

// 方式1：multipart/form-data（表单上传）
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $file = $_FILES['image'];
    $requestLogger->debug('表单上传方式', ['name' => $file['name'], 'size' => $file['size'], 'type' => $file['type']]);
    
    $fileContent = file_get_contents($file['tmp_name']);
    $fileSize = $file['size'];
    
    // 通过文件内容检测 MIME 类型
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_buffer($finfo, $fileContent);
    // finfo_close($finfo); // 在 PHP 8.5+ 中已废弃，finfo 对象会自动释放
    
    $requestLogger->debug('文件类型检测', ['detected_type' => $mimeType]);
}
// 方式2：binary（二进制直接上传）
else if (strpos($contentType, 'image/') === 0 || strpos($contentType, 'application/octet-stream') === 0) {
    $requestLogger->debug('二进制上传方式', ['content_type' => $contentType]);
    
    $fileContent = file_get_contents('php://input');
    $fileSize = strlen($fileContent);
    
    if (empty($fileContent)) {
        $requestLogger->warning('文件内容为空');
        $auditLogger->warning('图片上传失败：文件内容为空', [
            'user_id' => $currentUser['user_id'],
            'username' => $username,
            'reason' => '文件内容为空',
        ]);
        
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        
        Response::error('请上传图片文件', $errorCodes['INVALID_PARAMS']);
    }
    
    // 通过文件内容检测 MIME 类型
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_buffer($finfo, $fileContent);
    // finfo_close($finfo); // 在 PHP 8.5+ 中已废弃，finfo 对象会自动释放
    
    $requestLogger->debug('文件类型检测', ['detected_type' => $mimeType]);
}
else {
    $requestLogger->warning('不支持的上传方式', ['content_type' => $contentType]);
    $auditLogger->warning('图片上传失败：不支持的上传方式', [
        'user_id' => $currentUser['user_id'],
        'username' => $username,
        'content_type' => $contentType,
        'reason' => '不支持的上传方式',
    ]);
    
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    Response::error('请上传图片文件（支持 multipart/form-data 或 binary 格式）', $errorCodes['INVALID_PARAMS']);
}

// 验证文件类型
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
if (!in_array($mimeType, $allowedTypes)) {
    $requestLogger->warning('文件类型不允许', ['mimeType' => $mimeType]);
    $auditLogger->warning('图片上传失败：文件类型不允许', [
        'user_id' => $currentUser['user_id'],
        'username' => $username,
        'mimeType' => $mimeType,
        'reason' => '文件类型不允许',
    ]);
    
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    Response::error('只支持上传 JPG、PNG、GIF、WEBP 格式的图片', $errorCodes['INVALID_PARAMS']);
}

// 验证文件大小（限制 5MB）
$maxSize = 5 * 1024 * 1024; // 5MB
if ($fileSize > $maxSize) {
    $requestLogger->warning('文件大小超限', ['fileSize' => $fileSize, 'maxSize' => $maxSize]);
    $auditLogger->warning('图片上传失败：文件大小超限', [
        'user_id' => $currentUser['user_id'],
        'username' => $username,
        'fileSize' => $fileSize,
        'maxSize' => $maxSize,
        'reason' => '文件大小超限',
    ]);
    
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    Response::error('图片大小不能超过 5MB', $errorCodes['INVALID_PARAMS']);
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

// 生成 32 位哈希文件名（MD5）
$hash = md5($fileContent . time() . rand(1000, 9999));
$requestLogger->debug('生成文件名', ['hash' => $hash, 'extension' => $extension]);

// 创建上传目录
$uploadDir = __DIR__ . '/../img';
if (!is_dir($uploadDir)) {
    $requestLogger->debug('创建上传目录', ['dir' => $uploadDir]);
    if (!mkdir($uploadDir, 0755, true)) {
        $errorLogger->error('创建上传目录失败', ['dir' => $uploadDir]);
        $auditLogger->error('图片上传失败：创建上传目录失败', [
            'user_id' => $currentUser['user_id'],
            'username' => $username,
            'dir' => $uploadDir,
            'reason' => '创建上传目录失败',
        ]);
        
        if (method_exists($errorLogger, 'flush')) {
            $errorLogger->flush();
        }
        if (method_exists($auditLogger, 'flush')) {
            $auditLogger->flush();
        }
        
        Response::error('创建上传目录失败', $errorCodes['SYSTEM_ERROR'], 500);
    }
    $requestLogger->info('上传目录创建成功', ['dir' => $uploadDir]);
}

// 目标文件路径
$filename = $hash . '.' . $extension;
$targetPath = $uploadDir . '/' . $filename;
$requestLogger->debug('目标文件路径', ['path' => $targetPath]);

// 保存文件
if (file_put_contents($targetPath, $fileContent) === false) {
    $errorLogger->error('文件保存失败', ['path' => $targetPath]);
    $auditLogger->error('图片上传失败：文件保存失败', [
        'user_id' => $currentUser['user_id'],
        'username' => $username,
        'path' => $targetPath,
        'reason' => '文件保存失败',
    ]);
    
    if (method_exists($errorLogger, 'flush')) {
        $errorLogger->flush();
    }
    if (method_exists($auditLogger, 'flush')) {
        $auditLogger->flush();
    }
    
    Response::error('图片保存失败', $errorCodes['DATABASE_ERROR'], 500);
}
$requestLogger->info('文件保存成功', ['path' => $targetPath, 'size' => $fileSize]);

// 生成完整访问 URL
$website = rtrim($appConfig['website'], '/');
$imageUrl = $website . '/img/' . $filename;
$requestLogger->debug('生成访问URL', ['url' => $imageUrl]);

// 记录审计日志
$auditLogger->notice('图片上传成功', [
    'user_id' => $currentUser['user_id'],
    'username' => $username,
    'user_type' => $userType,
    'filename' => $filename,
    'size' => $fileSize,
    'type' => $mimeType,
    'url' => $imageUrl,
]);

// 刷新日志
if (method_exists($auditLogger, 'flush')) {
    $auditLogger->flush();
}
if (method_exists($requestLogger, 'flush')) {
    $requestLogger->flush();
}

// 记录到upload.log文件
$uploadLogPath = __DIR__ . '/../logs/upload.log';
$uploadLogDir = dirname($uploadLogPath);
if (!is_dir($uploadLogDir)) {
    mkdir($uploadLogDir, 0755, true);
}
$uploadLogEntry = date('Y-m-d H:i:s') . ' - 用户ID: ' . $currentUser['user_id'] . ' - 用户名: ' . $username . ' - 类型: ' . $userType . ' - 文件名: ' . $filename . ' - 大小: ' . $fileSize . ' bytes - 类型: ' . $mimeType . ' - URL: ' . $imageUrl . "\n";
file_put_contents($uploadLogPath, $uploadLogEntry, FILE_APPEND);

// 返回成功响应
Response::success([
    'url' => $imageUrl,
    'filename' => $filename,
    'size' => $fileSize,
    'type' => $mimeType
], '图片上传成功');

