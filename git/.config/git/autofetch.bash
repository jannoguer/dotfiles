__auto_git_fetch() {
    local rc=$? toplevel  # keep $? intact for later PROMPT_COMMAND entries and PS1

    if [ -z "${AUTO_GIT_FETCH_DISABLE:-}" ] && [ "$PWD" != "${__AUTO_GIT_FETCH_LAST_DIR:-}" ]; then
        __AUTO_GIT_FETCH_LAST_DIR=$PWD
        toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$toplevel" ] && [ "$toplevel" != "${__AUTO_GIT_FETCH_LAST_REPO:-}" ]; then
            __AUTO_GIT_FETCH_LAST_REPO=$toplevel
            # GIT_SSH_COMMAND overrides core.sshCommand, so carry it over
            (
                {
                    ssh=${GIT_SSH_COMMAND:-$(git -C "$toplevel" config core.sshCommand)}
                    GIT_TERMINAL_PROMPT=0 \
                    GIT_SSH_COMMAND="${ssh:-ssh} -oBatchMode=yes -oConnectTimeout=5" \
                    git -C "$toplevel" \
                        -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=10 \
                        fetch --all --prune --quiet --jobs=4 --no-write-fetch-head \
                        >/dev/null 2>&1
                } &
            )
        fi
    fi

    return "$rc"
}

case ";${PROMPT_COMMAND:-};" in
    *";__auto_git_fetch;"*) ;;
    *) PROMPT_COMMAND="__auto_git_fetch;${PROMPT_COMMAND:-}" ;;
esac
