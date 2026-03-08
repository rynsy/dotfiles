#Requires -Version 5.1
<#
.SYNOPSIS
    Windows provisioning script for dotfiles.
.DESCRIPTION
    Standalone Windows setup: installs packages via winget and creates config
    symlinks. Requires Developer Mode or Administrator for symlinks.
    This is independent from install.sh (Mac/Linux) by design.
.EXAMPLE
    .\install.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Dotfiles Bootstrap (Windows) ===" -ForegroundColor Cyan
Write-Host "Dotfiles directory: $DotfilesDir"
Write-Host ""

# --- Step 1: Check symlink capability ---

function Test-SymlinkCapability {
    $testLink = Join-Path $env:TEMP "symlink-test-$(Get-Random)"
    $testTarget = Join-Path $env:TEMP "symlink-target-$(Get-Random)"
    try {
        New-Item -ItemType File -Path $testTarget -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path $testLink -Target $testTarget -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    } finally {
        Remove-Item -Path $testLink, $testTarget -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "--- Checking symlink capability ---"
if (-not (Test-SymlinkCapability)) {
    Write-Host ""
    Write-Host "ERROR: Cannot create symbolic links." -ForegroundColor Red
    Write-Host "Enable Developer Mode (Settings > Update & Security > For developers)" -ForegroundColor Yellow
    Write-Host "or run this script as Administrator." -ForegroundColor Yellow
    exit 1
}
Write-Host "Symlink capability: OK"
Write-Host ""

# --- Step 2: Install packages via winget ---

Write-Host "--- Installing packages ---"

$packages = @(
    "Git.Git",
    "Neovim.Neovim",
    "junegunn.fzf",
    "ajeetdsouza.zoxide",
    "Alacritty.Alacritty"
)
# Note: tmux has no native Windows package -- skipped.
# Note: stow has no Windows equivalent -- symlinks created manually below.

foreach ($pkg in $packages) {
    Write-Host "Installing $pkg..."
    winget install -e --id $pkg --accept-source-agreements --accept-package-agreements
}

Write-Host ""

# --- Step 3: Create config symlinks ---

Write-Host "--- Creating config symlinks ---"

function New-Symlink {
    param(
        [string]$Link,
        [string]$Target,
        [switch]$Directory
    )
    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $Link -Force
        } else {
            Write-Warning "Backing up existing file: $Link -> $Link.backup"
            Move-Item $Link "$Link.backup"
        }
    }
    if ($Directory) {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
    }
    Write-Host "  $Link -> $Target"
}

# nvim config (directory symlink)
New-Symlink -Link "$HOME\.config\nvim" `
            -Target "$DotfilesDir\nvim\.config\nvim" `
            -Directory

# git config
New-Symlink -Link "$HOME\.gitconfig" `
            -Target "$DotfilesDir\git\.gitconfig"

# PowerShell profile
New-Symlink -Link "$HOME\Documents\PowerShell\profile.ps1" `
            -Target "$DotfilesDir\powershell\.config\powershell\profile.ps1"

# Alacritty config
New-Symlink -Link "$env:APPDATA\alacritty\alacritty.toml" `
            -Target "$DotfilesDir\alacritty\.config\alacritty\alacritty.toml"

Write-Host ""

# --- Step 4: Post-install notes ---

Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Post-install steps:"
Write-Host "  1. Open a new terminal for PATH changes to take effect"
Write-Host "  2. Launch nvim to install plugins (first run may take a moment)"
Write-Host ""
