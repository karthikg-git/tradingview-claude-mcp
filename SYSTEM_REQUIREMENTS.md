# System Requirements

Complete system requirements for TradingView Claude MCP installation.

---

## Minimum Requirements

### Hardware

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | Dual-core 2.0 GHz | Quad-core 3.0 GHz+ |
| **RAM** | 4 GB | 8 GB+ |
| **Disk Space** | 500 MB | 1 GB+ |
| **Display** | 1280x720 | 1920x1080+ |
| **Internet** | 5 Mbps | 25 Mbps+ (for real-time data) |

### Software

| Component | Version | Check Command | Install |
|-----------|---------|---------------|---------|
| **Operating System** | | | |
| - macOS | 10.15+ (Catalina or later) | `sw_vers` | - |
| - Windows | 10/11 (64-bit) | `ver` | - |
| - Linux | Ubuntu 20.04+, Debian 10+, Fedora 33+ | `lsb_release -a` | - |
| **Node.js** | v18.0.0 or higher | `node --version` | [nodejs.org](https://nodejs.org/) |
| **npm** | v8.0.0 or higher | `npm --version` | Bundled with Node.js |
| **TradingView Desktop** | Latest version | Check Applications folder | [tradingview.com/desktop](https://www.tradingview.com/desktop/) |
| **Claude Code** | Latest version | `claude --version` | [claude.ai/code](https://claude.ai/code) |

### Optional Tools

| Tool | Purpose | Install |
|------|---------|---------|
| **git** | Clone repository | Pre-installed (macOS/Linux), [git-scm.com](https://git-scm.com/) (Windows) |
| **curl** | Health checks | Pre-installed (macOS/Linux), `choco install curl` (Windows) |
| **jq** | JSON processing | `brew install jq` (macOS), `apt install jq` (Linux), `choco install jq` (Windows) |
| **nc** (netcat) | Port checking | Pre-installed (macOS/Linux), `nmap` package (Windows) |

---

## Platform-Specific Requirements

### macOS

**Supported Versions:**
- macOS 10.15 (Catalina) or later
- macOS 11 (Big Sur)
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15+ (Latest)

**Architecture:**
- Intel (x86_64)
- Apple Silicon (ARM64/M1/M2/M3/M4)

**Required Permissions:**
- Full Disk Access for Terminal/Claude Code (System Preferences > Security & Privacy)
- Network access for TradingView Desktop

**Installation Methods:**
- **Homebrew** (recommended): `brew install node`
- **Official installer**: [nodejs.org/download](https://nodejs.org/download/)
- **nvm**: Node Version Manager

**Shell Support:**
- bash (default on older macOS)
- zsh (default on macOS 10.15+)
- fish, sh

### Linux

**Supported Distributions:**
- Ubuntu 20.04 LTS, 22.04 LTS, 24.04 LTS
- Debian 10, 11, 12
- Fedora 33+
- CentOS 8+
- Arch Linux (latest)
- Pop!_OS 20.04+

**Architecture:**
- x86_64 (AMD64)
- ARM64 (aarch64)

**Dependencies:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y nodejs npm curl netcat-openbsd git

# Fedora/CentOS
sudo dnf install -y nodejs npm curl nmap-ncat git

# Arch Linux
sudo pacman -S nodejs npm curl gnu-netcat git
```

**Display Server:**
- X11 (tested)
- Wayland (should work, not extensively tested)

**Window Manager:**
- GNOME, KDE, XFCE, i3, etc. (any)

### Windows

**Supported Versions:**
- Windows 10 (64-bit, version 1903 or later)
- Windows 11 (64-bit)

**Architecture:**
- x86_64 (AMD64 only)
- ARM64 not supported (TradingView Desktop limitation)

**PowerShell:**
- PowerShell 5.1+ (pre-installed)
- PowerShell 7+ (recommended for better performance)

**Required Components:**
- Windows Defender exclusion for `tradingview-claude-mcp` folder (optional, speeds up npm install)
- Microsoft Visual C++ Redistributable (usually pre-installed)

**Installation Methods:**
- **Official installer**: [nodejs.org/download](https://nodejs.org/download/) (recommended)
- **Chocolatey**: `choco install nodejs`
- **Scoop**: `scoop install nodejs`
- **nvm-windows**: Node Version Manager for Windows

**Terminal:**
- PowerShell (recommended)
- Command Prompt (cmd)
- Windows Terminal (best experience)
- Git Bash (works but not officially supported for hooks)

---

## TradingView Requirements

### Desktop Application

**Version:**
- Latest version recommended
- v2.14+ required (older versions may have CDP issues)

**Download:**
- [tradingview.com/desktop](https://www.tradingview.com/desktop/)

**Installation Paths:**
- macOS: `/Applications/TradingView.app`
- Windows: `%LOCALAPPDATA%\Programs\TradingView\TradingView.exe` or `C:\Program Files\TradingView\`
- Linux: `/opt/TradingView/`, `/usr/bin/tradingview`, or `~/.local/bin/tradingview`

### Subscription

**Required:**
- Any paid TradingView subscription (Pro, Pro+, or Premium)
- Real-time data access for your desired markets

**Why:**
- Free accounts have 15-minute delayed data
- Some indicators require paid subscriptions
- Morning brief workflow needs real-time data

**Pricing:**
- [tradingview.com/pricing](https://www.tradingview.com/pricing/)

---

## Claude Code Requirements

### Version

**Required:**
- Latest stable release

**Download:**
- [claude.ai/code](https://claude.ai/code)

**Platforms:**
- macOS (Intel & Apple Silicon)
- Windows (x86_64)
- Linux (x86_64)

### Configuration Directory

**Location:**
- macOS/Linux: `~/.claude/`
- Windows: `%USERPROFILE%\.claude\`

**Required Files:**
- `.mcp.json` - MCP server configuration
- `settings.json` - Hooks and preferences (optional but recommended)

### Permissions

Claude Code needs permission to:
- Execute bash/PowerShell scripts (for hooks)
- Read/write to `~/.claude/` directory
- Network access to localhost:9222 (CDP port)

---

## Network Requirements

### Ports

| Port | Protocol | Purpose | Direction |
|------|----------|---------|-----------|
| 9222 | TCP | Chrome DevTools Protocol (CDP) | Localhost only |

**Firewall:**
- No inbound rules needed (localhost only)
- Allow TradingView Desktop outbound for market data

**Proxy:**
- TradingView Desktop must be able to connect to TradingView servers
- CDP runs on localhost, not affected by proxy

---

## Verification Checklist

Run these commands to verify your system meets requirements:

### macOS / Linux

```bash
# Node.js version (should be v18+)
node --version

# npm version (should be v8+)
npm --version

# TradingView Desktop (should show path)
ls -la /Applications/TradingView.app  # macOS
which tradingview  # Linux

# Claude Code config directory
ls -la ~/.claude/

# Optional tools
curl --version
nc -h 2>&1 | head -1
jq --version
git --version
```

### Windows (PowerShell)

```powershell
# Node.js version (should be v18+)
node --version

# npm version (should be v8+)
npm --version

# TradingView Desktop
Test-Path "$env:LOCALAPPDATA\Programs\TradingView\TradingView.exe"

# Claude Code config directory
Test-Path "$env:USERPROFILE\.claude"

# Optional tools
curl --version
git --version
```

---

## Installation Size

| Component | Size |
|-----------|------|
| Repository (without node_modules) | ~5 MB |
| npm dependencies (node_modules) | ~25 MB |
| Total installation | ~30 MB |
| Screenshots (optional, generated) | Varies |
| Session data (optional, generated) | < 1 MB |

---

## Performance Considerations

### CPU Usage

- **Idle:** < 1% CPU
- **During MCP calls:** 5-15% CPU
- **During compilation (Pine):** 10-30% CPU

### Memory Usage

- **Node.js server:** ~50-100 MB
- **TradingView Desktop:** 200-500 MB
- **Claude Code:** 300-800 MB
- **Total:** ~600 MB - 1.5 GB

### Network Usage

- **MCP server:** ~0 KB/s (localhost only)
- **TradingView real-time data:** 10-50 KB/s
- **Claude Code (cloud):** Varies by usage

### Disk I/O

- **Minimal** during normal operation
- **Higher** during npm install (one-time)
- **Session saves:** < 100 KB per save

---

## Common Compatibility Issues

### Node.js Version Too Old

**Symptom:**
```
SyntaxError: Unexpected token '?'
```

**Fix:**
Update Node.js to v18+ from [nodejs.org](https://nodejs.org/)

### TradingView Desktop Not Found

**Symptom:**
```
TradingView.app not found at /Applications/TradingView.app
```

**Fix:**
1. Install TradingView Desktop from [tradingview.com/desktop](https://www.tradingview.com/desktop/)
2. Verify installation path matches script expectations
3. Update hook scripts if installed to custom location

### PowerShell Execution Policy (Windows)

**Symptom:**
```
.\install.ps1 : File cannot be loaded because running scripts is disabled
```

**Fix:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Permission Denied (macOS/Linux)

**Symptom:**
```
bash: ./install.sh: Permission denied
```

**Fix:**
```bash
chmod +x install.sh hooks/**/*.sh
```

---

## Upgrade Path

### From Original tradingview-mcp

1. Backup existing installation
2. Clone this repository
3. Run automated installer
4. Migrate `rules.json` if you customized it

### From tradingview-mcp-jackson

1. Clone this repository
2. Run automated installer
3. Your existing rules.json will be preserved

---

## Support Matrix

| OS | Architecture | Status | Tested |
|----|--------------|--------|--------|
| macOS 15 (Sequoia) | Apple Silicon (M4) | ✅ Supported | ✅ Yes |
| macOS 15 (Sequoia) | Apple Silicon (M1/M2/M3) | ✅ Supported | ✅ Yes |
| macOS 14 (Sonoma) | Intel/ARM | ✅ Supported | ✅ Yes |
| macOS 13 (Ventura) | Intel/ARM | ✅ Supported | ✅ Yes |
| macOS 12 (Monterey) | Intel/ARM | ✅ Supported | ⚠️ Limited |
| macOS 11 (Big Sur) | Intel/ARM | ✅ Supported | ⚠️ Limited |
| macOS 10.15 (Catalina) | Intel | ✅ Supported | ⚠️ Limited |
| Windows 11 | x86_64 | ✅ Supported | ✅ Yes |
| Windows 10 (1903+) | x86_64 | ✅ Supported | ✅ Yes |
| Ubuntu 24.04 LTS | x86_64 | ✅ Supported | ✅ Yes |
| Ubuntu 22.04 LTS | x86_64 | ✅ Supported | ✅ Yes |
| Ubuntu 20.04 LTS | x86_64 | ✅ Supported | ⚠️ Limited |
| Debian 12 | x86_64 | ✅ Supported | ⚠️ Limited |
| Fedora 39+ | x86_64 | ✅ Supported | ⚠️ Limited |
| Arch Linux | x86_64 | ✅ Supported | ⚠️ Limited |

✅ Fully supported and tested  
⚠️ Supported but not extensively tested  
❌ Not supported

---

## Getting Help

If your system doesn't meet requirements:

1. **Check Node.js version**: Upgrade to v18+ from [nodejs.org](https://nodejs.org/)
2. **Check TradingView Desktop**: Install from [tradingview.com/desktop](https://www.tradingview.com/desktop/)
3. **Check Claude Code**: Install from [claude.ai/code](https://claude.ai/code)
4. **Open an issue**: [GitHub Issues](https://github.com/karthikg-git/tradingview-claude-mcp/issues)

---

**Ready to install?** Head to [INSTALL.md](INSTALL.md) or run the automated installer!
