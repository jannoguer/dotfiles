#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
ALL_MODULES="bash,git,claude,vim,mintty,vscode"

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

Modules: ${ALL_MODULES//,/, }

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

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
CREATED=0 UPDATED=0 UNCHANGED=0 SKIPPED=0 REMOVED=0 KEPT=0
BACKUP_DIR=""
HAS_HISTORY=0

should_sync() {
  [[ -z "$SELECTED" || ",$SELECTED," == *",$1,"* ]]
}

# Sets MOD_SRC and MOD_DST for a module; returns 1 if the module must be skipped.
module_paths() {
  case "$1" in
    bash)
      MOD_SRC="bash/.bashrc"
      MOD_DST="$HOME/.dotfiles.bashrc"
      ;;
    git|claude|vim)
      MOD_SRC="$1"
      MOD_DST="$HOME"
      ;;
    mintty)
      if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
        if [[ -n "$SELECTED" ]]; then
          echo "Skipping mintty: not running on Windows (msys/cygwin)."
        fi
        return 1
      fi
      MOD_SRC="mintty/.minttyrc"
      MOD_DST="$HOME/.minttyrc"
      ;;
    vscode)
      # VSCode stores user config in a platform-specific location, so unlike the
      # other modules its destination is resolved per OS instead of mirroring $HOME.
      local code_dir
      case "$OSTYPE" in
        darwin*)
          code_dir="$HOME/Library/Application Support/Code"
          ;;
        msys|cygwin|win32)
          if [[ -n "${APPDATA:-}" ]]; then
            code_dir="$(cygpath "$APPDATA")/Code"
          else
            code_dir="$HOME/AppData/Roaming/Code"
          fi
          ;;
        *)
          code_dir="${XDG_CONFIG_HOME:-$HOME/.config}/Code"
          ;;
      esac
      MOD_SRC="vscode/User"
      MOD_DST="$code_dir/User"
      ;;
  esac
}

ensure_bashrc_line() {
  if [[ -f "$HOME/.bashrc" ]] && grep -qxF -- "$1" "$HOME/.bashrc"; then
    return
  fi
  # Terminate an unterminated last line so the new one is not glued onto it.
  if [[ -s "$HOME/.bashrc" && -n "$(tail -c1 "$HOME/.bashrc")" ]]; then
    echo >> "$HOME/.bashrc"
  fi
  echo "$1" >> "$HOME/.bashrc"
  if [[ "$VERBOSE" -eq 1 ]]; then
    echo "Added to $HOME/.bashrc: $1"
  fi
}

post_bash() {
  ensure_bashrc_line '[ -f ~/.dotfiles.bashrc ] && source ~/.dotfiles.bashrc'
}

post_claude() {
  if [[ -f "$HOME/.claude/statusline.sh" ]]; then
    chmod +x "$HOME/.claude/statusline.sh"
  fi
  ensure_bashrc_line '[ -f ~/.claude/haiku.bash ] && source ~/.claude/haiku.bash'
}

backup_file() {
  local rel="${1#"$HOME"/}"
  rel="${rel#/}"
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
  fi
  mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
  cp -p "$1" "$BACKUP_DIR/$rel"
}

