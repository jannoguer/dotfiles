#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/.."

echo "Syncing dotfiles from $DOTFILES_DIR to $HOME/..."

echo "Syncing git configuration files..."
cp -ri "$DOTFILES_DIR/git/." "$HOME/"
chmod +x "$HOME/.config/git"/hooks/*
echo "Git configuration sync done!"

echo "Syncing claude configuration files..."
cp -ri "$DOTFILES_DIR/claude/." "$HOME/"
echo "Claude configuration sync done!"

echo "Syncing vim configuration files..."
cp -ri "$DOTFILES_DIR/vim/." "$HOME/"
echo "Vim configuration sync done!"

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  echo "Syncing mintty configuration files..."
  cp -ri "$DOTFILES_DIR/mintty/." "$HOME/"
  echo "Mintty configuration sync done!"
fi

echo "Done!"
