# QQQ Intraday Strategy — Master Reference

> **Single source of truth.** Every strategy tested, every result, every lesson learned.
> Read this before any session. Never re-test something already marked ❌.

---

## CURRENT BEST (start here every session)

**File**: `strategies/QQQ_ORB_PST6_8_trail.pine`
**TV Editor name**: `ORB-VWAP PST6-8 v4 trail`
**Instrument**: QQQ, 15-min chart
**Session**: PST 6:45am–8:00am = ET 9:45am–11:00am

### Results (1-year backtest, Apr 2025–Apr 2026)
| Metric | Result | Target | Status |
|---|---|---|---|
| Annual P&L | +21.2% (+$5,293) | >10% | ✅ |
| Max Drawdown | 4.5% ($1,127) | <25% | ✅ |
| Profit Factor | 2.241 | >1.3 | ✅ |
| Win Rate | 77% | >35% | ✅ |
| Total Trades | 74 | >30/yr | ✅ |

### Final Parameters
```pine
i_maxRisk  = 250.0    // $ risk per trade — can scale up to ~$400 to push toward 30%+
i_maxDay   = 500.0    // daily kill switch
i_atrMult  = 1.5      // LOCKED — tested, optimal
i_useHTF   = true     // 1H EMA20 trend filter — keep ON
i_volMax   = 1.0      // ORB volume < 1.0× 20-day rolling avg
i_trailAct = 0.5      // trail activates at 0.5R from entry
i_trailOff = 0.5      // trail stays 0.5R behind highest price
i_startDt  = timestamp("2025-04-18")  // 1yr backtest

// Session window
inSession = nyTotal >= 9*60+45 and nyTotal < 11*60+0  // ET 9:45–11:00
```

### Strategy Logic (plain English)
1. Each day at 9:30 ET: record opening bar high/low (ORB)
2. Track rolling 20-day average of ORB bar volumes
3. Skip today if ORB volume >= 1.0× that average (noisy day)
4. From 9:45–11:00 ET: watch for close above ORB high + above VWAP + 1H EMA trending up
5. Enter long (or mirror for short: below ORB low + below VWAP + downtrend)
6. Hard stop: 1.5× ATR below entry
7. Once price moves +0.5R: activate trailing stop 0.5R behind highest price
8. Let run until trail hit or 3:30 ET EOD close

---

## ENVIRONMENT SETUP (required — do not skip)

```pine
strategy("...",
    initial_capital=25000,
    margin_long=25, margin_short=25,   // 4:1 intraday leverage — REQUIRED or silent reject
    commission_type=strategy.commission.cash_per_contract,
    commission_value=0,                // zero commission at Schwab/Fidelity
    slippage=1,                        // 1 tick = $0.01/share
    calc_on_every_tick=false)          // bar-close evaluation
```

**Pine v6 exit syntax** (MUST use tick offsets — absolute prices cause 0 trades):
```pine
strategy.exit("Lx", "L", loss=stopTicks, trail_points=trailPoints, trail_offset=trailOffset)
// NOT: stop=price, limit=price  ← this is the 0-trades bug
```

**Position sizing**:
```pine
stopDist    = math.max(atrVal * i_atrMult, syminfo.mintick * 10)
stopDollars = stopDist * syminfo.pointvalue  // =1 for QQQ, =2 for MNQ
qty         = math.min(math.max(math.floor(i_maxRisk / stopDollars), 1), 200)
stopTicks   = math.round(stopDist / syminfo.mintick)
```

**Session detection** (use arithmetic, not time() functions):
```pine
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
nyTotal  = nyHour * 60 + nyMinute
isOpen   = nyHour == 9 and nyMinute == 30   // 9:30 ET ORB bar
inSession = nyTotal >= 9*60+45 and nyTotal < 11*60+0
```

**Volume filter** (rolling avg of ORB bar volumes — NOT daily volume):
```pine
var float[] orbVols  = array.new_float(0)
var float   prevOrbV = na
var bool    volOk    = false
if isOpen
    if not na(prevOrbV)
        array.push(orbVols, prevOrbV)
        if array.size(orbVols) > 20
            array.shift(orbVols)
    orbAvg  = array.size(orbVols) >= 5 ? array.avg(orbVols) : na
    volOk  := not na(orbAvg) and volume < orbAvg * i_volMax
    prevOrbV := volume   // ← push PREVIOUS day's volume, not today's
```

---

## ALL STRATEGIES TESTED

### STRATEGY 1: QQQ ORB-VWAP v2 (Baseline)
**File**: `strategies/QQQ_ORB_VWAP_v2.pine`
**Status**: ✅ Profitable but below target — used as baseline

**Logic**: ORB first 15-min bar + close > orbHigh + close > VWAP + 1H EMA trend
**Entry**: 9:45–11:30 ET, 1 trade/day max
**Exit**: ATR×1.5 stop, fixed 2:1 R:R

