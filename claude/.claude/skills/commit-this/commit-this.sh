#!/usr/bin/env bash
# commit-this - gate a repository and write one subject-only conventional commit.
#
#   commit-this.sh --check [--staged]
#       Report repo state. --staged additionally requires a non-empty index and
#       scans the staged diff. Never mutates anything.
#
#   commit-this.sh --commit --message "<subject>" (--index-as-is | --all | --paths <p>...)
#       Re-runs the identical gate, stages per the given intent, re-checks, commits,
#       and verifies what was actually recorded. The gate cannot be skipped.
#
# Vocabulary: INFO / WARN / BLOCK (+FIX) lines, then RESULT: OK|BLOCKED.
# Exit 0 = OK, 1 = BLOCKED (nothing committed), 2 = committed but the recorded
# message does not match what was validated (a hook rewrote it).
set -u

MODE=""
STAGED=0
MSG=""
INTENT=""
PATHS=()
NPATHS=0
blocked=0

say()   { printf '%s\n' "$*"; }
warn()  { say "WARN: $1"; }
block() { blocked=1; say "BLOCK: $1"; say "  FIX: $2"; }
die()   { say "BLOCK: $1"; say "  FIX: $2"; say "RESULT: BLOCKED"; exit 1; }

# ---------------------------------------------------------------- arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --check)       MODE=check ;;
    --commit)      MODE=commit ;;
    --staged)      STAGED=1 ;;
    --message)     shift; [ $# -gt 0 ] || die "--message needs a value" "quote the subject"; MSG="$1" ;;
    --index-as-is) INTENT=index ;;
    --all)         INTENT=all ;;
    --paths)       INTENT=paths; shift; while [ $# -gt 0 ]; do PATHS[$NPATHS]="$1"; NPATHS=$((NPATHS+1)); shift; done; break ;;
    *)             die "unknown argument: $1" "see the usage block at the top of commit-this.sh" ;;
  esac
  shift
done

case "$MODE" in
  check)
    [ -z "$MSG" ]    || die "--message is not valid with --check" "drop it, or use --commit"
    [ -z "$INTENT" ] || die "a staging intent is not valid with --check" "--check never stages"
    ;;
  commit)
    [ -n "$MSG" ] || die "--commit needs --message \"<subject>\"" \
      "commit-this.sh --commit --message 'feat: x' --all"
    [ -n "$INTENT" ] || die "--commit needs a staging intent" \
      "one of --index-as-is (user said 'commit staged changes'), --all ('commit everything'), --paths <p>... (user named files)"
    [ "$INTENT" != paths ] || [ "$NPATHS" -gt 0 ] || \
      die "--paths given with no paths" "list the paths the user named"
    [ "$STAGED" -eq 0 ] || die "--staged is not valid with --commit" "--commit always checks the index itself"
    ;;
  *)
    die "no mode given" "use --check or --commit; see the usage block at the top of commit-this.sh"
    ;;
esac

# ------------------------------------------------------------ message rules
# Locale-independent character count: drop UTF-8 continuation bytes, count the rest.
char_count() { printf '%s' "$1" | LC_ALL=C tr -d '\200-\277' | LC_ALL=C wc -c | tr -d ' '; }

has_emoji() {
  if grep -Pq '' </dev/null 2>/dev/null; then
    printf '%s' "$1" | grep -Pq '[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B00}-\x{2BFF}\x{FE0F}\x{2190}-\x{21FF}\x{203C}\x{2049}]'
  else
    # BSD grep has no -P: match the UTF-8 byte sequences for the same ranges.
    printf '%s' "$1" | LC_ALL=C grep -q \
      -e $'\360\237' -e $'\342\230' -e $'\342\231' -e $'\342\232' -e $'\342\233' \
      -e $'\342\234' -e $'\342\235' -e $'\342\236' -e $'\342\254' -e $'\342\255' -e $'\357\270\217'
  fi
}

