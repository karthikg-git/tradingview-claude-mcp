#!/usr/bin/env bash
# pine-compact.sh [file] or stdin
# Compresses backtest error context via Ollama before cloud handoff
# Reduces token waste from repeated error logs / full strategy history

set -euo pipefail

MODEL="qwen2.5-coder:32b"
OLLAMA_URL="http://localhost:11434/api/generate"

if [[ -n "${1:-}" && -f "$1" ]]; then
  CONTEXT=$(cat "$1")
else
  echo "Reading from stdin... (Ctrl+D when done)" >&2
  CONTEXT=$(cat)
fi

if [[ -z "$CONTEXT" ]]; then
  echo "ERROR: No input" >&2
  exit 1
fi

PROMPT="Compress this TradingView Pine Script backtest session for handoff to another AI agent.
Extract only what matters:
1. Unique errors (deduplicate — list each once with count if repeated)
2. Current metrics: WR%, PF, DD%, net profit, trade count
3. Last change attempted + outcome (pass/fail + reason)
4. Current parameter values for key inputs
5. What has NOT worked (do not retry list)

Target: under 200 words. No preamble. No fluff. Dense facts only.

Session to compress:
${CONTEXT}"

echo "=== Pine Compact (local Ollama) ===" >&2
echo "Compressing context..." >&2

RESPONSE=$(curl -sf "$OLLAMA_URL" \
  -H "Content-Type: application/json" \
  -d "$(printf '{"model":"%s","prompt":%s,"stream":false}' "$MODEL" "$(echo "$PROMPT" | jq -Rs .)")") || true

if [[ -z "$RESPONSE" ]]; then
  echo "ERROR: Ollama unreachable at $OLLAMA_URL" >&2
  exit 1
fi

COMPACT=$(echo "$RESPONSE" | jq -r '.response // .error')
echo "$COMPACT"

# Optionally save to file for pasting into cloud session
OUTPUT_FILE="/tmp/pine_compact_context.txt"
echo "$COMPACT" > "$OUTPUT_FILE"
echo "" >&2
echo "Saved to: $OUTPUT_FILE (paste into cloud session)" >&2
echo "Approx tokens saved: $(echo "$CONTEXT" | wc -w) words → $(echo "$COMPACT" | wc -w) words" >&2
