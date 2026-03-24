file_path = r'd:\github\douyinTasksystemAPI\api\b\v1\auth\register.php'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 替换剩余的 logDebug 和 Response 调用
replacements = [
    ("logDebug('检查用户名是否已存在')", "$requestLogger->debug('检查用户名是否已存在', ['username' => $username])"),
    ("logDebug('用户名已被占用：' . $username)", "$requestLogger->warning('用户名已被占用', ['username' => $username])"),
    ("Response::error('用户名已被占用', $errorCodes['USER_USERNAME_EXISTS'])", "echo json_encode(['code' => 2007, 'message' => '用户名已被占用', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);\n        exit;"),
    ("logDebug('用户名可用：' . $username)", "$requestLogger->debug('用户名可用', ['username' => $username])"),
    
    ("logDebug('检查邮箱是否已存在')", "$requestLogger->debug('检查邮箱是否已存在', ['email' => $email])"),
    ("logDebug('邮箱已被注册：' . $email)", "$requestLogger->warning('邮箱已被注册', ['email' => $email])"),
    ("Response::error('邮箱已被注册', $errorCodes['USER_EMAIL_EXISTS'])", "echo json_encode(['code' => 2008, 'message' => '邮箱已被注册', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);\n        exit;"),
    ("logDebug('邮箱可用：' . $email)", "$requestLogger->debug('邮箱可用', ['email' => $email])"),
    
    ("logDebug('检查手机号是否已存在')", "$requestLogger->debug('检查手机号是否已存在', ['phone' => $phone])"),
    ("logDebug('手机号已被注册：' . $phone)", "$requestLogger->warning('手机号已被注册', ['phone' => $phone])"),
    ("Response::error('手机号已被注册', $errorCodes['USER_PHONE_EXISTS'])", "echo json_encode(['code' => 2009, 'message' => '手机号已被注册', 'data' => [], 'timestamp' => time()], JSON_UNESCAPED_UNICODE);\n            exit;"),
    ("logDebug('手机号可用：' . $phone)", "$requestLogger->debug('手机号可用', ['phone' => $phone])"),
    
    ("logDebug('开启事务')", "$requestLogger->debug('开启数据库事务')"),
    ("logDebug('生成密码哈希')", "$requestLogger->debug('生成密码哈希')"),
    ("logDebug('查询 B 端用户最大登录设备数配置')", "$requestLogger->debug('查询 B 端用户最大登录设备数配置')"),
    ("logDebug('B 端用户最大登录设备数：' . $maxDevices)", "$requestLogger->debug('B 端用户最大登录设备数', ['max_devices' => $maxDevices])"),
    
    ("logDebug('创建 B 端用户记录')", "$requestLogger->debug('创建 B 端用户记录')"),
    ("logDebug('创建 B 端用户结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('创建 B 端用户结果', ['success' => $result])"),
    ("logDebug('生成的用户 ID: ' . $userId)", "$requestLogger->debug('生成的用户 ID', ['user_id' => $userId])"),
    
    ("logDebug('创建钱包记录')", "$requestLogger->debug('创建钱包记录')"),
    ("logDebug('创建钱包结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('创建钱包结果', ['success' => $result])"),
    ("logDebug('生成的钱包 ID: ' . $walletId)", "$requestLogger->debug('生成的钱包 ID', ['wallet_id' => $walletId])"),
    
    ("logDebug('更新用户记录的钱包 ID')", "$requestLogger->debug('更新用户记录的钱包 ID')"),
    ("logDebug('更新钱包 ID 结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('更新钱包 ID 结果', ['success' => $result])"),
    
    ("logDebug('生成 Token')", "$requestLogger->debug('生成 Token')"),
    ("logDebug('Token 生成成功：' . $tokenData['token'])", "$requestLogger->debug('Token 生成成功', ['token' => $tokenData['token']])"),
    ("logDebug('Token 过期时间：' . $tokenData['expired_at'])", "$requestLogger->debug('Token 过期时间', ['expired_at' => $tokenData['expired_at']])"),
    
    ("logDebug('更新用户表的 token 字段')", "$requestLogger->debug('更新用户表的 token 字段')"),
    ("logDebug('更新 token 结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('更新 token 结果', ['success' => $result])"),
    
    ("logDebug('插入快捷派单配置记录')", "$requestLogger->debug('插入快捷派单配置记录')"),
    ("logDebug('插入配置记录结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('插入配置记录结果', ['success' => $result])"),
    
    ("logDebug('提交事务')", "$requestLogger->debug('提交数据库事务')"),
    ("logDebug('事务提交成功')", "$requestLogger->debug('事务提交成功')"),
    
    ("logDebug('返回成功响应')", "$requestLogger->info('B 端用户注册成功', ['user_id' => $userId, 'username' => $username])"),
    ("logDebug('响应数据：' . json_encode($responseData))", ""),
    ("Response::success($responseData, '注册成功')", "echo json_encode([\n        'code' => 0,\n        'message' => '注册成功',\n        'data' => $responseData,\n        'timestamp' => time()\n    ], JSON_UNESCAPED_UNICODE);\n    exit;"),
    ("logDebug('=== B 端用户注册请求结束 ===')", ""),
    
    # 异常处理
    ("logDebug('回滚事务')", "$requestLogger->debug('回滚数据库事务')"),
    ("logDebug('数据库错误：' . $e->getMessage())", "$errorLogger->error('数据库异常', ['message' => $e->getMessage(), 'code' => $e->getCode()])"),
    ("logDebug('SQL 状态：' . $e->getCode())", ""),
    ("Response::error('注册失败', $errorCodes['DATABASE_ERROR'], 500)", "echo json_encode([\n        'code' => 5001,\n        'message' => '注册失败',\n        'data' => [],\n        'timestamp' => time()\n    ], JSON_UNESCAPED_UNICODE);\n    exit;"),
    
    ("logDebug('系统错误：' . $e->getMessage())", "$errorLogger->error('系统异常', ['message' => $e->getMessage()])"),
    ("Response::error('注册失败', $errorCodes['SYSTEM_ERROR'], 500)", "echo json_encode([\n        'code' => 5002,\n        'message' => '注册失败',\n        'data' => [],\n        'timestamp' => time()\n    ], JSON_UNESCAPED_UNICODE);\n    exit;"),
]

count = 0
for old, new in replacements:
    if old in content:
        content = content.replace(old, new)
        count += 1
        print(f"已替换：{old[:50]}...")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"\n完成！共替换 {count} 处")
