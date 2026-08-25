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
