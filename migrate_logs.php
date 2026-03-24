<?php
/**
 * 日志迁移脚本
 * 将 accept.php 中的 error_log() 调用替换为统一日志系统
 */

$file = __DIR__ . '/api/c/v1/tasks/accept.php';
$content = file_get_contents($file);

// 定义替换规则
$replacements = [
    // 请求相关 - 使用 requestLogger
    "error_log('请求方法错误：' . \$_SERVER['REQUEST_METHOD'])" => "\$requestLogger->warning('请求方法错误', ['method' => \$_SERVER['REQUEST_METHOD']])",
    "error_log('请求体：' . \$requestBody)" => "\$requestLogger->debug('请求体内容', ['body' => \$requestBody])",
    "error_log('读取请求体失败：' . \$e->getMessage())" => "\$errorLogger->error('读取请求体失败', ['exception' => \$e->getMessage()])",
    
    // 数据库相关
    "error_log('数据库连接成功')" => "\$requestLogger->debug('数据库连接成功')",
    "error_log('数据库连接失败：' . \$e->getMessage())" => "\$errorLogger->error('数据库连接失败', ['exception' => \$e->getMessage()])",
    
    // 用户认证相关
    "error_log('用户认证成功，用户 ID: ' . \$currentUser['user_id'])" => "\$requestLogger->info('用户认证成功', ['user_id' => \$currentUser['user_id']])",
    "error_log('用户认证失败：' . \$e->getMessage())" => "\$errorLogger->error('用户认证失败', ['exception' => \$e->getMessage()])",
    
    // 接单时间校验
    "error_log('校验最后一次接单时间')" => "\$requestLogger->debug('校验最后一次接单时间')",
    "error_log('最后接单时间：' . \$staticRecord['accept_task_update_at'] . '，时间差：' . \$timeDiff . '秒')" => "\$requestLogger->debug('接单时间校验', ['last_accept' => \$staticRecord['accept_task_update_at'], 'time_diff' => \$timeDiff])",
    "error_log('接单间隔不足 3 分钟，禁止接单')" => "\$auditLogger->notice('接单间隔不足 3 分钟', ['time_diff' => \$timeDiff])",
    "error_log('接单间隔符合要求，继续校验')" => "\$requestLogger->debug('接单间隔符合要求')",
    
    // 用户状态查询
    "error_log('查询用户封禁状态和新手状态，用户 ID: ' . \$currentUser['user_id'])" => "\$requestLogger->debug('查询用户封禁状态', ['user_id' => \$currentUser['user_id']])",
    "error_log('用户新手状态：' . \$isNewbie)" => "\$requestLogger->debug('用户新手状态', ['is_newbie' => \$isNewbie])",
    "error_log('选择任务表：' . \$taskTable)" => "\$requestLogger->debug('选择任务表', ['table' => \$taskTable])",
    "error_log('用户封禁状态：' . \$userInfo['blocked_status'])" => "\$requestLogger->debug('用户封禁状态', ['blocked_status' => \$userInfo['blocked_status']])",
    "error_log('用户被禁止登录：' . \$message)" => "\$auditLogger->notice('用户被禁止登录', ['message' => \$message])",
    "error_log('用户被禁止接单：' . \$message)" => "\$auditLogger->notice('用户被禁止接单', ['message' => \$message])",
    
    // 任务参数相关
    "error_log('获取到任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('获取任务 ID', ['b_task_id' => \$bTaskId])",
    "error_log('任务 ID 为空或无效：' . \$bTaskId)" => "\$requestLogger->warning('任务 ID 无效', ['b_task_id' => \$bTaskId])",
    
    // 进行中任务校验
    "error_log('校验用户是否有进行中的任务，用户 ID: ' . \$currentUser['user_id'])" => "\$requestLogger->debug('校验进行中任务', ['user_id' => \$currentUser['user_id']])",
    "error_log('用户有进行中的任务，禁止接单')" => "\$auditLogger->notice('用户有进行中任务，禁止接单')",
    "error_log('用户无进行中的任务，继续校验')" => "\$requestLogger->debug('无进行中任务')",
    
    // 重复接单校验
    "error_log('校验用户是否已接过该任务，任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('校验重复接单', ['b_task_id' => \$bTaskId])",
    "error_log('用户已接过该任务，禁止重复接单')" => "\$auditLogger->notice('用户重复接单被拒')",
    "error_log('用户未接过该任务，继续校验')" => "\$requestLogger->debug('非重复接单')",
    
    // 统计记录相关
    "error_log('查询当日统计记录，用户 ID: ' . \$currentUser['user_id'] . '，日期：' . \$today)" => "\$requestLogger->debug('查询当日统计', ['user_id' => \$currentUser['user_id'], 'date' => \$today])",
    "error_log('创建当日统计记录')" => "\$requestLogger->debug('创建当日统计记录')",
    "error_log('当日统计记录创建成功，ID: ' . \$dailyStatsId)" => "\$requestLogger->debug('当日统计创建成功', ['id' => \$dailyStatsId])",
    "error_log('当日统计记录已存在，ID: ' . \$dailyStatsId . '，驳回次数：' . \$rejectedCount . '，通过次数：' . \$approvedCount . '，弃单次数：' . \$abandonCount)" => "\$requestLogger->debug('当日统计已存在', ['id' => \$dailyStatsId, 'rejected' => \$rejectedCount, 'approved' => \$approvedCount, 'abandon' => \$abandonCount])",
    
    // 驳回次数校验
    "error_log('用户当日驳回次数超过限制，禁止接单')" => "\$auditLogger->notice('用户驳回次数超限', ['rejected_count' => \$rejectedCount])",
    "error_log('用户当日驳回次数未超过限制，继续校验')" => "\$requestLogger->debug('驳回次数未超限')",
    
    // 弃单次数校验
    "error_log('用户当日弃单次数：' . \$abandonCount)" => "\$requestLogger->debug('用户弃单次数', ['abandon_count' => \$abandonCount])",
    "error_log('用户当日弃单次数超过限制，禁止接单')" => "\$auditLogger->notice('用户弃单次数超限', ['abandon_count' => \$abandonCount])",
    "error_log('用户当日弃单次数未超过限制，继续校验')" => "\$requestLogger->debug('弃单次数未超限')",
    
    // 任务查询
    "error_log('查询任务信息，任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('查询任务信息', ['b_task_id' => \$bTaskId])",
    "error_log('任务不存在，任务 ID: ' . \$bTaskId)" => "\$requestLogger->warning('任务不存在', ['b_task_id' => \$bTaskId])",
    "error_log('任务信息查询成功，任务 ID: ' . \$bTask['id'])" => "\$requestLogger->debug('任务查询成功', ['b_task_id' => \$bTask['id']])",
    
    // 组合任务校验
    "error_log('校验组合任务，combo_task_id: ' . \$comboTaskId)" => "\$requestLogger->debug('校验组合任务', ['combo_task_id' => \$comboTaskId])",
    "error_log('用户已接过该组合任务，禁止重复接单')" => "\$auditLogger->notice('用户重复接组合任务被拒')",
    "error_log('用户未接过该组合任务，继续校验')" => "\$requestLogger->debug('非重复接组合任务')",
    
    // 任务状态校验
    "error_log('校验任务是否开放，stage_status: ' . \$bTask['stage_status'])" => "\$requestLogger->debug('校验任务开放状态', ['stage_status' => \$bTask['stage_status']])",
    "error_log('任务未开放，禁止接单')" => "\$auditLogger->notice('任务未开放')",
    "error_log('任务已开放，继续校验')" => "\$requestLogger->debug('任务已开放')",
    "error_log('校验任务状态，status: ' . \$bTask['status'])" => "\$requestLogger->debug('校验任务状态', ['status' => \$bTask['status']])",
    "error_log('任务已结束，禁止接单')" => "\$auditLogger->notice('任务已结束')",
    "error_log('任务状态正常，继续校验')" => "\$requestLogger->debug('任务状态正常')",
    
    // 任务数量校验
    "error_log('任务剩余数量：' . \$remainingCount . '，总数量：' . \$taskCount . '，已完成：' . \$taskDone . '，进行中：' . \$taskDoing . '，待审核：' . \$taskReviewing)" => "\$requestLogger->debug('任务数量统计', ['remaining' => \$remainingCount, 'total' => \$taskCount, 'done' => \$taskDone, 'doing' => \$taskDoing, 'reviewing' => \$taskReviewing])",
    "error_log('任务无剩余名额，禁止接单')" => "\$auditLogger->notice('任务无剩余名额')",
    "error_log('任务有剩余名额，继续处理')" => "\$requestLogger->debug('任务有剩余名额')",
    
    // 推荐评论
    "error_log('解析推荐评论，分配给当前用户')" => "\$requestLogger->debug('解析推荐评论')",
    "error_log('无推荐评论')" => "\$requestLogger->debug('无推荐评论')",
    "error_log('分配推荐评论成功')" => "\$requestLogger->debug('推荐评论分配成功')",
    
    // 事务处理
    "error_log('开启事务')" => "\$requestLogger->debug('开启数据库事务')",
    "error_log('查询模板佣金配置，模板 ID: ' . \$bTask['template_id'])" => "\$requestLogger->debug('查询模板佣金', ['template_id' => \$bTask['template_id']])",
    "error_log('计算佣金，阶段：' . \$stage . '，佣金：' . \$rewardAmount . '分')" => "\$requestLogger->debug('计算佣金', ['stage' => \$stage, 'reward' => \$rewardAmount])",
    "error_log('任务阶段：' . \$taskStage . '，阶段文本：' . \$taskStageText)" => "\$requestLogger->debug('任务阶段信息', ['stage' => \$taskStage, 'stage_text' => \$taskStageText])",
    
    // 插入记录
    "error_log('插入 C 端任务记录')" => "\$requestLogger->debug('插入 C 端任务记录')",
    "error_log('C 端任务记录插入成功，记录 ID: ' . \$recordId)" => "\$auditLogger->notice('C 端任务记录创建成功', ['record_id' => \$recordId])",
    
    // 更新 task_doing
    "error_log('查询普通任务当前 task_doing 值，任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('查询任务 task_doing', ['b_task_id' => \$bTaskId])",
    "error_log('当前 task_doing=' . \$currentTaskDoing . ', 更新为=' . \$newTaskDoing)" => "\$requestLogger->debug('计算 task_doing', ['current' => \$currentTaskDoing, 'new' => \$newTaskDoing])",
    "error_log('更新 B 端任务进行中数量：task_doing=' . \$newTaskDoing . ', 任务 ID: ' . \$bTaskId)" => "\$requestLogger->debug('更新 B 端任务 doing 数量', ['b_task_id' => \$bTaskId, 'new_doing' => \$newTaskDoing])",
    "error_log('B 端任务进行中数量更新成功')" => "\$requestLogger->debug('B 端任务更新成功')",
    
    // 更新统计
    "error_log('更新当日接单统计，统计 ID: ' . \$dailyStatsId)" => "\$requestLogger->debug('更新接单统计', ['stats_id' => \$dailyStatsId])",
    "error_log('当日接单统计更新成功')" => "\$requestLogger->debug('接单统计更新成功')",
    
    // 更新静态记录
    "error_log('更新用户任务静态记录的最后接单时间')" => "\$requestLogger->debug('更新用户静态记录')",
    "error_log('用户任务静态记录不存在，创建新记录')" => "\$requestLogger->debug('创建用户静态记录')",
    "error_log('用户任务静态记录更新成功')" => "\$requestLogger->debug('用户静态记录更新成功')",
    
    // 事务提交
    "error_log('提交事务')" => "\$requestLogger->debug('提交数据库事务')",
    "error_log('事务提交成功')" => "\$requestLogger->debug('事务提交成功')",
    "error_log('接单成功，返回响应，记录 ID: ' . \$recordId)" => "\$auditLogger->notice('接单成功', ['record_id' => \$recordId, 'b_task_id' => \$bTaskId])",
    
    // 异常处理
    "error_log('发生异常，回滚事务')" => "\$errorLogger->error('事务回滚', ['exception' => 'PDOException'])",
    "error_log('PDO 异常：' . \$e->getMessage())" => "\$errorLogger->error('PDO 异常', ['message' => \$e->getMessage(), 'file' => \$e->getFile(), 'line' => \$e->getLine()])",
    "error_log('异常文件：' . \$e->getFile())" => "",
    "error_log('异常行号：' . \$e->getLine())" => "",
];

// 执行替换
$count = 0;
foreach ($replacements as $search => $replace) {
    if (strpos($content, $search) !== false) {
        $content = str_replace($search, $replace, $content, $replaceCount);
        $count += $replaceCount;
        echo "替换：{$search} -> {$replace} ({$replaceCount} 处)\n";
    }
}

// 保存文件
file_put_contents($file, $content);

echo "\n完成！共替换 {$count} 处 error_log() 调用\n";
