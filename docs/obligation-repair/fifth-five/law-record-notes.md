# P3-04 Complete Law-Record Wire Slice

## Scope And Integration

Area `law`, parent `P3-04`, proof `LawRecordWire.lean`, replay
`LawRecordWireReplay.lean`, trace `law-record-wire.tsv`, source trace
`law-record-wire-source.tsv`. The general proof is in
`docs/section3-repair-audit/formal/`; its namespace is
`ACGN.FifthFive.LawRecordWire`. Replay namespace:
`ACGN.FifthFive.LawRecordWireReplay`.

`fifth_law_record_replays.py` supplies the unchanged third/fourth dispatcher
`generate(build, formal)`, `negatives(build, formal)`, and
`source_mutations()` interfaces. No production, shared runner, old ledger,
experiment, or existing proof was modified by this area. Nothing was committed
or published. The authoritative original requirement remains unchanged:

> Law evidence binds exact operator identity, result/element types, path,
> carrier, policy, parameter, endpoints, and fixed theory digest.

Its original hash is
`3991aa4c4db10ffcd0bcc1bc0197fda0b30377e422d4804b44dd05fd89bdab89`.
This slice does not promote the original PARTIAL/DIRECT status or discharge
P1-19/A-01. Package closure remains the main harness's separately frozen run.

## Mechanical Surface

- PROVED: general seventeen-field structural record encoding/decoding,
  reconstruction iff exact fields, coordinate preservation, field corruption
  rejection, independent-registry membership, complete-table reconstruction,
  table cardinality and changed-table rejection, exact index/endpoint preimages,
  and matrix-guarded admission. The registry is an explicit parameter, not a
  record supplied by the claimant. Expected-entry reconstruction retains the
  profile, result and element keys, carrier, quotient, arity, law family and
  both endpoints. All named theorems print their dependencies.
- TESTED: 152 predeclared Java observations, including 48 accepted fixtures
  carrying 94 complete law records. Every registry opcode is exercised under
  fixed FORBID/MODULAR and parser-owned width-3 FORBID/width-6 MODULAR profiles.
  Witness types cover Bool, Int, unary/binary relations, empty relations,
  relation unions, comparable carriers and an opaque equality carrier. This
  is full opcode/law-family coverage over finite witnesses, not enumeration of
  all possible types or profiles.
- TESTED: 51 single-field corruptions cover all 17 fields on Set, modular
  variadic Bag, and fixed Bag fixtures. All 17 scalar omissions, extra scalar,
  scalar order, wrong tag/child count, record omissions/duplicates/order, and
  11 coherent recomputation attacks are predeclared. Each observed byte vector
  is encoded with public Wire/Codec APIs and passed to the PUBLIC standalone
  `IndependentVerifier.verify(..., KERNEL, policy)`. No private verifier API,
  reflective field mutation, or expected-string substitute is executed.
- CHECKED: five additional counterfeit vocabulary declarations reach the
  independent registry matrix/type checks for operator, result, element,
  carrier and policy. These are unused declarations, so unrelated term typing
  cannot short-circuit the intended observation. Exact Int evidence is added
  where required. Their law rows have recomputed parameter/index/endpoints,
  schema references and origin digests. The public result must be the exact
  fixed-matrix/type rejection, not merely any non-success outcome.
- CHECKED: every case recomputes and rechecks the outer vocabulary content ID.
  Exact types, schema keys, schema IDs and operator payload/reference censuses
  are independently reconstructed in the encoder. TEST_ONLY operator IDs are
  opaque references, not a claim of full operator-ID preimage refinement.
- CHECKED: ten complete javac-resolved class shape/binding pins cover the
  registry, certificate, origin, profile/factory, structural key, writer,
  standalone semantic verifier, Wire and Codec. Eighteen predeclared source
  controls must exit 1 with `UNMODELED_SOURCE:` and leave no successful trace.
  These pins are frozen constants, never learned during replay generation.

The Java execution census is fixed in the test and independently repeated in
the encoder. Missing, duplicated, reordered and additional observation/source
rows block. Producer certificate projections, actual writer records, actual
candidate payloads and public outcome/detail are separate observations.
The Python unit fixtures are synthetic encoder tests only.

## Encoding And Trust

Lean text is a Unicode scalar list. Structural-key framing counts UTF-16 units;
table comparison explicitly expands UTF-16 units and compares them
lexicographically. It does not use Lean String `<`. Supplementary U+10000
versus BMP U+E000, prefix and equal-string cases are checked in the Lean kernel
and by actual Java `String.compareTo` assertions. Isolated Java surrogates are
outside the scalar model and rejected by the public canonical UTF-8 codec.

The finite wire fixtures themselves are ASCII. The encoder interns exact texts
and lowers well-formed structural keys to shared constructor expressions only
after checking an exact parse/re-encode roundtrip. Malformed structural texts
remain literal observations. This is a tested TCB conversion, not a universal
parser refinement theorem. It cannot replace a different observed key with an
expected registry key. Raw binary codec grammar is the separate wire area;
this general record codec starts at the decoded-node boundary.

