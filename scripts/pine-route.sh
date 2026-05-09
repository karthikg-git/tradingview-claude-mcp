#!/usr/bin/env bash
# pine-route.sh "<task description>"
# Classifies a task as LOCAL (free) or CLOUD (paid) and prints start command
# No API call — pure keyword routing, instant
set -euo pipefail

TASK="${*:-}"
if [[ -z "$TASK" ]]; then
  echo "Usage: pine-route.sh \"<what you want to do>\""
  echo ""
  echo "Examples:"
  echo "  pine-route.sh \"fix syntax error on line 42\""
  echo "  pine-route.sh \"run backtest on QQQ 1yr\""
  exit 0
fi

TASK_LOWER=$(echo "$TASK" | tr '[:upper:]' '[:lower:]')

# Cloud-required: anything touching TradingView MCP, backtesting, live data
CLOUD_PATTERN="backtest|compile|tradingview|chart|equity|drawdown|win rate|profit factor|mcp|screenshot|indicator|strategy tester|open interest|volume profile|alert|watchlist|replay|candle|ticker|symbol|timeframe"

# Local-sufficient: code editing, syntax, drafting, logic review
LOCAL_PATTERN="syntax|error|fix|draft|write|edit|tweak|param|parameter|typo|format|structure|boilerplate|review|check|refactor|rename|add condition|remove condition|variable|function|logic|repainting|lookahead"

if echo "$TASK_LOWER" | grep -qE "$CLOUD_PATTERN"; then
  echo "ROUTE: CLOUD"
  echo "WHY:   Requires TradingView MCP tools or live backtest data"
  echo ""
  echo "START: claude"
  echo "       (normal session, Anthropic API)"
elif echo "$TASK_LOWER" | grep -qE "$LOCAL_PATTERN"; then
  echo "ROUTE: LOCAL"
  echo "WHY:   Code edit/review — no MCP needed, Ollama handles it free"
  echo ""
  echo "START: bash scripts/pine-edit-local.sh <file.pine> \"$TASK\""
else
  echo "ROUTE: LOCAL (default)"
  echo "WHY:   Ambiguous — start with Ollama, escalate to cloud if MCP needed"
  echo ""
  echo "START: bash scripts/pine-edit-local.sh <file.pine> \"$TASK\""
fi
