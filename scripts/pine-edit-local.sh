#!/usr/bin/env bash
# pine-edit-local.sh <file.pine> "<edit instruction>"
# Ollama (qwen2.5-coder:32b) generates the edit — zero cloud tokens consumed
# Claude calls this instead of Edit/Write on .pine files

set -euo pipefail

FILE="${1:-}"
INSTRUCTION="${2:-}"

if [[ -z "$FILE" || -z "$INSTRUCTION" ]]; then
  echo "Usage: pine-edit-local.sh <file.pine> '<edit instruction>'"
  echo "Example: pine-edit-local.sh strategies/QQQ_ORB.pine 'change stop loss from 0.5% to 0.3%'"
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: File not found: $FILE" >&2
  exit 1
fi

MODEL="qwen2.5-coder:32b"
OLLAMA_URL="http://localhost:11434/api/generate"
CURRENT_CODE=$(cat "$FILE")

PROMPT="You are an expert TradingView Pine Script v6 developer. Apply this change to the code below.

CHANGE REQUESTED: ${INSTRUCTION}

Rules:
- Return ONLY the complete modified Pine Script. Nothing else.
- No markdown fences (no \`\`\`pine or \`\`\`)
- No explanation before or after the code
- Preserve ALL unchanged logic exactly as-is
- No new comments unless the edit specifically requires one
- Must be valid Pine Script v6

CURRENT CODE:
${CURRENT_CODE}"

echo "Routing to local Ollama ($MODEL)..."
START=$(date +%s)

RESPONSE=$(curl -sf "$OLLAMA_URL" \
  -H "Content-Type: application/json" \
  -d "$(printf '{"model":"%s","prompt":%s,"stream":false}' "$MODEL" "$(echo "$PROMPT" | jq -Rs .)")") || true

if [[ -z "$RESPONSE" ]]; then
  echo "" >&2
  echo "ERROR: Ollama unreachable at $OLLAMA_URL" >&2
  echo "Fix: run 'ollama serve' in a terminal, then retry" >&2
  exit 1
fi

RESULT=$(echo "$RESPONSE" | jq -r '.response // empty')
if [[ -z "$RESULT" ]]; then
  echo "ERROR: Empty response from Ollama" >&2
  echo "Raw: $RESPONSE" >&2
  exit 1
fi

# Strip any markdown fences Ollama might add despite instructions
CLEAN=$(echo "$RESULT" | sed '/^```/d' | sed '/^$/N;/^\n$/d')

# Backup original before overwriting
cp "$FILE" "${FILE}.bak"
echo "$CLEAN" > "$FILE"

END=$(date +%s)
ELAPSED=$((END - START))
LINES=$(echo "$CLEAN" | wc -l)

echo "SUCCESS: Edit applied via Ollama (local)"
echo "File:    $FILE ($LINES lines)"
echo "Backup:  ${FILE}.bak"
echo "Time:    ${ELAPSED}s"
echo "Cost:    \$0.00 (no cloud tokens)"
