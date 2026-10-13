---
name: commit-this
description: Commit changes with a conventional subject-only message, and push only when the user explicitly asks. Use when asked to commit this, commit staged changes, commit current work, commit these files, commit and push, or save work to git. Stages everything by default but narrows at any hint of a specific scope, checks the remote for new commits without pulling, enforces the message template and the 50-char target with a 72-char hard cap, and hard-stops on a repo state that cannot safely take a commit. Never force-pushes. Not for amending, squashing, or writing a message without committing.
---

# Commit This

One invocation, one commit, one line of message. A single script does all the
enforcing: `commit-this.sh` gates the repository, checks the remote, stages what you
tell it to, commits, verifies what was actually recorded, and pushes only when told
to. You decide only *what* to commit, *what to call it*, and whether the user asked
for a push.

## Do not use this skill when

- **The user asked only for a message** ("write me a commit message", "what should
  I call this?"). Produce the message and stop. Do not commit.
- **The user asked to amend, squash, reword, or fix up.** None of those are commits
  this skill can make. Say so and stop.
- **The user asked for a destructive push** (force, force-with-lease, deleting or
  overwriting a remote branch). Say it is destructive, give them the command, and
  let them run it.

## Contract

- Template: `(feat|fix|docs|style|refactor|test|chore)[(<scope>)][!]: <subject>`
- A repository with **no commits at all** takes exactly `initial commit`. Nothing else.
  (An unborn *branch* in a repo that already has history - `git checkout --orphan` -
  is not this case and takes a normal templated message.)
- Target 50 characters or under; hard cap 72. Over 50 warns, over 72 blocks.
  Counted in characters, not bytes.
- Subject only: single line, no body, no trailers, no `Co-Authored-By`, no emoji.
- Never `--no-verify`, never `--amend`.
- Push only through `--push`, and only on an explicit request (see step 4).
  Never `--force`, `--force-with-lease`, `+refspec`, `--delete`, `--mirror`, or
  `--prune`.
- Never `git pull`, `git fetch`, `git merge`, or `git rebase`. The remote check is
  read-only.
- One commit per invocation.

**Type mapping.** The seven types above are the whole list. When the natural
Conventional-Commits type is not one of them, map it and say nothing further:
`ci:` and `build:` -> `chore:`, `perf:` -> `refactor:`, `revert:` -> `fix:`.

## Locate the script

```bash
CT="$HOME/.claude/skills/commit-this/commit-this.sh"
[ -f "$CT" ] || CT="$(git rev-parse --show-toplevel)/.claude/skills/commit-this/commit-this.sh"
[ -f "$CT" ] || { echo "commit-this.sh not found"; }
```

Installed location is `~/.claude/skills/commit-this/commit-this.sh`. A repo that
vendors its own copy under `<repo>/.claude/skills/commit-this/` wins for that repo.
If neither exists, stop and tell the user the skill is not installed.

## Step 1 - resolve what to commit

`--all` is the default: a bare "commit this", "commit it", "commit", or
`/commit-this` with no scope takes `--all`. The user does not have to say "all".

The default gives way to **the slightest hint of a narrower scope**. Any of these
rules out `--all`:

| Hint | Flag |
|---|---|
| "staged", "what I added", "the index" | `--index-as-is` |
| a file, directory, or glob ("commit src/auth.ts", "the docs folder") | `--paths <p>...` |
| a feature, fix, or topic ("commit the parser fix", "the login changes") | `--paths <p>...` with the files that make it up |
| a limiter ("only", "just", "just the", "except", "without", "but not") | `--paths <p>...` |
| the index already holds a subset while other changes are unstaged | ask: the user may have curated it |

When a hint points to something but you cannot map it to exact paths with
confidence, **ask**. Never fall back to `--all` once there is a hint of scope.

If the user names paths, pass exactly those paths. Do not widen them because
something nearby looks related. With `--paths`, read the `INFO: staged/unstaged`
counts afterwards: if the scope left changes behind, mention them.

## Step 2 - look before you commit

```bash
bash "$CT" --check
git status --short
```

`--check` reports state and blocks on anything that makes a commit unsafe. It never
touches the repo. Then stage nothing yet - read `git status --short`, and
`git diff` / `git diff --cached` as needed, to write the message from what actually
changed.

**On `RESULT: BLOCKED`: stop.** Report every `BLOCK:` line with its `FIX:` line to
the user, verbatim, and end the turn. Do not resolve it yourself - no aborting
merges, no resetting, no switching branches, no deleting lock files.

`WARN:` lines never block. Repeat them to the user and carry on.

Both modes check the remote, whether or not the user asked: `git ls-remote` against
the branch's upstream, compared with local history. Nothing is fetched, pulled, or
merged. One line reports the result:

| Line | Meaning |
|---|---|
| `INFO: remote=<r>/<b> has nothing new` | the upstream has no commits HEAD lacks |
| `WARN: behind <r>/<b> by N commit(s)` | already fetched but not merged |
| `WARN: <r>/<b> has commits you do not have locally` | not fetched yet, so the count is unknown |
| `WARN: could not reach remote` / `upstream ... no longer exists` | not checked |
| `INFO: remote=no upstream configured` | new or local-only branch, not checked |

A "behind" warning does not block the commit. Tell the user the remote has new
commits and that pulling is theirs to do. Never pull, fetch, or merge yourself.

## Step 3 - commit

```bash
bash "$CT" --commit --message "feat(auth): add token refresh" --paths src/auth.ts
bash "$CT" --commit --message "fix: handle empty payload"     --all
bash "$CT" --commit --message "initial commit"                --index-as-is
bash "$CT" --commit --message "fix: handle empty payload"     --all --push
```

Flags can come in any order. `--paths` collects arguments up to the next `--flag`.

`--commit` re-runs the **identical** gate from step 2 before it stages anything, so
state that changed since your look is caught here, not missed. Order inside one run:
gate -> validate message -> stage per the intent flag -> re-check the index and scan
it -> commit -> compare the recorded message against the validated one.

Exit codes:

| rc | Meaning | What you do |
|---|---|---|
| 0 | `COMMITTED: <sha> <subject>` | report it, plus any WARN |
| 1 | `RESULT: BLOCKED`, **nothing was committed** | report the BLOCK/FIX lines and stop |
| 2 | `COMMITTED-BUT-INVALID` - the commit exists but a hook rewrote its message | report it and stop; do **not** amend; it was not pushed |
| 3 | `COMMITTED-NOT-PUSHED` - the commit exists but the push failed | report git's push output and stop; do not retry with force |

If it blocks on the message, rewrite the message and re-run. If it blocks because a
pre-commit hook rejected the commit, the hook's own output is printed above the
block - report that and stop. Never work around a hook.

## Step 4 - push, only on an explicit request

Pass `--push` **only** when the user's current message asks for a push in words:
"push", "commit and push", "push it". Nothing else counts:

- "save", "ship it", "sync", "publish", "upload", "send it up" are **not** push
  requests. Commit without `--push`.
- A push approved earlier in the session does not carry over to this commit.
- A remote "behind" warning is never a reason to push, pull, or both.

When unsure, do not push. Commit, then ask.

`--push` runs `git push` when the branch has an upstream. With no upstream and exactly one
remote it runs `git push -u <remote> HEAD`. Any other case blocks before pushing.
It never forces.

**Destructive pushes are the user's to run.** If a push is rejected (non-fast-forward,
diverged history, protected branch) or the user asks for `--force`,
`--force-with-lease`, a `+refspec`, `--delete`, `--mirror`, or `--prune`: do not run
it. Say plainly that it is destructive and what it would overwrite, give the exact
command, and stop. The usual safe fix for a non-fast-forward is to pull first, and
that is theirs to run too.

