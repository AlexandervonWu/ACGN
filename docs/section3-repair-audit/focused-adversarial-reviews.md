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

## P0 Subtype JOIN Module-Authority Ballot 1

- Verdict: `FAIL`; the ballot was invalidated on its first completed review.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Decisive reviewer: `01a0254b-8680-7b31-9c4f-d417d692650c`, formal
  correspondence scope.
- Invalidated running reviewers:
  `01a0254a-ed54-7c20-b2b6-e958b8d59a0c` (producer authority),
  `01a0254b-28cb-7951-817b-5fd364cac45f` (Java chain semantics),
  `01a0254b-4ad1-7c60-ac78-d8b12f2fc6ab` (wire/verifier), and
  `01a0254b-a866-7fc1-8b82-8a5ab86e0ae9` (integration/documentation).
- Decisive findings: the Lean fold admitted unary chains, ignored the
  unary-interior JOIN guard, did not consume parser authority, assumed its
  encoded result, and did not model schema-v9 standalone outcomes.
- Additional local falsification before replacement review: object IDs were
  not paired with nominal labels; nullary JOIN output was admitted; and an
  arbitrary unchecked `ChainIndex` could be wrapped as certified.
- Moving-byte repair: producer evidence now binds module identity-to-label
  pairs and positioned parent edges; executable producer and structural folds
  enforce Java's arity, guard, type, result, and evidence constraints; equality
  authority requires a checked fold; schema v8 rejects and schema-v9 exact,
  malformed, and nonexact outcomes are explicit. These later bytes require a
  wholly fresh five-reviewer ballot.

## P0 Subtype JOIN Module-Authority Ballot 2

- Verdict: `FAIL`; the replacement ballot was invalidated on its first
  completed review.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Decisive reviewer: `01a02561-dda7-7111-8535-c711a393d488`, formal
  correspondence scope.
- Invalidated running reviewers:
  `01a02561-597c-7d00-a4fb-7bad7017805f` (producer authority),
  `01a02561-8229-7be2-95db-f7690fcc8498` (Java chain semantics),
  `01a02561-b0ca-7341-9a00-b79d5b08457f` (wire/verifier), and
  `01a02562-12f1-76e0-b2bc-e5adb4545c5e` (integration/documentation).
- Reviewed evidence: `/tmp/acgn-subtype-section3-final6`, input manifest
  `8171a4a8ff17df4b9c1e6925757b3bbf31fee5bbd7caf09a4b9d0f1535cb1733`.
- Decisive findings: the finite exact-chain outcome ignored the fixed theory
  digest; object IDs were not injective; source positions were self-supplied
  flags; record replay assumed equality; and a slice-level result was named as
  though it established whole-bundle verification.
- Moving-byte repair: unique module object identities and concrete positioned
  parent declarations are now part of the executable snapshot; path admission
  replays those ledgers; the exact v5 version/digest are checked; outcome names
  are chain-slice-specific; and replay compares each committed field. The
  finite witness and Java/parser refinement remain openly partial. A third
  wholly fresh ballot is required.

## P0 Subtype JOIN Formal Preflight 3

- Verdict: `FAIL`; this was a token-conserving preflight and was never counted
  as one of the required five ballot reviews.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewer: `01a02575-9817-7193-ba91-8de0580ec925`.
- Reviewed evidence: `/tmp/acgn-subtype-section3-final7`.
- Decisive findings: the formal parent ledger lacked a global acyclicity check,
  and one variadic JOIN could consume a different authority snapshot at each
  boundary.
- Moving-byte repair: snapshot validation now checks every module object's
  functional parent chain with bounded fuel; the producer JOIN fold requires
  one common authority snapshot. Concrete two-node-cycle and mixed-module
  three-operand witnesses reject. Another preflight is required before the
  five-reviewer ballot.

## P0 Subtype JOIN Formal Preflight 4

- Verdict: `PASS` for the bounded formal slice; this preflight does not count
  toward the required five-reviewer ballot.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewer: `01a02587-84b5-7900-aeeb-38f8e410e005`.
- Reviewed evidence: `/tmp/acgn-subtype-section3-final8`.
- The reviewer found no bounded counterexample after independently checking
  module identity uniqueness/ownership, positioned functional acyclic parent
  declarations, identity-to-label paths, one authority snapshot per JOIN,
  fold guards/results, fixed v5 metadata, field commitment replay, and
  slice-local exact/nonexact/schema outcomes.
- General parser/JVM/SHA-256/wire-parser refinement remained explicitly outside
  this preflight and remains open in the claim catalog.

## P0 Subtype JOIN Module-Authority Ballot 3

- Verdict: `FAIL`; one finding invalidated the complete ballot, and the other
  completed findings are retained rather than discarded.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewed evidence: `/tmp/acgn-subtype-section3-final9`.
- Producer-provenance reviewer:
  `01a0258c-ee6e-7fc0-9c02-2d124eecb7f3`.
  It found that legal `sig B { f: seq A }` types were rejected because Alloy's
  built-in `seq/Int -> Int` edge has no user-source filename.
- Java-semantics reviewer:
  `01a0258d-0f9e-76d0-a520-68e457257db8`.
  It found that separately parsed modules with identical labels and ancestry
  could be mixed after module identity was reduced to a Boolean.
- Formal reviewer:
  `01a0258d-4ccc-7ec1-8ecf-f172d0f82380`.
  It found that `{ serializedAuthority with live := true }` reconstructed the
  former Boolean authority in Lean.
- Interrupted after invalidation to conserve the user's review budget:
  `01a0258d-2f93-70c0-89d4-ebe298e1efbf` and
  `01a0258d-6a73-7681-bc62-e69bd8f83323`.
- Moving-byte repair: Java admits only the exact `Sig.SEQIDX -> Sig.SIGINT`
  identity edge as built-in, carries a transient `CompModule` identity through
  proof evidence, requires every present variadic-leaf capability to agree,
  and requires both nonexact boundary endpoints to share it. Lean replaces the
  Boolean with an immutable-snapshot-indexed capability and a distinct
  snapshot-only serialization state. A wholly fresh ballot is required.

## Correlated DAG Staged Review: Invalidated Luna Round 1

- Verdict: `FAIL`; both completed Luna reviews invalidated the snapshot.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a034d4-5550-75f1-9ea8-93f8efc0994f` and
  `01a034d4-9a9d-72e3-8b5e-7f281bae6744`.
- Decisive bookkeeping findings: the audit files reused `GC-F58` and
  `A2-F25` for distinct incidents.
- Decisive producer finding: binary DAG combination checked module identity
  but did not explicitly validate the merged hierarchy before JOIN could
  consume both contradictory boundary columns.
- Scope finding: the standalone Lean file is a declared finite falsification
  model and not a proof of arbitrary parser-to-Java refinement. The claim
  matrix already records that boundary as `PARTIAL`; a parser-backed subset
  signature regression was added to strengthen, not overstate, conformance.
- Moving-byte repair: audit IDs are unique; merged hierarchy consistency is
  checked before pair decisions; a malformed internal-ledger witness rejects;
  and subset versus primitive-extension parser behavior has an executable
  regression. The full bounded Java suite, both dependent Lean modules, and
  Development Run I pass their executable checks. A fresh Luna pair must
  restart the staged review.

## Correlated DAG Staged Review: Invalidated Luna Round 2

- Verdict: `FAIL`; both completed Luna reviews invalidated staged tree
  `a9ee8195eeca8bc1274d0ac49b1fad1c617de5d7`.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a034ed-8ce7-77e2-9537-888ad1e5b0d3` and
  `01a034ed-b907-7281-baf4-c4a88d962245`.
- Semantic findings: direct DAG JOIN accepted exact `univ` overlap, and the
  public column constructor accepted non-Alloy atomic graph symbols. Both
  states disagreed with the standalone verifier's closed vocabulary.
- Reproducibility findings: the prose claimed pinned Lean 4.33.0 without a
  repository toolchain pin, and four Phase 6 focused test counts were stale.
- Moving-byte repair: dependent chain combination and direct boundary replay
  reject explicit `univ`; dependent columns admit only `Int` or nonempty
  `AlloySig:*`; a root `lean-toolchain` selects 4.33.0; the Lean model proves
  fail-closed certified JOIN/ARROW witnesses; and current test counts are
  synchronized. A fresh Luna pair must restart the staged review.

## Correlated DAG Staged Review: Aborted Luna Round 3

- Verdict: `ABORTED BEFORE DECISION`; local preflight invalidated staged tree
  `1a6bf13dcd96dc1fce4c0027b4b679d08947115d` while both fresh Luna reviewers
  were still running.
- Reviewers: `01a03505-435e-7cf1-beb4-856167476926` and
  `01a03505-8539-77e1-8615-961ed3ec3212`.
- Decisive local counterexample: pairwise DAG folding could consume module A's
  last exact boundary before module B entered a later pair. The scalar-column
  fold already performed the required complete-input preflight; the DAG fold
  did not.
- Moving-byte repair: all original correlated alternatives are now checked for
  one live module and one consistent acyclic hierarchy before the first fold
  step. A fresh review pair is mandatory.

## Correlated DAG Staged Review: Aborted Luna Round 4

- Verdict: `ABORTED BEFORE DECISION`; local formal preflight invalidated
  immutable review commit `9b83667e010350773effd1995863d1a0cb0ad53e`.
- Reviewers: `01a0350a-3d64-7443-8154-62ccf6cb0a94` and
  `01a0350a-6452-7c92-abca-a45da90d0429`.
- Decisive mismatch: Java direct boundary derivation rejected explicit `univ`,
  but Lean's raw `.univ/.univ` boundary remained exact; only the whole-family
  certified wrapper rejected it.
- Moving-byte repair: explicit `univ` makes the raw Lean boundary undefined,
  matching Java and verifier behavior. A fresh pair must review later bytes.

## Correlated DAG Semantic Correction After Round 4

- Verdict: `PRIOR REPAIR INVALIDATED`; this is not a review PASS.
- The earlier rounds correctly detected cross-layer disagreement, but their
  proposed invariant was wrong: they conflated an explicit parser-provided
  `univ` relation column with missing or unresolved type information.
- Decisive counterexamples: for `trans : A -> B -> C`, both associations of
  `(x.trans).univ` and `(univ.trans).x` are legal and have the same relational
  denotation. The concrete endpoint's authenticated path terminates at `univ`;
  an exact `univ/univ` boundary needs no invented carrier.
- Moving-byte repair: dependent theory v8 admits explicit `univ` through exact
  identity or an authenticated subtype path, removes special fallback behavior
  from producer and verifier, and retains failure for absent typing. JOIN still
  refuses reassociation when an interior operand is unary, which is the bounded
  non-associative counterexample.
- Evidence before the restarted ballot: 83 focused dependent-chain checks and
  504 parser-pipeline checks pass; both standalone Lean files compile. A fresh
  Luna pair must review the corrected immutable snapshot before Terra or Sol.

## Correlated DAG Explicit-Univ Luna Round 5

- Verdict: `FAIL`; immutable staged tree
  `7de9f3114afc439920c761af9e7c0e3b3d58ff5d` is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a03536-61c0-7b93-ab38-9d73d585cc11` and
  `01a03536-5b01-7bd0-9c3f-263bfe851105`.
- Patch-local findings: the Phase A2 report retained the old 99-check/v6
  evidence text, and the standalone correlated-family model did not expose a
  guarded variadic JOIN certification function. Both are repaired on later
  moving bytes; a new immutable review is required.
- Rejected counterexample: the proposed `((A.(A -> B)).B)` nullary JOIN is
  rejected by the Alloy parser as an illegal relational join. It therefore
  does not refute the producer's supported well-typed expression domain.
- Already-declared limitation: independent reconstruction of the Fast Rewrite
  source-content scalar is already `PARTIAL` under A2-12; the review found no
  new producer/verifier acceptance route.
- Newly explicit release blockers: the protected bounded-assurance runner
  omits root `lean-toolchain` bytes from its input manifest, and the protected
  verifier build script emits timestamp-dependent JAR bytes. These are
  recorded as GC-F65 and GC-F71 and are not silently modified in this phase.
- Semantic result: neither reviewer found a concrete counterexample to Java
  dependent-DAG correlation, ordered duplicate-preserving JOIN/ARROW `Seq`,
  explicit parser-`univ` endpoint handling, or producer/verifier v8 identity.
  The gate nevertheless remains failed because unanimity is mandatory.

## Correlated DAG All-Disjoint Luna Round 6

- Verdict: `FAIL`; immutable staged tree
  `a25d0a18ad1e1a690b435320bb4e8082cb10f1d4` is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a03547-f4d0-7083-9c4e-e6a10b783594` and
  `01a03547-fb51-7f10-bee6-eff7809ecf3a`.
- Decisive semantic finding: the parser-valid binary JOIN
  `(A->B).(C->D)` produced a complete one-by-one disjoint decision matrix but
  then threw because its normalized alternative list was empty. Binary JOIN
  needs no reassociation, and its result has positive arity two, so fallback
  was semantically unjustified.
- Documentation findings: two focused reports still named pre-DAG mutation
  counts, and current prose did not separate an authenticated empty result from
  unresolved typing.
- Moving-byte repair: dependent theory v9 introduces a typed empty family with
  positive arity and zero alternatives. Java, wire replay, and standalone Lean
  preserve its arity, complete disjoint matrix, and ordered source `Seq`;
  mutations of its arity, carrier, and common ancestor reject. A computed
  nullary relation remains unsupported because Alloy has no nullary relation
  carrier. The focused counts and claims are synchronized on later bytes.
- Gate state: `FAIL` remains binding for this snapshot. A fresh immutable Luna
  pair must review the repaired bytes before any Terra or Sol round begins.

## Correlated DAG Typed-Empty Luna Round 7

- Verdict: `FAIL`; immutable staged tree
  `533f3e68c1ff615ec33607ab08b762ceb61d2e47` is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a03571-9ba4-7321-bfae-eb3de0e3eb2d` and
  `01a03571-a576-7661-ad72-1b88ca1c5b32`.
- Producer/verifier mismatch: a typed-empty arity-two interior JOIN operand
  passed producer admission, while verifier replay called the nonempty product
  decoder during its interior guard and rejected it.
- Producer proof bypass: an empty parser result returned before a source
  `PLUS` or `INTERSECT` node recursively derived its operand DAG and compared
  that derivation with the parser type.
- Formal authority gap: the first correlated-family wrapper checked a common
  module identity but did not bind each exact column to an object/nominal
  ancestry path. One reviewer compiled a forged `univ` witness using an
  unrelated Product path. Pure family operations and authority therefore were
  not yet one executable model.
- Documentation finding: current Phase 6 prose still reported 364 theory
  certificate checks while the immutable assurance run executed 398.
- Moving-byte repair: verifier and producer now share the relation-arity guard;
  empty set operators recurse before result acceptance; an exact empty-interior
  certificate and parser-backed empty UNION/INTERSECTION fixtures are
  permanent; and the formal correlated DAG carries per-column parser paths
  through executable ARROW/JOIN matrices. Current focused counts are
  synchronized. A fresh immutable Luna pair is mandatory.

## Correlated DAG Authority Luna Round 8

- Verdict: `FAIL`; immutable staged tree
  `d11fcae129afec4fa530001c7a8589dc21d98281` is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a0358e-a6ef-7c61-997b-78995145f7e6` and
  `01a0358e-a711-76a3-b3b6-02a6e721dad1`.
- Decisive Java counterexample: direct calls to all three variadic fold APIs
  bypassed the JOIN interior-arity guard. `[A->B, B, A->A]` therefore
  returned a flattened relation although the application constructor and Lean
  certified chain rejected it.
- Decisive formal counterexamples: the older parser-authority abstraction
  discarded absent authorities before comparing modules, while the standalone
  public `TypedFamily` JOIN accepted a forged arity-zero empty operand and
  wrong-width products.
- Documentation findings: current prose named 398 theory-certificate checks
  although the snapshot ran 405, and the wire grammar required a nonempty
  product list despite typed-empty DAGs.
- Qualification of one proposed repair: requiring a parser-module token on
  every Java exact column is too strong. Quantified primitive-set slots carry
  exact `PRIMITIVE_SET_SINGLETON` leaf proofs and legitimately have no subtype
  ancestry. A2-27 now states the two authority cases separately; parser-derived
  nontrivial ancestry still requires one live module plus object and nominal
  paths.
- Explicit unresolved boundary: wire replay checks the derived leaf DAG but
  does not independently replay raw UNION/INTERSECTION source children.
  Production paths carrying parser ancestry remain `UNCHECKABLE` without the
  separately pinned hierarchy authority, so this is not a route to a false
  `VERIFIED` result; it remains release-blocking for any stronger raw-source
  replay claim under GC-F79.
- Moving-byte repair: all variadic Java entry points now share the arity guard;
  standalone typed-family operations validate positive arity and width; the
  parser-correlated Lean fold rejects absent authorities; the grammar and
  current counts are synchronized. A fresh immutable Luna pair is mandatory.

## Correlated DAG Variadic Luna Round 9

- Verdict: `FAIL`; immutable staged tree
  `ee9b73aa2e3a3560fd8156c147207b241a4e83fc` is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a035b7-2977-7843-b1ce-35c268cd2524` and
  `01a035b7-2953-7642-a5bd-8038f8dea9c2`.
- Decisive verifier counterexample: an exact singleton relation headed by the
  generic nullary constructor `Bogus` passed standalone atomic-column replay.
  Its singleton ancestry did not trigger the missing hierarchy authority, so
  the forged vocabulary could reach `VERIFIED` although producer construction
  rejects it.
- Formal boundary counterexample: `familyJoinFold` returned its current value
  without validating the empty-rest base case. Direct raw calls therefore
  admitted a forged arity-zero or wrong-width family, although the certified
  wrapper validated all source operands.
- Claim-boundary correction: the scalar `foldColumns` helper has no arity field
  and therefore cannot encode a positive-arity empty family. Production,
  graph-type, and DAG paths retain typed-empty arity; the scalar compatibility
  path is now documented only for nonempty single products.
- Control findings: both reviewers confirmed the v10 digest, current test
  counts, typed-empty grammar, and GC-F79's `UNCHECKABLE` fence for nontrivial
  parser ancestry. GC-F65, GC-F71, GC-F79, and the 182 traceability diagnostics
  remain explicit blockers rather than repaired claims.
- Moving-byte repair: verifier atomic columns now exactly mirror the producer
  vocabulary and have direct negative tests; the Lean fold validates its base
  case; the scalar-family boundary is stated precisely. A fresh immutable Luna
  pair is mandatory.

## Correlated DAG Atomic-Column Luna Round 10

- Verdict: `FAIL`; immutable staged tree
  `5221b6f7a09270313efff35afe40bacc040bb979` is invalidated. One reviewer
  returned `PASS`; unanimity therefore was not reached.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a035cc-3b09-7ed3-969f-557462a0521b` and
  `01a035cc-3ae7-7220-8471-79193a53e54c`.
