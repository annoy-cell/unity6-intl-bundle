@echo off
setlocal
cd /d "%~dp0"
title Unity 6 Bundle - Batch Download

echo ============================================
echo   Unity 6 Bundle - download / verify / extract
echo ============================================
echo.
echo  Default folder (this script's folder):
echo  %~dp0
echo.
set "DEST=%~dp0"
set /p INPUT=Press Enter to use default, or type another folder (e.g. D:\Unity6):
if not "%INPUT%"=="" set "DEST=%INPUT%"
echo.
echo  Target: %DEST%
echo  Starting... keep this window open.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_and_extract.ps1" -Destination "%DEST%"
echo.
echo Finished. Press any key to close.
pause >nul