# Envoirment variables
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL=""


# Aliases
alias c='clear'

alias g='git'
alias gti='git'
alias igt='git'
alias itg='git'
alias tgi='git'


# Functions
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

portal() {
  local f="$HOME/.portals" d
  touch "$f"

  case "$1" in
    ""|list)
      cat "$f" ;;
    set)
      [ -n "$2" ] || { echo "portal: set needs a name" >&2; return 1; }
      d=$(cd "${3:-.}" && pwd) || return 1
      grep -v "^$2 " "$f" > "${f}.tmp"; mv "${f}.tmp" "$f"
      echo "$2 $d" >> "$f" ;;
    go)
      d=$(grep "^$2 " "$f" | cut -d' ' -f2-)
      [ -n "$d" ] || { echo "portal: unknown: $2" >&2; return 1; }
      cd "$d" ;;
    *)
      echo "usage: portal [list] | set NAME [DIR] | go NAME" >&2; return 1 ;;
  esac
}
