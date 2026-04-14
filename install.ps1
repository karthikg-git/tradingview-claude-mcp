# TradingView Claude MCP - Automated Installation Script (Windows)
# Usage: .\install.ps1
# Requires: PowerShell 5.1+ (Run as Administrator not required)

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallDir = Join-Path $env:USERPROFILE "tradingview-claude-mcp"
$ClaudeConfigDir = Join-Path $env:USERPROFILE ".claude"
$McpConfig = Join-Path $ClaudeConfigDir ".mcp.json"
$SettingsConfig = Join-Path $ClaudeConfigDir "settings.json"
$HooksDir = Join-Path $ClaudeConfigDir "hooks\tradingview"

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   TradingView Claude MCP - Auto Installer         ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "✓ Detected: Windows" -ForegroundColor Green
Write-Host ""

Write-Host "=== Prerequisites Check ===" -ForegroundColor Yellow

# Check Node.js
try {
    $nodeVersion = & node --version 2>$null
    Write-Host "✓ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found" -ForegroundColor Red
    Write-Host "  Install from https://nodejs.org/ (v18+ recommended)" -ForegroundColor Yellow
    exit 1
}

# Check npm
try {
    $npmVersion = & npm --version 2>$null
    Write-Host "✓ npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ npm not found" -ForegroundColor Red
    exit 1
}

# Check TradingView Desktop
$tvPaths = @(
    "$env:LOCALAPPDATA\Programs\TradingView\TradingView.exe",
    "$env:ProgramFiles\TradingView\TradingView.exe",
    "$env:ProgramFiles(x86)\TradingView\TradingView.exe"
)

$tvFound = $false
foreach ($path in $tvPaths) {
    if (Test-Path $path) {
        Write-Host "✓ TradingView Desktop found at $path" -ForegroundColor Green
        $tvFound = $true
        break
    }
}

if (-not $tvFound) {
    Write-Host "⚠ TradingView Desktop not found" -ForegroundColor Yellow
    Write-Host "  Install from: https://www.tradingview.com/desktop/" -ForegroundColor Yellow
    Write-Host "  You can continue installation and install TradingView later." -ForegroundColor Yellow
    $continue = Read-Host "  Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        exit 1
    }
}

# Check Claude Code
if (-not (Test-Path $ClaudeConfigDir)) {
    Write-Host "⚠ Claude Code config directory not found" -ForegroundColor Yellow
    Write-Host "  Creating directory..." -ForegroundColor Yellow
    New-Item -Path $ClaudeConfigDir -ItemType Directory -Force | Out-Null
}
Write-Host "✓ Claude Code config directory exists" -ForegroundColor Green

Write-Host ""
Write-Host "=== Installation Steps ===" -ForegroundColor Yellow