- Formal guard counterexample: direct `joinFlatGuard` accepted a malformed
  interior family whose declared arity was two but whose only product had
  width zero. The certified wrapper's outer validation prevented a false
  certified result, but the public helper's answer contradicted its name and
  report wording.
- Formal ARROW counterexample: an early helper named `certifiedFamilyArrow`
  accepted raw product families with inconsistent widths. Its raw Cartesian
  behavior was correct, but it carried no typed certification boundary.
- Documentation contradiction: `FORMAT.md` still said an arity-only empty
  relation could not participate in JOIN/ARROW evidence, while the exact
  empty-interior fixture is intentionally verified under v10.
- Control findings: both reviewers found no bypass of the repaired atomic
  verifier vocabulary, Java variadic guards, typed-empty DAG arity, or GC-F79
  nonexact `UNCHECKABLE` fence. Current counts and v10 digest agreed.
- Moving-byte repair: the guard validates all families, the certified ARROW
  theorem uses `typedFamilyArrow`, and format prose states the positive-arity
  typed-empty rule. A fresh immutable Luna pair is mandatory.

## Correlated DAG Typed-Family Luna Round 11

- Verdict: `FAIL`; immutable staged tree
  `c43a3fa0feab39dccddbe48d37972ba3592e3031` is invalidated. One reviewer
  returned `PASS`; unanimity therefore was not reached.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a035d8-4ba5-71e0-bd6b-98f5a35e166a` and
  `01a035d8-4bc9-7a22-b5d5-2907d7cacab3`.
- Decisive producer/verifier mismatch: primitive singleton conversion accepted
  `AlloyCarrier(AlloySig:)` and could construct the empty signature relation
  view, while the DAG and standalone verifier reject the same carrier.
- Control findings: the reviewers found no new bypass in the verifier atomic
  vocabulary, typed-family operations, Java variadic guards, typed-empty DAG
  arity, v10 identity, or GC-F79 fence.
- Moving-byte repair: primitive conversion now requires a nonempty signature
  identity before building a unary view, with direct conversion and leaf-proof
  regressions. A fresh immutable Luna pair is mandatory.

## Correlated DAG Atomic-Identity Luna Round 12

- Verdict: `FAIL`; immutable staged tree
  `b7225a38ef093f2f8175e99ba4f39ace8f120a52` is invalidated. Both reviewers
  independently reconstructed the same counterexample.
- Reviewer model and effort: `gpt-5.6-luna`, `max`.
- Reviewers: `01a035e5-859c-7932-9cec-5257019ada29` and
  `01a035e5-b2b5-72c0-bcd1-a6ec5d270c8d`.
- Decisive producer/verifier mismatch: `AlloySig: ` has a whitespace-only suffix
  but passed prefix-length tests in primitive conversion, dependent-column
  admission, correspondence derivation, and standalone replay.
- Control findings: all stated focused counts, Lean modules, theory-v10 digest,
  protected-tree boundary, and GC-F79's `UNCHECKABLE` fence agreed with the
  snapshot.
- Moving-byte repair: producer and verifier now require a nonblank,
  whitespace-free signature identity through mirrored atomic-column predicates;
  direct producer and verifier regressions retain the exact witness. A fresh
  immutable Luna pair is mandatory.

## Correlated DAG Ingress-And-Replay Luna Round 13

- Verdict: `FAIL`; immutable staged tree
  `0ab2fcc8ca08f48ebd1a45ac484378ff5079ce66` (tree
  `511906c12c00fa8d2093a1e1583d2c9af10acc1b`) is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`, bounded by an explicit
  review timebox.
- Reviewers: `01a035fc-73df-7fa0-8eb0-4e906e13fae6` and
  `01a035fc-b1d6-7da3-bf32-45a09c9821bc`.
- Decisive replay mismatch: producer-legal `seq/Int -> Int -> univ` ancestry
  was serialized, but verifier replay's redundant constructor-only check
  rejected its `Int` step.
- Decisive fallback bypass: all leaf `IllegalArgumentException` values were
  treated as unsupported flattening, allowing malformed public exact types to
  fall back to ordinary binary syntax. Binding type normalization could erase
  whitespace before the certification boundary observed it.
- Decisive public-API mismatch: the exact leaf-rule helper admitted
  `Rel(Bogus)` before later DAG validation rejected the same carrier.
- Moving-byte repair: exact-type and binding ingress reject whitespace-bearing
  identities; exact leaf proofs validate their full DAG family; only explicit
  unsupported markers authorize fallback; verifier replay admits `Int` in the
  closed atomic ancestry vocabulary and retains the hierarchy fence. The
  sequence witness now crosses producer export and verifier replay in a
  permanent fixture. A fresh immutable Luna pair is mandatory.

## Correlated DAG Converter-Ingress Luna Round 14

- Verdict: `FAIL`; immutable staged tree
  `2e77452d5b45bc758ce5075a238698108a393a26` (tree
  `225eafcc0ab4ed3c93bfddaec74fa44851be0025`) is invalidated.
- Reviewer model and effort: `gpt-5.6-luna`, `max`, bounded by an explicit
  review timebox.
- Reviewers: `01a03616-8cc5-79c1-b6f0-e5e3b88bfe3e` and
  `01a03616-d8f6-7ff2-888e-b1360c4310d1`.
- New finding: package-level producer column converters still trimmed
  `" S "` into `AlloySig:S`, violating fail-closed identity admission on an
  alternate ingress.
- Control findings: typed fallback routing, exact leaf/DAG parity, sequence
  replay, theory identity, current focused counts, and protected paths agreed.
  One reviewer returned `FAIL` solely because GC-F79 and the 182 catalogued
  obligations remain open. Those are acknowledged whole-artifact blockers,
  not newly repaired or silently waived by this focused ballot.
- Moving-byte repair: both package-level conversion helpers reject whitespace
  before constructing an Alloy column, with a direct regression. A fresh
  immutable Luna pair is mandatory; whole-artifact status remains
  `INCOMPLETE` regardless of the focused result.

## Correlated DAG Scalar-Identity Review Ladder Round 15

- Verdict: `FAIL` at the Terra tier; immutable staged commit
  `e9e7e743057df5e172c6abd001f477bcc01bc668` (tree
  `8fdad5838daae5671fad0817eaa20b18b36565d3`) is invalidated.
- Luna tier: two independent `gpt-5.6-luna` maximum-effort reviewers returned
  scoped `PASS` for the dependent-DAG moving bytes.
- Terra tier: one reviewer returned `PASS`; the other found that the
  whitespace policy still admitted C0 controls, Unicode format characters,
  private-use and unassigned code points, and unpaired UTF-16 surrogates.
  Unanimity was therefore not reached and no Sol tier was started.
- Decisive serialization witness: an unpaired surrogate admitted as an Alloy
  identity is not stable under UTF-8 certificate encoding.
- Moving-byte repair: producer and verifier now mirror a scalar-category
  admission rule at every identity ingress and retain direct NUL, `U+200B`,
  and unpaired `U+D800` regressions. A fresh ladder is mandatory.
- Whole-artifact blockers GC-F65, GC-F71, GC-F79, and the 182 traceability
  diagnostics remain open and keep the bounded assurance outcome
  `INCOMPLETE`; this focused ladder does not waive them.

## Correlated DAG Canonical-UTF-8 Luna Round 16

