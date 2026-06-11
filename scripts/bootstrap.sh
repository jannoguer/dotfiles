#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/.."
ALL_MODULES="bash,git,claude,vim,mintty"

usage() {
  cat <<EOF
Usage: $(basename "$0") [-m MODULES] [--overwrite] [-v] [-h]

Syncs dotfiles from this repo into \$HOME.

Options:
  -m, --modules MODULES   Comma-separated list of modules to sync.
                          If omitted, all modules are synced.
      --overwrite         Overwrite existing files without prompting.
  -v, --verbose           Print each file as it is copied.
  -h, --help              Show this help and exit.

Modules: bash, git, claude, vim, mintty

Examples:
  $(basename "$0")
  $(basename "$0") -m git,claude
EOF
}

SELECTED=""
OVERWRITE=0
VERBOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--modules)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; usage >&2; exit 1; }
      SELECTED="$2"
      shift 2
      ;;
    --overwrite)
      OVERWRITE=1
      shift
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -n "$SELECTED" ]]; then
  IFS=',' read -ra REQUESTED <<< "$SELECTED"
  for mod in "${REQUESTED[@]}"; do
    if [[ ",$ALL_MODULES," != *",$mod,"* ]]; then
      echo "Unknown module: $mod (valid: $ALL_MODULES)" >&2
      exit 1
    fi
  done
fi

if [[ "$OVERWRITE" -eq 1 ]]; then
  CP_FLAGS="-rf"
else
  CP_FLAGS="-ri"
fi
if [[ "$VERBOSE" -eq 1 ]]; then
  CP_FLAGS="${CP_FLAGS}v"
fi

should_sync() {
  [[ -z "$SELECTED" || ",$SELECTED," == *",$1,"* ]]
}

echo "Syncing dotfiles from $DOTFILES_DIR to $HOME/..."

if should_sync bash; then
  echo "Syncing bash configuration files..."
  cp $CP_FLAGS "$DOTFILES_DIR/bash/." "$HOME/"
  echo "Bash configuration sync done!"
fi

if should_sync git; then
  echo "Syncing git configuration files..."
  cp $CP_FLAGS "$DOTFILES_DIR/git/." "$HOME/"
  if [[ -d "$HOME/.config/git/hooks" ]]; then
    chmod +x "$HOME/.config/git/hooks"/*
  fi
  echo "Git configuration sync done!"
fi

if should_sync claude; then
  echo "Syncing claude configuration files..."
  cp $CP_FLAGS "$DOTFILES_DIR/claude/." "$HOME/"
  echo "Claude configuration sync done!"
fi

if should_sync vim; then
  echo "Syncing vim configuration files..."
  cp $CP_FLAGS "$DOTFILES_DIR/vim/." "$HOME/"
  echo "Vim configuration sync done!"
fi

if should_sync mintty; then
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Syncing mintty configuration files..."
    cp $CP_FLAGS "$DOTFILES_DIR/mintty/." "$HOME/"
    echo "Mintty configuration sync done!"
  elif [[ -n "$SELECTED" ]]; then
    echo "Skipping mintty: not running on Windows (msys/cygwin)."
  fi
fi

echo "Done!"
