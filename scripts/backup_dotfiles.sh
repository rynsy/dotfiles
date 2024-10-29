#!/bin/bash

# Define the directories as an array
DIRECTORIES=("alacritty" "autorandr" "bluetuith" "gh" "lazygit" "manjaro" "nvim" "scripts" "sway" "waybar" "zsh")

# Create the directories and copy each one to ~/dotfiles
for DIR in "${DIRECTORIES[@]}"; do
	# Create the directory under ~/dotfiles
	mkdir -p "$HOME/dotfiles/$DIR"

	# Copy the directory from ~/.config to ~/dotfiles
	cp -rf "$HOME/.config/$DIR" "$HOME/dotfiles/"
done
