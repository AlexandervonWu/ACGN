# Stopped v3 Candidate: Distance And Operation Parity

## Status And Scope

The author stopped candidate run `d5bebb92-d7b5-422d-ad58-aac95162f171`
on November 7, 2026. Its source is
`5d9b127e476cb6edf8938780069b7b730ca5ff46`. The service was stopped, no
matching experiment workers remained, and the heartbeat was deleted. No
restart, tag, push or release is authorized by this investigation.

All completed natural stages and completed synthetic observations are retained.
The interrupted synthetic cohort is not a complete benchmark. Natural results
remain useful evidence; cancellation is not authorization to delete them.
The source manifest and measured JAR still describe the frozen run, not this
later investigation and patches. Earlier final cohorts remain unchanged.

The comparison below uses exactly 61,598 successful AST-distinct paired-oracle
rows, excluding the original 4,482 identical-AST rows. A streaming comparison
confirmed identical eligible paths, labels, predicate names and raw-AST
distances against the retained pre-repair run. Separate nearest-truth
measurements use 42,386 incorrect predicates and independent truth minima.

## What Widened

The signed mean gap (Fast minus certified) changed from -0.051625 to +0.137943.
Fast's sum changed from 860,530 to 872,207; the certified sum stayed 863,710.
The certified distance was unchanged on EVERY paired row, not only in aggregate.
Fast changed on 11,425 rows.

The larger absolute difference between means does not mean that overall
per-row agreement worsened. Previously, opposite-signed discrepancies canceled
more closely:

- Paired mismatches: 20,728 -> 15,331 (26.04% fewer).
- Sum of absolute paired discrepancies: 36,906 -> 29,963 (18.81% lower).
- Mean absolute paired discrepancy: 0.599143 -> 0.486428.
- Rows with smaller absolute discrepancy: 8,339; larger: 2,936; unchanged: 50,323.
- Old mismatch becoming equal: 6,533; old equality becoming a mismatch: 1,136.
- Nearest-truth mismatches: 14,841 -> 10,808.
- Sum of absolute nearest-truth discrepancies: 24,355 -> 18,955.

These improvements DO NOT satisfy the author's zero-disagreement requirement.
Both paired means remain in [13,15], but that is only an auxiliary gate.

## Mismatch Classification

`scripts/classify_distance_mismatches.py` classifies all 15,331 archived
disagreements, without rerunning the corpus or interpreting equal aggregate
means as parity. Its compact output is
`evidence/stopped-classification.json`. The exhaustive classified CSV and 52
selected diagnostic witnesses are retained externally under
`stopped-investigation/classification-20261107/` beside the supervision state.

- Matrix only: 15,307 rows (8,961 Fast-greater, 6,346 certified-greater).
- Temporal and matrix: 17 rows (15 Fast-greater, two certified-greater).
- Temporal only: two rows, both certified-greater.
- Quantifier and matrix: five rows, all Fast-greater.

These are disjoint symptom classes, not inferred root-cause counts. Each row
also records its signed gap, prior gap, introduced/improved/worsened status,
and confirmed contributing mechanism only where a source-backed witness
exists. Uninvestigated rows explicitly retain `UNCLASSIFIED`; assigning a JOIN
or binder bug to every matrix discrepancy would be unsupported. The six
correct-pool zero disagreements are a separate population, not extra members
of the 15,331 paired-oracle rows. Operation-sequence disagreement counts cannot
be reconstructed from these archives because no replay plans were exported.

## Mechanisms And Concrete Witnesses

The production changes in the candidate were confined to Fast comparison:
result-type-aware node costs in `CanonicalDistance.nodeUpdateCost`, and
presentation cleanup, local ALL grouping and ACI deduplication in
`EGraphNode.FastComparison.copy`. The certified producer was not repaired.
Adding result-type costs generally raises Fast costs; presentation quotienting
can lower them. The combined aggregate shift is not a measurement of either
change in isolation.

The existing audit already identified unequal binary/flat JOIN edit units,
unequal live temporal projections, and missing certified partial JOIN rotation
coverage. A shared scalar head-cost rule does not fix different operand
geometry or admitted representatives. There is still no implemented common
finite representation union/minimum connecting both tracks.

