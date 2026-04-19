---
name: walk-forward-plan
description: Generate a walk-forward validation plan — rolling quarterly backtests to prove the edge isn't curve-fit to one market period. Use before trading live.
---

# Walk-Forward Validation Plan

In-sample optimization on 1 year proves nothing alone. Walk-forward testing runs the SAME params on rolling out-of-sample periods. If edge holds across multiple quarters, it's real. If it only works on the tuned period, it's overfit.

## Step 1: Define the Test Windows

For QQQ ORB strategy (optimized on Apr 2025 – Apr 2026):

Generate `inWindow` timestamps for each quarter:

```
OUT-OF-SAMPLE WINDOWS (change inWindow in Pine for each test):

Q1 2024: time >= timestamp("2024-01-01") and time < timestamp("2024-04-01")
Q2 2024: time >= timestamp("2024-04-01") and time < timestamp("2024-07-01")
Q3 2024: time >= timestamp("2024-07-01") and time < timestamp("2024-10-01")
Q4 2024: time >= timestamp("2024-10-01") and time < timestamp("2025-01-01")
Q1 2025: time >= timestamp("2025-01-01") and time < timestamp("2025-04-01")
```

These are ALL out-of-sample — the strategy was tuned on Apr 2025–Apr 2026, so anything before is unseen data.

Note: Q1 2025 includes the high-volatility tariff period (Jan–Mar 2025). Expect weaker results — this tests regime resilience.

## Step 2: Generate Modified Pine Files

For each quarter, create a test variant by modifying the `inWindow` line only:

```bash
# All other params stay IDENTICAL to current best
# Only change: inWindow = time >= timestamp("YYYY-MM-DD") and time < timestamp("YYYY-MM-DD")
```

Read current file:
```bash
cat strategies/QQQ_ORB_PST6_8_trail.pine
```

Output modified `inWindow` lines for each quarter. User will paste each into the file, run `/backtest-with-tv`, record results.

## Step 3: Results Tracker Template

Provide this table for user to fill in as they run each quarter:

```
## Walk-Forward Results — QQQ ORB PST6-8 Trail

Params: atrMult=1.5, volMax=1.0, trail=0.5R/0.5R (FIXED — no changes between runs)

| Period | Trades | Win Rate | PF | Net % | DD % | Grade |
|--------|--------|----------|----|-------|------|-------|
| Q1 2024 | | | | | | |
| Q2 2024 | | | | | | |
| Q3 2024 | | | | | | |
| Q4 2024 | | | | | | |
| Q1 2025 | | | | | | |
| IN-SAMPLE (Apr25–Apr26) | 74 | 77% | 2.24 | +21.2% | 4.5% | A |

Grade scale: A=PF>1.8, B=PF 1.3-1.8, C=PF 1.0-1.3, F=PF<1.0
```

## Step 4: Interpret Results

After user fills in the table, analyze:

**Edge is REAL if:**
- 3+ quarters grade B or above
- No single quarter below PF=0.8 (survivable loss)
- Avg quarterly PF across all periods > 1.3

**Edge is QUESTIONABLE if:**
- 2 quarters grade F
- High variance between quarters (some A, some F)
- Only the in-sample period performs well

**Edge is OVERFIT if:**
- Most out-of-sample quarters grade F
- In-sample PF >> out-of-sample average by >50%

## Step 5: Regime Analysis

After results, identify what market regime each quarter had:
- Q1 2024: QQQ trending up strongly (AI rally)
- Q2 2024: Mixed, mild correction then recovery
- Q3 2024: Volatile (Yen carry unwind Aug 2024), then recovery
- Q4 2024: Post-election rally, strong uptrend
- Q1 2025: Tariff announcements, high volatility, sharp drawdown

Cross-reference grades with regime → reveals what market conditions the strategy needs.

## Step 6: Recommendations

```
## Walk-Forward Verdict

Overall Grade: [A/B/C/F]
Best quarter: [period] — [why]
Worst quarter: [period] — [why]
Regime dependency: [works in trending / struggles in volatile / etc.]

Recommendation:
- [TRADE LIVE / TRADE REDUCED SIZE / DO NOT TRADE / REBUILD]
- [specific condition to add based on failing quarters]
```

## Notes

- Never change params between quarters — only `inWindow` changes
- Minimum 15 trades per quarter to trust the result (fewer = statistically meaningless)
- If a quarter has <15 trades, note it but don't grade it
- Restore original `inWindow` after all tests: `time >= timestamp("2025-04-18")`
