---
name: strategy-diagnose
description: Diagnose backtest results — identify root causes of underperformance and rank fixes by expected impact. Use after /backtest-with-tv shows poor metrics.
---

# Strategy Diagnose

Analyze backtest metrics, identify what's broken, and prescribe ranked fixes. No TradingView needed — pure analysis.

## Step 1: Gather Metrics

Ask user to paste backtest results if not already provided. Need:
- Net Profit % and $
- Profit Factor (overall, long, short separately if available)
- Win Rate
- Max Drawdown % and $
- Total Trades
- Avg win $ vs Avg loss $
- Long vs Short breakdown

Also ask: what changed since last test? (new filter, param tweak, different date range?)

## Step 2: Benchmark vs Current Best

Always compare against the established baseline:
**Current Best:** `QQQ_ORB_PST6_8_trail.pine` — +21.2%/yr, PF=2.24, WR=77%, DD=4.5%, 74 trades

Score each metric:
- Net Profit: >15% = ✅, 10-15% = ⚠️, <10% = ❌
- Profit Factor: >2.0 = ✅, 1.5-2.0 = ⚠️, <1.5 = ❌
- Win Rate: >70% = ✅, 55-70% = ⚠️, <55% = ❌
- Max DD: <6% = ✅, 6-12% = ⚠️, >12% = ❌
- Trades: >50 = ✅, 30-50 = ⚠️, <30 = ❌ (too few to trust)

## Step 3: Diagnose Root Cause

Run through this diagnostic tree:

### Long vs Short Asymmetry
If long PF << short PF:
→ Market in downtrend regime during test period
→ Fix: add daily/weekly trend filter to disable longs in downtrend
→ Check: is 50-day EMA or 200-day EMA filter already present?

If short PF << long PF:
→ Market in uptrend regime
→ Fix: disable shorts when QQQ above 50-day MA

### Too Many Trades (vs baseline)
More trades than baseline with worse PF:
→ A filter was removed or loosened
→ Fix: tighten vol filter (reduce i_volMax) or add confirmation

### Too Few Trades (vs baseline)
Fewer than 30 trades:
→ Filter too restrictive — not enough edge to measure
→ Fix: loosen one filter, run again

### High Drawdown with Low Profit Factor
DD > 12% and PF < 1.3:
→ Stop loss too wide OR entries in wrong regime
→ Fix: check ATR mult (should be 1.5), check vol filter

### Good Win Rate but Low PF
WR > 65% but PF < 1.5:
→ Avg loss >> avg win (bad R:R)
→ Trail activating too late or offset too tight
→ Fix: adjust trail_act or trail_offset — but WARNING: do not go below 0.5R/0.5R

### Low Win Rate with Okay PF
WR < 50% but PF > 1.5:
→ Strategy is letting winners run but catching many small losses
→ Not necessarily broken — check if avg win / avg loss ratio > 2.0

## Step 4: Rank Fixes by Impact

After diagnosis, rank top 3 fixes:

Format each as:
```
#1 [Fix name] — Expected impact: [high/medium/low]
   Problem: [what metric is broken and why]
   Change: [exact param or code change]
   Risk: [what could go wrong / what to watch for]
```

## Step 5: Pine Edit Prompt

For the top fix, generate a ready-to-use prompt the user can paste into the same local Claude session:

```
Modify strategies/QQQ_ORB_PST6_8_trail.pine:
[exact instruction]
Do NOT change: atrMult, trailAct, trailOff, volMax, session, margin, commission.
Save the file. Show changed lines only.
```

## Step 6: Report Format

```
## Strategy Diagnosis: [date]

### Scores vs Baseline
| Metric | Result | Baseline | Score |
|--------|--------|----------|-------|
| Net Profit | | +21.2% | |
| PF | | 2.24 | |
| WR | | 77% | |
| DD | | 4.5% | |
| Trades | | 74 | |

### Root Cause
[1-2 sentence diagnosis]

### Ranked Fixes
#1 ...
#2 ...
#3 ...

### Edit Prompt for Local Session
[paste-ready prompt]
```

## Notes

- Never restart from zero — always build on current best params
- If ALL metrics are worse, suspect a date range or regime issue, not a code bug
- If only longs fail: regime problem (trend filter needed), not entry logic
- If only shorts fail: same but opposite
- Fewer trades is not always bad — quality > quantity for this strategy
