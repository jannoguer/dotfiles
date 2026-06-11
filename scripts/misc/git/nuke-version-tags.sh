#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
POPULATE_SCRIPT="$SCRIPT_DIR/populate-main-with-version-tags.sh"
TAG_PATTERN='^v[0-9]+\.[0-9]+\.[0-9]+$'
REMOTE="origin"
ASSUME_YES=false

usage() {
    echo "Usage: $(basename "$0") [-y|--yes]"
    echo "Deletes all local and remote tags matching vX.Y.Z, then runs populate-main-with-version-tags.sh."
}

while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes) ASSUME_YES=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Error: unknown argument: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: not inside a git repository." >&2
    exit 1
fi

if [ ! -f "$POPULATE_SCRIPT" ]; then
    echo "Error: required script not found: $POPULATE_SCRIPT" >&2
    exit 1
fi

LOCAL_TAGS=$(git tag --list | grep -E "$TAG_PATTERN" || true)

REMOTE_TAGS=""
HAS_REMOTE=false
if git remote get-url "$REMOTE" >/dev/null 2>&1; then
    HAS_REMOTE=true
    if ! REMOTE_LS=$(git ls-remote --tags --refs "$REMOTE" 2>&1); then
        echo "Error: could not reach remote '$REMOTE':" >&2
        echo "$REMOTE_LS" >&2
        exit 1
    fi
    REMOTE_TAGS=$(echo "$REMOTE_LS" | awk '{print $2}' | sed 's|^refs/tags/||' | grep -E "$TAG_PATTERN" || true)
else
    echo "No remote '$REMOTE' configured, skipping remote tag deletion."
fi

if [ -z "$LOCAL_TAGS" ] && [ -z "$REMOTE_TAGS" ]; then
    echo "No vX.Y.Z tags found locally or remotely."
else
    echo "The following tags will be PERMANENTLY deleted:"
    if [ -n "$LOCAL_TAGS" ]; then
        echo "  Local:  $(echo "$LOCAL_TAGS" | tr '\n' ' ')"
    fi
    if [ -n "$REMOTE_TAGS" ]; then
        echo "  Remote ($REMOTE): $(echo "$REMOTE_TAGS" | tr '\n' ' ')"
    fi

    if [ "$ASSUME_YES" != true ]; then
        if [ ! -t 0 ]; then
            echo "Error: non-interactive session. Re-run with -y/--yes to confirm deletion." >&2
            exit 1
        fi
        read -r -p "Proceed? [y/N] " REPLY
        case "$REPLY" in
            y|Y|yes|YES) ;;
            *) echo "Aborted."; exit 1 ;;
        esac
    fi

    if [ -n "$REMOTE_TAGS" ]; then
        mapfile -t REMOTE_TAG_ARR <<< "$REMOTE_TAGS"
        REFSPECS=()
        for TAG in "${REMOTE_TAG_ARR[@]}"; do
            REFSPECS+=(":refs/tags/$TAG")
        done
        git push "$REMOTE" "${REFSPECS[@]}"
        echo "Deleted ${#REMOTE_TAG_ARR[@]} remote tag(s) from '$REMOTE'."
    fi

    if [ -n "$LOCAL_TAGS" ]; then
        mapfile -t LOCAL_TAG_ARR <<< "$LOCAL_TAGS"
        git tag -d "${LOCAL_TAG_ARR[@]}" >/dev/null
        echo "Deleted ${#LOCAL_TAG_ARR[@]} local tag(s)."
    fi
fi

echo "Running populate-main-with-version-tags.sh..."
exec bash "$POPULATE_SCRIPT"
