#!/usr/bin/env bash
LC_ALL=C
IFS= read -rd '' input

STATUS_URL=https://status.claude.com/api/v2/summary.json
STATUS_COMPONENT='Claude Code'
STATUS_FILE=${TMPDIR:-/tmp}/claude-statusline-status
STATUS_TTL=30
RESERVE=4

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

# A failed fetch records no status, so the dot goes unknown instead of stale.
fetch_status() {
  local body obj state=''
  if body=$(curl -fs --max-time 5 "$STATUS_URL"); then
    while [[ $body =~ ([{][^{}]*[}])(.*) ]]; do
      obj=${BASH_REMATCH[1]} body=${BASH_REMATCH[2]}
      [[ $obj == *"\"name\":\"$STATUS_COMPONENT\""* ]] && json_str "$obj" status state && break
    done
  fi
  printf '%s %s' "$1" "$state" > "$STATUS_FILE.tmp" && mv -f "$STATUS_FILE.tmp" "$STATUS_FILE"
}

# Runs on every redraw, so it never waits on the network: it serves the
# recorded "<epoch> <status>" and refreshes it in the background once per TTL.
# The epoch is claimed before fetching so concurrent sessions fetch only once.
service_status() {
  local checked=0 cached=''
  [[ -f $STATUS_FILE ]] && read -r checked cached < "$STATUS_FILE"
  [[ $checked =~ ^[0-9]+$ ]] || checked=0
  if (( EPOCHSECONDS - checked >= STATUS_TTL )); then
    printf '%s %s' "$EPOCHSECONDS" "$cached" > "$STATUS_FILE"
    fetch_status "$EPOCHSECONDS" </dev/null >/dev/null 2>&1 &
  fi
  [[ -n $cached && -n ${STATUS_COLOR[$cached]} ]] && printf -v "$1" '%s' "$cached"
}

model='' effort='' used='' size='' rl5h='' rl7d='' cost=''
json_obj "$input" model obj && json_str "$obj" display_name model
json_obj "$input" effort obj && json_str "$obj" level effort
json_obj "$input" context_window obj && {
  json_num "$obj" used_percentage used
  json_num "$obj" context_window_size size
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

used_display=--
[[ -n $used ]] && printf -v used_display '%.0f%%' "$used"

core=$used_display
if [[ -n $size ]]; then
  size=${size%.*}
  if (( size >= 1000000 )); then
    core+=" of $(( size / 1000000 ))M"
  else
    core+=" of $(( size / 1000 ))k"
  fi
fi

extra=''
[[ -n $rl5h ]] && printf -v extra '%s %.0f%% (5h)' "$extra" "$rl5h"
[[ -n $rl7d ]] && printf -v extra '%s %.0f%% (7d)' "$extra" "$rl7d"
[[ -z $extra && -n $cost ]] && printf -v extra ' $%.2f' "$cost"

left="using ${model:-?}${effort:+ on $effort}"
left=${left,,}

avail=0
[[ $COLUMNS =~ ^[0-9]+$ ]] && avail=$(( COLUMNS - RESERVE ))

# Shed detail until the line fits; widths come from the undecorated variant
# because ${#...} counts the invisible ANSI bytes. 2 = dot plus its space.
plain=("$core$extra" "$core" "$used_display")
shown=("$core${extra:+$DIM$extra$RESET}" "$core" "$used_display")
for i in 0 1 2; do
  right=${shown[i]}
  gap=$(( avail - ${#left} - 2 - ${#plain[i]} ))
  (( avail <= 0 || gap >= 2 )) && break
done
(( gap < 2 )) && gap=2

printf '%s%*s%s%s\n' "$left" "$gap" '' "$dot" "$right"
