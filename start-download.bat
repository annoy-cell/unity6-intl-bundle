@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Unity 6 整合包 - 批量下载

echo ============================================
echo   Unity 6 整合包 - 批量下载 / 校验 / 解压
echo ============================================
echo.
echo  默认下载到本脚本所在目录：
echo  %~dp0
echo.
set "DEST=%~dp0"
set /p INPUT=直接回车用默认路径，或输入其他目录（例如 D:\Unity6）:
if not "%INPUT%"=="" set "DEST=%INPUT%"
echo.
echo  目标目录: %DEST%
echo  正在启动下载，请保持窗口打开 ...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_and_extract.ps1" -Destination "%DEST%"
echo.
echo 脚本已结束。
pause