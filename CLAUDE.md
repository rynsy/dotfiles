# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

GNU Stow-managed dotfiles for Arch Linux (Hyprland/omarchy). Cross-platform support for macOS via aerospace and ghostty platform configs.

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

Stowed packages (defined in `install.sh`): `nvim`, `zsh`, `claude`, `git`, `ssh`, `tmux`

Additional packages not in install.sh: `aerospace` (macOS only), `ghostty`, `zmk` (git submodule → `Adv360-Pro-ZMK`)

Each package directory mirrors the target home directory structure (e.g., `nvim/.config/nvim/` → `~/.config/nvim/`).

## Key Architecture

- **Neovim**: LazyVim-based. Plugins in `nvim/.config/nvim/lua/plugins/` (one feature per file). Themes in `all-themes.lua` are lazy-loaded with `priority = 1000`. Transparency configured in `plugin/after/transparency.lua`.
- **Zsh**: zinit plugin manager, Powerlevel10k prompt. Config split across `zsh/.config/zsh/config.d/` files: `alias`, `env`, `path`, `secrets.encrypted`.
- **Tmux**: TPM for plugins. Sessionizer script at `tmux/.config/tmux/scripts/sessionizer.sh`. VI-mode copy with OS-detected clipboard (pbcopy/wl-copy).
- **Secrets**: ansible-vault encrypted at `zsh/.config/zsh/config.d/secrets.encrypted`. Decrypted file (`secrets`) is gitignored.
- **ZMK**: Kinesis Advantage 360 Pro firmware as git submodule. Mac layer maps Left Ctrl → Cmd for aerospace compatibility.

## Cross-Platform Patterns

Keybindings are kept consistent: Hyprland uses `Super+hjkl/1-9`, aerospace uses `Cmd+hjkl/1-9` (ZMK Mac layer maps physical Left Ctrl to Cmd). Ghostty uses platform-specific config files (`linux.conf`, `macos.conf`) that are silently ignored if missing.
