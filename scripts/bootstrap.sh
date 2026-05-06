#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/.."

echo "Syncing dotfiles from $DOTFILES_DIR to home directory..."

echo "Syncing git configuration files..."
cp -riv "$DOTFILES_DIR/git/." "$HOME/"
chmod +x "$HOME/.config/git"/hooks/*
echo "Git configuration sync done!"

echo "Syncing claude configuration files..."
cp -riv "$DOTFILES_DIR/claude/." "$HOME/"
echo "Claude configuration sync done!"

echo "Done!"