validate_message() { # $1 = message, $2 = FIRST_COMMIT (yes|no)
  local m="$1" first="$2" n
  [ -n "$m" ] || { block "empty commit message" "pass a subject"; return; }

  case "$m" in
    *$'\n'*)
      block "commit message spans multiple lines" \
            "this skill writes subject-only commits; compress it into one line"
      return ;;
  esac

  if printf '%s' "$m" | LC_ALL=C grep -q '[[:cntrl:]]'; then
    block "commit message contains a control character" "retype the subject as plain text"
    return
  fi

  case "$m" in
    ' '*|*' ')
      block "commit message has leading or trailing whitespace" \
            "git strips it, leaving a message this script never validated; trim it"
      return ;;
  esac

  if has_emoji "$m"; then
    block "commit message contains an emoji or pictographic character" \
          "remove it; commit subjects are plain text"
    return
  fi

  if [ "$first" = yes ]; then
    [ "$m" = "initial commit" ] || block \
      "this repository has no commits yet, so its first message must be exactly 'initial commit'" \
      "--message 'initial commit'"
  else
    [[ $m =~ ^(feat|fix|docs|style|refactor|test|chore)(\([^()[:space:]]+\))?!?:\ [^[:space:]].*$ ]] || block \
      "message does not match the template: $m" \
      "(feat|fix|docs|style|refactor|test|chore)[(scope)][!]: <subject>  - lowercase type, subject starts with a non-space. Map other types: ci/build -> chore, perf -> refactor, revert -> fix"
  fi

  n=$(char_count "$m")
  [ "$n" -le 50 ] || block "message is $n characters, limit is 50: $m" "shorten the subject"
}

# --------------------------------------------------------------- repo state
git rev-parse --git-dir >/dev/null 2>&1 || \
  die "not inside a git repository" "cd into the repo, or run 'git init' if this is meant to be a new one"

GIT_DIR=$(git rev-parse --git-dir)

[ "$(git rev-parse --is-bare-repository)" = false ] || \
  die "this is a bare repository, it has no working tree and cannot take a commit" \
      "commit in a clone or worktree of it instead"
[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = true ] || \
  die "not inside a working tree" "cd into the repository's working tree"

if git rev-parse --verify -q HEAD >/dev/null 2>&1; then
  FIRST_COMMIT=no
elif [ "$(git rev-list --all --count 2>/dev/null || echo 0)" -eq 0 ]; then
  FIRST_COMMIT=yes    # genuinely empty repository
else
  FIRST_COMMIT=no     # unborn branch (git checkout --orphan) in a repo that already has history
fi

say "INFO: branch=$(git symbolic-ref -q --short HEAD || echo "(detached at $(git rev-parse --short HEAD))")"
say "INFO: first_commit=$FIRST_COMMIT"

counts() {
  say "INFO: staged=$(git diff --cached --name-only | wc -l | tr -d ' ')" \
      "unstaged=$(git diff --name-only | wc -l | tr -d ' ')" \
      "untracked=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')"
}

gate() {
  local eff loc
  # Identity: honours GIT_AUTHOR_*/GIT_COMMITTER_* env vars, config, and auto-detection.
  git var GIT_AUTHOR_IDENT >/dev/null 2>&1 || block \
    "git cannot determine an author identity" \
    "git config --global user.name '<name>' && git config --global user.email '<email>'"
  git var GIT_COMMITTER_IDENT >/dev/null 2>&1 || block \
    "git cannot determine a committer identity" \
    "git config --global user.name '<name>' && git config --global user.email '<email>'"

  [ -z "$(git ls-files -u | head -n 1)" ] || block \
    "unresolved merge conflicts in: $(git -c core.quotePath=false diff --name-only --diff-filter=U | tr '\n' ' ')" \
    "resolve the conflicts, 'git add' each resolved file, then re-run"

  [ ! -e "$GIT_DIR/MERGE_HEAD" ] || block \
    "a merge is in progress" "finish it ('git merge --continue') or abort it ('git merge --abort')"
  [ ! -e "$GIT_DIR/CHERRY_PICK_HEAD" ] || block \
    "a cherry-pick is in progress" "'git cherry-pick --continue' or '--abort'"
  [ ! -e "$GIT_DIR/REVERT_HEAD" ] || block \
    "a revert is in progress" "'git revert --continue' or '--abort'"
  { [ ! -d "$GIT_DIR/rebase-merge" ] && [ ! -d "$GIT_DIR/rebase-apply" ]; } || block \
    "a rebase is in progress" "'git rebase --continue' or '--abort'"
  [ ! -e "$GIT_DIR/BISECT_LOG" ] || block \
    "a bisect is in progress" "'git bisect reset'"
  [ ! -e "$GIT_DIR/index.lock" ] || block \
    "the index is locked ($GIT_DIR/index.lock)" \
    "another git process may be running; if none is, the lock is stale and the user can delete it"

  if [ "$FIRST_COMMIT" = no ] && ! git symbolic-ref -q HEAD >/dev/null; then
    block "detached HEAD at $(git rev-parse --short HEAD), a commit here would be unreachable" \
          "'git switch -c <branch>' to keep the work, or 'git switch <branch>'"
  fi

  eff=$(git config --get core.hooksPath || true)
  loc=$(git config --local --get core.hooksPath || true)
  if [ -n "$eff" ] && [ -z "$loc" ] && \
     [ -n "$(ls "$GIT_DIR/hooks"/pre-commit "$GIT_DIR/hooks"/commit-msg 2>/dev/null)" ]; then
    warn "core.hooksPath=$eff comes from outside this repo, so this repo's own .git/hooks/* will NOT run"
  fi
}

