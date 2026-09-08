# Independent Container Review

Target: v2.15 FF-P2-20 / FF-P2-18. Mechanical-closure skill, normative
protocol, and frozen fourth-five configuration read. No internet,
implementation edits, new rules, or additional authority requested.

## Status

Final bounded review outcome: **PASS** after the two demonstrated repairs.
No blocking finding remains on the reviewed P2-20/P2-18 surface. The
producer/verifier preorder mismatch and the exact-reversal adapter false PASS
are both resolved; their original evidence is preserved below.

Machine-readable final targeted recheck:
`/tmp/acgn-container-review-20260908-adapter-fixed/review-result.json`.
Its input manifest root is
`337d4b172caf24f81578e050b820cca87715ba9744893b60e456c7d99b375aca`.
It explicitly binds the preceding actual Java execution root
`2cd0614b8567b1836a7365578ec8ea49f04b7a50539800b56db97022f7b4c82a`
and its trace hashes; execution source equality is checked rather than
silently rebinding a prior whole-package result.
This is not a full-package closure run or a claim of universal refinement.

## Preserved Counterexample

The smallest binary-tree depth exposing the order mismatch has four leaves:
`[1,[0,[1,0]]]`, one exact modular `ALLOY/IPLUS` instance, `Bag<One(Int)>`,
root path 0, admitted nonempty arity, exact registry A/C evidence, and one
caller context. Repeated leaves are retained in order `[1,0,1,0]`.
This shape/word is already in the original local census at
`flat / family 2 / 4:30:0` (case 1158).

The unmodified public path is `TypedENode.flatConstructCertified` -> local
`CertificateVerifier.verify` -> constructed graph insertion and source ledger
-> `CertificateExportSession.write` -> public `Codec`/`Bundle` ->
`IndependentVerifier.verify(FULL, policy)`. No certificate fields or private
state are forged. Provenance is TEST_ONLY; the CALL census is independently
empty and pinned before verification. This is not a parser-refinement claim.

Producer and writer emit splice paths `[[1],[1,1]]`. The old standalone
`flatInput` recurses before appending each parent, obtaining `[[1,1],[1]]`.
Consequently the valid export is `REJECTED:THEORY_MISMATCH`, detail
`Flat splice does not reconstruct from the visible source tree`. The
three-leaf control `[1,[0,1]]` verifies. Four leaves are minimal within binary
associations; no claim of global minimality over unary K+ trees is made.

Relevant anchors: `FlatConstructionCertificate.java:258`,
`CertificateBundleWriter.java:2232`, and
`certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java:2975`.
The original regression's FULL fixture at line 322 used only one splice and
therefore did not expose this failure.

This is relevant to P2-18's exact recursive splice witness boundary connected
to P2-20's legal flatten result, not a production constructor-mutation theory.
The local flatten/order/multiplicity results were not falsified. An added
notes-only exclusion of deeper exported order cannot resolve the concrete
supported boundary failure. The earlier scratch finite-census-only PASS
classification is superseded and must not be cited as closure.

Raw original evidence is retained unchanged in
`/tmp/acgn-container-review-20260908` and
`/tmp/acgn-container-review-20260908-latest`. The latter includes the profile
context-version repair and repinned verifier, but precedes the splice repair.

| Preserved Artifact | SHA-256 |
| --- | --- |
| Original snapshot manifest | `5c7fbd757b3bc3fb1ca6f8db10d36fce13c94715d33dcdc6b660ffdf14885ec8` |
| Profile-repinned snapshot manifest | `0e76b1e7aaea129c71e6ee86bf80a0f1667c041aafcf26b68c3c376aaa133fb8` |
| Unchanged `SpliceOrderProbe.java` | `05b292ddc4152bd7537c8122be99b3bfd0b863702289f4c30c3445e770bb6469` |
| Both pre-splice `splice-order-probe.log` files | `43b29c1a2f1d9cb2a14e717dd5d998cd461c678f0b267dfbb4a2d7379e9c8537` |
| Profile-repinned `deep.acgncert` | `994af2a4c4525dac06dfc25354a87e19038b0852697fd60bc8d9e5802cf42a14` |

