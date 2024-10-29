#!/bin/bash

# Define the directories as an array
DIRECTORIES=("alacritty" "autorandr" "bluetuith" "gh" "lazygit" "manjaro" "nvim" "scripts" "sway" "waybar" "zsh")

# Create the directories and copy each one to ~/dotfiles
for DIR in "${DIRECTORIES[@]}"; do
	# Create the directory under ~/dotfiles if it doesn't exist
	mkdir -p "$HOME/dotfiles/$DIR"

	# Use rsync to copy while excluding .git directories
	rsync -a --exclude='.git' "$HOME/.config/$DIR/" "$HOME/dotfiles/$DIR"
done

cd "$HOME"/dotfiles/ || exit
git add * || exit
git commit -m "automated backup" || exit
git push --all || exit
