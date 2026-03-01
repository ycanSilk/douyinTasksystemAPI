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

header('Content-Type: application/json; charset=utf-8');

// 只允许 POST 请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
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
$db = Database::connect();

// Token 认证（三端通用）
$auth = new AuthMiddleware($db);
$currentUser = $auth->authenticateAny();

$fileContent = '';
$fileSize = 0;
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';

// 方式1：multipart/form-data（表单上传）
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $file = $_FILES['image'];
    $fileContent = file_get_contents($file['tmp_name']);
    $fileSize = $file['size'];
    
    // 通过文件内容检测 MIME 类型
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_buffer($finfo, $fileContent);
    finfo_close($finfo);
}
// 方式2：binary（二进制直接上传）
else if (strpos($contentType, 'image/') === 0 || strpos($contentType, 'application/octet-stream') === 0) {
    $fileContent = file_get_contents('php://input');
    $fileSize = strlen($fileContent);
    
    if (empty($fileContent)) {
        Response::error('请上传图片文件', $errorCodes['INVALID_PARAMS']);
    }
    
    // 通过文件内容检测 MIME 类型
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_buffer($finfo, $fileContent);
    finfo_close($finfo);
}
else {
    Response::error('请上传图片文件（支持 multipart/form-data 或 binary 格式）', $errorCodes['INVALID_PARAMS']);
}

// 验证文件类型
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
if (!in_array($mimeType, $allowedTypes)) {
    Response::error('只支持上传 JPG、PNG、GIF、WEBP 格式的图片', $errorCodes['INVALID_PARAMS']);
}

// 验证文件大小（限制 5MB）
$maxSize = 5 * 1024 * 1024; // 5MB
if ($fileSize > $maxSize) {
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

// 创建上传目录
$uploadDir = __DIR__ . '/../img';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// 目标文件路径
$filename = $hash . '.' . $extension;
$targetPath = $uploadDir . '/' . $filename;

// 保存文件
if (file_put_contents($targetPath, $fileContent) === false) {
    Response::error('图片保存失败', $errorCodes['DATABASE_ERROR'], 500);
}

// 生成完整访问 URL
$website = rtrim($appConfig['website'], '/');
$imageUrl = $website . '/img/' . $filename;

// 返回成功响应
Response::success([
    'url' => $imageUrl,
    'filename' => $filename,
    'size' => $fileSize,
    'type' => $mimeType
], '图片上传成功');

