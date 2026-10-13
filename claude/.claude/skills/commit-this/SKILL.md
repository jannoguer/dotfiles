---
name: commit-this
description: Commit changes with a conventional subject-only message, and push only when the user explicitly asks. Use when asked to commit this, commit staged changes, commit current work, commit these files, commit and push, or save work to git. Stages everything by default but narrows at any hint of a specific scope, checks the remote for new commits without pulling, enforces the message template and the 50-char target with a 72-char hard cap, and hard-stops on a repo state that cannot safely take a commit. Never force-pushes. Not for amending, squashing, or writing a message without committing.
---

# Commit This

`commit-this.sh` does all the enforcing. You decide only what to commit, what to
call it, and whether the user asked for a push.

## Do not use this skill when

- **The user asked only for a message.** Produce it and stop.
- **The user asked to amend, squash, reword, or fix up.** Say this skill cannot and stop.

## Contract

- Template: `(feat|fix|docs|style|refactor|test|chore)[(<scope>)][!]: <subject>`
- A repository with **no commits at all** takes exactly `initial commit`. An orphan
  branch in a repo with history is not this case and takes a templated message.
- Write for 50 characters (not bytes), type and scope included. Over 50 warns, over 72 blocks.
- Subject only: single line, no body, no trailers, no `Co-Authored-By`, no emoji.
- Never `--no-verify`, never `--amend`. Never work around a hook.
- Push only through `--push`, only on an explicit request (step 4).
- Never `git pull`, `fetch`, `merge`, or `rebase`.
- **Destructive pushes are the user's to run**: `--force`, `--force-with-lease`,
  `+refspec`, `--delete`, `--mirror`, `--prune`. Whether the user asked for one or a
  push was rejected, do not run it: say it is destructive and what it would
  overwrite, give the exact command, and stop. The safe fix for a non-fast-forward
  is to pull first, and that is theirs too.
- One commit per invocation.

**Type mapping**, applied silently: `ci:`/`build:` -> `chore:`, `perf:` ->
`refactor:`, `revert:` -> `fix:`.

## Locate the script

```bash
CT="$HOME/.claude/skills/commit-this/commit-this.sh"
[ -f "$CT" ] || CT="$(git rev-parse --show-toplevel)/.claude/skills/commit-this/commit-this.sh"
```

If neither exists, stop and tell the user the skill is not installed.

## Step 1 - resolve what to commit

`--all` is the default: a bare "commit this", "commit", or `/commit-this` takes it.
The user does not have to say "all". **The slightest hint of a narrower scope** rules
it out:

| Hint | Flag |
|---|---|
| "staged", "what I added", "the index" | `--index-as-is` |
| a file, directory, or glob ("commit src/auth.ts", "the docs folder") | `--paths <p>...` |
| a feature, fix, or topic ("commit the parser fix", "the login changes") | `--paths <p>...` with the files that make it up |
| a limiter ("only", "just", "except", "without", "but not") | `--paths <p>...` |
| the index already holds a subset while other changes are unstaged | ask: the user may have curated it |

If you cannot map a hint to exact paths with confidence, **ask**. Never fall back to
`--all` once there is a hint of scope. Pass named paths exactly, without widening
them, quoted, in whatever form the user wrote them (Windows forms work). With
`--paths`, if the `INFO: staged/unstaged` counts show changes left behind, mention them.

## Step 2 - look before you commit

```bash
bash "$CT" --check
git status --short
```

`--check` never touches the repo. Read `git diff` / `git diff --cached` as needed to
write the message from what actually changed.

- **`RESULT: BLOCKED`: stop.** Report every `BLOCK:` line with its `FIX:` line
  verbatim and end the turn. Do not resolve it yourself: no aborting merges,
  resetting, switching branches, deleting lock files, `git add -f` on an ignored
  path, or editing git config (including over a `core.hooksPath` warning).
- **`WARN:` never blocks.** Repeat it to the user and carry on. This includes the
  remote check, which runs every time: being behind the upstream never blocks; tell
  the user, and leave pulling to them.
- Git's `CRLF will be replaced by LF` lines are harmless; do not relay them.

## Step 3 - commit

```bash
bash "$CT" --commit --message "feat(auth): add token refresh" --paths src/auth.ts
bash "$CT" --commit --message "fix: handle empty payload"     --all
bash "$CT" --commit --message "fix: handle empty payload"     --all --push
```

Flags go in any order; `--paths` collects arguments up to the next `--flag`.
`--commit` re-runs the full gate itself, so `--check` is for reading, not a token.

| rc | Output | What you do |
|---|---|---|
| 0 | `COMMITTED: <sha> <subject>` | report it, plus any WARN |
| 1 | `RESULT: BLOCKED`, nothing committed | message problem: rewrite and re-run; anything else: report BLOCK/FIX (and hook output above it) and stop |
| 2 | `COMMITTED-BUT-INVALID`: a hook rewrote the message | report and stop; do not amend; nothing was pushed |
| 3 | `COMMITTED-NOT-PUSHED`: the push failed or its target was ambiguous | report git's output and stop; never retry with force |

Blocks you fix yourself rather than report: `no mode given` or `unknown argument`
(re-read the usage block atop the script), a missing staging intent (go back to
step 1), `--push` with `--check` (drop it), and an empty repo (use `initial commit`).
On `WARN: sensitive-looking file staged` or `credential-shaped string`, tell the
user; with `--push` it is already on the remote.

## Step 4 - push, only on an explicit request

Pass `--push` **only** when the user's current message asks for a push in words:
"push", "commit and push", "push it". Nothing else counts:

- "save", "ship it", "sync", "publish", "upload", "send it up" are **not** push requests.
- A push approved earlier in the session does not carry over.
- A remote "behind" warning is never a reason to push or pull.

When unsure, do not push: commit, then ask. `--push` runs `git push` with an
upstream, `git push -u <remote> HEAD` with none and exactly one remote, and blocks
otherwise.

## If the change spans several concerns

Still one commit, subject from the dominant concern, **and tell the user** which
other concern you folded in. Splitting it is a new request.
