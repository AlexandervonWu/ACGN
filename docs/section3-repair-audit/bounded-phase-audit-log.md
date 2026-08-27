# Bounded Phase Audit Log

## Authority And Scope

This is a preliminary, finite, DO-178C Level A-inspired assurance log. It is
not a DO-178C certification, a phase ballot, or evidence over an immutable
release. Four independent bounded reviews inspected all 142 implementation,
metric, and global claims that existed before the 12 assurance-process claims
`A-01..A-12` were added. The worktree moved during review, so every result below
is a fault-finding baseline only.

The complete 154-claim statement and proof-process catalog is generated at
[`docs/section3-assurance-claims.md`](../section3-assurance-claims.md). The
finite acceptance criteria for `A-01..A-12` are in
[`do178c-assurance-plan.md`](do178c-assurance-plan.md).

Each review had a 25-minute wall-clock bound, a finite shell-command budget,
no network/theory lookup, read-only repository access, and at least two fresh
falsification passes within its assigned scope. `SATISFIED` means only that the
bounded obligations inspected by that review survived; `GAP` and `REFUTED`
both block a phase.

## Review Census

| Review | IDs | Satisfied | Gap | Refuted | Incomplete | Phase result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| P1 + A2 | 40 | 0 | 40 | 0 | 0 | `FAIL` |
| P2 + P3 | 36 | 5 | 29 | 2 | 0 | `FAIL` |
| P4 + P5 | 27 | 4 | 14 | 9 | 0 | `FAIL` |
| P6 + M + G | 39 | 2 | 28 | 9 | 0 | `FAIL` |
| **Total** | **142** | **11** | **111** | **20** | **0** | **FAIL** |

## Per-Claim Results

### P1 And A2

- `GAP`: `P1-01..P1-20`, `A2-01..A2-20`.
- No requirement was accepted or directly refuted within the bound.
- The principal common gap was absence of a checked Lean-to-Java/wire
  refinement despite substantial passing producer-authored tests.

### P2 And P3

- `SATISFIED`: `P2-01`, `P2-02`, `P2-08`, `P2-11`, `P3-02`.
- `REFUTED`: `P3-01`, `P3-16`.
- `GAP`: `P2-03..P2-07`, `P2-09`, `P2-10`, `P2-12..P2-20`,
  `P3-03..P3-15` except `P3-02`.
- `P3-01` was internally inconsistent about erased columns of statically
  empty relations. Its claim text has since been corrected and its old proof
  mapping invalidated.
- `P3-16` is still `REFUTED`. Fresh bounded review report SHA-256
  `d8949a6320ef75b44c261797f5124093d862a62c62f966e85a404e442f1c44bf`
  found explicit width 0 aliased to omitted width 4 and caller-forgeable
  source authority. Both local defects are repaired: only `-1` defaults and
  explicit zero is preserved,
  parser/module identity owns commands and scoped signatures, source authority
  is package-private, Lean covers zero/ownership/authority, and 31
  parser-backed checks pass. Production defaults, exact options partition,
  cache inventory, export, and independent replay remain blocking.

### P4 And P5

- `SATISFIED`: `P5-01..P5-04`.
- `REFUTED`: `P4-01`, `P5-05..P5-08`, `P5-10..P5-12`, `P5-15`.
- `GAP`: `P4-02..P4-12`, `P5-09`, `P5-13`, `P5-14`.
- `P4-01` omitted the live-owner premise. Its claim text has since been
  narrowed and its old proof mapping invalidated. A later focused review found
  no supported-API counterexample but returned `GAP`: the mapped Lean
  determinism theorem is reflexivity over one input-ordered list, and no
  transition/refinement proof connects that model to every reachable
  quiescent Java observation. The reviewed bytes remain refuted. A later
  moving-worktree repair replaces the list/reflexivity model with extensional
  duplicate/permutation invariance and supported-operation closure; the
  current row is `PARTIAL/PARTIAL` pending fresh review and Java refinement.