The largest newly worsened paired witness is
`coursesOld/both/xJnitBpFv9K74WNvf_inv14.als`: Fast 88 -> 49, certified 88 -> 88.
Its student body conjoins two quantified formulas related by exchanging the
two universally bound students. A source/projection replay confirms that Fast
retains one equivalent local ONE branch while the certified primary projection
retains both. The projected duplicate fallback compares nested OR operands
positionally despite their order-insensitive semantics. This is a confirmed
contributor, not evidence that it explains every remaining unit of distance.

The correct-truth pool changed from 282 certified-only and two Fast-only zero
pairs to zero certified-only and six Fast-only pairs. The two previously known
`classroom_rl/inv12` partial-JOIN pairs still give Fast 0 / certified 8.
The four new `productionLineNew/inv5` pairs all involve
`vxzQHEki2BEDvK5Fc_inv5.als` and give Fast 0 / certified 16; its body conjoins
two quantified implications expressing the same human/robot exclusion.
Independent source-based investigation identifies singleton collapse followed
by a missing parent flatten: the source child has head AND, but its certified
construction collapses to an OR invocation. The parent wraps that invocation
as a leaf without reconsidering same-instance OR associativity. The resulting
projection is `OR(OR(c,d),a,b)` versus flat `OR(c,d,a,b)`. Four original-source
inequivalence checks are UNSAT at scope 4; three reduced equivalences are UNSAT
at scopes 1 through 6, with satisfiable changed-membership controls. These are
bounded checks, not a universal soundness proof. Detailed evidence is in
`stopped-investigation/four-fast-only-20261107-a/README.txt`.

All paired-oracle zero subsets still match (4,088 each). Neither main path
gave an incorrect zero in paired or nearest-truth results. This distinguishes
the observed completeness/cost problem from a demonstrated unsound collapse.

## Operation-Sequence Blocker

The author now requires zero differing distances AND zero differing operation
sequences on all 61,598 eligible paired rows. Current evidence cannot establish
the latter: `CanonicalBatchTest` writes `legacyDiagnosticEdits` produced by
`Canonical.edits`. `QuotientRepairDistance.Result` exposes the total,
temporal/quantifier/matrix costs, orbit-exactness, authority and alignment count,
but no structured edit plan. Legacy strings are diagnostics, not a certified
backtrace or independently replayed minimal witness.

Required implementation boundary:

1. Define common admitted representation coordinates and typed edit operations.
2. Both paths independently produce optimal plans with the same deterministic
   tie-break. Equal scalar minima can otherwise select different valid plans.
3. Replay each plan and check its cost and admitted endpoints; preserve type,
   binder, temporal-phase and certificate-authority boundaries.
4. Compare exact ordered plans and costs over the original complete population.
   Missing, incomplete or unvalidated plans must block, not pass vacuously.

This investigation patches projected duplicate comparison; it does not yet
implement full repair-plan extraction or the missing singleton-composition
certificate bridge. Existing
`IncidentLaws.lean` and `UnionMinimum.lean` cover their documented laws and
conditional finite minima, not implemented plan extraction, deterministic
tie-breaking, replay correctness or Java refinement. Those new obligations
remain open. The empirical verifier now explicitly blocks G18 while independent
replay evidence is unavailable. `BatchParityGate` makes distance/component
mismatches fatal, retains a first-incident source/hash and both decompositions,
cancels dispatch and prevents ordinary file retries. Equal scalars also stop
with `REPLAY_WITNESS_UNAVAILABLE`; this is not a claim of implemented replay.
Partial JSON stays explicitly partial and no completed summary is published.
There is no bypass flag authorizing another corpus run with missing witnesses.

## Patch Boundary

The retained `RepairProjection.sameProjectedNode` change compares children of
order-insensitive nodes using a bijective matching, not their incidental list
positions. The matching preserves multiplicity, retains ordered comparison
for sequence nodes, and keeps operator, semantic payload, binding coordinate
and container-kind checks. A shared finite step budget fails rather than
returning a partial equality. Projection identity advances to v14.

