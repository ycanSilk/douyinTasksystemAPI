@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ===============================================================================
REM 日志查看自动化运维脚本 (Windows 批处理版本)
REM 使用方法：view_logs.bat
REM ===============================================================================

REM 配置日志基础路径（可以修改）
if "%LOG_BASE_PATH%"=="" (
    set LOG_BASE_PATH=%~dp0logs
)

REM 颜色定义（需要 Windows 10+）
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
  set "COLOR_GREEN=%%b[32m"
  set "COLOR_YELLOW=%%b[33m"
  set "COLOR_BLUE=%%b[34m"
  set "COLOR_CYAN=%%b[36m"
  set "COLOR_RESET=%%b[0m"
)

REM 显示标题
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  日志查看自动化运维工具%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo.

REM 主菜单
:menu
echo 请选择操作:
echo 1. 查看所有可用的日志
echo 2. 查看今日请求日志
echo 3. 查看今日错误日志
echo 4. 查看今日审计日志
echo 5. 查看指定接口日志
echo 6. 搜索日志
echo 7. 实时监控错误日志
echo 8. 清理旧日志
echo 0. 退出
echo.

set /p choice=请输入选项 (0-8): 

if "%choice%"=="1" goto list_logs
if "%choice%"=="2" goto view_request
if "%choice%"=="3" goto view_error
if "%choice%"=="4" goto view_audit
if "%choice%"=="5" goto view_api
if "%choice%"=="6" goto search_logs
if "%choice%"=="7" goto watch_error
if "%choice%"=="8" goto clean_logs
if "%choice%"=="0" goto exit

echo 无效的选择，请重新输入
echo.
goto menu

REM 列出所有日志
:list_logs
echo.
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  可用的日志文件列表%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo.

for %%t in (request error audit sql operation access cron) do (
    set "type_path=%LOG_BASE_PATH%\%%t"
    if exist "!type_path!" (
        echo %COLOR_GREEN%[%%t]%COLOR_RESET%
        dir /s /b "!type_path!\*.log" 2>nul | findstr /i "%%t" | more
        echo.
    )
)

echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 查看今日请求日志
:view_request
set "today=%date:~0,4%-%date:~5,2%-%date:~8,2%"
set "log_file=%LOG_BASE_PATH%\request\%date:~0,4%-%date:~5,2%\%date:~8,2%\request_%today%.log"

echo.
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  查看请求日志%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo 文件：%COLOR_YELLOW%!log_file!%COLOR_RESET%
echo.

if exist "!log_file!" (
    powershell -Command "Get-Content '!log_file!' -Tail 100 | more"
) else (
    echo %COLOR_YELLOW%今日无请求日志%COLOR_RESET%
)

echo.
echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 查看今日错误日志
:view_error
set "today=%date:~0,4%-%date:~5,2%-%date:~8,2%"
set "log_file=%LOG_BASE_PATH%\error\%date:~0,4%-%date:~5,2%\%date:~8,2%\error_%today%.log"

echo.
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  查看错误日志%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo 文件：%COLOR_YELLOW%!log_file!%COLOR_RESET%
echo.

if exist "!log_file!" (
    powershell -Command "Get-Content '!log_file!' -Tail 100 | more"
) else (
    echo %COLOR_YELLOW%今日无错误日志%COLOR_RESET%
)

echo.
echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 查看今日审计日志
:view_audit
set "today=%date:~0,4%-%date:~5,2%-%date:~8,2%"
set "log_file=%LOG_BASE_PATH%\audit\%date:~0,4%-%date:~5,2%\%date:~8,2%\audit_%today%.log"

echo.
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  查看审计日志%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo 文件：%COLOR_YELLOW%!log_file!%COLOR_RESET%
echo.

if exist "!log_file!" (
    powershell -Command "Get-Content '!log_file!' -Tail 100 | more"
) else (
    echo %COLOR_YELLOW%今日无审计日志%COLOR_RESET%
)

