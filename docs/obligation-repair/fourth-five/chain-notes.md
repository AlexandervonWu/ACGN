# A2-07 And A2-11 Dependent Chain Witnesses

Candidate contribution only. The aggregate harness owns the frozen input root,
registered claims/verifiers, two clean builds, provenance, separate review,
and final machine-readable closure decision. Neither a synthetic encoder test
nor this note is authority for a Java observation or parent-status promotion.

## Integration

- Proof: `docs/section3-repair-audit/formal/DependentChainWitnesses.lean`.
  No imports or proof dependencies. Lean 4.33.0; 28 named theorem audits.
- Java main: `is.fivefivefive.CanDis.theory.DependentChainWitnessesRegressionTest`.
  Zero arguments runs assertions; one argument writes the observation TSV only
  after all checks pass. Source-only javac compilation needs no verifier types.
  Runtime classpath must contain the producer, libraries, and verifier classes.
  All reflective operations target public APIs through `getMethod` or public
  constructors. There is no private lookup, accessibility override, reflection
  mutation, allocation bypass, or additional helper file.
- The main temporarily sets and finally restores the existing TEST_ONLY
  provenance property. It never supplies publication provenance or commits.
- Extractor: `DependentChainWitnessesExtractor ROOT OUTPUT.tsv`, JDK 17,
  no helper dependency. It resolves 13 whole classes and checks fixed AST and
  binding hashes, including method/field/constructor ownership and modifiers.
  The AST representation includes literals. It deletes stale output first.
- Plugin: `scripts/fourth_chain_replays.py`; `generate(build, formal)` returns
  `[('DependentChainWitnessReplay.lean', source, 8754)]`.
  Namespace: `ACGN.FourthFive.DependentChainWitnessReplay`.
- Inputs: `dependent-chain-witness.tsv` and
  `dependent-chain-witness-source.tsv`. The plugin reads no other trace.
- `negatives(build, formal)` returns 16 closed false-proposition modules.
  `source_mutations()` returns 20 five-tuples ending with
  `DependentChainWitnessesExtractor`. Each source anchor is unique. Mutations
  run only in isolated copies, never in this worktree.
- Encoder checks: `PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_fourth_chain_replays.py -v`.
  Eighteen tests. Their synthetic rows are never substituted for Java evidence.

## Frozen Candidate Surface

Parent A2-07 retains claim hash
`1f73b67ab4d51c8aa6cea982b564d710f2a6711852633153eedd075026a87f6e`.
Parent A2-11 retains claim hash
`d12228a367db5e5046a6eb901b867b559db8c57590b6c91ada4e8dd473459ef5`.
The old matrix and packages are unchanged by this contribution.

| Check | Pass Predicate | Blocking Condition |
| --- | --- | --- |
| General proof | All 28 theorems compile and every audit contains only admitted foundations | Missing theorem/audit, warning, failed compilation, forbidden assumption |
| Source conformance | Exactly 13 fixed owner/AST/binding tuples | Missing, duplicate, foreign, unresolved, or changed tuple |
| Actual observations | Main completes all 48 writer bundles and the exact 8,741-row census | Any failed assertion, missing output, census drift |
| Replay | All 8,754 generated propositions compile with audited ordinary kernel decisions | Schema/census/input drift, false proposition, missing audit |
| Controls | All 16 false-decide modules and 20 source variants reject at their intended boundaries | Acceptance, syntax/import failure, compiler failure instead of source-pin rejection |
| Encoder | All 18 adversarial tests pass | Missing or failed test |

Every verification-relevant source/library/tool/compiler option, this proof,
the regression, extractor, plugin, encoder test, and notes must be in the
aggregate manifest. Source or evidence changes invalidate the prior root.
Development checks below do not replace the aggregate's two isolated builds.

## Proof Boundary

`derive` is executable on exact family and primitive descriptors. The exact
rule requires the stored family to be exactly the view, with positive retained
arity and positional product widths. The primitive rule requires precisely
one unary alternative containing the supplied Int or nominal column. An opaque
or missing type has no rule. Explicit `univ` is a supplied nominal column,
never a fallback. A positive-arity empty family admits the exact rule but
cannot be justified by a primitive singleton rule.

These descriptors are the image of validated Java types, not a proof of the
entire GraphType parser, nominal-name admission grammar, or union normalization.
The finite replay independently constructs exact Java type keys. Primitive
AlloyCarrier storage is retained separately from its unary relation view.
The general proof never obtains parser authority from text or equality.
Parser-authenticated subfamily admission is not added to `derive`; attempts
to substitute that rule on the exact fixtures are negative controls, not
positive claims about external parser authority.

