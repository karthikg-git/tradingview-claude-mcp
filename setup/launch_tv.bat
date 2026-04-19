@echo off
setlocal enabledelayedexpansion

echo Detecting TradingView installation...
set TVEXE=
for /d %%i in ("C:\Program Files\WindowsApps\TradingView.Desktop_*_x64_*") do (
    if exist "%%i\TradingView.exe" set TVEXE=%%i\TradingView.exe
)

if not defined TVEXE (
    echo ERROR: TradingView Desktop not found.
    echo Please install TradingView from the Microsoft Store.
    pause
    exit /b 1
)

echo Found: %TVEXE%
echo.
echo Killing existing TradingView instances...
taskkill /f /im TradingView.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo Launching TradingView with CDP enabled on port 9222...
start "" "%TVEXE%" --remote-debugging-port=9222

echo Waiting for CDP to become available...
:check
netstat -ano | findstr ":9222 " >nul 2>&1
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto check
)

echo.
echo TradingView is up! CDP listening on port 9222.
echo You can now use Claude Code with the TradingView MCP tools.
