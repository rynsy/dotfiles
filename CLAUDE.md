# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

GNU Stow-managed dotfiles for Arch Linux (Hyprland/omarchy), macOS, and Windows. Cross-platform provisioning via `install.sh` (Linux/macOS) and `install.ps1` (Windows).

## Stow Commands

```bash
cd ~/dotfiles
stow --no-folding <package>    # create symlinks
stow -D <package>              # remove symlinks
stow -R <package>              # restow (remove + create)
./install.sh                   # full bootstrap (pacman, zinit, stow all)
```

**`--no-folding` is required** — creates per-file symlinks so omarchy's theme files (`theme.lua`, `omarchy-theme-hotreload.lua`) coexist with stow-managed nvim files.

## Packages

Stowed packages (defined in `install.sh`): `nvim`, `zsh`, `claude`, `git`, `ssh`, `tmux`, `ghostty`, `bash`, `shell`, `powershell`, `alacritty`

Additional packages not in install.sh: `aerospace` (macOS only), `zmk` (git submodule -> `Adv360-Pro-ZMK`)

Each package directory mirrors the target home directory structure (e.g., `nvim/.config/nvim/` → `~/.config/nvim/`).

## Key Architecture

- **Neovim**: LazyVim-based. Plugins in `nvim/.config/nvim/lua/plugins/` (one feature per file). Themes in `all-themes.lua` are lazy-loaded with `priority = 1000`. Transparency configured in `plugin/after/transparency.lua`.
- **Shell config**: Shared config in `shell/.config/shell/config.d/` — sourced by both zsh and bash. Files: `alias`, `env`, `path`, plus platform overrides (`alias.linux`, `path.darwin`, etc.). Platform files loaded conditionally via `uname`.
- **Zsh**: zinit plugin manager, Powerlevel10k prompt. Zsh-specific config in `zsh/.config/zsh/`; shared aliases/env/path sourced from `~/.config/shell/config.d/`.
- **Bash**: Sources shared config from `~/.config/shell/config.d/` via `.bashrc`.
- **PowerShell**: Cross-platform `profile.ps1` with equivalent aliases to zsh config. Standalone definitions (does not parse bash/zsh files). Stowed to `~/.config/powershell/`; on Windows, `install.ps1` symlinks to `$HOME\Documents\PowerShell\`.
- **Tmux**: TPM for plugins. Sessionizer script at `tmux/.config/tmux/scripts/sessionizer.sh`. VI-mode copy with OS-detected clipboard (pbcopy/wl-copy).
- **Secrets**: ansible-vault encrypted at `shell/.config/shell/config.d/secrets.encrypted`. Decrypted file (`secrets`) is gitignored.
- **Alacritty**: Fallback terminal. Platform-include pattern mirrors Ghostty: base `alacritty.toml` imports `linux.toml`/`macos.toml` (missing files silently skipped).
- **ZMK**: Kinesis Advantage 360 Pro firmware as git submodule. Mac layer maps Left Ctrl → Cmd for aerospace compatibility.

## Cross-Platform Patterns

Keybindings are kept consistent: Hyprland uses `Super+hjkl/1-9`, aerospace uses `Cmd+hjkl/1-9` (ZMK Mac layer maps physical Left Ctrl to Cmd). App configs (Ghostty, Alacritty) use the platform-include pattern: base config imports platform-specific files (`linux.conf`/`macos.conf`) that are silently ignored if missing. Shell config sourced from `~/.config/shell/config.d/` with `uname`-conditional platform files (`path.linux`, `path.darwin`, `alias.linux`, `alias.darwin`, etc.).
