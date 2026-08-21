# Phase 4 Audit: Collision Buckets and Serialization

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Status

PRELIMINARY MAX-ADVERSARIAL REVIEW FAILED; THE CURRENT MOVING SNAPSHOT AWAITS
FRESH REVIEW. The in-memory graph and schema-v8 snapshot
relation represent multiple incomparable leader owners for one exact shape.
The producer bridge now keys every retained replay and serialized shape
identity by the complete `(owner, shape)` parent-record key. Standalone
verifier fixtures cover incomparable-owner and nontrivial rebuild states. The
current bounded production writer does not export insertion-collision or
nonempty rebuild-record histories; it returns `UNCHECKABLE` for those cases.
They must not be described as end-to-end producer evidence.

## Implemented Obligations

- `TypedSlottedPortEGraph.hashCons` maps each canonical shape to a deterministic
  nonempty sorted owner bucket.
- Collision resolution tries both directed interface orientations. A parent is
  installed only after an exact typed collision certificate succeeds; otherwise
  both leaders remain. Only the dedicated no-directed-embedding exception is
  memoized. A stored-record change invalidates every affected negative entry,
  and final quiescence performs one fresh uncached compatibility pass.
- Rebuild rehomes absorbed records, reconstructs the hash relation, and checks
  exact quiescent ownership.
- Snapshot and structural keys retain every `(shape, owner)` pair. Each shape
  record also carries its exact canonical-to-occurrence coordinate bijection.
- `acgncert-schema-v8` parses hash ownership as `Map<key, Set<leader>>`, orders
  records by `(key, owner)`, checks nonempty leader buckets, and reconstructs
  exact quiescent buckets from all live shape records.
- A fresh insertion into an existing key is accepted without a union only when
  the standalone verifier computes that neither owner context admits a typed
  injection into the other.
- `acgncert-schema-v2`, rootless-binder `acgncert-schema-v5`, provenance-
  incomplete v6, and transition-incomplete v7 fail with
  `UNSUPPORTED_FORMAT_VERSION`; no historical state is silently reinterpreted.
- Producer replay lookup, shape IDs, reverse parent-use references, dirty
  records, and unfolding references use `ParentRecordKey`, not a shape-only
  map. A rehomed shape receives a new owner-qualified ID while retaining its
  independently checked source replay.

## Existing Regression Evidence

The numeric counts in the historical review paragraphs below identify the
snapshots those reviews actually examined; they are not current-ballot results.
On the current moving schema-v8 worktree, the protected producer/verifier
harness passes `VerifierTest=134`, writer `95` twice, inspection `68`, and pins
`31`, with the export census exactly `1/2/0`. The focused producer transition
gate passes `69` checks; six neighboring theory suites pass `4,720` additional
checks. These are moving-worktree conformance results, not a ballot.

- Theory state/rebuild tests cover `{x:Int}` and `{y:Bool}` owners of one equal
  effective shape, deterministic buckets, no unsound union, and quiescence.
- `VerifierTest` covers explicit v2 and v5 rejection. Existing v6 checkpoint fixtures
  include an incomparable two-owner bucket that verifies and a compatible
  two-owner bucket that rejects with `INVALID_COLLISION`.
- `ProducerBundleInspectionTest` checks that a shape rehomed by a certified
  union has distinct owner-qualified record IDs before and after the union.
- `CertificateBundleWriterTest` passes 66 checks in each byte-identical run;
  `ProducerBundleInspectionTest` passes 68 checks; the complete bounded Java
  gate passes with the exact `1/2/0` export census unchanged.

## Fault And Contradiction Log

