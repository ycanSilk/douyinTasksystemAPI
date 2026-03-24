# 日志系统配置文件
# 使用说明：
# 1. 修改此文件中的日志路径配置
# 2. 运行脚本前设置环境变量：export LOG_BASE_PATH=/your/path
# 3. 或在 .bashrc 中永久设置

#===============================================================================
# 基础配置
#===============================================================================

# 日志基础路径（绝对路径）
LOG_BASE_PATH="./logs"

# 是否启用日志轮转（1=启用，0=禁用）
LOG_ROTATION_ENABLED=1

# 日志保留天数
LOG_RETENTION_DAYS=30

# 错误日志保留天数
ERROR_LOG_RETENTION_DAYS=90

# 审计日志保留天数
AUDIT_LOG_RETENTION_DAYS=365

#===============================================================================
# 接口日志映射配置
# 格式：API 路径模式=日志文件前缀
#===============================================================================

# B 端认证接口
API_LOG_B_AUTH_REGISTER="request/b_auth_register"
API_LOG_B_AUTH_LOGIN="request/b_auth_login"
API_LOG_B_AUTH_LOGOUT="request/b_auth_logout"

# C 端认证接口
API_LOG_C_AUTH_REGISTER="request/c_auth_register"
API_LOG_C_AUTH_LOGIN="request/c_auth_login"
API_LOG_C_AUTH_LOGOUT="request/c_auth_logout"

# C 端任务接口
API_LOG_C_TASKS_ACCEPT="request/c_tasks_accept"
API_LOG_C_TASKS_SUBMIT="request/c_tasks_submit"
API_LOG_C_TASKS_REVIEW="request/c_tasks_review"
API_LOG_C_TASKS_LIST="request/c_tasks_list"
API_LOG_C_TASKS_DETAIL="request/c_tasks_detail"

# B 端任务接口
API_LOG_B_TASKS_CREATE="request/b_tasks_create"
API_LOG_B_TASKS_UPDATE="request/b_tasks_update"
API_LOG_B_TASKS_DELETE="request/b_tasks_delete"
API_LOG_B_TASKS_REVIEW="request/b_tasks_review"
API_LOG_B_TASKS_LIST="request/b_tasks_list"
API_LOG_B_TASKS_DETAIL="request/b_tasks_detail"

# 定时任务
API_LOG_CRON_TASK_CHECK="cron/task_check"
API_LOG_CRON_TASK_AUTO_REVIEW="cron/task_auto_review"
API_LOG_CRON_SUPPLY_NEWBIE="cron/supply_newbie_tasks"

#===============================================================================
# 日志级别配置
#===============================================================================

# 日志级别：DEBUG=10, INFO=20, NOTICE=30, WARNING=40, ERROR=50, CRITICAL=60
LOG_LEVEL=20

# 生产环境日志级别（建议 WARNING）
PROD_LOG_LEVEL=40

#===============================================================================
# 性能配置
#===============================================================================

# 是否启用异步日志（1=启用，0=禁用）
ASYNC_LOG_ENABLED=1

# 异步日志队列大小
ASYNC_QUEUE_SIZE=100

# 是否启用敏感数据脱敏（1=启用，0=禁用）
SENSITIVE_DATA_MASK_ENABLED=1

#===============================================================================
# 通知配置
#===============================================================================

# 错误日志告警阈值（每小时错误数量）
ERROR_ALERT_THRESHOLD=100

# 告警邮箱（多个邮箱用逗号分隔）
ALERT_EMAIL=""

# 是否启用邮件告警（1=启用，0=禁用）
EMAIL_ALERT_ENABLED=0

#===============================================================================
# 高级配置
#===============================================================================

# 日志文件格式化（JSON=1, TEXT=0）
LOG_FORMAT_JSON=1

# 是否记录调用栈（1=启用，0=禁用）
LOG_STACK_TRACE=0

# 最大日志文件大小（MB）
MAX_LOG_FILE_SIZE=100

# 日志文件备份数量
LOG_BACKUP_COUNT=5

#===============================================================================
# 环境检测
#===============================================================================

# 自动检测环境
if [ -f ".env" ]; then
    # 加载 .env 文件
    export $(cat .env | grep -v '^#' | xargs)
fi

# 检测是否为生产环境
if [ "$APP_ENV" = "production" ]; then
    LOG_LEVEL=$PROD_LOG_LEVEL
    ASYNC_LOG_ENABLED=1
    LOG_STACK_TRACE=0
fi
