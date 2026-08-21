# Focused Bounded Adversarial Reviews

This record preserves finite falsification results produced while the worktree
was moving. It is not a phase ballot and cannot authorize `PASS`. Each result
must be rerun against one immutable input manifest before it can become
assurance evidence.

## P3-16 Source-Command Semantic Profile

- Verdict: `REFUTED`
- Temporary full report: `/tmp/acgn-p3-16-review/report.md`
- Report SHA-256:
  `d8949a6320ef75b44c261797f5124093d862a62c62f966e85a404e442f1c44bf`
- Located counterexamples: explicit Alloy width zero was aliased to omitted
  width/default four; a caller could forge source authority with a public
  structural key; production defaults bypassed source selection; the
  standalone verifier admitted only fixed profile constants; and the abstract
  Lean model did not match Java authority construction.
- Current moving-byte repair evidence: explicit zero is preserved; only `-1`
  defaults to four; selected commands and scoped signatures require parser
  object identity in one parsed module; source authority is package-private;
  31 parser-backed Java checks and the revised Lean file pass.
- Open blockers: production default call sites, a proved complete partition of
  semantic `A4Options`, cache-key inventory, export propagation, and
  standalone source-profile replay.
- Traceability disposition: `PROVED/REFUTED/INCOMPLETE`. The abstract formal
  selector obligations compile, but direct production conformance is refuted.

## P4-01 Quiescent Collision Buckets

- Verdict: `GAP`
- Temporary full report: `/tmp/acgn-p4-01-review/report.md`
- Report SHA-256:
  `ca9b9e84b4210749e5ea448d4c26997947b06499c58bf6667a20fad1466f6f67`
- Bounded results: `TheoryStateTest` passed 4,207 checks;
  `TheoryRebuildTest` passed 110 checks; the Lean file compiled; a concurrent
  probe observed 29 valid snapshots and 15,971 dirty-state rejections with
  zero malformed successful snapshots. No supported-API counterexample was
  found.
- Blocking formal defect: `live_owner_bucket_is_deterministic` is reflexivity
  over one duplicate-preserving, input-ordered `List`, not an extensional
  finite-set/permutation theorem. The model omits quiescence, union,
  restriction, rebuild, stale-owner removal, and Java refinement.
- Trust-boundary probe: reflection-only private-state corruption can leave the
  status `QUIESCENT`; a public snapshot then trusts that status while
  `checkInvariants()` rejects. Reflection is outside the supported API, so this
  is not a supported behavioral counterexample. It demonstrates that the
  encapsulation and reachable-state assumptions must be explicit and that
  transition preservation cannot be omitted.
- Open blockers: extensional finite-set and permutation/duplicate proof;
  reachable transition system; Java abstraction/refinement relation; failed
  mutator-exit coverage; structural coverage; immutable-manifest rerun.
- Reviewed-byte disposition: `REFUTED/PARTIAL/INCOMPLETE`. After this review,
  the moving worktree replaced the list/reflexivity model with extensional
  duplicate/permutation invariance plus supported mutation/rebuild/public
  observation closure. That candidate repair is `PARTIAL/PARTIAL` until a
  fresh independent review and Java refinement evidence succeed; the original
  review is not retroactively changed.

## Review Rule

Any one `REFUTED`, `GAP`, exhausted bound, unresolved assumption, or manifest
mismatch blocks the associated claim and phase. A later local repair closes
only the reproduced counterexample; it does not convert either review into a
`PASS`.

## Phase 4 Exact Hash-Rebuild Mutation Review

- Verdict: `FAIL`; not a phase ballot.
- Temporary report: `/tmp/acgn-phase4-replacement-review-20260821.md`.
- Report SHA-256:
  `b8146b875cb4ba0850446db6d0ccd01bdc6e31df12a7a4ceaf43c3223b1e7cbf`.