# Copies a file unless identical; backs up any file it replaces.
sync_file() {
  local src="$1" dst="$2" answer
  if [[ -e "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      UNCHANGED=$((UNCHANGED + 1))
      return
    fi
    if [[ "$OVERWRITE" -eq 0 ]]; then
      # diff exits 1 when files differ; any other non-zero status is a real error.
      diff -u "$dst" "$src" || [[ $? -eq 1 ]]
      # EOF on stdin (no answer possible) counts as "no".
      read -r -p "Overwrite $dst? [y/N] " answer || answer=n
      if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        SKIPPED=$((SKIPPED + 1))
        return
      fi
    fi
    backup_file "$dst"
    UPDATED=$((UPDATED + 1))
  else
    CREATED=$((CREATED + 1))
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  if [[ "$VERBOSE" -eq 1 ]]; then
    echo "Copied $src -> $dst"
  fi
}

sync_tree() {
  local src_dir="$1" dst_dir="$2" src
  # Read from fd 3 so sync_file can still prompt on stdin.
  while IFS= read -r -d '' -u 3 src; do
    sync_file "$src" "$dst_dir/${src#"$src_dir"/}"
  done 3< <(find "$src_dir" -type f -print0)
}

sync_path() {
  if [[ -d "$1" ]]; then
    sync_tree "$1" "$2"
  else
    sync_file "$1" "$2"
  fi
}

# Removes a file and any parent directories it leaves empty, stopping at $HOME.
remove_stale() {
  local dir
  rm "$1"
  dir="$(dirname "$1")"
  while [[ "$dir" == "$HOME"/* && -z "$(ls -A "$dir")" ]]; do
    rmdir "$dir"
    dir="$(dirname "$dir")"
  done
}

# Deletes files deployed from a path that existed in git history but is gone from the
# working tree, only if their content equals a blob committed at that path.
clean_stale() {
  local src_rel="$1" dst_dir="$2" nl=$'\n' tab=$'\t'
  local log tok path dst id ob nb expect_path=0 hist="$nl" paths="$nl"
  # A temp file instead of process substitution so a git failure still aborts under set -e.
  log="$(mktemp)"
  git -C "$DOTFILES_DIR" log --all --no-renames --raw --no-abbrev --format= -z -- "$src_rel" > "$log"
  # Tokens alternate ":<modes> <old blob> <new blob> <status>" and the path.
  while IFS= read -r -d '' tok; do
    [[ -n "$tok" ]] || continue
    if [[ "$expect_path" -eq 0 ]]; then
      [[ "$tok" == :* ]] || continue
      read -r _ _ ob nb _ <<< "$tok"
      expect_path=1
      continue
    fi
    expect_path=0
    path="$tok"
    [[ "$paths" == *"$nl$path$nl"* ]] || paths+="$path$nl"
    for id in "$ob" "$nb"; do
      [[ "$id" =~ ^0+$ ]] || hist+="$path$tab$id$nl"
    done
  done < "$log"
  rm "$log"
  while IFS= read -r path; do
    [[ -n "$path" && ! -f "$DOTFILES_DIR/$path" ]] || continue
    dst="$dst_dir/${path#"$src_rel"/}"
    [[ -f "$dst" ]] || continue
    id="$(git -C "$DOTFILES_DIR" hash-object --no-filters -- "$dst")"
    if [[ "$hist" == *"$nl$path$tab$id$nl"* ]]; then
      remove_stale "$dst"
      echo "Removed stale $dst"
      REMOVED=$((REMOVED + 1))
    else
      echo "Kept modified stale file $dst"
      KEPT=$((KEPT + 1))
    fi
  done <<< "$paths"
}

# -e, not -d: in a worktree .git is a file.
if command -v git >/dev/null && [[ -e "$DOTFILES_DIR/.git" ]]; then
  HAS_HISTORY=1
else
  echo "Skipping stale cleanup: $DOTFILES_DIR is not a git checkout."
fi

echo "Syncing dotfiles from $DOTFILES_DIR to $HOME/..."

for mod in ${ALL_MODULES//,/ }; do
  should_sync "$mod" || continue
  module_paths "$mod" || continue
  echo "Syncing $mod configuration files..."
  sync_path "$DOTFILES_DIR/$MOD_SRC" "$MOD_DST"
  if [[ "$HAS_HISTORY" -eq 1 && -d "$DOTFILES_DIR/$MOD_SRC" ]]; then
    clean_stale "$MOD_SRC" "$MOD_DST"
  fi
  if declare -F "post_$mod" >/dev/null; then
    "post_$mod"
  fi
  echo "$mod configuration sync done!"
done

echo "Done: $CREATED created, $UPDATED updated, $UNCHANGED unchanged, $SKIPPED skipped, $REMOVED removed, $KEPT kept modified."
if [[ -n "$BACKUP_DIR" ]]; then
  echo "Backups: $BACKUP_DIR"
fi
