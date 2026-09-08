# Container Witness Transitions

This is the bounded v2.15 implementation slice for P2-20 and P2-18. It does
not replace the parent requirement statements or confer release authority.
The shared fourth-five runner owns input freezing, claim registration,
provenance, clean-build evidence binding, and the final closure decision.

## Interface

- Proof: `docs/section3-repair-audit/formal/ContainerWitnessTransitions.lean`.
  No imports or additional proof dependencies; Lean 4.33.0 is required.
- Test: `is.fivefivefive.CanDis.theory.ContainerWitnessTransitionsRegressionTest`.
  Optional single argument is the observation TSV output path. `src` compiles
  alone; public-API reflection loads verifier classes only at runtime, in both
  no-argument and output-file modes. Missing runtime APIs fail, never skip.
- Extractor: `ContainerWitnessTransitionsExtractor ROOT OUTPUT.tsv`.
  Full JDK 17, including `jdk.compiler`, is required. It resolves `src` and
  `certificate-verifier/src`, never `certificate-verifier/test`.
- Plugin: `scripts/fourth_container_replays.py`; `generate(build, formal)`
  returns one `(ContainerWitnessReplay.lean, source, 102)` record.
- `negatives(build, formal)` returns nine `(label, file, source)` controls.
  `source_mutations()` returns seven `(label, relativeSource, uniqueOld, new,
  extractor)` controls. Mutations belong only in isolated generated copies.
- Traces: `container-witness.tsv` and `container-witness-source.tsv`.

## Frozen Census

The encoder independently enumerates exactly 1,617 observation identities.
It rejects omissions, extras, duplicate identities, renumbered duplicates,
noncanonical values, changed request trees/words, changed stages, and changed
field-control counts. No observation supplies its own expected census.

| Surface | Rows | Exact finite domain |
| --- | ---: | --- |
| Typed recursive construction | 1,413 | All words of lengths 1-4 over three distinct, same-type complete port identities; every binary association, with a unary root at length 1; Boolean AND under FORBID and MODULAR, integer IPLUS under MODULAR |
| Structural carrier trace | 93 | Seq, Bag, Set; all two-symbol words of lengths 0-4, including repeats and empty structural carriers |
| Typed/authority boundaries | 42 | Fourteen named rejections for each of the three typed families |
| Production UNIT admission | 6 | Both profiles, all three K0 carrier kinds; all remain rejected |
| Parser/adapter path | 6 | Left/right relational-union association and a mixed intersection/union barrier under both parser-authorized profiles |
| Independent FULL wire replay | 37 | Three positive exports and 34 one-field/ledger rejection controls |
| Recursive FULL wire replay | 20 | All five four-leaf binary associations of `[1,0,1,0]`, separately exported for Boolean Set and integer Bag; ten positives and ten exact ledger-order reversals |

The fourteen boundary labels are `missingA`, `wrongAHead`, `wrongAType`,
`wrongAPath`, `wrongASchema`, `wrongAProfile`, `wrongATheory`, `testAuthority`,
`leafType`, `leafContext`, `empty`, `nonflatPath`, `wrongTarget`, and
`mixedUnsealed`. Wrong leaf type is exercised in the same caller context;
it cannot pass merely by failing a different-context check.

FULL replay uses fresh typed graph insertions, a real construction-source
ledger, `CertificateExportSession.write`, public `Codec`/`Bundle`, and
`IndependentVerifier.verify(..., FULL, policy)`. Cases are a flat Boolean
Set quotient, a flat modular integer Bag permutation, and fixed nonflat
Boolean IFF Bag permutation. Theory and empty-CALL commitments are pinned
once from each original test-only bundle, never recomputed from a candidate.
There is no private verifier reflection or fabricated PASS result.

The recursive exports use fresh graphs and source ledgers for every shape.
Their rows retain the actual decoded wire source association, raw term order,
normalized outputs, fibers, and complete ordered splice coordinates. Wire term
IDs must preserve exactly the producer's two complete identity classes, and
each nested-source key must equal its exact producer occurrence key. Reversal
uses the public immutable wire constructors and codec and must be rejected
with `THEORY_MISMATCH`, not a malformed bundle or checksum failure.
The encoder binds each named `reverseSplices` input to the exact reversal of
that shape's independently enumerated ledger. Empty, substituted, duplicate,
or unreversed ledgers are rejected before replay; each accepted encoding also
proves equality with the executable Lean producer collector's reversed list.