# Step 1: Install to user directory
if ($RepoDir -ne $InstallDir) {
    Write-Host "[1/6] Copying files to $InstallDir..." -ForegroundColor Yellow

    if (Test-Path $InstallDir) {
        $backup = "$InstallDir.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "  Backing up existing installation to $backup" -ForegroundColor Yellow
        Move-Item -Path $InstallDir -Destination $backup
    }

    New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null

    # Copy files excluding node_modules, .git, .env
    Get-ChildItem -Path $RepoDir -Recurse | Where-Object {
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\.git\\' -and
        $_.Name -ne '.env'
    } | ForEach-Object {
        $dest = $_.FullName.Replace($RepoDir, $InstallDir)
        if ($_.PSIsContainer) {
            New-Item -Path $dest -ItemType Directory -Force | Out-Null
        } else {
            $destDir = Split-Path -Parent $dest
            if (-not (Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $dest -Force
        }
    }

    Set-Location $InstallDir
    Write-Host "✓ Files copied successfully" -ForegroundColor Green
} else {
    Write-Host "[1/6] Already in installation directory" -ForegroundColor Yellow
    Set-Location $InstallDir
}

# Step 2: Install npm dependencies
Write-Host "[2/6] Installing npm dependencies..." -ForegroundColor Yellow
& npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependencies installed" -ForegroundColor Green

# Step 3: Configure MCP server
Write-Host "[3/6] Configuring MCP server..." -ForegroundColor Yellow

$serverPath = Join-Path $InstallDir "src\server.js"
$mcpEntry = @{
    command = "node"
    args = @($serverPath)
}

if (Test-Path $McpConfig) {
    $backup = "$McpConfig.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $McpConfig -Destination $backup
    Write-Host "✓ Backed up existing .mcp.json" -ForegroundColor Green

    $existingConfig = Get-Content $McpConfig -Raw | ConvertFrom-Json
    if (-not $existingConfig.mcpServers) {
        $existingConfig | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value @{}
    }
    $existingConfig.mcpServers | Add-Member -MemberType NoteProperty -Name "tradingview" -Value $mcpEntry -Force
    $existingConfig | ConvertTo-Json -Depth 10 | Set-Content $McpConfig
    Write-Host "✓ Merged TradingView MCP into existing config" -ForegroundColor Green
} else {
    $newConfig = @{
        mcpServers = @{
            tradingview = $mcpEntry
        }
    }
    $newConfig | ConvertTo-Json -Depth 10 | Set-Content $McpConfig
    Write-Host "✓ Created new .mcp.json" -ForegroundColor Green
}

# Step 4: Install hooks
Write-Host "[4/6] Installing Claude Code hooks..." -ForegroundColor Yellow
New-Item -Path $HooksDir -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $InstallDir "hooks\windows\*") -Destination $HooksDir -Force
Write-Host "✓ Hooks installed to $HooksDir" -ForegroundColor Green

# Step 5: Configure settings.json hooks
Write-Host "[5/6] Configuring Claude Code settings..." -ForegroundColor Yellow

$launchScript = Join-Path $HooksDir "launch_tv.ps1"
$healthScript = Join-Path $HooksDir "health_check.ps1"

$hookConfig = @{
    hooks = @{
        UserPromptSubmit = @(
            @{
                matcher = "(?i)tradingview"
                hooks = @(
                    @{
                        type = "command"
                        command = "powershell -File `"$launchScript`""
                        timeout = 45000
                    }
                )
            },
            @{
                matcher = "(?i)health check"
                hooks = @(
                    @{
                        type = "command"
                        command = "powershell -File `"$healthScript`""
                        timeout = 10000
                    }
                )
            }
        )
    }
    enabledMcpjsonServers = @("tradingview")
}

if (Test-Path $SettingsConfig) {
    $backup = "$SettingsConfig.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $SettingsConfig -Destination $backup
    Write-Host "✓ Backed up existing settings.json" -ForegroundColor Green

    $existingSettings = Get-Content $SettingsConfig -Raw | ConvertFrom-Json

    if (-not $existingSettings.hooks) {
        $existingSettings | Add-Member -MemberType NoteProperty -Name "hooks" -Value @{UserPromptSubmit = @()}
    }
    if (-not $existingSettings.hooks.UserPromptSubmit) {
        $existingSettings.hooks | Add-Member -MemberType NoteProperty -Name "UserPromptSubmit" -Value @()
    }

    # Append new hooks
    $existingSettings.hooks.UserPromptSubmit += $hookConfig.hooks.UserPromptSubmit

    if (-not $existingSettings.enabledMcpjsonServers) {
        $existingSettings | Add-Member -MemberType NoteProperty -Name "enabledMcpjsonServers" -Value @()
    }
    if ($existingSettings.enabledMcpjsonServers -notcontains "tradingview") {
        $existingSettings.enabledMcpjsonServers += "tradingview"
    }

    $existingSettings | ConvertTo-Json -Depth 10 | Set-Content $SettingsConfig
    Write-Host "✓ Updated settings.json with hooks" -ForegroundColor Green
} else {
    $hookConfig | ConvertTo-Json -Depth 10 | Set-Content $SettingsConfig
    Write-Host "✓ Created new settings.json with hooks" -ForegroundColor Green
}

# Step 6: Set up trading rules
Write-Host "[6/6] Setting up trading rules..." -ForegroundColor Yellow
$rulesFile = Join-Path $InstallDir "rules.json"
$rulesExample = Join-Path $InstallDir "rules.example.json"

if (-not (Test-Path $rulesFile) -and (Test-Path $rulesExample)) {
    Copy-Item -Path $rulesExample -Destination $rulesFile
    Write-Host "✓ Created rules.json from example" -ForegroundColor Green
    Write-Host "⚠ Edit $rulesFile to customize your trading rules" -ForegroundColor Yellow
} else {
    Write-Host "✓ rules.json already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          Installation Complete! 🎉                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. " -NoNewline; Write-Host "Restart Claude Code" -ForegroundColor Green -NoNewline; Write-Host " to load the MCP server"
Write-Host ""
Write-Host "2. " -NoNewline; Write-Host "Test the installation:" -ForegroundColor Green
Write-Host "   Type: " -NoNewline; Write-Host "health check" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. " -NoNewline; Write-Host "Launch TradingView:" -ForegroundColor Green
Write-Host "   Type: " -NoNewline; Write-Host "tradingview" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. " -NoNewline; Write-Host "Run your first analysis:" -ForegroundColor Green
Write-Host "   Type: " -NoNewline; Write-Host "Give me a morning brief on SPY" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation: https://github.com/karthikg-git/tradingview-claude-mcp" -ForegroundColor Blue
Write-Host ""