The bounded source regression now measures Fast 49 / certified 50 for the
largest outlier, instead of the archived 49 / 88. Its residual is an explicit
singleton `AND(ONE(...))` in the certified repair projection, not an unexplained
scalar adjustment. The repair removes 38 units of this witness's 39-unit gap;
it does not satisfy exact parity. Four original production-line pairs still
measure 0 / 16 in both directions, and their missing composition stays visible
in the tests rather than being mislabeled a completed fix.

A separate singleton/parent-flattening prototype reached 0/0 on the reduced
witness, but is **not retained**: the source-to-expanded-construction evidence
link still needs a justified certificate bridge. The independent exporter
also reports `UNCHECKABLE: redundant shape coordinates are outside the
supported slice` on that witness. Recording an expanded construction as an
extra source root is not a substitute for proving its link to the original.
The conditional associativity and permutation lemmas in
`SingletonComposition.lean` do not discharge that Java/certificate obligation.
The four new correct-pool zero discrepancies therefore remain open.

No full-corpus replay, new performance measurement or 0/61,598 parity claim is
made for the patch. Partial JOIN rotations, binary/flat edit geometry, live
temporal phase ordering, complete admitted-space minimization and public
replay-plan extraction remain blockers before the next authorized corpus run.

## Bounded Validation

The final integrated `scripts/run_distance_parity_tests.sh` exits 0: three Lean
files compile (20 lemmas), 4,590 numbered Java checks pass, and the saturation
suite and fatal-gate unit checks pass. Two one-pair CLI tests exit nonzero as
required, retain their witnesses, and produce no completed results. Four
classification tests and six existing release-gate tests also pass. Known
0/16 and 49/50 cases are expected BLOCKED boundaries in those tests, not parity
successes. No full-corpus post-patch mismatch count has been measured.

The integrated log is
`stopped-investigation/gate-tests-20261107/final-regressions.log`; accompanying
`final-source-hashes.txt` and `final-proof-tool-hashes.txt` bind the tested Java,
proofs, runner, Python checks and JAR dependencies. Both hash inventories still
match after the run. This is bounded regression evidence, not a completed
mechanical closure or an independent certificate replay for unsupported inputs.
The earlier `regressions.log` tested the withdrawn prototype and is not evidence
for the final retained implementation. The independent investigation's
`singleton-patch-20261107/FINAL.txt` records the rejected source-exposure step,
both export failures and cleanup of its stopped disposable build.

## Evidence

### Proof-First Follow-Up Repairs

The preceding v14 measurements and withdrawn prototype are historical. The
follow-up v15 patch first checked `FlatExposure.lean`, then implemented a
source-linked Java exposure step. It retains the original flat source endpoint
and uses the graph's actual node-to-returned-invocation insertion/find equality
as a certificate premise. Exact leaf, context, operator, result type and
semantic profile are checked. It does **not** register an expanded expression
as an additional trusted source root. The repair projection composes Boolean
flattening after certified child collapse, retaining alternative representations
under explicit finite budgets. JOIN, binder and temporal boundaries are not
opened by this rule.

The reduced singleton witness and all four original production-line correct-pool
witnesses now measure **Fast 0 / certified 0** in both directions, with equal
canonical observations. These are bounded correct-pool checks, not a new
61,598-row paired-corpus measurement. The changed-membership negative control
remains nonzero in both paths. The largest outlier remains **49 / 50**; its
uncertified singleton-AND residual was not forcibly eliminated.

Independent bundle replay for the new source-linked exposure record is still
**BLOCKED**. The exporter rejects these records explicitly before emitting a
bundle; the test verifies that no bundle is written. Local certificate checks
and the Lean model do not establish universal Java refinement or independent
wire verification. The older redundant-coordinate export limitation also
remains open. Do not treat this patch as a completed certificate closure.

The second repair checked `AugmentedPrelude.lean` before changing the augmented
model writer. It uses Alloy's lexer and source positions to rename only the
module-name span. A module-less input is preserved in full after a new header;
existing module parameters, signatures, imports and surrounding text are not
discarded. The previous unconditional first-line removal is gone. Thirty-one
tests cover missing headers, first-line imports/signatures, comments, inline
declarations, CRLF/tabs, path names and multiline parameterized modules.

