<?php
/**
 * 自动加载器
 * 
 * PSR-4 标准的自动加载器
 */

spl_autoload_register(function ($class) {
    // 项目命名空间前缀
    $baseNamespace = 'Core\\';
    
    // 检查是否是我们要加载的命名空间
    if (strpos($class, $baseNamespace) === 0) {
        // 将命名空间转换为文件路径
        $relativeClass = substr($class, strlen($baseNamespace));
        $file = __DIR__ . '/' . str_replace('\\', '/', $relativeClass) . '.php';
        
        // 如果文件存在，就加载它
        if (file_exists($file)) {
            require $file;
            return true;
        }
    }
    
    return false;
});