scan_index() {
  local empty_fix f
  case "$INTENT" in
    index) empty_fix="the user asked to commit the staged changes, but nothing is staged; ask them what to stage" ;;
    all)   empty_fix="the working tree is clean, there is nothing to commit" ;;
    paths) empty_fix="the named paths staged nothing - check they exist, are spelled right, and are not gitignored" ;;
    *)     empty_fix="stage the changes the user named ('git add -- <paths>') and re-run" ;;
  esac

  if git diff --cached --quiet; then
    block "nothing is staged, there is no commit to make" "$empty_fix"
    return
  fi

  # Collect the staged paths once, then size them in a SINGLE batched cat-file.
  # One 'git cat-file' per file costs ~35ms on Windows - minutes on a large change set.
  local nf=0 i line sizes
  FILES=()
  while IFS= read -r -d '' f; do
    [ -z "$f" ] && continue
    FILES[$nf]="$f"
    nf=$((nf + 1))
    case "$f" in
      .env|*/.env|.env.*|*/.env.*|*.env|*.pem|*.p12|*.pfx|*.key|*id_rsa*|*.keystore|*credentials.json|*.netrc|*.htpasswd)
        warn "sensitive-looking file staged: $f" ;;
    esac
  done < <(git diff --cached --name-only -z --diff-filter=ACMR)

  if [ "$nf" -gt 0 ]; then
    sizes=$(printf ':%s\0' "${FILES[@]}" | git cat-file --batch-check='%(objectsize)' -z 2>/dev/null)
    i=0
    while IFS= read -r line; do
      case "$line" in
        ''|*[!0-9]*) : ;;   # 'missing' or unreadable (a submodule, say): nothing to size
        *) [ "$line" -gt 5242880 ] && warn "large file staged: ${FILES[$i]} ($((line / 1048576)) MB)" ;;
      esac
      i=$((i + 1))
    done <<< "$sizes"
  fi

  if git diff --cached -U0 | grep -qE -- '-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|xox[baprs]-[A-Za-z0-9-]{10,}'; then
    warn "staged diff contains a credential-shaped string"
  fi
}

# ------------------------------------------------------------------- check
if [ "$MODE" = check ]; then
  counts
  gate
  [ "$STAGED" -eq 1 ] && scan_index
  if [ "$blocked" -eq 1 ]; then say "RESULT: BLOCKED"; exit 1; fi
  say "RESULT: OK"
  exit 0
fi

# ------------------------------------------------------------------ commit
counts
gate
validate_message "$MSG" "$FIRST_COMMIT"
if [ "$blocked" -eq 1 ]; then
  say "RESULT: BLOCKED"
  say "(nothing was staged, nothing was committed)"
  exit 1
fi

case "$INTENT" in
  index) : ;;
  all)   git add -A || die "'git add -A' failed" "read git's error above" ;;
  paths) git add -- "${PATHS[@]}" || die "'git add' rejected the named paths" \
           "read git's message above: usually the path is gitignored (the user must confirm before force-adding) or misspelled" ;;
esac

scan_index
if [ "$blocked" -eq 1 ]; then say "RESULT: BLOCKED"; exit 1; fi

say "INFO: committing $(git diff --cached --name-only | wc -l | tr -d ' ') file(s)"
if ! out=$(git commit -m "$MSG" 2>&1); then
  say "$out"
  die "git commit failed (a hook rejected it, or git errored)" \
      "fix what the output above reports, then re-run; never pass --no-verify"
fi
say "$out"

recorded=$(git log -1 --pretty=%B)
if [ "$recorded" != "$MSG" ]; then
  say "BLOCK: the recorded commit does not match the validated message - something rewrote it"
  say "  validated: [$MSG]"
  git log -1 --pretty=%B | sed 's/^/  recorded:  | /'
  say "  FIX: a commit-msg/prepare-commit-msg hook or a commit.template did this."
  say "       Report it to the user. Do NOT amend - ask whether to keep the commit or fix the hook."
  say "COMMITTED-BUT-INVALID: $(git log -1 --pretty='%h %s')"
  say "RESULT: BLOCKED"
  exit 2
fi

say "COMMITTED: $(git log -1 --pretty='%h %s')"
say "RESULT: OK"
