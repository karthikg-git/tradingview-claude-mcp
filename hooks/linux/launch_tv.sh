#!/bin/bash
# TradingView CDP Launcher - Linux
# Kills existing TradingView, relaunches with CDP on port 9222, polls for readiness

TV_APP="/usr/bin/tradingview"
CDP_PORT=9222
MAX_ATTEMPTS=20

# Try common installation paths
if [ ! -f "$TV_APP" ]; then
    if [ -f "/opt/TradingView/tradingview" ]; then
        TV_APP="/opt/TradingView/tradingview"
    elif [ -f "$HOME/.local/bin/tradingview" ]; then
        TV_APP="$HOME/.local/bin/tradingview"
    else
        echo '{"status":"error","message":"TradingView not found. Install from https://www.tradingview.com/desktop/"}'
        exit 1
    fi
fi

# Kill all existing TradingView processes
pkill -f "tradingview" 2>/dev/null
sleep 2

# Launch with remote debugging port enabled
"$TV_APP" --remote-debugging-port=$CDP_PORT \
    --user-data-dir="$HOME/.config/TradingView" \
    > /tmp/tradingview_launch.log 2>&1 &

# Poll for CDP readiness
for i in $(seq 1 $MAX_ATTEMPTS); do
    if nc -z 127.0.0.1 $CDP_PORT 2>/dev/null; then
        # Verify CDP responds with JSON
        TARGETS=$(curl -s --max-time 3 "http://127.0.0.1:$CDP_PORT/json" 2>/dev/null)
        if [ -n "$TARGETS" ]; then
            echo "{\"status\":\"ready\",\"cdp_port\":$CDP_PORT,\"message\":\"TradingView CDP is ready\",\"attempt\":$i}"
            exit 0
        fi
    fi
    sleep 1
done

echo "{\"status\":\"timeout\",\"cdp_port\":$CDP_PORT,\"message\":\"TradingView CDP did not respond within ${MAX_ATTEMPTS}s — try health check\"}"
exit 1
