#!/usr/bin/env python3
"""
PreToolUse hook: intercepts Edit/Write on .pine files.
Blocks Claude's direct edit → forces delegation to pine-edit-local.sh (Ollama, free).
Exit 2 = block + feed message to Claude.
Exit 1 = warn but allow (Ollama down — no deadlock).
Exit 0 = allow (non-pine file).
"""
import json
import sys
import os
import urllib.request

OLLAMA_URL = "http://localhost:11434"

def ollama_running():
    try:
        urllib.request.urlopen(f"{OLLAMA_URL}/api/tags", timeout=2)
        return True
    except Exception:
        return False

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool_name = data.get("tool_name", "")
tool_input = data.get("tool_input", {})
file_path = tool_input.get("file_path", tool_input.get("path", ""))

if tool_name not in ("Edit", "Write", "MultiEdit"):
    sys.exit(0)

if not file_path.endswith(".pine"):
    sys.exit(0)

# Escape hatch: if Ollama is down, warn but allow direct edit (avoid deadlock)
if not ollama_running():
    print("WARNING: Ollama unreachable — allowing direct Edit/Write (cloud tokens apply).")
    print("To restore local routing: run 'ollama serve' in a terminal.")
    sys.exit(1)  # warn Claude but do NOT block

hook_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(os.path.dirname(hook_dir))
display_path = os.path.relpath(file_path, project_root) if os.path.isabs(file_path) else file_path

print("BLOCKED: Direct edits to .pine files route through local Ollama (free).")
print("")
print("Use instead:")
print(f'  bash scripts/pine-edit-local.sh "{display_path}" "<describe the change>"')
print("")
print("Model: qwen2.5-coder:32b | Cost: $0.00")

sys.exit(2)
