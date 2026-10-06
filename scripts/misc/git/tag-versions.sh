#!/bin/sh
# tag the releases of the checked-out branch as vX.Y.Z,
# following Semantic Versioning 2.0.0 (https://semver.org).
#
# Bump per commit (Conventional Commits):
#   first commit                        -> v0.1.0     (semver FAQ)
#   "type!: ..." or "type(scope)!: ..." -> major bump  (X+1.0.0)   rule 8
#   "BREAKING CHANGE:" footer in body   -> major bump  (X+1.0.0)   rule 8
#   "feat: ..."  or "feat(scope): ..."  -> minor bump  (X.Y+1.0)   rule 7
#   "fix: ..."   or "perf: ..."         -> patch bump  (X.Y.Z+1)   rule 6
#   anything else (docs, chore, refactor, test, ...) -> no bump, no tag
# While the major is 0 (initial development, semver rule 4) anything may
# change, so a breaking commit bumps the minor instead. Releasing 1.0.0 is a
# decision (rule 5): tag it by hand, e.g. "git tag v1.0.0 <sha>", and rerun.
#
# Existing vX.Y.Z tags are kept and numbering continues from them, so the
# script is safe to rerun after new commits.
#
# Usage: tag-versions.sh [--force] [repo-dir]
#   Refuses to run unless the checked-out branch is main or master;
#   --force skips that check.
set -eu
force=0
if [ "${1:-}" = --force ]; then
  force=1
  shift
fi
cd "${1:-.}"

branch=$(git rev-parse --abbrev-ref HEAD)
case $branch in
  main | master) ;;
  *)
    if [ $force = 0 ]; then
      echo "refusing: on branch '$branch', not main/master (use --force)" >&2
      exit 1
    fi
    ;;
esac

breaking=$(git log --format=%H --grep='^BREAKING[ -]CHANGE:' HEAD)
cmds=$(
  git log --reverse --topo-order --decorate-refs='refs/tags/v[0-9]*.[0-9]*.[0-9]*' \
    --format='%H|%D|%s' HEAD |
    awk -F'|' -v x=0 -v y=0 -v z=0 -v breaking="$breaking" '{
      if ($2 ~ /^tag: v/) { # already tagged: continue numbering from it
        split(substr($2, 7), n, /[^0-9]/); x = n[1]; y = n[2]; z = n[3]; next
      }
      if (x + y + z == 0) y = 1 # first commit
      else if ($3 ~ /^[a-z]+(\([^)]*\))?!: / || index(breaking, $1)) {
        if (x == 0) y++; else { x++; y = 0 }
        z = 0
      }
      else if ($3 ~ /^feat(\([^)]*\))?: /) { y++; z = 0 }
      else if ($3 ~ /^(fix|perf)(\([^)]*\))?: /) z++
      else next
      print "create refs/tags/v" x "." y "." z " " $1
    }'
)

if [ -z "$cmds" ]; then
  echo "nothing new to tag"
else
  printf '%s\n' "$cmds" | git update-ref --stdin
  last=${cmds##*refs/tags/}
  echo "tagged up to ${last%% *}"
fi