- Verdict: unanimous `FAIL`; immutable staged commit
  `d8e4f539bce3a17870169e3003a6fefcfb66a762` (tree
  `1d37a8cab6182b123511affa3cdcef66062c51ef`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort.
- Decisive shared counterexample: polymorphic operator keys decoded Base64
  bytes with replacement semantics. Malformed UTF-8 such as `ED A0 80` could
  become the same Java `U+FFFD` string as valid `EF BF BD` before digest and
  stable-key checks.
- Additional producer counterexample: canonical wire encoding used
  replacement semantics for an unpaired UTF-16 surrogate, so an in-memory
  identity could change before serialization.
- Coverage finding: the direct category matrix omitted private-use,
  unassigned, and valid supplementary-plane identities.
- Moving-byte repair: producer and verifier canonical encoders/decoders now
  report malformed input, polymorphic-key replay uses the strict decoder, and
  permanent tests cover all three missing categories. A fresh Luna pair is
  mandatory.

## Correlated DAG In-Memory Identity Luna Round 17

- Verdict: unanimous `FAIL`; immutable staged commit
  `3f9ac238d7640d595c2c556a7777a19e3a1f0f50` (tree
  `f708d97527a5b5762aaf845c932a42f64319780a`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort.
- Exact-type finding: verifier resolution checked a constructor symbol only
  with `trim().isEmpty()`. A valid-UTF-8 exact-type record carrying a format,
  control, private-use, or unassigned `AlloySig:` identity could therefore
  enter verifier state although producer exact types reject it.
- In-memory finding: `Wire.Node` and public `Bundle.parse(Wire.Node)` could
  receive a lone surrogate without first crossing the strict decoder;
  `SigSymbol` was another public producer identity ingress with no scalar
  policy.
- Moving-byte repair: all verifier exact-type symbols use the scalar policy,
  every wire node validates well-formed Unicode at construction, and
  `SigSymbol` reuses the exact Alloy identity guard. Permanent category and
  supplementary-plane tests cover each path. A fresh Luna pair is mandatory.

## Correlated DAG Producer-Parity Luna Round 18

- Verdict: unanimous `FAIL`; immutable staged commit
  `7c3b988566c66e5adc90cd8c294f04ce00071fa1` (tree
  `ee9a512853188297d79d7bec14cb9ba455836db1`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort.
- Generic-type finding: public `GraphType` admitted format, private-use, and
  unassigned symbols that writer exact-type emission serialized, while the
  verifier rejected the resulting record.
- Normalization finding: public `ExactAlloyType.unaryRelation("this/A")`
  retained `this/`, unlike parser ingestion, and therefore represented the
  same Alloy signature with a different dependent identity.
- Specification finding: outer wire strings are strict UTF-8 byte-length
  framed, while embedded structural keys intentionally use Java/Unicode
  UTF-16 code-unit lengths. The encoding remained injective and mirrored, but
  the review scope did not state the inner unit.
- Moving-byte repair: graph symbols and writer exact types enforce the common
  identity policy, every exact column/ancestry normalizes `this/`, and the
  nested length domains are explicit in `FORMAT.md`. A fresh Luna pair is
  mandatory.

## Correlated DAG Prefix-Alias Luna Round 19

- Verdict: `ABORTED BEFORE DECISION`; immutable staged commit
  `f731ce70bed762fb82448dbe9eafdd050ba76f39` (tree
  `6dbb4f5728a224fac3aef8111c2f7440c96e5230`) is invalidated by local
  preflight.
- Reviewers: two independent `gpt-5.6-luna` maximum-effort agents were stopped
  as soon as the local counterexample was established; neither vote is reused.
- Counterexample: `ExactAlloyType` normalized `this/A`, but direct
  `SigSymbol("this/A")`, package column conversion, and
  `GraphType.constructor("AlloySig:this/A")` retained distinct spellings.
- Moving-byte repair: every producer Alloy identity constructor normalizes one
  prefix, rejects empty/repeated prefixes, and verifier wire replay rejects
  noncanonical spellings. A wholly fresh Luna pair is mandatory.

## Correlated DAG Polymorphic-Identity Luna Round 20

- Verdict: `FAIL`; immutable staged commit
  `8db1a455b14a642785fdaae80d4c5a757893d248` (tree
  `8011fa01c6fc3e2f5a94122d80e0162c1fb48734`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort. One returned the decisive finding; the other exhausted the
  bounded timebox without a verdict, which is not a pass.
- Counterexample: an otherwise valid polymorphic declaration could carry a
  control-character phantom type parameter. `OperatorDeclaration` admitted
  it, and its structural key flowed into the Base64 polymorphic wire identity.
- Moving-byte repair: operator and type-parameter names now use the common
  visible-identity predicate, with category-complete direct tests. A wholly
  fresh Luna pair is mandatory.

## Correlated DAG Verifier-Parameter Luna Round 21

- Verdict: `FAIL`; immutable staged commit
  `101344cefee8ce227df262ec080acaec30942988` (tree
  `63268c1533a68d3f78a396d932fe66dfe231a8aa`) is invalidated.
- The first broad two-reviewer Luna attempt exhausted its bounded timebox
  without returning verdicts and was closed as non-passing. A replacement
  focused pair reviewed the same bytes; one returned the decisive failure and
  the other exhausted the replacement timebox without a verdict.
- Counterexample: standalone polymorphic-key replay accepted producer-forbidden
  nonbreaking-space, control, format, private-use, or unassigned type-parameter
  names through `requireCanonicalText`. Operator semantic identities had the
  same broader model ingress.
- Moving-byte repair: both verifier paths use an independent visible-identity
  predicate with direct category and supplementary-plane probes. A wholly
  fresh Luna pair is mandatory.

## Correlated DAG Type-Reference Namespace Luna Round 22

- Verdict: `FAIL`; immutable staged commit
  `a9e298463e5986536bdef685c2b2c486b860e245` (tree
  `5739d08f460ea7b445915e4617aa6b164e9d81d8`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort. One returned scoped `PASS`; the other supplied the decisive
  counterexample, so unanimity was not reached.
- Counterexample: the test-only exact-type reference fallback searched content
  IDs before displays. A constructor display equal to the Boolean content ID
  could therefore denote two distinct types and resolve as the Boolean type.
- Moving-byte repair: exact-type parsing now proves that IDs and displays are
  globally disjoint across distinct types before resolving any reference. A
  publication-profile fixture retains the minimum collision. A wholly fresh
  Luna pair is mandatory; whole-artifact status remains `INCOMPLETE`.

## Correlated DAG CALL-Identity Luna Round 23

- Verdict: `FAIL`; immutable staged commit
  `5eac20736543a3a098c41e0ddb53de335680bdda` (tree
  `12fac6af79cdf1e107f48be892b97a19c5a161d9`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort. One returned scoped `PASS`; the other supplied the decisive
  counterexample, so unanimity was not reached.
- Counterexample: `CallMetadata.requireText` admitted the valid-UTF-8 callee
  `m/f\u0000X`, while later typed-operator construction or standalone replay
  rejected the same identity.
- Moving-byte repair: CALL symbols, normalized metadata, occurrence
  certificates, and standalone replay now share the visible-identity category
  boundary. Eleven direct checks cover the minimum witness and all excluded
  categories. A wholly fresh Luna pair is mandatory.

## Correlated DAG Authority And Completeness Round 24

- Verdict: `FAIL`; immutable staged commit
  `196fd7e72ed6dbf9fc6bfda63a6e3f85531a1490` (tree
  `874f22eb6489358bba4a0edc6dff3b1b4c9da482`) is invalidated.
- Reviewer ladder: two independent `gpt-5.6-luna` maximum-effort reviewers
  both returned scoped `PASS`, so the same snapshot advanced to two fresh
  `gpt-5.6-terra` reviewers. Both Terra reviewers returned `FAIL`; no Sol tier
  was started.
- Dependent-DAG finding: recursive `PLUS`/`INTERSECT` derivation compared its
  result with parser evidence only after erasing parser-module occurrence
  authority. Equal labels and ancestry from a separately parsed module could
  satisfy that weaker comparison.
- CALL finding: occurrence rows were checked only when present. Removing the
  CALL occurrence ledger from an otherwise valid certificate was not rejected
  by a closed completeness invariant.
- Moving-byte repair: dependent DAG comparison now binds exact paths and a
  shared live parser-module capability; source construction records every CALL
  occurrence and both artifact assembly and standalone replay require exact
  CALL coverage. Direct Java mutations and independent Lean predicates retain
  both counterexamples. A wholly fresh Luna pair is mandatory.

## CALL Occurrence-Cardinality Luna Round 25

- Verdict: unanimous `FAIL`; immutable staged commit
  `cca0eed85805990639d584e21cfd34a241fdbb76` (tree
  `961b6609832859bb580dc95c35c71f9b8d022cac`) is invalidated.
- Reviewer model and effort: two independent `gpt-5.6-luna` reviewers at
  maximum effort. Both reconstructed the same counterexample independently.
- Counterexample: the standalone verifier compared only sets of CALL semantic
  operator identities. The two occurrences in `f[f[a]]` use one identity, so
  deleting either occurrence row preserved the set and passed the claimed
  completeness check.
- Moving-byte repair: every wire occurrence now has a distinct nullary model
  anchor derived injectively from its complete wire key; anchor/record sets and
  semantic operator sets are checked independently. The nested same-operator
  fixture and one-row omission mutation are permanent, with an independent
  Lean occurrence-anchor model. A wholly fresh Luna pair is mandatory.

## CALL Anchor-Isolation Preflight Round 26

- Verdict: `ABORTED BEFORE DECISION`; immutable staged commit
  `2e7f846287bb27dbbefe768a7e611657f4664fe7` (tree
  `91198315f6d96c0eee51bc86a7c339b56e428592`) is invalidated by local
  preflight. Both Luna reviewers were stopped and no vote is reusable.
- Counterexample class: occurrence markers were nullary and complete, but the
  verifier did not yet prove they were absent from semantic terms, witnesses,
  proofs, canonical records, and publication structure.
- Moving-byte repair: markers now match their source CALL context/sort and
  their content-addressed term ID must occur exactly once across the complete
  bundle. A single bounded iterative scan checks all markers, and Lean models
  extra-reference and context/sort substitution rejection. A wholly fresh
  Luna pair is mandatory.

## CALL Anchor-Isolation Luna Round 27

- Verdict: `NON-PASSING / NO ADMISSIBLE FINDING`; immutable staged commit
  `ccbfe7e5e0f360a55c412b5bb2ce38faa230ca7d` (tree
  `3a4bf9ba6375363b418d63085925528c9244f1d6`) is invalidated for review-gate
  purposes.
- The first Luna pair exhausted the timebox without either required verdict.
  A fresh replacement pair also exhausted the timebox and, after forced
  termination, each returned only the bare word `FAIL` with no counterexample,
  location, or evidence.
- Protocol consequence: silence is not `PASS`, and an unsupported one-word
  failure is not an actionable falsification result. No code inference or
  repair is made from these responses. The next ballot must bind a new
  snapshot and provide each reviewer a compact immutable diff packet so an
  evidenced verdict can be completed inside the bound.

## CALL External-Authority Luna Round 28

- Verdict: unanimous `FAIL`; immutable staged commit
  `b0da56e034b094e5b2cf412a435458fb808c8afe` (tree
  `2e61802ec8af71d6e6ca5ec59e94617fcf674705`) is invalidated.
- Both fresh Luna reviewers used the compact 1,027-line immutable review packet
  `/tmp/acgn-luna-round28-review.patch` (SHA-256
  `0335dba5dd8bf23d353f8d7bedbd6a67629833b040db418c90544500e5e950c3`)
  and independently returned the same evidenced finding.
- Counterexample: remove one same-operator nested CALL row together with its
  unused marker term/operator. The remaining row/marker sets and semantic
  operator set still match. Adding an otherwise unused same-operator CALL term
  exposes the dual underconstrained-model form.
- Disposition: this is not repaired with another self-authored digest. Schema
  v10 receives neither raw Alloy source nor an externally pinned occurrence
  commitment, so complete source-occurrence coverage is outside standalone
  authority. Claims are narrowed to unpaired-tampering detection, GC-F108 is
  open, and the ladder stops before Terra/Sol with overall status
  `INCOMPLETE`.

### Bounded MVP disposition after Round 28

The Round 28 failure remains valid historical provenance for the bundle-only
snapshot. The subsequent MVP adds a caller-owned occurrence commitment outside
the bundle. The verifier binds it to the selected input identifier and source
hash, recomputes it from every replayed occurrence key, classifies absence as
`UNCHECKABLE`, and rejects the coordinated nested-row/anchor omission against
the retained full-set value. The CLI inspection command emits an untrusted
candidate only; it is not permitted to bootstrap its own authority.

This closes GC-F108 for executions supplied with an independently retained
commitment. It does not prove raw Alloy parsing or derive that commitment
inside the standalone verifier. Per the bounded MVP stopping rule, no new
open-ended Luna/Terra/Sol ladder was started.

## Correct-Pool Kernel Luna Round 29

- Verdict: `FAIL` (zero of two passes). The reviewed moving-worktree manifest
  contained 298 entries at
  `/tmp/acgn-p0-review-manifest.6z0Bpc.tsv`, SHA-256
  `64e4569fe7e5d5de2633b92c5d9848ce3bbd4459c7e3c834e40b5f7c6f1ed917`.
  Both independent `gpt-5.6-luna` reviewers returned evidenced failures, so no
  Terra or Sol tier was started.
- Union-component counterexample: admission inspected all alternatives inside
  one e-class but omitted a separately allocated malformed CALL e-class unioned
  with the visible invocation. Certification freezing had the same component
  boundary, and the first scan-based repair had quadratic arena cost.
- Temporal counterexample: `pushTemporalNegations` could discard a parent
  `NOT(REF)` before admitting the referenced temporal child's malformed CALL.
- Operator-authority counterexample: exact generic `Bool` metadata, without a
  parser operator identity or internal derivation, authorized AND absorption
  and Boolean ITE expansion.
- Moving-byte repair: union roots retain component memberships; graph admission
  and freezing traverse all reachable members; `NormalForm` admits the entire
  acyclic temporal tree before normalization or dualization; and Boolean
  operator authority is bound either to concordant parser metadata or to an
  exact-opcode internal derivation token. Permanent Java probes and independent
  finite Lean models retain all three witnesses.
- Protocol consequence: this round remains a failure record. A new manifest
  and wholly fresh Luna pair are required before the repair can advance to
  Terra. Whole-artifact status remains `INCOMPLETE` independently of this P0.

## Correct-Pool Kernel Luna Round 30

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The reviewed
  moving-worktree manifest contained 314 records at
  `/tmp/acgn-p0-review-round30.URRs48.tsv`, SHA-256
  `e3dd3e32a1471146bc0e85127ad12f3467245a989d55ee8da3ef6cec93e8acc9`.
  Both fresh `gpt-5.6-luna` maximum-effort reviewers verified all 314 hashes
  before independently returning evidenced failures.
- Stale-authority counterexample: an internally derived OR retained its hidden
  rewrite token after public type and child mutation. Restoring generic `Bool`
  metadata then allowed Boolean absorption on a term not derived by trusted
  normalization.
- Temporal-provenance counterexample: a public exact-Boolean REF named
  `temporal[0:1]`, with no IRAgent/NormalForm issuance evidence, was admitted by
  both `pushTemporalNegations` and direct `TheoryAlloyAdapter` adaptation.
- Moving-byte repair: public semantic mutation now revokes internal operator
  authority; only package-private normalized child assembly preserves it.
  Temporal references are issued and registered by their owning NormalForm,
  tied to source opcode, child identities, index, and arity, and checked in
  every live/certification matrix before rewriting or adaptation. Permanent
  Java probes and finite Lean models retain both witnesses.
- Protocol consequence: this remains a failure record. The repaired bytes need
  a new manifest and a wholly fresh Luna pair before advancing. The global
  Section 3 result remains `INCOMPLETE` because its independent open
  obligations are unchanged.

## Correct-Pool Kernel Luna Round 31

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The reviewed
  moving-worktree manifest contained 314 records at
  `/tmp/acgn-p0-review-round31.tfXNoU.tsv`, SHA-256
  `4dc4d87b2635b4a9768a806fead573c499b7b782a8ef431d2652a06c38649176`.
  Both fresh `gpt-5.6-luna` maximum-effort reviewers verified every manifest
  record and independently produced the same authority-boundary failure.
- Smallest counterexample: a public caller created an exact-Boolean ALWAYS or
  BEFORE source with zero children and no reachable MASG occurrence, then
  called `NormalForm.createTemporalReference(source, 0, 1)`. Temporal-tree
  admission and direct `TheoryAlloyAdapter` adaptation both accepted it. The
  owner record captured only opcode/index/child phases, not the source
  occurrence or source arity.
- Additional local falsification: per-owner authority counters all began at
  one, so a reference moved between structurally similar owners could collide
  with a destination ledger key.
- Moving-byte repair: the metadata-only overload is deleted. The only
  production issuance route consumes a one-use evidence object privately
  constructed by the active IRAgent traversal and bound to graph/node/visit,
  exact source metadata and lineage, exact temporal downlink occurrences,
  owner, arity, and child range. Authority IDs are globally monotonic, and a
  parser-backed transplant regression requires distinct IDs and destination
  rejection. The Lean model now exposes each premise separately instead of
  collapsing provenance into an `ownerBound` Boolean.
- Evidence on repaired bytes: the bounded Java suite passes, the standalone
  Lean module compiles, and the exact 11-file reproducer parses 11/11 files and
  completes all 13 correct-pool tasks in 0.015 s without a strict-kernel
  violation. This round remains a failure record; a new manifest and fresh
  Luna pair are required before any Terra review.

## Correct-Pool Kernel Luna Round 32

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The exact
  314-record moving-worktree manifest was
  `/tmp/acgn-p0-review-round32.0lGSLB.tsv`, SHA-256
  `2462a4aad7fde11119c00a8b9f6a75b22e17b8e0a2967f24129799ccffc1bef3`.
  Both fresh `gpt-5.6-luna` maximum-effort reviewers verified all records and
  independently found the same source-visit defect.
- Cross-visit counterexample: a reused binary temporal parser node had one
  incomplete edge at visit 1 and a complete two-edge bucket at visit 2.
  `downlinksFor` selected visit 2, while evidence declared visit 1 and checked
  every edge against its own visit. IRAgent accepted the mixed occurrence.
- Live-provenance counterexample: after a valid parser-backed `after some S`
  lowering, clearing the source Multigraph vertex and edge ledgers still left
  temporal admission and direct adaptation successful.
- Moving-byte repair: a temporal claim is revalidatable after consumption. It
  retains the exact root-to-source identity path and exact source-visit edge
  occurrences; owner admission requires the original live graph/node/type,
  matching graph-edge counterparts, complete bucket equality, and unique
  positions. A source occurrence can no longer borrow another visit, and
  mutating the source graph revokes an unsealed claim. At the fast-metric or
  certification preparation boundary, one final admission seals the private
  owner-bound claim and releases all parser-graph references. This preserves
  snapshot independence without retaining every source MASG in corpus pools.
- Protocol consequence: Round 32 remains a failure record. Permanent public
  IRAgent regressions and separate Lean premises retain both counterexamples.
  A new manifest and fresh Luna pair are required before Terra.

## Correct-Pool Kernel Luna Round 33

- Verdict: `FAIL`; no Terra or Sol tier was started. The exact 314-record
  moving-worktree manifest was `/tmp/acgn-p0-review-round33.CQ9FOF.tsv`,
  SHA-256
  `251866da2c013031910a1cba31a0d901c3280e2fa172ee90b895f165780eac82`.
  One fresh `gpt-5.6-luna` maximum-effort reviewer produced a decisive
  counterexample, so the other running review was closed without a vote.
- Atomicity counterexample: a blocking EGraphNode freeze hook exposed that the
  NormalForm advertised itself frozen while its backing arena remained
  mutable. A concurrent `setSourceName` succeeded after adapter admission, and
  the adapter certified the changed constant.
- Moving-byte repair: NormalForm no longer publishes frozen before its graph.
  Admission, temporal-reference validation, and an enforced component freeze
  now execute under one arena monitor without overridable dispatch. Fast
  metric preparation uses this same immutable boundary. A hostile subclass
  regression attempts an in-hook mutation; the trusted path must bypass that
  hook, retain the admitted value, and reject later mutation.
- Protocol consequence: Round 33 remains a failure record. A new manifest and
  two wholly fresh Luna reviews are required before Terra.

## Correct-Pool Kernel Luna Round 34

- Verdict: `FAIL`; no Terra or Sol tier was started. The exact 314-record
  moving-worktree manifest was `/tmp/acgn-p0-review-round34.2TqBUO.tsv`,
  SHA-256
  `01af1c05b396fd9e75c706e955546ec28981a0f5f905f2a903a980bb7b64f79a`.
  One fresh `gpt-5.6-luna` maximum-effort reviewer produced a decisive
  counterexample, so the other review was closed without a vote.
- Subclass-dispatch counterexample: a metadata-less underlying CALL subclass
  reported `CONSTANT` from `getOpcode` and replaced `requireAdmittedArity` with
  a no-op. Direct arena admission invoked those overrides, froze the malformed
  node, and the adapter succeeded.
- Moving-byte repair: EGraphNode is now final. Trusted opcode, source, child,
  arity, admission, and freeze behavior therefore has no Java subclass
  dispatch surface. A permanent reflection assertion pins the class boundary,
  and the ordinary post-certification mutation probe still rejects.
- Protocol consequence: Round 34 remains a failure record. A new manifest and
  two wholly fresh Luna reviews are required before Terra.

## Correct-Pool Kernel Luna Round 35

- Verdict: `FAIL`; no Terra or Sol tier was started. The reviewed 314-record
  moving-worktree manifest was `/tmp/acgn-p0-review-round35.Jpat5T.tsv`,
  SHA-256
  `93f0dd28cc49b8b238203c4ba57fba4921e17b59b77aa22f49d8a161bb83eb39`.
  One fresh `gpt-5.6-luna` maximum-effort engineering reviewer supplied a
  decisive reproducible finding, so the other in-flight review was closed.
- Retention counterexample: create one retained root and a disconnected pair
  of e-classes, union only the disconnected pair, and invoke
  `EGraphNode.retainReachable(List.of(root))`. The old implementation added
  every registered class to the reachable set, so the disconnected component
  remained strongly referenced by the arena.
- Moving-byte repair: cleanup now follows child edges and expands only union
  components reached from retained roots. It then removes all other registered
  classes and reports the removal count. The regression removes exactly two
  disconnected classes, preserves a reachable union peer, and observes zero
  removals on a repeated cleanup. `Phase5SourceRules.lean` separately models
  child reachability, union reachability, and the fact that registration alone
  is insufficient.
- Protocol consequence: Round 35 remains a failure record. The bounded Java
  suite and standalone Lean module pass on the repaired bytes. The exact
  11-file P0 corpus parses 11/11 files and completes all 13 correct-pool tasks
  in 0.013 s without a strict-kernel violation. A new manifest and two fresh
  Luna reviews are required before Terra.

## Correct-Pool Kernel Luna Round 36

- Verdict: `FAIL`; no Terra or Sol tier was started. The exact 314-record
  moving-worktree manifest was `/tmp/acgn-p0-review-round36.tsv`, SHA-256
  `2a22bedded2037773ed96cb36147a8ebc72f1b60bf6be61b1a6759afe96d4ef8`.
  One fresh `gpt-5.6-luna` maximum-effort engineering reviewer supplied a
  decisive supported-Java counterexample, so the other review was closed.
- Child-liveness counterexample: after a valid unary temporal occurrence was
  lowered, remove only its child target from `Multigraph.getVertices()` while
  retaining the ordinary source edge. The ticket still found its source, edge,
  visit, position, and bucket, so both owner admission and direct adaptation
  accepted a graph whose downlink target was no longer live.
- Moving-byte repair: each temporal downlink now also requires its exact target
  identity in the graph vertex set until the claim is sealed. The regression
  rejects the child-only removal through both public boundaries, restores the
  target to show the valid graph remains admissible, and separately retains
  edge-removal rejection. Lean models child-target liveness independently from
  source-graph and edge-bucket liveness.
- Protocol consequence: Round 36 remains a failure record. A new manifest and
  two fresh Luna reviews are required before Terra. On the repaired bytes, the
  bounded Java suite and standalone Lean module pass; the exact 11-file corpus
  parses 11/11 files and completes all 13 correct-pool tasks in 0.013 s without
  a strict-kernel violation. The complete bounded Section 3 harness executes
  58 steps with zero executable failures and truthfully remains `INCOMPLETE`
  with 182 open diagnostics.

## Correct-Pool Kernel Luna Round 37

- Verdict: `FAIL`; no Terra or Sol tier was started. The reviewed 314-record
  moving-worktree manifest was `/tmp/acgn-p0-review-round37.tsv`, SHA-256
  `b1b168fa877621eb05a1c25690f078db88f5de12fe73a6ec552e71a2f9b00d32`.
  One fresh `gpt-5.6-luna` maximum-effort engineering reviewer supplied a
  decisive supported-Java counterexample, so the other review was closed.
- Root-liveness counterexample: in a graph whose non-temporal root reaches a
  temporal source, remove only the captured root from the vertex set while
  retaining the root-to-source edge and all downstream vertices. The path
  still had continuous edges and live targets, so the old ticket admitted and
  sealed evidence rooted outside the live graph.
- Moving-byte repair: pre-seal evidence now requires the captured root itself
  in the graph vertex set as well as stable `graph.getRoot()` identity. The
  nested `NOT(AFTER true)` regression rejects root-only removal through owner
  admission and direct adaptation, restores the root to establish specificity,
  and retains the child/edge mutation checks. Lean records root liveness as an
  independent premise.
- Protocol consequence: Round 37 remains a failure record. The bounded Java
  suite and standalone Lean module pass on repaired bytes. The exact P0 corpus
  parses 11/11 files and completes all 13 correct-pool tasks in 0.015 s without
  a strict-kernel violation. A new manifest and two fresh Luna reviews are
  required before Terra.

## Correct-Pool Kernel Luna/Terra Round 38

- Verdict: `FAIL`. The exact 314-record moving-worktree manifest was
  `/tmp/acgn-p0-review-round38.tsv`, SHA-256
  `91bd8bb1e7ee1a268fc87d95be6724dc2e0e33118af40a3705ec52a1ebce65fd`.
  Both independent `gpt-5.6-luna` maximum-effort engineering reviewers
  returned `PASS`, so the unchanged snapshot advanced. One fresh
  `gpt-5.6-terra` maximum-effort reviewer then supplied a decisive supported-
  Java counterexample; the other Terra review was closed and no Sol tier was
  started.
- Shared-freeze counterexample: freeze a child through one parent, retain the
  same child under another unfrozen parent, then saturate the second parent.
  The entry-root mutation check succeeded and recursive saturation changed the
  frozen child's `IN(none, none)` opcode to `CONSTANT`. With a mutable sibling
  before the frozen child, the old traversal could also partially rewrite the
  sibling before failing.
- Moving-byte repair: saturation now checks mutability of every node and every
  reachable union alternative under the arena monitor before its first rewrite,
  and each recursive visit rechecks its node. The regression requires the
  shared frozen child and an earlier mutable sibling both to retain `IN` after
  rejection. Lean models all-reachable mutability and a failed preflight with
  no partial output.
- Protocol consequence: Round 38 remains a failure record despite its Luna
  passes. On repaired bytes the bounded Java suite and standalone Lean module
  pass, and the exact P0 corpus parses 11/11 files and completes all 13 correct-
  pool tasks in 0.014 s without a strict-kernel violation. A new manifest
  restarts at Luna before any Terra or Sol vote can be reused.

## Correct-Pool Kernel Luna Round 39

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The exact
  314-record moving-worktree manifest was `/tmp/acgn-p0-review-round39.tsv`,
  SHA-256
  `0a7b22f6bf50a4dc6cd9e5dfe92440dcb031c075692d01b798d9e0897850d343`.
  Both fresh `gpt-5.6-luna` maximum-effort engineering reviewers supplied
  independent supported-Java counterexamples.
- Temporal-coverage counterexample: attach one valid temporal child to a
  NormalForm whose valid Boolean matrix contains no temporal REF. Because
  completeness compared the empty observed-authority set with the empty issued-
  authority set, admission and freezing both succeeded vacuously.
- Arena-inheritance counterexample: build a valid IMPLIES graph on one thread
  and saturate it on another. The derived NOT constructor selected the executing
  thread's `CURRENT_ARENA`, then failed when attaching an operand from the
  source graph. Snapshot creation had the same transient thread-local choice.
- Moving-byte repairs: temporal child indices now require one exact,
  nonoverlapping, exhaustive owner-issued range plus matrix REF coverage.
  Existing-graph rewrites and snapshots pass the source graph's arena explicitly,
  while only public graph construction consults `CURRENT_ARENA`; the arena field
  is final. Direct Java regressions cover rejection at admission/freeze and
  successful cross-thread IMPLIES saturation. Lean models exact child coverage
  and source-arena inheritance independently.
- Protocol consequence: Round 39 remains a failure record. On the repaired
  bytes, the bounded Java suite and standalone Lean module pass; the exact
  11-file corpus parses 11/11 files and completes all 13 correct-pool tasks in
  0.013 s without a strict-kernel violation. A new manifest and wholly fresh
  Luna pair are required before Terra.

## Correct-Pool Kernel Luna Round 40

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The exact
  314-record moving-worktree manifest was `/tmp/acgn-p0-review-round40.tsv`,
  SHA-256
  `23d23ce214d535f3b676f0315e7a08ce59224b80efac5a91d2e6d4f0deb030a2`.
  Both fresh `gpt-5.6-luna` maximum-effort engineering reviewers verified the
  manifest and supplied independent supported-Java counterexamples.
- Mutation-atomicity counterexample: replacing a unary `NOT` child list with
  two children, or appending a second child, threw only after changing the
  source. Related CALL metadata setters revoked provenance before rejecting an
  invalid negative value.
- Empty-retention counterexample: `retainReachable(List.of())` returned zero
  while a registered two-class union component remained in both arena storage
  layers.
- Moving-byte repairs: child and metadata mutations now preflight their entire
  prospective state before one commit; empty-root retention atomically prunes
  registered classes and union-find state. Java regressions preserve the exact
  prior child identity, arity, and metadata after rejection and require a
  two-class empty closure to report two removals then zero. Lean separately
  models transactional rejection and the empty reachability closure.
- Protocol consequence: Round 40 remains a failure record. On the repaired
  bytes, the bounded Java suite and standalone Lean module pass; the exact
  11-file corpus parses 11/11 files and completes all 13 correct-pool tasks in
  0.016 s without a strict-kernel violation. A new manifest and wholly fresh
  Luna pair are required before Terra.

## Correct-Pool Kernel Luna Round 41

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The exact
  314-record moving-worktree manifest was `/tmp/acgn-p0-review-round41.tsv`,
  SHA-256
  `4e56f0bcf667e1e5e35af3c54ac213182214ae9f403e849d88fae2c9a5960e13`.
  Both fresh `gpt-5.6-luna` maximum-effort engineering reviewers verified all
  hashes and supplied independent supported-Java counterexamples.
- Retired-handle counterexample: empty-root pruning erased class and union-find
  tables but left escaped class handles marked registered. Their next canonical
  lookup dereferenced a missing leader and raised `NullPointerException`.
- Cross-thread temporal counterexample: NormalForm clone/synthetic factories
  still selected the executing thread's arena. A delegated `NOT ALWAYS`
  rewrite changed the child operation before foreign-arena matrix construction
  failed, leaving a split temporal state.
- Moving-byte repairs: pruned classes enter a permanent retired state checked
  by every reuse boundary. All NormalForm-derived nodes inherit their source
  arena, and temporal dualization stages child operations, child matrices,
  parent matrices, and saturation before one nonthrowing commit. Direct Java
  regressions retain both witnesses; Lean models lifecycle rejection and the
  all-or-nothing temporal commit.
- Protocol consequence: Round 41 remains a failure record. On the repaired
  bytes, the bounded Java suite and standalone Lean module pass; the exact
  11-file corpus parses 11/11 files and completes all 13 correct-pool tasks in
  0.014 s without a strict-kernel violation. A new manifest and wholly fresh
  Luna pair are required before Terra.

## Correct-Pool Kernel Luna Round 42

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The exact
  314-record moving-worktree manifest was `/tmp/acgn-p0-review-round42.tsv`,
  SHA-256
  `67d5d848974389da6332aa48c20ac24a73742f9c5751db980c3cd205ddc99cab`.
  Both fresh `gpt-5.6-luna` maximum-effort engineering reviewers verified the
  snapshot and found independent omissions in the new retirement boundary.
- Admission counterexample: a pruned root still crossed
  `requireAdmittedGraph()` because the traversal read its residual nodes without
  checking the retired flag.
- Retention counterexample: an escaped retired class still strongly held its
  node/child graph plus shape, symmetry, and slot caches, despite having been
  removed from arena and union-find tables.
- Moving-byte repairs: admission and union expansion require liveness before
  traversal. Retirement clears all semantic/cache payload while preserving a
  permanent tombstone identity for explicit rejection. Java directly checks
  stale-handle admission; Lean separately pins retired admission rejection and
  zero retained payload. No claim depends on JVM garbage-collection timing.
- Protocol consequence: Round 42 remains a failure record. On the repaired
  bytes, the bounded Java suite and standalone Lean module pass; the exact
  11-file corpus parses 11/11 files and completes all 13 correct-pool tasks in
  0.020 s without a strict-kernel violation. A new manifest and wholly fresh
  Luna pair are required before Terra.

## Correct-Pool Kernel Round 43

- Luna verdict: unanimous `PASS` on the exact 314-record snapshot
  `/tmp/acgn-p0-review-round43.tsv`, SHA-256
  `e9a7703a21bf4b5bee7b8e6c5ece909e9031579e6966707f4ec2260fe37e18e7`.
  This advanced the unchanged bytes to Terra; it did not close the round.
- Terra verdict: unanimous `FAIL`; no Sol tier was started. Both fresh
  maximum-effort reviewers independently identified the temporal lifecycle
  check-then-act race. One also identified the all-null retained-root case.
- Temporal counterexample: `pushTemporalNegations()` could finish staging
  after checking a child mutable, a concurrent `freezeForCertification()`
  could then freeze that child, and the later staged commit could still change
  its operation and matrix.
- Retention counterexample: `retainReachable(singletonList(null))` filtered out
  its only entry but skipped empty-closure cleanup, leaving all current-arena
  registrations alive.
- Moving-byte repairs: a temporal tree now owns one shared lifecycle monitor,
  and all construction, admission, rewrite, and freeze boundaries use it.
  Existing-graph node creation also performs its owner-mutability check and
  construction under the arena monitor. Null-root filtering now dispatches to
  the same complete cleanup as an empty list. Parser-backed concurrency and
  direct retired-handle regressions cover both boundaries; Lean enumerates the
  two serialized lifecycle outcomes and the all-null empty closure.
- Protocol consequence: Round 43 remains a failure record. All later review
  tiers must restart from a new immutable manifest; neither the Luna passes nor
  any earlier review result may be reused.

## Correct-Pool Kernel Luna Round 44

- Verdict: unanimous `FAIL`; no Terra or Sol tier was started. The exact
  314-record moving-worktree manifest was `/tmp/acgn-p0-review-round44.tsv`,
  SHA-256
  `7d7434582cb7c92362c5a88aac953c4654735195ab9abb9d985d9e616a34dcdd`.
  Both fresh maximum-effort Luna reviewers verified the snapshot and supplied
  independent ordinary-Java counterexamples.
- Reserved-identity counterexample: a caller could assign
  `alloy/builtin/univ` through `setSemanticIdentity` on a user-created set node;
  `x in forged` then collapsed to `true`. The repair separates parser/factory
  and derived built-in authority from mutable metadata, and trusted cloning
  transfers that authority only after all revoking metadata operations.
- Retired-node counterexample: pruning retired the escaped e-class handle but
  an escaped node and child-list view still exposed their former semantic
  payload. Retirement now erases node payload and every semantic read checks
  the permanent tombstone, including reads through a previously returned list.
- A focused rerun exposed and repaired one integration error in the first
  authority patch: `removeEndNodes` replaces even a leaf's child list with an
  empty list. The trusted nullary path now preserves built-in authority; adding
  any child or using a public mutation still revokes it. `EGraphSaturationTest`,
  all 332 `AlloySourceRuleRegressionTest` checks, all 533
  `CanonicalAlloyPipelineTest` checks, and the standalone Lean module pass.
- Protocol consequence: Round 44 remains a failure record. A new manifest and
  two wholly fresh Luna reviews are required before any Terra review.

## Correct-Pool Kernel Luna Round 45

- Verdict: `FAIL`; the first completed Luna review invalidated the snapshot,
  so the second review was stopped and no Terra or Sol tier was started. The
  exact 314-record manifest was `/tmp/acgn-p0-review-round45.tsv`, SHA-256
  `9248e61992ab7ffb753453ea2f01598217d1651908b51772eb8d2af53063ead9`.
- Supported source witness: `some (A + none)` and `some A` produced repair
  distance zero but unequal producer observations. The public kernel check
  raised `A zero repair distance lacks producer-observation equality`.
- Transition fault: the certificate matrix was cloned before saturation, while
  relational `+ none` elimination occurred only during saturation. The
  certificate adapter therefore observed the unreduced union and repair
  projection observed its reduced operand.
- Moving-byte repair: authenticated relational `none` units/absorbers,
  self-difference, and Boolean complement/contradiction now close in the
  guarded source-rule pass before the snapshot. ACI normalization stays after
  the snapshot and retains its certificate-governed semantics. Parser-backed
  regressions include union/intersection units, self-difference, Boolean
  complement/contradiction, and union/intersection idempotence.
- Protocol consequence: Round 45 remains a failure record. The repaired bytes
  require a new manifest and two wholly fresh Luna reviews.

## Correct-Pool Kernel Luna Round 46

- Verdict: `FAIL`; one Luna reviewer returned `PASS`, but unanimity is required
  and the other fresh reviewer produced a supported source counterexample. No
  Terra or Sol tier was started. The exact 314-record manifest was
  `/tmp/acgn-p0-review-round46.tsv`, SHA-256
  `fbd6b0c896459206de7aef536acbee42b8684750b4e0bf5bff60bc7c9820a419`.
- Supported source witness: `some (S + S) or not (some S)` and `no none` are
  equivalent, but the first retained a different producer observation while
  its post-ACI repair projection became `true`. Public distance evaluation
  therefore raised `A zero repair distance lacks producer-observation
  equality`.
- Transition fault: the guarded complement pass ran before the certified ACI
  quotient was available. Simple `some (S + S)` was covered by its flat
  construction, but an enclosing rule could not consume that identity. A
  follow-up bound-slot witness showed the same omission when an ACI Boolean
  parent itself collapsed to one dual operand.
- Moving-byte repair: source smart-rule comparison is now read-only and
  quotient-aware. It flattens only the same licensed ACI operator, composes
  slot maps, applies Set sorting/idempotence, and peels a certified singleton
  before duality. It does not reorder the snapshot boundary or conflate
  distinct operators. Parser-backed A/C/I, self-difference, bound-slot, and
  near-miss checks pass, and the standalone Lean module proves the underlying
  relation laws and equality transport.
- Protocol consequence: Round 46 remains a failure record. These repaired
  bytes require a new immutable manifest and two wholly fresh Luna reviews.

## Correct-Pool Kernel Luna Round 47

- Verdict: `FAIL`; no Terra or Sol tier was started. The exact 314-record
  manifest was `/tmp/acgn-p0-review-round47.tsv`, SHA-256
  `f63d898de7d62a5b6cc4ec6e0458b7e8e4f7c2a79b21c1429b8f11bbf0def593`.
  One completed Luna reviewer supplied a supported equality witness. The
  other review was stopped as soon as the snapshot was invalidated.
- Commutative-dual witness: `(S = Protected) or not (Protected = S)` and
  `no none` reached unequal producer observations while repair projection had
  distance zero. Complement comparison consumed equality duality but compared
  its certified commutative children positionally.
- Independent type/occurrence probes on the same moving snapshot found that
  scalar `#S + #T` was mislabeled relational `PLUS`, and that
  `some ((S + T) + (S + T))` rewound both nested shared-symbol occurrences
  into one visit plus an empty advertised visit. A distinct nested-union
  control then exposed grouping sensitivity across parser-inferred result
  carrier widening.
- Moving-byte repairs: exact parser result sort selects `IPLUS`/`IMINUS` before
  policy assignment; nested binary occurrences keep monotone visit identities;
  commutative duals compare composed certified child multisets; and
  parser-authenticated relational union splices across only same-arity
  subfamily-to-outer-carrier widening, retaining explicit leaf coercions.
  Parser-backed positive and near-miss controls pass, and the standalone Lean
  model covers overload selection, integer non-idempotence, visit separation,
  equality commutation, union associativity, and carrier restriction.
- Protocol consequence: Round 47 remains a failure record. All review results
  on its manifest are void for closure; repaired bytes require a new manifest
  and two wholly fresh Luna reviews.

## Correct-Pool Kernel Luna Round 48

- Verdict: `FAIL`; both Luna reviews were stopped before completion and no
  Terra or Sol tier was started. The exact 315-record manifest was
  `/tmp/acgn-p0-review-round48.tsv`, SHA-256
  `cf4177e9630d737ce3aedcc7ee1240f9f54924244bdef46dd537ac6b9068bd48`.
- Supported source witness: a nested formula ITE parsed successfully but the
  production pipeline rejected it with `ITE has arity 0 outside K[3]` before
  any certified observation was produced. The shared ITE symbol's child
  traversal rewound later source occurrence visits, reproducing the binary
  occurrence fault at ternary arity.
- Moving-byte repair: ternary traversal retains every monotonically allocated
  nested occurrence and uses the saved parent visit only when attaching its
  condition, then, and else edges. Parser-backed nested formula and expression
  fixtures exercise both visitor entry points; the formula equals its direct
  branch expansion at certified distance zero. Lean independently proves the
  three later visits pairwise distinct.
- Protocol consequence: Round 48 remains a failure record. All review results
  on its manifest are void; repaired bytes require a new manifest and two
  wholly fresh Luna reviews.

## Correct-Pool Kernel Round 49

- Verdict: `FAIL`. Two fresh Luna reviewers returned `PASS`, but a local
  valid-source reconstruction invalidated the snapshot before the two Terra
  reviews completed; both Terra reviews were stopped and no Sol tier started.
  The exact 315-record manifest was `/tmp/acgn-p0-review-round49.tsv`, SHA-256
  `19596d2b20869f19ce099a24273d550160cb4be70cb89c0f78ec3e5a71421256`.
- Supported source witness: `#Left + #Right`, `Int + Int`, and their `-`
  counterparts have exact carrier `INT` but parser identities
  `PLUS`/`MINUS`. Direct SAT reconstruction proves relational union and
  difference semantics: `Int + Int = Int`, `no (Int - Int)`, and singleton
  cardinality operands union to `1`, not arithmetic `2`.
- Transition fault: the Round-49 candidate selected the operation family from
  exact result carrier and relabeled these supported relational expressions as
  `IPLUS`/`IMINUS`. Carrier and container law had been conflated.
- Moving-byte repair: preserve parser operator identity. A relational Set
  schema may use the exact unary `Int` carrier without globally treating
  `GraphType.INT` as a relation family; genuine integer opcodes retain their
  separate Bag policy. Direct solver and parser-backed kernel regressions plus
  a standalone Lean identity-directed lowering model cover the boundary.
- Protocol consequence: both Luna passes are void for closure. The repaired
  bytes require a new immutable manifest and two wholly fresh Luna reviews.

## Correct-Pool Kernel Luna Round 50

- Verdict: `FAIL`. One Luna reviewer produced a supported source witness, so
  the other still-running Luna was stopped and no Terra or Sol tier started.
  The exact 317-record manifest was `/tmp/acgn-p0-review-round50.tsv`, SHA-256
  `db47454bcdea3f39bd021c61c0c8b0fe2a45aae7653fd5476cfe45e244260b35`.
- Supported source witness: `open util/integer; pred p { 1 fun/add 1 = 2 }`
  parsed as genuine `IPLUS`, then production adaptation failed with
  `Theory-faithful adaptation requires an exact occurrence type for CONSTANT`.
- Transition fault: IRAgent's visit tracker used structural
  `AugmentedNode.equals`. Two separately allocated literal nodes with equal
  value therefore shared a counter, even though each node's parser type was
  stored under its own first occurrence.
- Moving-byte repair: use identity-keyed lowering visits. The exact reviewer
  probe now prepares repeated and nested `fun/add`, `fun/sub`, cardinality,
  negative-literal, relational-Int, and nested-ITE cases; IPLUS remains fixed
  C-Bag arity two under overflow-forbidding semantics.
- Protocol consequence: Round 50 remains a failure record. Repaired bytes
  require a new immutable manifest and two wholly fresh Luna reviews.

## Correct-Pool Kernel Luna Round 51

- Verdict: `FAIL`. One fresh Luna reviewer found a supported public-boundary
  counterexample, so the other Luna review was stopped and no Terra or Sol
  tier started. The exact 317-record manifest was
  `/tmp/acgn-p0-review-round51.tsv`, SHA-256
  `2b964fd2604ef809682a506ef7b0d24776d21644fa239eec9e0b940b5a178594`.
- Supported source witness: `sig S {}; pred mixed { some (Int + S) }` parsed
  as relational `PLUS` with exact alternatives `Int` and `S`. The producer
  erased `S`, exported an Int-only ACI union, and the freshly built standalone
  verifier returned `VERIFIED`. Alloy independently satisfies
  `some S and (Int + S) != Int`, making the accepted observation false.
- Transition fault: `ExactAlloyType.from` interpreted `Type.is_int()` as
  exclusivity. In Alloy it also holds when Int is one member of a heterogeneous
  unary type family.
- Moving-byte repair: exact Int classification now requires exactly one
  nonempty unary product whose column is the parser's built-in `Sig.SIGINT`.
  Mixed Int/signature products proceed through ordinary alternative extraction
  and retain a correlated relation-family carrier. Parser extraction,
  producer equality/distance, direct SAT, export/verifier, and standalone Lean
  obligations exercise both the witness and exact-Int controls.
- Protocol consequence: Round 51 remains a failure record. No result from its
  reviewers counts toward closure; repaired bytes require a new immutable
  manifest and two wholly fresh Luna reviews.

## Correct-Pool Kernel Round 52

- Verdict: `FAIL`. Two fresh Luna and two fresh Terra reviewers returned
  `PASS`, but one final-tier Sol reviewer found a supported source
  counterexample. One parallel Sol worker was rejected by an unrelated service
  classifier and its replacement was stopped immediately after the snapshot
  failed; neither contributes a verdict. The exact 318-record manifest was
  `/tmp/acgn-p0-review-round52.tsv`, SHA-256
  `db02f06bf333fec36ba1dd751ac963fea40d7427b4bdea952ab77cad78f20812`.
- Supported source witness: with `sig C extends P {}`, Alloy reports no
  counterexample to `((Int + C) + P) = (Int + (C + P))`. Production instead
  emitted distinct digests and repair distance 4 for predicates containing
  the two groupings.
- Transition fault: nested PLUS widening required literal exact-type
  alternative containment. The outer family contained `P` and `Int`; the
  nested family contained `C` and `Int`. Although live parser evidence proved
  `C -> P`, the literal check blocked only the left grouping, making ACI
  normalization grouping dependent.
- Moving-byte repair: nested relation-family inclusion is now reconstructed
  per correlated product. Every candidate column must reach the corresponding
  carrier column through authenticated ancestry from the identical parser
  module. Reverse ancestry, siblings, cross-module lookalikes, arity changes,
  non-PLUS operators, and absent evidence remain barriers. Parser-backed,
  direct Alloy, exact reviewer-probe, and Lean positive/negative checks cover
  the boundary.
- Protocol consequence: every Round-52 pass is void for closure. Repaired
  bytes require a new immutable manifest and a wholly fresh review ladder.

## Correct-Pool Kernel Luna Round 53

- Verdict: `FAIL`. One fresh Luna reviewer found a supported source
  counterexample, so the other Luna review was stopped and no Terra or Sol
  tier was started. The exact 318-record manifest was
  `/tmp/acgn-p0-review-round53.tsv`, SHA-256
  `879a35e7140b292f17e91274b3a2250d61ba020cc159073679ea1720b9b9cc12`.
- Supported source witness: Alloy proved `(P & univ) = P`, but predicates
  containing `some (P & univ)` and `some P` produced different certified
  digests and repair distance 3.
- Transition fault: `R & univ -> R` and the related authenticated set-constant
  identities were available only in post-snapshot saturation. The producer
  therefore observed a raw term while the repair projection observed its
  reduced form.
- Moving-byte repair: authenticated `R & univ`, `R + univ`, `R - none`,
  `R - univ`, and `none - R` now close before the certification snapshot and
  remain mirrored in saturation. Recognition still requires the internal
  parser-factory or trusted-derived built-in token. Direct Alloy, parser-backed
  producer/distance, forged-name, and Lean relation-equation checks cover the
  boundary.
- Review clarification: a separate suspicion that `#A + #B` denotes integer
  arithmetic is refuted by direct Alloy execution. Parser `PLUS` is relational
  union even on the unary `Int` carrier and is correctly ACI; genuine
  arithmetic is parser `IPLUS` (for example `fun/add`) and remains
  non-idempotent. The formerly empty nested `PLUS` witness was real but is
  already tracked as GC-F158 and remains covered by the monotone-occurrence
  regression.
- Protocol consequence: Round 53 remains a failure record. Repaired bytes
  require a new immutable manifest and a wholly fresh review ladder.

## Correct-Pool Kernel Luna Round 54

- Verdict: `DISCOVERY`, therefore the snapshot is invalid. Two fresh Luna
  reviewers returned `PASS`, but their reasoning and the surrounding review
  context contained the valid Alloy law `R subset C => R + C = C`, with the
  concrete source witness `sig A, B extends P {}; some (A + B + P)` versus
  `some P`. A reviewer `PASS` cannot suppress such a discovery under the
  controlling protocol. The Terra tier was stopped and produces no ballot.
- Snapshot: `/tmp/acgn-p0-review-round54.tsv`, 318 records, SHA-256
  `eb901f8ae043d01b70e9e599c8fee67444c8e4270d3b58749a2e9dc442a07a45`.
- Supported-path result: Alloy found no counterexample, while the production
  observations differed and the repair distance was 4.
- Repair: the actual parser-authenticated full signature now absorbs every
  same-module ancestry-proved subrelation in its relational-union region,
  including through reassociation. The implementation does not grant carrier
  authority to an arbitrary expression merely because its result is typed by
  that signature. `extends`, subset-`in`, composite, sibling-only, unrelated,
  and typed-field controls are retained in parser-backed tests, and Lean proves
  direct plus contextual subset absorption.
- Protocol consequence: both Luna `PASS` reports are void. The repaired bytes
  require a new immutable manifest and a wholly fresh review ladder.

## Correct-Pool Kernel Luna Round 55

- Verdict: `FAIL`. Both fresh Luna reviewers independently found the supported
  subset-signature carrier defect, so no Terra or Sol tier was started. One
  review also contained the valid latent discovery `none in R = true`; it is
  promoted to `DISCOVERY` despite the reviewer's top-level failure category.
- Snapshot: `/tmp/acgn-p0-review-round55.tsv`, 318 records, SHA-256
  `9003bde20ec7b27f2936094cb537b0d351ad47ffd3833f5b543c69bb86803527`.
- Minimal failure: `sig P {}; sig X in P {}; sig Y in X {}` with predicates
  `some (Y + X)` and `some X`. Alloy found no counterexample to `Y + X = X`,
  while production reported unequal observations and repair distance 3.
- Minimal discovery: `none in X` versus `no none`. Alloy found no
  counterexample, while production again retained distance 3. Generalizing the
  witness also exposed that plain relational `ARROW` and `JOIN` had not
  propagated authenticated empty operands.
- Transition faults: parser exact types retain primitive ancestry but erase the
  named subset declaration boundary; the full-carrier rule therefore could not
  prove `Y subset X`. Empty-subset normalization was syntactically restricted
  to `none in none`, and empty product/composition results remained structural.
- Moving-byte repair: actual signature leaves carry runtime-only same-module
  parser declaration authority. Named carriers consume declaration-DAG
  ancestry; exact-family containment remains limited to primitive carriers.
  Same-arity `none in R` and its dual now close before certification, and exact
  relation-valued plain `ARROW`/`JOIN` propagate an authenticated empty operand
  with the result arity. Direct Alloy, parser-backed equality/distance,
  sibling/typed-expression controls, and Lean transitivity, subset, product,
  and composition proofs cover the schemas.
- Repair-audit discovery: the parser convenience method
  `Sig.isSameOrDescendentOf` is not itself a sound containment certificate for
  `sig X in A+B`, because it accepts either branch. Before freezing the next
  snapshot, the implementation was tightened to unique-parent recursion for
  primitive signatures and all-parent recursion for subset signatures. Alloy
  finds `some X-A` while proving `X` below a common ancestor of both parents;
  both controls and their Lean counterparts pass.
- Protocol consequence: both Round-55 findings invalidate the snapshot and all
  of its reviewer output. Repaired bytes require a new immutable manifest and
  a wholly fresh review ladder.

## Post-Round-55 Repair Evidence

- The bounded Java suite passes, including 768 certificate-integrated pipeline
  checks, 2,266 repair-distance checks, direct visualization and saturation
  checks, all theory tests, and distance-artifact regeneration.
- Standalone `Phase5SourceRules.lean` compiles with the declaration-DAG,
  empty-subset, product, and composition obligations.
- `/tmp/acgn-kernel-round57-20260826` parses 11/11 focused corpus files and
  completes all 13 correct-pool tasks without a kernel exception.
- `/tmp/acgn-section3-round56-20260826` is intentionally invalid evidence: 57
  of 58 steps passed, while `input-manifest-stability` correctly failed because
  the multi-parent repair and documentation were still changing during that
  run. No result from that moving snapshot is reused. A stable rerun is
  required before the next reviewer snapshot.

## Correct-Pool Kernel Luna Round 57

- Verdict: `INVALIDATED WITHOUT BALLOT`. Both Luna reviewers exceeded the
  bounded review window and were stopped after the main-agent audit found a
  supported semantic omission on the same immutable snapshot. Their processes
  returned no final report, so neither contributes a `PASS` or failure claim.
- Snapshot: `/tmp/acgn-p0-review-round57-full.tsv`, 582 records, SHA-256
  `ef4057ef1e381b25f357984e2d0d4a7d5584d443ff95e9859b0806a4d23e3b9e`.
- Mandatory discovery: `abstract sig P {}; sig A, B extends P {}` generates
  the Alloy fact `P = A + B`. Alloy found no counterexample, but the production
  pipeline reported unequal observations and repair distance 3 for `some P`
  and `some (A+B)`.
- General repair: live parser declarations now derive a carrier only from a
  complete, nonempty set of direct `extends` branches, recursively through
  abstract children. Every additional operand must be certified below the
  carrier. The selected representative is the highest covered abstract
  ancestor, so singleton abstract chains agree with explicitly named parents.
  Subset-`in` declarations do not satisfy an abstract-cover branch.
- Evidence: direct Alloy assertions establish direct, nested, singleton, and
  contextual cover laws. SAT controls retain missing branches, non-abstract
  parent remainder, and subset-only parent remainder. The integrated pipeline
  gives certified equality and zero distance only for the admitted laws, and
  standalone Lean proves cover, nesting, absorption, and the missing-branch
  countermodel.
- Protocol consequence: Round 57 and all moving repair bytes are permanently
  invalid review evidence. A stable test pass and new immutable manifest are
  required before restarting at the Luna tier.

## Correct-Pool Kernel Luna Round 58

- Verdict: `DISCOVERY / SNAPSHOT INVALIDATED`. Two independent Luna reviewers
  examined immutable manifest `/tmp/acgn-p0-review-round58-full.tsv` (582
  records; SHA-256
  `9ab8057a19e3ae0f0ab9b59fd6adf0e28f832b2e96e388c06fd076794027ffcf`).
  Neither report is a passing ballot because each contained mandatory semantic
  discoveries.
- Reviewer 1 identified omitted relational schemas for the reserved identity,
  transpose, and nested closure. Its illustrative transpose term was malformed
  for a unary join result; independent validation reduced the valid witness to
  a binary field `r` and established `~(~r)=r`.
- Reviewer 2 independently identified the two-sided `iden` law. It also tested
  the conjecture that an abstract signature with no direct extensions is empty;
  Alloy produced a satisfying nonempty parent, so that conjecture was rejected
  and no rewrite was admitted.
- Independent semantic validation: Alloy found no counterexample to
  `iden.R=R`, `R.iden=R`, `~(~R)=R`, `~(A->B)=B->A`,
  `^(^R)=^R`, `*(*R)=*R`, `^(*R)=*R`, or `*(^R)=*R`.
  It produced concrete countermodels for wrong transpose order, arbitrary JOIN
  operands as identities, and `^R=*R`. The production snapshot retained
  positive repair distances before the repair.
- General repair: only parser-factory `iden` authority enables exact relational
  JOIN identity elimination; exact binary transpose is involutive and reverses
  only plain binary ARROW; exact nested closure selects RCLOSURE iff either
  layer is reflexive. Enum atom-cover coverage was added explicitly without
  broadening the existing abstract-cover rule.
- Evidence on repaired moving bytes: parser-backed certified equality and zero
  distance cover left/right/middle/all-identity JOIN, double transpose, reversed
  product, all four closure combinations, and enum cover. SAT near misses remain
  distinct. `MASGVisitorTypeRegressionTest` executes the corresponding Alloy
  commands, and `Phase5SourceRules.lean` proves authority, composition,
  transpose, product, and finite-path closure obligations without producer
  imports.
- Protocol consequence: the Round-58 manifest and reports are historical fault
  evidence only. The repaired bytes require complete checks, a new immutable
  manifest, and a fresh Luna-to-Terra-to-Sol ladder.

## Correct-Pool Kernel Luna Round 59

- Verdict: `DISCOVERY / SNAPSHOT INVALIDATED`. The first two Luna processes
  exceeded their bounded window and were closed without ballots. Of two fresh
  bounded replacements, one was closed without a report and one returned
  `FAIL` against immutable manifest
  `/tmp/acgn-p0-review-round59-full.tsv` (582 records; SHA-256
  `325889ee431cfd7dfde6674b36f816192a02a135b9f9e4b9f8c8b584126c26ce`).
- Allegation: with `abstract sig A {}; sig B extends A {}; sig C {}`, the
  abstract-cover helper could collapse `B+C` to `A` despite unrelated `C`.
  Independent parser-to-certificate validation refuted that allegation:
  `some (B+C)` and `some A` produced unequal certified observations at repair
  distance 3. The reviewer had stopped before the production
  all-terminals-within-carrier gate in `parserCertifiedAbstractUnionCarrier`.
- Promoted discovery: that exact downstream guard had no explicit unrelated
  terminal regression. A helper-local analysis could therefore miss the
  distinction between proposing and admitting an abstract carrier.
- General coverage repair: the production test now keeps a complete direct
  abstract cover plus an unrelated signature distinct from the carrier at
  positive distance. Direct Alloy supplies a nonempty outside atom, and
  standalone Lean proves that any outside witness prevents the enlarged union
  from equaling the carrier. No implementation rule changed.
- Protocol consequence: even though the alleged defect was false, the valid
  omitted-coverage discovery voids Round 59. Complete checks and a new immutable
  manifest are required before restarting the Luna tier.

## Correct-Pool Kernel Round 60

- Verdict: `TERRA DISCOVERY / SNAPSHOT INVALIDATED`. Immutable manifest
  `/tmp/acgn-p0-review-round60-full.tsv` contained 582 records and had SHA-256
  `7d5e6d83b52a2dca9887f65e67818c118a7d9e7ff56ccedfaaa253549220f9d0`.
  Two Luna max reviewers returned `PASS` after one false `R+none` discovery
  was corrected against the guarded pre-certificate rule and existing parser
  regression. Both later Terra max reviewers found independent mandatory
  equivalences.
- Terra discovery 1: Alloy proves `~iden=iden`, `^iden=iden`, and
  `*iden=iden`. Independent solver checks were UNSAT, while all three
  parser-to-certificate comparisons returned unequal observations at distance
  2.
- Terra discovery 2: for `abstract sig P` and `B,C extends P`, Alloy proves
  `(B->B)+(B->C)=B->P`. A nonempty `B,C` model exists, but both normal and
  parser-source-bound certified preparation returned distance 7.
- General repair 1: transpose and both closure operators adopt only an
  authority-bearing `iden` child with identical exact occurrence evidence.
  The source pass and saturation agree.
- General repair 2: one complete abstract cover may lift through either
  coordinate of plain binary ARROW terms when all remaining coordinates are
  identical and slot-free. The result exact type is independently derived as
  the Cartesian product of parser-authenticated factor types. A diagonal family
  cannot collapse because it lacks the full Cartesian grid; unrelated product
  alternatives also block the rule.
- Evidence on moving repaired bytes: the two Terra probes now report zero for
  all four positive comparisons. The integrated parser suite covers both
  product orientations and negative grid/outsider controls; direct Alloy
  checks the laws and witnesses; standalone Lean proves product
  distributivity, abstract-cover lifting, the diagonal countermodel, identity
  transpose, and both identity closure fixed points.
- Protocol consequence: every Luna and Terra ballot on Round 60 is historical
  evidence only. Full checks, a new immutable manifest, and a wholly fresh
  Luna-to-Terra-to-Sol ladder are required.

## Correct-Pool Kernel Round 61

- Verdict: `LUNA DISCOVERY / SNAPSHOT INVALIDATED`. Immutable manifest
  `/tmp/acgn-p0-review-round61-full.tsv` contained 582 records and had SHA-256
  `9758b53794d0869cb0f882f4e1b32fce8f7e58af70a03d88e19ade52c2169547`.
  One Luna max reviewer returned `PASS`; the other returned `DISCOVERY`.
  The passing ballot cannot suppress the independently validated discovery.
- Reviewer discovery: the product-cover rule called its input "plain" only
  when the raw EGraph node had two children. Alloy's source tree remains binary
  for dependent-chain commitments, but longer plain products are presented as
  variadic ordered sequences after certified adaptation. The smallest witness
  was `(B->B->B)+(B->B->C)=B->B->P` for a complete abstract cover
  `P=B+C`.
- Independent validation: Alloy found no counterexample and found a nonvacuous
  model with both branches populated. Before repair, production preparation
  returned unequal observations and distance 10. The main audit also proved
  the stronger complete-grid law
  `(B->B)+(B->C)+(C->B)+(C->C)=P->P`; production missed it, while Alloy
  produced counterexamples for the diagonal and three-cell partial grids.
- General repair: source ARROW trees are flattened only into a temporary factor
  sequence for proof analysis. One complete parser-owned cover may reduce any
  coordinate of a subgroup whose other coordinates are semantically identical.
  The residual relational union is strictly smaller and is normalized
  recursively, which closes complete grids across multiple coordinates without
  admitting a diagonal or partial grid. Every derived product is rebuilt as a
  binary source tree and receives an independent parser-authenticated Cartesian
  exact-type proof at each node.
- Repair evidence: ternary and full-grid production probes now report certified
  equality and distance zero; diagonal and partial-grid probes remain nonzero.
  `CanonicalAlloyPipelineTest` includes all four boundaries, direct Alloy
  commands prove the positive laws and negative witnesses, and standalone Lean
  proves variadic distribution, cover lifting, an explicit four-cell product
  construction, and the missing-cell countermodel.
- Protocol consequence: both Round-61 Luna reports are historical finding
  evidence only. Complete checks and a new immutable manifest are required
  before restarting with two fresh Luna reviewers.

## Correct-Pool Kernel Round 62

- Verdict: `LUNA FAIL / SNAPSHOT INVALIDATED`. Immutable manifest
  `/tmp/acgn-p0-review-round62-full.tsv` contained 582 records and had SHA-256
  `5ed21051b7b1ef22060f8855f0885b8d8123c60b260e91b5d7205937997b7e6e`.
  One Luna max reviewer returned `PASS`; the other returned `DISCOVERY`. The
  main audit independently reproduced the candidate and promoted it to `FAIL`
  because valid Alloy source terminated with an exception.
- Smallest witness: with `abstract sig Parent {}` and `sig A,B extends Parent`,
  Alloy proves `(A->Int)+(B->Int)=Parent->Int` and admits a model with both
  branches populated. The Round-62 producer threw from
  `ExactAlloyType.parserCertifiedCartesianProduct` before producing an
  observation because exact `Int` has scalar kind `INT`, not `RELATION`.
- General repair: exact `Int` keeps its scalar kind so parser-directed integer
  operator dispatch cannot be confused with relational union. `fromParser`
  now attaches transient same-module authority to an exact Int occurrence.
  The Cartesian proof constructor may interpret only that live evidence as the
  unary set column `Int`; public synthetic `intType()`, serialized evidence,
  and evidence from another parser module remain inadmissible.
- Repair evidence: the direct Alloy check is UNSAT and its nonvacuity run is
  SAT; the repaired production comparison reports certified equality and
  distance zero. Exact-type tests prove the one-column product shape and reject
  synthetic and mixed-module factors. The parser-backed pipeline suite and
  Alloy command matrix include the witness. Standalone Lean instantiates the
  abstract-cover product law with an integer-set coordinate.
- Protocol consequence: both Round-62 Luna reports are historical evidence
  only. The repaired bytes require the complete checks and a new immutable
  snapshot before a fresh Luna tier.

## Correct-Pool Kernel Round 63

- Verdict: `SOL DISCOVERY / SNAPSHOT INVALIDATED`. Immutable manifest
  `/tmp/acgn-p0-review-round63-full.tsv` contained 582 records and had SHA-256
  `6c428e9fb43812227e3717d43b0cf8df9aa845d103544cf843140a84a3973e40`.
  Two Luna max and two Terra max reviewers returned `PASS`. Both Sol max
  reviewers then returned independent `DISCOVERY` verdicts, so all earlier
  ballots on the snapshot are historical only.
- Sol discovery 1: Alloy proves converse distributes through relational union,
  intersection, and difference. Independent checks found no counterexample and
  found nonvacuous relations, while the production pipeline returned distance
  5 for each of `~(r+s)`/`~r+~s`, `~(r&s)`/`~r&~s`, and
  `~(r-s)`/`~r-~s`.
- Sol discovery 2: Alloy proves ordinary Cartesian distribution such as
  `(A->A)+(A->B)=A->(A+B)`. The same independent run found both right and left
  laws nonvacuous and saw production distance 5. The existing product helper
  could factor only when the varying coordinate reconstructed a full signature
  or abstract cover.
- General repair 1: parser-authenticated exact binary converse now reverses
  correlated type columns and distributes through only `PLUS`, `INTERSECT`,
  and `MINUS`, preserving the operator. Derived operands recursively consume
  the existing plain-product reversal. Saturation mirrors the guarded source
  schedule; no override or unrelated operator receives the rule.
- General repair 2: complete product subgroups may now retain an ordinary
  parser-authenticated coordinate union when no smaller certified carrier is
  available. Strict residual reduction handles finite complete grids. Partial
  and diagonal grids cannot create missing cells. Derived products remain
  ordered binary ARROW source trees with exact Cartesian proofs.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` reports 965 checks; all
  bounded Java suites pass; direct Alloy proves seven distribution laws and
  supplies four positive/negative witnesses. The producer additionally closes
  converse distribution through a product union and a quantified binary-
  relation slot; `Phase5SourceRules.lean` proves
  converse involution and all three container laws in addition to the existing
  product distribution and complete-grid boundary.
- Protocol consequence: Round 63 contributes findings, not review credit. The
  repaired bytes require full assurance, a new immutable manifest, and a fresh
  Luna-to-Terra-to-Sol ladder.

## Correct-Pool Kernel Round 64

- Verdict: `LUNA DISCOVERY / SNAPSHOT INVALIDATED`. Immutable manifest
  `/tmp/acgn-p0-review-round64-full.tsv` contained 582 records and had SHA-256
  `48a2b60c0ab61bf41f26bde37e2bf4f6c6345216e0aa3121abec386d9037cbbd`.
  One Luna max reviewer returned `DISCOVERY`; the other returned `PASS` with
  no latent finding beyond the independently identified slot-product gap.
  No Terra or Sol ballot was admissible after the first discovery.
- Main-agent discovery: the product proof flattened only slot-free factors.
  The minimized valid source `(x->A)+(x->B)` versus `x->(A+B)` had an UNSAT
  Alloy inequality check and SAT nonvacuity witness, but production distance
  6. The generalized repair preserves composed invocation maps throughout
  fixed-coordinate subgroup and complete-grid factoring. Bound fixed-left,
  fixed-right, and full-grid cases now close; a partial grid remains distinct.
- Luna discovery: Boolean and relational lattices lacked the two absorption
  and two distributive laws. Independent Alloy checks proved all eight laws
  over arbitrary overlapping sets, while production distances ranged from 5
  through 9. The first generalized repair exposed a second concrete fault:
  copying an outer exact type onto `B+C` or `B&C` either retained a hidden type
  mismatch or authorized an unrelated subrelation absorption.
- General repair: the shared source/saturation normalizer orients distribution
  toward a factored form and applies absorption without expansion. Every new
  relational intermediate obtains its own exact union or ancestry-intersection
  proof from operands in one live parser module; a proved empty overlap retains
  arity and transient module authority without inventing columns. Boolean
  normalization still requires formula authority. Synthetic, serialized,
  cross-module, wrong-arity, operator, complete-grid, and partial-grid barriers
  remain explicit.
- Moving-byte evidence: the focused pipeline suite reports 1,048 checks and
  the expanded Alloy command matrix passes. The complete bounded assurance
  run at `/tmp/acgn-section3-round65-pre.TROBuw` executes 58/58 steps with no
  executable failure and remains honestly `INCOMPLETE` with 186 open
  diagnostics. The exact 11-file correct-pool corpus parses 11/11 sources and
  completes all 13 AST-distinct comparisons without a kernel exception in
  `/tmp/acgn-kernel-round65-valid.VF75fM`. `Phase5SourceRules.lean` proves
  all Boolean and pointwise relational lattice laws plus parametric bound-slot
  product distribution. These results are repair evidence only; changed bytes
  require full assurance and a new immutable Round-65 snapshot.
- Protocol consequence: Round 64 contributes findings, not review credit. The
  Luna-to-Terra-to-Sol ladder restarts only after the complete bounded gate
  passes on the repaired candidate.

## Correct-Pool Kernel Round 65

- Verdict: `LUNA FAIL / DISCOVERY / SNAPSHOT INVALIDATED`. Two independent
  Luna max reviewers examined immutable manifest
  `/tmp/acgn-p0-review-round65-full.tsv` (582 records; SHA-256
  `abc8a66992635a02260d395ca0dc10e68d0154ca9ad3d613197a83b83ce9be23`).
  Both found the repeated composite-carrier failure already recorded in
  GC-F189: mutually containing operands could delete each other rather than
  retaining one ACI representative. One reviewer additionally supplied the
  sound algebraic candidates promoted to GC-F190. Neither report is a ballot.
- Independent validation: the main audit reproduced the empty/repeated-union
  failure from valid Alloy source, retained one stable representative under
  mutual containment, and reran the duplicate ACI pair. It then minimized and
  solver-checked all four difference schemas, both JOIN/union distribution
  directions, and `some`/`no` over union. Alloy found no counterexample and
  admitted the two nonvacuity controls. JOIN over intersection and the two
  cardinality/intersection analogues had concrete countermodels and remain
  outside the rewrite system.
- Further failure exposed by the generalized tests: relation-valued predicate
  parameters were weakened to unary primitive binding evidence. Exact binary
  JOIN input therefore failed certified binder construction. Binding identity,
  certified lowering, and repair projection now retain the complete parser
  relation arity.
- Confluence and provenance repairs: cardinality is oriented from relational
  union into Boolean ACI, duplicates are removed before expansion, derived
  Boolean authority is installed after child construction, and finite covered
  dual branches close under the certified Boolean policy. Cardinality tests are
  separate from the nested-`PLUS` splice fixture, so exact flat-construction
  evidence is still mandatory whenever that operator survives normalized-IR
  preprocessing.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,167 checks;
  `AlloySourceRuleRegressionTest` passes 332; `QuotientRepairDistanceTest`
  passes 2,266; saturation, MASG exact-type, and backtranslation suites pass.
  `Phase5SourceRules.lean` independently proves the admitted schemas, finite
  covered-dual closure, and unary/binary binding-profile separation. These
  results are repair evidence only.
- Protocol consequence: every Round-65 report is historical finding evidence.
  The changed bytes require the complete bounded checks and a wholly fresh
  Luna-to-Terra-to-Sol ladder on one new immutable snapshot.

## Correct-Pool Kernel Round 66

- Verdict: `MAIN-AGENT DISCOVERY / SNAPSHOT INVALIDATED`. Two independent Luna
  max reviewers examined immutable manifest
  `/tmp/acgn-p0-review-round66-full.tsv` (543 records: 542 repository files and
  one external governing prompt; SHA-256
  `8b151fa11087f758277d88e52616e340bb5762046b36b0a6d472fb4b0901e79c`).
  One returned `PASS`. The other returned `DISCOVERY` for parser-opcode-sensitive
  `Int` addition and subtraction; independent inspection found this was an
  already implemented, solver-tested, Lean-proved, and logged rule under
  P5-F30/GC-F162 rather than an omitted opportunity. Neither result earns
  ballot credit because the main-agent falsification below changed the bytes.
- Main-agent discovery: valid Alloy proved `((A-B)-C)=A-(B+C)` with no
  counterexample at scope 3 and admitted a nonempty witness, while the production
  quotient reported distance 5. Alloy separately produced a counterexample to
  the right-nested reassociation `((A-B)-C)=A-(B-C)`.
- General repair: only a left-nested relational `MINUS` accumulates removed
  operands into a parser-certified ACI union. The implementation composes slot
  invocations, requires live exact relation evidence, retains the outer exact
  result, and repeats the binary schema to normalize an arbitrary finite left
  chain. Right-nested subtraction is unchanged, and synthetic exact types do
  not authorize the rule.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,184 checks with
  binary and four-level positive pairs plus the right-nested barrier;
  `EGraphSaturationTest` retains the authority-loss control. Direct Alloy gives
  UNSAT for the generalized law and SAT for its nonvacuity and right-nested
  controls. `Phase5SourceRules.lean` proves the universal binary schema and a
  concrete right-nested countermodel. P5-25 and GC-F195 record the bounded
  claim and incident.
- Protocol consequence: Round 66 is finding evidence only. A complete bounded
  run and a fresh Luna-to-Terra-to-Sol ladder are required on a new immutable
  manifest.

## Correct-Pool Kernel Round 67

- Verdict: `MAIN-AGENT DISCOVERY / SNAPSHOT INVALIDATED`. Two fresh Luna max
  reviewers returned `PASS` on immutable manifest
  `/tmp/acgn-p0-review-round67-full.tsv` (543 records; SHA-256
  `9b39bf8f7a61e2108930c6b59f80911605fe29ad0d32239139c0c7bff607cc89`).
  Both verified the manifest and reported no new rule. Under the controlling
  protocol, those PASS reports do not suppress the two independently validated
  discoveries below and earn no ballot credit.
- Main-agent discoveries: direct Alloy checks proved
  `A-(B-C)=(A-B)+(A&C)` and `(A-B)&C=(A&C)-B`; production distances were 9
  and 4. The second law generalized pointwise to
  `(A-B)&(C-D)=(A&C)-(B+D)`. Alloy found no counterexample for any admitted
  schema and retained a satisfiable nonvacuity witness.
- General repair: right-nested difference now expands by its own law rather
  than borrowing left-nested reassociation. A certified intersection collects
  all ordinary and kept operands by intersection and all removed operands by
  union. Every intermediate type is derived from one live parser module,
  composed slot invocations are retained, generated branches are normalized
  recursively before the source snapshot, and synthetic exact evidence cannot
  authorize either rule.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,202 checks with
  right-nested, single-intersection, and two-difference pairs at certified
  distance zero; the left/right nesting distinction remains positive.
  `EGraphSaturationTest` retains separate authority-loss controls.
  `Phase5SourceRules.lean` proves the right-nested law and both intersection
  schemas. P5-26/P5-27 and GC-F196/GC-F197 record the claims and incidents.
- Protocol consequence: Round 67 is finding evidence only. The complete
  bounded gate and the Luna-to-Terra-to-Sol ladder restart on changed bytes.

## Correct-Pool Kernel Round 68

- Verdict: `LUNA DISCOVERY / SNAPSHOT INVALIDATED`. Two fresh Luna max
  reviewers examined immutable manifest
  `/tmp/acgn-p0-review-round68-full.tsv` (543 records; SHA-256
  `7d401dc58849753d86a13ecbdb4e51429f07424f548683713434407205127aa0`).
  One returned `PASS`; the other returned `DISCOVERY` for Cartesian-product
  difference. The PASS cannot suppress that finding, and changed bytes earn
  neither report ballot credit.
- Independent validation: production gave distance 6 for each of
  `(A->C)-(B->C)` versus `(A-B)->C` and `(A->B)-(A->C)` versus
  `A->(B-C)`. Direct Alloy checks found no counterexample at scope 3. A
  two-coordinate generalization was rejected by a satisfiable Alloy witness.
  The same audit promoted overlapping left/right difference normalization and
  a three-difference intersection from temporary probes into permanent
  coverage.
- General repair: equal-length plain Cartesian products factor only when one
  certified coordinate invocation differs. The coordinate difference requires
  live same-module and same-arity parser evidence; the ordered ARROW chain and
  composed slot maps are rebuilt without changing the other coordinates.
  Multiple changed coordinates stay explicit.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,244 checks with
  left, right, and ternary-middle coordinate pairs at certified distance zero,
  plus the multi-coordinate barrier. Exact-type construction rejects
  synthetic, serialized, cross-module, and arity-mismatched evidence.
  `EGraphSaturationTest` retains the synthetic-authority barrier, and
  `Phase5SourceRules.lean` proves the three positive schemas, a concrete
  two-coordinate countermodel, and three-branch difference extraction.
  P5-28/P5-F64 and GC-F198 record the bounded claim and incident.
- Protocol consequence: Round 68 is finding evidence only. The full bounded
  gate and reviewer ladder restart from a newly frozen manifest.

## Correct-Pool Kernel Round 69

- Verdict: `MAIN-AGENT DISCOVERY + P0 FAIL / SNAPSHOT INVALIDATED`. Two Luna
  reviewers were launched against manifest
  `/tmp/acgn-p0-review-round69-assurance.2OY1jT/input-manifest.tsv` (543
  inputs; SHA-256
  `cc5b501119a5530ed8ffebbc18c258ab4cda63f3471d2414962e91b898cdfe91`).
  The main-agent falsification changed the candidate before either reviewer
  returned a verdict, so both were stopped and neither contributes ballot
  credit.
- Discovery: direct Alloy proved
  `(A->C)&(B->D)=(A&B)->(C&D)`. The omission generalized to fixed
  coordinates, every finite equal-arity product subgroup, ternary products,
  and intersections with nonproduct residual operands. Production initially
  reported positive distance for the minimized binary cases.
- General repair: every parser-authenticated product in a compatible
  intersection subgroup contributes one operand to every coordinate
  intersection. The ordered product is rebuilt with composed slot maps;
  residual operands remain in the outer intersection. Synthetic,
  cross-module, and arity-mismatched evidence cannot authorize the rule.
- P0 exposed by the generalized regression: valid source
  `(a&b&c)->(d&e&f)` retained nested ACI operands in the exact pre-ACI
  certificate tree and flat operands in the frozen repair tree. Raw-content
  equality therefore rejected a semantically admitted normalization before a
  certified observation could be produced.
- Transfer repair: the dependent certificate still commits exactly to its
  pre-ACI source path and content. A second exact repair-occurrence seal is
  created only after lineage, path, ordered chain structure, exact types,
  composed slot maps, and certified ACI operand quotient agree. Subsequent
  mutation is checked against that repair seal; no arbitrary source-content
  substitution is accepted.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,276 checks;
  `EGraphSaturationTest` and `MASGVisitorTypeRegressionTest` pass; five new
  Alloy product-intersection assertions are UNSAT; and
  `Phase5SourceRules.lean` proves binary, three-source, and ternary
  coordinatewise intersection plus product/JOIN congruence under proved
  operand equality. P5-29/P5-30, P5-F65/P5-F66, and GC-F199/GC-F200 record
  the bounded obligations and incidents.
- Protocol consequence: Round 69 is finding evidence only. The complete
  bounded gate and Luna-to-Terra-to-Sol ladder restart on a new manifest.

## Correct-Pool Kernel Round 70

- Verdict: `LUNA FAIL + DISCOVERY / SNAPSHOT INVALIDATED`. Two Luna max
  reviewers verified all 543 inputs in manifest
  `/tmp/acgn-p0-review-round70-assurance/input-manifest.tsv`, SHA-256
  `4a2bf25433f96a15778ec24ad3be76d1848135756598d56c2131d102449e2ed8`.
  The relational reviewer returned `FAIL`; the binder/certificate reviewer
  returned `DISCOVERY`. Their stopped reports are
  `/tmp/acgn-round70-luna-a.md` (SHA-256
  `47cc3f057dc8349ce6383f5b823520624766b70350971630a5f28f4440ae98c0`)
  and `/tmp/acgn-round70-luna-b.md` (SHA-256
  `e3d4fa75a6fea6391616a2b9079c2811fdc4902c1fb7e987beedd47f07abdd9b`).
- Main-agent discovery: P5-30 named certified ACI transfer through both JOIN
  and ARROW, but the permanent repaired-path suite pinned only an n-ary
  intersection operand under ARROW. A valid-source probe independently showed
  that JOIN association, union reordering, duplicate elimination, and
  intersection reordering currently produce certified equality and distance
  zero; the missing evidence was coverage, not a newly observed wrong result.
- Repair: promote ARROW union-duplicate elimination and JOIN union reorder,
  union duplicate elimination, and intersection reorder to permanent parser
  pairs. Add four direct Alloy assertions. All four checks are UNSAT and all
  four pairs prepare and compare at certified distance zero.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` now passes 1,300 checks.
  P5-F67 and GC-F201 record the coverage contradiction and repair.
- Protocol consequence: both reviewer reports are finding evidence only. The
  changed test and documentation bytes require the complete gate and a wholly
  fresh reviewer ladder.

## Correct-Pool Kernel Round 71

- Verdict: `TWO LUNA DISCOVERIES / SNAPSHOT INVALIDATED`. Both independent
  Luna max reviewers found the same omitted relational families. Their reports
  are `/tmp/acgn-round71-luna-a.md` (SHA-256
  `437fc788fb1aea4255b00d9b63043f6fec77b1222c1fb4bdb23e72457e80a60b`)
  and `/tmp/acgn-round71-luna-b.md` (SHA-256
  `e796ea8b255e2d70aa658e915b6964a7159857924920fb3ac3ce47cdf109baf9`).
  Neither report supplies ballot credit.
- Independently validated discovery 1: Alloy and extensional relation
  semantics prove `~(r.s)=(~s).(~r)`. Production retained positive distance;
  preserving JOIN order has a concrete Alloy and Lean counterexample.
- Independently validated discovery 2: domain and range restriction distribute
  over union, intersection, and difference in either coordinate; repeated
  restrictions intersect their restrictors; domain and range commute; and a
  complete union grid factors. Diagonal grids and differences changing both
  coordinates are unsound and have concrete counterexamples.
- General repair: represent each authenticated restriction by its restrictor
  and relation coordinates, factor only complete coordinate covers, and derive
  exact correlated result types from live same-module parser evidence. Reverse
  exact binary JOIN sequences under converse. Generated relational operators
  receive canonical source identities so bottom-up and top-down forms converge.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,428 checks;
  `EGraphSaturationTest` passes the synthetic-authority barriers; all 17 direct
  Alloy assertions are UNSAT; three near misses are SAT; and
  `Phase5SourceRules.lean` proves the admitted schemas and decisive
  countermodels. P5-31/P5-32, P5-F68/P5-F69, and GC-F202/GC-F203 record the
  bounded claims and incidents.
- Protocol consequence: Round 71 is finding evidence only. The complete gate
  and Luna-to-Terra-to-Sol ladder restart from a newly frozen manifest.

## Correct-Pool Kernel Round 72

- Verdict: `LUNA FAIL + TWO DISCOVERIES / SNAPSHOT INVALIDATED`. The bounded
  gate had completed all 58 executable steps on 543 inputs under
  `/tmp/acgn-p0-review-round72-assurance`, but both Luna reports contained
  findings. The reports are `/tmp/acgn-round72-luna-a.md` (SHA-256
  `c1e6b309d12e16cec66ef1f0ddd75c87f1e402b94355bd52bbd1dc01c72d15a6`)
  and `/tmp/acgn-round72-luna-b.md` (SHA-256
  `7e928d03bda7b5af6c1a93ea1757ba71d1d96cd0944d664ceb83aa79febf2fd1`).
  Neither report supplies ballot credit.
- Independently validated FAIL: valid n-ary JOIN distribution at the middle
  or initial coordinate threw during dependent-source transfer after one
  factorization. The minimized laws are `r.s.t+r.u.t=r.(s+u).t` and
  `r.s.t+u.s.t=(r+u).s.t`; direct Alloy checks are UNSAT.
- Independently validated discoveries: converse commutes with both closure
  operators, and converse swaps domain with range restriction. The four
  minimized laws are `~(^r)=^(~r)`, `~(*r)=*(~r)`,
  `~(A<:r)=(~r):>A`, and `~(r:>A)=A<:(~r)`; direct Alloy checks are UNSAT.
- General repair: close guarded JOIN factoring to a fixed point before cloning
  the certificate matrix; reverse positive paths while retaining the closure
  kind; and treat restriction converse as an authenticated coordinate swap.
  Exact occurrence profiles, ordered JOIN boundaries, composed slots, and
  parser authority remain mandatory. Closure-kind changes, unswapped
  restrictions, JOIN/intersection distribution, and synthetic authority remain
  explicit barriers.
- Rejected claims after independent reproduction: in this Alloy build surface
  `#A + #B` is relational union over unary `Int`, not integer arithmetic;
  arithmetic addition remains `fun/add`/`IPLUS`. Direct solver checks refuted
  the alleged idempotence defect. The exact valid source
  `some ((A+B)+(A+B))` also prepares, certifies, and compares at distance zero;
  the alleged empty-PLUS crash was not reproducible.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,482 checks;
  `EGraphSaturationTest` passes both new synthetic-authority barriers; seven
  direct positive Alloy assertions are UNSAT and two near-miss witnesses are
  SAT; `Phase5SourceRules.lean` compiles with arbitrary-coordinate JOIN,
  converse-closure, and converse-restriction proofs. P5-33/P5-34,
  P5-F70/P5-F71/P5-F72, and GC-F204/GC-F205/GC-F206 record the obligations.
- Protocol consequence: Round 72 is finding evidence only. The complete gate
  and Luna-to-Terra-to-Sol ladder restart from a new manifest.

## Correct-Pool Kernel Round 73

- Verdict: `MAIN-AGENT DISCOVERY + LATENT DISCOVERY / SNAPSHOT INVALIDATED`.
  The bounded gate completed 58/58 executable steps over 543 inputs with input
  manifest SHA-256
  `04978a652ab33f39f39229792afa4d2f7e283ffd41fc8b5ee36cdd4bc42cdb1d`
  and output manifest SHA-256
  `a09aea87eb9deec4d4adc750f51af348505656c8d81329df886094156f825292`.
  Its correct overall result was `INCOMPLETE` with 201 open traceability
  diagnostics. The candidate was invalidated before reviewer completion.
- Main-agent discovery: direct Alloy proved full-carrier restriction identities
  and empty-coordinate zeros. Production reported distances 3 or 4 for the
  minimized `univ<:r`, `r:>univ`, `none<:r`, and `r:>none` pairs. Generalized
  checks also cover a primitive endpoint carrier and an empty relation operand.
- Latent-review discovery: one interrupted reviewer observed that typed empty
  relations were excluded from exact-binary unary guards. Independent main
  probes proved `~(none->none)=none->none`,
  `^(none->none)=none->none`, and `*(none->none)=iden`; the first two pipeline
  pairs had positive distance before repair.
- General repair: restrictions consume only authenticated built-in univ or a
  closed primitive carrier whose exact restriction result equals the relation,
  and either authenticated empty coordinate derives arity-preserving none.
  Empty TRANSPOSE/CLOSURE derives none; empty RCLOSURE derives authenticated
  iden. Variable carriers, forged names, and closure-kind substitutions remain
  barriers.
- Independently dismissed reviewer leads: `(Int+Int)->A` already compares at
  distance zero with `Int->A` and its Alloy law is UNSAT. Dependent-domain
  predicates with reversed semantic roles remain distinct at distance 2 and
  Alloy supplies a counterexample. API-only symbol/cover and temporal-collision
  speculations supplied no supported-path witness and were not promoted.
- The interrupted Luna reports are `/tmp/acgn-round73-luna-a.md` (SHA-256
  `2aa36f6c1777d5c41efe033131bad74c018bf08700b1a2b80f33303191b66215`)
  and `/tmp/acgn-round73-luna-b.md` (SHA-256
  `dc61c06cf910078b662eefb4f933c47e34c7d73b83c8bb64de06649d3e841d5a`).
  Their `DISCOVERY` dispositions acknowledge the invalidation; neither report
  supplies ballot credit.
- Moving-byte evidence: `CanonicalAlloyPipelineTest` passes 1,572 checks;
  `EGraphSaturationTest` covers authenticated and forged empty operands; thirteen
  positive Alloy assertions are UNSAT and two near-miss witnesses are SAT;
  `Phase5SourceRules.lean` proves every admitted identity and zero schema.
  P5-35/P5-36, P5-F73/P5-F74, and GC-F207/GC-F208 record the obligations.
- Protocol consequence: Round 73 is finding evidence only. The complete gate
  and reviewer ladder restart from a new manifest.

## Correct-Pool Kernel Round 74

- Verdict: `MAIN-AGENT DISCOVERY / SNAPSHOT INVALIDATED`. The bounded gate
  completed 58/58 executable steps over 543 inputs with input manifest SHA-256
  `d9b27de1546ea87fc96268e988d693511a0a87a058cd7e15c6cb2b09e8611726`
  and output manifest SHA-256
  `f15f7c3e3983ade9e3eaada4adb850d0c3412ba8204b1592794033fe08d969bb`.
  Its correct overall result was `INCOMPLETE` with 203 open diagnostics. The
  candidate was invalidated before reviewer completion.
- Main-agent discovery: direct Alloy checks proved the contextual restriction
  laws `(D<:R).S=D<:(R.S)`, `R.(S:>C)=(R.S):>C`, and
  `(R:>M).S=R.(M<:S)`. The exact Round-74 producer assigned distances 6, 6,
  and 5 to the minimized predicate pairs.
- Adversarial self-review found and reproduced a P0 defect in the first repair:
  it lifted a unary operand's only coordinate as though it survived JOIN. Two
  such endpoint-lift pairs were SAT-inequivalent but falsely compared at zero.
  The final rule requires underlying arity at least two before endpoint
  lifting. Unary and internal guards stay on the eliminated middle boundary
  and are oriented as a domain restriction on the right adjacent operand.
- Final general repair: every rewrite rederives the source and destination
  JOIN and restriction profiles from one parser module, compares the exact
  source occurrence, preserves ordered operands, coordinate roles, and slot
  invocations, and uses the arity-sensitive terminating orientation above.
- Independent generalization evidence: ten parser-backed pairs now close at
  certified distance zero, including three-operand chains, ternary relations,
  combined endpoint restrictions, intersected adjacent guards, unary
  boundaries, and quantified relation slots. Nine direct Alloy assertions are
  UNSAT; four wrong-side, wrong-guard, or wrong-unary-endpoint witnesses are SAT
  and remain distinct. The former false zeroes reopen at distances 4 and 5.
  Synthetic exact types do not authorize the rewrite. Lean proves projected
  endpoint, internal-boundary, and unary-boundary schemas, and existing JOIN
  associativity lifts the local rules through arbitrary chains.
- Interrupted reports: both reviewers stopped without an independent finding
  and returned `PASS`; neither ballot counts for a completed ladder. Reports
  are `/tmp/acgn-round74-luna-a.md` (SHA-256
  `1c5b4f457a5f407f0eb16bc8461131246871ecbbd55f2c9501d1c3d02e406ccb`)
  and `/tmp/acgn-round74-luna-b.md` (SHA-256
  `a55dcceb184bfd8826a470fdfb67816eef30c77a9c01ec8b3ac5fd9e929b6c54`).
  Their reports contain no latent scoped discovery.
- Moving-byte evidence before the fresh gate: `CanonicalAlloyPipelineTest`
  passes 1,655 checks, `EGraphSaturationTest` passes, and
  `Phase5SourceRules.lean` compiles without an admission. P5-37, P5-F75,
  P5-F76, GC-F209, GC-F210, I-F88, and I-F89 record the obligation and repair.
- Protocol consequence: Round 74 is finding evidence only. The complete gate
  and Luna-to-Terra-to-Sol ladder restart from a new manifest.

## Correct-Pool Kernel Round 75

- Verdict: `DISCOVERY / SNAPSHOT INVALIDATED`. The bounded gate completed
  58/58 executable steps over 543 inputs with input-manifest SHA-256
  `83276560277178d58e6e09ebfefda45313a728e805d16eac94887cfa84e3eda9`
  and output-manifest SHA-256
  `fed995cb19a3e11872dfa85f0f9a214979841cc07db2d523db2f1b808cfe3b58`.
  Its correct overall result was `INCOMPLETE` with 204 open diagnostics. The
  candidate was invalidated before any ballot could count.
- Main-agent discovery 1: direct Alloy proved `A<:r=r:>A` for unary `r`, while
  the exact Round-75 producer assigned distance 3. Higher-arity domain and
  range restrictions have different coordinate roles and a concrete SAT
  countermodel.
- General repair 1: after exact live parser occurrence validation, orient only
  unary RANGE restriction to DOMAIN. Synthetic exact-type labels cannot
  authorize the rewrite. The parser pair now closes at zero, the binary case
  remains distinct, and Lean proves both the law and countermodel.
- Both fresh Luna reviewers independently reproduced the unary omission and
  returned `DISCOVERY`. Their invalidated reports are
  `/tmp/acgn-round75-luna-a.md` (SHA-256
  `1daeaf6dc79e71f55ef55ff063e2a343ee1e3ef0da5d91c0ea01d6a02a468ca4`)
  and `/tmp/acgn-round75-luna-b.md` (SHA-256
  `94ad9efc77a0fcf34a1a34eb69aa595f15addaf92dfd25f8412d6f33b6882461`).
  They are finding evidence, not PASS ballots.
- Main-agent discovery 2: `r in r`, `r = r`, `r not in r`, and `r != r`
  retained distance 3 from true, true, false, and false. Four direct Alloy
  assertions were UNSAT.
- General repair 2: fold the four comparison atoms only when both relation
  operands have parser-authenticated set-family evidence and match in the
  already-certified operand quotient. This admits ACI-established identity
  without equating distinct invocations or trusting synthetic type labels.
  The four positive pairs close at zero; a distinct-subset case remains
  nonzero and its negation has a SAT witness. Lean proves direct reflexivity
  and all four equality-premise transport obligations.
- Moving-byte evidence before the next fresh gate:
  `CanonicalAlloyPipelineTest` passes 1,692 checks,
  `EGraphSaturationTest` passes, and `Phase5SourceRules.lean` compiles without
  an admission. P5-38/P5-39, P5-F77/P5-F78, GC-F211/GC-F212, and I-F90/I-F91
  record the obligations and repairs.
- Protocol consequence: Round 75 is finding evidence only. A new immutable
  manifest and the complete Luna-to-Terra-to-Sol ladder are mandatory.

## Adaptive Equivalence Augmenter Round A1

- Verdict: `TWO LUNA FAILS / SNAPSHOT INVALIDATED`. Both reviewers used the
  immutable manifest at `/tmp/acgn-adaptive-review-manifest.txt`, whose SHA-256
  was `4171ac017d97c8d4a4358db4a436bf4ee2746774556ebbfa41231cab898ad30d`.
- Report A is `/tmp/acgn-adaptive-luna-1.md`, SHA-256
  `f703aaa9c98479c8424e6aa7696649cbd523c9fdab7dfb2000da87e9f291d0b0`.
  Report B is `/tmp/acgn-adaptive-luna-2.md`, SHA-256
  `4716714016d71aa378b02107ba2b40f6358e2d3cabc65c612965560a28f1276a`.
- Both independently reproduced the blocking scope witness: `some Z` and
  `one Z` agree at scope 1 but differ at scope 2, while the reviewed local
  index allowed scope-1 evidence to create an unrestricted zero. Both also
  found that a caller-selected process could impersonate Lean.
- Repairs bind local identity, lookup, and certificates to the complete
  semantic validation context; keep timeout/error evidence retryable; fix
  endpoint-pair cache invalidation; charge future applications to growth
  bounds; compare certified and semantic patterns for duplicate schemas; and
  pin the exact Lean toolchain content and version into R0 and proof evidence.
- The reviewers proposed Boolean absorption and distributivity as discoveries.
  Independent W/X/Y source probes showed every pair already has R0 distance
  zero. They are now bootstrap coverage checks, not adaptive admissions or new
  static rules.
- Round A1 supplies finding evidence only. Its manifest is obsolete. A fresh
  manifest and complete Luna-to-Terra-to-Sol ladder are required.

## Adaptive Equivalence Augmenter Round A2

- Verdict: `MAIN-AGENT CONTRADICTION / TWO INVALIDATION FAILS`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v2.txt` had SHA-256
  `bb18c67b2681e2d4d678d74319b69b336c828341f4ddadbee326eeb867ea74da`.
- Before either reviewer completed, the main audit found that the assurance
  ledger still claimed one schema application while the regression recorded
  two context-distinct applications. The ledger was corrected and A2 stopped.
- The stopped reports are `/tmp/acgn-adaptive-luna-v2-a.md`, SHA-256
  `ca0f10b0115500a5f1619222eeb7933b03a4e45d8e1b0db2d486471dfcf82406`,
  and `/tmp/acgn-adaptive-luna-v2-b.md`, SHA-256
  `b5229fdea10f77423b276f0e19ad55f0572e72bea5b0c9d3e493d931fcb954d5`.
  Both report only `SNAPSHOT_INVALIDATED`; neither is a reviewer ballot.
- Protocol consequence: all A2 bytes and ballots are obsolete. A3 starts with
  fresh hashes and fresh agents.

## Adaptive Equivalence Augmenter Round A3

- Verdict: `TWO LUNA FAILS / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v3.txt` had SHA-256
  `d206d02e62bfe999e6d2d0b966931fff581b0358cbb2ba5c6ce54aa4ceb159d2`.
- Report A is `/tmp/acgn-adaptive-luna-v3-a.md`, SHA-256
  `c75547284a95e075fa94fe38402f7d18318da920726a7428524cacea9fd72c66`.
  Report B is `/tmp/acgn-adaptive-luna-v3-b.md`, SHA-256
  `db14355ec93b53674e86e84834d5d204307456036a7e2c5a4771e793b126bf50`.
- Both independently found that Alloy's normalized expression string omits
  quantified declaration domains. That collision identified distinct domain
  propositions as one Lean variable. Each reviewer produced two locally valid
  training pairs, a Lean-accepted generalized equality, and an unseen source
  pair that received adaptive distance zero despite a direct Alloy SAT
  counterexample. The main agent independently reproduced the first witness.
- Repair: opaque propositions now use a complete parser-AST digest with source
  identity, operator/type/multiplicity data, quantified domains and flags,
  calls, declarations, and De Bruijn-style bound-variable slots. Unknown node
  families reject rather than falling back to display text. Alpha-renaming
  remains equal, while a domain change remains distinct.
- Permanent evidence: the former schema now exposes separate proposition
  variables and its self-contained Lean proof fails. It remains `CANDIDATE`,
  admission rejects, the unseen adaptive distance remains positive, and the
  direct Alloy counterexample is retained. The standalone Lean file proves the
  erased-domain schema has a Boolean countermodel.
- Protocol consequence: A3 is finding evidence only. A fresh complete gate and
  Luna-to-Terra-to-Sol ladder must restart from new hashes.

## Adaptive Equivalence Augmenter Round A4

- Verdict: `NO BALLOTS / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v4.txt` had SHA-256
  `f0cab14c320f3d941e55c49d73ecf6f21e9573c7a3d4cc406998313f8d04bb51`.
- Both Luna processes exceeded the bounded review window without producing an
  audit report or verdict. They were stopped and contribute no PASS credit.
- The main audit then exercised the complete atom identity on current bytecode.
  Alpha-renamed lets and nested dependent quantifiers retained equal keys;
  changed let/domain expressions, declaration disjointness, and declaration
  multiplicity retained different keys; identical nested calls remained equal.
- Those successful probes exposed a nontrivial persistent-coverage omission,
  not a semantic failure. The seven checks were moved into
  `EquivalenceAugmenterTest`, increasing the suite from 59 to 66 checks.
- Protocol consequence: because test and documentation bytes changed, A4 is
  obsolete. A fresh immutable manifest and reviewer ladder are required.

## Adaptive Equivalence Augmenter Round A5

- Verdict: `MAIN-AGENT FAIL / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v5.txt` had SHA-256
  `82ac3cf88489e469ca147e62abd1ae431af8f20cfa81aa44d6d3d7a68d14c351`.
- The main proof-boundary audit found that `LeanSchemaProofValidator` parsed and
  hashed one file image, then passed the original path to Lean. A supported
  caller could therefore make the evidence digest and kernel input name
  different byte images.
- Repair EA-F23 compiles the already checked byte array through Lean's
  `--stdin` interface. The original path remains an audit reference only.
- Both Luna processes were stopped after the snapshot was invalidated; neither
  produced a report or ballot. A5 contributes no PASS credit.
- Protocol consequence: code and documentation bytes changed. A fresh gate and
  Luna-to-Terra-to-Sol ladder are mandatory.

## Adaptive Equivalence Augmenter Round A6

- Verdict: `MAIN-AGENT DISCOVERY / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v6.txt` had SHA-256
  `33eb50bb8f484d7790d339357d10657aa701d59ad41c7ca1c38898de9d2c2a9a`.
- The ledger sorted records but rendered `JSONObject` values backed by
  `HashMap`. Semantic JSON content was intact, but the documented deterministic
  byte transcript was not guaranteed across runtimes.
- Repair EA-F24 recursively sorts every object key and retains stable array
  order. Repeated writes, lexical root order, and required local/schema/
  application fields are now permanent regressions.
- Both Luna processes were stopped after invalidation and produced no report or
  ballot. A6 contributes no PASS credit.
- Protocol consequence: serialization, tests, and documentation changed. The
  complete gate and reviewer ladder restart from a new manifest.

## Adaptive Equivalence Augmenter Round A8

- Verdict: `LUNA FAIL / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v8.txt` had SHA-256
  `049dd6a4d01024155edf663fed646d6a61107f1188fe05b4a96708b1f1ab6c36`.
- The completed Luna report is `/tmp/acgn-adaptive-luna-v8c-a.md`, SHA-256
  `91ea37db65d60503691065563636982a80d6f446dbbec3737747384143d88bc2`.
  It found that `sorryAx` bypassed the identifier-bounded `sorry` filter and
  that Lean treated the resulting declaration as a warning while exiting zero.
- The main agent independently compiled the minimized false theorem
  `forall p q : Prop, p <-> q` with `sorryAx`; Lean 4.33.0 emitted
  `declaration uses sorry` and returned zero. It also reproduced the same
  semantic hole through the `impossible` tactic without either forbidden token.
- Repair EA-F26 rejects `sorryAx` text, compiles the exact checked bytes into a
  private module, and runs checker-owned `#print axioms` against the requested
  theorem. Only Lean's pinned foundational axioms are accepted, so local warning
  suppression cannot hide `sorryAx`. Direct, implicit-sorry, and producer-axiom
  regressions are permanent. The second Luna process was stopped after
  invalidation and produced no report or ballot.
- Protocol consequence: A8 is finding evidence only. A fresh gate and complete
  reviewer ladder are required.

## Adaptive Equivalence Augmenter Round A9

- Verdict: `MAIN-AGENT P0 / SNAPSHOT INVALIDATED` before reviewer ballots.
- A minimized Lean module exported a macro for the exact `#print axioms`
  command, locally suppressed the warning from an implicit `sorryAx`, and made
  the checker print `True : Prop` with exit status zero. This was a reachable
  false-certification path for submitted schema proofs.
- Repair EA-F27 freezes the accepted proof language against parser, macro,
  notation, elaborator, and initializer extensions. The existing independent
  axiom census remains mandatory, and the exact macro-shadowing witness is now
  a rejection regression.
- Protocol consequence: all earlier adaptive review snapshots predate this
  semantic-boundary repair. A fresh immutable manifest and complete
  Luna-to-Terra-to-Sol ladder are required.

## Adaptive Equivalence Augmenter Round A10

- Verdict: `LUNA FAIL / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v11.txt` had SHA-256
  `a7b5f25d751e870f71bae8cbd3afa5dee264eb299fc0ac949a52d18494ae190f`.
- Luna A report `/tmp/acgn-adaptive-luna-v11-a.md` has SHA-256
  `ed46d397d469ba40be50169752bbfe2516fba0d8eb948c835cbb52bbd6d45b01`.
  It found a valid module where imported `ord/first` and a distinct local
  `first` shared a trailing name. Valid UNSAT evidence for the imported call
  was reconstructed as the local callable, producing an accepted false zero
  certificate for an R0-distance-1 pair. The main agent independently
  reproduced every transition, including the contrasting local SAT witness.
- Repair EA-F28 requires the parser-resolved callable object to be declared by
  the root module and permits MASG lookup only through that declaration's exact
  local identity. Imported aliases can no longer fall back to a local trailing
  segment. The direct imported-UNSAT/local-SAT pair and no-record boundary are
  permanent regressions.
- The stopped Luna B report `/tmp/acgn-adaptive-luna-v11-b.md` has SHA-256
  `2ab9054aad375db6d39b2871065761118dbe871f4b865ab07833a05412ea6998`.
  Before invalidation it independently demonstrated EA-F29: declaration text
  inside a Lean raw string satisfied the digest-marker search although no
  executable `acgnSchemaDigest` existed. The main agent reproduced acceptance.
  Checker-owned source now proves the exact digest constant by kernel
  reduction before the theorem axiom census; the raw-string decoy rejects.
- Protocol consequence: A10 contributes finding evidence only. Code, tests,
  and documentation changed; a fresh gate and complete reviewer ladder are
  mandatory.

## Adaptive Equivalence Augmenter Round A11

- Verdict: `TWO LUNA FAILS / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v14.txt` had SHA-256
  `11b531b18af6cb9e2daa0fa062959570f29d74fdbbb6cf0b6dac35d5a8cea9e9`.
- Luna A report `/tmp/acgn-adaptive-luna-v14-a.md` has SHA-256
  `7ff6764341328213057e8e4056619f04d69968e111f43e7cf68fe96aef13758f`.
  It supplied a complete public-pipeline witness in which expressions of
  parser type `Rel(U)` were labelled `Rel(NotTheActualCarrier)`. Arity-only
  checking accepted the forged exact-type guard evidence, admitted a schema,
  and produced a replay-valid generalized zero certificate. The main agent
  independently reproduced all transitions. Repair EA-F30 now authenticates
  complete parser types and binds them into evidence; the witness cannot leave
  `CANDIDATE`.
- Luna B report `/tmp/acgn-adaptive-luna-v14-b.md` has SHA-256
  `2b33b28b5056e1724791b9ba54e12ce1e08496d335f13af77aa618cbb0ec2506`.
  It independently confirmed the exact-type authority failure and reduced a
  second source-context witness: endpoints certified under a command fixing
  exactly two atoms were checked by a fresh scope-one command, yielding false
  local equality. Repair EA-F31 makes source command identity and all bound
  options explicit, checks them against the endpoint profile, and replays the
  exact parser-owned command configuration.
- The same report recorded a valid nullary/unary Alloy overload that failed
  during MASG declaration indexing. Independent reduction confirmed that the
  spelling-only map rejected the module before source correspondence. Repair
  EA-F32 keys declaration lookup, forest identity, and callee targets by name,
  kind, and arity; same-kind/same-arity ambiguity remains fail-closed.
- Both reports are finding evidence only. Their snapshot predates EA-F30 and
  EA-F31; a fresh gate and reviewer ladder are mandatory.

## Adaptive Equivalence Augmenter Round A12

- Snapshot v15 manifest `/tmp/acgn-adaptive-review-manifest-v15.txt` had
  SHA-256
  `7c4d00d0018b5561a7bf1f89d27ae54f0738cb36e2d463e603bdddefcea1e9f5`.
- Luna B completed `PASS`; its report is
  `/tmp/acgn-adaptive-luna-v15-b.md`, SHA-256
  `c80cb6d8ba3020d6255ba9e5cd5915bf34e197cab736429a7cd100f243bdcd0e`.
  Luna A remained nonresponsive in a
  bounded probe and was closed without a report or ballot. This is not a
  unanimous review round.
- Main-agent proof-ledger review then located EA-F33: the repaired type,
  source-command, and overload gates had executable regressions but lacked
  companion standalone Lean obligations. Those constructive obligations were
  added, invalidating v15 before any higher-tier review. A fresh two-Luna round
  starts from new hashes.

## Adaptive Equivalence Augmenter Round A13

- Verdict: `SOL FAIL / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v16.txt` had SHA-256
  `4136f5575bfa4408c916b812b8972db6cc77a9acf00f871b9231038e0a2b4eea`.
- Two Luna reports and two Terra reports returned `PASS` on the exact v16
  checksum subject. Their report SHA-256 values were, respectively,
  `a4b41441b0001f75b8a1f986681a3722b5a9b8b867c0657e1eaeaaf2853cf2f2`,
  `429351772a081a6641231b9f90dcfc4d7b6ea72dc512df637064bd45f89fc3a4`,
  `f49a6b764fb2fd2f5114e48a9c2435deb49c2f2615626f5e365b5e0d11ec0fc7`,
  and `c82a6a48c296c0d40785dcbe06df88afefb9a387d68885e440e24558c6309835`.
- One Sol report also returned `PASS` at
  `/tmp/acgn-adaptive-sol-v16-b2.md`, SHA-256
  `e85ab840a48e1c6303e1bf42e757e970f72599220db770114ef98add8c01f3ee`.
  Classifier-stopped attempts produced no report and receive no ballot.
- The second valid Sol report, `/tmp/acgn-adaptive-sol-v16-c.md`, SHA-256
  `5e59bea85ec342bbb40483be8a28dcafa22385e8c22231e305573b8ff5243b83`,
  found EA-F34. A valid Alloy follow-up command supplied a non-null parent to
  the generated equality command. Alloy solved the ancestor command, and its
  unrelated UNSAT result certified a false local equality, distance zero, and
  successful certificate replay. The main agent independently compiled and
  reproduced every transition using the exact v16 classes.
- Repair: source-bound profiles now reject follow-up command chains until the
  complete chain is represented, and generated equality commands are required
  to execute with a null parent. The former witness stops before profile
  authority is minted; its independently executed equality remains SAT.
  Permanent regressions cover both the adaptive validator and the central
  semantic-profile factory, while standalone Lean models command-result
  identity and parent-result substitution.
- Protocol consequence: every v16 ballot is historical finding evidence only.
  Code, tests, formal evidence, and documentation changed; a fresh complete
  gate and Luna-to-Terra-to-Sol ladder are required.

## Adaptive Equivalence Augmenter Round A14

- Verdict: `TERRA DISCOVERY / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v17.txt` had SHA-256
  `e7f0769be85ba1e034f1fdb18d90d6c8bc8934f6b83b88d17aaf6bcaf4dff1cf`.
- Both fresh Luna reports returned `PASS` on the exact snapshot. Their reports
  `/tmp/acgn-adaptive-luna-v17-a.md` and
  `/tmp/acgn-adaptive-luna-v17-b.md` have SHA-256 values
  `f5e060979e59b734c1ee91b3a475196ceeb97fb5f3c8699db1f4ad5136941328`
  and `5371c6472952cb45312e3e5a5f28362ead1803011eaf318b53f4440490d60a9d`.
- Terra B report `/tmp/acgn-adaptive-terra-v17-b.md`, SHA-256
  `93235df9dfee25b0a377e97488a2c2e21d6a7394b104c56e0383f235d7a55dca`,
  found EA-F35. Source replay authenticated a command formula and its bounds
  but discarded the formula when executing equality. Under `run { one A }`,
  the sound contextual equality `some A iff one A` was falsified by a two-atom
  model outside the command's search domain. The main agent independently
  reproduced the validator and local-record outputs. Terra A was stopped after
  invalidation and contributes no ballot.
- Repair: use Alloy's parser-lowered `Command.formula` as the selected command's
  executable search domain and conjoin it with the generated equality's
  counterexample condition. This uniformly handles run and check commands,
  records the executed-formula digest, and leaves global comparison unchanged.
  Run/check regressions verify the contextual local equality while retaining
  unbound SAT counterexamples. Standalone Lean proves both search domains and
  the contextual no-counterexample implication.
- Protocol consequence: every v17 ballot is finding history only. The complete
  gate and reviewer ladder restart from new hashes.

## Adaptive Equivalence Augmenter Round A15

- Verdict: `LUNA DISCOVERY / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v18.txt` had SHA-256
  `640f96a382a2a435eeedc5b2d0c7f913c73622470641e7132e5944f878245329`.
- Luna B returned `PASS`; report `/tmp/acgn-adaptive-luna-v18-b.md` has
  SHA-256
  `570219d5e9e42c5fe70760a5a8f65d60ed12b279d03bb7ad293ba026ea1b2f83`.
  Luna A report `/tmp/acgn-adaptive-luna-v18-a.md`, SHA-256
  `2f12962e552c5585ffd09b39895ca391c69845125cc37779a9a48f7ebbd61a49`,
  found EA-F36. Two source-bound requests differing only in request scope
  executed one parser-owned command context but created distinct local records.
  The main agent independently reproduced both IDs, contexts, and successful
  Alloy outcomes.
- Repair: local and cache context identity now uses the effective execution
  context. Request scope is retained only when it controls execution; a
  source-bound request uses the authenticated command index/options instead.
  The former witness now has one ID, one context, one record, and one
  certificate. Existing request-scoped scope separation remains covered, and
  standalone Lean proves both normalization branches.
- Protocol consequence: v18 contributes finding history only. A fresh complete
  gate and Luna-to-Terra-to-Sol ladder are required.

## Adaptive Equivalence Augmenter Round A16

- Verdict: `LUNA DISCOVERY / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v19.txt` had SHA-256
  `5676f190bf4a559c28776affeac9c89b38376d652bdfebf8d32070af13391669`.
- Luna A report `/tmp/acgn-adaptive-luna-v19-a.md`, SHA-256
  `eb5cff28367a2b358096c402a74238e5b45470c73fc082572a808ffe4a61ee91`,
  found EA-F37. `left` and `this/left` resolved to the same parser declaration,
  source correspondence, and prepared endpoint, but raw expression hashes made
  two local context IDs. The main agent independently reproduced both verified
  records. Luna B was stopped after invalidation and contributes no ballot.
- Repair: semantic-context identity now incorporates the parser-resolved
  correspondence digest instead of raw endpoint selector strings. That digest
  already authenticates exact source bytes, root declaration identity,
  observations, and profiles. Qualified/unqualified witnesses now reuse one
  local record and certificate; source/provenance rejection remains unchanged.
  Standalone Lean models resolved identity as independent of spelling.
- Protocol consequence: v19 is finding history only; the complete gate and
  reviewer ladder restart from new hashes.

## Adaptive Equivalence Augmenter Round A17

- Verdict: `LUNA FAIL / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v20.txt` had SHA-256
  `7d11450bab7cf15b484ffc88dc5fdc06fb353839f0978de91660f952483ae2b8`;
  its checksum ledger had SHA-256
  `9f03ea4ed2554e7f13747cd7ff37dcefa5d7d1718ccfd8de6968b5a063f24942`.
- Luna A returned `PASS`; report `/tmp/acgn-adaptive-luna-v20-a.md` has
  SHA-256
  `2abecc4bfd5ec808871b6459952f6165fafcdf9e4bcda3bcf76258165ada6c9d`.
  Luna B returned `FAIL`; report `/tmp/acgn-adaptive-luna-v20-b.md` has
  SHA-256
  `2cd4fb7d5103903bb2fa279f1d5465c9b01c3f08c2d702a7968621f22e4d0943`.
- EA-F38: generalized application reconstructed the compared source endpoints
  but skipped command/options authentication against their semantic profile.
  An admitted schema could consequently issue a zero certificate whose context
  digest named an unauthenticated command. The main agent compiled the new
  regression against the exact frozen v20 classes; it failed because the
  request was accepted. The witness log is
  `/tmp/acgn-ea-f38-pre-fix-witness.log`, SHA-256
  `f3f050d5af91bb07edc7f9ea893520a5ba3b972a272c74f9206ec005fa17a098`.
- Repair: schema application now calls the existing fail-closed semantic-context
  validator before source correspondence, cache lookup, or application-record
  mutation. Repaired classes reject the witness and retain the ledger size.
  Standalone Lean proves that unequal endpoint/request contexts cannot construct
  application authority.
- Protocol consequence: the v20 PASS cannot suppress the valid FAIL. Every v20
  ballot is historical evidence only, and the full gate plus staged reviewer
  ladder must restart on a fresh content manifest.

## Adaptive Equivalence Augmenter Round A18

- Verdict: `TWO NONBLOCKING DISCOVERIES / NO CORE FAILURE`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v21.txt` has SHA-256
  `3a4eeb38af041996754463d7842caca359d1a7ecbb1942e265f2d17ce5bac6bc`;
  its checksum ledger has SHA-256
  `3876d2852ec2a6b7f52b1890b9f56f23344932be82252d9974ccf36f4c36a150`.
- Luna A report `/tmp/acgn-adaptive-luna-v21-a.md`, SHA-256
  `c807270059e9c4a229c4fa9a27c57290f9747016c860d782d5de1b688ab86606`,
  found positive `R0` distances for the exact cardinality/empty-relation family.
  The main agent independently reproduced all four Alloy equalities; the probe
  log SHA-256 is
  `7ddffddc8ac7aa2d92278836114939dde6cce7af6ebb3a85470c092f919df6f6`.
- Luna B report `/tmp/acgn-adaptive-luna-v21-b.md`, SHA-256
  `513c06e5764ef16f2028eb86bb805d9dd31991d6c48e326879aeef5284bd6ef9`,
  recorded the narrower automatic-generalization boundary for term equalities
  and universal binders. Both reports found no false result or certificate.
- Disposition: under the revised bounded stopping rule, discoveries are logged
  for future work and do not invalidate a round unless they violate a core
  assumption. Neither finding does: `R0` incompleteness remains positive, exact
  local evidence remains context-bound, and unsupported schema admission fails
  closed. No static rewrite or adaptive semantic rule was added. The staged
  review therefore continues while preserving both reports as future-work
  evidence.

## Adaptive Equivalence Augmenter Round A19

- Verdict: `TERRA FAIL / SNAPSHOT INVALIDATED`. Manifest
  `/tmp/acgn-adaptive-review-manifest-v22.txt` has SHA-256
  `8125907b89f831f5ca1cde4911abe770f825ac4840ede5a0d580caaf151fd752`;
  its checksum ledger has SHA-256
  `1da5c0fba2ca2eacecb0d7d0a5b019fe910c17ed12caa54a65e0ece7e938b485`.
- Both Luna reviewers and Terra B returned `PASS`. Terra A returned `FAIL` in
  `/tmp/acgn-adaptive-terra-v22-a.md` (SHA-256
  `a213e05c0be1961b7daffd98714ee890f5e44173918abf64b00d31f93d6a52cb`).
  EA-F39 showed that replacing the body of a valid filesystem module reached
  through `open` changed Alloy from `COUNTEREXAMPLE` to
  `NO_COUNTEREXAMPLE`, while the root source hash, semantic profile, and
  endpoint-correspondence digest remained unchanged.
- The main agent independently reproduced the transition in
  `/tmp/acgn-main-import-correspondence.log` (SHA-256
  `e6b1b227e38b87649686fcbe3724745104c17f3caf3bb2decc6ee9d2120bb9b3`).
  Adaptive validation and correspondence now reject every explicit `open`
  until its parser-resolved dependency bytes can be committed. The repaired
  probe log is `/tmp/acgn-main-import-correspondence-v23.log` (SHA-256
  `333c68ee26425ce4f61b2a39a55d5aac4d3642439efc44d2d9eb0b97f2ac998c`).
  Standalone Lean proves that explicit-open state has no closed-root authority.
- Protocol consequence: every v22 ballot is historical evidence only. A fresh
  complete gate and Luna-to-Terra-to-Sol ladder must restart on new hashes.
