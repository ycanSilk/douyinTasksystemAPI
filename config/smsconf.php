<?php
/**
 * 短信服务配置文件
 */

return [
    // 阿里云 AccessKey
    'accessKeyId' => 'LTAI5tFKSCQ1U6qfh6ehNnx9',
    'accessKeySecret' => '3yseBDJDdmWALvdEnvKzKFjMI74uav',
    
    // 短信服务配置
    'sms' => [
        'signName' => '速通互联验证码',
        'templateCode' => '100001',
        'endpoint' => 'dypnsapi.aliyuncs.com'
    ]
];
