#!/bin/bash

# WebSocket 服务器启动脚本
# 用于后台启动 WebSocket 服务器，并在启动前关闭之前的实例

# 定义变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_FILE="$SCRIPT_DIR/notification.php"
LOG_DIR="$SCRIPT_DIR/socket-log"
PID_FILE="$SCRIPT_DIR/websocket-server.pid"
PORT=9999

# 确保日志目录存在
mkdir -p "$LOG_DIR"

echo "===================================="
echo "WebSocket 服务器启动脚本"
echo "===================================="

# 检查之前的进程是否存在
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "发现之前的 WebSocket 服务器进程 (PID: $OLD_PID)，正在关闭..."
        kill "$OLD_PID"
        sleep 2
        # 再次检查是否关闭
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo "强制关闭之前的进程..."
            kill -9 "$OLD_PID"
            sleep 1
        fi
        echo "之前的进程已关闭"
    else
        echo "发现 PID 文件，但进程不存在，删除 PID 文件"
        rm -f "$PID_FILE"
    fi
fi

# 检查端口是否被占用
echo "检查端口 $PORT 是否被占用..."
PORT_PID=$(lsof -t -i:$PORT 2>/dev/null)
if [ ! -z "$PORT_PID" ]; then
    echo "发现端口 $PORT 被进程 $PORT_PID 占用，正在关闭..."
    # 关闭占用端口的进程
    kill "$PORT_PID"
    sleep 2
    # 再次检查是否关闭
    PORT_PID=$(lsof -t -i:$PORT 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        echo "强制关闭占用端口的进程..."
        kill -9 "$PORT_PID"
        sleep 1
    fi
    echo "端口 $PORT 已释放"
else
    echo "端口 $PORT 未被占用"
fi

# 启动新的 WebSocket 服务器
echo "正在启动 WebSocket 服务器..."
php "$SERVER_FILE" > "$LOG_DIR/server-output.log" 2>&1 &

# 获取新进程的 PID
NEW_PID=$!

# 保存 PID 到文件
echo "$NEW_PID" > "$PID_FILE"

# 检查服务器是否成功启动
sleep 3
if ps -p "$NEW_PID" > /dev/null 2>&1; then
    echo "WebSocket 服务器启动成功！"
    echo "PID: $NEW_PID"
    echo "日志输出: $LOG_DIR/server-output.log"
    echo "===================================="
else
    echo "WebSocket 服务器启动失败！"
    echo "请检查日志文件: $LOG_DIR/server-output.log"
    echo "===================================="
    rm -f "$PID_FILE"
    exit 1
fi
