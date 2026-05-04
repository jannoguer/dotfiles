#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# GIT ---
GIT_SOURCE_DIR="$SCRIPT_DIR/../git"
GIT_DEST_DIR="$HOME/.config/git"

mkdir -p "$GIT_DEST_DIR"

echo "Syncing git configuration files to $GIT_DEST_DIR..."

cp -riv "$GIT_SOURCE_DIR/." "$GIT_DEST_DIR/"

chmod +x "$GIT_DEST_DIR"/hooks/*
# ---

# CLAUDE ---
CLAUDE_SOURCE_DIR="$SCRIPT_DIR/../claude"
CLAUDE_DEST_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DEST_DIR"

echo "Syncing claude configuration files to $CLAUDE_DEST_DIR..."

cp -riv "$CLAUDE_SOURCE_DIR/." "$CLAUDE_DEST_DIR/"
# ---

echo "Done!"
