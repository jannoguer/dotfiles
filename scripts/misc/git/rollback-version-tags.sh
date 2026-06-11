#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: not inside a git repository." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DOTFILE="$SCRIPT_DIR/.created_tags"

if [ ! -f "$DOTFILE" ]; then
    echo "No rollback dotfile ($DOTFILE) found. Exiting."
    exit 0
fi

echo "Starting tag rollback..."

while IFS= read -r TAG || [ -n "$TAG" ]; do
    if [ -z "$TAG" ]; then
        continue
    fi
    if git tag -d "$TAG" >/dev/null 2>&1; then
        echo "Rolled back tag: $TAG"
    else
        echo "Warning: tag $TAG not found locally, skipping." >&2
    fi
done < "$DOTFILE"

rm -f "$DOTFILE"
echo "Rollback complete."
