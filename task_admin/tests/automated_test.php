<?php
/**
 * 自动化测试脚本
 * 用于验证所有新增功能
 */

require_once __DIR__ . '/../auth/AuthMiddleware.php';
require_once __DIR__ . '/../../core/Database.php';

class AutomatedTest {
    private $pdo;
    private $testResults = [];
    private $baseUrl = 'http://localhost/task_admin';
    
    public function __construct() {
        $this->pdo = Database::connect();
    }
    
    /**
     * 运行所有测试
     */
    public function runAllTests() {
        echo "====================================\n";
        echo "TaskSystem 自动化测试\n";
        echo "====================================\n\n";
        
        // 运行系统用户管理测试
        $this->testSystemUsers();
        
        // 运行角色管理测试
        $this->testSystemRoles();
        
        // 运行权限管理测试
        $this->testSystemPermissions();
        
        // 运行充值管理测试
        $this->testRechargeManagement();
        
        // 运行提现管理测试
        $this->testWithdrawManagement();
        
        // 运行放大镜任务管理测试
        $this->testMagnifierTasks();
        
        // 运行统计面板测试
        $this->testStatistics();
        
        // 运行认证测试
        $this->testAuthentication();
        
        // 输出测试结果
        $this->outputTestResults();
    }
    
    /**
     * 系统用户管理测试
     */
    private function testSystemUsers() {
        echo "运行系统用户管理测试...\n";
        
        // 测试1: 获取系统用户列表
        $this->testCase('系统用户列表', function() {
            $url = $this->baseUrl . '/api/system_users/list.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 创建系统用户
        $this->testCase('创建系统用户', function() {
            $url = $this->baseUrl . '/api/system_users/create.php';
            $data = [
                'username' => 'test_user_' . time(),
                'password' => 'test123',
                'email' => 'test_' . time() . '@example.com',
                'role_id' => 1
            ];
            $response = $this->sendRequest('POST', $url, $data);
            $result = json_decode($response, true);
            return isset($result['code']) && $result['code'] == 0;
        });
        
        echo "\n";
    }
    
    /**
     * 角色管理测试
     */
    private function testSystemRoles() {
        echo "运行角色管理测试...\n";
        
        // 测试1: 获取角色列表
        $this->testCase('角色列表', function() {
            $url = $this->baseUrl . '/api/system_roles/list.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 创建角色
        $this->testCase('创建角色', function() {
            $url = $this->baseUrl . '/api/system_roles/create.php';
            $data = [
                'name' => '测试角色_' . time(),
                'description' => '测试角色描述'
            ];
            $response = $this->sendRequest('POST', $url, $data);
            $result = json_decode($response, true);
            return isset($result['code']) && $result['code'] == 0;
        });
        
        echo "\n";
    }
    
    /**
     * 权限管理测试
     */
    private function testSystemPermissions() {
        echo "运行权限管理测试...\n";
        
        // 测试1: 获取权限列表
        $this->testCase('权限列表', function() {
            $url = $this->baseUrl . '/api/system_permissions/list.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 创建权限
        $this->testCase('创建权限', function() {
            $url = $this->baseUrl . '/api/system_permissions/create.php';
            $data = [
                'name' => '测试权限_' . time(),
                'code' => 'test_permission_' . time(),
                'description' => '测试权限描述'
            ];
            $response = $this->sendRequest('POST', $url, $data);
            $result = json_decode($response, true);
            return isset($result['code']) && $result['code'] == 0;
        });
        
        echo "\n";
    }
    
    /**
     * 充值管理测试
     */
    private function testRechargeManagement() {
        echo "运行充值管理测试...\n";
        
        // 测试1: 获取充值列表
        $this->testCase('充值列表', function() {
            $url = $this->baseUrl . '/api/recharge/list.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 导出充值记录
        $this->testCase('导出充值记录', function() {
            $url = $this->baseUrl . '/api/recharge/export.php';
            $response = $this->sendRequest('GET', $url);
            return strlen($response) > 0;
        });
        
        echo "\n";
    }
    
    /**
     * 提现管理测试
     */
    private function testWithdrawManagement() {
        echo "运行提现管理测试...\n";
        
        // 测试1: 获取提现列表
        $this->testCase('提现列表', function() {
            $url = $this->baseUrl . '/api/withdraw/list.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 导出提现记录
        $this->testCase('导出提现记录', function() {
            $url = $this->baseUrl . '/api/withdraw/export.php';
            $response = $this->sendRequest('GET', $url);
            return strlen($response) > 0;
        });
        
        echo "\n";
    }
    
    /**
     * 放大镜任务管理测试
     */
    private function testMagnifierTasks() {
        echo "运行放大镜任务管理测试...\n";
        
        // 测试1: 获取放大镜任务列表
        $this->testCase('放大镜任务列表', function() {
            $url = $this->baseUrl . '/api/magnifier/list.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 获取放大镜任务详情
        $this->testCase('放大镜任务详情', function() {
            $url = $this->baseUrl . '/api/magnifier/detail.php?id=1';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']);
        });
        
        echo "\n";
    }
    
    /**
     * 统计面板测试
     */
    private function testStatistics() {
        echo "运行统计面板测试...\n";
        
        // 测试1: 获取统计数据
        $this->testCase('统计面板数据', function() {
            $url = $this->baseUrl . '/api/stats/dashboard.php';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        // 测试2: 带时间范围的统计数据
        $this->testCase('带时间范围的统计数据', function() {
            $url = $this->baseUrl . '/api/stats/dashboard.php?timeRange=7d';
            $response = $this->sendRequest('GET', $url);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 0;
        });
        
        echo "\n";
    }
    
    /**
     * 认证测试
     */
    private function testAuthentication() {
        echo "运行认证测试...\n";
        
        // 测试1: 登录功能
        $this->testCase('登录功能', function() {
            $url = $this->baseUrl . '/auth/login.php';
            $data = [
                'username' => 'task',
                'password' => 'taskplatformMVP'
            ];
            $response = $this->sendRequest('POST', $url, $data);
            $result = json_decode($response, true);
            return isset($result['code']) && $result['code'] == 0;
        });
        
        // 测试2: 无效Token认证
        $this->testCase('无效Token认证', function() {
            $url = $this->baseUrl . '/api/system_users/list.php';
            $headers = [
                'Authorization: Bearer invalid_token'
            ];
            $response = $this->sendRequest('GET', $url, [], $headers);
            $data = json_decode($response, true);
            return isset($data['code']) && $data['code'] == 401;
        });
        
        echo "\n";
    }
    
    /**
     * 执行测试用例
     */
    private function testCase($name, callable $test) {
        try {
            $result = $test();
            $status = $result ? '通过' : '失败';
            $this->testResults[] = [
                'name' => $name,
                'status' => $status,
                'error' => $result ? '' : '测试失败'
            ];
            echo "[{$status}] {$name}\n";
        } catch (Exception $e) {
            $this->testResults[] = [
                'name' => $name,
                'status' => '失败',
                'error' => $e->getMessage()
            ];
            echo "[失败] {$name} - {$e->getMessage()}\n";
        }
    }
    
    /**
     * 发送HTTP请求
     */
    private function sendRequest($method, $url, $data = [], $headers = []) {
        $ch = curl_init();
        
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            $headers[] = 'Content-Type: application/json';
        }
        
        if (!empty($headers)) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        }
        
        $response = curl_exec($ch);
        
        if (curl_errno($ch)) {
            throw new Exception('CURL错误: ' . curl_error($ch));
        }
        
        curl_close($ch);
        return $response;
    }
    
    /**
     * 输出测试结果
     */
    private function outputTestResults() {
        echo "====================================\n";
        echo "测试结果汇总\n";
        echo "====================================\n";
        
        $passed = 0;
        $failed = 0;
        
        foreach ($this->testResults as $result) {
            if ($result['status'] === '通过') {
                $passed++;
            } else {
                $failed++;
            }
        }
        
        echo "总测试用例: " . count($this->testResults) . "\n";
        echo "通过: " . $passed . "\n";
        echo "失败: " . $failed . "\n";
        
        if ($failed > 0) {
            echo "\n失败的测试用例:\n";
            foreach ($this->testResults as $result) {
                if ($result['status'] === '失败') {
                    echo "- {$result['name']}: {$result['error']}\n";
                }
            }
        }
        
        echo "\n====================================\n";
        echo "测试完成！\n";
        echo "====================================\n";
    }
}

// 运行测试
$test = new AutomatedTest();
$test->runAllTests();
?>