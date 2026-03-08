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
_shell_config="$HOME/.config/shell/config.d"
[[ -f "$_shell_config/env"   ]] && . "$_shell_config/env"
[[ -f "$_shell_config/path"  ]] && . "$_shell_config/path"
[[ -f "$_shell_config/alias" ]] && . "$_shell_config/alias"
case "$(uname -s)" in
  Linux)  for f in env.linux path.linux alias.linux; do [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"; done ;;
  Darwin) for f in env.darwin path.darwin alias.darwin; do [[ -f "$_shell_config/$f" ]] && . "$_shell_config/$f"; done ;;
esac
[[ -f "$_shell_config/secrets" ]] && . "$_shell_config/secrets"
unset _shell_config
