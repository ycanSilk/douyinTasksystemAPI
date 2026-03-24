@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ===============================================================================
REM 日志系统配置向导
REM 使用方法：setup_logs.bat
REM ===============================================================================

echo.
echo ========================================
echo   日志系统配置向导
echo ========================================
echo.
echo 本向导将帮助您配置日志系统
echo.

REM 询问是否使用默认配置
set /p use_default="是否使用默认配置？(Y/N，默认 Y): "
if /i "!use_default!"=="" set "use_default=Y"
if /i "!use_default!"=="Y" goto use_default_config
if /i "!use_default!"=="N" goto custom_config

:use_default_config
echo.
echo 使用默认配置:
echo - 日志路径：%~dp0logs
echo - 请求日志保留：30 天
echo - 错误日志保留：90 天
echo - 审计日志保留：365 天
echo.
goto create_config

:custom_config
echo.
set /p log_path="请输入日志基础路径 (默认：%~dp0logs): "
if "!log_path!"=="" set "log_path=%~dp0logs"

set /p request_days="请输入请求日志保留天数 (默认：30): "
if "!request_days!"=="" set "request_days=30"

set /p error_days="请输入错误日志保留天数 (默认：90): "
if "!error_days!"=="" set "error_days=90"

set /p audit_days="请输入审计日志保留天数 (默认：365): "
if "!audit_days!"=="" set "audit_days=365"

:create_config
echo.
echo 正在创建配置文件...

REM 创建日志配置目录
if not exist "%~dp0config" mkdir "%~dp0config"

REM 创建配置文件
(
echo # 日志系统配置文件
echo # 自动生成于 %date% %time%
echo.
echo LOG_BASE_PATH="!log_path!"
echo LOG_RETENTION_DAYS=!request_days!
echo ERROR_LOG_RETENTION_DAYS=!error_days!
echo AUDIT_LOG_RETENTION_DAYS=!audit_days!
echo LOG_ROTATION_ENABLED=1
echo ASYNC_LOG_ENABLED=1
echo SENSITIVE_DATA_MASK_ENABLED=1
) > "%~dp0config\log_config.bat"

echo 配置文件已创建：%~dp0config\log_config.bat
echo.

REM 创建日志目录
echo 正在创建日志目录结构...
for %%d in (request error audit sql operation access cron) do (
    if not exist "!log_path!\%%d" mkdir "!log_path!\%%d"
    echo 创建目录：!log_path!\%%d
)

echo.
echo ========================================
echo   配置完成！
echo ========================================
echo.
echo 配置文件位置：%~dp0config\log_config.bat
echo 日志存储位置：!log_path!
echo.
echo 下一步:
echo 1. 在每个接口文件中添加 LoggerRouter::setContext^(^)
echo 2. 运行 view_logs.bat 查看日志
echo 3. 查看文档：docs\分级日志系统使用指南.md
echo.

set /p open_doc="是否打开使用指南？(Y/N): "
if /i "!open_doc!"=="Y" (
    start notepad "%~dp0docs\分级日志系统使用指南.md"
)

echo.
echo 按任意键退出...
pause >nul
