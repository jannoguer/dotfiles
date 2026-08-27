---
name: commit-this
description: Commit the changes the user named, with a conventional subject-only message. Use when asked to commit this, commit staged changes, commit current work, commit these files, or save work to git. Refuses to guess what to stage, enforces the message template and the 50-char limit, and hard-stops on a repo state that cannot safely take a commit. Not for pushing, amending, squashing, or writing a message without committing.
---

# Commit This

One invocation, one commit, one line of message. A single script does all the
enforcing: `commit-this.sh` gates the repository, stages what you tell it to,
commits, and verifies what was actually recorded. You decide only *what* to commit
and *what to call it*.

## Do not use this skill when

- **The user asked only for a message** ("write me a commit message", "what should
  I call this?"). Produce the message and stop. Do not commit.
- **The user asked to push.** "commit and push" - do the commit half with this
  skill, then tell the user the push is theirs to run. This skill never pushes.
- **The user asked to amend, squash, reword, or fix up.** None of those are commits
  this skill can make. Say so and stop.

## Contract

- Template: `(feat|fix|docs|style|refactor|test|chore)[(<scope>)][!]: <subject>`
- A repository with **no commits at all** takes exactly `initial commit`. Nothing else.
  (An unborn *branch* in a repo that already has history - `git checkout --orphan` -
  is not this case and takes a normal templated message.)
- 50 characters or under, counted in characters, not bytes.
- Subject only: single line, no body, no trailers, no `Co-Authored-By`, no emoji.
- Never `--no-verify`, never `--amend`, never `git push`.
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

## Step 1 - resolve what to commit. Do not assume.

The user has to say which changes. Read their words literally and pick the intent flag:

| They said | Flag | Effect |
|---|---|---|
| "commit staged changes", "commit what I staged" | `--index-as-is` | stages nothing, commits the index as it is |
| "commit current work", "commit everything", "commit all" | `--all` | `git add -A` |
| "commit the parser fix", "commit src/auth.ts", "commit these files" | `--paths <p>...` | stages only those paths |

**"commit this" alone is not one of these rows.** Neither is "commit it", "commit
that", or a bare `/commit-this`. When the phrasing does not clearly pick a row, or
could pick two, **stop and ask which**. Do not fall back to `--all` - it is the row
with the largest blast radius and the weakest evidence behind it.

If the user names paths, pass exactly those paths. Do not widen them because
something nearby looks related.

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

## Step 3 - commit

```bash
bash "$CT" --commit --message "feat(auth): add token refresh" --paths src/auth.ts
bash "$CT" --commit --message "fix: handle empty payload"     --all
bash "$CT" --commit --message "initial commit"                --index-as-is
```

`--commit` re-runs the **identical** gate from step 2 before it stages anything, so
state that changed since your look is caught here, not missed. Order inside one run:
gate -> validate message -> stage per the intent flag -> re-check the index and scan
it -> commit -> compare the recorded message against the validated one.

Exit codes:

| rc | Meaning | What you do |
|---|---|---|
| 0 | `COMMITTED: <sha> <subject>` | report it, plus any WARN |
| 1 | `RESULT: BLOCKED`, **nothing was committed** | report the BLOCK/FIX lines and stop |
| 2 | `COMMITTED-BUT-INVALID` - the commit exists but a hook rewrote its message | report it and stop; do **not** amend |

If it blocks on the message, rewrite the message and re-run. If it blocks because a
pre-commit hook rejected the commit, the hook's own output is printed above the
block - report that and stop. Never work around a hook.

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
- **50 chars is the whole subject**, type and scope included, and it is counted in
  characters - accented and CJK subjects are measured the same under any locale.
  `refactor(parser): rewrite the whole tokenizer today` is 51 and is rejected.
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
| `BLOCK: message is N characters` | over 50 | shorten; N is characters, so trust it |
| `BLOCK: contains an emoji` / `a control character` / `leading or trailing whitespace` | message is not plain single-line text | retype it |
| `BLOCK: a merge is in progress` / `unresolved merge conflicts` / `a rebase is in progress` | mid-operation | report the FIX line, do **not** run it yourself |
| `BLOCK: detached HEAD` | the commit would be unreachable | report the FIX line and stop |
| `BLOCK: the index is locked` | another git process, or a stale lock | report it; deleting the lock is the user's call |
| `BLOCK: git cannot determine an author identity` | no identity from env, config, or auto-detect | report the FIX line |
| `BLOCK: this is a bare repository` | no working tree | nothing to do here; the user needs a clone or worktree |
| `BLOCK: git commit failed` | a hook rejected it | its output is printed above; report and stop |
| `COMMITTED-BUT-INVALID` (rc=2) | hook rewrote the message post-validation | report; do not amend |
| `WARN: sensitive-looking file staged` / `credential-shaped string` | possible secret in the commit | tell the user before they push |
