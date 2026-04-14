# Changelog

All notable changes to TradingView Claude MCP are documented in this file.

## [Complete Edition] - 2026-04-14

### 🚀 Major Features Added

#### Automated Installation
- **Single-command installers** for macOS, Linux, and Windows
- `install.sh` - Bash installer for macOS/Linux with automatic prerequisites check
- `install.ps1` - PowerShell installer for Windows with full automation
- Automatic config merging (preserves existing MCP servers and settings)
- Automatic backup of existing configurations
- Smart prerequisite detection and validation

#### Cross-Platform Hook Scripts
- **macOS hooks** (`hooks/macos/`) - Bash scripts for TradingView CDP launch and health checks
- **Linux hooks** (`hooks/linux/`) - Compatible with multiple distributions
- **Windows hooks** (`hooks/windows/`) - PowerShell scripts with same functionality
- Auto-launch TradingView when mentioning "tradingview" in prompts
- Health check integration with "health check" trigger

#### Comprehensive Documentation
- **INSTALL.md** - Complete installation guide with troubleshooting
- **QUICKSTART.md** - Get started in under 5 minutes
- **SYSTEM_REQUIREMENTS.md** - Detailed system requirements and compatibility matrix
- **CHANGELOG.md** - This file, tracking all changes
- Updated **README.md** - Complete overview with all features
- Configuration examples in `/config/` directory

### 🔧 Configuration

#### New Configuration Templates
- `config/mcp.json.example` - MCP server configuration template
- `config/settings.json.example` - Claude Code settings template with hooks
- Platform-specific hook configurations

#### Directory Structure
```
hooks/
├── macos/          # macOS launch scripts
├── linux/          # Linux launch scripts
└── windows/        # Windows PowerShell scripts

config/
├── mcp.json.example
└── settings.json.example
```

### 📚 Documentation Updates

#### New Documentation Files
- **INSTALL.md** - Step-by-step installation for all platforms
- **QUICKSTART.md** - Quick start guide with common workflows
- **SYSTEM_REQUIREMENTS.md** - Complete requirements and compatibility
- **CHANGELOG.md** - Version history and changes

#### Updated Documentation
- **README.md** - Completely rewritten with:
  - Single-command installation instructions
  - 78 MCP tools reference
  - Configuration examples
  - Daily workflow examples
  - CLI usage guide
  - Troubleshooting section

### 🐛 Bug Fixes

- Fixed TradingView Desktop v2.14+ launch compatibility
- Improved CDP connection reliability
- Better error messages in hooks
- Enhanced timeout handling for TradingView launch

### 🎯 Improvements

#### Installation Process
- Automatic npm dependency installation
- Smart config file merging (no overwrites)
- Automatic backup before modifications
- Cross-platform path handling
- jq integration for JSON processing (optional)

#### Hook Scripts
- Better error messages with JSON output
- Polling mechanism for CDP readiness
- Configurable timeouts
- Multiple TradingView installation path detection
- Process cleanup before launch

#### User Experience
- Color-coded installer output
- Clear next steps after installation
- Verification commands provided
- Comprehensive troubleshooting guides
- Quick reference cards

### 🔒 Security

- All operations local-only (no external data transmission)
- CDP runs on localhost:9222 only
- Automatic backup of existing configurations
- No credential storage required
- Read-only by default (writes only to config files)

### 📊 Testing

- Verified on macOS (Intel & Apple Silicon)
- Verified on Windows 10/11
- Verified on Ubuntu 22.04, 24.04
- Hook scripts tested across platforms
- Installation tested from scratch

### 🌟 Inherited Features (from upstream)

All features from tradingview-mcp-jackson:
- Morning brief workflow (`morning_brief` tool)
- Session save/load (`session_save`, `session_get`)
- Trading rules configuration (`rules.json`)
- 78 MCP tools for TradingView control
- Pine Script development tools
- Strategy backtesting
- Replay mode
- Multi-symbol scanning
- Custom indicator data extraction
- CLI tools (`tv` command)

All features from original tradingview-mcp:
- Chrome DevTools Protocol integration
- Chart state reading
- Indicator value extraction
- Symbol/timeframe control
- Drawing tools
- Alert management
- Screenshot capture
- Tab/layout management
- UI automation

### 📦 Dependencies

No new dependencies added. Uses existing:
- `@modelcontextprotocol/sdk` ^1.12.1
- `chrome-remote-interface` ^0.33.2
- `dotenv` ^17.4.1

### 🔄 Migration

#### From Original tradingview-mcp
1. Clone this repository
2. Run `bash install.sh` (macOS/Linux) or `.\install.ps1` (Windows)
3. Migrate your rules.json if customized

#### From tradingview-mcp-jackson
1. Clone this repository
2. Run automated installer
3. Existing rules.json preserved automatically

### 🚧 Known Issues

None identified in this release.

### 📝 Notes

- Automated installation tested on fresh systems
- All previous manual setup methods still supported
- Backward compatible with existing configurations
- No breaking changes to MCP tools or API

### 🙏 Credits

- Original [tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp) by @tradesdontlie
- Enhanced [tradingview-mcp-jackson](https://github.com/LewisWJackson/tradingview-mcp-jackson) by @LewisWJackson
- This Complete Edition adds automated installation and comprehensive docs

---

## [Previous Versions]

See upstream repositories for earlier version history:
- https://github.com/tradesdontlie/tradingview-mcp
- https://github.com/LewisWJackson/tradingview-mcp-jackson

---

## Future Roadmap

Potential future enhancements:
- [ ] Automated testing CI/CD
- [ ] Docker container support
- [ ] Additional pre-built skills
- [ ] Web dashboard for session management
- [ ] Multi-chart synchronized analysis
- [ ] Advanced portfolio tracking
- [ ] Integration with other trading platforms

---

**Version:** Complete Edition (2026-04-14)  
**License:** MIT  
**Repository:** https://github.com/karthikg-git/tradingview-claude-mcp
