---
name: iterative-retrieval
description: Run a budgeted multi-cycle search when a first-shot Grep or Glob fails, or when terminology drift between user wording and codebase naming is likely. Curates a file list before handing off to a subagent or downstream task.
---

# Iterative Retrieval

A bounded refinement loop for code search when one shot is not enough. Hard cycle cap, explicit gap tracking, curated output.

## When to use

- A first Grep returned nothing, too much, or the wrong files, and you need a recovery path that is not ad-hoc thrashing.
- Terminology drift is likely: the user's wording probably differs from codebase naming ("rate limit" vs "throttle", "user" vs "actor").
- You need a retrieval budget. A 3-cycle cap forces a result or an escalation, never indefinite grepping.
- You are curating context for a subagent or downstream step and need the candidate list in your own working memory.

Skip when the path or symbol is already known, when one Grep is obviously enough, or when you can hand the question to the Explore subagent and accept its synthesis without inspecting it yourself.

## The loop

Hard cap: 3 cycles.

1. **Dispatch.** One Grep or Glob with current keywords and path patterns.
2. **Evaluate.** Score each hit from an excerpt: high (directly implements the target), medium (related types or callers), low (tangential), drop (unrelated). Name the gap that remains, or state there is none.
3. **Refine.** Add 1-2 keywords from high hits, preferring codebase terminology. Exclude paths scored low. Aim the next dispatch at the named gap.

Exit when you have 3+ high-relevance hits and no remaining gap, or after cycle 3. Return the curated list.

## Examples

### Terminology already matches

Task: "Fix the authentication token expiry bug"

- Cycle 1. `token|auth|expiry` in `src/**`. Hits: `auth.ts` (high), `tokens.ts` (high), `user.ts` (low). Gap: refresh path. Refine: add `refresh`, `jwt`; exclude `user.ts`.
- Cycle 2. Refined search. Hits: `session-manager.ts` (high), `jwt-utils.ts` (high). No gap. Exit.

Result: `auth.ts`, `tokens.ts`, `session-manager.ts`, `jwt-utils.ts`.

### Terminology drift

Task: "Add rate limiting to API endpoints"

- Cycle 1. `rate|limit|api` in `routes/**`. Empty. Skim `routes/` listing: codebase says `throttle`. Gap: actual middleware module. Refine: replace keywords with `throttle`, `middleware`.
- Cycle 2. Hits: `throttle.ts` (high), `middleware/index.ts` (medium). Gap: how routes wire middleware. Refine: add `router`.
- Cycle 3. Hits: `router-setup.ts` (high). Cap reached. Exit.

Result: `throttle.ts`, `middleware/index.ts`, `router-setup.ts`.

## Mastery notes

- **Cycle 1 is reconnaissance, not retrieval.** Expect to learn vocabulary, not collect final files. If cycle 1 already has the answer, this skill was overkill.
- **Excerpts, not Reads.** Use Grep `-C 3` or a 30-line window. A full Read during evaluation blows context before cycle 3 finishes.
- **1-2 new keywords per refine, not five.** More than that and the next cycle's noise drowns the signal you were trying to learn from.
- **Low does not become high.** An excluded path stays excluded; do not revisit it later in the loop.
- **3 cycles is a contract.** If cycle 3 still has critical gaps, the search strategy is wrong. Pivot: read a known entry point (router, main, primary config, package manifest) and trace outward from there.
