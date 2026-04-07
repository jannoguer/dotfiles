#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define source and destination
GIT_SOURCE_DIR="$SCRIPT_DIR/../git"
GIT_DEST_DIR="$HOME/.gitconfig"

# Check if ~/.gitconfig exists AND is a standard file (not a directory)
if [ -f "$GIT_DEST_DIR" ]; then
    echo "Found an existing .gitconfig file. Backing it up to .gitconfig.bak..."
    mv "$GIT_DEST_DIR" "$GIT_DEST_DIR.bak"
fi

# Ensure the destination directory exists
mkdir -p "$GIT_DEST_DIR"

echo "Syncing git configuration files to $GIT_DEST_DIR..."

# Copy contents interactively and recursively
cp -riv "$GIT_SOURCE_DIR/." "$GIT_DEST_DIR/"

echo "Done!"
