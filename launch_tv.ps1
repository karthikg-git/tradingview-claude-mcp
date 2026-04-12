# Auto-detect TradingView Desktop installation (handles version updates)
$tvDir = Get-ChildItem "C:\Program Files\WindowsApps" `
         -Filter "TradingView.Desktop_*_x64_*" `
         -Directory -ErrorAction SilentlyContinue |
         Sort-Object Name -Descending | Select-Object -First 1

if (-not $tvDir) {
    $ctx = "ERROR: TradingView Desktop not found in WindowsApps. Please install it from the Microsoft Store."
    @{ hookSpecificOutput = @{ hookEventName = "UserPromptSubmit"; additionalContext = $ctx } } | ConvertTo-Json -Compress
    exit 1
}

$tvExe = Join-Path $tvDir.FullName "TradingView.exe"

# Kill existing instances
Stop-Process -Name TradingView -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Launch with CDP remote debugging
Start-Process -FilePath $tvExe -ArgumentList "--remote-debugging-port=9222"

# Poll up to 20 seconds for CDP to become available
$ready = $false
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Seconds 2
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("127.0.0.1", 9222)
        $tcp.Close()
        $ready = $true
        break
    } catch {}
}

$ctx = if ($ready) {
    "TradingView launched and CDP is ready on port 9222. Automatically running tv_health_check now to confirm."
} else {
    "TradingView launched but CDP is not ready yet (still loading). Please wait a few seconds, then say 'health check'."
}

@{
    hookSpecificOutput = @{
        hookEventName     = "UserPromptSubmit"
        additionalContext = $ctx
    }
} | ConvertTo-Json -Compress
