# Phase 3: Cross-Platform Provisioning - Research

**Researched:** 2026-03-08
**Domain:** Cross-platform dotfiles provisioning (GNU Stow, shell config extraction, install scripts, PowerShell, Alacritty)
**Confidence:** HIGH

## Summary

This phase extracts shared shell configuration into a neutral `shell/` stow package, extends `install.sh` to support macOS via Homebrew alongside the existing Arch Linux pacman flow, creates a standalone `install.ps1` for Windows, adds a cross-platform PowerShell profile, and introduces an Alacritty config package. The existing codebase has clean patterns to follow -- Ghostty's platform-include pattern (`config` + `linux.conf` + `macos.conf` with silent missing-file handling) is the reference architecture for all app configs.

The core technical challenge is the shell config extraction: moving files from `zsh/.config/zsh/config.d/` to `shell/.config/shell/config.d/` while updating all source paths in `.zshrc`, `.bashrc`, and `install.sh` conflict checks. The install script extension is straightforward -- `uname` detection, package name mapping, and a `--minimal` flag gating CORE vs EXTRA packages. Windows support is intentionally simple and best-effort.

**Primary recommendation:** Execute as a sequence of waves -- first extract the shell config (foundation), then extend install.sh, then add PowerShell and Alacritty packages, and finally update the README. Each wave should be independently verifiable.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Extract shared config from `zsh/.config/zsh/config.d/` into `shell/.config/shell/config.d/`
- Shared files: `alias`, `env`, `path`, `secrets.encrypted` (and decrypted `secrets`)
- Platform overrides follow pattern: `env.linux`/`env.darwin`, `path.linux`/`path.darwin`, `alias.linux`/`alias.darwin`
- Linux-only entries move to platform files: XDG_SESSION_TYPE, LUA_PATH (env.linux); nmcli, navicat, zig-wasm (alias.linux); Factorio, emscripten paths (path.linux)
- Zsh keeps its own `config.d/` directory for zsh-only things (zinit, p10k, completion settings)
- Bash and zsh both source from `~/.config/shell/config.d/` for shared config
- Secrets move to `shell/.config/shell/config.d/` -- single source of truth for all shells
- CORE packages (installed with `--minimal`): stow, zsh, fzf, zoxide, tmux, neovim, git
- EXTRA packages: ghostty, bash, plus any GUI tools
- Stow all stow packages on all platforms -- configs self-filter via platform includes (ghostty pattern)
- No platform-filtered stow list; simpler install logic
- Single `install.sh` for Mac + Linux with `uname` check at script top
- Auto-install Homebrew on Mac if missing (official install script)
- `--minimal` flag installs only CORE packages
- Fail early if unsupported OS
- `install.ps1` is standalone for Windows -- no shared code with install.sh
- PowerShell alias parity: git shortcuts (gcm, gcl), directory jumps (lab, proj, s, p), n=nvim, t=tmux attach, dc=docker-compose
- Cross-platform pwsh -- profile works on Windows, Mac, and Linux
- Standalone aliases defined in PowerShell syntax -- does not parse bash/zsh config files
- May drift from zsh aliases -- acceptable for best-effort
- Windows symlinks via `New-Item -ItemType SymbolicLink` (requires admin or Developer Mode; script checks and warns)
- Alacritty: low-priority fallback terminal, mirrors Ghostty's platform-include pattern
- Alacritty added to stow PACKAGES list, stowed on all platforms

