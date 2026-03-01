<?php
/**
 * 短信服务配置文件
 */

return [
    // 阿里云 AccessKey
    'accessKeyId' => 'LTAI5tAgw2FJRKhdqG8vdTBK',
    'accessKeySecret' => '5k8lzCabexPeW9V6lZvsOVFYCFdev4',
    
    // 短信服务配置
    'sms' => [
        'signName' => '速通互联验证码',
        'templateCode' => '100001',
        'endpoint' => 'dypnsapi.aliyuncs.com'
    ]
];