| ID | Located fault | Repair | Regression |
| --- | --- | --- | --- |
| P4-F01 | Producer insertion evidence rejected a second owner solely because its canonical shape already appeared. | Index retained insertion evidence by `ParentRecordKey(owner,shape)`. | The writer no longer has a shape-only duplicate-owner guard. |
| P4-F02 | Producer replay lookup and shape IDs were keyed by shape alone. Rehoming silently reused the old owner's record identity. | Resolve replay provenance through the snapshot parent relation and derive each shape ID from `(owner,shape)`. | The parent-path fixture exhibits one structural term under two owners and now has two distinct record IDs. |
| P4-F03 | Parent-use, dirty-queue, and unfolding records inherited the same shape-only alias. | Emit and resolve all three through the complete owner-qualified key. | Full checkpoint verification and finite-unfolding verification pass. |
| P4-F04 | The independent verifier accepted a post-union checkpoint after the absorbed owner's shape and hash records were deleted. `requireUnionShapeTransfer` treated a missing old record as successful retirement without explicit retirement evidence. | Require removal of the child-qualified ID and presence of the exact parent-qualified term; preserve replay evidence unless the parent already owned that term. | `unionTransitionFixture(true)` rejects with `INVALID_UNION`; the review's original closed mutation now rejects with the same code. |
| P4-F05 | The standalone verifier parsed arbitrary shape IDs and did not derive the declared identity from `(owner, canonical shape)`. The accepted fixture reused `shape-1` across owner `1 -> 0`, contradicting the serialized-format contract. | Define and independently recompute `shape/sha256(producer-shape-id[owner,termId])`; update every producer and reverse reference. | The union fixture now changes IDs on rehome, and a content-consistent arbitrary-ID fixture rejects with `NONCANONICAL_ENCODING`. |
| P4-F06 | Standalone collision compatibility compared only exact-type multiplicities. This is weaker than the graph's occurrence-aware typed witness/endpoint criterion and can classify distinct same-typed interfaces as mergeable. | Serialize the exact shape-to-occurrence bijection per record and reconstruct `parentWitness^-1 ; childWitness` in both directions. | Same-typed `{left-slot:Int}` and `{right-slot:Int}` owners coexist; identical occurrence coordinates reject as an unresolved compatible collision. |
| P4-F07 | Reverse parent-use records were ordered by only their first scalar, so two owner-qualified uses with one child could serialize noncanonically. | Canonically sort the complete `(childOwner,parentShapeId)` pair. | The dual-owner producer fixture is byte-identical across independent exports and verifies under the standalone checker. |
| P4-F08 | A negative collision cached at coherence revision `r` survived a same-revision stored-witness replacement during rebuild and suppressed a newly valid directed union. | Invalidate affected cache entries on every stored-record removal/installation and require a fresh uncached compatibility pass before quiescence. | The old independent probe no longer reaches its expected suppressed state; `TheoryRebuildTest` permanently exercises the same-revision transition and passes 110 checks. |
| P4-F09 | Collision resolution caught every `IllegalArgumentException` and silently treated malformed or stale proof failures as semantic incompatibility. | Introduce a dedicated `IncompatibleInterfaces` exception for the expected no-embedding cases and memoize only that type; every other defect propagates. | A wrong-owner endpoint equation propagates; replacing it with a valid equation at the same revision immediately merges, proving the defect did not poison the memo. |
| P4-F10 | Public Phase 4 prose implied production export of incomparable collision/rebuild transitions, but `CertificateBundleWriter` rejects insertion collisions and nonempty rebuild records. | Narrow the public producer claim to the actual bounded bridge and retain standalone verifier fixtures as verifier-only evidence. | `TRUST.md`, `FORMAT.md`, and this report now distinguish producer export from standalone DTO coverage; full production transition export remains a blocked deliverable if required. |
| P4-F11 | This report named active schema v3 although the parser then accepted exactly schema v5. | Replace the stale v3 claim; P4-F14 subsequently advances the rooted contract to v6. | Retained as historical fault provenance; the current version boundary is tested by P4-F14. |
| P4-F12 | The ledger requested an unqualified SHA-256 injectivity theorem for owner-qualified shape IDs. | State the defensible obligation: unique canonical preimage encoding, deterministic recomputation, and fail-closed collision checking; make no mathematical hash-injectivity claim. | Arbitrary and reused ID mutations remain negative tests; the formal model proves injectivity only of the unhashed structural pair. |
| P4-F13 | No claim-complete Phase 4 Lean/Z3 and Java/wire refinement existed. | Import and strengthen the independent finite owner/interface model, then map every remaining implementation and provenance claim before ballots. | Still open; this finding blocks Phase 4. |
| P4-F14 | Rooted binder-occurrence identity replaced the rootless identity while producer and parser still advertised schema v5, silently changing the meaning of accepted bytes. | It was first separated as v6; CALL provenance advanced the contract to v7, and exact transition plus witness-unfold evidence advances it to v8. All earlier versions reject. | `VerifierTest` relabels a valid v8 bundle as v5, v6, and v7 and requires `UNSUPPORTED_FORMAT_VERSION`; the formal version model admits only 8. |
| P4-F15 | The bounded Lean union relation accepted an arbitrary post-union dirty queue and erased parent topology, reverse uses, revision, status, histories, and rebuild intervals. | Extend `Phase4WireConservation.lean` with exact transition frames, deterministic union/rebuild effects, parent-path and reverse-use validity, event-specific revision/status, and a closed rebuild-interval automaton. | The former arbitrary-dirty and zero-revision countermodels now evaluate false; exact union/rebuild frames and seven interval attacks compile under Lean 4.33.0. This remains a bounded contract plus Java conformance evidence, not a mechanized JVM refinement proof. |
| P4-F16 | A compressed parent path could retain an absent intermediate e-class or contradict the current assignment forest. | Validate every primitive path endpoint against current class metadata and require every primitive step to remain within one current rooted component. | Both independent compressed-path forgeries reject and are permanent cases in `Phase4ProducerTransitionEvidenceTest`. |
| P4-F17 | Empty parent-use and restriction buckets remained visible through getters but were omitted from the structural state key, allowing a no-op rebuild start to hide a mutation. | Reject empty retained buckets at snapshot construction so observable state and state identity have one representation. | Both hidden-ledger mutations reject before event construction. |
| P4-F18 | Insertion and restriction histories could be stored under absent or unrelated e-class keys. | Require insertion keys to equal the inserted class and name a current class; require nonempty, composable restriction chains indexed by their class and ending at current metadata. | Orphan and misindexed insertion/restriction snapshots reject in the 69-check producer gate. |
| P4-F19 | A live shape and exact reverse-use entry could invoke an absent e-class. | Validate every invocation target, output type, current-or-certified-historical interface, leader state, and dirty repair obligation. | The absent-invocation snapshot rejects at construction. |
| P4-F20 | A locally valid retirement certificate could be copied into an unrelated empty snapshot. | Require all retirement owners to exist, the retired key to be non-live, owner-union sources to be nonleaders, and each retained-successor chain to terminate at a live record. | The copied orphan-retirement ledger rejects at construction. |
| P4-F21 | The producer trace sink accepted a zero-revision union outside rebuild scope, a rebuild record/completion without a start, and an externally observed trace ending with an open start. | Track one explicit rebuild transaction in the sink; bind union revision authority to that context; reject nesting, interruption, missing boundaries, shifted report starts, and observation of an open interval. | Direct attacks for all three former acceptances now reject; the ordinary writer harness remains green. |
| P4-F22 | Removing `REBUILD_START`, renumbering all later events, and recomputing content IDs still produced a standalone `VERIFIED` bundle. | Make `CheckpointVerifier` enforce one consecutive start/record-or-local-union/completion transaction and reject an unfinished interval; bind union revision/status rules to interval context. | `VerifierTest` now has 134 checks, including missing-start and open-interval fixtures; the protected census and digests remain unchanged. |
| P4-F23 | The rebuild regression survived a semantic no-op implementation of `rebuildHashConsExactly()` that incremented only a diagnostic counter. Invocation evidence did not establish reconstruction of the exact live-owner index. | At the transition boundary, validate the incoming index, clear the derived hash index, reconstruct it solely from authoritative live records, and validate exact buckets again before publishing quiescence. | A fresh replacement review kills both counter-only and empty-body mutants in the full 115-check rebuild suite and the isolated interface-change path; the bounded Phase 4 review passes while universal JVM refinement remains open. |

