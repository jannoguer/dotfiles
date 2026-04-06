#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" >/dev/null 2>&1 && pwd)"
DOTFILE="$SCRIPT_DIR/.created_tags"

if [ ! -f "$DOTFILE" ]; then
    echo "No rollback dotfile ($DOTFILE) found. Exiting."
    exit 0
fi

echo "Starting tag rollback..."

# Read the dotfile line by line
while IFS= read -r TAG; do
    if [ -n "$TAG" ]; then
        # Delete the tag from the local git repository
        git tag -d "$TAG" 2>/dev/null || true
        echo "Successfully rolled back tag: $TAG"
    fi
done < "$DOTFILE"

# Clean up the dotfile after completion
rm "$DOTFILE"
echo "Rollback complete."
