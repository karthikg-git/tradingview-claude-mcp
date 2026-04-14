# TradingView CDP Launcher - Windows
# Kills existing TradingView, relaunches with CDP on port 9222, polls for readiness

$TV_APP_PATHS = @(
    "$env:LOCALAPPDATA\Programs\TradingView\TradingView.exe",
    "$env:ProgramFiles\TradingView\TradingView.exe",
    "$env:ProgramFiles(x86)\TradingView\TradingView.exe"
)

$CDP_PORT = 9222
$MAX_ATTEMPTS = 20

# Find TradingView executable
$TV_APP = $null
foreach ($path in $TV_APP_PATHS) {
    if (Test-Path $path) {
        $TV_APP = $path
        break
    }
}

if (-not $TV_APP) {
    Write-Output '{"status":"error","message":"TradingView.exe not found. Install from https://www.tradingview.com/desktop/"}'
    exit 1
}

# Kill all existing TradingView processes
Get-Process -Name "TradingView" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Launch with remote debugging port enabled
$userDataDir = Join-Path $env:APPDATA "TradingView"
$logFile = Join-Path $env:TEMP "tradingview_launch.log"

Start-Process -FilePath $TV_APP `
    -ArgumentList "--remote-debugging-port=$CDP_PORT", "--user-data-dir=`"$userDataDir`"" `
    -RedirectStandardOutput $logFile `
    -RedirectStandardError $logFile `
    -WindowStyle Hidden

# Poll for CDP readiness
for ($i = 1; $i -le $MAX_ATTEMPTS; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$CDP_PORT/json" -TimeoutSec 3 -ErrorAction Stop
        if ($response.Content) {
            Write-Output "{`"status`":`"ready`",`"cdp_port`":$CDP_PORT,`"message`":`"TradingView CDP is ready`",`"attempt`":$i}"
            exit 0
        }
    } catch {
        Start-Sleep -Seconds 1
    }
}

Write-Output "{`"status`":`"timeout`",`"cdp_port`":$CDP_PORT,`"message`":`"TradingView CDP did not respond within ${MAX_ATTEMPTS}s — try health check`"}"
exit 1
