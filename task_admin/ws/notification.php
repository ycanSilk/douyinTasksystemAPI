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
    private $checkInterval = 10; // 检查间隔（秒）
    
    private function log($message) {
        // 获取当前日期，格式为 YYYYMMDD
        $date = date('Ymd');
        // 日志目录
        $logDir = __DIR__ . '/socket-log';
        // 确保日志目录存在
        if (!is_dir($logDir)) {
            mkdir($logDir, 0777, true);
        }
        // 日志文件路径
        $logFile = $logDir . "/$date.log";
        
        $timestamp = date('Y-m-d H:i:s');
        $logMessage = "[$timestamp] $message\n";
        
        // 打开并写入日志文件
        $file = fopen($logFile, 'a');
        if ($file) {
            fwrite($file, $logMessage);
            fflush($file);
            fclose($file);
        }
        
        // 同时输出到控制台
        echo $logMessage;
    }
    
    public function __destruct() {
        // 不需要关闭文件，每次写入都会关闭
    }
    
    public function __construct() {
        $this->log('WebSocket服务器启动中...');
        
        // 创建 WebSocket 服务器
        $this->server = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
        if (!$this->server) {
            $this->log('Could not create socket: ' . socket_strerror(socket_last_error()));
            die('Could not create socket: ' . socket_strerror(socket_last_error()));
        }
        
        // 设置 socket 选项
        socket_set_option($this->server, SOL_SOCKET, SO_REUSEADDR, 1);
        
        // 绑定到本地地址和端口
        $address = '0.0.0.0';
        $port = 9999;
        
        if (!socket_bind($this->server, $address, $port)) {
            $this->log('绑定 socket 失败: ' . socket_strerror(socket_last_error()));
            die('绑定 socket 失败: ' . socket_strerror(socket_last_error()));
        }
        
        // 开始监听
        if (!socket_listen($this->server, 10)) {
            $this->log('监听 socket 失败: ' . socket_strerror(socket_last_error()));
            die('监听 socket 失败: ' . socket_strerror(socket_last_error()));
        }
        
        $this->log("WebSocket server started on ws://$address:$port");
        $this->run();
    }
    
    private function run() {
        while (true) {
            // 清理已关闭的客户端连接
            $this->cleanClosedConnections();
            
            // 准备监听的 socket
            $readSockets = array_merge([$this->server], $this->clients);
            $writeSockets = [];
            $errorSockets = [];
            
            // 使用 select 函数监听 socket 活动
            $activity = socket_select($readSockets, $writeSockets, $errorSockets, 1);
            
            if ($activity === false) {
                $this->log('Select 错误: ' . socket_strerror(socket_last_error()));
                continue;
            }
            
            // 处理新的连接
            if (in_array($this->server, $readSockets)) {
                $client = socket_accept($this->server);
                if ($client) {
                    // 进行 WebSocket 握手
                    $this->performHandshake($client);
                    $this->clients[] = $client;
                    $this->log("New client connected. Total clients: " . count($this->clients));
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
                        @socket_close($client);
                        $this->log("连接断开. Total clients: " . count($this->clients));
                    }
                    continue;
                }
                
                try {
                    // 处理 WebSocket 消息
                    $message = $this->decodeMessage($data);
                    if ($message) {
                        $this->log("收到消息: $message");
                    }
                } catch (Exception $e) {
                    $this->log('处理消息错误: ' . $e->getMessage());
                    // 不关闭连接，继续处理
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
            $this->log("提取 Sec-WebSocket-Key 失败");
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
    
    private function cleanClosedConnections() {
        // 清理已关闭的客户端连接
        $validClients = [];
        foreach ($this->clients as $client) {
            // 检查连接是否有效
            $socketInfo = @socket_getpeername($client, $address, $port);
            if ($socketInfo !== false) {
                $validClients[] = $client;
            } else {
                // 连接已关闭，清理
                @socket_close($client);
            }
        }
        
        if (count($this->clients) !== count($validClients)) {
            $removedCount = count($this->clients) - count($validClients);
            $this->log("清理已关闭的客户端连接，移除了 $removedCount 个连接");
            $this->clients = $validClients;
        }
    }
    
    private function checkAuditTasks() {
        try {
            // 调用 detect.php 接口获取真实的审核任务数据
            $url = 'http://localhost:28806/task_admin/api/admin_notifications/detect.php';
            
            // 添加WebSocket服务器标识
            $url .= '?ws_server=true';
            
            $this->log("调用 detect.php 接口获取审核任务数据");
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 10);
            curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_PROXY, '');
            curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_HTTP);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_NOBODY, false);
            
            $response = curl_exec($ch);
            
            // 检查curl错误
            if (curl_errno($ch)) {
                $this->log('cURL error: ' . curl_error($ch));
                return;
            }
            
            $this->log("从 detect.php 收到响应: " . var_export($response, true));
            
            if ($response !== false) {
                $data = json_decode($response, true);
                
                if (json_last_error() !== JSON_ERROR_NONE) {
                    $this->log('JSON decode error: ' . json_last_error_msg());
                    return;
                }
                
                if (isset($data['code']) && $data['code'] === 0 && isset($data['data']['detection_result'])) {
                    $detectionResult = $data['data']['detection_result'];
                    
                    $this->log("检测结果: " . json_encode($detectionResult));
                    
                    // 推送通知给所有客户端
                    $notification = [
                        'type' => 'audit_notification',
                        'data' => [
                            'detection_result' => $detectionResult
                        ]
                    ];
                    
                    $message = json_encode($notification);
                    
                    // 发送给所有客户端
                    foreach ($this->clients as $client) {
                        try {
                            $encodedMessage = $this->encodeMessage($message);
                            socket_write($client, $encodedMessage, strlen($encodedMessage));
                        } catch (Exception $e) {
                            $this->log('发送消息错误: ' . $e->getMessage());
                            // 不中断循环，继续发送给其他客户端
                        }
                    }
                    
                    $this->log("推送通知给 " . count($this->clients) . " 个客户端");
                } else {
                    $this->log("Invalid response from detect.php: " . json_encode($data));
                    // 检查是否是数据库连接失败
                    if (isset($data['code']) && $data['code'] == 1002) {
                        $this->log("数据库连接失败，跳过本次检测");
                    }
                }
            } else {
                $this->log("Failed to get response from detect.php");
            }
        } catch (Exception $e) {
            $this->log('Error checking audit tasks: ' . $e->getMessage());
        }
    }
}

// 启动 WebSocket 服务器
try {
    new WebSocketServer();
} catch (Exception $e) {
    $errorMessage = 'Error: ' . $e->getMessage();
    echo $errorMessage . "\n";
    // 尝试写入到日志文件
    $logFile = fopen('socket-log.log', 'a');
    if ($logFile) {
        $timestamp = date('Y-m-d H:i:s');
        fwrite($logFile, "[$timestamp] $errorMessage\n");
        fclose($logFile);
    }
}
