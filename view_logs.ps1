# 日志查看工具 - PowerShell 版本
# 使用方法：.\view_logs.ps1
# 功能：从 JSON 配置读取接口映射，智能查看日志

param(
    [ValidateSet('request', 'error', 'audit', 'sql', 'operation', 'access', 'cron')]
    [string]$Type = '',
    [string]$Api = '',
    [string]$Keyword = '',
    [switch]$List,
    [switch]$Today,
    [switch]$Watch,
    [switch]$Help
)

# 脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# JSON 配置文件路径
$ConfigFile = Join-Path $ScriptDir "config\api_log_mapping.json"

# 日志基础路径
$LogBasePath = if ($env:LOG_BASE_PATH) { $env:LOG_BASE_PATH } else { Join-Path $ScriptDir "logs" }

# 从 JSON 加载配置
function Get-ApiMapping {
    if (Test-Path $ConfigFile) {
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        $apiRoutes = @{}
        
        foreach ($category in $config.api_routes.PSObject.Properties.Name) {
            $interfaces = $config.api_routes.$category
            foreach ($api in $interfaces.PSObject.Properties.Name) {
                $apiRoutes[$api] = $interfaces.$api.log_prefix
            }
        }
        return $apiRoutes
    } else {
        Write-Warning "配置文件不存在：$ConfigFile"
        return @{}
    }
}

# 加载接口映射
$ApiLogMap = Get-ApiMapping

# 显示帮助
function Show-Help {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  日志查看自动化运维工具" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "使用方法:"
    Write-Host "  .\view_logs.ps1                    # 交互式菜单"
    Write-Host "  .\view_logs.ps1 -List              # 列出所有日志"
    Write-Host "  .\view_logs.ps1 -Type request      # 查看指定类型日志"
    Write-Host "  .\view_logs.ps1 -Api c/tasks/accept  # 查看指定接口日志"
    Write-Host "  .\view_logs.ps1 -Keyword '注册'    # 搜索日志"
    Write-Host "  .\view_logs.ps1 -Watch -Type error # 实时监控"
    Write-Host "  .\view_logs.ps1 -Help              # 显示帮助"
    Write-Host ""
}