The final follow-up runner exits 0: five Lean files compile, 4,647 numbered Java
checks pass, the saturation and fatal-gate suites pass, both one-pair CLI stop
checks pass, and the four classification plus six release-gate Python tests
pass. The exposure unit tests include wrong leaf/node/context/type/profile,
missing insertion proof, repeated occurrences and a different-head barrier.

On this workstation the final log and Java/proof/tool/dependency hashes are in
`stopped-investigation/proof-first-patches-20261107/`. This remains bounded
regression evidence. Full-corpus execution, heartbeat supervision, publication
and tagging were not restarted. Remaining work includes independent exposure
wire replay, the 49/50 residual, partial JOIN rotations, common positive-distance
representation geometry, temporal-phase presentation, and independently
generated/replayed ordered edit plans. The fail-closed replay gate stays active.

### Residual Native Matrix Replay

The next bounded Astra investigation added `MatrixReplay.lean` before the Java
matrix replay APIs and the `DistanceReplayDiagnostics` postmortem CLI. Each
engine supplies its own native representatives, selected bindings and cost
functions. The checker consumes every child occurrence exactly once, checks
ordered versus unordered matching and recomputes derivation charges without
calling the distance search. Search/choice admission and native cost rules
remain trusted here. Receipts explicitly say `complete=false` and do not grant
public repair-plan or independent certificate authority.

Replaying `coursesOld/both/xJnitBpFv9K74WNvf_inv14.als`, `inv14` versus `inv14c`,
reproduces Fast **49 = 0 + 2 + 47** and certified **50 = 0 + 2 + 48**. The
diverging matrix branch is Fast `ONE -> IN` at cost 40 versus certified
`AND(ONE(...)) -> IN` at cost 41. The wrapper changes downstream child matching,
not merely a separately adjustable scalar charge. Both directions are covered
by bounded replay tests.

The original source AND has two ONE children. Its recorded certificate has
two fibers `[[0],[1]]` and distinct operand invocations (`e25` and `e47` in this
probe), not a singleton partition. Projection-level deduplication does not
establish the missing source-level equality certificate. The existing source
partition/singleton guards are retained: **the 49/50 metric residual is not
patched**. A sound repair must establish that occurrence-linked equality and
its composition before admitting the collapsed representative.

Parent review also reproduced a mutable-receipt aliasing bug: returning the
checker's cached JSON snapshots allowed a caller to tamper with a source
snapshot and verify it with that same checker. After checking the Lean
endpoint-separation contract, the Java emitter now returns independent JSON
copies. The regression failed before the patch and passes afterward. This is
a diagnostic-integrity repair, not a change to either metric.

Postmortem evidence is retained on the workstation under
`stopped-investigation/opseq-astra-20261107/replay-SCotAJw9/`; controller tests,
the aliasing reproducer and combined regressions are under
`stopped-investigation/opseq-controller-20261107/`. Full temporal/quantifier
edit plans, independent choice admission, source-certificate wire replay and
complete Java/Lean correspondence remain blockers. No corpus-wide zero-gap
claim follows from these bounded diagnostics.

### First Guarded Replay Scan

The author-authorized stop-first natural scan used clean local commit
`a6831f4cc602db194aaea21f4b47ba2a8367a3c7` and fresh run
`parity-opseq-20261107T182651Z`, with 16 workers, 8g heap, reward pool 100 and the
unchanged 12 GiB service cap / 6 GiB host reserve. Its frozen JAR SHA-256 is
`582454303ebf54630c359b61c95bb8351a404378ebe69e858aca6b15b2cbc3e3`.

The first observed incident was
`classroom_fol/both/2KmASqDBmqEueukiz_inv5.als`, `inv5` versus `inv5c`:
both decompositions are **[10, 0, 2, 8]**. The batch stopped nonzero with
`REPLAY_WITNESS_UNAVAILABLE`; afterward both native matrix receipts independently
replayed to 8. This is a missing complete-witness failure, not a measured
scalar disagreement. The partial archive contains zero completed result rows;
its placeholder summary averages are not corpus measurements.

