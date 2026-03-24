<?php
/**
 * 日志迁移脚本 v2
 * 将 accept.php 中剩余的 error_log() 调用替换为统一日志系统
 */

$file = __DIR__ . '/api/c/v1/tasks/accept.php';
$content = file_get_contents($file);

// 定义替换规则 - 更精确的匹配
$replacements = [
    // 请求相关
    "error_log('请求方法错误：' . \$_SERVER['REQUEST_METHOD'])" => "\$requestLogger->warning('请求方法错误', ['method' => \$_SERVER['REQUEST_METHOD']])",
    "error_log('请求体：' . \$requestBody)" => "\$requestLogger->debug('请求体内容', ['body' => \$requestBody])",
    "error_log('读取请求体失败：' . \$e->getMessage())" => "\$errorLogger->error('读取请求体失败', ['exception' => \$e->getMessage()])",
    
    // 数据库连接失败
    "error_log('数据库连接失败：' . \$e->getMessage())" => "\$errorLogger->error('数据库连接失败', ['exception' => \$e->getMessage()])",
    
    // 用户认证
    "error_log('用户认证成功，用户 ID: ' . \$currentUser['user_id'])" => "\$requestLogger->info('用户认证成功', ['user_id' => \$currentUser['user_id']])",
    "error_log('用户认证失败：' . \$e->getMessage())" => "\$errorLogger->error('用户认证失败', ['exception' => \$e->getMessage()])",
    
    // 接单时间
    "error_log('最后接单时间：' . \$staticRecord['accept_task_update_at'] . '，时间差：' . \$timeDiff . '秒')" => "\$requestLogger->debug('接单时间校验', ['last_accept' => \$staticRecord['accept_task_update_at'], 'time_diff' => \$timeDiff])",
    "error_log('接单间隔不足 3 分钟，禁止接单')" => "\$auditLogger->notice('接单间隔不足 3 分钟', ['time_diff' => \$timeDiff])",
    
    // 用户状态
    "error_log('查询用户封禁状态和新手状态，用户 ID: ' . \$currentUser['user_id'])" => "\$requestLogger->debug('查询用户封禁状态', ['user_id' => \$currentUser['user_id']])",
    "error_log('用户新手状态：' . \$isNewbie)" => "\$requestLogger->debug('用户新手状态', ['is_newbie' => \$isNewbie])",
    "error_log('选择任务表：' . \$taskTable)" => "\$requestLogger->debug('选择任务表', ['table' => \$taskTable])",
    "error_log('用户封禁状态：' . \$userInfo['blocked_status'])" => "\$requestLogger->debug('用户封禁状态', ['blocked_status' => \$userInfo['blocked_status']])",
    "error_log('用户被禁止登录：' . \$message)" => "\$auditLogger->notice('用户被禁止登录', ['message' => \$message])",
    
    // 任务参数
    "error_log('获取到任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('获取任务 ID', ['b_task_id' => \$bTaskId])",
    "error_log('任务 ID 为空或无效：' . \$bTaskId)" => "\$requestLogger->warning('任务 ID 无效', ['b_task_id' => \$bTaskId])",
    
    // 校验逻辑
    "error_log('校验用户是否有进行中的任务，用户 ID: ' . \$currentUser['user_id'])" => "\$requestLogger->debug('校验进行中任务', ['user_id' => \$currentUser['user_id']])",
    "error_log('校验用户是否已接过该任务，任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('校验重复接单', ['b_task_id' => \$bTaskId])",
    "error_log('查询当日统计记录，用户 ID: ' . \$currentUser['user_id'] . '，日期：' . \$today)" => "\$requestLogger->debug('查询当日统计', ['user_id' => \$currentUser['user_id'], 'date' => \$today])",
    
    // 任务查询
    "error_log('查询任务信息，任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('查询任务信息', ['b_task_id' => \$bTaskId])",
    "error_log('任务不存在，任务 ID: ' . \$bTaskId)" => "\$requestLogger->warning('任务不存在', ['b_task_id' => \$bTaskId])",
    "error_log('任务信息查询成功，任务 ID: ' . \$bTask['id'])" => "\$requestLogger->debug('任务查询成功', ['b_task_id' => \$bTask['id']])",
    
    // 任务数量
    "error_log('任务剩余数量：' . \$remainingCount . '，总数量：' . \$taskCount . '，已完成：' . \$taskDone . '，进行中：' . \$taskDoing . '，待审核：' . \$taskReviewing)" => "\$requestLogger->debug('任务数量统计', ['remaining' => \$remainingCount, 'total' => \$taskCount, 'done' => \$taskDone, 'doing' => \$taskDoing, 'reviewing' => \$taskReviewing])",
    
    // 模板佣金
    "error_log('查询模板佣金配置，模板 ID: ' . \$bTask['template_id'])" => "\$requestLogger->debug('查询模板佣金', ['template_id' => \$bTask['template_id']])",
    "error_log('计算佣金，阶段：' . \$stage . '，佣金：' . \$rewardAmount . '分')" => "\$requestLogger->debug('计算佣金', ['stage' => \$stage, 'reward' => \$rewardAmount])",
    "error_log('任务阶段：' . \$taskStage . '，阶段文本：' . \$taskStageText)" => "\$requestLogger->debug('任务阶段信息', ['stage' => \$taskStage, 'stage_text' => \$taskStageText])",
    
    // 插入记录
    "error_log('插入 C 端任务记录')" => "\$requestLogger->debug('插入 C 端任务记录')",
    "error_log('C 端任务记录插入成功，记录 ID: ' . \$recordId)" => "\$auditLogger->notice('C 端任务记录创建成功', ['record_id' => \$recordId])",
    
    // 更新统计
    "error_log('更新当日接单统计，统计 ID: ' . \$dailyStatsId)" => "\$requestLogger->debug('更新接单统计', ['stats_id' => \$dailyStatsId])",
    
    // 接单成功
    "error_log('接单成功，返回响应，记录 ID: ' . \$recordId)" => "\$auditLogger->notice('接单成功', ['record_id' => \$recordId, 'b_task_id' => \$bTaskId])",
    
    // PDO 异常
    "error_log('PDO 异常：' . \$e->getMessage())" => "\$errorLogger->error('PDO 异常', ['message' => \$e->getMessage()])",
    "error_log('异常文件：' . \$e->getFile())" => "",
    "error_log('异常行号：' . \$e->getLine())" => "",
];

// 执行替换
$count = 0;
foreach ($replacements as $search => $replace) {
    if (strpos($content, $search) !== false) {
        $content = str_replace($search, $replace, $content, $replaceCount);
        $count += $replaceCount;
        echo "替换：{$search} ({$replaceCount} 处)\n";
    }
}

// 保存文件
file_put_contents($file, $content);

echo "\n完成！共替换 {$count} 处 error_log() 调用\n";
