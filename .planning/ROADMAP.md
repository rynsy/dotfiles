# Roadmap: Dotfiles Overhaul

## Overview

Three phases: fix environment inconsistencies (Phase 1), extend ZMK keyboard firmware (Phase 2), and build cross-platform provisioning for Windows/Mac/Linux (Phase 3). Phase 1 delivers a clean daily driver. Phase 2 completes the keyboard story. Phase 3 is long-term infrastructure work with no fixed timeline.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Environment Fixes** - Fix all shell/editor/tmux bugs and clean up zsh config (completed 2026-03-08)
- [ ] **Phase 2: ZMK Firmware** - Add media keys and Android layer to keyboard firmware
- [ ] **Phase 3: Cross-Platform Provisioning** - PowerShell config, alacritty package, and full/minimal install scripts for Arch/Mac/Windows (long-term)

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
**Plans:** 1 plan

Plans:
- [ ] 01.1-01-PLAN.md — Create bash/ stow package (.bashrc + .bash_profile) sourcing shared config.d files; update install.sh

### Phase 2: ZMK Firmware
**Goal**: The keyboard firmware has media/volume keys on the Fn layer and a working Android BT layer, built and flashed successfully
**Depends on**: Phase 1
**Requirements**: ZMK-01, ZMK-02, ZMK-03, ZMK-04, ZMK-05
**Success Criteria** (what must be TRUE):
  1. Pressing Fn layer keys controls media playback (prev/play-pause/next) and volume (up/down/mute) on connected devices
  2. Mod+A toggles the Android layer on and off
  3. The Android layer connects to BT slot 3 (the phone) when toggled on
  4. Firmware builds successfully via GitHub Actions with no errors
**Plans**: TBD

### Phase 3: Cross-Platform Provisioning
**Goal**: The repo can provision a full or minimal dev environment on Arch Linux, macOS, and Windows from a single source of truth
**Depends on**: Phase 2
**Requirements**: PROV-01, PROV-02, PROV-03, PROV-04, PSH-01, PSH-02, PSH-03, APP-01, APP-02, XPLAT-01, XPLAT-02
**Success Criteria** (what must be TRUE):
  1. Running install.sh with --minimal on a fresh Arch or Mac box installs zsh, tmux, nvim and stows their configs
  2. Running install.ps1 on Windows creates correct symlinks and installs packages via winget
  3. PowerShell profile provides equivalent aliases to zsh (git shortcuts, directory jumps, tmux attach)
  4. Alacritty config is stowed and platform-specific overrides work on Linux and Mac
  5. README clearly documents how to provision each platform
**Plans**: TBD (long-term — plan when ready to execute)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Environment Fixes | 3/4 | Complete    | 2026-03-08 |
| 01.1. Bash Config | 0/1 | Not started | - |
| 2. ZMK Firmware | 0/TBD | Not started | - |
| 3. Cross-Platform Provisioning | 0/TBD | Not started (long-term) | - |
