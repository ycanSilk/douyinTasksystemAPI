<?php
/**
 * WebSocket 审核任务通知服务端
 * 用于实时推送审核任务通知到前端
 */

// 检查是否在命令行模式下运行
if (php_sapi_name() === 'cli') {
    // 命令行模式，直接启动 WebSocket 服务器
} else {
    // 允许所有跨域请求
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');

    // 如果是 OPTIONS 请求，直接返回
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        exit(0);
    }

    // 检查是否是 WebSocket 连接请求
    if (!isset($_SERVER['HTTP_UPGRADE']) || $_SERVER['HTTP_UPGRADE'] !== 'websocket') {
        http_response_code(400);
        echo '不是 WebSocket 请求';
        exit(0);
    }
}

// WebSocket 服务器类
class WebSocketServer {
    private $server;
    private $clients = [];
    private $lastTaskCheckTime = 0;
    private $checkInterval = 60; // 检查间隔（秒）
    
    public function __construct() {
        // 创建 WebSocket 服务器
        $this->server = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
        if (!$this->server) {
            die('Could not create socket: ' . socket_strerror(socket_last_error()));
        }
        
        // 设置 socket 选项
        socket_set_option($this->server, SOL_SOCKET, SO_REUSEADDR, 1);
        
        // 绑定到本地地址和端口
        $address = '0.0.0.0';
        $port = 8080;
        
        if (!socket_bind($this->server, $address, $port)) {
            die('绑定 socket 失败: ' . socket_strerror(socket_last_error()));
        }
        
        // 开始监听
        if (!socket_listen($this->server, 5)) {
            die('监听 socket 失败: ' . socket_strerror(socket_last_error()));
        }
        
        echo "WebSocket server started on ws://$address:$port\n";
        $this->run();
    }
    
    private function run() {
        while (true) {
            // 准备监听的 socket
            $readSockets = array_merge([$this->server], $this->clients);
            $writeSockets = [];
            $errorSockets = [];
            
            // 使用 select 函数监听 socket 活动
            $activity = socket_select($readSockets, $writeSockets, $errorSockets, 1);
            
            if ($activity === false) {
                echo 'Select 错误: ' . socket_strerror(socket_last_error()) . "\n";
                continue;
            }
            
            // 处理新的连接
            if (in_array($this->server, $readSockets)) {
                $client = socket_accept($this->server);
                if ($client) {
                    // 进行 WebSocket 握手
                    $this->performHandshake($client);
                    $this->clients[] = $client;
                    echo "New client connected\n";
                }
                // 从 readSockets 中移除服务器 socket
                $key = array_search($this->server, $readSockets);
                unset($readSockets[$key]);
            }
            
            // 处理客户端消息
            foreach ($readSockets as $client) {
                // 尝试读取数据，捕获可能的错误
                $data = @socket_read($client, 1024);
                
                if ($data === false || $data === '') {
                    // 客户端断开连接
                    $key = array_search($client, $this->clients);
                    if ($key !== false) {
                        unset($this->clients[$key]);
                        socket_close($client);
                        echo "连接断开\n";
                    }
                    continue;
                }
                
                // 处理 WebSocket 消息
                $message = $this->decodeMessage($data);
                if ($message) {
                    echo "收到消息: $message\n";
                }
            }
            
            // 定期检查审核任务
            $currentTime = time();
            if ($currentTime - $this->lastTaskCheckTime >= $this->checkInterval) {
                $this->checkAuditTasks();
                $this->lastTaskCheckTime = $currentTime;
            }
        }
    }
    
