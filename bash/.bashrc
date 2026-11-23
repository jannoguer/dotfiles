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