- The shared `P5-05..P5-08`, `P5-11`, and `P5-15` falsifier was
  case-insensitive classification of legal user signatures `None` and `Univ`
  as Alloy built-ins. The exact counterexample is repaired on current moving
  bytes, but broader requirements remain open pending structural coverage and
  immutable review.
- `P5-12` failed on `one (A - A)`. Raw rewriting, Fast Rewrite saturation,
  pre-prenex domain analysis, and Lean now cover self-difference; the original
  solver-backed probe reports distance zero to false and no retained binding.
- `P5-10` remains open because command-specific authority records are absent.

### P6, Metric, And Global

- `SATISFIED`: `P6-01`, `M-01`.
- `REFUTED`: `P6-02`, `P6-10`, `M-05`, `G-12`, `G-13`, `G-15..G-18`.
- `GAP`: `P6-03..P6-09`, `P6-11..P6-13`, `M-02..M-04`, `M-06..M-08`,
  `G-01..G-11`, `G-14`.
- `P6-02` and `P6-10` remain open because local symmetry groups retain full
  closure lists despite streaming claims.
- `M-05` was directly refuted by `R(A(X))` versus `R(X)`. Both metric paths
  now share a Zhang-Shasha postorder/leftmost/keyroot implementation. Lean
  proves the ordered-forest recurrence and promotion witnesses, and 49 bounded
  pairs agree with an independent mapping oracle. Structural coverage remains
  open.
- `G-12`, `G-13`, `G-15..G-18` remain open process/provenance/census claims.

## Review Artifact Digests

| Review | Report SHA-256 | Traceability TSV SHA-256 |
| --- | --- | --- |
| P1 + A2 | `138dfa55d78d48c20d112bc766aa9708dc15c74fc057f8234a2eefa8c30cbd45` | `f1ab92540eb8e7c86ccacbf8e2ab862057c8a4046ebaecb63a6f00fa04395209` |
| P2 + P3 | `68b95a9a8d1b4f43126f79fae5ec49aa01cf3d0ab441d4efbf7fe18a1aaec182` | `a22d0445f8976b32709adac21060777c057a95bb2b0f6622be5715c48d0f5ff1` |
| P4 + P5 | `9c9d4fd75bb8e136fc755256885310a294e11a0710605f70f5b5ae4b696d7eb1` | `d28a07bb5049bff4f68155556ebe62c9d45462e5147601ea4f20cb660e8ddf6f` |
| P6 + M + G | `8720e292d8dfe9ad5c68ae70bf4caa2ce215b9fbabce313c78aab4fb45a4050c` | `70a02b359da908ea49658c79b0a40cabdd947aa8ddfdfbbd6a69c15261ff2036` |

The later focused P4-01 review is not a ballot and is not included in the
142-claim census above. Its report SHA-256 is
`ca9b9e84b4210749e5ea448d4c26997947b06499c58bf6667a20fad1466f6f67`.
It used 23 shell-command attempts, reran the 4,207-check state suite and
110-check rebuild suite, compiled the Lean model, and returned `GAP` because
formal determinism and Java transition refinement remain unproved.

The P6/M/G evidence manifest is not admissible assurance evidence: it contains
non-file pseudo-records in `sha256sum` syntax and combines a 142-requirement
runtime with a later 154-row matrix hash. This defect is `GC-F21`. The report's
fault findings remain preliminary leads, not votes.

## Current Gate

`INCOMPLETE`. No phase passes. A repaired counterexample changes only that
counterexample's disposition; it does not retroactively convert the bounded
review or its remaining gaps into a pass. The next admissible review must use
one immutable manifest, execute the nonprotected assurance runner, compile
every mapped Lean declaration without forbidden proof escapes, and bind all
test and review outputs to that same manifest.

The first two executions of the new nonprotected runner, including the
preserved initial runner failure and corrected 42-step `INCOMPLETE` run, are
recorded in [`bounded-assurance-run-log.md`](bounded-assurance-run-log.md).
