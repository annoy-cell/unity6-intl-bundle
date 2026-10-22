@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "OUT=unity6-intl-bundle.zip"
set "EXPECT=5327028600"

echo ============================================
echo   Unity 6 Bundle - merge 36 parts and extract
echo ============================================
echo.

set "MISSING="
for /l %%i in (1,1,36) do (
  set "N=00%%i"
  set "IDX=!N:~-3!"
  if not exist "part-!IDX!" set "MISSING=!MISSING! part-!IDX!"
)
if not "%MISSING%"=="" (
  echo [ERROR] Missing parts:
  echo        %MISSING%
  echo        Download all 36 parts into this folder first.
  pause
  exit /b 1
)

echo [1/3] All 36 parts found.
echo.
echo [2/3] Merging 36 parts into %OUT% ... about 5 GB, please wait.
if exist "%OUT%" del /f /q "%OUT%"
copy /b /y part-001+part-002+part-003+part-004+part-005+part-006+part-007+part-008+part-009+part-010+part-011+part-012+part-013+part-014+part-015+part-016+part-017+part-018+part-019+part-020+part-021+part-022+part-023+part-024+part-025+part-026+part-027+part-028+part-029+part-030+part-031+part-032+part-033+part-034+part-035+part-036 "%OUT%" >nul
if errorlevel 1 goto :mergefail

for %%A in ("%OUT%") do set "SZ=%%~zA"
echo       Merged size: %SZ% bytes
if not "%SZ%"=="%EXPECT%" (
  echo       [WARN] expected %EXPECT% bytes, got %SZ% - a part may be incomplete.
  echo              Re-download the missing part, or check SHA256SUMS.txt.
  pause
)
echo.
echo [3/3] Extracting ...
where tar >nul 2>nul
if errorlevel 1 goto :unzip_ps
tar -xf "%OUT%"
if errorlevel 1 goto :unzip_fail
goto :done

:unzip_ps
echo       tar not found, using PowerShell (slower) ...
powershell -NoProfile -Command "Expand-Archive -LiteralPath '%OUT%' -DestinationPath '.' -Force"
if errorlevel 1 goto :unzip_fail

:done
echo.
echo All done.
echo Output folder: the extracted directory in this folder
echo.
pause
exit /b 0

:mergefail
echo [ERROR] Merge failed - check free disk space (need about 11 GB).
pause
exit /b 1

:unzip_fail
echo [ERROR] Auto-extract failed - please extract %OUT% with 7-Zip manually.
pause
exit /b 1