<?php
/**
 * Admin 图片上传接口
 * POST /task_admin/api/upload.php
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, X-Token, Authorization');



// 处理OPTIONS预检请求
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'code' => 1001,
        'message' => '请求方法错误',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

require_once __DIR__ . '/../auth/AuthMiddleware.php';

// 验证 Admin 登录
AdminAuthMiddleware::authenticate();

$appConfig = require __DIR__ . '/../../config/app.php';

$fileContent = '';
$fileSize = 0;
$file = null;

// 支持 multipart/form-data 上传，兼容 'image' 和 'file' 两种字段名
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $file = $_FILES['image'];
} elseif (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
    $file = $_FILES['file'];
}

if ($file) {
    $fileContent = file_get_contents($file['tmp_name']);
    $fileSize = $file['size'];
    
    // 检测 MIME 类型
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_buffer($finfo, $fileContent);
    finfo_close($finfo);
} else {
    http_response_code(400);
    echo json_encode([
        'code' => 1002,
        'message' => '请上传图片文件（支持字段名：image 或 file）',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 验证文件类型
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
if (!in_array($mimeType, $allowedTypes)) {
    http_response_code(400);
    echo json_encode([
        'code' => 1003,
        'message' => '只支持上传 JPG、PNG、GIF、WEBP 格式的图片',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 验证文件大小（限制 5MB）
$maxSize = 5 * 1024 * 1024;
if ($fileSize > $maxSize) {
    http_response_code(400);
    echo json_encode([
        'code' => 1004,
        'message' => '图片大小不能超过 5MB',
        'data' => [],
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

// 生成 MD5 哈希文件名
$hash = md5($fileContent . time() . rand(1000, 9999));

// 创建上传目录
$uploadDir = __DIR__ . '/../../img';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// 目标文件路径
$filename = $hash . '.' . $extension;
$targetPath = $uploadDir . '/' . $filename;

// 保存文件
if (file_put_contents($targetPath, $fileContent) === false) {
    http_response_code(500);
    echo json_encode([
        'code' => 5000,
        'message' => '图片保存失败',
        'data' => [],
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// 生成完整访问 URL
$website = rtrim($appConfig['website'], '/');
$imageUrl = $website . '/img/' . $filename;

// 返回成功响应
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
