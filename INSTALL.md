# Complete Installation Guide

## Quick Install (Single Command)

### macOS / Linux

```bash
git clone https://github.com/karthikg-git/tradingview-claude-mcp.git
cd tradingview-claude-mcp
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/karthikg-git/tradingview-claude-mcp.git
cd tradingview-claude-mcp
.\install.ps1
```

**That's it!** Restart Claude Code and type "health check" to verify.

---

## What Gets Installed

The automated installer:

1. ✅ Copies files to `~/tradingview-claude-mcp`
2. ✅ Installs npm dependencies (`@modelcontextprotocol/sdk`, `chrome-remote-interface`, `dotenv`)
3. ✅ Configures `~/.claude/.mcp.json` (merges with existing servers)
4. ✅ Installs hooks to `~/.claude/hooks/tradingview/`
5. ✅ Updates `~/.claude/settings.json` with UserPromptSubmit hooks
6. ✅ Creates `rules.json` from example template
7. ✅ Makes all scripts executable

Backups are created automatically before modifying existing configs.

---

## Prerequisites

### Required

| Component | Version | Check Command | Install Link |
|-----------|---------|---------------|--------------|
| **Node.js** | v18+ | `node --version` | [nodejs.org](https://nodejs.org/) |
| **npm** | v8+ | `npm --version` | Comes with Node.js |
| **TradingView Desktop** | Latest | Check Applications folder | [tradingview.com/desktop](https://www.tradingview.com/desktop/) |
| **Claude Code** | Latest | Check `~/.claude/` exists | [claude.ai/code](https://claude.ai/code) |

### Optional (for advanced features)

- **jq** - JSON processor for config merging (recommended)
  - macOS: `brew install jq`
  - Linux: `sudo apt install jq`
  
- **curl** - For health checks (usually pre-installed)
- **nc** (netcat) - For port checking (usually pre-installed)

---

## Manual Installation

If the automated installer doesn't work, follow these steps:

### 1. Clone and Install Dependencies

```bash
git clone https://github.com/karthikg-git/tradingview-claude-mcp.git ~/tradingview-claude-mcp
cd ~/tradingview-claude-mcp
npm install
```

### 2. Configure MCP Server

Edit or create `~/.claude/.mcp.json`:

```json
{
  "mcpServers": {
    "tradingview": {
      "command": "node",
      "args": ["/Users/YOUR_USERNAME/tradingview-claude-mcp/src/server.js"]
    }
  }
}
```

**Replace `YOUR_USERNAME`** with your actual username:
- macOS/Linux: Run `whoami` or `echo $USER`
- Windows: Run `echo %USERNAME%`

### 3. Install Hooks

**macOS:**
```bash
mkdir -p ~/.claude/hooks/tradingview
cp hooks/macos/*.sh ~/.claude/hooks/tradingview/
chmod +x ~/.claude/hooks/tradingview/*.sh
```

**Linux:**
```bash
mkdir -p ~/.claude/hooks/tradingview
cp hooks/linux/*.sh ~/.claude/hooks/tradingview/
chmod +x ~/.claude/hooks/tradingview/*.sh
```

**Windows:**
```powershell
New-Item -Path "$env:USERPROFILE\.claude\hooks\tradingview" -ItemType Directory -Force
Copy-Item -Path "hooks\windows\*" -Destination "$env:USERPROFILE\.claude\hooks\tradingview\"
```

### 4. Configure Claude Code Hooks

Edit or create `~/.claude/settings.json`:

**macOS/Linux:**
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)tradingview",
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/tradingview/launch_tv.sh",
            "timeout": 45000
          }
        ]
      },
      {
        "matcher": "(?i)health check",
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/tradingview/health_check.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  },
  "enabledMcpjsonServers": ["tradingview"]
}
```

**Windows (PowerShell):**
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)tradingview",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -File C:\\Users\\YOUR_USERNAME\\.claude\\hooks\\tradingview\\launch_tv.ps1",
            "timeout": 45000
          }
        ]
      }
    ]
  },
  "enabledMcpjsonServers": ["tradingview"]
}
```

### 5. Set Up Trading Rules (Optional)

```bash
cd ~/tradingview-claude-mcp
cp rules.example.json rules.json
# Edit rules.json to customize your trading rules
```

### 6. Restart Claude Code

Completely restart Claude Code (quit and reopen) to load the new MCP server.

---

## Verification

After installation, verify everything works:

### Step 1: Check MCP Server

In Claude Code, type:
```
health check
```