The 34 wire controls vary permutation/quotient fiber indices, input/output
counts, trace key, exact left/right endpoints, target, splice path, outer
arity, nested arity, position, nested source, missing splice ledger entry,
and nonflat input order. Replacement structural keys remain syntactically
valid. The fiber, key, endpoint, target, splice-coordinate, and input-order
controls require `REJECTED:THEORY_MISMATCH`; count/ledger-shape controls
require `REJECTED:INVALID_RECORD_SHAPE`. Envelope checksums are rebuilt by
the real public codec, so a checksum failure cannot discharge a control.

## Proof And Correspondence

The 21 general theorems have explicit `#print axioms` audits. Executable
structural recursion gives a same-exact-index, nonempty, typed-associativity
flatten decision, its success/rejection characterization, concatenation
order, and occurrence-count preservation. Flattening retains repeats before
the separately modeled container quotient. The remaining theorems bind all
trace fields, exact permutation/quotient fibers, five splice coordinates,
nine law-index fields, and both concrete witness endpoints. The UNIT/deletion
decision remains false; empty structural storage never manufactures a unit.

`recursive_splice_order` proves, for arbitrary trees and structural source-key
functions, equality of the producer preorder collector and the verifier's
validate-child-then-insert-at-saved-position collector. `saved_ledger_position`
proves the exact list insertion identity for arbitrary preceding and nested
ledger entries. The ledger acceptance/rejection theorems bind the full ordered
coordinate list, not its set. Every recursive Java row is replayed against
these executable collectors; expected splice order is not just a Python literal.

The index model distinguishes structural coordinates, not just hashes. Java
independently reconstructs actual `container-law-index-v2`, law source
endpoints, `container-application-trace-v1`, and `associative-splice-v1`
keys through the supported structural-key API. Each scalar/child field is
varied individually and checked unequal. These are structural field-sensitivity
checks, distinct from the independently rejected wire mutations.

Each typed row checks actual recursive raw occurrence order, normalization
outputs, complete fibers, and ordered splice coordinates. The observed
outputs enter Lean independently of model outputs. The generated 102
theorems use kernel `decide`; nine mutated observation controls must fail
with the specific false-proposition diagnostic. A loader, syntax,
termination, resource, or unrelated theorem error is not accepted instead.

There are 13 exact source objects, each independently enumerated by the
extractor and encoder: `AlloyLawRegistry`, `CertificateBundleWriter`,
`CertificateVerifier`, `ContainerApplicationTrace`,
`ContainerConstructionCertificate`, `ContainerLawCertificate`,
`ContainerLawDeclaration`, `FlatApplication`, `FlatConstructionCertificate`,
`SemanticEvidenceVerifier`, `StructuralKey`, `TheoryAlloyAdapter`, and
`TypedENode`. Pins cover complete compiler-parsed class signatures and bodies,
plus resolved identifiers, selections, invocations, constructors, declarations,
types, modifiers, and enclosing-owner modifiers. The encoder checks the exact
frozen hashes, not merely their shape. Missing/ambiguous/unresolved mapping
fails closed. Compiler analysis failure is not a registered source rejection.

Source controls remove the law parameter, fiber coordinate, splice position,
same-head guard, final dispatch restriction, independent verifier fiber
comparison, or the repaired preorder insertion position. All seven must
produce compiler-resolved shape/binding mismatch,
exit 1, the `UNMODELED_SOURCE:` diagnostic, and no output trace.

The verifier class pin was consciously refreshed after reviewing the main
agent's single-line P3-03 correction of `SOURCE_COMMAND_CONTEXT_VERSION`
from `alloy-command-options-v2` to
`alloy-command-options-v4-independent-search-domain`. Its resolved binding
hash did not change. The subsequent reviewed preorder fix changed both the
verifier shape and binding pins: the saved `splicePosition` is captured before
child recursion and passed to the insertion afterward, retaining all validated
child fields. The final frozen verifier pins include both main-owned repairs.

The complete writer shape and binding pins were consciously refreshed after
reviewing the third main-owned repair: dependent-chain type registration now
collects exact DAG, product, and case types for the canonical left fold as well
as the source association. The diff does not change container serialization.
Self-checks predating this writer revision are superseded, not reused.

## Trust And Boundaries