**Results** (4.5yr, Sep 2021–Apr 2026):
| Metric | Value |
|---|---|
| Total P&L | +9.1% (+$2,275) |
| Annualized | ~2.0% |
| Trades | 115 |
| Win Rate | 36% |
| Profit Factor | ~1.15 |

**Why it's profitable but not enough**: 36% WR × $20 EV/trade × 115 = ~$2,300 maximum. Signal is structurally limited.

---

### STRATEGY 2: QQQ ORB-VWAP v2 RR3
**File**: `strategies/QQQ_ORB_VWAP_v2_RR3.pine`
**Status**: ❌ Not better than baseline

**Same as v2 but R:R=3:1**
| Metric | Value |
|---|---|
| Total P&L | +9.4% |
| Trades | ~116 |
| Win Rate | ~33% |
| Note | Higher DD, not worth it |

---

### STRATEGY 3: QQQ ORB-VWAP v4 vol (Low-Vol Filter)
**File**: `strategies/QQQ_ORB_VWAP_v4_vol.pine`
**Status**: ✅ Best QQQ config before session window discovery

**Key insight**: High-volume ORB days = institutional reversals = breakouts fail. Low-volume = clean trending.

**Vol threshold sweep** (4.5yr backtest):
| Threshold | Trades | Win% | PF | Direction |
|---|---|---|---|---|
| ≥1.5× (high vol) | 71 | 35% | <1 | ❌ Negative |
| ≥1.2× (high vol) | 82 | 36.6% | <1 | ❌ Negative |
| <0.8× (low vol) | 37 | 37.8% | 1.17 | ✅ Positive |
| **<0.9× (low vol)** | **51** | **43.1%** | **1.41** | ✅ Best |
| <1.0× (low vol) | 67 | 44.8% | ~1.35 | ✅ Positive |

---

### STRATEGY 4: QQQ ORB PST 6-8 (Session Window)
**File**: `strategies/QQQ_ORB_PST6_8.pine`
**Status**: ✅ Better than full-session — PST window improves quality

**User constraint**: Only trade PST 6am–8am (ET 9am–11am).

**Multi-instrument test** (same signal, 1yr, vol=1.2):
| Instrument | Annual% | PF | WR | Trades |
|---|---|---|---|---|
| **QQQ** | **+10.5%** | **1.292** | **38.8%** | **67** |
| TSLA | +9.0% | 1.125 | 39.3% | 122 |
| NFLX | +0.3% | 1.014 | 35.5% | 76 |
| SPY | -2.4% | 0.894 | 35.1% | 37 |
| MNQ1! | -3.9% | 0.873 | 33.3% | 69 |
| META | -11.8% | 0.808 | 34.3% | 99 |

**Conclusion**: QQQ is the right instrument for this signal. SPY too slow. MNQ too volatile at open. TSLA has edge but 2.6× higher DD for similar P&L.

**Vol threshold sweep** (QQQ, PST 6-8, 1yr, fixed 2:1):
| vol | Trades | WR | PF | Annual% |
|---|---|---|---|---|
| 0.9 | 44 | 43.2% | 1.522 | +12.3% |
| **1.0** | **56** | **42.9%** | **1.474** | **+14.1%** ← sweet spot |
| 1.1 | 63 | 41.3% | 1.409 | +13.4% |
| 1.2 | 67 | 38.8% | 1.292 | +10.5% |

---

### STRATEGY 5: QQQ ORB PST 6-8 + Trailing Stop (CURRENT BEST)
**File**: `strategies/QQQ_ORB_PST6_8_trail.pine`
**Status**: ✅ TARGET HIT — all acceptance criteria met

**Trailing stop sweep** (QQQ, PST 6-8, vol=1.0, 1yr):
| Trail activate | Trail offset | Annual% | PF | WR | Trades | DD |
|---|---|---|---|---|---|---|
| Fixed 2:1 target | — | +14.1% | 1.474 | 42.9% | 56 | 7.4% |
| 1.0R | 1.0R | +14.5% | 1.580 | 56.7% | 60 | 6.5% |
| 0.75R | 0.5R | +17.9% | 1.778 | 65.2% | 66 | 4.8% |
| **0.5R** | **0.5R** | **+21.2%** | **2.241** | **77.0%** | **74** | **4.5%** |
| ~~0.5R~~ | ~~0.25R~~ | ~~+29.7%~~ | — | — | 96 | ⚠️ INVALID |

**Why trailing stop works so well**: QQQ ORB breakouts on quiet days almost always move at least 0.5R before reversing. Trail locks in breakeven immediately → very few full losers → WR jumps to 77%.

