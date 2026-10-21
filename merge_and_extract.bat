@echo off
chcp 936 >nul
setlocal
cd /d "%~dp0"

set "OUT=unity6-intl-bundle.zip"
set "EXPECT=5327028600"

echo ==========================================
echo   Unity 6 整合包 - 分卷合并 / 自动解压
echo ==========================================
echo.

for %%i in (001 002 003 004 005) do (
  if not exist "unity6-intl-bundle.zip.%%i" (
    echo [错误] 缺少分卷文件: unity6-intl-bundle.zip.%%i
    echo        请把 5 个分卷全部下载到本目录后再运行本脚本。
    pause
    exit /b 1
  )
)

echo [1/3] 分卷检查 ... 5 个分卷齐全
echo.

echo [2/3] 正在合并 5 个分卷, 共约 5 GB, 请稍候 ...
if exist "%OUT%" del /f /q "%OUT%"
copy /b /y unity6-intl-bundle.zip.001+unity6-intl-bundle.zip.002+unity6-intl-bundle.zip.003+unity6-intl-bundle.zip.004+unity6-intl-bundle.zip.005 "%OUT%" >nul
if errorlevel 1 goto :mergefail

for %%A in ("%OUT%") do set "SZ=%%~zA"
echo       合并完成: %OUT%  大小 %SZ% 字节
if not "%SZ%"=="%EXPECT%" (
  echo       [警告] 期望 %EXPECT% 字节, 实际 %SZ% 字节, 可能有分卷没下载完整。
  echo              建议重新下载缺失部分, 或先对照 SHA256SUMS.txt 校验。
  pause
)
echo.

echo [3/3] 正在解压 ...
where tar >nul 2>nul
if errorlevel 1 goto :unzip_ps
tar -xf "%OUT%"
if errorlevel 1 goto :unzip_fail
goto :done

:unzip_ps
echo       未找到 tar, 改用 PowerShell 解压, 速度较慢请耐心等待 ...
powershell -NoProfile -Command "Expand-Archive -LiteralPath '%OUT%' -DestinationPath '.' -Force"
if errorlevel 1 goto :unzip_fail

:done
echo.
echo 已全部完成。
echo 解压目录: 国际版 UnityHub 和 Unity6编辑器 及教程
echo.
pause
exit /b 0

:mergefail
echo [错误] 合并失败, 请确认磁盘剩余空间是否充足。
pause
exit /b 1

:unzip_fail
echo [错误] 自动解压失败, 请手动用 7-Zip 解压 %OUT% 。
pause
exit /b 1