- Passed boundary: 18,015 producer checks, 134 standalone-verifier checks,
  three Phase 4 Lean modules, exact traceability anchors, and the schema-v8
  writer/replay harness.
- Decisive counterexample: replacing `rebuildHashConsExactly()` with only its
  diagnostic counter increment survived all 115 rebuild checks and the full
  producer set. The tests observed invocation, not reconstruction of the
  authoritative live-owner relation.
- Moving-byte repair: rebuild completion now deliberately discards the
  incrementally maintained hash index and reconstructs it from live records;
  the postcondition checks exact owner buckets. A local out-of-tree semantic
  no-op mutant now fails at that postcondition. This does not alter the failed
  review; a fresh independent replacement review is required.

## Phase 5 And Quotient Kernel Bounded Re-review

- Verdict: `PASS-for-bounded-scope`; not a phase ballot.
- Temporary report: `/tmp/acgn-p5-rereview-20260821.md`.
- Report SHA-256:
  `b73d29b11bf43eea10ec67608436ffdc9c0e57134f1d02e0e12b87519a54dcbd`.
- Passed boundary: 253 source-rule checks, nine bounded SAT falsification
  queries, Lean/Java agreement for guarded `univ in none`, schema-v8
  writer/replay including 22 fixture-authorized bundles, and 76 concrete
  metric-refinement checks over 11 Lean vectors.
- Explicit limits: bounded Alloy scopes; fixture-only certificate authority;
  no proof of every temporal dynamic program, assignment implementation,
  pruning path, source-to-repair projection, or Java/JVM refinement.
- Invalidation: the subsequent P5-F22 command-authority repair changed the
  source-rule test and Lean model, so a new immutable review is required.

## Phase 4 Rebuild Replacement Review

- Verdict: `PASS-for-explicitly-bounded-Phase-4-scope`; not a phase ballot and
  not whole-artifact closure.
- Temporary report:
  `/tmp/acgn-phase4-second-replacement-review-20260821.md`.
- Report SHA-256:
  `51be23abbdf7f6a981eeb31a8263f834d9710f459db5155fe863ae73a1b5906a`.
- Passed boundary: 19,258 counted producer checks plus the unnumbered
  saturation/ablation suites, 134 standalone-verifier checks, all three Phase
  4 Lean modules, exact P4 traceability anchors, and the schema-v8 harness at
  census `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.
- Mutation result: both a counter-only and an empty-body
  `rebuildHashConsExactly()` mutant fail the semantic owner-bucket postcondition
  in the full rebuild suite and in the isolated interface-change path.
- Explicit limits: the dirty moving snapshot is not an immutable ballot;
  universal JVM refinement and the declared P4 partial obligations remain
  open.

## Phase 5 Scope-Shadowing Replacement Review

- Verdict: `FAIL`; not a phase ballot.
- Temporary report:
  `/tmp/acgn-phase5-replacement-review-20260821.md`.
- Report SHA-256:
  `0effc5df4d35b810ddf3a612b58d4d9665cd8706c3bae6bf3360242398aca0d9e`.
- Passed boundary before the counterexample: 299 source-rule checks, the core
  saturation and five ablation paths, both Phase 5 Lean modules, and exact P5
  traceability references.
- Decisive counterexample: `target[x:A] { (some x:B | x=x) implies some none }`
  is solver-equivalent to `no B` through scope 3, but repair projection merged
  the two raw source spellings and threw a cross-type alias collision. An
  equal-carrier version exposed the corresponding silent-capture risk.
- Moving-byte repair: projection authority now uses only alpha-renamed and
  rooted De Bruijn identities. Four permanent implication/IFF controls pass
  source-versus-normalized checks and the focused suite now passes 332 checks;
  scope separation is modeled in `PrenexAciScheduling.lean`.
- The failed verdict remains in force. A fresh independent replacement review
  is running, and the generated claim catalog must be refreshed after the
  matrix stabilizes.