The main independently reproduced the same rejection in
`/tmp/acgn-v215-splice-before/run.log` and reports post-fix acceptance in
`/tmp/acgn-v215-splice-before/after.log`.

One targeted parser reachability attempt, preserved as
`/tmp/acgn-container-review-20260908-latest/source-pipeline.log`, normalized
the source to a four-input application with no nested splices, then exhausted
its 1 GiB export heap. It establishes neither a parser-path semantic defect
nor a parser-path PASS. It is not used to discharge or block these claims.

## Repair Boundary

The first expanded adapter candidate also had a demonstrated frozen-control
false PASS. For `wireTree / family 0 / 0:reverseSplices` (case 1598), changing
only `splices` from `[[1,1,2,2,1],[1,2,2,1]]` to `[]` is accepted by
`program`; the generated `containerBlock99` kernel-checks with exit 0.
The new branch checks only that a rejected ledger differs from preorder,
not that this named mutation is the exact registered reversal. This is a
strict finite adapter defect, not an allegation that the production verifier
accepts an empty ledger. The control must bind its actual mutation as well as
its false acceptance decision. No new production authority is required.

Raw decisive data and copied adapter/test source are preserved under
`/tmp/acgn-container-reversal-adapter-probe`. The synthetic table is used only
to test the encoder's contract, never as producer execution evidence.

| Adapter Counterexample Artifact | SHA-256 |
| --- | --- |
| `fourth_container_replays.py` | `6cf6aa834a471a8c8fbce4154dfc1216f287e20b0e590cc64f3f6be8e9344849` |
| `changed-row.json` | `a8c6d6f675acd17652c79249d2628f5e582e94f8489a7ccc6b83bfaaaab97c69` |
| `ReversalAdapterProbe.lean` | `ae215e2e49dd1ed0efb727ac10b2fe4a237fdeb172dcfa62586dd3a58a81d5e7` |
| `probe.log` | `eef5a95801c3f5d63c6048617b11e608450498dbd8485b99544668f90ee273f0` |

The main's fix saves the splice-list size before child recursion, validates
the child using the existing checks, then inserts the reconstructed parent
at that saved position. This restores parent-before-descendant order while
preserving left-to-right sibling order. Exact path, arity, position, nested
source, operator, context, schema, endpoint, law and profile checks remain.
The separate profile context-version correction is not a container law change.

## Final Recheck

- CHECKED: the preorder patch preserves every existing child-validation and
  exact-index comparison; its list insertion is at the saved prefix length.
  The A2-11 writer patch affects dependent type collection, not the container
  serialization loop. The public reflection bridge uses public constructors,
  methods and fields, retains one original verification policy, propagates
  errors, and does not synthesize verifier outcomes.
- PROVED in the bounded model: the current 21 theorems kernel-compile,
  including producer/verifier splice-list equality, saved insertion position,
  accepted ledger order and changed-order rejection. This does not make the
  encoder's named negative fixture exact; the concrete false PASS above remains.
- TESTED: source-only producer compilation and separate verifier compilation
  pass in `/tmp/acgn-container-review-20260908-settled`. The fresh settled
  snapshot passes all 1,617 Java observations, 13 source objects, 21 model and
  102 replay theorems with exact inventories/axiom audits, eleven encoder
  tests, and nine registered false-proposition rejections. The unchanged
  original deep producer probe now returns `VERIFIED:NONE`; the independently
  reversed public ledger returns `REJECTED:THEORY_MISMATCH`.
- CHECKED before the guard repair: the settled adapter generated byte-identical
  `ReversalAdapterProbe.lean`, and the current model is byte-identical to the
  model used by its successful kernel run. The final diagnostic script checks
  those equalities mechanically before emitting the preserved BLOCKED record.
- The first final-run attempt caught the A2-11 writer source before its
  paired pin update; its extraction failure is retained as a handoff race,
  not a semantic finding. The settled rerun resolves this: both pin tables
  match the actual writer and verifier and source extraction passes. Only
  unrelated chain-area files changed during that run; the container code,
  proof, docs, writer, verifier and pins remained fixed.
