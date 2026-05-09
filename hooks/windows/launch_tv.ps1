# TradingView CDP Launcher - Windows (Chrome PWA mode)
# Kills existing Chrome TV app, relaunches with CDP on port 9222, polls for readiness

$CHROME_EXE = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$TV_USER_DATA = "$env:LOCALAPPDATA\TradingViewChrome"
$CDP_PORT = 9222
$MAX_ATTEMPTS = 30

# Kill any Chrome instance using the TV user data dir
Get-Process -Name "chrome" -ErrorAction SilentlyContinue | ForEach-Object {
    $cmdline = (Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
    if ($cmdline -and $cmdline -match "TradingViewChrome") {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}
Start-Sleep -Seconds 2

# Launch Chrome as TradingView PWA with remote debugging
Start-Process -FilePath $CHROME_EXE `
    -ArgumentList "--app=https://www.tradingview.com/chart/", `
        "--user-data-dir=`"$TV_USER_DATA`"", `
        "--remote-debugging-port=$CDP_PORT", `
        "--no-first-run", `
        "--no-default-browser-check"

# Give Chrome time to bind the port before polling
Start-Sleep -Seconds 5

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

Write-Output "{`"status`":`"timeout`",`"cdp_port`":$CDP_PORT,`"message`":`"TradingView CDP did not respond within ${MAX_ATTEMPTS}s - try health check`"}"
exit 1
