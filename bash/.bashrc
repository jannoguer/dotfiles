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
          echo "Error: $1 requires a file argument." >&2
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
    age -d "${age_args[@]}" | gzip -d > "$output"
  else
    age -d "${age_args[@]}" | gzip -d
  fi
}
