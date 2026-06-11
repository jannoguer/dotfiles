---
name: iterative-retrieval
description: Run a budgeted multi-cycle search when a first-shot Grep or Glob fails, or when terminology drift between user wording and codebase naming is likely. Curates a file list before handing off to a subagent or downstream task.
---

# Iterative Retrieval

A bounded refinement loop for code search when one shot is not enough. Hard cycle cap, per-cycle ledger, deterministic scoring, contracted handoff output.

## Activation gate

USE when any of these holds:

- A first Grep or Glob returned nothing, too much, or the wrong files, and you need a recovery path that is not ad-hoc thrashing.
- Terminology drift is likely: the user's wording probably differs from codebase naming ("rate limit" vs "throttle", "user" vs "actor").
- You are curating context for a subagent or downstream step and MUST hold the candidate list in your own working memory.

SKIP when the path or symbol is already known, when one Grep is obviously enough, or when you can hand the question to the Explore subagent and accept its synthesis without inspecting it yourself. Invoking this loop for a trivially findable symbol is itself a failure.

## Invariants

These hold in every cycle. Violating any one of them ends the loop as a DEAD END, not as a license to improvise.

- HARD CAP: 3 dispatches total. The counter never resets mid-task; there are no bonus cycles.
- NEVER rerun an identical query. Every dispatch MUST differ from all prior dispatches in keywords or scope. Record each query verbatim in the ledger before running it.
- Escape regex metacharacters in literal search terms (`interface\{\}`, `foo\(bar\)`). Default to case-insensitive matching.
- Evaluate from excerpts only: Grep with `-C 3` or a bounded content window. NEVER full-Read a file during evaluation; that blows context before cycle 3 finishes.
- Overflow guard: if a dispatch returns more than 30 files, do NOT score. The query is over-broad; go straight to Refine with a narrower scope or more specific keyword.
- Score at most 10 hits per cycle, best-first. Unscored hits are not lost; they reappear if a refined query still matches them.
- Pre-exclude generated and vendored noise: lockfiles, `dist`/`build` output, minified bundles, snapshots, vendored deps — unless the target plausibly lives there.
- Low does not become high. An excluded path stays excluded for the rest of the loop.

## The loop

Maintain a ledger, one row per cycle: `cycle | query + scope | hit count | scored hits | named gap`. The ledger is the loop's state; if context is compacted mid-search, the ledger is what survives.

1. **Dispatch.** One Grep or Glob with current keywords and path patterns, logged to the ledger first.
2. **Evaluate.** Score each hit from its excerpt:
   - `high` — the excerpt shows this file implements or defines the target behavior.
   - `medium` — related types, callers, or wiring the target depends on.
   - `low` — shares vocabulary but not behavior. Exclude its path going forward.
   - `drop` — unrelated; discard silently.
   Then name the single most important remaining gap in one sentence, or state "no gap".
3. **Refine.** Add 1-2 keywords harvested from high-hit excerpts, preferring codebase identifiers over user wording. Generate word-shape variants when naming style is unknown (`rateLimit`, `rate_limit`, `rate-limit`). Exclude low-scored paths. Aim the next dispatch at the named gap, nothing else.

Exit on the first condition that fires:

- SUCCESS: 3+ high hits and no named gap.
- CAP: cycle 3 is complete.
- DEAD END: a refined cycle returned zero hits twice in a row, or no refinement differing from prior queries exists.

## Output contract

The consumer of this loop (you, a subagent prompt, a downstream task) gets exactly this:

On SUCCESS — curated list, one line per file: `path — score — one-clause role`. State "no remaining gap".

On CAP or DEAD END — four parts: (a) the partial curated list, (b) the unresolved gap in one sentence, (c) every attempted query verbatim from the ledger so the consumer never repeats them, (d) the pivot recommendation below. Do not present a partial list as complete.

## Pivot protocol

If the cap is hit with a critical gap remaining, the search strategy is wrong — a 4th grep is forbidden. Instead: Read one known entry point (router, main, primary config, package manifest) and trace imports or references outward toward the gap. Hand the ledger to whatever continues the work.

## Examples

### Terminology already matches

Task: "Fix the authentication token expiry bug"

- Cycle 1. `token|auth|expiry` in `src/**`. Hits: `auth.ts` (high), `tokens.ts` (high), `user.ts` (low). Gap: refresh path. Refine: add `refresh`, `jwt`; exclude `user.ts`.
- Cycle 2. Refined search. Hits: `session-manager.ts` (high), `jwt-utils.ts` (high). No gap. SUCCESS.

Output: `auth.ts — high — token validation entry`, `tokens.ts — high — expiry constants`, `session-manager.ts — high — refresh flow`, `jwt-utils.ts — high — decode/sign helpers`. No remaining gap.

### Terminology drift

Task: "Add rate limiting to API endpoints"

- Cycle 1. `rate.?limit|ratelimit` in `routes/**`. Empty. Skim `routes/` listing: codebase says `throttle`. Gap: actual middleware module. Refine: replace keywords with `throttle`, `middleware`.
- Cycle 2. Hits: `throttle.ts` (high), `middleware/index.ts` (medium). Gap: how routes wire middleware. Refine: add `router`.
- Cycle 3. Hits: `router-setup.ts` (high). CAP.

Output: list of the three files with scores and roles, gap "none — wiring located in cycle 3", queries attempted: the three above.

## Mastery notes

- **Cycle 1 is reconnaissance, not retrieval.** Expect to learn vocabulary, not collect final files. If cycle 1 already has the answer, this skill was overkill.
- **1-2 new keywords per refine, not five.** More than that and the next cycle's noise drowns the signal you were trying to learn from.
- **The ledger is cheap insurance.** Five short rows cost almost nothing and make the failure report, the no-repeat rule, and compaction survival all free.
