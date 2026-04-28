---
name: git-commit-convention
description: Generates concise conventional git commits without AI signatures.
---

# Strict Conventional Commit Generator

## Instructions

When the user asks you to generate or format a git commit message or provides a git diff, you must strictly abide by the following constraints:

- **Required Format:** You must use exactly this structure:
    `(feat|fix|docs|style|refactor|test|chore)[(<scope>)][!]: <subject>`
- **Breaking Changes:** If the change is a breaking change, append an exclamation mark (`!`) immediately before the colon.
- **Strict Length Limit:** The entire commit line MUST be **50 characters or less**. 
- **Subject Rules:** * Use the imperative mood (e.g., "add", not "added" or "adds").
    * Do not capitalize the first letter.
    * Do not end the subject with a period or any punctuation.
- **Scope Rules:** If a scope is used, it must be lowercase and kebab-case (e.g., `user-auth`, not `UserAuth`).
- **Summary Only:** Do not generate a commit body, extended description, or any additional paragraphs.
- **No AI Co-Authoring/Filler:** You must **never** append a `Co-authored-by:` line, an email, or any AI session metadata.

## Examples of Valid Output

> feat(auth): add JWT validation
> fix!: resolve race condition
> docs(readme): update install steps
> chore(deps): bump vite
