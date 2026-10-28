haiku() {
  claude -p ${1:+"$*"} --model haiku --effort low --no-session-persistence --safe-mode \
    --system-prompt "Directly output the result in the prompt's language without filler."
}
