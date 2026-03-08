# Requirements: Dotfiles Overhaul

**Defined:** 2026-03-08
**Core Value:** A consistent, reliable development environment that works correctly across all devices — especially the Linux server accessed via Termux on Android.

## v1 Requirements

### Bug Fixes

- [x] **BUG-01**: nvim plugins.lua early return removed so all plugin config loads correctly
- [x] **BUG-02**: DOTNET_ROOT defined exactly once with the correct value
- [x] **BUG-03**: GEM_HOME points to gem root directory, not bin directory
- [x] **BUG-04**: tmux-yank plugin and manual copy-pipe binding no longer conflict
- [x] **BUG-05**: killemall function does not shadow system killall command

### Zsh

- [x] **ZSH-01**: EDITOR=nvim set so git, crontab, and other tools use nvim
- [x] **ZSH-02**: Stale aliases removed (zellij, alacritty-light, alacritty-dark)
- [x] **ZSH-03**: Quick tmux attach alias available (t → tmux new -As main)
- [x] **ZSH-04**: HISTSIZE increased to 50000

### tmux

- [x] **TMUX-01**: Sessionizer uses popup (display-popup) instead of new window
- [x] **TMUX-02**: OSC 52 clipboard works end-to-end (verified from Termux SSH session)

### ZMK

- [ ] **ZMK-01**: Media keys (prev/play-pause/next) added to Fn layer (Layer 2)
- [ ] **ZMK-02**: Volume keys (up/down/mute) added to Fn layer (Layer 2)
- [ ] **ZMK-03**: Layer 5 (Android) added — transparent base, BT slot 3
- [ ] **ZMK-04**: Mod+A toggles Layer 5 (Android) on/off
- [ ] **ZMK-05**: Firmware builds successfully via GitHub Actions after changes

### Dotfiles Management

- [x] **DOTS-01**: Ghostty stow situation clarified — either stowed from dotfiles or documented as Omarchy-managed
- [x] **DOTS-02**: .gitignore updated to exclude .planning/

## v1.5 Requirements — Bash Config and Shell Parity (Phase 01.1)

### Bash

- [ ] **BASH-01**: `bash/` stow package exists with `.bashrc` that sources shared aliases
- [ ] **BASH-02**: Shared `config.d/alias` file is bash-compatible (no zsh-only syntax)
- [ ] **BASH-03**: `t` alias available in bash sessions (tmux attach)
- [ ] **BASH-04**: EDITOR, PATH, and core env vars set in bash sessions
- [ ] **BASH-05**: bash config added to `install.sh` PACKAGES list

## v2 Requirements

### Termux Workflow

- **TERM-01**: Voice-to-text script for Termux using termux-speech-to-text
- **TERM-02**: Termux widget shortcut for voice-to-text → clipboard

### ZMK

- **ZMK-06**: Android layer updated with any remaps discovered through actual use

### Zsh

- **ZSH-05**: MANPAGER set to nvim for man page viewing

## v3 Requirements — Cross-Platform Provisioning (Long-term)

### Provisioning Scripts

- **PROV-01**: `install.sh` supports Arch Linux full mode (existing) and minimal mode (zsh, tmux, nvim only — no GUI tools)
- **PROV-02**: `install.sh` supports macOS via Homebrew (full and minimal modes)
- **PROV-03**: `install.ps1` Windows setup script — creates symlinks manually (no Stow), installs packages via winget
- **PROV-04**: All provisioning scripts share a common "minimal" package set definition

### PowerShell

- **PSH-01**: `powershell/` stow package with cross-platform `profile.ps1`
- **PSH-02**: PowerShell profile has equivalent aliases to zsh config (git shortcuts, directory jumps, docker-compose, tmux attach)
- **PSH-03**: PowerShell profile works on Windows, Mac, and Linux (pwsh)

### Additional App Configs

- **APP-01**: `alacritty/` stow package with platform-specific config includes (mirrors ghostty pattern)
- **APP-02**: Alacritty config is cross-platform (Linux/Mac/Windows paths handled)

### Cross-Platform Structure

- **XPLAT-01**: Each app config follows the platform-include pattern (base config + optional platform overrides)
- **XPLAT-02**: README documents what each provisioning script installs and how to use it

## Out of Scope

| Feature | Reason |
|---------|--------|
| Colemak layout | No real pain point; productivity cost too high |
| Windows ZMK layer | Layer 0 works fine for Windows |
| Vim plugin overhaul | No specific pain point surfaced |
| OpenCode/Claude workflow | No specific pain point surfaced |
| Android modifier remaps | Unknown need; discover through use first |
| chezmoi migration | User wants to keep Stow |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| BUG-01 | Phase 1 | Complete |
| BUG-02 | Phase 1 | Complete |
| BUG-03 | Phase 1 | Complete |
| BUG-04 | Phase 1 | Complete |
| BUG-05 | Phase 1 | Complete |
| ZSH-01 | Phase 1 | Complete |
| ZSH-02 | Phase 1 | Complete |
| ZSH-03 | Phase 1 | Complete |
| ZSH-04 | Phase 1 | Complete |
| TMUX-01 | Phase 1 | Complete |
| TMUX-02 | Phase 1 | Complete |
| DOTS-01 | Phase 1 | Complete |
| DOTS-02 | Phase 1 | Complete |
| ZMK-01 | Phase 2 | Pending |
| ZMK-02 | Phase 2 | Pending |
| ZMK-03 | Phase 2 | Pending |
| ZMK-04 | Phase 2 | Pending |
| ZMK-05 | Phase 2 | Pending |

**Coverage:**
- v1 requirements: 18 total — mapped to phases 1–2 ✓
- v2 requirements: 3 total — deferred
- v3 requirements: 10 total — deferred (Phase 3, long-term)

---
*Requirements defined: 2026-03-08*
*Last updated: 2026-03-08 after roadmap creation*
