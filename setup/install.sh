#!/bin/bash
# TradingView Claude MCP - Automated Installation Script
# Supports: macOS, Linux
# Usage: bash install.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/tradingview-claude-mcp"
CLAUDE_CONFIG_DIR="$HOME/.claude"
MCP_CONFIG="$CLAUDE_CONFIG_DIR/.mcp.json"
SETTINGS_CONFIG="$CLAUDE_CONFIG_DIR/settings.json"
HOOKS_DIR="$HOME/.claude/hooks/tradingview"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   TradingView Claude MCP - Auto Installer         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect OS
OS_TYPE="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    echo -e "${GREEN}✓${NC} Detected: macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
    echo -e "${GREEN}✓${NC} Detected: Linux"
else
    echo -e "${RED}✗${NC} Unsupported OS: $OSTYPE"
    echo "   This installer supports macOS and Linux only."
    echo "   For Windows, use install.ps1 instead."
    exit 1
fi

echo ""
echo "=== Prerequisites Check ==="

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗${NC} Node.js not found"
    echo "   Install Node.js from https://nodejs.org/ (v18+ recommended)"
    exit 1
else
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js: $NODE_VERSION"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗${NC} npm not found"
    exit 1
else
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm: $NPM_VERSION"
fi

# Check for TradingView Desktop
if [ "$OS_TYPE" == "macos" ]; then
    if [ ! -d "/Applications/TradingView.app" ]; then
        echo -e "${YELLOW}⚠${NC}  TradingView Desktop not found at /Applications/TradingView.app"
        echo "   Install from: https://www.tradingview.com/desktop/"
        echo "   You can continue installation and install TradingView later."
        read -p "   Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo -e "${GREEN}✓${NC} TradingView Desktop found"
    fi
fi

# Check Claude Code
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    echo -e "${YELLOW}⚠${NC}  Claude Code config directory not found at $CLAUDE_CONFIG_DIR"
    echo "   Creating directory..."
    mkdir -p "$CLAUDE_CONFIG_DIR"
fi
echo -e "${GREEN}✓${NC} Claude Code config directory exists"

echo ""
echo "=== Installation Steps ==="