## If the change spans several concerns

Still one commit, with a subject from the dominant concern - **and say so to the
user**: name the other concern you folded in, so it does not silently disappear
behind a message that does not describe it. If they want it split, that is a new
request and a second invocation.

## Gotchas

- **`--check` is advisory, not a token.** Its OK does not authorise the later
  commit; `--commit` gates itself. Skipping step 2 is not unsafe, it just means you
  write the message without having read the diff.
- **`core.hooksPath` set outside the repo silently disables `.git/hooks/*`.** The
  gate WARNs when it sees local hooks that will be ignored. It does **not** warn for
  husky-style repos: husky sets `core.hooksPath` at the *local* level, and local
  wins, so those hooks do run. Do not "fix" a hooksPath warning by editing the
  user's git config.
- **A `commit-msg` hook can rewrite the message after every check has passed.** That
  is what rc=2 is for: the commit is already in history, so report it and let the
  user decide. Amending is not yours to do.
- **`git add` on a conflicted file marks it resolved**, which is why the gate runs
  before any staging inside `--commit`, not after.
- **The length is the whole subject**, type and scope included, and it is counted in
  characters - accented and CJK subjects are measured the same under any locale.
  Write for 50. `refactor(parser): rewrite the whole tokenizer today` is 51: it
  commits with a WARN, so shorten it if you can. Only 73 and over is rejected.
