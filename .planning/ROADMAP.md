# Roadmap: Dotfiles Overhaul

## Overview

Three phases: fix environment inconsistencies (Phase 1), extend ZMK keyboard firmware (Phase 2), and build cross-platform provisioning for Windows/Mac/Linux (Phase 3). Phase 1 delivers a clean daily driver. Phase 2 completes the keyboard story. Phase 3 is long-term infrastructure work with no fixed timeline.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Environment Fixes** - Fix all shell/editor/tmux bugs and clean up zsh config (completed 2026-03-08)
- [x] **Phase 2: ZMK Firmware** - Add media keys and Android layer to keyboard firmware (completed 2026-03-08)
- [ ] **Phase 3: Cross-Platform Provisioning** - Shared shell config, PowerShell profile, and full/minimal install scripts for Arch/Mac/Windows (long-term)

## Phase Details

### Phase 1: Environment Fixes
**Goal**: The development environment is clean and reliable — no broken configs, no stale aliases, no conflicting bindings
**Depends on**: Nothing (first phase)
**Requirements**: BUG-01, BUG-02, BUG-03, BUG-04, BUG-05, ZSH-01, ZSH-02, ZSH-03, ZSH-04, TMUX-01, TMUX-02, DOTS-01, DOTS-02
**Success Criteria** (what must be TRUE):
  1. Neovim loads all plugin configuration without stopping at an early return
  2. Shell environment variables (DOTNET_ROOT, GEM_HOME, EDITOR) are each defined once with correct values
  3. tmux copy works without binding conflicts, and OSC 52 clipboard is confirmed working from a Termux SSH session
  4. Running `killemall` does not suppress or shadow the system `killall` command
  5. Zsh has no aliases for removed tools (zellij, alacritty switchers), and `t` attaches or creates a main tmux session
**Plans**: 4 plans

Plans:
- [ ] 01-01-PLAN.md — Fix zsh config: remove stale aliases, fix killall shadow, add t alias, set EDITOR, fix GEM_HOME, remove duplicate DOTNET_ROOT, increase HISTSIZE
- [ ] 01-02-PLAN.md — Fix nvim plugins.lua early return and tmux binding conflicts; update sessionizer to display-popup
- [ ] 01-03-PLAN.md — Stow ghostty config and add to install.sh PACKAGES
- [ ] 01-04-PLAN.md — Verify OSC 52 clipboard passthrough from Termux SSH session (manual checkpoint)

### Phase 01.1: Bash Config and Shell Parity (INSERTED)

**Goal:** Bash sessions have the same aliases and env vars as zsh — t, n, gcm, EDITOR, and full PATH all work out of the box
**Requirements**: BASH-01, BASH-02, BASH-03, BASH-04, BASH-05
**Depends on:** Phase 1
**Plans:** 1/1 plans complete

Plans:
- [ ] 01.1-01-PLAN.md — Create bash/ stow package (.bashrc + .bash_profile) sourcing shared config.d files; update install.sh

### Phase 2: ZMK Firmware (Complete)
**Goal**: The keyboard firmware has media/volume keys on the Fn layer and a working Android BT layer, built and flashed successfully
**Depends on**: Phase 1
**Requirements**: ZMK-01, ZMK-02, ZMK-03, ZMK-04, ZMK-05
**Completed**: 2026-03-08
**Notes**: Media keys were initially placed on left hand (QWE/ASD) by upstream, then relocated to right-hand HJKL cluster (Fn+HJKL=prev/vol/next, Fn+;=play, Fn+M=mute). Merge conflict resolved in favor of HJKL layout.

Plans:
- [x] 02-01-PLAN.md — Edit adv360.keymap: add media/volume keys to Fn layer, append Android layer (Layer 5), add Mod+A toggle
- [x] 02-02-PLAN.md — Commit and push via submodule git workflow; verify GitHub Actions firmware build succeeds

### Phase 3: Cross-Platform Provisioning
**Goal**: The repo can provision a full or minimal dev environment on Arch Linux, macOS, and Windows from a single source of truth
**Depends on**: Phase 2
**Requirements**: SHELL-01, SHELL-02, PROV-01, PROV-02, PROV-03, PROV-04, PSH-01, PSH-02, PSH-03, APP-01, APP-02, XPLAT-01, XPLAT-02
**Success Criteria** (what must be TRUE):
  1. Shared shell config lives in `shell/.config/shell/config.d/` — zsh, bash, and pwsh all source from `~/.config/shell/config.d/`
  2. Platform-specific paths are gated by `uname` (path.linux, path.darwin)
  3. Running `install.sh --minimal` on a fresh Arch or Mac box installs zsh, tmux, nvim and stows their configs
  4. Running `install.ps1` on Windows creates correct symlinks and installs packages via winget (best-effort)
  5. PowerShell profile provides equivalent aliases to zsh (git shortcuts, directory jumps, tmux attach)
  6. README clearly documents how to provision each platform

**Architecture decisions:**
- `shell/` stow package owns shared config (alias, env, path, path.linux, path.darwin) — no shell "hosts" another shell's config
- `install.sh` handles both Arch (pacman) and macOS (brew) with a `--minimal` flag; PACKAGES split into CORE and EXTRA
- `install.ps1` is a standalone PowerShell script for Windows — no shared code with install.sh, intentionally simple
- Mac and Linux are first-class citizens; Windows is best-effort

**Plans**: 4 plans

Plans:
- [x] 03-01-PLAN.md — Extract shared shell config into shell/ stow package; split platform files; update zsh/bash sourcing
- [x] 03-02-PLAN.md — Extend install.sh with platform detection (pacman/brew), CORE/EXTRA split, --minimal flag
- [ ] 03-03-PLAN.md — Create powershell/ profile and alacritty/ config stow packages
- [ ] 03-04-PLAN.md — Create install.ps1 for Windows; update README.md and CLAUDE.md

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Environment Fixes | 3/4 | Complete    | 2026-03-08 |
| 01.1. Bash Config | 1/1 | Complete    | 2026-03-08 |
| 2. ZMK Firmware | 2/2 | Complete | 2026-03-08 |
| 3. Cross-Platform Provisioning | 0/4 | Planning complete | - |
