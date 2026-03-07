#!/usr/bin/env bash
# tmux sessionizer — fzf-powered project session switcher
# Bound to prefix+f

# Find project directories and select with fzf
selected=$(find ~/code -mindepth 1 -maxdepth 1 -type d | fzf-tmux -p --reverse --prompt="session> ")

# Exit if nothing selected
if [[ -z "$selected" ]]; then
    exit 0
fi

# Session name from directory basename, replacing dots with underscores
session_name=$(basename "$selected" | tr '.' '_')

# If not inside tmux, create or attach
if [[ -z "$TMUX" ]]; then
    tmux new-session -A -s "$session_name" -c "$selected"
    exit 0
fi

# If inside tmux, create session if it doesn't exist, then switch
if ! tmux has-session -t="$session_name" 2>/dev/null; then
    tmux new-session -ds "$session_name" -c "$selected"
fi

tmux switch-client -t "$session_name"