**⚠️ CRITICAL WARNING — trail_offset limit**:
Trail offset < 0.5R at 15-min resolution creates intrabar exit/re-entry loops. The 0.5R/0.25R result showing +29.7% is a backtest artifact (96 trades from 56-trade signal = artificial re-entries). Pine `calc_on_every_tick=false` means trail is evaluated at bar close only — at 0.25R offset, every modest intrabar pullback exits and the signal may re-enter. **Never go below 0.5R trail offset.**

---

## WHAT FAILED — DO NOT RETRY

### Signal Filters (all tested on QQQ ORB, all worse than unfiltered)
| Filter | Result | Root Cause |
|---|---|---|
| Gap direction ≥0.2% | -7%, 82 trades | ORB is direction-agnostic; gap continuation ≠ gap and go |
| Gap direction ≥0.1% | -5%, 91 trades | Same |
| Flat gap ≤0.2% | 0 trades | QQQ gaps >0.2% nearly every day |
| Flat gap ≤0.5% | 0 trades | Still too restrictive |
| High volume ≥1.2× | Negative | Institutional reversal days destroy ORB |
| Daily EMA strict | 0 trades | Filters all trades during corrections |
| RSI>60 + volume combo | 0 trades | Two restrictive filters compound |
| ADX>20 trend filter | PF=1.414, 39 trades | Removes valid slow-trend setups |
| Bar quality (top 50% close) | PF=1.202, 38 trades | Removes valid setups with partial closes |
| 2-bar ORB confirmation | PF=1.553, 40 trades | Higher quality, but total $ less than 1-bar vol=1.0 |

### Exit Methods (vs trailing stop)
| Exit Method | Result | Why Worse |
|---|---|---|
| Fixed 2:1 R:R | +14.1%, WR=43% | Cuts winners at 2R, misses trend days |
| Fixed 2.5:1 R:R | +14.7%, WR=42% | Marginal, not worth complexity |
| Fixed 3:1 R:R | +9.4%, WR=33% | Win rate too low to compensate |
| Manual bar-level SL/TP | Inaccurate | Closes at bar close not SL/TP price |

### Entry Styles
| Entry | Trades | Result | Root Cause |
|---|---|---|---|
| Opening Drive at 9:45 | 78 | Negative | Entering AFTER move — buying tops |
| Opening Drive at 9:30 | 22 | PF=0.52 | Open bar too volatile, immediate reversal |
| VWAP Cross + EMA direction | 21 | Negative | Direction filter kills signals |
| VWAP Bounce wick rejection | 45 | -16.7% | False bounces in trends |
| VWAP Reclaim (2-bar hold) | N/A | PF=0.836 | Doesn't work on QQQ 15-min |

### Instruments (PST 6-8 window, same ORB signal)
| Instrument | Result | Status | Why |
|---|---|---|---|
| SPY | -2.4% | ❌ Don't use | Too slow/liquid, ORB moves too small |
| MNQ1! | -3.9% | ❌ Don't use | Too volatile at open, whipsaws ORB |
| META | -11.8% | ❌ Don't use | Individual stock ORB unpredictable |
| NFLX | +0.3% | ❌ Don't use | Negligible edge, not worth it |
| TSLA | +9.0%, PF=1.125 | ⚠️ Tested positive but chose QQQ | Same P&L, 2.6× higher drawdown. Only revisit if QQQ edge degrades. |
| **QQQ** | **+10.5%, PF=1.292** | **✅ Best** | Best risk-adjusted in class |

### Pine Setup Bugs (will cause 0 trades silently)
| Bug | Symptom | Fix |
|---|---|---|
| `strategy.exit stop=price` | 0 trades | Use `loss=ticks, profit=ticks` |
| `initial_capital=10000, no margin` | 0 trades | Set `margin_long=25, margin_short=25` |
| `commission_value=0.0005` (0.05%) | -13% P&L | $37/trade drag; use 0 for QQQ |
| `request.security daily volume` | na values | Use rolling array of ORB bar vols instead |
| Vol array self-inclusive | Inflated avg | Push PREVIOUS day's vol, not today's |

---

## ATR STOP MULTIPLIER — LOCKED AT 1.5×

Tested exhaustively on QQQ 15-min. Do not re-test.
| ATR Mult | Trades | Win% | PF | P&L |
|---|---|---|---|---|
| 1.0× | 67 | ~22% | 0.65 | ❌ Negative |
| 1.25× | 87 | ~26% | 0.79 | ❌ Negative |
| **1.5× (optimal)** | **115** | **36%** | **~1.15** | **✅ Profitable** |
| 1.75× | 120 | 38.3% | 0.94 | ❌ Negative |

**Why 1.5× is the floor**: QQQ 15-min ATR ≈ $1.50–$3.00. At 1.5×, stop is $2.25–$4.50 — enough room to breathe but not so wide that target is unreachable.