# 列出所有日志
function Show-List {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  可用的日志文件" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # 按类型显示
    foreach ($type in 'request', 'error', 'audit', 'sql', 'operation', 'access', 'cron') {
        $typePath = Join-Path $LogBasePath $type
        if (Test-Path $typePath) {
            Write-Host "[$type]" -ForegroundColor Green
            Get-ChildItem -Path $typePath -Filter *.log -Recurse | Select-Object -First 20 | ForEach-Object {
                Write-Host "  - $($_.Name)"
            }
            Write-Host ""
        }
    }
    
    # 显示接口日志
    Write-Host "[接口日志]" -ForegroundColor Green
    $today = Get-Date -Format "yyyy-MM-dd"
    foreach ($api in $ApiLogMap.Keys) {
        $prefix = $ApiLogMap[$api]
        $logFile = Join-Path $LogBasePath "${prefix}_${today}.log"
        if (Test-Path $logFile) {
            Write-Host "  ✓ $api -> $(Split-Path $logFile -Leaf)" -ForegroundColor Green
        } else {
            Write-Host "  ○ $api (今日无日志)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# 查看指定类型的日志
function Show-TypeLog {
    param([string]$LogType)
    
    $today = Get-Date -Format "yyyy-MM-dd"
    $monthPath = Get-Date -Format "yyyy-MM"
    $dayPath = Get-Date -Format "dd"
    
    $logFile = Join-Path $LogBasePath "$LogType\$monthPath\$dayPath\${LogType}_${today}.log"
    
    if (Test-Path $logFile) {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  查看 $LogType 日志" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "文件：$logFile" -ForegroundColor Yellow
        Write-Host ""
        Get-Content $logFile -Tail 100 | Out-Host -Paging
    } else {
        Write-Host "未找到 $LogType 日志文件" -ForegroundColor Red
    }
}

# 查看指定接口的日志
function Show-ApiLog {
    param([string]$ApiPath)
    
    $found = $false
    $today = Get-Date -Format "yyyy-MM-dd"
    
    foreach ($api in $ApiLogMap.Keys) {
        if ($api -like "*$ApiPath*" -or $ApiPath -like "*$api*") {
            $found = $true
            $prefix = $ApiLogMap[$api]
            $logFile = Join-Path $LogBasePath "${prefix}_${today}.log"
            
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host "  接口：$api" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "日志文件：$logFile" -ForegroundColor Yellow
            Write-Host ""
            
            if (Test-Path $logFile) {
                Get-Content $logFile -Tail 100 | Out-Host -Paging
            } else {
                Write-Host "该接口今日无日志" -ForegroundColor Yellow
            }
            break
        }
    }
    
    if (-not $found) {
        Write-Host "未找到匹配的接口：$ApiPath" -ForegroundColor Red
        Write-Host "提示：使用 -List 查看所有接口" -ForegroundColor Yellow
    }
}

# 搜索日志
function Search-Log {
    param([string]$Keyword)
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  搜索日志：$Keyword" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $results = Select-String -Path "$LogBasePath\**\*.log" -Pattern $Keyword -SimpleMatch | Select-Object -First 50
    
    if ($results) {
        $results | ForEach-Object {
            Write-Host "$($_.Filename): $($_.Line)"
        }
        Write-Host "`n显示前 50 条匹配结果" -ForegroundColor Yellow
    } else {
        Write-Host "未找到匹配的记录" -ForegroundColor Yellow
    }
}

# 实时监控日志
function Watch-Log {
    param([string]$LogType, [string]$ApiPath)
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  实时监控日志 (Ctrl+C 退出)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $today = Get-Date -Format "yyyy-MM-dd"
    
    if ($ApiPath) {
        foreach ($api in $ApiLogMap.Keys) {
            if ($api -like "*$ApiPath*") {
                $prefix = $ApiLogMap[$api]
                $logPattern = Join-Path $LogBasePath "${prefix}_*.log"
                Write-Host "监控接口：$api" -ForegroundColor Green
                Get-Content $logPattern -Wait -Tail 10 | Out-Host
                break
            }
        }
    } elseif ($LogType) {
        $monthPath = Get-Date -Format "yyyy-MM"
        $dayPath = Get-Date -Format "dd"
        $logFile = Join-Path $LogBasePath "$LogType\$monthPath\$dayPath\${LogType}_${today}.log"
        Write-Host "监控类型：$LogType" -ForegroundColor Green
        Write-Host "日志文件：$logFile" -ForegroundColor Yellow
        Get-Content $logFile -Wait -Tail 10 | Out-Host
    }
}

# 主程序
if ($Help) {
    Show-Help
    exit
}

if ($List) {
    Show-List
    exit
}

if ($Type) {
    Show-TypeLog -LogType $Type
    exit
}

if ($Api) {
    Show-ApiLog -ApiPath $Api
    exit
}

if ($Keyword) {
    Search-Log -Keyword $Keyword
    exit
}

if ($Watch) {
    Watch-Log -LogType $Type -ApiPath $Api
    exit
}

# 交互式菜单
while ($true) {
    Clear-Host
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  日志查看自动化运维工具" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 查看所有可用的日志"
    Write-Host "2. 查看今日请求日志"
    Write-Host "3. 查看今日错误日志"
    Write-Host "4. 查看今日审计日志"
    Write-Host "5. 查看指定接口日志"
    Write-Host "6. 搜索日志"
    Write-Host "7. 实时监控错误日志"
    Write-Host "0. 退出"
    Write-Host ""
    
    $choice = Read-Host "请选择 (0-7)"
    
    switch ($choice) {
        '1' { Show-List; Read-Host "按回车键继续" }
        '2' { Show-TypeLog -LogType 'request'; Read-Host "按回车键继续" }
        '3' { Show-TypeLog -LogType 'error'; Read-Host "按回车键继续" }
        '4' { Show-TypeLog -LogType 'audit'; Read-Host "按回车键继续" }
        '5' { 
            $apiPath = Read-Host "输入接口名称或路径"
            Show-ApiLog -ApiPath $apiPath
            Read-Host "按回车键继续"
        }
        '6' { 
            $keyword = Read-Host "输入搜索关键词"
            Search-Log -Keyword $keyword
            Read-Host "按回车键继续"
        }
        '7' { 
            Write-Host "`n按 Ctrl+C 退出监控" -ForegroundColor Yellow
            Watch-Log -LogType 'error'
        }
        '0' { 
            Write-Host "再见！" -ForegroundColor Green
            exit
        }
        default { 
            Write-Host "无效的选择" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