Expected output:
```json
{"status":"ready","cdp_port":9222,"pages":"1","message":"CDP is healthy"}
```

Or if TradingView isn't running:
```json
{"status":"not_ready","cdp_port":9222,"message":"TradingView CDP is not responding — type tradingview to launch"}
```

### Step 2: Launch TradingView

Type:
```
tradingview
```

Expected: TradingView Desktop launches with CDP enabled.

### Step 3: Test MCP Tools

Type:
```
What symbol is currently shown on my TradingView chart?
```

Claude should use `mcp__tradingview__chart_get_state` to read your chart.

### Step 4: Run Morning Brief

Type:
```
Give me a morning brief on SPY
```

Claude should:
1. Launch TradingView (if needed)
2. Set symbol to SPY
3. Analyze chart with indicators
4. Provide market summary

---

## Troubleshooting

### MCP Server Not Loading

**Symptom:** No `mcp__tradingview__*` tools available

**Fix:**
1. Check `~/.claude/.mcp.json` exists and has correct path
2. Verify Node.js can run the server:
   ```bash
   node ~/tradingview-claude-mcp/src/server.js
   ```
3. Check `~/.claude/settings.json` has `"tradingview"` in `enabledMcpjsonServers`
4. Restart Claude Code completely

### Hooks Not Triggering

**Symptom:** Typing "tradingview" doesn't launch the app

**Fix:**
1. Check `~/.claude/settings.json` has `UserPromptSubmit` hooks configured
2. Verify hook scripts are executable:
   ```bash
   ls -la ~/.claude/hooks/tradingview/
   ```
3. Test hook manually:
   ```bash
   bash ~/.claude/hooks/tradingview/launch_tv.sh
   ```
4. Check hook logs in Claude Code UI

### TradingView Won't Launch with CDP

**Symptom:** TradingView launches but CDP not accessible

**Fix:**
1. Completely quit TradingView (not just close window)
2. Check if port 9222 is already in use:
   ```bash
   lsof -i :9222
   ```
3. Run launch script manually:
   ```bash
   bash ~/.claude/hooks/tradingview/launch_tv.sh
   ```
4. Check logs:
   ```bash
   tail -f /tmp/tradingview_launch.log
   ```

### npm Install Fails

**Symptom:** `npm install` shows errors

**Fix:**
1. Update Node.js to latest LTS version
2. Clear npm cache:
   ```bash
   npm cache clean --force
   ```
3. Delete `node_modules` and `package-lock.json`:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

### Permission Denied Errors (macOS/Linux)

**Symptom:** `Permission denied` when running scripts

**Fix:**
```bash
chmod +x ~/.claude/hooks/tradingview/*.sh
chmod +x ~/tradingview-claude-mcp/hooks/**/*.sh
```

### jq Not Found (Non-critical)

**Symptom:** Installer warns "jq not found"

**Impact:** Config merging done manually, doesn't break functionality

**Fix (optional):**
- macOS: `brew install jq`
- Linux: `sudo apt install jq` or `sudo yum install jq`

---

## Uninstall

To completely remove TradingView MCP:

```bash
# Remove installation directory
rm -rf ~/tradingview-claude-mcp

# Remove hooks
rm -rf ~/.claude/hooks/tradingview

# Remove from .mcp.json (manual - remove "tradingview" entry)

# Remove from settings.json (manual - remove hook matchers)
```

Restore backups if needed:
```bash
ls ~/.claude/*.backup.*
```

---

## Advanced Configuration

### Custom CDP Port

If port 9222 conflicts, change it:

1. Edit hook scripts (`launch_tv.sh`, `health_check.sh`)
2. Change `CDP_PORT=9222` to your desired port
3. Restart TradingView

### Multiple TradingView Instances

Not supported - CDP connects to single instance on port 9222.

### Running on Remote Server

For headless servers:
1. Use Xvfb for virtual display (Linux)
2. Enable SSH port forwarding for CDP:
   ```bash
   ssh -L 9222:localhost:9222 user@remote-server
   ```

---

## Next Steps

Once installed:

1. **Read the full README.md** - Learn about 78 MCP tools
2. **Explore skills/** - Pre-built workflows (morning brief, replay, strategy reports)
3. **Customize rules.json** - Define your trading rules and preferences
4. **Try CLI tools** - `tv chart SPY`, `tv pine list`, `tv alert create`

Need help? [Open an issue](https://github.com/karthikg-git/tradingview-claude-mcp/issues)
