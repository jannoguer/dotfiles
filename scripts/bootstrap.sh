#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# GIT ---
GIT_SOURCE_DIR="$SCRIPT_DIR/../git"
GIT_CONFIG_FILE="${GIT_CONFIG_GLOBAL:-$HOME/.config/git/config}"
GIT_DEST_DIR="$(dirname "$GIT_CONFIG_FILE")"

mkdir -p "$GIT_DEST_DIR"

echo "Syncing git configuration files to $GIT_DEST_DIR..."

cp -riv "$GIT_SOURCE_DIR/." "$GIT_DEST_DIR/"

if [ "$GIT_CONFIG_FILE" != "$GIT_DEST_DIR/.gitconfig" ]; then
    mv "$GIT_DEST_DIR/.gitconfig" "$GIT_CONFIG_FILE"
fi

chmod +x "$GIT_DEST_DIR"/hooks/*
# ---

# CLAUDE
CLAUDE_SOURCE_DIR="$SCRIPT_DIR/../claude"
CLAUDE_DEST_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DEST_DIR"

echo "Syncing claude configuration files to $CLAUDE_DEST_DIR..."

cp -riv "$CLAUDE_SOURCE_DIR/." "$CLAUDE_DEST_DIR/"
# ---

echo "Done!"