    private function performHandshake($client) {
        // 读取客户端请求
        $request = socket_read($client, 1024);
        
        // 提取 Sec-WebSocket-Key
        if (preg_match('/Sec-WebSocket-Key: (.*)\r\n/', $request, $matches)) {
            $key = $matches[1];
            
            // 生成 Sec-WebSocket-Accept
            $acceptKey = base64_encode(sha1($key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', true));
            
            // 构建握手响应
            $response = "HTTP/1.1 101 Switching Protocols\r\n";
            $response .= "Upgrade: websocket\r\n";
            $response .= "Connection: Upgrade\r\n";
            $response .= "Sec-WebSocket-Accept: $acceptKey\r\n\r\n";
            
            // 发送响应
            socket_write($client, $response, strlen($response));
        } else {
            // 无法提取 Sec-WebSocket-Key，关闭连接
            echo "提取 Sec-WebSocket-Key 失败\n";
            socket_close($client);
        }
    }
    
    private function decodeMessage($data) {
        $length = ord($data[1]) & 127;
        if ($length == 126) {
            $masks = substr($data, 4, 4);
            $data = substr($data, 8);
        } elseif ($length == 127) {
            $masks = substr($data, 10, 4);
            $data = substr($data, 14);
        } else {
            $masks = substr($data, 2, 4);
            $data = substr($data, 6);
        }
        
        $message = '';
        for ($i = 0; $i < strlen($data); $i++) {
            $message .= $data[$i] ^ $masks[$i % 4];
        }
        
        return $message;
    }
    
    private function encodeMessage($message) {
        $length = strlen($message);
        
        if ($length <= 125) {
            $header = chr(129) . chr($length);
        } elseif ($length <= 65535) {
            $header = chr(129) . chr(126) . pack('n', $length);
        } else {
            $header = chr(129) . chr(127) . pack('Q', $length);
        }
        
        return $header . $message;
    }
    
    private function checkAuditTasks() {
        try {
            // 调用 detect.php 接口获取真实的审核任务数据
            // 使用正确的HTTP服务器端口（8000）
            $url = 'http://localhost:8000/task_admin/api/admin_notifications/detect.php';
            
            // 添加WebSocket服务器标识
            $url .= '?ws_server=true';
            
            echo "Calling detect.php at: $url\n";
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 10);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // 禁用 SSL 验证
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); // 禁用 SSL 主机验证
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true); // 跟随重定向
            curl_setopt($ch, CURLOPT_PROXY, ''); // 禁用代理
            curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_HTTP); // 确保使用HTTP代理类型
            
            // 添加详细的调试信息
            curl_setopt($ch, CURLOPT_VERBOSE, true);
            $verbose = fopen('php://temp', 'w+');
            curl_setopt($ch, CURLOPT_STDERR, $verbose);
            
            $response = curl_exec($ch);
            
            // 检查curl错误
            if (curl_errno($ch)) {
                echo 'cURL error: ' . curl_error($ch) . "\n";
            }
            
            // 输出详细的调试信息
            rewind($verbose);
            $verboseLog = stream_get_contents($verbose);
            echo "cURL verbose log: $verboseLog\n";
            fclose($verbose);
            
            // 移除 curl_close() 调用，因为在 PHP 8.0+ 中它已无效果
            // curl_close($ch);
            
            echo "从 detect.php 收到响应: $response\n";
            
            if ($response) {
                $data = json_decode($response, true);
                
                if (json_last_error() !== JSON_ERROR_NONE) {
                    echo 'JSON decode error: ' . json_last_error_msg() . "\n";
                }
                
                if (isset($data['code']) && $data['code'] === 0 && isset($data['data']['detection_result'])) {
                    $detectionResult = $data['data']['detection_result'];
                    
                    echo "Detection result: " . print_r($detectionResult, true) . "\n";
                    
                    // 检查是否有审核任务（使用英文key）
                    $hasTasks = false;
                    $checkFields = ['recharge', 'withdraw', 'agent', 'magnifier'];
                    
                    echo "开始检查审核任务...\n";
                    echo "检测字段列表: " . implode(', ', $checkFields) . "\n";
                    
                    foreach ($checkFields as $field) {
                        $fieldValue = isset($detectionResult[$field]) ? $detectionResult[$field] : 'not set';
                        echo "检查字段: $field, 值: $fieldValue\n";
                        
                        if (isset($detectionResult[$field]) && $detectionResult[$field] > 0) {
                            $hasTasks = true;
                            echo "✅ 检测到审核任务: $field = " . $detectionResult[$field] . "\n";
                        }
                    }
                    
                    echo "是否有审核任务: " . ($hasTasks ? '是' : '否') . "\n";
                    
                    // 只有当有审核任务时才推送通知
                    if ($hasTasks) {
                        // 构建通知消息
                        $notification = [
                            'type' => 'audit_notification',
                            'data' => [
                                'detection_result' => $detectionResult
                            ]
                        ];
                        
                        // 序列化消息
                        $message = json_encode($notification);
                        
                        // 发送给所有客户端
                        foreach ($this->clients as $client) {
                            $encodedMessage = $this->encodeMessage($message);
                            socket_write($client, $encodedMessage, strlen($encodedMessage));
                        }
                        
                        echo "Sent audit notification: $message\n";
                    } else {
                        echo "No audit tasks to notify\n";
                    }
                } else {
                    echo "Invalid response from detect.php: $response\n";
                }
            } else {
                echo "Failed to get response from detect.php\n";
            }
        } catch (Exception $e) {
            echo 'Error checking audit tasks: ' . $e->getMessage() . "\n";
        }
    }
}

// 启动 WebSocket 服务器
try {
    new WebSocketServer();
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage() . "\n";
}
