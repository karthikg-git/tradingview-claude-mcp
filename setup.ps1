#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up TradingView Claude MCP integration on a new Windows PC.
.DESCRIPTION
    - Verifies TradingView Desktop and Claude Code are installed
    - Copies launch scripts to ~/Automation/Tradingview/
    - Configures the 'tradingview' keyword hook in ~/.claude/settings.json
#>

$ErrorActionPreference = "Stop"
$installDir   = "$env:USERPROFILE\Automation\Tradingview"
$settingsFile = "$env:USERPROFILE\.claude\settings.json"
$scriptRoot   = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  TradingView Claude MCP Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# ── 1. Check TradingView ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "[1/4] Checking TradingView Desktop..." -ForegroundColor Yellow
$tvDir = Get-ChildItem "C:\Program Files\WindowsApps" `
         -Filter "TradingView.Desktop_*_x64_*" `
         -Directory -ErrorAction SilentlyContinue |
         Sort-Object Name -Descending | Select-Object -First 1

if (-not $tvDir) {
    Write-Host "  ERROR: TradingView Desktop not found." -ForegroundColor Red
    Write-Host "  Install from: https://apps.microsoft.com/detail/9N57FSXPF50X" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: $($tvDir.FullName)" -ForegroundColor Green

# ── 2. Check Claude Code ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "[2/4] Checking Claude Code..." -ForegroundColor Yellow
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Host "  ERROR: 'claude' not found in PATH." -ForegroundColor Red
    Write-Host "  Install Claude Code from https://claude.ai/code then rerun setup." -ForegroundColor Red
    exit 1
}
Write-Host "  OK: $($claudeCmd.Source)" -ForegroundColor Green

# ── 3. Install scripts ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[3/4] Installing scripts to $installDir ..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Copy-Item (Join-Path $scriptRoot "launch_tv.ps1") $installDir -Force
Copy-Item (Join-Path $scriptRoot "launch_tv.bat") $installDir -Force
Write-Host "  OK: Scripts copied." -ForegroundColor Green

# ── 4. Configure Claude hook ──────────────────────────────────────────────────
Write-Host ""
Write-Host "[4/4] Configuring Claude Code hook..." -ForegroundColor Yellow

New-Item -ItemType Directory -Path (Split-Path $settingsFile) -Force | Out-Null

if (Test-Path $settingsFile) {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
} else {
    $settings = [PSCustomObject]@{}
}

# Hook command — runs in PowerShell, intercepts the keyword 'tradingview'
$hookCommand = '$d = [Console]::In.ReadToEnd() | ConvertFrom-Json; $p = if ($d.prompt) { $d.prompt.ToLower().Trim() } else { '''' }; if ($p -eq ''tradingview'') { & "$env:USERPROFILE/Automation/Tradingview/launch_tv.ps1" }'

$hookEntry = [PSCustomObject]@{
    hooks = @(
        [PSCustomObject]@{
            type          = "command"
            shell         = "powershell"
            command       = $hookCommand
            timeout       = 45
            statusMessage = "Launching TradingView..."
        }
    )
}

# Merge into existing settings
if (-not ($settings.PSObject.Properties.Name -contains "hooks")) {
    $settings | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{})
}
if (-not ($settings.hooks.PSObject.Properties.Name -contains "UserPromptSubmit")) {
    $settings.hooks | Add-Member -NotePropertyName UserPromptSubmit -NotePropertyValue @()
}

$alreadySet = $settings.hooks.UserPromptSubmit |
              Where-Object { $_.hooks | Where-Object { $_.command -like "*tradingview*" } }

if ($alreadySet) {
    Write-Host "  OK: Hook already configured, skipping." -ForegroundColor Yellow
} else {
    $settings.hooks.UserPromptSubmit = @($settings.hooks.UserPromptSubmit) + @($hookEntry)
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
    Write-Host "  OK: Hook added to $settingsFile" -ForegroundColor Green
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host @"

Next steps:
  1. Restart Claude Code  (or open /hooks to reload config)
  2. Open your project in Claude Code
  3. Type  tradingview  in chat
     Claude auto-launches TradingView and confirms CDP connection

Scripts  : $installDir
Settings : $settingsFile
"@ -ForegroundColor White
