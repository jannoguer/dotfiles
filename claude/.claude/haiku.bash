haiku() {
  claude -p ${1:+"$*"} --model haiku --effort low --no-session-persistence --safe-mode \
    --permission-mode bypassPermissions --tools Bash \
    --system-prompt 'Reply with only the result, as plain text: no preamble, markdown, code fences, or closing offers. Print results; edit files only when asked. If unsure, say "I don'"'"'t know".'
}
