#!/usr/bin/env bash
input=$(cat)

get_block_from() {
  echo "$1" | grep -oP "\"$2\":\{(?:[^{}]|\{[^{}]*\})*\}" | head -1
}
get_str_from() {
  echo "$1" | grep -oP "\"$2\":\"\K[^\"]*" | head -1
}
get_num_from() {
  echo "$1" | grep -oP "\"$2\":\K[0-9.eE+-]+" | head -1
}
fmt_pct() {
  printf '%.0f%%' "$1"
}

model_block=$(get_block_from "$input" model)
model=$(get_str_from "$model_block" display_name)
model="${model,,}"

ctx_block=$(get_block_from "$input" context_window)
pct=$(get_num_from "$ctx_block" used_percentage)
ctx_size=$(get_num_from "$ctx_block" context_window_size)

rl_block=$(get_block_from "$input" rate_limits)
rl5h=$(get_num_from "$(get_block_from "$rl_block" five_hour)" used_percentage)
rl7d=$(get_num_from "$(get_block_from "$rl_block" seven_day)" used_percentage)

cost_block=$(get_block_from "$input" cost)
cost_usd=$(get_num_from "$cost_block" total_cost_usd)

DIM=$'\033[2m'
RESET=$'\033[0m'

pct_display="--"
[[ -n "$pct" ]] && pct_display=$(fmt_pct "$pct")

ctx_size_display=""
if [[ -n "$ctx_size" ]]; then
  size_int=${ctx_size%.*}
  if [[ "$size_int" -ge 1000000 ]]; then
    ctx_size_display=" of $((size_int / 1000000))M"
  else
    ctx_size_display=" of $((size_int / 1000))k"
  fi
fi

left="using $model"

rl_text=""
[[ -n "$rl5h" ]] && rl_text="$rl_text $(fmt_pct "$rl5h") (5h)"
[[ -n "$rl7d" ]] && rl_text="$rl_text $(fmt_pct "$rl7d") (7d)"

if [[ -z "$rl_text" && -n "$cost_usd" ]]; then
  rl_text=$(printf ' $%.2f' "$cost_usd")
fi

core="${pct_display}${ctx_size_display}"

reserve=${STATUSLINE_RESERVE:-4}
avail=0
[[ -n "$COLUMNS" && "$COLUMNS" -gt 0 ]] && avail=$(( COLUMNS - reserve ))

right_plain="${core}${rl_text}"
right_colored="${core}${DIM}${rl_text}${RESET}"
[[ -z "$rl_text" ]] && right_colored="$core"

fits() {
  [[ "$avail" -le 0 ]] || (( ${#left} + 2 + ${#1} <= avail ))
}

if ! fits "$right_plain"; then
  right_plain="$core"
  right_colored="$core"
fi
if ! fits "$right_plain"; then
  right_plain="$pct_display"
  right_colored="$pct_display"
fi

gap=2
if [[ "$avail" -gt 0 ]]; then
  pad=$(( avail - ${#left} - ${#right_plain} ))
  [[ "$pad" -lt 2 ]] && pad=2
  gap=$pad
fi

printf '%s%*s%s\n' "$left" "$gap" '' "$right_colored"