The controller checked the frozen manifest before and after the bounded
postmortem. The service exited with status 1, MainPID became 0, and no batch or
postmortem JVM remained before recovery dispatch. The original incident and
diagnostic are preserved separately. Incident fingerprint:
`269b76f366cb92db3463e10ad9f6a91ecce65a972763d4ff0fdd440e8a78f59c`.
The actual `gpt-6-astra` agent
`01a1b6f9-4f81-7571-9191-e45c72efe56f` received the incident for one bounded
proof-first repair attempt; ownership and dispatch are recorded externally.
No automatic retry, heartbeat restart, push, tag or release occurred.

The bounded Astra follow-up checked `DeclarationReplay.lean` before implementing
fixed-native-order declaration backtraces and a separate occurrence/cost replay
checker. The missing two units are deletion of `ALL Class ONE` and
`ALL Person ONE`; reverse replay inserts those declarations. The certified
backtrace is constrained to the paid/parameter correspondence selected by its
matrix search. Identity-only temporal receipts account for zero temporal cost;
nonidentity temporal edits remain unsupported by this supplemental checker.

For this incident, each arm now has numerical diagnostic coverage of
**10 = 2 declaration units + 8 matrix units**, in both directions. Their matrix
operation shapes, child indices and costs match; that restricted comparison
does not equate their full labels or public action identities. An ordered
receipt-addressed diagnostic list is checked against the component receipts,
but is not represented as an executable common public-source repair plan.
All `complete`/`parityAuthority` flags remain false. No scalar metric was changed,
the original 49/50 residual is untouched, and the full batch gate still blocks.

The follow-up evidence, summary and hashes are under
`stopped-investigation/opseq-astra-20261107/first-incident-F4QFo6Pn/`.
Remaining obligations include canonical-order admission, scope-valid public
sequence linkage in common coordinates, general temporal replay, independent
source-certificate replay and Java/Lean correspondence. The new bounded tests
reject omitted/repeated/reordered/substituted declaration occurrences and
altered diagnostic action order; numerical coverage is not promoted to parity.

The parent's final combined runner exits 0: seven Lean contracts compile,
4,786 numbered Java checks pass, saturation and fatal-gate suites pass, both
batch stop CLI cases pass, and the residual/first-incident replay CLI checks
pass in both directions with overwrite refusal. Classification and release-gate
Python suites pass (4 and 6 tests), as do the 9 local controller tests. Java,
proof, tool and dependency hash inventories match the tested inputs. Logs and
inventories are in `opseq-controller-20261107/validation-after-astra/`.
This is bounded regression evidence, not full mechanical closure or a new
corpus measurement. The controller remains blocked with no automatic restart.

### Continued Regression: Local Domains And Native Replay

The author requested further regression rather than restarting the unchanged
fail-closed scan. The actual Astra owner remains
`01a1b6f9-4f81-7571-9191-e45c72efe56f` (`gpt-6-astra`). The next source-level
repair first checks `LocalDomainOperand.lean`, then represents an admitted
ambient-dependent local declaration domain as a real typed operand. It no
longer leaves that dependency only in a generated-name-sensitive descriptor.
Current-block dependencies and unsupported domains retain their existing path.

This lets the original two ONE operands produce the same typed invocation and
the actual source-linked singleton fiber `[[0,1]]`. The existing certificate
verifier and occurrence guard are retained; no projection-only equality or
scalar override is used. The original `xJnitBpFv9K74WNvf_inv14.als` pair now
returns **49/49 in both directions**, and both replay branches cost 40. The
local-domain regression also rejects substituting another source occurrence
or omitting its singleton evidence, distinguishes different ambient domains,
and checks reduced positive and negative examples with bounded Alloy scopes.
This supersedes the unresolved 49/50 status above, not its preserved evidence.

`TemporalReplay.lean` precedes a native Zhang-Shasha backtrace and separate
executable ordered-tree replay checker. Internal node deletion promotes its
children; insertion wraps a contiguous forest; relabeling keeps children.
The checker validates endpoint snapshots, current paths, unit charges and the
exact resulting tree without calling the distance search. Native phase
insertion/deletion is now covered for both arms, including explicit admitted
root-alternative selection. Ordinary child deletion still charges its raw
subtree; tests reject using a cheaper phase selection at that boundary.