TRUSTED: Lean 4.33.0 kernel and its admitted `propext`, `Classical.choice`,
`Quot.sound`; JDK/javac 17; the frozen compiler extractor and tested Python
encoder/structural parser; Java/Python libraries; Alloy parser/profile/type
interpretation; SHA-256 implementation and collision resistance; OS/filesystem
and hardware. The general proof accepts an arbitrary digest function and
proves only equal-preimage/equal-digest, never hash injectivity. Finite SHA
results are independently computed over exact preimages by the encoder.

OUT_OF_SCOPE: universal JVM/parser refinement, all arbitrary Java strings and
types, publication or raw-source authority, cryptographic injectivity, whole
corpus experiments, unlisted/future sources, and stronger parent statements.
All generated producer artifacts are explicitly TEST_ONLY. KERNEL observations
do not claim FULL, PAIR, publication, or whole-corpus verification.

## Local Validation

Local evidence is under `/tmp/acgn-law-dev`,
`/tmp/acgn-law-source-controls-v1`, `/tmp/acgn-law-negative-controls-v2`, and
`/tmp/acgn-law-clean-v1`. These development checks are not a substitute for the
main harness's canonical manifest, two isolated proof builds, provenance and
machine-readable closure report.

- `PYTHONPATH=scripts python3 -m unittest scripts/test_fifth_law_record_replays.py`:
  18 tests passed.
- `LawRecordWireRegressionTest`: 152 observations passed; no production changes.
- `LawRecordWireExtractor`: all 10 frozen source objects matched.
- Source controls: 18/18 exited 1 with the exact source-rejection marker.
- Replay negatives: 60/60 exited 1 and passed the main harness's strict
  `check_rejection` diagnostic classifier.
- General proof: 27 named theorems, all dependency-audited with pinned Lean
  4.33.0, no unsupported proof declarations.
- Full replay: all 246 named theorems (94 entry reconstructions plus 152
  observations) passed the pinned Lean 4.33.0 kernel and the main harness's
  strict proof-log audit. Elapsed time was 168.26 seconds, peak RSS 2,046,600 KB.
  Final generated replay size is 343,869 UTF-8 bytes (338,480 characters).
- Fresh Java builds A and B each compiled all current producer/verifier sources,
  ran the 152-case regression, and matched all ten extractor pins. Their
  observation traces, source traces and generated replay sources are identical.
  The manifest/check report is `/tmp/acgn-law-clean-v1/report.json`; it is a
  local build/encoder report, not the package closure report.
- All 18 source-control logs additionally passed the main harness's strict
  `check_rejection` classifier. No package VERIFIED claim is made by this note.

Deterministic artifact SHA-256 values:

| Artifact | SHA-256 |
| --- | --- |
| `law-record-wire.tsv` | `bbad2d31bc408e78cad816902722cfe51716b8a8a5456d20e05f4a5527e6810b` |
| `law-record-wire-source.tsv` | `c36b0c5e9bdc865f82af30ee66549a6ce0e44f2162576eb9539fb1aadbc8ad14` |
| `LawRecordWireReplay.lean` | `9942a3eddf1bd8cf876b974e734d0da977bd0883f34a47e84be1a6b012c31686` |

The six area files are ready for the integrated freeze. The main harness must
still run its own two isolated proof builds and bind all area evidence to its
complete input root, verifier set and public provenance before deciding closure.

## Preserved False Starts

1. An initial partial javac invocation exposed fixture API naming mistakes and
   the repo's multi-file sealed-class compilation requirement. The fixture was
   corrected and subsequent checks compile all source files. A transient
   compile error in the concurrently developed canonical-wire test was reported
   without editing that file; the temporary exclusion was development-only.
2. Initial vocabulary mutations rejected at graph typing (and then missing
   exact Int coverage), not at registry admission. Those observations were
   rejected as inadequate evidence. Unused coherent declarations with the
   required exact-type evidence replaced them. No producer/verifier defect was
   found or production fix made.
3. Initial Lean drafts had elaboration errors; a stale `.olean` produced a
   failed local import attempt. These failed commands are not proof evidence.
   All accepted checks use the explicit 4.33.0 toolchain path, never default Lean.
4. Raw String replay reduction, then flattened scalar-list replay, consumed
   excessive memory. Those local runs were explicitly interrupted (exit 130).
   `replay-proof.log` and `replay-proof-v2.log` retain the two later interrupted
   scalar-list attempts; the initial String attempt was an interactive command.
   Shared structural dictionaries and reuse of general table lemmas replaced
   the costly representation without dropping fields, cases or predicates.
5. The original generic table-order draft used native Lean ordering. The
   integration review's U+10000/U+E000 witness exposed the model mismatch;
   the model now uses explicit Java-consistent UTF-16 ordering. This was a
   correspondence correction, not a production bug.