### Claude's Discretion
- Exact brew package name mappings (may differ from pacman names)
- How zsh/bash source the shared config (dot-source order, guard syntax)
- PowerShell profile structure and function naming
- Alacritty base config content and platform-specific overrides
- README structure and content depth

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SHELL-01 | Extract shared config from `zsh/.config/zsh/config.d/` into `shell/.config/shell/config.d/` stow package; update zsh, bash to source from new location | Shell config extraction patterns, sourcing guard syntax, stow package structure |
| SHELL-02 | Platform-specific path files (`path.linux`, `path.darwin`) sourced conditionally via `uname`; remove hardcoded Linux-only paths from base `path` file | uname detection pattern, platform file sourcing convention |
| PROV-01 | `install.sh` supports Arch Linux full mode (existing) and minimal mode (zsh, tmux, nvim only -- no GUI tools) | CORE/EXTRA package split, --minimal flag pattern |
| PROV-02 | `install.sh` supports macOS via Homebrew (full and minimal modes) | Homebrew auto-install, brew package name mappings, stow on macOS |
| PROV-03 | `install.ps1` standalone Windows setup script -- creates symlinks manually (no Stow), installs packages via winget | winget package IDs, New-Item -SymbolicLink, Developer Mode detection |
| PROV-04 | install.sh PACKAGES split into CORE and EXTRA; `--minimal` installs only CORE | Package categorization, bash array patterns |
| PSH-01 | `powershell/` stow package with cross-platform `profile.ps1` | PowerShell profile paths per platform, stow target directories |
| PSH-02 | PowerShell profile has equivalent aliases to zsh config | PowerShell alias/function syntax, Set-Alias vs function patterns |
| PSH-03 | PowerShell profile works on Windows, Mac, and Linux (pwsh) | $IsWindows/$IsLinux/$IsMacOS variables, cross-platform pwsh profile |
| APP-01 | `alacritty/` stow package with platform-specific config includes (mirrors ghostty pattern) | Alacritty TOML import syntax, missing file handling, config paths |
| APP-02 | Alacritty config is cross-platform (Linux/Mac/Windows paths handled) | Alacritty config locations per platform, import path resolution |
| XPLAT-01 | Each app config follows the platform-include pattern (base config + optional platform overrides) | Ghostty reference pattern, Alacritty import syntax |
| XPLAT-02 | README documents what each provisioning script installs and how to use it | Documentation structure |
</phase_requirements>

## Standard Stack

### Core
| Tool | Purpose | pacman Name | brew Name | winget ID | Notes |
|------|---------|-------------|-----------|-----------|-------|
| GNU Stow | Symlink farm manager | `stow` | `stow` | N/A (not on Windows) | `--no-folding` required per CLAUDE.md |
| zsh | Primary shell | `zsh` | `zsh` | N/A | macOS ships with zsh |
| fzf | Fuzzy finder | `fzf` | `fzf` | `junegunn.fzf` | Same name across platforms |
| zoxide | Smart cd | `zoxide` | `zoxide` | `ajeetdsouza.zoxide` | Same name across platforms |
| tmux | Terminal multiplexer | `tmux` | `tmux` | N/A (no native Windows) | Not available natively on Windows |
| neovim | Editor | `neovim` | `neovim` | `Neovim.Neovim` | Same formula name on brew |
| git | Version control | `git` | `git` | `Git.Git` | macOS has CLI tools git; brew git is optional |
| Ghostty | Primary terminal | `ghostty` | `ghostty` (cask) | N/A | `brew install --cask ghostty` |
| Alacritty | Fallback terminal | `alacritty` | `alacritty` (cask) | `Alacritty.Alacritty` | `brew install --cask alacritty` |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| Homebrew | macOS package manager | Auto-installed on macOS if missing |
| winget | Windows package manager | Used by install.ps1 for Windows provisioning |
| ansible-vault | Secrets encryption | Decrypt secrets.encrypted after stow |
| PowerShell 7 (pwsh) | Cross-platform shell | Profile works on all platforms |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| winget | Scoop/Chocolatey | winget is Microsoft's official tool, pre-installed on modern Windows |
| Stow on Windows | Manual symlinks | Stow doesn't run natively on Windows; New-Item -SymbolicLink is the correct approach |
| tmux on Windows | psmux | psmux is a Rust-based tmux clone for Windows but immature; skip for best-effort scope |

## Architecture Patterns