Unordered matrix backtracing now obtains the attaining column assignment from
the existing Hungarian solver instead of the diagnostic's exponential subset
DP. Input traversal, assignment work, receipt size and recursion remain
bounded. Bounded exhaustive assignment and ordered-tree mapping oracles check
the attained costs; these tests are not a proof of all Java search behavior.
All public completeness/authority flags remain false and the batch stop gate
is unchanged.

The parent integration evidence is external at
`ACGN/intermediate/temporal-replay-20261107-O9K6GZ/`; Astra's local-domain
evidence is at `stopped-investigation/opseq-astra-20261107/singleton-equality-C7gHze2v/`.
The combined runner exited zero with all nine Lean contracts, 13,121 numbered
Java checks, CLI fail-stop/replay checks and ten Python checks passing.
`integration-inputs.sha256` was verified unchanged after the run; the complete
log is `integration-regressions.log` in the parent evidence directory.
No new full-corpus mean, zero subset or operation-sequence parity claim follows
from this repair. A fresh bounded diagnostic still finds **0/8** on
`partial-join.als`; that source-linked completeness gap is the next incident.

### Guarded Chain Edit Units And Incident Capture

The next Fast metric increment uses the already-proved guarded JOIN sequence
geometry without mutating retained binary source syntax. The existing
`GuardedJoinChain.lean` dependencies and new `FastChainGeometry.lean` compiled
before the Java edit. Every internal JOIN must retain matching parser-derived
result-type evidence from the same module; every interior flattened operand
must have at least two columns. Ordered occurrences, duplicate operands, and
unary endpoint types remain intact. Unsupported trees retain their binary
boundary; traversal budget exhaustion fails instead of publishing a minimum.

The reduced `chain-cost.als` and natural
`productionLine_v1/correct/Nc6rBGbJRWcFSpGY8_inv2.als` now replay at **1/1**,
previously **3/1**, in both directions. The focused test has 61 checks,
including wrong-module and missing-intermediate-type refusals. Evidence is
at `ACGN/intermediate/fast-chain-20261107-PHiw00/`. This repairs the P05 edit
unit witness; it does not establish the full representation-union minimum.

`IncidentReplay.lean` precedes the first-incident latch change. The latch is
published before IO or diagnostic work, and the immutable small incident is
written before capturing a separate `parity-native-replay.json`. Other workers
cannot dispatch another pair while capture runs. The sidecar retains native
operations from the already-prepared arms, not fabricated public plans.
Capture failure, changed source or failed persistence cannot clear the stop.
Focused concurrency, failure and CLI tests are retained at
`ACGN/intermediate/incident-replay-20261107-68PaDt/`.

A fresh diagnostic of `classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als` still
finds **17/11**: temporal **2/1**, matrix **15/10**. Fast retains two identical
native child-phase snapshots while the certified live projection retains one.
`temporal-next.json` in the chain evidence directory preserves this incident.
The CLI fail-stop regression now uses that unresolved witness, because the
former binary/flat witness has been repaired. Complete public replay remains
unavailable and no new full-corpus assessment is claimed.

### Certified Partial JOIN Repair

Astra's occurrence-linked rotation/realization repair now gives **0/0 in both
directions** on `partial-join.als` and both README P03 natural pairs, with equal
producer observations. The eight spurious edits in the longer certified path
come from the missing path `r.((s.D).C) -> (r.(s.D)).C -> ((r.s).D).C`.
Each rotation checks the distinct middle boundary columns and result type;
derived child nodes carry exact insertion equalities. The original occurrence
ledger remains authoritative, and flat `[r,s,D,C]` is still rejected.

`GuardedJoinRotation.lean` compiled before the Java repair. Thirty source
checks and fourteen kernel controls pass, including source/ledger substitution,
missing insertion evidence and an independently satisfiable unary-middle
counterexample. Compact evidence is in
`stopped-investigation/opseq-astra-20261107/partial-join-4YdiEpf5/evidence.json`.
The independent exporter explicitly refuses the new unsupported wire evidence;
this is not a complete public-certification claim.

The combined runner exited zero: sixteen Lean files, 13,226 numbered Java
checks, both CLI stop/replay suites and ten Python checks passed. The pre-run
input SHA inventory verified unchanged afterward. Log and inventory:
`ACGN/intermediate/join-integration-20261107-fgCFYL/`. The author's current rule
is shorter-replay-first fault diagnosis, not scalar selection, with full
source/certificate/typed-representation/edit alignment required on the
certified track. The remaining public-alignment and temporal gaps still block
a corpus-wide invariant claim or release.

