#!/bin/bash

#===============================================================================
# 日志查看自动化运维脚本
# 使用方法：./view_logs.sh
# 功能：根据接口名称/路径智能查看对应的日志文件
#===============================================================================

# 配置日志基础路径（可以修改）
LOG_BASE_PATH="${LOG_BASE_PATH:-./logs}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# JSON 配置文件路径
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config/api_log_mapping.json}"

# 从 JSON 配置加载接口映射
load_api_mapping() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}警告：配置文件不存在：$CONFIG_FILE${NC}"
        echo -e "${YELLOW}使用默认配置${NC}"
        return 1
    fi
    
    # 使用 PHP 解析 JSON 并输出为 shell 关联数组
    if command -v php &> /dev/null; then
        eval "$(php -r "
            \$json = file_get_contents('$CONFIG_FILE');
            \$config = json_decode(\$json, true);
            \$apiRoutes = \$config['api_routes'] ?? [];
            foreach (\$apiRoutes as \$category => \$interfaces) {
                foreach (\$interfaces as \$path => \$info) {
                    \$prefix = \$info['log_prefix'] ?? '';
                    echo 'API_LOG_MAP[\"$path\"]=\"$prefix\";' . PHP_EOL;
                }
            }
        ")"
        return 0
    else
        echo -e "${YELLOW}警告：PHP 未安装，使用默认配置${NC}"
        return 1
    fi
}

# 声明关联数组
declare -A API_LOG_MAP

# 加载配置
load_api_mapping

