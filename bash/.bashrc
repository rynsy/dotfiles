# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return ;;
esac

# History settings
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth

# Source shared config (single source of truth; also used by zsh)
[[ -f "$HOME/.config/zsh/config.d/env"   ]] && . "$HOME/.config/zsh/config.d/env"
[[ -f "$HOME/.config/zsh/config.d/path"  ]] && . "$HOME/.config/zsh/config.d/path"
[[ -f "$HOME/.config/zsh/config.d/alias" ]] && . "$HOME/.config/zsh/config.d/alias"
