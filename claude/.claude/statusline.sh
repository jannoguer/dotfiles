#!/usr/bin/env bash
LC_ALL=C
IFS= read -rd '' input

STATUS_URL=https://status.claude.com/api/v2/summary.json
STATUS_COMPONENT=${STATUSLINE_STATUS_COMPONENT:-Claude Code}
STATUS_TTL=${STATUSLINE_STATUS_TTL:-120}
RESERVE=${STATUSLINE_RESERVE:-4}

DIM=$'\033[2m'
RESET=$'\033[0m'
declare -A STATUS_COLOR=(
  [unknown]=$'\033[38;2;153;153;153m'
  [operational]=$'\033[38;2;78;186;101m'
  [degraded_performance]=$'\033[38;2;232;196;106m'
  [partial_outage]=$'\033[38;2;223;134;102m'
  [major_outage]=$'\033[38;2;255;107;128m'
  [under_maintenance]=$'\033[38;2;102;163;223m'
)

# A JSON object nested up to two levels deep; bash ERE has no recursion.
OBJ='[{]([^{}]|[{]([^{}]|[{][^{}]*[}])*[}])*[}]'
SEP='[[:space:]]*:[[:space:]]*'

json_obj() { [[ $1 =~ \"$2\"$SEP($OBJ) ]] && printf -v "$3" '%s' "${BASH_REMATCH[1]}"; }
json_str() { [[ $1 =~ \"$2\"$SEP\"([^\"]*)\" ]] && printf -v "$3" '%s' "${BASH_REMATCH[1]}"; }
json_num() { [[ $1 =~ \"$2\"$SEP(-?[0-9]+(\.[0-9]+)?) ]] && printf -v "$3" '%s' "${BASH_REMATCH[1]}"; }

fetch_status() {
  local cache=$1 body obj
  body=$(curl -fsS --max-time 5 "$STATUS_URL") || return
  while [[ $body =~ ([{][^{}]*[}])(.*) ]]; do
    obj=${BASH_REMATCH[1]} body=${BASH_REMATCH[2]}
    [[ $obj == *"\"name\":\"$STATUS_COMPONENT\""* ]] || continue
    json_str "$obj" status obj || return
    printf '%s' "$obj" > "$cache.tmp" && mv -f "$cache.tmp" "$cache"
    return
  done
}

# Runs on every redraw, so it never waits on the network: it serves the cached
# state and refreshes in the background once per TTL. The lock holds the epoch
# of the last refresh attempt.
service_status() {
  local dir="${TMPDIR:-/tmp}/claude-statusline" cache lock claimed=0 cached=""
  cache="$dir/service-status" lock="$cache.lock"
  [[ -d $dir ]] || mkdir -p "$dir" || return
  [[ -f $lock ]] && read -r claimed < "$lock"
  [[ $claimed =~ ^[0-9]+$ ]] || claimed=0
  if (( EPOCHSECONDS - claimed >= STATUS_TTL )); then
    printf '%s' "$EPOCHSECONDS" > "$lock"
    fetch_status "$cache" </dev/null >/dev/null 2>&1 &
  fi
  [[ -f $cache ]] && read -r cached < "$cache"
  [[ -n $cached && -n ${STATUS_COLOR[$cached]} ]] && printf -v "$1" '%s' "$cached"
}

model='' used='' size='' rl5h='' rl7d='' cost='' obj='' ctx='' rl=''
json_obj "$input" model obj && json_str "$obj" display_name model
json_obj "$input" context_window ctx && {
  json_num "$ctx" used_percentage used
  json_num "$ctx" context_window_size size
}
json_obj "$input" rate_limits rl && {
  json_obj "$rl" five_hour obj && json_num "$obj" used_percentage rl5h
  json_obj "$rl" seven_day obj && json_num "$obj" used_percentage rl7d
}
json_obj "$input" cost obj && json_num "$obj" total_cost_usd cost

state=unknown symbol='●'
service_status state
[[ $state == unknown ]] && symbol='◌'
dot="${STATUS_COLOR[$state]}$symbol$RESET "

used_display="--"
[[ -n $used ]] && printf -v used_display '%.0f%%' "$used"

size_display=""
if [[ -n $size ]]; then
  size=${size%.*}
  if (( size >= 1000000 )); then
    size_display=" of $(( size / 1000000 ))M"
  else
    size_display=" of $(( size / 1000 ))k"
  fi
fi
core="$used_display$size_display"

extra=""
[[ -n $rl5h ]] && printf -v extra '%s %.0f%% (5h)' "$extra" "$rl5h"
[[ -n $rl7d ]] && printf -v extra '%s %.0f%% (7d)' "$extra" "$rl7d"
[[ -z $extra && -n $cost ]] && printf -v extra ' $%.2f' "$cost"

left="using ${model:-?}"
left=${left,,}

avail=0
[[ $COLUMNS =~ ^[0-9]+$ ]] && avail=$(( COLUMNS - RESERVE ))

# Shed detail until the line fits; widths come from the undecorated variant
# because ${#...} counts the invisible ANSI bytes. 2 = dot plus its space.
plain=("$core$extra" "$core" "$used_display")
shown=("$core${extra:+$DIM$extra$RESET}" "$core" "$used_display")
for i in 0 1 2; do
  right_plain=${plain[i]} right=${shown[i]}
  gap=$(( avail - ${#left} - 2 - ${#right_plain} ))
  (( avail <= 0 || gap >= 2 )) && break
done
(( gap < 2 )) && gap=2

printf '%s%*s%s%s\n' "$left" "$gap" '' "$dot" "$right"
