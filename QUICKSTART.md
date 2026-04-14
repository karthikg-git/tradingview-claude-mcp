# Quick Start Guide

Get up and running with TradingView Claude MCP in under 5 minutes.

---

## Installation (Choose Your Platform)

### macOS / Linux

```bash
git clone https://github.com/karthikg-git/tradingview-claude-mcp.git
cd tradingview-claude-mcp
bash install.sh
```

### Windows

```powershell
git clone https://github.com/karthikg-git/tradingview-claude-mcp.git
cd tradingview-claude-mcp
.\install.ps1
```

**Done!** The installer handles everything automatically.

---

## Verification

Restart Claude Code, then test each component:

### 1. Health Check
```
health check
```

**Expected:** `{"status":"ready",...}` or `{"status":"not_ready",...}`

### 2. Launch TradingView
```
tradingview
```

**Expected:** TradingView Desktop launches with CDP enabled

### 3. Read Chart State
```
What symbol is on my chart?
```

**Expected:** Claude uses `chart_get_state` and tells you the symbol

### 4. Morning Brief
```
Give me a morning brief on AAPL
```

**Expected:** Complete market analysis with indicators

---

## Daily Workflow Examples

### Market Analysis
```
Analyze SPY on the 5-minute chart with RSI and MACD
```

### Strategy Backtest
```
Run a backtest on my current Pine strategy and show me the performance
```

### Multi-Symbol Scan
```
Scan AAPL, MSFT, GOOGL on the daily chart and tell me which ones are oversold
```

### Replay Practice
```
Start replay mode on ES1! from last Monday and simulate my scalping setup
```

### Custom Indicator Data
```
Get the support and resistance levels from my "Profiler" indicator
```

---

## Key Features

| Feature | What It Does | Example Prompt |
|---------|--------------|----------------|
| **Morning Brief** | Market snapshot with technical analysis | `morning brief on SPY` |
| **Chart Reading** | Read symbol, timeframe, indicators | `what indicators are on my chart?` |
| **Pine Development** | Write, compile, debug Pine scripts | `create an RSI divergence indicator` |
| **Strategy Testing** | Backtest and analyze performance | `backtest my strategy on Bitcoin` |
| **Replay Mode** | Practice with historical data | `replay last Friday on TSLA 1-min` |
| **Multi-Chart Scan** | Analyze multiple symbols | `scan tech stocks for breakouts` |

---

## Essential Tools (Auto-Loaded)

Claude has access to 78 MCP tools. Most commonly used:

- `chart_get_state` - Read current chart
- `data_get_study_values` - Get indicator values
- `quote_get` - Real-time price
- `data_get_ohlcv` - Price bars
- `chart_set_symbol` - Change ticker
- `chart_set_timeframe` - Change resolution
- `chart_manage_indicator` - Add/remove indicators
- `pine_smart_compile` - Compile Pine scripts
- `data_get_strategy_results` - Backtest metrics
- `capture_screenshot` - Take chart snapshot

Full list: See [README.md](README.md) Tool Reference section.

---

## Customization

### Trading Rules

Edit `rules.json` to define your strategy:

```json
{
  "timeframe": "5m",
  "symbols": ["SPY", "QQQ", "IWM"],
  "indicators": {
    "rsi": { "length": 14, "overbought": 70, "oversold": 30 },
    "macd": { "fast": 12, "slow": 26, "signal": 9 },
    "ema": { "lengths": [9, 21, 50] }
  },
  "entryRules": [
    "RSI < 30 (oversold)",
    "Price above EMA 9",
    "MACD histogram positive"
  ],
  "exitRules": [
    "RSI > 70 (overbought)",
    "Price below EMA 9",
    "MACD crossover below signal"
  ]
}
```

### Hooks Customization

Edit `~/.claude/settings.json` to change triggers:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)(tradingview|tv|chart)",
        "hooks": [...]
      }
    ]
  }
}
```

---

## CLI Usage (Advanced)

Use standalone CLI without Claude Code:

```bash
# Get current chart state
tv chart

# Set symbol
tv chart --symbol TSLA

# Get OHLCV data
tv data ohlcv --summary

# List Pine scripts
tv pine list

# Compile Pine script
tv pine compile --file my_strategy.pine

# Create alert
tv alert create --symbol SPY --condition "Price crosses above 450"

# Take screenshot
tv capture --region chart
```

---

## Troubleshooting

### "MCP tools not available"

**Fix:**
1. Check `~/.claude/.mcp.json` exists
2. Verify `"tradingview"` in `enabledMcpjsonServers`
3. Restart Claude Code completely

### "Hooks not triggering"

**Fix:**
1. Check `~/.claude/settings.json` has `UserPromptSubmit` hooks
2. Test manually: `bash ~/.claude/hooks/tradingview/launch_tv.sh`
3. Check Claude Code hook logs

### "CDP not ready"

**Fix:**
1. Quit TradingView completely
2. Type `tradingview` to relaunch with CDP
3. Check: `curl http://127.0.0.1:9222/json`

Full troubleshooting: See [INSTALL.md](INSTALL.md)

---

## Next Steps

1. ✅ **Explore Skills** - Pre-built workflows in `/skills/`
2. ✅ **Read Full Docs** - [README.md](README.md) for all 78 tools
3. ✅ **Customize Rules** - Edit `rules.json` for your strategy
4. ✅ **Join Community** - Report issues, share workflows

---

## Quick Reference Card

| Task | Prompt |
|------|--------|
| Launch TradingView | `tradingview` |
| Health check | `health check` |
| Morning brief | `morning brief on SPY` |
| Analyze chart | `analyze this chart` |
| Change symbol | `show me AAPL` |
| Add indicator | `add RSI to chart` |
| Backtest strategy | `run backtest` |
| Screenshot | `take a screenshot` |
| Replay mode | `start replay from last Monday` |
| Multi-symbol scan | `scan SPY, QQQ, IWM for setups` |

---

**Ready to trade smarter with Claude?**  
Type `morning brief on SPY` to get started! 🚀