---

## R:R RATIO — EXHAUSTED, USE TRAILING STOP INSTEAD

Fixed R:R sweep on QQQ baseline (4.5yr):
| R:R | Trades | Win% | Annual% |
|---|---|---|---|
| 1.5:1 | N/A | Need 40% WR | Negative (WR only 36%) |
| 2.0:1 | 115 | 36% | +2.0% |
| 2.5:1 | 108 | ~38% | +2.4% |
| 3.0:1 | ~116 | ~33% | +2.1% |

**Conclusion**: Fixed R:R caps upside. Trailing stop consistently outperforms all fixed R:R options.

---

## NEXT STEPS (in priority order)

### 1. Walk-Forward Validation (Iteration 6) — DO FIRST
**Why**: Confirms the trailing stop edge is not overfit to 2025–2026 data.
**How**:
- Set `i_startDt = timestamp("2024-04-18")` → test 2024–2025
- Compare results to 2025–2026 baseline
- If PF degrades >30% (from 2.24 to <1.57), edge is suspect
- Acceptance: PF ≥ 1.5 in both periods

### 2. Scale Position Size
**Why**: Linear scaling — no signal changes needed.
- Current: $250/trade → +21.2%/yr
- Test $350/trade → expect +29.7%/yr (1.4×), DD ~6.3%
- Test $400/trade → expect +33.9%/yr (1.6×), DD ~7.2%
- **Constraint**: Keep max DD below 15% of capital ($3,750)

### 3. Second Trade Per Day
**Why**: After first trade exits via trail, signal may re-fire same morning.
**How**: Change `noPos` to count entries per day, allow up to 2.
**Risk**: Second trade after a loss = possible revenge pattern. Test carefully.

### 4. 5-Minute ORB Entry
**Why**: 5-min ORB is tighter = earlier entry = potentially more trades.
**Blocker**: 5-min data only loads ~3 months by default on QQQ.
**How to test**: Use 1-month range, compare signal quality.

### 5. TTM Squeeze Filter
**Why**: BB inside Keltner = compressed volatility about to explode. Taking ORB signal only when squeeze fires = confirms the breakout has momentum behind it. Very synergistic with ORB.
**How**: `bbUpper > kcUpper` = no squeeze (BB wider than KC). `bbUpper < kcUpper` = squeeze. Enter ORB only when squeeze fires (just exited compression).

### 6. Relative Strength vs SPY
**Why**: If QQQ outperforms SPY% from open (QQQ up 0.3% while SPY up 0.1%), institutional money specifically entering QQQ = ORB breakout more likely to hold.
**How**: `qqq_change = (close - open) / open`, `spy_change = request.security("SPY", ...)`. Enter long only if `qqq_change > spy_change`.

### 7. Pre-Market High/Low Level
**Why**: Breaking above pre-market high = institutional accumulation confirmed.
**How**: `request.security(syminfo.tickerid, "1440", high[1]...)` for prev-day pre-mkt high.
**Note**: Complex to implement cleanly in Pine — verify no lookahead bias.

---

## THEORETICAL EDGE ANALYSIS

With current best config (trail 0.5R/0.5R, vol=1.0, 1yr):
- 74 trades/year
- 77% WR → 57 wins, 17 losses
- Avg loss ≈ $251 (near-full 1R loss)
- Avg win ≈ $168 (trail closes early on reversals)
- EV per trade = (0.77 × $168) - (0.23 × $251) = $129 - $58 = **$71/trade**
- Annual P&L = 74 × $71 = **$5,254** ≈ matches backtest ($5,293) ✓

**Key**: This is a high-WR / low-avg-win system. Avg win < avg loss. Every individual loss stings. But 77% of trades are profitable (many at small gains/breakeven). This is normal for breakeven-lock trailing stop systems.

---

## FILE INDEX

| File | Status | Description |
|---|---|---|
| `QQQ_ORB_VWAP_v2.pine` | Baseline | Original ORB+VWAP, 2% annual |
| `QQQ_ORB_VWAP_v2_RR3.pine` | ❌ Superseded | R:R=3 variant, not better |
| `QQQ_ORB_VWAP_v4_vol.pine` | ✅ Reference | Best vol-filter config (vol=0.9, 4.5yr data) |
| `QQQ_ORB_PST6_8.pine` | ✅ Reference | PST 6-8 window, fixed 2:1, vol=1.0 |
| `QQQ_ORB_PST6_8_trail.pine` | ✅ **CURRENT BEST** | PST 6-8, trail 0.5/0.5, +21.2%/yr |
| `QQQ_strategy_plan.md` | 📋 Plan | Iteration log, acceptance criteria |
| `STRATEGY_REFERENCE.md` | 📖 This file | Complete reference — read every session |
