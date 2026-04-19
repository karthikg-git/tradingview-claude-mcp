# Hybrid Claude — Local vs Cloud

## Trading Workflow Diagram

```
 IDEA / TWEAK
      │
      ▼
┌─────────────────────────────────────────────────────┐
│  LOCAL SESSION  (free, qwen2.5-coder:32b)           │
│                                                     │
│  • Draft new strategy logic in Pine                 │
│  • Edit existing .pine files                        │
│  • Fix syntax errors, refactor code                 │
│  • Math: param ranges, R-multiples, sizing          │
│  • Brainstorm: "what if I add X condition?"         │
│  • Review code before pushing to TradingView        │
└──────────────────────┬──────────────────────────────┘
                       │  Pine code ready to test
                       ▼
┌─────────────────────────────────────────────────────┐
│  CLOUD SESSION  (paid, Claude Sonnet)                │
│                                                     │
│  • pine_set_source → inject code into TV            │
│  • pine_smart_compile → compile + check errors      │
│  • pine_get_errors → fix compile failures           │
│  • Run backtest (1yr, PST 6-8am window)             │
│  • data_get_strategy_results → read metrics         │
│  • Analyze: PF, WR, DD, MAE/MFE, equity curve       │
│  • Screenshot → visual confirmation                 │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
    RESULTS GOOD?             RESULTS BAD?
          │                         │
          ▼                         ▼
    Save .pine file          Back to LOCAL
    Update strategy          Edit params/logic
    memory                   (don't restart
                              from zero — build
                              on current best)
```

---

## When to Use Each — Quick Reference

| Activity | Session | Why |
|----------|---------|-----|
| Write/edit Pine Script | **Local** | Code editing, no TV needed |
| Fix Pine syntax errors | **Local** | Pure code task |
| Tweak param values (length, mult, etc.) | **Local** | Math + code only |
| Brainstorm new conditions | **Local** | No TV access needed |
| Compile + add to chart | **Cloud** | Needs MCP → TradingView |
| Run backtest | **Cloud** | Needs MCP → strategy tester |
| Read backtest metrics | **Cloud** | Needs MCP → data_get_strategy_results |
| Analyze results, decide next tweak | **Cloud** | Complex reasoning + context |
| Chart analysis, levels, labels | **Cloud** | Needs MCP → live chart |
| Fine-tuning loop (many iterations) | **Cloud** | Stay in same session — TV context alive |

**Rule:** Touch TradingView → Cloud. Touch only .pine files → Local.

---

## Fine-Tuning Loop (Stay in Cloud)

Once you're in the backtest iteration loop, **stay in Cloud**. Switching sessions loses TV state.

```
Cloud session:
  compile → backtest → read results → tweak param → compile → backtest → ...
```

Only drop to Local if you need major code restructuring mid-loop. Save file locally first.

---

## Start Local Session (free)

**Step 1** — Ensure Ollama is running (check system tray or):
```powershell
ollama serve
```

**Step 2** — Launch:
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\karth\Automation\Tradingview\start_local_claude.ps1"
```

Opens LiteLLM proxy window + Claude in current window.

---

## Start Cloud Session (normal)

```powershell
claude
```

---

## Troubleshooting

**First query takes 15-20s** — Normal. Ollama loads 32b into VRAM on first use.

**"Connection refused"** — LiteLLM still starting. Wait 5-10s, retry.

**Weak results from local** — Switch to cloud. 32b < Sonnet on complex reasoning.

**Port 4000 busy** — Script auto-kills old proxy. Manual fix: `netstat -ano | findstr :4000` → kill PID.

---

## Models

| Model | Used by |
|-------|---------|
| `qwen2.5-coder:32b` | Local Claude Code sessions |
| `deepseek-r1:32b` | Manual deep reasoning: `ollama run deepseek-r1:32b` |