`leafProof` and `leafKey` preserve the typing rule, exact stored type, relation
view, port, and DAG key. Theorems establish their coordinate injectivity.
`checkLeaf` links that serialized proof to `storedKey` of the same descriptor
used for derivation; a separately supplied unrelated stored-type key cannot
satisfy the check. All 144 actual leaf observations execute this contract.
`applicationKey` retains the binary source association, kind, context, output,
DAG, ordered children, and complete case sequence.

`foldSteps` is a general executable reconstruction parameterized by an explicit
combination function. It starts at operand zero, numbers steps from one,
records both input DAGs, the full case matrix, and the result DAG, and continues
through every remaining operand. `fold_step_count` proves no step is omitted.
The two reconstruction theorems connect successful reconstruction in both
directions to the complete fold. A mismatching final result is rejected.
Index injectivity preserves version, digest spelling, kind, every operand,
every fold-step key, and result. The step theorem retains the serialized index
coordinate, inputs, matrix, and result. The certificate detail theorem also
retains profile, exact source, source occurrence, and target.

`requiredTypes` traverses the complete index, including every certified fold
step and every complete case. It recognizes the six GraphType kind tags and
reconstructs the implicit exact relation type of each DAG product and case
result product. Case products remain requirements even when normalization
prunes them from a later DAG. `publishes` checks membership in the actual
published ledger. `register_coverage`, `index_registry_coverage`, and
`reconstructed_registry_fold_coverage` prove that registration covers the full
certified fold, including all intermediate result DAGs, independently of the
original binary source association. `step_registry_case` and
`product_registry_exact_relation` cover complete cases and their implicit
product types. `missing_required_type_rejected` is the executable omission
contract. These are model theorems, not universal proofs of writer execution.

For each real bundle Java independently resolves the published exact-type
records through their public wire IDs and type references. Python independently
enumerates the exact expected published ledger from the fixture certificate,
source, index, and target, including product requirements. Each of the 48 ledger
replays checks both exact observed ledger equality and executable `publishes`
against the complete independently reconstructed index.

Combination semantics are a declared dependency, not an assumed universal Java
refinement theorem. For this finite census Python independently computes exact
JOIN boundary matches, removes exactly the adjacent boundary columns, or takes
the ordered ARROW Cartesian product; it constructs all case keys and DAGs.
The generated Lean replay instantiates `Combine` with that finite table and
checks `reconstruct` against actual producer and writer index keys. Certificate
keys, complete source trees, typed ports, profiles, endpoints, target operator,
ordered dependent Seq schema, and source occurrence payloads are independently
constructed in Python, not copied from observed expected fields.

SHA-256 injectivity is not proved. The fixed theory text/version digest and
five-field profile fingerprint are recomputed by Python and checked against
real Java/writer values. Cryptographic binding remains explicit trust.

## Finite Census

The TSV has seven exact columns: `surface fixture coordinate producer writer
verifier status`. The three value cells use canonical ASCII Base64. Keys use
the real length-prefixed structural format, parsed recursively with strict
framing, node/depth/size bounds, no leading-zero counts, and no trailing bytes.
Unknown/duplicate/missing fixtures, malformed encodings, and undeclared failure
classes block. Observed outcomes are retained as propositions, not replaced
with the Python oracle.

- 96 leaf-grid rows: twelve stored types by eight relation/nonrelation views.
  They include Int, AlloyCarrier with prefixed and unprefixed nominal names,
  explicit `univ`, unary/binary relations, retained-arity empty relations,
  Bool, type variables, malformed carrier shape, and a variable carrier child.
- 48 actual writer bundles: JOIN and ARROW; six fixtures (`exact`, `primitive`,
  `int`, `univ`, `empty`, `repeat`); both overflow profiles; both three-leaf
  binary associations. JOIN repeat reuses the same port three times.
- 240 chain rows record the theory index, certificate key, source key, profile,
  and theory version/text/digest. 144 rows record all leaf proof keys and rules.
- 48 ledger rows record complete producer index requirements, actual published
  exact-type keys, and the actual public FULL result.
- 8,213 public-verifier one-field controls, once per operator/fixture except
  the additional right-associated intermediate deletion:
  5,910 recursive index coordinates; 1,457 writer-wire scalar coordinates;
  530 recursive leaf-proof coordinates; 108 certificate detail slots;
  72 alternative known leaf rules; 48 kind/profile/target/source controls;
  and 88 exact-type ledger deletions. The latter include every required type
  on the twelve canonical fixtures and the left-fold-only unary relation B
  on `JOIN:primitive:0:1`. That type is explicitly checked to be absent from
  the original source-association requirements, present in the published
  ledger, and necessary to public verification (`THEORY_MISMATCH` on deletion).
  Key traversal changes every tag/scalar, deletes each child independently,
  and swaps every adjacent pair of distinct children. Equal-child swaps are
  explicitly excluded as vacuous; duplicate preservation is checked positively.
