#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(nvim zsh claude git ssh tmux)
BACKUP_DIR="/tmp/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo "=== Dotfiles Bootstrap ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Step 1: Install packages
echo "--- Installing packages ---"
sudo pacman -S --needed stow zsh fzf zoxide tmux

# Step 2: Install zinit if missing
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  echo "--- Installing zinit ---"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Step 3: Back up conflicting real files
echo "--- Checking for conflicts ---"
conflicts=()

check_conflict() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    conflicts+=("$target")
  fi
}

# nvim: only check our managed files, leave omarchy symlinks alone
for f in init.lua stylua.toml .neoconf.json lazyvim.json; do
  check_conflict "$HOME/.config/nvim/$f"
done
for f in autocmds.lua keymaps.lua lazy.lua options.lua; do
  check_conflict "$HOME/.config/nvim/lua/config/$f"
done
for f in all-themes.lua better-escape.lua disable-news-alert.lua example.lua plugins.lua snacks-animated-scrolling-off.lua; do
  check_conflict "$HOME/.config/nvim/lua/plugins/$f"
done
check_conflict "$HOME/.config/nvim/plugin/after/transparency.lua"

check_conflict "$HOME/.zshenv"
for f in .zshrc .zprofile .p10k.zsh; do
  check_conflict "$HOME/.config/zsh/$f"
done
for f in alias env path secrets.encrypted .gitignore; do
  check_conflict "$HOME/.config/zsh/config.d/$f"
done

check_conflict "$HOME/.config/tmux/tmux.conf"
check_conflict "$HOME/.config/tmux/scripts/sessionizer.sh"

check_conflict "$HOME/.claude/settings.json"
check_conflict "$HOME/.claude/settings.local.json"
check_conflict "$HOME/.gitconfig"
check_conflict "$HOME/.ssh/config"

if [ ${#conflicts[@]} -gt 0 ]; then
  echo "Backing up ${#conflicts[@]} conflicting files to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  for f in "${conflicts[@]}"; do
    rel="${f#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$f" "$BACKUP_DIR/$rel"
    echo "  moved: $f"
  done
else
  echo "No conflicts found."
fi

# Step 4: Stow all packages
echo "--- Stowing packages ---"
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  echo "  stow --no-folding $pkg"
  stow --no-folding "$pkg"
done

# Step 5: Prompt to change shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo ""
  read -rp "Change default shell to zsh? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    chsh -s "$(which zsh)"
  fi
fi

# Step 6: Post-install notes
echo ""
echo "=== Done! ==="
echo ""
echo "Post-install steps:"
echo "  1. Decrypt secrets: cd $DOTFILES_DIR/zsh/.config/zsh/config.d && ansible-vault decrypt secrets.encrypted --output secrets"
echo "  2. Install TPM plugins: ~/.tmux/plugins/tpm/bin/install_plugins"
echo "  3. Launch nvim to install plugins (first run may take a moment)"
echo "  4. Open a new zsh shell to install zinit plugins and p10k prompt"
echo ""
if [ ${#conflicts[@]} -gt 0 ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
