# Phase 3: Cross-Platform Provisioning - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

The repo can provision a full or minimal dev environment on Arch Linux, macOS, and Windows from a single source of truth. This includes extracting shared shell config into a neutral `shell/` stow package, extending install.sh for macOS, creating a standalone install.ps1 for Windows, adding a PowerShell profile with equivalent aliases, and adding Alacritty as a low-priority fallback terminal config.

</domain>

<decisions>
## Implementation Decisions

### Config file splitting
- Extract shared config from `zsh/.config/zsh/config.d/` into `shell/.config/shell/config.d/`
- Shared files: `alias`, `env`, `path`, `secrets.encrypted` (and decrypted `secrets`)
- Platform overrides follow a consistent pattern: `env.linux`/`env.darwin`, `path.linux`/`path.darwin`, `alias.linux`/`alias.darwin`
- Linux-only entries move to platform files: XDG_SESSION_TYPE, LUA_PATH (env.linux); nmcli, navicat, zig-wasm (alias.linux); Factorio, emscripten paths (path.linux)
- Zsh keeps its own `config.d/` directory for zsh-only things (zinit, p10k, completion settings)
- Bash and zsh both source from `~/.config/shell/config.d/` for shared config
- Secrets move to `shell/.config/shell/config.d/` — single source of truth for all shells

### Package categorization
- CORE packages (installed with `--minimal`): stow, zsh, fzf, zoxide, tmux, neovim, git
- EXTRA packages: ghostty, bash, plus any GUI tools
- Stow all stow packages on all platforms — configs self-filter via platform includes (ghostty pattern)
- No platform-filtered stow list; simpler install logic

### Install script strategy
- Single `install.sh` for Mac + Linux
- `uname` check at script top: Linux → pacman, Darwin → brew
- Same package list mapped to platform-appropriate names
- Auto-install Homebrew on Mac if missing (official install script)
- `--minimal` flag installs only CORE packages
- Fail early if unsupported OS
- `install.ps1` is standalone for Windows — no shared code with install.sh

### PowerShell profile
- Alias parity: git shortcuts (gcm, gcl), directory jumps (lab, proj, s, p), n=nvim, t=tmux attach, dc=docker-compose
- Cross-platform pwsh — profile works on Windows, Mac, and Linux
- Standalone aliases defined in PowerShell syntax — does not parse bash/zsh config files
- May drift from zsh aliases — acceptable for best-effort
- Windows symlinks via `New-Item -ItemType SymbolicLink` (requires admin or Developer Mode; script checks and warns)

### Alacritty config
- Low-priority fallback terminal — not primary (Ghostty is primary)
- Mirrors Ghostty's platform-include pattern: base `alacritty.toml` + `linux.toml`/`macos.toml` imports
- Added to stow PACKAGES list, stowed on all platforms

### Claude's Discretion
- Exact brew package name mappings (may differ from pacman names)
- How zsh/bash source the shared config (dot-source order, guard syntax)
- PowerShell profile structure and function naming
- Alacritty base config content and platform-specific overrides
- README structure and content depth

</decisions>

<specifics>
## Specific Ideas

- Ghostty's existing pattern (`config`, `linux.conf`, `macos.conf`) is the reference for how platform includes should work across all app configs
- Bash currently sources from `~/.config/zsh/config.d/` — this is the migration path that needs updating
- Windows is best-effort — it's OK if install.ps1 drifts from install.sh

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ghostty/.config/ghostty/` — Working platform-include pattern (config + linux.conf + macos.conf) to replicate for Alacritty
- `zsh/.config/zsh/config.d/` — Source files to extract into shell/ (alias, env, path, secrets.encrypted)
- `bash/.bashrc` — Already sources from config.d, needs path update from zsh/ to shell/
- `install.sh` — Working stow + conflict detection logic to extend with platform branching

### Established Patterns
- `--no-folding` stow flag used everywhere for per-file symlinks
- Config.d sourcing pattern: individual files (alias, env, path) sourced separately
- Conflict backup to /tmp/dotfiles-backup/ before stowing

### Integration Points
- `install.sh` PACKAGES array — needs `shell` added, platform detection added
- `bash/.bashrc` — source paths change from `~/.config/zsh/config.d/` to `~/.config/shell/config.d/`
- `zsh/.zshrc` or equivalent — source paths need updating to shared location
- New `powershell/` stow package — profile.ps1 target location varies by OS

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-cross-platform-provisioning*
*Context gathered: 2026-03-08*