- 13 source rows plus 8,741 observations give 8,754 replay theorems.

Every base bundle goes through actual producer certification, the real writer,
public `Codec` and `Bundle`, and public `IndependentVerifier` with `FULL`.
The fixtures have an independently fixed empty CALL set. The caller commitment
is computed from the fixed fixture identifier, its input bytes, and that empty
set; it is not obtained by feeding `CallOccurrenceCommitment.inspect()` back
into verification. The declared theory's full manifest scalars are checked
before pinning its content digest. This grants only TEST_ONLY fixture trust,
not parser provenance, source-command authority, or external subtype authority.

Controls mutate one field of a decoded real writer record, rebuild the enclosing
manifest digest, require public Bundle parsing to succeed, re-encode through
the real Codec, then invoke public FULL verification on a fresh verifier.
No producer object crosses that API. Rejection must not be INTERNAL_ERROR or
RESOURCE_LIMIT. Profile DIGEST_MISMATCH is a semantic field check after valid
envelope/manifest parsing, not an unrepaired enclosing digest failure.

## Development Evidence

The original unmutated `JOIN:primitive:0:1` failed because the writer omitted
the left-fold-only unary relation B. The unchanged fixture is
`A . ((A->B) . (B->C))`, with A stored as AlloyCarrier. Main owns the production
repair: before snapshotting the exact-type ledger, the writer now collects the
source association and canonical fold, all DAGs, products, ancestry, boundaries,
and complete case results, and checks the final fold DAG equals the certified
source DAG. There is no fallback, added fixture type, or verifier relaxation.
Pre-fix evidence is retained at `/tmp/acgn-v215-chain-before/run.log` and in
the independent review snapshots documented in `review-chain.md`.

Two fixture lifecycle issues were repaired only in the new regression: use
public `graph.rebuild()` before witness queries, and reuse the first existing
leaf for repeated positions instead of reinserting a colliding constant.
The repeated-port structural model, multiplicity, 96-point type grid, all
48 chain fixtures, and expected FULL acceptance are unchanged. Existing graph
quiescence and retired-collision export guards remain intact.

The verifier pin was consciously recomputed after reviewing both main-owned
corrections: the source-command v4 version literal and preservation of parent
preorder in flat-input splices. The writer pin was then consciously recomputed
after reviewing the fold-ledger correction above. Whole source SHA-256:

| Production Source | SHA-256 |
| --- | --- |
| `CertificateBundleWriter.java` | `0bfba740161bb7495aae130b25999b5255662a3aef0f1fae3b0751b3d42636c5` |
| `SemanticEvidenceVerifier.java` | `ec63aab42919edce0483dd93b50b755da5cedcb8dedc184291f3dfd08a238037` |

The fixed compiler-resolved writer AST/binding pair is
`94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6`
and `a8dc4e4157b854b38e8d98da97e6bf614c72ac4ffc7f08ef4fd39dc2bce4126d`.
The verifier pair is
`c91040e65f45bfc520051f2ccdba9aa6a609e01c0d597eba731fd613f65743da`
and `a96e5e846bc4901abe3350c51da5a02ba7650677d50a176ab88b8390e0660177`.
Both extractor and Python expected map pin these exact pairs. There is no
accept-current-source mode. All 20 source controls were rerun after both final
production files stabilized, including four fold/product/case ledger variants.

The first actual ledger replay encountered a kernel evaluation obstruction,
not a false ledger equality: Lean 4.33's string-prefix helper did not reduce
under ordinary `decide`. `/tmp/chain-witness-dev/formal/actual-replay.log`
preserves that failed run. The model now uses explicit decidable equality over
the six exact type tags. No synthetic row, native evaluation, new axiom, or
weakened proposition replaces an observation. The complete rerun is
`/tmp/chain-witness-dev/formal/actual-final.log`: exit 0, all 8,754 audits, no
warning, error, or `sorryAx`. The failed log is not final evidence.

Completed narrow development checks, distinct from aggregate frozen closure:

