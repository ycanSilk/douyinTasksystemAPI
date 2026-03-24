import re

file_path = r'd:\github\douyinTasksystemAPI\api\b\v1\auth\register.php'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 逐行处理
lines = content.split('\n')
new_lines = []

for i, line in enumerate(lines):
    original_line = line
    
    # 替换各种 logDebug 模式
    if "logDebug('用户名已被占用:" in line:
        line = line.replace("logDebug('用户名已被占用：' . $username)", "$requestLogger->warning('用户名已被占用', ['username' => $username])")
    elif "logDebug('用户名可用:" in line:
        line = line.replace("logDebug('用户名可用：' . $username)", "$requestLogger->debug('用户名可用', ['username' => $username])")
    elif "logDebug('邮箱已被注册:" in line:
        line = line.replace("logDebug('邮箱已被注册：' . $email)", "$requestLogger->warning('邮箱已被注册', ['email' => $email])")
    elif "logDebug('邮箱可用:" in line:
        line = line.replace("logDebug('邮箱可用：' . $email)", "$requestLogger->debug('邮箱可用', ['email' => $email])")
    elif "logDebug('手机号已被注册:" in line:
        line = line.replace("logDebug('手机号已被注册：' . $phone)", "$requestLogger->warning('手机号已被注册', ['phone' => $phone])")
    elif "logDebug('手机号可用:" in line:
        line = line.replace("logDebug('手机号可用：' . $phone)", "$requestLogger->debug('手机号可用', ['phone' => $phone])")
    elif "logDebug('查询 B 端用户最大登录设备数配置')" in line:
        line = line.replace("logDebug('查询 B 端用户最大登录设备数配置')", "$requestLogger->debug('查询 B 端用户最大登录设备数配置')")
    elif "logDebug('B 端用户最大登录设备数:" in line:
        line = line.replace("logDebug('B 端用户最大登录设备数：' . $maxDevices)", "$requestLogger->debug('B 端用户最大登录设备数', ['max_devices' => $maxDevices])")
    elif "logDebug('创建 B 端用户记录')" in line:
        line = line.replace("logDebug('创建 B 端用户记录')", "$requestLogger->debug('创建 B 端用户记录')")
    elif "logDebug('创建 B 端用户结果:" in line:
        line = line.replace("logDebug('创建 B 端用户结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('创建 B 端用户结果', ['success' => $result])")
    elif "logDebug('生成的用户 ID:" in line:
        line = line.replace("logDebug('生成的用户 ID: ' . $userId)", "$requestLogger->debug('生成的用户 ID', ['user_id' => $userId])")
    elif "logDebug('创建钱包结果:" in line:
        line = line.replace("logDebug('创建钱包结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('创建钱包结果', ['success' => $result])")
    elif "logDebug('生成的钱包 ID:" in line:
        line = line.replace("logDebug('生成的钱包 ID: ' . $walletId)", "$requestLogger->debug('生成的钱包 ID', ['wallet_id' => $walletId])")
    elif "logDebug('更新用户记录的钱包 ID')" in line:
        line = line.replace("logDebug('更新用户记录的钱包 ID')", "$requestLogger->debug('更新用户记录的钱包 ID')")
    elif "logDebug('更新钱包 ID 结果:" in line:
        line = line.replace("logDebug('更新钱包 ID 结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('更新钱包 ID 结果', ['success' => $result])")
    elif "logDebug('生成 Token')" in line:
        line = line.replace("logDebug('生成 Token')", "$requestLogger->debug('生成 Token')")
    elif "logDebug('Token 生成成功:" in line:
        line = line.replace("logDebug('Token 生成成功：' . $tokenData['token'])", "$requestLogger->debug('Token 生成成功', ['token' => $tokenData['token']])")
    elif "logDebug('Token 过期时间:" in line:
        line = line.replace("logDebug('Token 过期时间：' . $tokenData['expired_at'])", "$requestLogger->debug('Token 过期时间', ['expired_at' => $tokenData['expired_at']])")
    elif "logDebug('更新用户表的 token 字段')" in line:
        line = line.replace("logDebug('更新用户表的 token 字段')", "$requestLogger->debug('更新用户表的 token 字段')")
    elif "logDebug('更新 token 结果:" in line:
        line = line.replace("logDebug('更新 token 结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('更新 token 结果', ['success' => $result])")
    elif "logDebug('插入配置记录结果:" in line:
        line = line.replace("logDebug('插入配置记录结果：' . ($result ? '成功' : '失败'))", "$requestLogger->debug('插入配置记录结果', ['success' => $result])")
    elif "logDebug('响应数据:" in line:
        line = line.replace("logDebug('响应数据：' . json_encode($responseData))", "")
    elif "logDebug('=== B 端用户注册请求结束 ===')" in line:
        line = line.replace("logDebug('=== B 端用户注册请求结束 ===')", "")
    elif "logDebug('数据库错误:" in line:
        line = line.replace("logDebug('数据库错误：' . $e->getMessage())", "$errorLogger->error('数据库异常', ['message' => $e->getMessage(), 'code' => $e->getCode()])")
    elif "logDebug('SQL 状态:" in line:
        line = ""
    elif "logDebug('系统错误:" in line:
        line = line.replace("logDebug('系统错误：' . $e->getMessage())", "$errorLogger->error('系统异常', ['message' => $e->getMessage()])")
    
    new_lines.append(line)
    if original_line != line:
        print(f"行 {i+1}: 已替换")

content = '\n'.join(new_lines)
content = content.replace('exit;;', 'exit;')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("\n完成!")
