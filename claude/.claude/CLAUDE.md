# Global rules

## Approach
- Before writing code, stop at the first option that works: don't build it > reuse code in the repo > standard library or platform API > an installed dependency > minimal new code. Justify any new dependency in one sentence.
- If a request is ambiguous or a simpler approach exists, say so in one sentence, then proceed with the most reasonable reading. Ask only when the choice is costly to reverse.
- When the user asks a question or wants an assessment, answer and stop. Don't change code.
- Unsure of an API, signature, flag, or config key: read the source, types, or docs. Never guess.

## Code
- Read the callers and tests of any function or type whose behavior you change.
- Every changed line traces to the request: no drive-by refactors, renames, or reformatting. Mention unrelated problems instead of fixing them.
- KISS, DRY, YAGNI: no speculative abstractions, configuration, or handling for impossible cases.
- Fix the root cause once, where it originates, not at each call site.
- Never silence errors: no empty catch, `|| true`, suppression comments, disabled lints, skipped tests, or hardcoded outputs to pass a check. If one is truly needed, ask first.
- Delete what your change made obsolete. No commented-out code, no compatibility shims unless asked.
- Comment only what the code can't say: a non-obvious why, constraint, or workaround, in one line.
- New or changed logic gets a test at a real seam. Mock only boundaries (network, disk, clock).

## Verification
- Say done, fixed, or passing only after running the check in this session and reading its output. Otherwise say "unverified".
- A bug is fixed only when the original symptom is retested.
- Filter long build or test output to the failures or the last ~40 lines; rerun unfiltered only if needed.
- If the same fix fails twice, stop: list what you tried, re-diagnose, then change strategy or ask. Never rerun an identical failing command.

## Output
- No emojis anywhere: chat, code, comments, commits, docs, logs.
- Lead with the outcome. Be brief.
- If anything was skipped or left unverified, say so in the final line.

## Git
- Commit or push only when asked. Conventional Commits, imperative subject of at most 72 characters, one logical change per commit.
- No AI attribution: no Co-Authored-By trailers or "Generated with" lines.
- Never commit secrets, credentials, or .env files; scan the diff first.

## Compaction
Preserve: the original request, modified files, failed approaches, test commands, open questions.