| Check | Result And Raw Evidence |
| --- | --- |
| All `src` compilation | JDK17 `--release 17`, producer-only output `/tmp/chain-witness-dev/current`; no verifier compile-time dependency |
| Verifier compilation | `certificate-verifier/src` only, output `/tmp/chain-witness-dev/current-verifier`; no verifier/test dependency |
| Optional-path main | Exit 0; `fold-ledger-run.log`: 8,741 rows, 48 bundles, 8,213 controls, 19,108 checks |
| No-argument main | Exit 0; `noargs-run.log`, identical counts; neither run needs an external provenance override |
| General proof | `formal/general-final.log`: 28 complete admitted-foundation audits, no warnings/errors |
| Actual replay | `formal/actual-final.log`: 8,754 complete admitted-foundation audits, no warnings/errors |
| Lean negatives | All 16 pass the shared strict false-decide diagnostic checker; `actual-negatives/chain-*/lean.log` |
| Source controls | All 20 pass the shared strict UNMODELED_SOURCE checker; `/tmp/chain-source-controls/chain-*.final.log` |
| Encoder suite | All 18 tests pass; synthetic unit data stays separate from the actual Java trace |

Relative raw-evidence paths in that table are under `/tmp/chain-witness-dev`.
The final actual input files are `dependent-chain-witness.tsv` and
`dependent-chain-witness-source.tsv` there. A failure writes only
`<requested trace>.failed.tsv`, never a successful trace; the plugin consumes
neither that partial diagnostic nor a synthetic unit fixture.

Reproduction entry points are the Integration commands above and:

```sh
java -cp '/tmp/chain-witness-dev/current:/tmp/chain-witness-dev/current-verifier:lib/*' is.fivefivefive.CanDis.theory.DependentChainWitnessesRegressionTest
java -cp '/tmp/chain-witness-dev/current:lib/*' DependentChainWitnessesExtractor . OUTPUT.tsv
```

Use the registered main harness for fresh builds, `generate`, negatives, source
variants, and final input binding; these local paths are development evidence,
not a substitute for the required two isolated clean builds.

## Classification

PROVED: the registered exact-leaf, structural-coordinate, complete-fold,
reconstruction, and registry-coverage theorems under their explicit
descriptor/combination/type-key boundary.
TESTED: only actually completed Java observations; synthetic encoder fixtures
are separate and cannot supply missing Java evidence. CHECKED: source pins,
schemas, finite census, key reconstruction, audited replay propositions and
rejection controls, when their respective executions finish successfully.

TRUSTED: Lean 4.33.0 kernel and printed standard foundations (`propext`,
`Classical.choice`, `Quot.sound`); JDK17 compiler binding resolution/JVM/public
reflection/standard library; pinned local libraries; Python and the reviewed
source-to-descriptor interpretation; SHA-256; filesystem/OS/hardware; and the
aggregate snapshot, evidence, provenance, and build machinery.

OUT OF SCOPE: whole-Java/heap/compiler/byte-parser refinement; general subtype,
disjointness, correlated-union normalization, or parser-authenticated subfamily
semantics; arbitrary nominal-name grammar; universal SHA-256 injectivity;
new rewrite, parser, certificate, or publication authority; production results,
unlisted claims, future revisions, and automatic promotion of the old parents.

## Final Reviewer Handoff

READY_FOR_REVIEW was sent after the actual complete replay, all theorem audits,
all 16 negative modules, all 20 source controls, and all 18 encoder tests passed.
No candidate blocker remains. This is not an aggregate closure verdict. Main
owns independent review, input freeze, full experiment reruns, and final closure.
No shared runner, config, matrix, release, old package, or production file was
edited by this contribution; no commit was created.

The six owned files are the five below plus this
`docs/obligation-repair/fourth-five/chain-notes.md`. Code and tests are frozen at
these SHA-256 values; the aggregate manifest records this note's final hash
externally rather than making it self-referential.

| Owned File | SHA-256 |
| --- | --- |
| `docs/section3-repair-audit/formal/DependentChainWitnesses.lean` | `329b0b5753f6d6d4f677515987dd256f5b3d4f5cd260d98c7a96296d4ad8441c` |
| `src/is/fivefivefive/CanDis/theory/DependentChainWitnessesRegressionTest.java` | `6c6e3303b5fada6f642a5dbbf5c81a87b9d4d9298db6accbd0e4947dca5b9e43` |
| `scripts/java/DependentChainWitnessesExtractor.java` | `bd8ec8871f63a67d0c89edd72df9545239075a6cc38852cd1a4cf3773187a3ca` |
| `scripts/fourth_chain_replays.py` | `e27d3bda35958b7cb7806ab8513630bcfeab420fb002b883e8ddebbc2c05416b` |
| `scripts/test_fourth_chain_replays.py` | `dd79e1908452392581f551e5ef6dd4a55aff2d842774a348ee412c90af8da551` |