## Independent Review 1

**Verdict: FAIL.** The reviewer independently reran the graph and verifier
suites, then constructed mutation probes outside the repository. The graph's
bucket ownership, bidirectional orientation search, revision-scoped negative
memo, rehoming, and quiescence checks passed. The serialized trust boundary
failed the three cases recorded as P4-F04 through P4-F06. Before remediation,
the focused counts were `TheoryStateTest=4205`, `TheoryRebuildTest=105`,
`TheoryDeterminismTest=47`, `VerifierTest=86`, writer `66` twice, inspection
`68`, semantic mutations `19`, and pins `31`; the export census remained
`VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`. These passing counts do not close
Phase 4 because the mutation probe demonstrated accepted evidence loss.

## Remediation Verification

The review's exact owner-reuse probe now reports
`ownerChangedWithoutIdChange=false`. Its exact dropped-transfer mutation now
rejects with `INVALID_UNION`. The expanded focused suite and complete bounded
gate pass
`VerifierTest=88`, writer `66` twice, inspection `68`, semantic mutations `19`,
and pins `31`; the export census remains exactly `1/2/0`. A fresh independent
verdict remains required before closure.

## Review Gate

A new fresh reviewer must probe both orientation checks, revision-scoped negative
memoization, absorbed-record rehoming, owner-qualified wire references,
incomparable coexistence, compatible-pair rejection, and schema-v2 fail-closed
behavior after P4-F04 through P4-F06 are repaired. Fixed-batch incomparability
must remain explicit test-only evidence; failed producer attempts are not proof
objects and grant no authority.

