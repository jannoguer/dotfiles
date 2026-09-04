# Global Directives

## Output
- No emojis anywhere: chat, code, comments, commit messages, docs, UI strings, logs.

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