# 如果加载失败，使用默认配置
if [ ${#API_LOG_MAP[@]} -eq 0 ]; then
    API_LOG_MAP=(
        ["b/auth/register"]="request/b_auth_register"
        ["b/auth/login"]="request/b_auth_login"
        ["c/tasks/accept"]="request/c_tasks_accept"
        ["c/tasks/submit"]="request/c_tasks_submit"
        ["cron/task_check"]="cron/task_check"
    )
fi

# 显示帮助信息
show_help() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  日志查看自动化运维工具${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "使用方法:"
    echo -e "  ${GREEN}$0${NC}                    # 交互式菜单"
    echo -e "  ${GREEN}$0 -l${NC}                  # 列出所有可用的日志"
    echo -e "  ${GREEN}$0 -t <type>${NC}           # 查看指定类型的日志 (request/error/audit/sql)"
    echo -e "  ${GREEN}$0 -a <api>${NC}            # 查看指定接口的日志"
    echo -e "  ${GREEN}$0 -k <keyword>${NC}        # 搜索包含关键词的日志"
    echo -e "  ${GREEN}$0 -T${NC}                  # 查看今天的日志"
    echo -e "  ${GREEN}$0 -w${NC}                  # 实时监控日志"
    echo -e "  ${GREEN}$0 -c${NC}                  # 清理旧日志"
    echo -e "  ${GREEN}$0 -h${NC}                  # 显示帮助信息"
    echo ""
    echo -e "示例:"
    echo -e "  ${GREEN}$0 -a c/tasks/accept${NC}   # 查看 C 端接单接口日志"
    echo -e "  ${GREEN}$0 -t error -T${NC}         # 查看今天的错误日志"
    echo -e "  ${GREEN}$0 -k '注册失败'${NC}       # 搜索包含'注册失败'的日志"
    echo -e "  ${GREEN}$0 -w -t error${NC}         # 实时监控错误日志"
    echo ""
    echo -e "环境变量:"
    echo -e "  ${YELLOW}LOG_BASE_PATH${NC}         # 日志基础路径 (默认：./logs)"
    echo ""
}

# 列出所有可用的日志
list_logs() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  可用的日志文件列表${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    # 按类型分组显示
    for type in request error audit sql operation access cron; do
        type_path="$LOG_BASE_PATH/$type"
        if [ -d "$type_path" ]; then
            echo -e "${GREEN}[$type]${NC}"
            find "$type_path" -name "*.log" -type f 2>/dev/null | head -20 | while read -r file; do
                echo "  - $(basename "$file")"
            done
            echo ""
        fi
    done
    
    # 显示接口日志
    echo -e "${GREEN}[接口日志]${NC}"
    for api in "${!API_LOG_MAP[@]}"; do
        log_name="${API_LOG_MAP[$api]}"
        log_file="$LOG_BASE_PATH/${log_name}_$(date +%Y-%m-%d).log"
        if [ -f "$log_file" ]; then
            echo "  ✓ $api -> ${log_name}_$(date +%Y-%m-%d).log"
        else
            echo "  ○ $api (今日无日志)"
        fi
    done
}

# 查看指定类型的日志
view_type_logs() {
    local log_type="$1"
    local show_today="$2"
    
    if [ "$show_today" = "today" ]; then
        local date_str=$(date +%Y-%m-%d)
        local log_file="$LOG_BASE_PATH/$log_type/$(date +%Y-%m)/$(date +%d)/${log_type}_${date_str}.log"
    else
        # 查找最新的日志文件
        local log_file=$(find "$LOG_BASE_PATH/$log_type" -name "${log_type}_*.log" -type f 2>/dev/null | sort -r | head -1)
    fi
    
    if [ -f "$log_file" ]; then
        echo -e "${CYAN}========================================${NC}"
        echo -e "${CYAN}  查看 ${log_type} 日志${NC}"
        echo -e "${CYAN}========================================${NC}"
        echo -e "文件：${YELLOW}$log_file${NC}"
        echo ""
        tail -100 "$log_file" | less +F
    else
        echo -e "${RED}未找到 $log_type 日志文件${NC}"
    fi
}

# 查看指定接口的日志
view_api_logs() {
    local api_path="$1"
    local show_today="$2"
    
    # 查找匹配的接口
    local found=false
    for api in "${!API_LOG_MAP[@]}"; do
        if [[ "$api" == *"$api_path"* ]] || [[ "$api_path" == *"$api"* ]]; then
            found=true
            local log_name="${API_LOG_MAP[$api]}"
            
            if [ "$show_today" = "today" ]; then
                local date_str=$(date +%Y-%m-%d)
                local log_file="$LOG_BASE_PATH/${log_name}_${date_str}.log"
            else
                # 查找最新的日志文件
                local log_file=$(find "$LOG_BASE_PATH" -name "${log_name}_*.log" -type f 2>/dev/null | sort -r | head -1)
            fi
            
            if [ -f "$log_file" ]; then
                echo -e "${CYAN}========================================${NC}"
                echo -e "${CYAN}  接口：$api${NC}"
                echo -e "${CYAN}========================================${NC}"
                echo -e "日志文件：${YELLOW}$log_file${NC}"
                echo ""
                tail -100 "$log_file" | less +F
            else
                echo -e "${YELLOW}接口 $api 今日无日志${NC}"
            fi
            break
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "${RED}未找到匹配的接口：$api_path${NC}"
        echo -e "${YELLOW}提示：使用 $0 -l 查看所有可用的接口${NC}"
    fi
}

# 搜索日志
search_logs() {
    local keyword="$1"
    local log_type="$2"
    
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  搜索日志：$keyword${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    if [ -n "$log_type" ]; then
        # 在指定类型中搜索
        grep -r "$keyword" "$LOG_BASE_PATH/$log_type"/*.log 2>/dev/null | head -50
    else
        # 在所有日志中搜索
        grep -r "$keyword" "$LOG_BASE_PATH"/**/*.log 2>/dev/null | head -50
    fi
    
    echo ""
    echo -e "${YELLOW}显示前 50 条匹配结果${NC}"
}

# 实时监控日志
watch_logs() {
    local log_type="$1"
    local api_path="$2"
    
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  实时监控日志 (Ctrl+C 退出)${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    if [ -n "$api_path" ]; then
        # 监控指定接口
        for api in "${!API_LOG_MAP[@]}"; do
            if [[ "$api" == *"$api_path"* ]]; then
                local log_name="${API_LOG_MAP[$api]}"
                local log_pattern="$LOG_BASE_PATH/${log_name}_*.log"
                echo -e "监控接口：${GREEN}$api${NC}"
                tail -f $log_pattern 2>/dev/null
                break
            fi
        done
    elif [ -n "$log_type" ]; then
        # 监控指定类型
        local date_str=$(date +%Y-%m-%d)
        local log_file="$LOG_BASE_PATH/$log_type/$(date +%Y-%m)/$(date +%d)/${log_type}_${date_str}.log"
        echo -e "监控类型：${GREEN}$log_type${NC}"
        echo -e "日志文件：${YELLOW}$log_file${NC}"
        tail -f "$log_file" 2>/dev/null
    else
        # 监控所有错误日志
        echo -e "监控类型：${GREEN}error${NC}"
        find "$LOG_BASE_PATH/error" -name "error_*.log" -type f 2>/dev/null | xargs tail -f 2>/dev/null
    fi
}

# 清理旧日志
clean_logs() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  清理旧日志${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo -e "${YELLOW}警告：此操作将删除超过保留期限的日志文件！${NC}"
    echo ""
    read -p "确定要清理旧日志吗？(y/n): " confirm
    
    if [ "$confirm" = "y" ]; then
        # 删除超过 30 天的日志
        find "$LOG_BASE_PATH" -name "*.log" -type f -mtime +30 -delete
        echo -e "${GREEN}已删除超过 30 天的日志文件${NC}"
        
        # 删除空目录
        find "$LOG_BASE_PATH" -type d -empty -delete 2>/dev/null
        echo -e "${GREEN}已清理空目录${NC}"
    else
        echo -e "${YELLOW}操作已取消${NC}"
    fi
}

# 交互式菜单
interactive_menu() {
    while true; do
        echo -e "${CYAN}========================================${NC}"
        echo -e "${CYAN}  日志查看自动化运维工具${NC}"
        echo -e "${CYAN}========================================${NC}"
        echo ""
        echo "1. 查看所有可用的日志"
        echo "2. 查看今日请求日志"
        echo "3. 查看今日错误日志"
        echo "4. 查看今日审计日志"
        echo "5. 查看指定接口日志"
        echo "6. 搜索日志"
        echo "7. 实时监控错误日志"
        echo "8. 清理旧日志"
        echo "0. 退出"
        echo ""
        read -p "请选择 (0-8): " choice
        
        case $choice in
            1)
                list_logs
                ;;
            2)
                view_type_logs "request" "today"
                ;;
            3)
                view_type_logs "error" "today"
                ;;
            4)
                view_type_logs "audit" "today"
                ;;
            5)
                read -p "输入接口名称或路径 (如：c/tasks/accept): " api_path
                view_api_logs "$api_path" "today"
                ;;
            6)
                read -p "输入搜索关键词：" keyword
                search_logs "$keyword"
                ;;
            7)
                watch_logs "error"
                ;;
            8)
                clean_logs
                ;;
            0)
                echo -e "${GREEN}再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选择，请重新输入${NC}"
                ;;
        esac
        
        echo ""
        read -p "按回车键继续..."
        clear
    done
}

# 解析命令行参数
while getopts "lht:a:k:Twc" opt; do
    case $opt in
        l)
            list_logs
            exit 0
            ;;
        h)
            show_help
            exit 0
            ;;
        t)
            view_type_logs "$OPTARG" "today"
            exit 0
            ;;
        a)
            view_api_logs "$OPTARG" "today"
            exit 0
            ;;
        k)
            search_logs "$OPTARG"
            exit 0
            ;;
        T)
            # 与 -t 或 -a 配合使用
            TODAY="today"
            ;;
        w)
            if [ -n "$WATCH_TYPE" ]; then
                watch_logs "$WATCH_TYPE" "$WATCH_API"
            else
                watch_logs "" ""
            fi
            exit 0
            ;;
        c)
            clean_logs
            exit 0
            ;;
        \?)
            show_help
            exit 1
            ;;
    esac
done

# 如果没有参数，显示交互式菜单
interactive_menu
