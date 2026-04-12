# TradingView Claude MCP Setup

One-command setup to connect **Claude Code** to **TradingView Desktop** via Chrome DevTools Protocol (CDP).

After setup, type `tradingview` in the Claude Code chat — TradingView launches with CDP enabled and Claude automatically verifies the connection.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Windows 10 / 11 | Windows Store (WindowsApps) install only |
| [TradingView Desktop](https://apps.microsoft.com/detail/9N57FSXPF50X) | Install from the Microsoft Store |
| [Claude Code](https://claude.ai/code) | Must be installed and authenticated |
| TradingView MCP server | Must be configured in your `.mcp.json` (see your Claude Code docs) |

---

## Quick Setup

```powershell
# 1. Clone the repo
git clone https://github.com/karthikg-git/tradingview-claude-mcp.git
cd tradingview-claude-mcp

# 2. Run the installer (no admin required)
.\setup.ps1
```

**Then restart Claude Code** and type `tradingview` in chat.

---

## What `setup.ps1` does

1. Verifies **TradingView Desktop** is installed (auto-detects version path — survives app updates)
2. Verifies **Claude Code** is in PATH
3. Copies `launch_tv.ps1` and `launch_tv.bat` to `~\Automation\Tradingview\`
4. Adds a `UserPromptSubmit` hook to `~\.claude\settings.json` that intercepts the keyword `tradingview` and runs the launch script

No admin rights required. Safe to rerun — it skips steps already done.

---

## Usage

In any Claude Code session, just type:

```
tradingview
```

Claude will:
1. Kill any existing TradingView instance
2. Relaunch with `--remote-debugging-port=9222`
3. Poll until CDP is ready (up to 20 seconds)
4. Run `tv_health_check` automatically

### Manual launch (no chat needed)

Double-click `launch_tv.bat` in `~\Automation\Tradingview\`, or run:

```powershell
~\Automation\Tradingview\launch_tv.ps1
```

Then say `health check` in Claude Code chat.

---

## How it works

TradingView Desktop (Windows Store) must be launched with `--remote-debugging-port=9222` for CDP to bind. The TradingView MCP server connects to this port to control charts.

The `UserPromptSubmit` hook in Claude Code fires on every chat message. When it detects the exact word `tradingview`, it:

1. Kills existing TradingView processes (avoids port conflicts)
2. Launches the correct binary with CDP enabled
3. Polls `127.0.0.1:9222` via TCP until ready
4. Returns a JSON `additionalContext` that tells Claude to run `tv_health_check`

```
User types 'tradingview'
       │
       ▼
UserPromptSubmit hook fires
       │
       ▼
launch_tv.ps1 runs
  ├── Kill existing TradingView.exe
  ├── Start TradingView.exe --remote-debugging-port=9222
  └── Poll port 9222 until ready
       │
       ▼
additionalContext injected into Claude
       │
       ▼
Claude runs tv_health_check → Connected!
```

---

## File structure

```
tradingview-claude-mcp/
├── README.md          ← this file
├── setup.ps1          ← one-click installer
├── launch_tv.ps1      ← CDP launch script (used by hook and manually)
└── launch_tv.bat      ← manual double-click fallback
```

After setup, scripts live at `~\Automation\Tradingview\`.

---

## Troubleshooting

**`tv_launch` MCP tool fails / CDP not connecting**
The Windows Store (WindowsApps) sandbox prevents the built-in `tv_launch` MCP tool from binding CDP. This repo's approach bypasses that by launching the binary directly.

**CDP not ready after 20 seconds**
TradingView is slow on a cold start. Say `health check` in Claude Code chat to retry — Claude will keep trying until it connects.

**Hook not firing after setup**
The settings watcher needs to reload. Run `/hooks` in Claude Code or restart the session.

**Multiple `TradingView.exe` processes**
Normal — the app spawns ~10 renderer subprocesses. Only the main process binds port 9222.

**TradingView updated and path changed**
`launch_tv.ps1` auto-detects the version path (`TradingView.Desktop_*_x64_*`) — no manual update needed after a Store update.

**Hook already exists warning during setup**
Setup detected a previous installation and skipped re-adding the hook. Existing config is preserved.

---

## On a new PC — complete checklist

- [ ] Install TradingView Desktop from Microsoft Store
- [ ] Install Claude Code and authenticate (`claude login`)
- [ ] Configure TradingView MCP server in your `.mcp.json`
- [ ] Clone this repo and run `setup.ps1`
- [ ] Restart Claude Code
- [ ] Type `tradingview` to confirm everything works