### Recommended Project Structure
```
dotfiles/
├── shell/                              # NEW: shared shell config
│   └── .config/
│       └── shell/
│           └── config.d/
│               ├── alias              # universal aliases
│               ├── alias.linux        # nmcli, navicat, zig-wasm
│               ├── alias.darwin       # (empty or macOS-specific)
│               ├── env                # universal env vars (EDITOR, VISUAL, DOTNET_*)
│               ├── env.linux          # XDG_SESSION_TYPE, LUA_PATH, LUA_CPATH
│               ├── env.darwin         # (empty or macOS-specific)
│               ├── path               # universal paths (~/.local/bin, cargo, go, dotnet, etc.)
│               ├── path.linux         # Factorio, emscripten
│               ├── path.darwin        # Homebrew paths (/opt/homebrew/bin)
│               ├── secrets.encrypted  # ansible-vault encrypted
│               └── .gitignore         # ignores decrypted `secrets`
├── zsh/                               # MODIFIED: zsh-only config remains
│   ├── .zshenv                        # ZDOTDIR export (unchanged)
│   └── .config/zsh/
│       ├── .zshrc                     # sources ~/.config/shell/config.d/* (updated path)
│       ├── .zprofile
│       ├── .p10k.zsh
│       └── config.d/                  # zsh-only config (zinit, completion, etc.) - may be empty initially
├── bash/                              # MODIFIED: sources from shell/ now
│   ├── .bashrc                        # sources ~/.config/shell/config.d/* (updated path)
│   └── .bash_profile
├── powershell/                        # NEW: cross-platform PowerShell profile
│   └── .config/
│       └── powershell/
│           └── profile.ps1            # aliases equivalent to shell/config.d/alias
├── alacritty/                         # NEW: fallback terminal config
│   └── .config/
│       └── alacritty/
│           ├── alacritty.toml         # base config + imports linux.toml/macos.toml
│           ├── linux.toml             # Linux-specific settings
│           └── macos.toml             # macOS-specific settings
├── install.sh                         # MODIFIED: platform detection, --minimal, brew support
├── install.ps1                        # NEW: standalone Windows provisioning
└── README.md                          # MODIFIED: cross-platform docs
```

### Pattern 1: Platform-Conditional Sourcing (shell config.d)
**What:** Source shared config files, then platform-specific overrides based on `uname`
**When to use:** In `.zshrc` and `.bashrc` to load shared shell config
**Example:**
```bash
# Source shared config (single source of truth for all POSIX shells)
_shell_config="$HOME/.config/shell/config.d"
for f in env path alias; do
  [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"
done

# Source platform-specific overrides
case "$(uname -s)" in
  Linux)
    for f in env.linux path.linux alias.linux; do
      [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"
    done
    ;;
  Darwin)
    for f in env.darwin path.darwin alias.darwin; do
      [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"
    done
    ;;
esac

# Source secrets (decrypted file, gitignored)
[[ -f "$_shell_config/secrets" ]] && . "$_shell_config/secrets"
unset _shell_config
```

### Pattern 2: Ghostty-Style Platform Includes (Alacritty)
**What:** Base config imports platform-specific files; missing imports silently skipped
**When to use:** For app configs that need platform-specific overrides
**Example:**
```toml
# alacritty.toml - base config
import = [
  "~/.config/alacritty/linux.toml",
  "~/.config/alacritty/macos.toml",
]

# Font
[font]
normal = { family = "CaskaydiaMono Nerd Font", style = "Regular" }
size = 9.0

# Window
[window]
padding = { x = 14, y = 14 }

# Cursor
[cursor]
style = { shape = "Block", blinking = "Off" }
```
**Source:** [Alacritty official docs](https://alacritty.org/config-alacritty.html) -- imports skip missing files silently.

### Pattern 3: Install Script Platform Detection
**What:** Detect OS at script top, set package manager and package names accordingly
**When to use:** In `install.sh` for cross-platform provisioning
**Example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
case "$OS" in
  Linux)  PKG_MGR="pacman" ;;
  Darwin) PKG_MGR="brew" ;;
  *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac
```

### Pattern 4: PowerShell Cross-Platform Profile
**What:** Use built-in `$IsWindows`, `$IsLinux`, `$IsMacOS` automatic variables
**When to use:** In `profile.ps1` for platform-specific behavior
**Example:**
```powershell
# Cross-platform aliases
Set-Alias -Name n -Value nvim
Set-Alias -Name dc -Value docker-compose

# Functions for aliases that need arguments
function gcm { git commit -m @args }
function gcl { git clone @args }
function t { tmux new -As workspace }