- Before the guard repair, applying `splices=[]` to actual executed Java row 1598 generated a
  kernel-accepted `ActualReversalAdapterProbe.lean` (exit 0). Its hash is
  `ae215e2e49dd1ed0efb727ac10b2fe4a237fdeb172dcfa62586dd3a58a81d5e7`,
  equal to the initial synthetic counterexample. Actual Java trace hash:
  `39099895569fd04e6015fe55f0c4bfee995b75ae0efaa54df504906dc5203e32`.

## Exact-Reversal Repair

The final adapter adds only the targeted exact-reversal guard and its Lean
equality conjunct. A named negative row must contain
`list(reversed(required_splices))`, independently enumerated from its frozen
tree; arbitrary malformed ledgers no longer substitute for the intended
control. The emitted proposition additionally checks equality with the
executable Lean producer collector's reversed list. The ordinary accepted
ledger decision and all Java source/authority checks are unchanged.

The single targeted recheck uses the actual 1,617-row Java output, not a new
synthetic producer trace. Empty-ledger substitutions for all ten registered
reversal rows raise the exact registered-reversal BLOCK. All twelve encoder
tests pass, including empty, changed-coordinate, unreversed and duplicate
ledger substitutions. The legitimate complete trace regenerates 102 replay
theorems, all kernel-checking with exact inventories/axiom audits. The 21
model theorems are freshly checked as well. The producer regression, model,
writer, verifier and extractor hashes are mechanically unchanged from the
settled end-to-end run.

Final recheck logs are under
`/tmp/acgn-container-review-20260908-adapter-fixed`. SHA-256 bindings:

| Final Evidence | SHA-256 |
| --- | --- |
| `encoder-tests.log` | `0456c5c1c43ac4837f60336970850d0477a4865145a5c6cd1d992d1e6a9b801c` |
| `model-proof.log` | `fcbe4a59967095b6f32242cbca095492515c8e43121ae017803169063f166811` |
| `replay-proof.log` | `e3be14436bf540d02e3f98b213b727feae53f8febc5c858953a5f8127859c296` |

The original unit/deletion admission remains false; no missing UNIT rule is
requested. Structural field sensitivity, exact wire validation, Lean model
facts and trusted source/codec interpretation remain distinct. Trust is the
frozen fourth-five TCB, including Lean/JDK/Python, parser/type/encoding
interpretation, SHA-256, OS and hardware. Full JVM/parser refinement,
publication authority, new laws and whole-corpus guarantees remain excluded.

Current reviewed file hashes are in the final manifest; principal entries:

| File | SHA-256 |
| --- | --- |
| `ContainerWitnessTransitions.lean` | `8da6e55e46087e9cf08c40635813b1ca03bc85f445eab4c42ad1739a996f29eb` |
| `ContainerWitnessTransitionsRegressionTest.java` | `00c3075783b82ddc5991fab9387943b2b73c6adaef36d8c87292bc8c264a465b` |
| `ContainerWitnessTransitionsExtractor.java` | `f64647a41d94a49ad40aa668915352652615e40fcad42a6f2ea0e77f59004811` |
| `fourth_container_replays.py` | `72dcff9daa5ed4aca4a419f34b312984f4513521b2ee0676009465e9f95e31eb` |
| `test_fourth_container_replays.py` | `de4b68f4889affd06a714dd1b06fb1356a7b8c1cc814d600d557c3b92991de55` |
| `container-notes.md` (reviewed snapshot) | `fb02d5a278fb810b0a1906199e4c8a4c89223a26ddc6bd280fddb16bd8660bee` |
| `SemanticEvidenceVerifier.java` | `ec63aab42919edce0483dd93b50b755da5cedcb8dedc184291f3dfd08a238037` |
| `CertificateBundleWriter.java` | `0bfba740161bb7495aae130b25999b5255662a3aef0f1fae3b0751b3d42636c5` |

Stop: the requested targeted recheck is complete; no discovery expansion.
This review is not the full package's mechanical VERIFIED decision. Two same-root
clean builds, all seven registered source controls, determinism and provenance
remain the registered runner's responsibility under the declared TCB.
