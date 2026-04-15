#!/usr/bin/env bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" >/dev/null 2>&1 && pwd)"
DOTFILE="$SCRIPT_DIR/.created_tags"

> "$DOTFILE"

LATEST_TAG=$(git tag --sort=-version:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)

if [ -z "$LATEST_TAG" ]; then
    FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
    git tag "v1.0.0" "$FIRST_COMMIT"
    echo "v1.0.0" >> "$DOTFILE"
    echo "Auto-tagged initial version: v1.0.0 (on first commit $FIRST_COMMIT)"
    LATEST_TAG="v1.0.0"
fi

VERSION="${LATEST_TAG#v}"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

git log --reverse --format="%H" "$LATEST_TAG..HEAD" | while read -r COMMIT_HASH; do
    COMMIT_MSG=$(git log -1 --format="%s" "$COMMIT_HASH")
    BUMP_TYPE="none"

    if [[ "$COMMIT_MSG" =~ ^[a-zA-Z]+(\(.*\))?!: ]]; then
        BUMP_TYPE="major"
    elif [[ "$COMMIT_MSG" =~ ^feat(\(.*\))?: ]]; then
        BUMP_TYPE="minor"
    elif [[ "$COMMIT_MSG" =~ ^fix(\(.*\))?: ]]; then
        BUMP_TYPE="patch"
    fi

    if [[ "$BUMP_TYPE" = "none" ]]; then
        continue
    fi

    if [[ "$BUMP_TYPE" = "major" ]]; then
        MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0
    elif [[ "$BUMP_TYPE" = "minor" ]]; then
        MINOR=$((MINOR + 1)); PATCH=0
    else
        PATCH=$((PATCH + 1))
    fi

    NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

    if [ -n "$(git tag -l "$NEW_VERSION")" ]; then
        echo "Skipping tag $NEW_VERSION — already exists." >&2
        continue
    fi

    git tag "$NEW_VERSION" "$COMMIT_HASH"
    echo "$NEW_VERSION" >> "$DOTFILE"
    echo "Auto-tagged new version: $NEW_VERSION (triggered by $BUMP_TYPE on commit $COMMIT_HASH)"
done