# Directory shortcuts (adjust paths per platform)
if ($IsWindows) {
    function lab { Set-Location "$env:USERPROFILE\code\lab" }
    function proj { Set-Location "$env:USERPROFILE\code\projects" }
} else {
    function lab { Set-Location "$HOME/code/lab" }
    function proj { Set-Location "$HOME/code/projects" }
}
Set-Alias -Name s -Value study
Set-Alias -Name p -Value proj
```
**Source:** [Microsoft PowerShell Profile Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5)

### Pattern 5: Windows Symlink Creation with Developer Mode Check
**What:** Check for symlink capability before attempting; warn if not available
**When to use:** In `install.ps1` for creating dotfile symlinks on Windows
**Example:**
```powershell
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

function New-Symlink {
    param([string]$Link, [string]$Target)
    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    if (Test-Path $Link) {
        if ((Get-Item $Link).LinkType -eq "SymbolicLink") {
            Remove-Item $Link -Force
        } else {
            Write-Warning "Backing up existing file: $Link"
            Move-Item $Link "$Link.backup"
        }
    }
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
}
```

### Anti-Patterns to Avoid
- **Parsing bash config from PowerShell:** The CONTEXT.md explicitly says PowerShell aliases are standalone, not parsed from bash/zsh files. Do not try to share a single alias file across shell families.
- **Platform-filtering the stow list:** User decided all packages stow on all platforms. Configs self-filter via platform includes. Do not add `if [[ "$OS" == "Darwin" ]]; then skip aerospace` logic.
- **Shared code between install.sh and install.ps1:** These are intentionally independent. No shared YAML config, no Makefile, no task runner.
- **Over-engineering Windows support:** Windows is best-effort. Do not add error recovery, retry logic, or WSL detection to install.ps1.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Homebrew installation | Custom brew download/compile | Official install script: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | Handles Xcode CLT, permissions, PATH setup |
| Package name mapping | Complex lookup table | Simple associative array in install.sh | Only ~10 packages; direct mapping is clearer |
| Symlink farm management | Custom symlink scripts for Mac/Linux | GNU Stow (`stow --no-folding`) | Already proven in this repo; same behavior on macOS |
| Windows package management | Custom download/install scripts | winget (`winget install -e --id Package.Name`) | Pre-installed on modern Windows, handles updates |
| Secrets encryption | Custom encryption | ansible-vault (already in use) | Already established pattern in this repo |

**Key insight:** The existing codebase already solves most hard problems. The main work is reorganizing files and extending patterns that already work.

## Common Pitfalls

### Pitfall 1: Breaking Existing Symlinks During Shell Config Migration
**What goes wrong:** Moving files from `zsh/.config/zsh/config.d/` to `shell/.config/shell/config.d/` while the old symlinks still point to the old location. Existing shell sessions break.
**Why it happens:** Stow creates symlinks from the target to the source. If you move source files, existing symlinks become dangling.
**How to avoid:** Sequence matters: (1) Create new `shell/` package with extracted files, (2) Update `.zshrc` and `.bashrc` source paths, (3) `stow -D zsh` to remove old symlinks, (4) `stow --no-folding shell zsh bash` to create new symlinks. The old config.d files in `zsh/` should be removed after extraction.
**Warning signs:** `ls -la ~/.config/zsh/config.d/` shows broken symlinks after migration.

### Pitfall 2: Homebrew PATH Not Available After Install
**What goes wrong:** On Apple Silicon Macs, Homebrew installs to `/opt/homebrew/bin` which is not in PATH by default. Subsequent `brew install` commands fail.
**Why it happens:** The Homebrew installer adds PATH setup to `.zprofile` but that only takes effect in new shells.
**How to avoid:** After installing Homebrew, explicitly eval the shellenv in the install script:
```bash
if [[ "$OS" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi
```
**Warning signs:** `brew: command not found` immediately after installing Homebrew on Apple Silicon.

### Pitfall 3: Ghostty Cask vs Formula
**What goes wrong:** Using `brew install ghostty` instead of `brew install --cask ghostty` fails.
**Why it happens:** GUI applications on macOS are casks, not formulae.
**How to avoid:** Use `brew install --cask ghostty` and `brew install --cask alacritty` for GUI apps. Keep a separate CASKS array.
**Warning signs:** `Error: No available formula with the name "ghostty"`.

### Pitfall 4: PowerShell Profile Path Differs by Platform
**What goes wrong:** Stowing PowerShell profile to `~/.config/powershell/profile.ps1` works on Linux/macOS but not on Windows.
**Why it happens:** Windows PowerShell 7 expects profiles at `$HOME\Documents\PowerShell\profile.ps1`.
**How to avoid:** The `powershell/` stow package targets `~/.config/powershell/` (Linux/macOS convention). On Windows, `install.ps1` creates symlinks to the Windows-expected location separately. This is fine because Windows doesn't use stow anyway.
**Warning signs:** PowerShell profile not loading on Windows after install.ps1 runs.

### Pitfall 5: Secrets File Path in .gitignore
**What goes wrong:** After moving `secrets.encrypted` to `shell/.config/shell/config.d/`, the existing `.gitignore` pattern `**/config.d/secrets` still works, but the decryption instructions in install.sh post-install notes point to the old path.
**Why it happens:** Path references exist in multiple places (install.sh, README, CLAUDE.md).
**How to avoid:** Search for all references to `zsh/.config/zsh/config.d/secrets` and update them. The `.gitignore` glob pattern `**/config.d/secrets` will correctly match the new location.
**Warning signs:** Post-install instructions tell user to `cd zsh/.config/zsh/config.d` which no longer has secrets.

### Pitfall 6: Stow Conflict When Both zsh/ and shell/ Provide Same Target
**What goes wrong:** If `zsh/.config/zsh/config.d/alias` still exists while `shell/.config/shell/config.d/alias` is being stowed, there's no conflict (different target paths). But if you accidentally leave old files in zsh's config.d and source paths aren't updated, you get stale config.
**Why it happens:** The migration is a move, not a copy. Must remove source files from old location.
**How to avoid:** After extracting to `shell/`, delete the moved files from `zsh/.config/zsh/config.d/`. Keep only zsh-specific files there (if any).
**Warning signs:** `diff` between old and new config.d files shows they're identical -- means old ones weren't removed.

### Pitfall 7: install.sh Conflict Check List Out of Date
**What goes wrong:** The existing install.sh has a hardcoded list of files to check for conflicts (lines 36-65). After adding `shell/`, `powershell/`, and `alacritty/` packages, these new files need conflict checks too.
**Why it happens:** The conflict detection is explicit, not automatic.
**How to avoid:** Add conflict checks for new paths: `~/.config/shell/config.d/*`, `~/.config/powershell/profile.ps1`, `~/.config/alacritty/alacritty.toml`. Consider refactoring to auto-detect from stow packages, but the explicit approach is fine given the project's simplicity preference.
**Warning signs:** Real files at new config locations silently overwritten by stow.

## Code Examples

### Shell Config Extraction -- What Moves Where

**Current `env` -> split into `env` (universal) + `env.linux` (Linux-only):**

Universal `shell/.config/shell/config.d/env`:
```bash
# Color fixes
export LS_COLORS='ow=01;36;40'

export DOTNET_CLI_TELEMETRY_OPTOUT=true
export VCPKGROOT="/lib/vcpkg"
export VCPKG_DISABLE_METRICS='True'

export CONFIG_ZMK_BLE_EXPERIMENTAL_FEATURES=y
export CONFIG_ZMK_BLE_EXPERIMENTAL_SEC=y

export EDITOR=nvim
export VISUAL=nvim
```

Linux-only `shell/.config/shell/config.d/env.linux`:
```bash
export LUA_PATH="/home/ryan/.luarocks/share/lua/5.4/?.lua;/home/ryan/.luarocks/share/lua/5.4/?/init.lua;./?.lua;/usr/local/share/lua/5.4/?.lua;/usr/local/share/lua/5.4/?/init.lua"
export LUA_CPATH="/home/ryan/.luarocks/lib/lua/5.4/?.so;./?.so;/usr/local/lib/lua/5.4/?.so"
export XDG_SESSION_TYPE=wayland
```

**Current `path` -> split into `path` (universal) + `path.linux` (Linux-only):**

Universal `shell/.config/shell/config.d/path`:
```bash
export PATH="$HOME/.local/bin:$PATH"

# Ruby Gems
export GEM_HOME="$HOME/.local/share/gem/ruby/3.2.0"
export PATH="$PATH:$GEM_HOME/bin"

# Composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Dotnet
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"

# Pulumi
export PATH="$PATH:$HOME/.pulumi/bin"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"
```

Linux-only `shell/.config/shell/config.d/path.linux`:
```bash
# Emscripten
export PATH="$PATH:/lib64/emscripten"

# Factorio
export PATH="/usr/local/games/factorio/bin/x64:$PATH"
```

macOS `shell/.config/shell/config.d/path.darwin`:
```bash
# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || true
```

**Current `alias` -> split into `alias` (universal) + `alias.linux` (Linux-only):**

Universal `shell/.config/shell/config.d/alias`:
```bash
alias termbin="nc termbin.com 9999"
alias ls='ls --color'
alias gcm="git commit -m"
alias gcl="git clone"
alias python="python3"
alias pip="pip3"
alias yarn="yarnpkg"
alias n=nvim
alias sail=./vendor/bin/sail

killemall(){
  kill -9 $(ps aux | rg -i $1 | tr -s ' ' | cut -d ' ' -f 2)
}
alias t='tmux new -As workspace'
alias ta='tmux attach -t workspace'

# Shortcuts
alias lab="cd ~/code/lab/"
alias cdar="cd ~/code/cdar/"
alias kdai="cd ~/code/cdar/kdai_data/"
alias proj="cd ~/code/projects/"
alias dui="cd ~/code/cdar/DUI_project/"
alias study="cd ~/code/study/"
alias s="study"
alias p="proj"

alias dc="docker-compose"
```

Linux-only `shell/.config/shell/config.d/alias.linux`:
```bash
alias wifi="nmcli dev wifi connect"
alias navicat='QT_QPA_PLATFORM="wayland;xcb" /opt/navicat16-premium-en/AppRun'
alias zig-wasm="zig build -Dtarget=wasm32-emscripten --sysroot '\$EMSDK/upstream/emscripten'"
```

### Updated .zshrc Sourcing Block
```bash
# Source shared shell config (shared with bash)
_shell_config="$HOME/.config/shell/config.d"
for f in env path alias; do
  [[ -f "$_shell_config/$f" ]] && source "$_shell_config/$f"
done
case "$(uname -s)" in
  Linux)  for f in env.linux path.linux alias.linux; do [[ -f "$_shell_config/$f" ]] && source "$_shell_config/$f"; done ;;
  Darwin) for f in env.darwin path.darwin alias.darwin; do [[ -f "$_shell_config/$f" ]] && source "$_shell_config/$f"; done ;;
esac
[[ -f "$_shell_config/secrets" ]] && source "$_shell_config/secrets"
unset _shell_config
```

### Updated .bashrc Sourcing Block
```bash
# Source shared config (single source of truth; also used by zsh)
_shell_config="$HOME/.config/shell/config.d"
[[ -f "$_shell_config/env"   ]] && . "$_shell_config/env"
[[ -f "$_shell_config/path"  ]] && . "$_shell_config/path"
[[ -f "$_shell_config/alias" ]] && . "$_shell_config/alias"
case "$(uname -s)" in
  Linux)  for f in env.linux path.linux alias.linux; do [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"; done ;;
  Darwin) for f in env.darwin path.darwin alias.darwin; do [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"; done ;;
esac
[[ -f "$_shell_config/secrets" ]] && . "$_shell_config/secrets"
unset _shell_config
```

### Install Script Package Arrays
```bash
# Package definitions
CORE_PACMAN=(stow zsh fzf zoxide tmux neovim git)
EXTRA_PACMAN=(ghostty bash)

CORE_BREW=(stow zsh fzf zoxide tmux neovim git)
EXTRA_BREW=()                           # ghostty is a cask
CORE_CASKS=()
EXTRA_CASKS=(ghostty alacritty)

# Stow packages (always all -- configs self-filter)
PACKAGES=(nvim zsh claude git ssh tmux ghostty bash shell powershell alacritty)
```

### PowerShell Profile Target Paths
```
Linux/macOS (stow target):  ~/.config/powershell/profile.ps1
Windows (install.ps1 symlink): $HOME\Documents\PowerShell\profile.ps1
```

The `powershell/` stow package structure:
```
powershell/
└── .config/
    └── powershell/
        └── profile.ps1
```

This stows to `~/.config/powershell/profile.ps1` on Linux/macOS, which is the correct `CurrentUserAllHosts` profile path for pwsh 7 on those platforms. On Windows, `install.ps1` creates a symlink from `$HOME\Documents\PowerShell\profile.ps1` to the dotfiles copy.

### Alacritty Config with Silent Platform Imports
```toml
# alacritty.toml - base config
# Platform-specific overrides (silently skipped if missing)
import = [
  "~/.config/alacritty/linux.toml",
  "~/.config/alacritty/macos.toml",
]

[font]
normal = { family = "CaskaydiaMono Nerd Font", style = "Regular" }
size = 9.0

[window]
padding = { x = 14, y = 14 }

[cursor]
style = { shape = "Block", blinking = "Off" }
```

Source: [Alacritty official config reference](https://alacritty.org/config-alacritty.html) -- "Imports are loaded in order, skipping all missing files."

### Winget Package IDs for install.ps1
```powershell
$packages = @(
    "Git.Git",
    "Neovim.Neovim",
    "junegunn.fzf",
    "ajeetdsouza.zoxide",
    "Alacritty.Alacritty"
)
# Note: tmux has no native Windows package. Skip it.
# Note: stow has no Windows equivalent. Symlinks created manually.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Alacritty YAML config | Alacritty TOML config | v0.13.0 (2024) | Must use `.toml` extension, `import = [...]` syntax |
| Windows PowerShell 5.1 | PowerShell 7 (pwsh) cross-platform | 2020+ | `$IsWindows`/`$IsLinux`/`$IsMacOS` only available in pwsh 7+ |
| Homebrew in `/usr/local` | Homebrew in `/opt/homebrew` (Apple Silicon) | 2021+ | PATH must include `/opt/homebrew/bin`; use `brew shellenv` |
| Ghostty config `?` prefix for optional | Alacritty silently skips missing imports | Current | Different syntax but same behavior -- missing platform files OK |

## Open Questions

1. **macOS `ls --color` compatibility**
   - What we know: GNU `ls` uses `--color`, macOS BSD `ls` uses `-G` for color. The shared `alias` file has `alias ls='ls --color'`.
   - What's unclear: Should we gate this alias by platform, or assume brew-installed GNU coreutils?
   - Recommendation: Move `alias ls='ls --color'` to `alias.linux` and add `alias ls='ls -G'` to `alias.darwin`. This avoids requiring GNU coreutils on macOS.

2. **Homebrew Ghostty availability**
   - What we know: Ghostty is available as `brew install --cask ghostty` based on community dotfiles repos.
   - What's unclear: Whether the cask name is exactly `ghostty` in the official Homebrew tap.
   - Recommendation: Include it in EXTRA_CASKS; if it fails, the install script continues (use `|| true` or warn-and-continue pattern).

3. **PowerShell `gcm` alias collision**
   - What we know: PowerShell has a built-in `gcm` alias for `Get-Command`. The user wants `gcm` = `git commit -m`.
   - What's unclear: Whether overriding the built-in will cause issues.
   - Recommendation: Use `Remove-Alias gcm -Force -ErrorAction SilentlyContinue` before defining the function, or use a different name. Document the override.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | bash + manual verification |
| Config file | none -- shell scripts tested via execution |
| Quick run command | `bash -n install.sh` (syntax check) |
| Full suite command | Manual: run install.sh --minimal on fresh env |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SHELL-01 | Shared config in shell/ package, zsh+bash source it | smoke | `bash -c 'source ~/.config/shell/config.d/alias && type n'` | Wave 0 |
| SHELL-02 | Platform paths sourced conditionally | smoke | `bash -c '. ~/.config/shell/config.d/path && echo $PATH'` | Wave 0 |
| PROV-01 | install.sh --minimal on Arch | manual-only | Run on fresh Arch VM/container | N/A |
| PROV-02 | install.sh on macOS | manual-only | Run on fresh macOS | N/A |
| PROV-03 | install.ps1 on Windows | manual-only | Run on fresh Windows | N/A |
| PROV-04 | CORE/EXTRA split | unit | `bash -n install.sh && grep -q 'CORE_' install.sh` | Wave 0 |
| PSH-01 | powershell/ stow package exists | smoke | `test -f powershell/.config/powershell/profile.ps1` | Wave 0 |
| PSH-02 | PowerShell alias parity | smoke | `pwsh -c '. ~/.config/powershell/profile.ps1; Get-Alias n'` | Wave 0 |
| PSH-03 | Profile cross-platform | manual-only | Run on Windows + Mac + Linux | N/A |
| APP-01 | alacritty/ stow package with imports | smoke | `test -f alacritty/.config/alacritty/alacritty.toml && grep -q 'import' alacritty/.config/alacritty/alacritty.toml` | Wave 0 |
| APP-02 | Alacritty cross-platform | smoke | `grep -q 'linux.toml' alacritty/.config/alacritty/alacritty.toml` | Wave 0 |
| XPLAT-01 | Platform-include pattern | smoke | Verify import/include in each app config | Wave 0 |
| XPLAT-02 | README docs provisioning | smoke | `grep -q 'install.sh' README.md && grep -q 'install.ps1' README.md` | Wave 0 |

### Sampling Rate
- **Per task commit:** `bash -n install.sh` + file existence checks
- **Per wave merge:** Full syntax checks + stow dry-run (`stow -n --no-folding <pkg>`)
- **Phase gate:** Stow all packages on Linux successfully; verify sourcing in new shell

### Wave 0 Gaps
- [ ] No automated test infrastructure exists -- all validation is manual/smoke tests
- [ ] `stow -n --no-folding shell` -- dry-run to verify no conflicts (run after shell/ created)
- [ ] `bash -n install.sh` -- syntax validation after modifications

## Sources

### Primary (HIGH confidence)
- [Alacritty official config reference](https://alacritty.org/config-alacritty.html) -- import syntax, missing file handling, config paths
- [Microsoft PowerShell about_Profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5) -- profile paths per platform, profile types
- [Microsoft winget docs](https://learn.microsoft.com/en-us/windows/package-manager/winget/) -- winget install syntax
- Existing codebase (`ghostty/.config/ghostty/config`) -- platform-include pattern reference

### Secondary (MEDIUM confidence)
- [winstall.app](https://winstall.app/apps/ajeetdsouza.zoxide) -- winget package IDs for zoxide
- [winget.run](https://winget.run/pkg/Neovim/Neovim) -- winget package ID for Neovim
- [Homebrew community dotfiles](https://github.com/joshukraine/dotfiles) -- brew package names, ghostty cask
- [GNU Stow on macOS guide](https://dev.to/hitblast/managing-configuration-using-gnu-stow-on-macos-5ff6) -- stow via brew works identically

### Tertiary (LOW confidence)
- Ghostty Homebrew cask name -- based on community repos, not verified against official tap
- Some winget package IDs -- should verify with `winget search` on actual Windows machine

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- package names verified via official sources and community repos
- Architecture: HIGH -- patterns derived from existing working codebase (ghostty) and official docs (Alacritty, PowerShell)
- Pitfalls: HIGH -- identified from real migration concerns in this specific codebase
- PowerShell profile: MEDIUM -- paths verified via Microsoft docs, but gcm alias collision needs testing
- Winget IDs: MEDIUM -- some verified via winstall.app/winget.run, others need on-machine verification
- Alacritty silent import: HIGH -- confirmed in official docs: "skipping all missing files"

**Research date:** 2026-03-08
**Valid until:** 2026-04-08 (stable domain -- shell config, stow, and config formats change slowly)
