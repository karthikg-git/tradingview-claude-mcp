# TradingView Claude MCP - Complete Edition

**Control TradingView Desktop from Claude Code with 78 MCP tools + automated installation**

Built on [tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp) by [@tradesdontlie](https://github.com/tradesdontlie) and [tradingview-mcp-jackson](https://github.com/LewisWJackson/tradingview-mcp-jackson) by [@LewisWJackson](https://github.com/LewisWJackson). This edition adds **fully automated installation for macOS/Linux/Windows** plus comprehensive documentation.

> [!WARNING]
> **Not affiliated with TradingView Inc. or Anthropic.** This tool connects to your locally running TradingView Desktop app via Chrome DevTools Protocol. Review the [Disclaimer](#disclaimer) before use.

> [!IMPORTANT]
> **Requires a valid TradingView subscription.** This tool does not bypass any TradingView paywall. It reads from and controls the TradingView Desktop app already running on your machine.

> [!NOTE]
> **All data processing happens locally.** Nothing is sent anywhere. No TradingView data leaves your machine.

---

## 🚀 Quick Install (Single Command)

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

**That's it!** The installer:
- ✅ Installs all npm dependencies
- ✅ Configures `~/.claude/.mcp.json`
- ✅ Sets up hooks for auto-launch
- ✅ Creates `rules.json` template
- ✅ Verifies prerequisites
- ✅ Backs up existing configs

Restart Claude Code and type `health check` to verify.

**Full installation guide:** [INSTALL.md](INSTALL.md)  
**Quick start guide:** [QUICKSTART.md](QUICKSTART.md)

---

## ✨ What This Tool Does

- **Read your chart** - Symbol, timeframe, all visible indicators, real-time price
- **Control TradingView** - Change symbols, add indicators, take screenshots, navigate charts
- **Morning brief** - One command scans watchlist, reads indicators, generates session bias
- **Pine development** - Write, compile, debug Pine scripts with Claude
- **Strategy testing** - Backtest performance, analyze trades, extract metrics
- **Replay mode** - Practice with historical data, simulate trades
- **Multi-chart analysis** - Scan multiple symbols simultaneously
- **Custom indicator data** - Read Pine drawings (lines, labels, tables, boxes)

---

## 📋 Prerequisites

| Component | Required Version | Install |
|-----------|-----------------|---------|
| **Node.js** | v18+ | [nodejs.org](https://nodejs.org/) |
| **TradingView Desktop** | Latest | [tradingview.com/desktop](https://www.tradingview.com/desktop/) |
| **Claude Code** | Latest | [claude.ai/code](https://claude.ai/code) |
| **TradingView Subscription** | Paid plan for real-time data | [tradingview.com/pricing](https://www.tradingview.com/pricing/) |

**Platform Support:** macOS, Windows, Linux

---

## 🎯 Key Features

### 1. Morning Brief Workflow

```
morning brief on SPY
```

Claude will:
1. Launch TradingView with CDP (if needed)
2. Set chart to your symbol
3. Read all visible indicators (RSI, MACD, EMA, custom indicators)
4. Apply your trading rules from `rules.json`
5. Generate session bias with entry/exit levels

### 2. Chart Reading

```
What's on my TradingView chart right now?
```

Claude uses `chart_get_state` to read:
- Current symbol and timeframe
- All visible indicators
- Chart type and style
- Pane layout

### 3. Pine Script Development

```
Create an RSI divergence indicator in Pine
```

Claude will:
1. Write Pine v5/v6 code
2. Compile with `pine_smart_compile`
3. Check for errors
4. Debug and fix issues
5. Add to your chart

### 4. Strategy Backtesting

```
Backtest my current strategy on Bitcoin
```

Claude reads strategy tester results:
- Net profit, win rate, profit factor
- Max drawdown, Sharpe ratio
- Individual trades with entry/exit
- Equity curve

### 5. Multi-Symbol Scanning

```
Scan AAPL, MSFT, GOOGL for oversold conditions
```

Claude analyzes multiple charts in parallel:
- Changes symbols automatically
- Reads indicators for each
- Compares and ranks results

### 6. Replay Mode Practice

```
Start replay on ES1! from last Monday
```

Claude controls replay mode:
- Sets up replay from specific date
- Steps through bars
- Simulates trades
- Analyzes performance

---

## 🔧 78 MCP Tools Available

### Chart Control
- `chart_get_state` - Read symbol, timeframe, indicators
- `chart_set_symbol` - Change ticker
- `chart_set_timeframe` - Change resolution
- `chart_set_type` - Change chart type (candles, line, etc.)
- `chart_manage_indicator` - Add/remove indicators
- `chart_scroll_to_date` - Navigate to specific date
- `chart_get_visible_range` - Get visible time range
- `chart_set_visible_range` - Set zoom level

### Data Reading
- `quote_get` - Real-time price snapshot
- `data_get_ohlcv` - Price bars (open, high, low, close, volume)
- `data_get_study_values` - All indicator values
- `data_get_strategy_results` - Backtest metrics
- `data_get_trades` - Strategy trade list
- `data_get_equity` - Equity curve data

### Custom Indicator Data (Pine Drawings)
- `data_get_pine_lines` - Horizontal levels from Pine indicators
- `data_get_pine_labels` - Text annotations
- `data_get_pine_tables` - Table data
- `data_get_pine_boxes` - Price zones

### Pine Script
- `pine_list_scripts` - List saved scripts
- `pine_open` - Open script in editor
- `pine_get_source` - Read script code
- `pine_set_source` - Update script code
- `pine_smart_compile` - Compile with auto-fix
- `pine_compile` - Standard compile
- `pine_check` - Check syntax
- `pine_get_errors` - Read compilation errors
- `pine_get_console` - Read Pine console output
- `pine_analyze` - Analyze code quality

### Indicators
- `indicator_set_inputs` - Change indicator settings
- `indicator_toggle_visibility` - Show/hide indicator

### Screenshots
- `capture_screenshot` - Take chart snapshot (full/chart/strategy_tester)

### Replay Mode
- `replay_start` - Start replay from date
- `replay_step` - Step forward/backward
- `replay_stop` - Exit replay
- `replay_status` - Check replay state
- `replay_trade` - Simulate trade
- `replay_autoplay` - Play automatically

### Alerts
- `alert_create` - Create price alert
- `alert_list` - List active alerts
- `alert_delete` - Remove alert

### Tabs & Layouts
- `tab_list` - List open tabs
- `tab_new` - Open new tab
- `tab_switch` - Switch to tab
- `tab_close` - Close tab
- `layout_list` - List saved layouts
- `layout_switch` - Switch layout

### Watchlist
- `watchlist_get` - Read watchlist symbols
- `watchlist_add` - Add symbol to watchlist

### Multi-Pane
- `pane_list` - List chart panes
- `pane_focus` - Focus specific pane
- `pane_set_layout` - Change pane layout
- `pane_set_symbol` - Set symbol for pane

### Drawing Tools
- `draw_shape` - Draw lines, rectangles, text
- `draw_list` - List drawings
- `draw_get_properties` - Get drawing properties
- `draw_remove_one` - Remove specific drawing
- `draw_clear` - Clear all drawings

### Market Data
- `symbol_search` - Search for symbols
- `symbol_info` - Get symbol details
- `depth_get` - Get order book depth (if available)

### Utility
- `tv_health_check` - Check CDP connection
- `tv_launch` - Launch TradingView with CDP
- `tv_ui_state` - Get UI state
- `tv_discover` - Discover available tools
- `batch_run` - Run multiple actions across symbols/timeframes
- `morning_brief` - **NEW** - Complete morning workflow
- `session_save` / `session_get` - **NEW** - Save/load daily briefs

### UI Automation (Advanced)
- `ui_click`, `ui_hover`, `ui_type_text`, `ui_keyboard`
- `ui_find_element`, `ui_evaluate`, `ui_scroll`
- `ui_open_panel`, `ui_fullscreen`

---

## 📁 Repository Structure

```
tradingview-claude-mcp/
├── src/
│   ├── server.js          # MCP server entry point
│   ├── connection.js      # CDP connection manager
│   ├── wait.js            # Polling utilities
│   ├── tools/             # MCP tool implementations
│   ├── core/              # Core functions
│   └── cli/               # CLI commands
├── hooks/
│   ├── macos/             # macOS launch scripts
│   ├── linux/             # Linux launch scripts
│   └── windows/           # Windows PowerShell scripts
├── config/
│   ├── mcp.json.example   # MCP config template
│   └── settings.json.example  # Claude settings template
├── skills/                # Pre-built workflows
│   ├── chart-analysis/
│   ├── morning-brief/
│   ├── pine-develop/
│   ├── replay-practice/
│   └── strategy-report/
├── scripts/               # Legacy launch scripts
├── tests/                 # Test suites
├── install.sh             # macOS/Linux installer
├── install.ps1            # Windows installer
├── package.json           # npm dependencies
├── rules.example.json     # Trading rules template
├── README.md              # This file
├── INSTALL.md             # Detailed installation guide
├── QUICKSTART.md          # Quick start guide
├── SETUP_GUIDE.md         # Manual setup guide
├── TROUBLESHOOTING.md     # Common issues
└── LICENSE                # MIT License
```

---

## ⚙️ Configuration

### Trading Rules (`rules.json`)

Customize your trading strategy:

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
    "Price below EMA 9"
  ],
  "riskRules": {
    "maxPositionSize": "10% of account",
    "stopLoss": "2% below entry",
    "profitTarget": "1:2 risk-reward"
  }
}
```

### MCP Configuration (`~/.claude/.mcp.json`)

Automatically configured by installer:

```json
{
  "mcpServers": {
    "tradingview": {
      "command": "node",
      "args": ["/path/to/tradingview-claude-mcp/src/server.js"]
    }
  }
}
```

### Hooks Configuration (`~/.claude/settings.json`)

Auto-launch TradingView when you mention it:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)tradingview",
        "hooks": [{
          "type": "command",
          "command": "bash /path/to/hooks/macos/launch_tv.sh",
          "timeout": 45000
        }]
      }
    ]
  },
  "enabledMcpjsonServers": ["tradingview"]
}
```

---

## 🧪 Testing

Run test suites:

```bash
npm test              # All tests
npm run test:e2e      # End-to-end tests
npm run test:unit     # Unit tests
npm run test:cli      # CLI tests
```

---

## 🛠️ CLI Usage

Use standalone without Claude Code:

```bash
# Chart operations
tv chart                    # Get current state
tv chart --symbol AAPL      # Change symbol
tv chart --timeframe 15     # Change timeframe

# Data
tv data ohlcv --summary     # Get price bars
tv quote                    # Real-time price
tv data indicators          # All indicator values

# Pine Script
tv pine list                # List scripts
tv pine compile --file my_script.pine
tv pine errors              # Show compilation errors

# Alerts
tv alert create --symbol SPY --condition "Price > 450"
tv alert list
tv alert delete <id>

# Replay
tv replay start --date 2026-04-01
tv replay step --bars 10
tv replay stop

# Screenshots
tv capture                  # Full screenshot
tv capture --region chart   # Chart only

# Morning brief
tv brief                    # Quick morning workflow
```

---

## 🐛 Troubleshooting

### MCP Server Not Loading

**Solution:**
1. Check `~/.claude/.mcp.json` exists
2. Verify path to `server.js` is correct
3. Restart Claude Code completely
4. Run: `node ~/tradingview-claude-mcp/src/server.js` to test manually

### Hooks Not Triggering

**Solution:**
1. Check `~/.claude/settings.json` has `UserPromptSubmit` hooks
2. Test manually: `bash ~/.claude/hooks/tradingview/launch_tv.sh`
3. Check hook logs in Claude Code

### CDP Connection Failed

**Solution:**
1. Quit TradingView completely
2. Type `tradingview` to relaunch with CDP
3. Verify port 9222 is open: `curl http://127.0.0.1:9222/json`
4. Check logs: `tail -f /tmp/tradingview_launch.log`

**Full troubleshooting guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📖 Documentation

- [Installation Guide](INSTALL.md) - Detailed setup instructions
- [Quick Start](QUICKSTART.md) - Get started in 5 minutes
- [Setup Guide](SETUP_GUIDE.md) - Manual configuration
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and fixes

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 🔒 Security

- All data processing happens locally
- No data sent to external servers
- CDP runs on localhost only
- Review [SECURITY.md](SECURITY.md) for details

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

## 🙏 Credits

Built on top of:
- [tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp) by [@tradesdontlie](https://github.com/tradesdontlie)
- [tradingview-mcp-jackson](https://github.com/LewisWJackson/tradingview-mcp-jackson) by [@LewisWJackson](https://github.com/LewisWJackson)

This edition adds:
- ✅ Fully automated installation (macOS/Linux/Windows)
- ✅ Comprehensive documentation
- ✅ Hook scripts for all platforms
- ✅ Enhanced troubleshooting guides
- ✅ Quick start guides
- ✅ Configuration examples

---

## ⚠️ Disclaimer

**THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.**

- Not affiliated with TradingView Inc. or Anthropic
- Not financial advice - use at your own risk
- Requires valid TradingView subscription
- Does not bypass any TradingView features or paywalls
- All trading decisions are your own responsibility
- Review all code before running
- Use in compliance with TradingView Terms of Service

By using this tool you acknowledge:
- You have a valid TradingView subscription
- You understand the risks of automated trading tools
- You will not hold the authors liable for any losses
- You will comply with all applicable laws and regulations

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/karthikg-git/tradingview-claude-mcp/issues)
- **Discussions:** [GitHub Discussions](https://github.com/karthikg-git/tradingview-claude-mcp/discussions)
- **Documentation:** [Wiki](https://github.com/karthikg-git/tradingview-claude-mcp/wiki)

---

**Ready to supercharge your TradingView workflow with Claude?**  
Install now and type `morning brief on SPY` to get started! 🚀
