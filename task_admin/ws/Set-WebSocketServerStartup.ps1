<#
.SYNOPSIS
    设置 WebSocket 服务器开机启动

.DESCRIPTION
    使用任务计划程序创建一个开机启动任务，运行 WebSocket 服务器启动脚本

.EXAMPLE
    .\Set-WebSocketServerStartup.ps1

.NOTES
    Author: Auto-generated
    Date: $(Get-Date)
#>

# 定义变量
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StartupScript = Join-Path $ScriptDir "Start-WebSocketServer.ps1"
$TaskName = "WebSocket 服务器启动"
$Description = "开机启动 WebSocket 服务器，用于实时推送审核任务通知"

Write-Host "===================================="
Write-Host "设置 WebSocket 服务器开机启动"
Write-Host "===================================="

# 检查启动脚本是否存在
if (-not (Test-Path $StartupScript)) {
    Write-Host "错误: 启动脚本不存在: $StartupScript"
    Write-Host "请确保 Start-WebSocketServer.ps1 文件在正确的位置"
    Write-Host "===================================="
    exit 1
}

# 创建任务计划程序任务
try {
    # 构建任务操作
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$StartupScript`""
    
    # 构建任务触发器（开机启动）
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    
    # 构建任务设置
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    # 构建任务主体（使用当前用户权限）
    $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
    
    # 创建任务
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description $Description
    
    # 注册任务
    Register-ScheduledTask -TaskName $TaskName -InputObject $Task -Force
    
    Write-Host "任务计划程序任务创建成功！"
    Write-Host "任务名称: $TaskName"
    Write-Host "触发条件: 开机启动"
    Write-Host "执行脚本: $StartupScript"
    Write-Host "===================================="
    Write-Host "要查看或修改任务，请打开 '任务计划程序' -> '任务计划程序库'"
    Write-Host "===================================="
} catch {
    Write-Host "创建任务计划程序任务时出错: $($_.Exception.Message)"
    Write-Host "请以管理员身份运行此脚本"
    Write-Host "===================================="
    exit 1
}
