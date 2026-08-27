#!/usr/bin/env bash
input=$(cat)

# Keys are Statuspage component states; "unknown" is the local fallback for
# before the first fetch answers.
STATUS_COMPONENT=${STATUSLINE_STATUS_COMPONENT:-Claude Code}
STATUS_TTL=${STATUSLINE_STATUS_TTL:-120}

declare -A STATUS_SYMBOL=(
  [unknown]="◌"
  [operational]="●"
  [degraded_performance]="●"
  [partial_outage]="●"
  [major_outage]="●"
  [under_maintenance]="●"
)
declare -A STATUS_COLOR=(
  [unknown]=$'\033[38;2;153;153;153m'
  [operational]=$'\033[38;2;78;186;101m'
  [degraded_performance]=$'\033[38;2;232;196;106m'
  [partial_outage]=$'\033[38;2;223;134;102m'
  [major_outage]=$'\033[38;2;255;107;128m'
  [under_maintenance]=$'\033[38;2;102;163;223m'
)

json_block() { grep -oP "\"$2\":\{(?:[^{}]|\{[^{}]*\})*\}" <<<"$1" | head -1; }
json_str()   { grep -oP "\"$2\":\"\K[^\"]*" <<<"$1" | head -1; }
json_num()   { grep -oP "\"$2\":\K[0-9.eE+-]+" <<<"$1" | head -1; }
pct()        { printf '%.0f%%' "$1"; }

# Claude Code redraws this line constantly, so it can never block on the network:
# serve whatever is cached and refresh in the background.
service_status() {
  local dir="${TMPDIR:-/tmp}/claude-statusline"
  local cache="$dir/service-status" lock="$dir/service-status.lock"
  local now age=$STATUS_TTL cached
  mkdir -p "$dir" 2>/dev/null || return
  now=$(date +%s)
  # Touching the lock is the timestamp, so claiming a refresh and recording when it
  # happened is one operation instead of two files that can disagree.
  [[ -f "$lock" ]] && age=$(( now - $(stat -c %Y "$lock" 2>/dev/null || echo 0) ))
  if (( age >= STATUS_TTL )); then
    : > "$lock"
    (
      body=$(curl -fsS --max-time 5 https://status.claude.com/api/v2/summary.json 2>/dev/null) || exit 0
      state=$(grep -oP "\"name\":\"${STATUS_COMPONENT}\",\"status\":\"\K[^\"]+" <<<"$body" | head -1)
      # Write then rename: a redraw racing this must never read a half-written cache.
      [[ -n "$state" ]] && printf '%s' "$state" > "$cache.tmp" && mv -f "$cache.tmp" "$cache"
    ) >/dev/null 2>&1 &
    disown 2>/dev/null
  fi
  cached=$(cat "$cache" 2>/dev/null)
  [[ -n "${STATUS_SYMBOL[$cached]}" ]] && printf '%s' "$cached"
}

model=$(json_str "$(json_block "$input" model)" display_name)

ctx=$(json_block "$input" context_window)
used=$(json_num "$ctx" used_percentage)
size=$(json_num "$ctx" context_window_size)

rl=$(json_block "$input" rate_limits)
rl5h=$(json_num "$(json_block "$rl" five_hour)" used_percentage)
rl7d=$(json_num "$(json_block "$rl" seven_day)" used_percentage)

cost=$(json_num "$(json_block "$input" cost)" total_cost_usd)

DIM=$'\033[2m'
RESET=$'\033[0m'

state=$(service_status)
dot="${STATUS_COLOR[${state:-unknown}]}${STATUS_SYMBOL[${state:-unknown}]}${RESET} "

used_display="--"
[[ -n "$used" ]] && used_display=$(pct "$used")

size_display=""
if [[ -n "$size" ]]; then
  bytes=${size%.*}
  if (( bytes >= 1000000 )); then
    size_display=" of $(( bytes / 1000000 ))M"
  else
    size_display=" of $(( bytes / 1000 ))k"
  fi
fi
core="${used_display}${size_display}"

extra="" extra_dim=""
[[ -n "$rl5h" ]] && extra+=" $(pct "$rl5h") (5h)"
[[ -n "$rl7d" ]] && extra+=" $(pct "$rl7d") (7d)"
[[ -z "$extra" && -n "$cost" ]] && extra=$(printf ' $%.2f' "$cost")
[[ -n "$extra" ]] && extra_dim="${DIM}${extra}${RESET}"

left="using ${model,,}"

avail=0
[[ -n "$COLUMNS" && "$COLUMNS" -gt 0 ]] && avail=$(( COLUMNS - ${STATUSLINE_RESERVE:-4} ))

# Shed detail until the line fits. Widths are measured on the plain variant because
# ${#…} counts the invisible ANSI bytes in the dimmed one; 4 = dot, its space, min gap.
plain=("${core}${extra}" "$core" "$used_display")
shown=("${core}${extra_dim}" "$core" "$used_display")
for i in 0 1 2; do
  right_plain=${plain[i]} right=${shown[i]}
  (( avail <= 0 || ${#left} + 4 + ${#right_plain} <= avail )) && break
done

gap=2
if (( avail > 0 )); then
  gap=$(( avail - ${#left} - 2 - ${#right_plain} ))
  (( gap < 2 )) && gap=2
fi

printf '%s%*s%s%s\n' "$left" "$gap" '' "$dot" "$right"
