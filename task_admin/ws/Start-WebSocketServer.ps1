<#
.SYNOPSIS
    WebSocket 服务器启动脚本

.DESCRIPTION
    用于后台启动 WebSocket 服务器，并在启动前关闭之前的实例

.EXAMPLE
    .\Start-WebSocketServer.ps1

.NOTES
    Author: Auto-generated
    Date: $(Get-Date)
#>

# 定义变量
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerFile = Join-Path $ScriptDir "notification.php"
$LogDir = Join-Path $ScriptDir "socket-log"
$PidFile = Join-Path $ScriptDir "websocket-server.pid"
$OutputLog = Join-Path $LogDir "server-output.log"

# 确保日志目录存在
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

Write-Host "===================================="
Write-Host "WebSocket 服务器启动脚本"
Write-Host "===================================="

# 检查之前的进程是否存在
if (Test-Path $PidFile) {
    $OldPid = Get-Content $PidFile -ErrorAction SilentlyContinue
    if ($OldPid) {
        try {
            $Process = Get-Process -Id $OldPid -ErrorAction SilentlyContinue
            if ($Process) {
                Write-Host "发现之前的 WebSocket 服务器进程 (PID: $OldPid)，正在关闭..."
                $Process | Stop-Process -Force
                Start-Sleep -Seconds 2
                # 再次检查是否关闭
                $Process = Get-Process -Id $OldPid -ErrorAction SilentlyContinue
                if ($Process) {
                    Write-Host "强制关闭之前的进程..."
                    $Process | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 1
                }
                Write-Host "之前的进程已关闭"
            } else {
                Write-Host "发现 PID 文件，但进程不存在，删除 PID 文件"
                Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
            }
        } catch {
            Write-Host "关闭之前进程时出错: $($_.Exception.Message)"
            Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "PID 文件为空，删除 PID 文件"
        Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    }
}

# 检查端口是否被占用
$Port = 9999
Write-Host "检查端口 $Port 是否被占用..."
try {
    $Processes = netstat -ano | Select-String ":$Port"
    if ($Processes) {
        foreach ($Process in $Processes) {
            $Pid = $Process.ToString().Split()[-1]
            if ($Pid -match '^\d+$') {
                $PortProcess = Get-Process -Id $Pid -ErrorAction SilentlyContinue
                if ($PortProcess) {
                    Write-Host "发现端口 $Port 被进程 $Pid ($($PortProcess.ProcessName)) 占用，正在关闭..."
                    $PortProcess | Stop-Process -Force
                    Start-Sleep -Seconds 2
                    # 再次检查是否关闭
                    $PortProcess = Get-Process -Id $Pid -ErrorAction SilentlyContinue
                    if ($PortProcess) {
                        Write-Host "强制关闭占用端口的进程..."
                        $PortProcess | Stop-Process -Force -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 1
                    }
                    Write-Host "端口 $Port 已释放"
                }
            }
        }
    } else {
        Write-Host "端口 $Port 未被占用"
    }
} catch {
    Write-Host "检查端口占用时出错: $($_.Exception.Message)"
}

# 启动新的 WebSocket 服务器
Write-Host "正在启动 WebSocket 服务器..."
try {
    # 后台启动进程
    $Process = Start-Process php -ArgumentList "`"$ServerFile`"" -NoNewWindow -PassThru -RedirectStandardOutput $OutputLog -RedirectStandardError $OutputLog
    
    # 保存 PID 到文件
    $Process.Id | Out-File -FilePath $PidFile -Force
    
    # 检查服务器是否成功启动
    Start-Sleep -Seconds 3
    $Process = Get-Process -Id $Process.Id -ErrorAction SilentlyContinue
    if ($Process) {
        Write-Host "WebSocket 服务器启动成功！"
        Write-Host "PID: $($Process.Id)"
        Write-Host "日志输出: $OutputLog"
        Write-Host "===================================="
    } else {
        Write-Host "WebSocket 服务器启动失败！"
        Write-Host "请检查日志文件: $OutputLog"
        Write-Host "===================================="
        Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
        exit 1
    }
} catch {
    Write-Host "启动服务器时出错: $($_.Exception.Message)"
    Write-Host "===================================="
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    exit 1
}
