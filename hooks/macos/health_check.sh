#!/bin/bash
# TradingView CDP Health Check - macOS
CDP_PORT=9222

if nc -z 127.0.0.1 $CDP_PORT 2>/dev/null; then
    TARGETS=$(curl -s --max-time 3 "http://127.0.0.1:$CDP_PORT/json" 2>/dev/null)
    if [ -n "$TARGETS" ]; then
        PAGE_COUNT=$(echo "$TARGETS" | grep -c '"type":"page"' 2>/dev/null || echo "unknown")
        echo "{\"status\":\"ready\",\"cdp_port\":$CDP_PORT,\"pages\":\"$PAGE_COUNT\",\"message\":\"CDP is healthy\"}"
        exit 0
    fi
fi

echo "{\"status\":\"not_ready\",\"cdp_port\":$CDP_PORT,\"message\":\"TradingView CDP is not responding — type tradingview to launch\"}"
exit 1