## Independent Review 2

**Verdict: PASS.** The fresh read-only reviewer completed all 22 bounded Java
classes and two independent consistency probes (`8 + 321` checks). It
confirmed incompatible owners coexist, compatible owners merge only through
an exact directed bijection, every live shape and parent-qualified proof moves
on union, shape IDs derive from `(owner,term)`, parent-use pairs sort by both
columns, and malformed maps, arbitrary IDs, dropped transfers, retained
compatible collisions, and schema v2 all reject. Focused counts were
`TheoryStateTest=4205`, `TheoryRebuildTest=105`,
`TheoryDeterminismTest=47`, `VerifierTest=88`, writer `94` twice,
inspection `68`, semantic mutations `42`, with census exactly `1/2/0`.
No new fault ID was assigned and Phase 4 is closed.

That closure statement records the earlier review protocol. It is superseded
by `adversarial-review-protocol.md`; current closure requires five fresh
unanimous reviews of one unchanged snapshot.

## Current Max-Adversarial Review Incidents

- One attempted current reviewer was terminated by the review service before
  producing any report after receiving the mandated hostile-producer wording.
  It is recorded as a service failure, not a verdict and not one of the five
  required ballots. A fresh replacement review was started. Phase 4 remains
  blocked independently by the incomplete formal and claim-census gates.

## Current Preliminary Review: FAIL

The replacement reviewer reconstructed 13 Phase 4 and cross-boundary faults
and produced a same-revision witness-change falsifier. Before repair it
reported `cachedResolution=0` and `freshResolution=1` while the existing state,
rebuild, determinism, and verifier suites all passed. The cache, exception
partition, quiescence, schema text, hash claim, and producer-boundary findings
are recorded as P4-F08 through P4-F13 above. This was a preliminary failing
review of a dirty worktree, not a ballot. Every future Phase 4 vote is void
until the complete formal/refinement ledger closes on one immutable snapshot.

## Current Rebuild Replacement Review

**Verdict: PASS for the explicitly bounded Phase 4 scope.** The report is
`/tmp/acgn-phase4-second-replacement-review-20260821.md`, SHA-256
`51be23abbdf7f6a981eeb31a8263f834d9710f459db5155fe863ae73a1b5906a`.
It compiled all producer and verifier sources outside the repository, passed
19,258 counted producer checks plus the unnumbered saturation and ablation
suites, passed 134 verifier checks and all three Phase 4 Lean modules, and
retained the schema-v8 census `1/2/0`. Both required rebuild no-op mutants were
killed by the exact owner-bucket postcondition in full and isolated runs.

This is bounded remediation evidence for P4-F23, not an immutable five-review
ballot. The traceability matrix still marks the universal/refinement portions
of P4-01, P4-04, P4-06, P4-07, P4-08, P4-10, and P4-11 partial. No
Java/JVM refinement theorem or whole-artifact closure is claimed.
