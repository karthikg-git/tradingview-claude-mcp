---
name: pine-preflight
description: Validate Pine Script before sending to TradingView — catch logic bugs, edge cases, and common errors without burning a compile attempt. Use on any .pine file before /backtest-with-tv.
---

# Pine Script Pre-Flight Checker

Validate the Pine Script locally before compiling in TradingView. Catch bugs early, save cloud round-trips.

## Step 1: Read the File

If user specifies a file, read it. Otherwise default to current best:
```bash
cat strategies/QQQ_ORB_PST6_8_trail.pine
```

## Step 2: Check Version & Declaration

- First line must be `//@version=6`
- Must have `strategy()` or `indicator()` declaration with required params
- For strategies: verify `overlay=true/false` matches intent
- For QQQ strategy: confirm `margin_long=25, margin_short=25` present — without this, orders silently rejected

## Step 3: Session & Time Logic

Check all time-based logic for correctness:
- `hour()` / `minute()` — confirm timezone arg matches intent (`"America/New_York"` for ET)
- `nyTotal = nyHour * 60 + nyMinute` arithmetic — verify boundary conditions (9:45 = 585, 11:00 = 660)
- `isOpen` flag — verify it only triggers on the 9:30 ET bar (nyHour==9, nyMinute==30)
- `inWindow` date filter — confirm `timestamp()` format is correct (`"YYYY-MM-DD"`)
- Session boundaries: entries only after ORB forms (nyTotal > 570), exits at EOD (nyTotal >= 930)

## Step 4: Entry Logic

Verify no lookahead bias:
- `request.security()` calls must use `lookahead=barmerge.lookahead_off`
- HTF data (1H EMA) fetched correctly — no future data leakage
- ORB high/low set ONLY on the 9:30 bar, not updated after

Check entry conditions are AND'd correctly:
- `ok = inSession AND inWindow AND noPos AND not dayDead AND orbFormed AND atrOk AND volOk`
- `longSig = ok AND close > orbH AND close > vwapVal AND htfOkL`
- `shortSig = ok AND close < orbL AND close < vwapVal AND htfOkS`

## Step 5: Position Sizing & Stops

- `stopDist` uses `math.max(atrVal * mult, mintick * 10)` — floor prevents zero stops
- `qty` is clamped: `math.min(math.max(math.floor(...), 1), 200)` — no zero or runaway size
- `strategy.exit` uses `loss=ticks` and `trail_points/trail_offset` in TICKS not prices
- Verify tick conversion: `stopTicks = math.round(stopDist / syminfo.mintick)` ✓

## Step 6: Trail Logic

CRITICAL — trail artifact check:
- `trail_offset` must be >= 0.5R equivalent in ticks
- If `trail_offset < trail_points * 0.5` → risk of bar-resolution re-entry artifacts
- Confirm: `trailPoints = stopDist * i_trailAct / mintick`, `trailOffset = stopDist * i_trailOff / mintick`

## Step 7: Volume Filter

- `orbVols` array initialized with `var` — persists across bars ✓
- Array capped at 20 entries via `array.shift()` — rolling window ✓
- `orbAvg` only computed when `array.size >= 5` — avoids early noise ✓
- `volOk` set on `isOpen` bar only — not recalculated mid-session ✓

## Step 8: Day Loss Limit

- `dayEq` captured at `isOpen` bar — beginning of day equity
- `dayDead` flips true if `equity - dayEq < -i_maxDay`
- Verify it resets each day: `if isOpen → dayDead := false` ✓

## Step 9: New Filter Validation (if any were added)

For any NEW filters added in this edit:
- Does it use `var` for persistent state? (required for arrays, accumulators)
- Is it evaluated at the right bar? (session open vs intrabar)
- Does it have a toggle input so it can be disabled for comparison?
- Does it interact correctly with existing `ok` conditions?
- No division by zero risk?
- No `na` propagation that could silently disable entries?

## Step 10: Report

Output a preflight report:

```
## Pine Preflight: [filename]

### ✅ Passed
- [list each check that passed]

### ⚠️ Warnings (won't crash, but review)
- [list any concerns]

### ❌ Failures (fix before compiling)
- [list bugs with line numbers and fix]

### Verdict
READY TO COMPILE / NEEDS FIXES
```

If NEEDS FIXES: make the fixes directly in the file, then re-run the checks and confirm clean.
If READY TO COMPILE: tell user to switch to cloud session and run `/backtest-with-tv`.
