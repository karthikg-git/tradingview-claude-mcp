#!/usr/bin/env bash
# pine-architect.sh <file.pine>
# Local Ollama pre-flight: catches syntax/logic/repainting issues before cloud compile
# Uses qwen2.5-coder:32b — FREE, no Anthropic tokens consumed

set -euo pipefail

PINE_FILE="${1:-}"
if [[ -z "$PINE_FILE" ]]; then
  # Auto-find most recently modified .pine in strategies/
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # ls -t sorts by mod time; works on all platforms including Windows Git Bash
  PINE_FILE=$(ls -t "$SCRIPT_DIR/../strategies/"*.pine 2>/dev/null | head -1)
  if [[ -z "$PINE_FILE" ]]; then
    echo "ERROR: No .pine files found in strategies/" >&2
    exit 1
  fi
  echo "Auto-selected: $PINE_FILE"
fi

if [[ ! -f "$PINE_FILE" ]]; then
  echo "ERROR: File not found: $PINE_FILE" >&2
  exit 1
fi

MODEL="qwen2.5-coder:32b"
OLLAMA_URL="http://localhost:11434/api/generate"
PINE_CODE=$(cat "$PINE_FILE")

PROMPT="You are an expert TradingView Pine Script v5 developer. Review this Pine Script for:
1. Syntax errors (invalid calls, missing brackets, wrong arg types)
2. Repainting (future data, request.security lookahead misuse, referencing bar_index[0] in conditions)
3. Logic errors (contradicting entry/exit conditions, conditions that never trigger)
4. Performance (expensive calcs inside loops, redundant series)
5. Common bugs (missing barstate.isconfirmed on entries, strategy.close before entry, etc.)

Format response exactly as:
STATUS: PASS or FAIL
ISSUES:
- [CRITICAL|WARNING|INFO] <description> (line N if detectable)
SUGGESTIONS:
- <fix per issue, one line>

Be concise. Flag real issues only — no generic advice.

Pine Script:
\`\`\`pine
${PINE_CODE}
\`\`\`"

echo "=== Pine Architect (local Ollama) ==="
echo "File: $PINE_FILE"
echo "Model: $MODEL"
echo ""

RESPONSE=$(curl -sf "$OLLAMA_URL" \
  -H "Content-Type: application/json" \
  -d "$(printf '{"model":"%s","prompt":%s,"stream":false}' "$MODEL" "$(echo "$PROMPT" | jq -Rs .)")") || true

if [[ -z "$RESPONSE" ]]; then
  echo "ERROR: Ollama unreachable at $OLLAMA_URL" >&2
  echo "Start with: ollama serve" >&2
  exit 1
fi

echo "$RESPONSE" | jq -r '.response // .error // "No response from model"'
echo ""
echo "=== Token cost: \$0.00 (local) ==="
