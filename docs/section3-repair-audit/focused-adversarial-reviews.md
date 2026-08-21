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

## Phase 5 Scope-Shadowing Fresh Replacement Review

- Verdict: `PASS-for-explicitly-bounded-Phase-5-scope`; not a phase ballot or
  whole-artifact closure.
- Temporary report:
  `/tmp/acgn-phase5-shadow-replacement-review-20260821.md`.
- Report SHA-256:
  `28f1003f59a5a1d367d86c4ad0a11f5d33c1c2db11a54a8c67f3836993184c1d`.
- Passed boundary: clean Java 17/UTF-8 compilation of 296 sources; 332
  source-rule checks; 182 instrumented saturation assertions; 264 ablation
  assertions; and 79 relevant Lean declarations.
- Independent falsification: 11 scope-shadowing variants at four Alloy scopes
  produced 44 UNSAT source-versus-normalized checks and 60 passing projection
  checks. Four mutants were killed, including restored raw-alias authority,
  source-first same-type capture, and incorrect implication/IFF polarity.
- Explicit limits: malformed hand-built IR, exhaustive Alloy scopes, universal
  JVM refinement, corpus reruns, and artifact closure were not authorized.

## Phase 6 Evidence-Mapping Review

- Verdict: `FAIL`; the reviewed snapshot was not closed.
- Temporary report: `/tmp/acgn-phase6-evidence-map-20260821.md`.
- Report SHA-256:
  `bb593ede990ae71deaa6125a1ade5d26def049e41f4db6598ed319293f2191b6`.
- Decisive findings: producer/verifier paths retained complete orbit state
  despite streaming claims, and P6-11 contained malformed evidence mappings.
- Moving-byte repair: production local traversal now uses a stabilizer chain,
  verifier replay retains one running minimum, and all P6 rows resolve to one
  real Lean file and real declarations. This failed review remains provenance;
  a fresh replacement review is required.

## Global And Metric Evidence-Mapping Review

- Verdict: `FAIL / NOT CLOSED`; not an integrated ballot.
- Temporary report: `/tmp/acgn-global-metric-evidence-map-20260821.md`.
- Report SHA-256:
  `31572a16b86bdb6601aa079c9865564af842335a507c632b5847d54e4a09b952`.
- Snapshot SHA-256:
  `e401b87f4725876caa7e769b9c92b191ae3c4d28a570d716c25668d81a76ce58`.
- Bounded execution: 17,666 numbered Java checks and 18 Lean files passed;
  the certificate census remained `1/2/0`.
- Findings at that snapshot: 13 global claims were partial, five literal
  global claims were contradicted, and all eight metric claims were partial.
  The stale current-facing diagnostic count in this directory has since been
  removed, but incomplete CI registration, closed-world coverage, authority
  surfaces, empirical manifests, and metric refinements remain open.

## Phase 6 Fresh Replacement Review

- Verdict: `FAIL / NOT CLOSED`; not a phase ballot.
- Temporary report:
  `/tmp/acgn-phase6-streaming-replacement-review-20260821.md`.
- Report SHA-256:
  `4a9574907deddff0bb086df63aa8abcae369874de463bd6124fd80944a7f7132`.
- Passed boundary: an independently reconstructed oracle checked 1,218 finite
  groups and 201,958 traversal assertions, including full `S7`; the focused
  producer/verifier, mutation, schema, Lean, and certificate-census controls
  also passed on the frozen reviewed snapshot.
- Decisive findings: the former P6-10 wording falsely included complete
  certificate/verifier witness ledgers in a no-retention claim; removal of the
  equal-shape witness tie-break survived permanent tests; and a first-candidate
  verifier required a temporary six-bundle `S3` sweep to expose it.
- Moving-byte repair: P6-10 is narrowed to candidate-term retention, with
  proof/completeness ledgers explicitly outside that claim; the six `S3`
  bundles and a direct equal-shape/different-witness comparator probe are now
  permanent. P6-03, P6-12, and P6-13 remain partial pending complete
  producer/verifier refinement and PAIR substitution evidence.

## Repair Metric Maximum-Adversarial Review

- Verdict: `FAIL / NOT CLOSED`; not an integrated ballot.
- Temporary report: `/tmp/acgn-metric-max-review-20260821.md`.
- Report SHA-256:
  `fc8569ebc5a1d267de3b4c3d508db5025da2928c53d878102b379c3ba250a4b0`.
- Bounded execution: 45,334 adversarial checks, 75 then-current metric checks,
  453 pipeline checks, 76 Lean/Java vectors, and four compiled Lean files.
- Decisive findings: a same-coordinate fallback erased parameter type edits
  and produced 210 typed-alpha mismatches; Hungarian arithmetic returned `-2`
  for an exact cost of `4,294,967,294`; the literal matrix-node deletion claim
  conflicted with the established whole-operand recurrence; and exact alpha
  search had no operational bound.
- Moving-byte repair: minimum quantifier/parameter edit plans now carry every
  paid modified-binding correspondence, the coordinate fallback is deleted,
  parameters are charged once, scope products stream, exact searches have
  fail-closed bounds, and Hungarian/DP arithmetic is checked. The matrix claim
  now states the existing Fast Rewrite subtree-operand unit. Fresh independent
  typed differentials and full Java-to-Lean refinement are still required.

## Phase 6 Post-Repair Mutation Review

- Verdict: `FAIL / INCOMPLETE`; not a phase ballot.
- Temporary report: `/tmp/acgn-phase6-postrepair-review-20260821.md`.
- Report SHA-256:
  `1d7a29ad873a3e44db2fecb038b83de544adc437709b4f9f2d97dcb0f12d8871`.
- Bounded execution: 70,188 Java checks and the Phase 6 Lean model passed on
  the frozen review snapshot; four of seven controlled source variants were
  detected.
- Surviving variants: producer witness-tie removal, standalone verifier
  first-candidate selection, and a complete candidate list retained beside
  the streaming minimum.
- Moving-byte repair: direct producer comparator checks, real verifier-minimum
  order checks, and a structural retained-state assertion now target those
  exact variants. Candidate-set refinement and general PAIR ownership remain
  partial, and a new review is mandatory.

## Repair Metric Post-Repair Mutation Review

- Verdict: `FAIL / INCOMPLETE`; not an integrated ballot.
- Temporary report: `/tmp/acgn-metric-postrepair-review-20260821.md`.
- Report SHA-256:
  `620a4c718f316ccb8348f2a7f2ecd8504587337f89e8594a2cf15c06ccb9e57b`.
- Decisive counterexample: `[T] -> [S,T]` retained the same logical `T`
  parameter but returned quantifier-plus-matrix cost `1+1` because the
  zero-cost shifted diagonal was discarded.
- Moving-byte repair: positional-parameter diagonals are now explicit selected
  correspondences. A separate oracle checks 1,156 sequence/reference cases;
  injectivity, subtree, resource, checked-total, assignment-overflow, and
  bound/free-direction branches have permanent tests. A fresh review remains
  required because all of these are later bytes.
