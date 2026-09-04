## Why the target file is read three times

One read per agent, and all three are structural:

- Reviewer A and Reviewer B each read it in their own isolated context. That
  isolation is the point — it's what makes the two critiques independent. B
  cannot reuse A's read.
- The applicator reads the live file (not the reviewers' quoted snippets)
  because it edits the actual current bytes and verifies each finding against
  them. Trusting a pasted snippet is the hallucination path the "judge, then
  apply" design exists to avoid.

Three is the floor for this design. Cutting below it costs something:

- One reviewer -> 2 reads, but you lose the cross-check.
- Reviewers paste the full file into their logs, applicator reads logs only ->
  still 3 reads total, and now the applicator trusts stale copies. Worse.

## Why reviewers run one tier below the primary

The two reviewers generate candidate findings; the applicator is the only
agent that decides and edits. Recall is cheap to buy with a smaller model run
twice, and a false positive from a reviewer costs nothing because the
applicator verifies every finding against the live file before acting. The
applicator, by contrast, is where a wrong judgment becomes a wrong edit, so it
runs on the same tier as the model the user chose for the session. Net effect:
roughly two-thirds of the pipeline's tokens move to the cheaper tier without
lowering the bar on what actually gets applied.

## Where it bites: large files

Three reads means 3x read tokens. Negligible for a small draft, real for a
2000-line file. Mitigation is scoping, already built in: the skill targets
specific files / the diff, not the whole tree. If a single target file is
itself huge, prefer pointing the skill at the changed hunks rather than the
whole file.
