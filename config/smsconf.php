<?php
/**
 * 短信服务配置文件
 */

return [
    // 阿里云 AccessKey
    'accessKeyId' => '你的keyid',
    'accessKeySecret' => 'accessKeySecret',
    
    // 短信服务配置
    'sms' => [
        'signName' => '速通互联验证码',
        'templateCode' => '100001',
        'endpoint' => 'dypnsapi.aliyuncs.com'
    ]
];
