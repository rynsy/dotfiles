#!/usr/bin/env bash
set -euo pipefail

# --- Argument parsing ---
MINIMAL=false
for arg in "$@"; do
  case "$arg" in
    --minimal) MINIMAL=true ;;
    *)
      echo "Usage: $0 [--minimal]" >&2
      echo "  --minimal  Install only core packages (stow, zsh, fzf, zoxide, tmux, neovim, git)" >&2
      exit 1
      ;;
  esac
done

# --- OS detection ---
OS="$(uname -s)"
case "$OS" in
  Linux)
    if command -v apt-get &>/dev/null || [ -f /etc/debian_version ]; then
      PKG_MGR="apt"
    else
      PKG_MGR="pacman"
    fi
    ;;
  Darwin) PKG_MGR="brew" ;;
  *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(nvim zsh claude git ssh tmux ghostty bash shell powershell alacritty)
BACKUP_DIR="/tmp/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo "=== Dotfiles Bootstrap ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo "OS: $OS (package manager: $PKG_MGR)"
echo "Minimal: $MINIMAL"
echo ""

# --- Package arrays ---
CORE_PACMAN=(stow zsh fzf zoxide tmux neovim git)
EXTRA_PACMAN=(bash ghostty alacritty)

CORE_BREW=(stow zsh fzf zoxide tmux neovim git)
EXTRA_BREW=(bash)
EXTRA_CASKS=(ghostty alacritty)

# Ubuntu/Debian — neovim and zoxide may be old/absent in older releases
CORE_APT=(stow zsh fzf tmux git curl ncurses-term)
EXTRA_APT=(neovim zoxide)

# Step 1: Install packages
echo "--- Installing packages ---"
if [ "$PKG_MGR" = "apt" ]; then
  echo "Installing core packages via apt..."
  sudo apt-get update -q
  sudo apt-get install -y "${CORE_APT[@]}"
  if [ "$MINIMAL" = false ]; then
    echo "Installing extra packages via apt (best-effort)..."
    for pkg in "${EXTRA_APT[@]}"; do
      sudo apt-get install -y "$pkg" || echo "  Warning: could not install '$pkg' — install manually if needed"
    done
  fi
elif [ "$PKG_MGR" = "pacman" ]; then
  echo "Installing core packages via pacman..."
  sudo pacman -S --needed "${CORE_PACMAN[@]}"
  if [ "$MINIMAL" = false ]; then
    echo "Installing extra packages via pacman..."
    sudo pacman -S --needed "${EXTRA_PACMAN[@]}"
  fi
elif [ "$PKG_MGR" = "brew" ]; then
  # Auto-install Homebrew if missing
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Eval shellenv so brew is available for the rest of the script
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  echo "Installing core packages via brew..."
  brew install "${CORE_BREW[@]}"
  if [ "$MINIMAL" = false ]; then
    echo "Installing extra packages via brew..."
    brew install "${EXTRA_BREW[@]}"
    echo "Installing cask packages via brew..."
    for cask in "${EXTRA_CASKS[@]}"; do
      brew install --cask "$cask" || echo "Warning: failed to install cask '$cask' (may not be available)"
    done
  fi
fi

# Step 2: Install zinit if missing
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  echo "--- Installing zinit ---"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Step 2b: Install TPM if missing
TPM_HOME="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_HOME" ]; then
  echo "--- Installing TPM ---"
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$TPM_HOME"
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

check_conflict "$HOME/.bashrc"
check_conflict "$HOME/.bash_profile"

check_conflict "$HOME/.config/tmux/tmux.conf"
check_conflict "$HOME/.config/tmux/scripts/sessionizer.sh"

check_conflict "$HOME/.claude/settings.json"
check_conflict "$HOME/.claude/settings.local.json"
check_conflict "$HOME/.gitconfig"
check_conflict "$HOME/.ssh/config"

# shell/ package conflicts
for f in alias env path secrets.encrypted .gitignore; do
  check_conflict "$HOME/.config/shell/config.d/$f"
done

# powershell/ package conflicts
check_conflict "$HOME/.config/powershell/profile.ps1"

# alacritty/ package conflicts
check_conflict "$HOME/.config/alacritty/alacritty.toml"

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
  stow --no-folding "$pkg" || echo "  Warning: stow $pkg had conflicts — resolve manually then re-run stow"
done

# Step 4.5: Clone TPM plugins directly (reliable, no tmux session required)
echo "--- Installing TPM plugins ---"
PLUGIN_DIR="$HOME/.tmux/plugins"
mkdir -p "$PLUGIN_DIR"
clone_plugin() {
  local repo="$1" dest="$2"
  if [ ! -d "$PLUGIN_DIR/$dest" ]; then
    echo "  cloning $repo"
    git clone --depth=1 "https://github.com/$repo" "$PLUGIN_DIR/$dest"
  else
    echo "  already installed: $dest"
  fi
}
clone_plugin "tmux-plugins/tmux-sensible"         "tmux-sensible"
clone_plugin "catppuccin/tmux"                    "tmux"
clone_plugin "tmux-plugins/tmux-yank"             "tmux-yank"
clone_plugin "tmux-plugins/tmux-resurrect"        "tmux-resurrect"
clone_plugin "tmux-plugins/tmux-continuum"        "tmux-continuum"

# Step 4.7: Place platform-specific Alacritty config
if [ -d "$DOTFILES_DIR/alacritty/platform" ]; then
  echo "--- Placing platform Alacritty config ---"
  mkdir -p "$HOME/.config/alacritty"
  case "$OS" in
    Linux)
      ln -sf "$DOTFILES_DIR/alacritty/platform/linux.toml" "$HOME/.config/alacritty/linux.toml"
      echo "  linked: linux.toml"
      ;;
    Darwin)
      ln -sf "$DOTFILES_DIR/alacritty/platform/macos.toml" "$HOME/.config/alacritty/macos.toml"
      echo "  linked: macos.toml"
      ;;
  esac
fi

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
echo "  1. Decrypt secrets: cd $DOTFILES_DIR/shell/.config/shell/config.d && ansible-vault decrypt secrets.encrypted --output secrets"
echo "  2. Launch nvim to install plugins (first run may take a moment)"
echo "  3. Open a new zsh shell to install zinit plugins and p10k prompt"
echo ""
echo "  Note: TMux plugins were cloned directly. If a plugin is missing,"
echo "  re-run install.sh or clone it to ~/.tmux/plugins/<name> manually."
if [ "$PKG_MGR" = "apt" ]; then
  echo ""
  echo "  Ubuntu notes:"
  echo "  - If neovim is too old, install latest from: https://github.com/neovim/neovim/releases"
  echo "  - If zoxide is missing, install from: https://github.com/ajeetdsouza/zoxide#installation"
  echo "  - F12 tmux passthrough requires ncurses-term (installed). If F12 doesn't work,"
  echo "    check your SSH client terminal supports sending F12."
fi
echo ""
if [ ${#conflicts[@]} -gt 0 ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
