---
name: kelly-size
description: Calculate optimal position size using Kelly Criterion from backtest win rate and avg win/loss. Compares Kelly recommendation vs current $250 fixed risk. Use after a backtest to optimize sizing.
---

# Kelly Position Sizing

Fixed $250 risk per trade is conservative and easy. Kelly Criterion calculates the mathematically optimal bet size to maximize long-term growth without risking ruin. Most pro traders use fractional Kelly (25-50%) for safety.

## Step 1: Get the Inputs

Need from backtest results (paste or read from last /backtest-with-tv output):
- Win rate (as decimal, e.g. 0.77)
- Avg winning trade ($)
- Avg losing trade ($)
- Total capital ($25,000)
- Current risk per trade ($250)

For QQQ ORB current best:
- Win rate: 0.77
- Avg win: ~$109 (varies by backtest period)
- Avg loss: ~$230
- Capital: $25,000
- Current risk: $250/trade

## Step 2: Calculate Kelly %

Full Kelly formula:
```
b = avg_win / avg_loss          (win/loss ratio)
p = win_rate
q = 1 - p                       (loss rate)

Kelly % = (b * p - q) / b
         = p - (q / b)
```

Example with current best metrics:
```
b = 109 / 230 = 0.474
p = 0.77
q = 0.23

Kelly % = (0.474 * 0.77 - 0.23) / 0.474
        = (0.365 - 0.23) / 0.474
        = 0.135 / 0.474
        = 28.5%
```

## Step 3: Calculate Dollar Risk

```
Full Kelly risk   = Kelly% × capital = 28.5% × $25,000 = $7,125/trade
Half Kelly risk   = Kelly% × 0.5 × capital = $3,562/trade
Quarter Kelly     = Kelly% × 0.25 × capital = $1,781/trade

Current fixed risk = $250/trade
```

## Step 4: Interpret

**If Kelly% > 0:** edge exists, formula is meaningful
**If Kelly% ≤ 0:** no edge detected — do not trade (negative expectancy)
**If Kelly% > 50%:** strategy has very high edge (or data is too good — verify)

Pro trader rule: **never bet more than 25% Kelly** in live trading. Reduces variance dramatically while keeping ~75% of growth rate.

## Step 5: Practical Recommendation

```
## Kelly Sizing Report

### Inputs
- Win Rate: [x]%
- Avg Win: $[x]
- Avg Loss: $[x]
- Capital: $25,000

### Kelly Calculation
- Win/Loss Ratio (b): [x]
- Full Kelly %: [x]%
- Full Kelly $: $[x]/trade
- Half Kelly $: $[x]/trade  ← recommended starting point
- Quarter Kelly $: $[x]/trade  ← conservative, use if new to live trading

### vs Current Setting
- Current: $250/trade ([x]% of capital)
- Half Kelly: $[x]/trade ([x]% of capital)
- Difference: [x]× current risk

### Recommendation
[Conservative / Moderate / Aggressive] sizing recommended.

If Half Kelly > $500: consider increasing i_maxRisk gradually
If Half Kelly < $200: current $250 may already be too aggressive for this edge quality
```

## Step 6: Growth Rate Comparison

Calculate expected annual growth at different sizing levels:

```
Expected growth rate ≈ Kelly% × edge_per_trade × trades_per_year

At current $250 risk ([x]% of capital):
  Expected annual growth ≈ [x]%

At Half Kelly ([x]% of capital):
  Expected annual growth ≈ [x]%

At Full Kelly (theoretical max, never use live):
  Expected annual growth ≈ [x]%
```

## Step 7: Generate Pine Edit (if sizing up)

If recommendation is to increase risk, generate the exact Pine change:

```
In strategies/QQQ_ORB_PST6_8_trail.pine:
Change: i_maxRisk = input.float(250.0, ...) default value
To:     i_maxRisk = input.float([NEW_VALUE], ...)

Note: Change only the default value. The input still accepts any value at runtime.
```

## Notes

- Kelly assumes each trade is independent — roughly true for this strategy (daily, not correlated)
- Kelly is calculated on NET metrics — if strategy has periods of negative edge, full Kelly risks ruin
- Always paper trade at new sizing for 20+ trades before going live
- If win rate or avg win/loss differs significantly from backtest, recalculate before each quarter
- Kelly with b < 1 (avg win < avg loss) requires very high win rate — verify WR is real, not overfit