### Shorter Replay And Closed Temporal Phases

The next bounded incident was
`classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als`, `inv4` / `inv4c`:
Fast 17 `[2,0,15]`, certified 11 `[1,0,10]` (temporal, quantifier, matrix).
Actual Astra agent `01a1b6f9-4f81-7571-9191-e45c72efe56f` first replayed the
archived shorter receipt against freshly prepared certified native endpoints.
The matrix checker forbids invoking distance search; endpoint/cost tampering
is rejected. Ten matrix edits plus one temporal edit replay to eleven, but
this does not discharge original-source/public certificate alignment.

Fast retained two identical closed `ALWAYS` phases with bodies
`NO(INTERSECT(Student,Teacher))`. Its extra charges were one temporal deletion
and a five-node duplicate matrix deletion. `ClosedTemporalPhase.lean` states
the local idempotence, Boolean-wrapper and reference-transport laws before the
Java refinement. The detached Fast view now admits only same-owner unary,
same-operator, typed closed leaves with no parameters, local/inherited bindings,
imports or child phases. It prunes only an admitted leaf whose reference was
removed by existing Boolean AND/OR deduplication. Original source names,
temporal authorities and certified child lists remain unchanged. A separate
metric coordinate transports later references without changing ordinary REF
semantic identity. Both directions now return **11/11**, `[1,0,10]`.

`ClosedTemporalPhaseTest` passes 69 checks, including mixed/binary tails,
different operators/parents, scope exclusions, identity preservation and key
budgets. A first solver test emitted a warning about possibly unsound static
reduction; those results are explicitly excluded. Replacement checks assert
temporal mode and 2..4-step bounds: scopes 1, 2 and 4 give UNSAT for the mixed-tail
equivalence counterexample and SAT for a mutable-time control impossible in
static semantics. The replacement log has no such warnings. These remain
bounded checks, not an unbounded proof or Java-Lean correspondence theorem.

The combined suite passes **13,314 numbered Java checks**, eighteen Lean files,
the unnumbered gate/saturation checks, three one-pair stop checks, the native
diagnostic CLI checks and ten Python tests. The 66,694-file input inventory was
unchanged after both the complete suite and a second clean Java build with
repeated retained stop checks. Evidence:

- `ACGN/intermediate/temporal-integration-20261107-FLmXNU/`, input inventory
  SHA-256 `a9137a1d0b812bc281f16b14dc84615d1efcce1f1c72819fd47a75289c10a03e`.
- Astra's compact record is under
  `ACGN/supervision/v3-20261107/stopped-investigation/opseq-astra-20261107/p06-shorter-ixbQgXM0/evidence.json`,
  SHA-256 `514ca543d8159c88817424a3264d0935c542cc19187b9ae25310d2cab0df5377`.

The certified producer was not changed by this increment. Full alignment stays
**BLOCKED**: an actual test-only export fails with
`UNCHECKABLE: retired collision records are not exportable`; public coordinates,
ordering/choice admission and source/Java-Lean correspondence remain unresolved.
The repaired 11/11 CLI pair therefore still stops with
`REPLAY_WITNESS_UNAVAILABLE`. A separate scoped temporal pair,
`trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als`, still stops at 21/22
(`[1,0,20]` / `[2,0,20]`). Both raw incidents are retained. No full-corpus run,
new mean, push, tag or release is implied by this checkpoint.

### Frozen Corpus Evidence

The old full inventory is `evidence/summary.json` and its companion CSV/JSON.
On this workstation, the new read-only audit lives in
`/media/augustus/8618-0ED0/ACGN/supervision/v3-20261107/natural-assessment-20261107/`.
Its `summary.json` pins input hashes, `paired-mismatches.csv` lists all differing
paired components, and `correct-pool-zero-disagreements.json` retains the six
exact source pairs. Raw completed outputs remain in the run's original
external directory. Do not mix these measurements with the older cohort or
relabel the frozen JAR as a later implementation.
