import re

file_path = r'd:\github\douyinTasksystemAPI\api\c\v1\tasks\accept.php'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 定义替换规则
replacements = [
    # 请求相关
    (r"error_log\('请求方法错误：' \. \$_SERVER\['REQUEST_METHOD'\]\)", r"$requestLogger->warning('请求方法错误', ['method' => $_SERVER['REQUEST_METHOD']])"),
    (r"error_log\('请求体：' \. \$requestBody\)", r"$requestLogger->debug('请求体内容', ['body' => $requestBody])"),
    (r"error_log\('读取请求体失败：' \. \$e->getMessage\(\)\)", r"$errorLogger->error('读取请求体失败', ['exception' => $e->getMessage()])"),
    
    # 数据库
    (r"error_log\('数据库连接失败：' \. \$e->getMessage\(\)\)", r"$errorLogger->error('数据库连接失败', ['exception' => $e->getMessage()])"),
    
    # 用户认证
    (r"error_log\('用户认证成功，用户 ID: ' \. \$currentUser\['user_id'\]\)", r"$requestLogger->info('用户认证成功', ['user_id' => $currentUser['user_id']])"),
    (r"error_log\('用户认证失败：' \. \$e->getMessage\(\)\)", r"$errorLogger->error('用户认证失败', ['exception' => $e->getMessage()])"),
    
    # 接单时间
    (r"error_log\('最后接单时间：' \. \$staticRecord\['accept_task_update_at'\] \. '，时间差：' \. \$timeDiff \. '秒'\)", r"$requestLogger->debug('接单时间校验', ['last_accept' => $staticRecord['accept_task_update_at'], 'time_diff' => $timeDiff])"),
    (r"error_log\('接单间隔不足 3 分钟，禁止接单'\)", r"$auditLogger->notice('接单间隔不足 3 分钟', ['time_diff' => $timeDiff])"),
    
    # 用户状态
    (r"error_log\('查询用户封禁状态和新手状态，用户 ID: ' \. \$currentUser\['user_id'\]\)", r"$requestLogger->debug('查询用户封禁状态', ['user_id' => $currentUser['user_id']])"),
    (r"error_log\('用户新手状态：' \. \$isNewbie\)", r"$requestLogger->debug('用户新手状态', ['is_newbie' => $isNewbie])"),
    (r"error_log\('选择任务表：' \. \$taskTable\)", r"$requestLogger->debug('选择任务表', ['table' => $taskTable])"),
    (r"error_log\('用户封禁状态：' \. \$userInfo\['blocked_status'\]\)", r"$requestLogger->debug('用户封禁状态', ['blocked_status' => $userInfo['blocked_status']])"),
    (r"error_log\('用户被禁止登录：' \. \$message\)", r"$auditLogger->notice('用户被禁止登录', ['message' => $message])"),
    
    # 任务参数
    (r"error_log\('获取到任务 ID: ' \. \$bTaskId\)", r"$requestLogger->debug('获取任务 ID', ['b_task_id' => $bTaskId])"),
    (r"error_log\('任务 ID 为空或无效：' \. \$bTaskId\)", r"$requestLogger->warning('任务 ID 无效', ['b_task_id' => $bTaskId])"),
    
    # 校验
    (r"error_log\('校验用户是否有进行中的任务，用户 ID: ' \. \$currentUser\['user_id'\]\)", r"$requestLogger->debug('校验进行中任务', ['user_id' => $currentUser['user_id']])"),
    (r"error_log\('校验用户是否已接过该任务，任务 ID: ' \. \$bTaskId\)", r"$requestLogger->debug('校验重复接单', ['b_task_id' => $bTaskId])"),
    (r"error_log\('查询当日统计记录，用户 ID: ' \. \$currentUser\['user_id'\] \. '，日期：' \. \$today\)", r"$requestLogger->debug('查询当日统计', ['user_id' => $currentUser['user_id'], 'date' => $today])"),
    
    # 任务查询
    (r"error_log\('查询任务信息，任务 ID: ' \. \$bTaskId\)", r"$requestLogger->debug('查询任务信息', ['b_task_id' => $bTaskId])"),
    (r"error_log\('任务不存在，任务 ID: ' \. \$bTaskId\)", r"$requestLogger->warning('任务不存在', ['b_task_id' => $bTaskId])"),
    (r"error_log\('任务信息查询成功，任务 ID: ' \. \$bTask\['id'\]\)", r"$requestLogger->debug('任务查询成功', ['b_task_id' => $bTask['id']])"),
    
    # 任务数量
    (r"error_log\('任务剩余数量：' \. \$remainingCount \. '，总数量：' \. \$taskCount \. '，已完成：' \. \$taskDone \. '，进行中：' \. \$taskDoing \. '，待审核：' \. \$taskReviewing\)", r"$requestLogger->debug('任务数量统计', ['remaining' => $remainingCount, 'total' => $taskCount, 'done' => $taskDone, 'doing' => $taskDoing, 'reviewing' => $taskReviewing])"),
    
    # 佣金
    (r"error_log\('查询模板佣金配置，模板 ID: ' \. \$bTask\['template_id'\]\)", r"$requestLogger->debug('查询模板佣金', ['template_id' => $bTask['template_id']])"),
    (r"error_log\('计算佣金，阶段：' \. \$stage \. '，佣金：' \. \$rewardAmount \. '分'\)", r"$requestLogger->debug('计算佣金', ['stage' => $stage, 'reward' => $rewardAmount])"),
    (r"error_log\('任务阶段：' \. \$taskStage \. '，阶段文本：' \. \$taskStageText\)", r"$requestLogger->debug('任务阶段信息', ['stage' => $taskStage, 'stage_text' => $taskStageText])"),
    
    # 插入
    (r"error_log\('插入 C 端任务记录'\)", r"$requestLogger->debug('插入 C 端任务记录')"),
    (r"error_log\('C 端任务记录插入成功，记录 ID: ' \. \$recordId\)", r"$auditLogger->notice('C 端任务记录创建成功', ['record_id' => $recordId])"),
    
    # 更新
    (r"error_log\('更新当日接单统计，统计 ID: ' \. \$dailyStatsId\)", r"$requestLogger->debug('更新接单统计', ['stats_id' => $dailyStatsId])"),
    
    # 成功
    (r"error_log\('接单成功，返回响应，记录 ID: ' \. \$recordId\)", r"$auditLogger->notice('接单成功', ['record_id' => $recordId, 'b_task_id' => $bTaskId])"),
    
    # 异常
    (r"error_log\('PDO 异常：' \. \$e->getMessage\(\)\)", r"$errorLogger->error('PDO 异常', ['message' => $e->getMessage()])"),
    (r"error_log\('异常文件：' \. \$e->getFile\(\)\)", r""),
    (r"error_log\('异常行号：' \. \$e->getLine\(\)\)", r""),
]

count = 0
for pattern, replacement in replacements:
    new_content, num_replacements = re.subn(pattern, replacement, content)
    if num_replacements > 0:
        print(f"替换成功 ({num_replacements} 处): {pattern[:50]}...")
        content = new_content
        count += num_replacements

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"\n完成！共替换 {count} 处 error_log() 调用")
