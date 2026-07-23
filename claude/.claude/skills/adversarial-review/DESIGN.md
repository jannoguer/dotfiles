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

## Where it bites: large files

Three reads means 3x read tokens. Negligible for a small draft, real for a
2000-line file. Mitigation is scoping, already built in: the skill targets
specific files / the diff, not the whole tree. If a single target file is
itself huge, prefer pointing the skill at the changed hunks rather than the
whole file.
