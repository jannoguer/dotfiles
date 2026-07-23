---
name: adversarial-review
description: Adversarially review drafted code with two independent reviewer agents, then apply the verified fixes with an applicator agent. Use when asked to adversarial-review, cross-review, critique-and-fix, or harden a draft before commit. Takes file paths as arguments; defaults to uncommitted changes.
---

# Adversarial Review

Pipeline: two reviewer agents critique the same draft independently and write separate logs; an applicator agent then judges every finding against the real code, applies the valid ones, and logs why. You orchestrate; agents do the work.

## Targets

Arguments are file paths to review. No arguments: take modified and untracked files from `git status --porcelain` (skip deletions, lockfiles, generated output). Nothing changed either: stop and ask what to review.

## Run directory

Resolve once per run (Bash tool, works on Windows Git Bash, macOS, Linux):

```bash
root="${TMPDIR:-${TEMP:-/tmp}}"
command -v cygpath >/dev/null && root=$(cygpath -m "$root")
root="$root/adversarial-review"; mkdir -p "$root"
proj=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
run="$root/$proj-$(date +%Y%m%d-%H%M%S)"
printf '%s\n' "$run" > "$root/LATEST"
echo "$run"
```

`$run` is a native path usable by every tool. The three artifacts of a run are `$run-review-a.md`, `$run-review-b.md`, `$run-apply.md`. To find the most recent run from any session or shell: read `<temp>/adversarial-review/LATEST`.

## Step 1 — two reviewers, in parallel

Launch two `general-purpose` agents in one message, `run_in_background: true`. Identical prompts except the output path (a vs b); independence comes from separate contexts. Wait for both to finish before step 2. Prompt for each:

> Adversarially review these files: <absolute paths>. Assume the code is wrong and hunt for proof: correctness bugs, unhandled edge cases, broken contracts, security holes, misleading names, dead or duplicated logic. You are READ-ONLY on the codebase: do not edit, create, or run anything that mutates state. Write your critique to <$run-review-a.md|$run-review-b.md> as a numbered list; per finding: severity (high/medium/low), file:line, one-sentence defect, concrete failure scenario (input/state -> wrong outcome). No praise, no style nitpicks, no summaries of what the code does. If you find nothing, write exactly one line saying so.

## Step 2 — applicator

After both logs exist, launch one `general-purpose` agent synchronously (`run_in_background: false`):

> Read <$run-review-a.md> and <$run-review-b.md>, then the target files: <absolute paths>. For every finding, verify it against the actual code before acting. Apply fixes for valid findings directly to the target files; reject findings that are wrong, speculative, or out of scope. Never suppress errors or weaken types to satisfy a critique. Write <$run-apply.md>: per finding, APPLIED or REJECTED plus a one-line why; end with a 2-3 sentence summary of what changed. Duplicate findings across the two logs count once.

## Report

Tell the user: counts of applied vs rejected findings, the changed files, and the three log paths. Do not paste the full logs.

## Gotchas

- On Windows Git Bash `$TMPDIR` is `/tmp`, which PowerShell and the Read tool cannot open — that is why the snippet converts with `cygpath -m` to a `C:/...` path. Do not skip it.
- Reviewer agents drift into editing if not forbidden explicitly; the READ-ONLY line in the prompt is load-bearing.
- Pass absolute file paths in agent prompts; agents may resolve relative paths against a different working directory.
