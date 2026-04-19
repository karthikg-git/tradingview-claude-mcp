---
name: param-robustness
description: Test parameter sensitivity — vary each param ±20% and predict metric impact. Identifies overfit params vs robust ones. Use after a backtest to validate the edge is real.
---

# Parameter Robustness Check

Quant funds don't trust a strategy with cherry-picked params. This skill checks if small param changes destroy the edge — if they do, the strategy is overfit and shouldn't be traded live.

## Step 1: Read the Strategy File

```bash
cat strategies/QQQ_ORB_PST6_8_trail.pine
```

Extract all tunable parameters with current values.

## Step 2: Identify Params to Test

For QQQ ORB strategy, test these params:

| Param | Current | -20% | +20% | Notes |
|-------|---------|------|------|-------|
| `i_atrMult` | 1.5 | 1.2 | 1.8 | Stop width |
| `i_volMax` | 1.0 | 0.8 | 1.2 | Entry filter |
| `i_trailAct` | 0.5 | 0.4 | 0.6 | Trail trigger |
| `i_trailOff` | 0.5 | 0.4 | 0.6 | Trail distance |
| `i_maxRisk` | 250 | 200 | 300 | Position size (scales linearly, skip) |

Skip `i_maxDay` and `i_maxRisk` — they scale results linearly, not structural.

## Step 3: Generate Test Variants

For each param, generate a modified Pine file with that ONE param changed. Output as a test plan:

```
TEST PLAN — Param Robustness
Run each variant via /backtest-with-tv, record results.

Variant 1: atrMult=1.2 (baseline 1.5, -20%)
Variant 2: atrMult=1.8 (baseline 1.5, +20%)
Variant 3: volMax=0.8  (baseline 1.0, -20%)
Variant 4: volMax=1.2  (baseline 1.0, +20%)
Variant 5: trailAct=0.4 (baseline 0.5, -20%)
Variant 6: trailAct=0.6 (baseline 0.5, +20%)
Variant 7: trailOff=0.4 (baseline 0.5, -20%)  ← CAUTION: artifact risk
Variant 8: trailOff=0.6 (baseline 0.5, +20%)
```

WARNING: trailOff below 0.5R risks bar-resolution re-entry artifacts — flag this clearly.

## Step 4: Predict Expected Ranges

Based on strategy logic, predict direction of impact for each change:

- `atrMult` higher → wider stop → fewer stopouts → higher WR, lower PF (larger losses)
- `atrMult` lower → tighter stop → more stopouts → lower WR, potentially higher PF
- `volMax` lower → fewer trades, higher quality → expect higher PF, fewer trades
- `volMax` higher → more trades, lower quality → expect lower PF
- `trailAct` higher → trail activates later → more losers converted to BE → lower WR
- `trailOff` higher → trail stays further back → larger winners, fewer premature exits

## Step 5: Robustness Scoring (after user runs variants)

When user provides variant results, score each param:

**Robust** = PF stays within 0.3 of baseline across both ±20% variants
**Fragile** = PF changes >0.5 in either direction
**Cliff** = PF drops below 1.0 with small change = DO NOT TRADE LIVE

```
## Robustness Report

Baseline: PF=2.24, WR=77%, Net=+21.2%

| Param | -20% PF | Baseline PF | +20% PF | Rating |
|-------|---------|-------------|---------|--------|
| atrMult | | 2.24 | | Robust/Fragile/Cliff |
| volMax | | 2.24 | | |
| trailAct | | 2.24 | | |
| trailOff | | 2.24 | | |

### Overall Verdict
ROBUST = safe to trade live with current params
FRAGILE = reduce position size, monitor closely
CLIFF = params are overfit — do not trade live, rebuild needed
```

## Notes

- A robust strategy tolerates ±20% param variation with <15% metric change
- If 3+ params are fragile, the strategy is likely overfit to historical data
- Fragile params should be set conservatively (toward the direction that favors robustness)
- Always confirm: `trailOff >= 0.5R` to avoid artifact contamination
