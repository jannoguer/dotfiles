#!/usr/bin/env bash

# Check if we are on the correct branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    exit 0
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" >/dev/null 2>&1 && pwd)"
DOTFILE="$SCRIPT_DIR/.created_tags"

> "$DOTFILE" # Initialize/clear the dotfile

# Get the latest tag using the provided logic
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ ! "$LATEST_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then 
    LATEST_TAG=$(git tag --sort=-version:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
    LATEST_TAG="${LATEST_TAG:-v0.0.0}"
fi

# Parse Major, Minor, Patch
VERSION="${LATEST_TAG#v}"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# Determine the commit range to evaluate
if [ "$LATEST_TAG" = "v0.0.0" ]; then
    COMMIT_RANGE="HEAD"
else
    COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Iterate over the commits in reverse chronological order (oldest to newest)
git log --reverse --format="%H" "$COMMIT_RANGE" | while read -r COMMIT_HASH; do
    
    # Get the commit message for the current hash
    COMMIT_MSG=$(git log -1 --format="%s" "$COMMIT_HASH")
    BUMP_TYPE="none"

    # Determine bump type based on exact regex logic provided 
    if [[ "$COMMIT_MSG" =~ ^[a-zA-Z]+(\(.*\))?!: ]]; then
        BUMP_TYPE="major"
    elif [[ "$COMMIT_MSG" =~ ^feat(\(.*\))?: ]]; then
        BUMP_TYPE="minor"
    elif [[ "$COMMIT_MSG" =~ ^fix(\(.*\))?: ]]; then
        BUMP_TYPE="patch"
    fi

    if [[ "$BUMP_TYPE" = "none" ]]; then
        continue # Skip to next commit instead of exiting
    fi

    # Apply the mathematical bumps 
    if [[ "$BUMP_TYPE" = "major" ]]; then
        MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0
    elif [[ "$BUMP_TYPE" = "minor" ]]; then
        MINOR=$((MINOR + 1)); PATCH=0
    else
        PATCH=$((PATCH + 1))
    fi

    NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

    # Check if tag exists
    if [ -n "$(git tag -l "$NEW_VERSION")" ]; then
        echo "Skipping tag $NEW_VERSION — already exists." >&2
        continue
    fi

    # Create the tag and save it to the dotfile
    git tag "$NEW_VERSION" "$COMMIT_HASH"
    echo "$NEW_VERSION" >> "$DOTFILE"
    echo "Auto-tagged new version: $NEW_VERSION (triggered by $BUMP_TYPE on commit $COMMIT_HASH)"
done
