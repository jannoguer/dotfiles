alias c='clear'

alias g='git'
alias gti='git'
alias igt='git'
alias itg='git'
alias tgi='git'

# Auto-fetch when entering a Git repository.
# Test with `ls -l .git/FETCH_HEAD`
#
# Set AUTO_GIT_FETCH_DISABLE to skip.
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
