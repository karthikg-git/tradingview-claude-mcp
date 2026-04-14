# TradingView CDP Health Check - Windows

$CDP_PORT = 9222

try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:$CDP_PORT/json" -TimeoutSec 3 -ErrorAction Stop
    if ($response.Content) {
        $pages = ([regex]::Matches($response.Content, '"type":"page"')).Count
        Write-Output "{`"status`":`"ready`",`"cdp_port`":$CDP_PORT,`"pages`":`"$pages`",`"message`":`"CDP is healthy`"}"
        exit 0
    }
} catch {
    Write-Output "{`"status`":`"not_ready`",`"cdp_port`":$CDP_PORT,`"message`":`"TradingView CDP is not responding — type tradingview to launch`"}"
    exit 1
}
