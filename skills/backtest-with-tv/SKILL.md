---
name: backtest-with-tv
description: Upload latest Pine Script strategy from disk to TradingView, compile it, run backtest, and report results. Use when ready to test a strategy after editing locally.
---

# Backtest with TradingView

Upload the latest local Pine Script to TradingView, compile, backtest, and report results.

## Step 1: Find the Strategy File

The user may specify a file. If not, default to the current best:
`strategies/QQQ_ORB_PST6_8_trail.pine`

List available strategies if user is unsure:
```bash
ls strategies/*.pine
```

Read the target file:
```bash
cat strategies/<filename>.pine
```

## Step 2: Health Check

Verify TradingView is connected before proceeding:
- `tv_health_check` → must return `cdp_connected: true`

If not connected, tell user to type `tradingview` to launch TV first.

## Step 3: Get Chart State

- `chart_get_state` → note current symbol, timeframe, and any existing studies

## Step 4: Upload to TradingView

- `pine_set_source` with the full file contents read in Step 1
- Confirm upload succeeded

## Step 5: Compile

- `pine_smart_compile` → compile and auto-detect errors

If errors returned:
1. Read each error (line number + message)
2. Fix in the local file: edit `strategies/<filename>.pine`
3. Re-read fixed file → `pine_set_source` again → `pine_smart_compile`
4. Repeat until 0 errors

Do NOT proceed to backtest with compile errors.

## Step 6: Add to Chart

After clean compile, click "Add to chart" or "Update on chart":
- `ui_click` with text "Add to chart" OR "Update on chart"

Wait 2 seconds for strategy to load, then:
- `capture_screenshot` region "chart" — confirm strategy overlay visible

## Step 7: Open Strategy Tester

- `ui_open_panel` with panel "strategy-tester"

Wait for strategy tester to load (2-3 seconds).

## Step 8: Read Backtest Results

- `data_get_strategy_results` → fetch all metrics
- `data_get_trades` → fetch last 20 trades
- `capture_screenshot` region "strategy_tester" — capture tester panel

## Step 9: Report Results

Report in this format:

```
## Backtest: [filename] on [symbol] [timeframe]
**Period:** 1 year (PST 6-8am window)

### Key Metrics
| Metric            | Value    | Target   |
|-------------------|----------|----------|
| Net Profit %      |          | > 15%    |
| Profit Factor     |          | > 2.0    |
| Win Rate          |          | > 70%    |
| Max Drawdown      |          | < 6%     |
| Total Trades      |          |          |

### vs Current Best (QQQ_ORB_PST6_8_trail)
+21.2%/yr · PF=2.24 · WR=77% · DD=4.5%

[Better / Worse / Same] — [1 sentence why]

### Next Steps
- [specific tweak suggestion if metrics missed targets]
- [or "save as new best" if all targets met]
```

## Notes

- Always build on current best config — never restart from zero
- Max 1yr backtest scope — use Pine `time >=` filter, not TV date range
- If strategy not visible on chart after "Add to chart", try `pine_smart_compile` again
- Save file locally before any edits: the disk file is source of truth
