# dotfiles

GNU Stow-managed dotfiles for Arch Linux with Hyprland (omarchy).

## Packages

| Package | Target | Contents |
|---------|--------|----------|
| `nvim` | `~/.config/nvim/` | LazyVim config, keymaps, plugins, transparency |
| `zsh` | `~/.zshenv`, `~/.config/zsh/` | zinit, p10k, aliases, env, secrets |
| `claude` | `~/.claude/` | Claude Code settings |
| `git` | `~/.gitconfig` | User, aliases, credential helpers |
| `ssh` | `~/.ssh/config` | Dev host config |

## Usage

### Bootstrap a new machine

```bash
git clone git@github.com:rynsy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Manual stow/unstow

```bash
cd ~/dotfiles
stow --no-folding <package>    # create symlinks
stow -D <package>              # remove symlinks
stow -R <package>              # restow (remove + create)
```

`--no-folding` is important for nvim -- it creates per-file symlinks so omarchy's
`theme.lua` and `omarchy-theme-hotreload.lua` coexist alongside stow-managed files.

## Secrets

Secrets are encrypted with ansible-vault and excluded via `.gitignore`:

```bash
# Decrypt
cd zsh/.config/zsh/config.d
ansible-vault decrypt secrets.encrypted --output secrets

# Re-encrypt after changes
ansible-vault encrypt secrets --output secrets.encrypted
```

## What's excluded

- **omarchy-managed nvim files**: `theme.lua`, `omarchy-theme-hotreload.lua` (symlinks managed by omarchy)
- **Generated files**: `lazy-lock.json`, `.zcompdump`, `.zcompcache/`
- **Secrets/tokens**: SSH keys, `~/.config/gh/hosts.yml`, `~/.claude/.credentials.json`
- **Claude runtime data**: history, cache, projects, session data

## Archive

The `archive/manjaro-i3-sway` branch preserves old configs: i3, sway, vim, manjaro,
autorandr, bluetuith, alacritty, waybar, lazygit, and backup scripts.
