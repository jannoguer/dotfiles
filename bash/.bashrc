alias c='clear'

alias g='git'
alias gti='git'
alias igt='git'
alias itg='git'
alias tgi='git'

__auto_git_fetch() {
    [ -n "$AUTO_GIT_FETCH_DISABLE" ] && return

    if [ "$PWD" = "$__AUTO_GIT_FETCH_LAST_DIR" ]; then
        return
    fi
    __AUTO_GIT_FETCH_LAST_DIR="$PWD"

    local toplevel
    toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return

    if [ "$toplevel" = "$__AUTO_GIT_FETCH_LAST_REPO" ]; then
        return
    fi
    __AUTO_GIT_FETCH_LAST_REPO="$toplevel"

    [ -n "$(git -C "$toplevel" remote 2>/dev/null)" ] || return
    (
        GIT_TERMINAL_PROMPT=0 \
        GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh} -oBatchMode=yes -oConnectTimeout=5" \
        git -C "$toplevel" \
            -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=10 \
            fetch --all --quiet 2>/dev/null &
    )
}

case ";${PROMPT_COMMAND:-};" in
    *";__auto_git_fetch;"*) ;;
    *) PROMPT_COMMAND="__auto_git_fetch;${PROMPT_COMMAND:-}" ;;
esac

whisper() {
  gzip -9 | age -e "$@"
}

yell() {
  local output=""
  local age_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -o|--output)
        if [[ -z "$2" ]]; then
          echo "yell: error: $1 requires a file argument." >&2
          return 1
        fi
        output="$2"
        shift 2
        ;;
      -o=*|--output=*)
        output="${1#*=}" 
        shift 1
        ;;
      *)
        age_args+=("$1")
        shift 1
        ;;
    esac
  done

  if [[ -n "$output" ]]; then
    age -d "${age_args[@]}" | gzip -d > "$output" || { rm -f "$output"; return 1; }
  else
    age -d "${age_args[@]}" | gzip -d
  fi
}

portal() {
  local f="$HOME/.portals" d
  touch "$f"

  if [ "$1" = "set" ]; then
    [ -n "$2" ] || { echo "portal: set needs a name" >&2; return 1; }
    grep -v "^$2 " "$f" > "${f}.tmp" 2>/dev/null || true
    mv "${f}.tmp" "$f" 2>/dev/null || true
    echo "$2 $(pwd)" >> "$f"
  elif [ "$1" = "go" ]; then
    d=$(grep "^$2 " "$f" | cut -d' ' -f2-)
    [ -n "$d" ] || { echo "portal: unknown: $2" >&2; return 1; }
    cd "$d"
  elif [ "$1" = "list" ]; then
    cat "$f"
  fi
}

up() {
  local p c i
  if [ -z "$1" ]; then
    cd ..
  elif [[ "$1" =~ ^[0-9]+$ ]]; then
    p=""
    for ((i=0; i<$1; i++)); do
      p="../$p"
    done
    cd "${p:-.}"
  else
    c="${PWD%/*}"
    while [ -n "$c" ]; do
      if [ "${c##*/}" = "$1" ]; then
        cd "$c"
        return
      fi
      c="${c%/*}"
    done
    echo "up: no ancestor: $1" >&2
    return 1
  fi
}

scribe() {
  local note_file="$HOME/.scribe.md"
  local today

  if [ $# -eq 0 ]; then
    if [ -f "$note_file" ]; then
      cat "$note_file"
    else
      echo "scribe: No notes taken yet. Write one using: scribe <your note>" >&2
    fi
    return
  fi

  today=$(date '+%Y-%m-%d')
  if ! grep -qx "## $today" "$note_file" 2>/dev/null; then
    [ -s "$note_file" ] && echo >> "$note_file"
    echo "## $today" >> "$note_file"
  fi
  echo "- $*" >> "$note_file"
}
