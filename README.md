# dotfiles

GNU Stow-managed dotfiles for Arch Linux (Hyprland/omarchy), macOS, and Windows. Cross-platform provisioning with a single source of truth.

## Quick Start

### Arch Linux (full)

```bash
git clone git@github.com:rynsy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Arch Linux (minimal)

Installs only core packages (stow, zsh, fzf, zoxide, tmux, neovim, git) -- no GUI tools:

```bash
./install.sh --minimal
```

### macOS

Auto-installs Homebrew if missing, then installs packages via brew:

```bash
git clone git@github.com:rynsy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Minimal mode works the same: `./install.sh --minimal`

### Windows

Requires Developer Mode for symlinks (Settings > Update & Security > For developers):

```powershell
git clone git@github.com:rynsy/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
.\install.ps1
```

Installs packages via winget and creates config symlinks manually (no Stow on Windows).

## Packages

| Package | Target | Contents |
|---------|--------|----------|
| `nvim` | `~/.config/nvim/` | LazyVim config, keymaps, plugins, transparency |
| `zsh` | `~/.zshenv`, `~/.config/zsh/` | zinit, p10k prompt, zsh-specific config |
| `bash` | `~/.bashrc`, `~/.bash_profile` | Bash config sourcing shared shell config |
| `shell` | `~/.config/shell/` | Shared config: aliases, env, path, secrets (used by zsh and bash) |
| `powershell` | `~/.config/powershell/` | Cross-platform PowerShell profile with equivalent aliases |
| `claude` | `~/.claude/` | Claude Code settings |
| `tmux` | `~/.config/tmux/` | tmux.conf, sessionizer script, catppuccin theme |
| `git` | `~/.gitconfig` | User, aliases, credential helpers |
| `ssh` | `~/.ssh/config` | Dev host config |
| `ghostty` | `~/.config/ghostty/` | Primary terminal config with platform includes |
| `alacritty` | `~/.config/alacritty/` | Fallback terminal config with platform includes |

All packages are stowed on all platforms. Configs self-filter via platform-specific includes (e.g., `linux.conf`/`macos.conf` silently skipped if missing).

## Post-Install

1. **Decrypt secrets:**
   ```bash
   cd ~/dotfiles/shell/.config/shell/config.d
   ansible-vault decrypt secrets.encrypted --output secrets
   ```
2. **Install TPM plugins:** `~/.tmux/plugins/tpm/bin/install_plugins`
3. **Launch nvim** to install plugins (first run may take a moment)
4. **Open a new zsh shell** to install zinit plugins and p10k prompt

## Stow Commands

```bash
cd ~/dotfiles
stow --no-folding <package>    # create symlinks
stow -D <package>              # remove symlinks
stow -R <package>              # restow (remove + create)
```

`--no-folding` is required -- it creates per-file symlinks so omarchy's `theme.lua` and `omarchy-theme-hotreload.lua` coexist alongside stow-managed nvim files.

## Structure

Shared shell config lives in `shell/.config/shell/config.d/` and is sourced by both zsh and bash. Platform-specific overrides (e.g., `alias.linux`, `path.darwin`) are loaded conditionally via `uname`. App configs (Ghostty, Alacritty) use the same platform-include pattern: a base config imports platform-specific files that are silently skipped if missing.

`install.sh` handles both Arch Linux (pacman) and macOS (Homebrew). `install.ps1` is a standalone Windows script using winget. The two scripts are independent by design.

## What's Excluded

- **omarchy-managed nvim files**: `theme.lua`, `omarchy-theme-hotreload.lua` (symlinks managed by omarchy)
- **TPM plugins**: `~/.config/tmux/plugins/`, `~/.tmux/plugins/` (installed at runtime by TPM)
- **Generated files**: `lazy-lock.json`, `.zcompdump`, `.zcompcache/`
- **Secrets/tokens**: SSH keys, `~/.config/gh/hosts.yml`, `~/.claude/.credentials.json`
- **Claude runtime data**: history, cache, projects, session data

## Archive

The `archive/manjaro-i3-sway` branch preserves old configs: i3, sway, vim, manjaro, autorandr, bluetuith, alacritty, waybar, lazygit, and backup scripts.
