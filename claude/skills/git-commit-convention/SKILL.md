---
name: git-commit-convention
description: Use whenever writing, generating, formatting, rewording, or proposing a git commit message, or when given a diff or staged changes to summarize as a commit. Enforces a strict 50-character conventional commit subject with no body and no AI signatures.
---

# git-commit-convention

## When to use

Invoke this skill any time the task involves producing a commit message:

- The user asks for a commit message, asks you to commit, or asks you to reword an existing message.
- The user pastes a diff, `git status`, or staged changes and asks what to write.
- You are about to call `git commit -m "..."` yourself.

Do not invoke for any non-commit git operation.

## Output format

Produce exactly one line, nothing else. No body, no trailing newline of prose, no explanation.

```
<type>[(<scope>)][!]: <subject>
```

- `<type>` is one of: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- `<scope>` names a subsystem or module (`auth`, `api`, `deps`), not a file path. Lowercase kebab-case.
- `!` marks a breaking change: removes or alters a public API, CLI flag, config key, or on-disk format.
- `<subject>` is the change summary.

## Hard rules

1. **Length.** The full line must be 50 characters or fewer.
2. **Imperative mood.** Use "add", not "added" or "adds".
3. **No capitalization.** The subject starts lowercase.
4. **No trailing punctuation.** No period, no ellipsis, no exclamation mark at the end of the subject.
5. **Subject only.** No body, no trailers, no signatures (`Co-authored-by:`, `Signed-off-by:`, "Generated with"), no metadata.
6. **Name what changed.** The subject must name the thing changed, not just the action. `fix: fix bug` and `chore: update stuff` are both forbidden.

## Type tie-breakers

- Prefer user-visible intent (`feat`/`fix`) over mechanical (`refactor`/`chore`).
- New behavior the user asked for is `feat`. Restoring intended behavior is `fix`.

## Procedure

1. Use the diff or summary already in context. Only run `git diff --staged` (or ask the user) if nothing usable is present.
2. Pick the single most accurate type.
3. Decide whether a scope adds clarity. If yes, pick the shortest meaningful kebab-case scope.
4. Draft the subject in the imperative mood, naming what changed.
5. Count characters. The prefix `<type>(<scope>): ` typically consumes 10-15 chars, leaving ~35 for the subject. If over 50, shorten the subject first, then drop the scope, then drop adjectives. Do not truncate mid-word.
6. Emit the single line. Stop.

## Valid examples

```
feat(auth): add JWT validation
fix!: resolve race condition
refactor: extract retry helper
```

## Invalid examples and why

- `Feat(auth): Add JWT validation.` capitalized type and subject, trailing period.
- `feat(auth): added JWT validation` past tense instead of imperative.
- `feat(UserAuth): add JWT validation` scope is not kebab-case.
- `feat: add JWT validation to the authentication middleware layer` exceeds 50 characters.
- `fix: fix bug` vague; subject does not name what changed.
- `feat: add login\n\nCo-authored-by: Claude <noreply@anthropic.com>` signature is forbidden.