echo.
echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 查看指定接口日志
:view_api
echo.
set /p api_path=输入接口名称或路径 (如：c/tasks/accept): 

REM 根据接口路径查找日志文件
set "log_prefix="
if "%api_path%"=="c/tasks/accept" set "log_prefix=c_tasks_accept"
if "%api_path%"=="c/tasks/submit" set "log_prefix=c_tasks_submit"
if "%api_path%"=="b/auth/register" set "log_prefix=b_auth_register"
if "%api_path%"=="cron/task_check" set "log_prefix=task_check"

if "!log_prefix!"=="" (
    echo %COLOR_YELLOW%未找到匹配的接口日志%COLOR_RESET%
) else (
    set "today=%date:~0,4%-%date:~5,2%-%date:~8,2%"
    set "log_file=%LOG_BASE_PATH%\request\!log_prefix!\%date:~0,4%-%date:~5,2%\%date:~8,2%\!log_prefix!_%today%.log"
    
    echo.
    echo %COLOR_CYAN%========================================%COLOR_RESET%
    echo %COLOR_CYAN%  接口：%api_path%%COLOR_RESET%
    echo %COLOR_CYAN%========================================%COLOR_RESET%
    echo 日志文件：%COLOR_YELLOW%!log_file!%COLOR_RESET%
    echo.
    
    if exist "!log_file!" (
        powershell -Command "Get-Content '!log_file!' -Tail 100 | more"
    ) else (
        echo %COLOR_YELLOW%该接口今日无日志%COLOR_RESET%
    )
)

echo.
echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 搜索日志
:search_logs
echo.
set /p keyword=输入搜索关键词：

echo.
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  搜索日志：%keyword%%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo.

powershell -Command "Select-String -Path '%LOG_BASE_PATH%\**\*.log' -Pattern '%keyword%' | Select-Object -First 50"

echo.
echo %COLOR_YELLOW%显示前 50 条匹配结果%COLOR_RESET%
echo.
echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 实时监控错误日志
:watch_error
echo.
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo %COLOR_CYAN%  实时监控错误日志%COLOR_RESET%
echo %COLOR_CYAN%  (按 Ctrl+C 退出)%COLOR_RESET%
echo %COLOR_CYAN%========================================%COLOR_RESET%
echo.

set "today=%date:~0,4%-%date:~5,2%-%date:~8,2%"
set "log_file=%LOG_BASE_PATH%\error\%date:~0,4%-%date:~5,2%\%date:~8,2%\error_%today%.log"

if exist "!log_file!" (
    powershell -Command "Get-Content '!log_file!' -Wait -Tail 10"
) else (
    echo %COLOR_YELLOW%今日无错误日志%COLOR_RESET%
)

goto menu

REM 清理旧日志
:clean_logs
echo.
echo %COLOR_YELLOW%========================================%COLOR_RESET%
echo %COLOR_YELLOW%  清理旧日志%COLOR_RESET%
echo %COLOR_YELLOW%========================================%COLOR_RESET%
echo.
echo %COLOR_YELLOW%警告：此操作将删除超过 30 天的日志文件！%COLOR_RESET%
echo.
set /p confirm=确定要清理旧日志吗？(y/n): 

if /i "%confirm%"=="y" (
    echo 正在清理...
    forfiles /p "%LOG_BASE_PATH%" /s /m *.log /d -30 /c "cmd /c del @path" 2>nul
    echo %COLOR_GREEN%已删除超过 30 天的日志文件%COLOR_RESET%
    
    REM 删除空目录
    for /f "delims=" %%i in ('dir /b /ad /s "%LOG_BASE_PATH%" 2^>nul') do (
        rd "%%i" 2>nul
    )
    echo %COLOR_GREEN%已清理空目录%COLOR_RESET%
) else (
    echo %COLOR_YELLOW%操作已取消%COLOR_RESET%
)

echo.
echo 按任意键返回菜单...
pause >nul
cls
goto menu

REM 退出
:exit
echo.
echo %COLOR_GREEN%再见！%COLOR_RESET%
exit /b 0