- PROVED: the general executable Lean model contracts and concrete replay
  propositions, checked by the pinned Lean kernel. Audits use only the usual
  `propext`, `Classical.choice`, and `Quot.sound` logical dependencies where
  reported; there are no admitted or runtime-evaluated proof shortcuts.
- TESTED: the declared Java observation census, actual producer/local
  certificate verification, six parser-adapter cases, public FULL bundle
  controls, and twelve encoder contract tests.
- CHECKED: compiler-resolved source pins, unique source-mutation anchors,
  complete row/source censuses, field sensitivity, and deterministic artifacts
  in clean self-check builds.
- TRUSTED: JDK 17 compiler/runtime and compiler-tree interpretation; Python
  and the tested Java-to-Lean finite encoding; the pinned Lean toolchain and
  kernel; existing Alloy/parser libraries; filesystem, OS, hardware; SHA-256
  and byte/structural-key encodings. No hash injectivity theorem is asserted.
- OUT OF SCOPE: universal JVM/parser refinement, arbitrary production inputs,
  unlisted opcode/carrier/arity families, transferable parser/profile
  authority, arbitrary recursive graph cycles, general unit/deletion laws,
  and unadmitted laws. Existing test-only provenance stays test-only.

The original standalone collector's postorder rejected a valid four-leaf
recursive export. That was an in-scope P2-20 defect, not an out-of-scope
boundary. Main preserved the failing and repaired probe evidence under
`incidents/splice-order-before/` and repaired only verifier insertion order.
The complete five-shape Set/Bag export census and ledger-reversal controls now
cover this failure. Production edits remain main-owned; producer behavior is
unchanged for containers. Prior narrower evidence must not be reused as proof
of this repair.

## Self-Check Handoff

READY_FOR_REVIEW: the six owned files are stable after the exact reversal
adapter repair and conscious review of all three main-owned production
repairs. There are still no proof imports or additional proof dependencies.
No production file, shared runner/configuration, old package, or workspace
commit was changed by this slice.

Fresh evidence is in `/tmp/acgn-container-integrated-834lhtit`:

- `self-check-summary.json` records two clean builds, 1,617 Java observations,
  13 source objects, 21 proof theorem audits, 102 replay blocks, twelve encoder
  tests, nine false-`decide` controls, and seven resolved source controls.
- `commands.json` and per-build logs record separate src-only compilation,
  combined `src` plus `certificate-verifier/src` compilation, and both Java
  invocation modes. Both modes report 1,617 observations and 106,624 checks.
  No verifier test classes or private reflection are used.
- `deep-full-observations.json` retains the actual twenty recursive wire rows
  from each build: all five Set and all five Bag exports are `VERIFIED:NONE`,
  and each exact ledger reversal is `REJECTED:THEORY_MISMATCH`.
- Both TSVs, generated replay source, compiled model, and complete proof
  inventory are byte-identical across builds. The deterministic Git fixtures
  exist only in the temporary build directories and remain TEST_ONLY.
- All nine Lean negatives pass the shared false-proposition diagnostic check.
  All seven source controls pass the shared `UNMODELED_SOURCE:` diagnostic
  check, report resolved observed pins, and leave no output trace. Mutations
  are restored in isolated copies; the input hashes are checked unchanged.

The review finding in `review-container.md` was an encoder contract defect,
not a production exploit: case 1598 (`wireTree / 0 / 0:reverseSplices`) could
substitute `[]` for the registered reversal and still prove rejection. The
preserved `/tmp/acgn-container-reversal-adapter-probe/changed-row.json` now
raises `Blocked: container reverseSplices differs from the exact registered
reversal`. `reversal-adapter-recheck.json` binds this result to the preserved
probe and repaired encoder hashes. The twelfth encoder test checks empty,
substituted, duplicate, and unreversed ledgers for all ten named controls;
generated Lean additionally equates each observation to the executable
collector's exact reversed list. Production checks are unchanged.

Earlier evidence directories, including the interrupted pre-adapter-repair
run, are preserved but superseded. Temporary self-check setup failures from
missing fixture Git metadata and directory-symlinked dependency JARs were
resolved by using real isolated Git fixtures and copied dependencies, matching
the supported provenance API. Their partial logs are not final evidence.

These local results are a handoff, not a closure report or a reusable frozen
input-root claim. The main runner must rerun the slice against its frozen
manifest and registered verifiers, compare both isolated builds, and bind
the outputs to the fourth-five claims and declared TCB before publication.