# Step 1: Install to home directory (if not already there)
if [ "$REPO_DIR" != "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[1/6]${NC} Copying files to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    rsync -av --exclude='node_modules' --exclude='.git' --exclude='.env' "$REPO_DIR/" "$INSTALL_DIR/"
    cd "$INSTALL_DIR"
    echo -e "${GREEN}✓${NC} Files copied successfully"
else
    echo -e "${YELLOW}[1/6]${NC} Already in installation directory"
    cd "$INSTALL_DIR"
fi

# Step 2: Install npm dependencies
echo -e "${YELLOW}[2/6]${NC} Installing npm dependencies..."
npm install
echo -e "${GREEN}✓${NC} Dependencies installed"

# Step 3: Configure MCP server
echo -e "${YELLOW}[3/6]${NC} Configuring MCP server..."

if [ -f "$MCP_CONFIG" ]; then
    # Backup existing config
    cp "$MCP_CONFIG" "$MCP_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓${NC} Backed up existing .mcp.json"

    # Merge with existing config using jq (if available)
    if command -v jq &> /dev/null; then
        TMP_CONFIG=$(mktemp)
        jq --arg path "$INSTALL_DIR/src/server.js" \
           '.mcpServers.tradingview = {"command": "node", "args": [$path]}' \
           "$MCP_CONFIG" > "$TMP_CONFIG"
        mv "$TMP_CONFIG" "$MCP_CONFIG"
        echo -e "${GREEN}✓${NC} Merged TradingView MCP into existing config"
    else
        echo -e "${YELLOW}⚠${NC}  jq not found, creating standalone config"
        cat > "$MCP_CONFIG" <<EOF
{
  "mcpServers": {
    "tradingview": {
      "command": "node",
      "args": ["$INSTALL_DIR/src/server.js"]
    }
  }
}
EOF
    fi
else
    # Create new config
    cat > "$MCP_CONFIG" <<EOF
{
  "mcpServers": {
    "tradingview": {
      "command": "node",
      "args": ["$INSTALL_DIR/src/server.js"]
    }
  }
}
EOF
    echo -e "${GREEN}✓${NC} Created new .mcp.json"
fi

# Step 4: Install hooks
echo -e "${YELLOW}[4/6]${NC} Installing Claude Code hooks..."
mkdir -p "$HOOKS_DIR"
cp "$INSTALL_DIR/hooks/$OS_TYPE/launch_tv.sh" "$HOOKS_DIR/"
cp "$INSTALL_DIR/hooks/$OS_TYPE/health_check.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/launch_tv.sh"
chmod +x "$HOOKS_DIR/health_check.sh"
echo -e "${GREEN}✓${NC} Hooks installed to $HOOKS_DIR"

# Step 5: Configure settings.json hooks
echo -e "${YELLOW}[5/6]${NC} Configuring Claude Code settings..."

if [ -f "$SETTINGS_CONFIG" ]; then
    cp "$SETTINGS_CONFIG" "$SETTINGS_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓${NC} Backed up existing settings.json"

    if command -v jq &> /dev/null; then
        TMP_SETTINGS=$(mktemp)
        jq --arg launch "$HOOKS_DIR/launch_tv.sh" \
           --arg health "$HOOKS_DIR/health_check.sh" \
           '
           .hooks.UserPromptSubmit |= (. // []) + [
             {
               "matcher": "(?i)tradingview",
               "hooks": [{
                 "type": "command",
                 "command": ("bash " + $launch),
                 "timeout": 45000
               }]
             },
             {
               "matcher": "(?i)health check",
               "hooks": [{
                 "type": "command",
                 "command": ("bash " + $health),
                 "timeout": 10000
               }]
             }
           ] | .enabledMcpjsonServers |= (. // []) + ["tradingview"] | .enabledMcpjsonServers |= unique
           ' "$SETTINGS_CONFIG" > "$TMP_SETTINGS"
        mv "$TMP_SETTINGS" "$SETTINGS_CONFIG"
        echo -e "${GREEN}✓${NC} Updated settings.json with hooks"
    else
        echo -e "${YELLOW}⚠${NC}  jq not found - please manually add hooks to settings.json"
        echo "   See: $INSTALL_DIR/config/settings.json.example"
    fi
else
    cat > "$SETTINGS_CONFIG" <<EOF
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)tradingview",
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOOKS_DIR/launch_tv.sh",
            "timeout": 45000
          }
        ]
      },
      {
        "matcher": "(?i)health check",
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOOKS_DIR/health_check.sh",
            "timeout": 10000
          }
        ]
      }
    ]
  },
  "enabledMcpjsonServers": ["tradingview"]
}
EOF
    echo -e "${GREEN}✓${NC} Created new settings.json with hooks"
fi

# Step 6: Set up trading rules (optional)
echo -e "${YELLOW}[6/6]${NC} Setting up trading rules..."
if [ ! -f "$INSTALL_DIR/rules.json" ] && [ -f "$INSTALL_DIR/rules.example.json" ]; then
    cp "$INSTALL_DIR/rules.example.json" "$INSTALL_DIR/rules.json"
    echo -e "${GREEN}✓${NC} Created rules.json from example"
    echo -e "${YELLOW}⚠${NC}  Edit $INSTALL_DIR/rules.json to customize your trading rules"
else
    echo -e "${GREEN}✓${NC} rules.json already exists"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Installation Complete! 🎉                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. ${YELLOW}Restart Claude Code${NC} to load the MCP server"
echo ""
echo "2. ${YELLOW}Test the installation:${NC}"
echo "   Type: ${GREEN}health check${NC}"
echo "   Expected: CDP status message"
echo ""
echo "3. ${YELLOW}Launch TradingView:${NC}"
echo "   Type: ${GREEN}tradingview${NC} in any Claude Code prompt"
echo ""
echo "4. ${YELLOW}Customize trading rules:${NC}"
echo "   Edit: ${GREEN}$INSTALL_DIR/rules.json${NC}"
echo ""
echo "5. ${YELLOW}Run your first analysis:${NC}"
echo "   Type: ${GREEN}Give me a morning brief on SPY${NC}"
echo ""
echo "Documentation: https://github.com/karthikg-git/tradingview-claude-mcp"
echo ""
echo "Troubleshooting:"
echo "  - If hooks don't trigger, check: $SETTINGS_CONFIG"
echo "  - If MCP tools missing, check: $MCP_CONFIG"
echo "  - For verbose logs: tail -f /tmp/tradingview_launch.log"
echo ""