- **A trailing space is a rejection, not a trim.** Git would strip it, leaving a
  message the script never validated, so the script refuses instead.
- **`--paths` with a path that matches nothing** fails with git's own `fatal:
  pathspec ...` above the block. That usually means a typo or a gitignored file, not
  a staging mistake. A **gitignored** path is the interesting case: git refuses it
  rather than force-adding, and that is correct - only the user can decide to
  `git add -f`, so report it and stop.
- **On Windows, git's `CRLF will be replaced by LF` warnings interleave with the
  script's own output.** They come from git, are harmless, and never affect the
  `BLOCK:`/`RESULT:` lines. Do not relay them as findings.
- **Windows path forms all work** as `--paths` arguments: `src/auth.ts`,
  `src\auth.ts`, an absolute `C:/...` path, and paths containing spaces. Pass them
  as the user wrote them; quote each one.
- **Large change sets are fine.** Sizing is one batched `cat-file`, so a 500-file
  commit gates in about a second. If you ever see it take minutes, the batching
  regressed.

## Troubleshooting

| Output | Meaning | What you do |
|---|---|---|
| `BLOCK: no mode given` / `unknown argument` | malformed call | re-read the usage block at the top of the script |
| `BLOCK: --commit needs a staging intent` | you skipped step 1 | resolve the intent, or ask the user |
| `BLOCK: nothing is staged` | index empty | the `FIX:` line is written for the intent you passed - read it, it says which of the three cases you are in |
| `BLOCK: message does not match the template` | bad type, missing `: `, or a subject starting with a space | rewrite and re-run |
| `BLOCK: this repository has no commits yet...` | empty repo | use exactly `initial commit` |
| `BLOCK: message is N characters` | over the 72 hard cap | shorten; N is characters, so trust it |
| `WARN: message is N characters` | 51-72, over the 50 target | commits anyway; tighten the subject when it reads fine shorter |
| `BLOCK: contains an emoji` / `a control character` / `leading or trailing whitespace` | message is not plain single-line text | retype it |
| `BLOCK: a merge is in progress` / `unresolved merge conflicts` / `a rebase is in progress` | mid-operation | report the FIX line, do **not** run it yourself |
| `BLOCK: detached HEAD` | the commit would be unreachable | report the FIX line and stop |
| `BLOCK: the index is locked` | another git process, or a stale lock | report it; deleting the lock is the user's call |
| `BLOCK: git cannot determine an author identity` | no identity from env, config, or auto-detect | report the FIX line |
| `BLOCK: this is a bare repository` | no working tree | nothing to do here; the user needs a clone or worktree |
| `BLOCK: git commit failed` | a hook rejected it | its output is printed above; report and stop |
| `COMMITTED-BUT-INVALID` (rc=2) | hook rewrote the message post-validation | report; do not amend |
| `COMMITTED-NOT-PUSHED` (rc=3) | push failed or the target was ambiguous | report; a force is the user's call |
| `BLOCK: --push is not valid with --check` | `--check` never pushes | drop it |
| `WARN: sensitive-looking file staged` / `credential-shaped string` | possible secret in the commit | tell the user; with `--push` it is already on the remote |
