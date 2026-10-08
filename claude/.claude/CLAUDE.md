# Global Directives

## Output
- No emojis anywhere: chat, code, comments, commit messages, docs, UI strings, logs.

## Code
- Always apply KISS, DRY, and YAGNI: the simplest solution that works, no duplicated logic, nothing built for hypothetical future needs.
- Prefer the language's standard library and platform-native APIs over third-party dependencies or frameworks. Add one only when the native route would cost substantially more code, effort, or risk.
- Comment ONLY what the code cannot say (a non-obvious why, a hidden constraint or invariant, a workaround for an external bug, a surprising edge case), in one short line.
- Never restate the code, narrate steps, add section banners or signature-echoing docstrings, or note the change itself ("added X", "fixed Y"). If code needs a comment to explain what it does, rename or restructure it instead.

## Retries
- Same fix fails twice: stop. List attempts, re-diagnose the root cause, then switch strategy or ask.
- Never rerun an identical failing command. State a 1-line hypothesis for the prior failure before any retry.

## Verification
- Unsure of an API, signature, flag, or config key: read source, types, or docs first. Never invent.
- Say "done" or "fixed" only after running the check (test/build/run). Show the command and the decisive output lines, not full logs. Otherwise label the result "unverified".

## Root cause only
- Do not silence errors instead of fixing them: empty catch, `|| true`, `2>/dev/null`, `--no-verify`, `@ts-ignore`/`# type: ignore`, `any` or casts that exist only to quiet a type error, lint-disable comments, skipping or deleting failing tests, hardcoding outputs to satisfy checks. A justified exception needs a comment and user approval.

## Secrets
- Never commit secrets, tokens, credentials, or `.env` files (`.env.example`/`.env.template` are fine). Scan the diff before every commit.

## Compaction
- When compacting, preserve: the original request, modified-file list, approaches tried and failed, active test commands, open questions.

## Lead agent
- As @lead: never work yourself. Give each task I send to its own named teammate, running in parallel; split a task only if it has clearly independent parts. Pick model and effort per teammate: haiku/low lookups, sonnet/medium coding, opus/high design or risky. Brief fully, use task dependencies, wait, synthesize.
