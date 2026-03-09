#!/bin/bash

# 脚本功能：更新计时器状态，确保计时器持续运行

# 设置时区
export TZ='Asia/Shanghai'

# 定义API URL
API_URL="http://54.179.253.64:28806/task_admin/api/admin_notifications/update_timer.php"

# 获取当前时间
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 定义检测间隔（秒）
DETECTION_INTERVAL=60

# 发送POST请求更新计时器状态
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "{\"last_detection_time\": \"$CURRENT_TIME\", \"detection_interval\": $DETECTION_INTERVAL}"

# 输出日志
echo "$(date '+%Y-%m-%d %H:%M:%S') - 计时器更新完成" >> /var/log/timer_update.log
