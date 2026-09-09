# Canonical Wire Tables: Bounded P3-12 Candidate

Area `wire`, original parent `P3-12`. This package adds no production change,
changes no parent statement or status, and does not itself declare mechanical
closure. The main fifth-five runner owns registration, manifest/provenance
binding, and the final three-state decision. No commit or publication is made.

## Proof Surface

`docs/section3-repair-audit/formal/CanonicalWireTables.lean` has namespace
`ACGN.FifthFive.CanonicalWireTables`. Its 17 named general theorems all have
`#print axioms` audits. There is no `sorry`, user axiom, `unsafe`, or native
decision procedure. The proofs use the pinned Lean 4.33.0 kernel and Std;
the only logical dependencies appearing in the audits are `propext` and
`Quot.sound`. Structural mutual recursion makes the tree computations reduce
under `decide +kernel`.

- `Node` contains UTF-8 bytes, not Lean strings or Java UTF-16 code units.
  The executable grammar requires nonempty tags, canonical Unicode scalar
  encodings, and nonnegative signed-32-bit lengths/counts. Four-byte lengths
  are big-endian and count bytes, not characters. Empty scalar strings are legal.
- The fuelled parser handles recursive children, length framing, invalid UTF-8,
  and trailing bytes. The fuel is explicit; replays use 32 on depth-at-most-three
  fixtures. Java resource-limit policy is not generally refined by this model.
- `decode_exact` is conditional on successful decoding. It proves the actual
  production `Codec.decode` re-encode/equality guard, NOT a universal parser
  round-trip theorem or encoding injectivity. The census separately kernel-checks
  finite round trips of every valid wire-tree input. No general codec
  injectivity or whole-parser/JVM refinement is claimed.
- `content` changes the record tag to `tag/content`, removes precisely the
  first scalar, and retains all content scalars and ordered children. `preimage`
  is the raw node encoding, without the ACGNCERT envelope or envelope digest.
  General theorems prove exact preimages, ID-field independence, and equality
  of digests from equality of preimages for ANY supplied digest function.
  There is no converse and no hash-injectivity assumption.
- `javaLT` converts actual UTF-8 text to UTF-16 units before lexicographic
  comparison. `ascii_units` proves the ASCII special case generally. Named-ID
  vectors distinguish U+10000 from U+E000: Java puts U+10000 first, whereas
  UTF-8 byte order puts U+E000 first. Native Lean string order is never used as
  a substitute. Conversion assumes the separately checked UTF-8 grammar.
- `sortedSection` is an executable stable insertion-sort model. General proofs
  preserve the complete multiset of records, including duplicates, and show
  the empty scalar section shape. This is not a theorem about Java's sorting
  implementation. `accepted_head` and `accepted_rows_ordered` establish the
  grammar/ID/hash obligations at every accepted row and strict adjacent Java
  order, for arbitrary list length and digest function.
- `claimedContent` is an independent comparison of exact preimages with an
  explicitly retained baseline record. Rehashing does not make a differing
  claimed preimage equal. This is evidence comparison, not an extra rejection
  rule invented for `Bundle.parse`, and not an independently proved law,
  flat/container-record, or endpoint semantic verifier.

## Finite Execution Surface

`CanonicalWireTablesRegressionTest` emits 66 ordered observations:

| Surface | Count | Scope |
| --- | ---: | --- |
| Public writer | 2 | One- and three-class exported TEST_ONLY graphs |
| Indexed tables | 44 | Eight table families, focused term/witness controls |
| Content encoding | 7 | Empty, ASCII, delimiter/NUL, BMP, supplementary, combining and escaped scalar text |
| Byte grammar | 13 | Valid bytes, truncation, trailing data, all four length/count coordinates and malformed UTF-8 |

The public export path executes `CertificateBundleWriter.sortedSection` via
snapshots; the last snapshot's class-ID order is observed, independently
censused, and compared with the Lean sorting model. Its context record is
located in the actual producer file bytes, then compared with public Codec
re-encoding and the exact independently reconstructed context preimage/ID.
Java also checks full-file encode/decode byte equality for both exports.
The complete exported files and unobserved tables are not universal Lean
refinement evidence. These small exports do not distinguish numeric and
lexical e-class order; the named Unicode table controls distinguish actual
string order separately.

All eight indexed tables have empty and sorted cases. Terms and witnesses
also cover adjacent duplicates, descending order, separated duplicates,
section scalars, wrong tag, missing/empty ID, stale and recomputed scalar or
child content, recomputed wrong tag, and recomputed child-order changes.
Witnesses add the two Unicode order cases. `witnesses` is intentionally
NOT content-addressed; stale content IDs there are legal table grammar.
Separated duplicate IDs fail at the first descending pair, hence report
`NONCANONICAL_ENCODING`, not necessarily `DUPLICATE_ID`.

Recomputed scalar/child changes are accepted structurally and have false
baseline-preimage claims. A recomputed wrong record tag is still rejected as
`UNKNOWN_VARIANT`. The Lean table result groups wrong tags with shape failures,
while replay propositions separately check the exact observed Java code.
`exact` concerns the designated baseline record control, not whole-table
semantic equality. Here "valid" means wire/table validity; fabricated generic
term rows are not advertised as accepted kernel terms or publication evidence.

The test uses only public verifier reflection to preserve src-only compilation
independence, with no `setAccessible`, private API calls, or reflected state
mutation. Byte mutations use the public Wire/Codec/Bundle boundary and correctly
recompute envelope hashes. The producer UTF-8 helper is directly accessible to
this same-package regression test; seven additional assertions check it.

## Source And Replay Binding

`CanonicalWireTablesExtractor ROOT OUTPUT.tsv` requires JDK 17. It parses and
attributes the source tree with javac, uniquely resolves four complete owners
(`Bundle`, `CertificateBundleWriter`, `Codec`, `Wire`), then checks frozen AST
and resolved-symbol hashes including owners, types, and modifiers. Missing,
ambiguous, unresolved or changed sources fail closed with `UNMODELED_SOURCE:`.
Pins occur independently in the extractor and Python plugin; no learning mode
is present. Complete-class pins intentionally reject unrelated edits too.
These are compiler-resolved source identities, not a proof of Java semantics.

The Python census is fixed independently of observed rows. Missing, repeated,
reordered, extra-column, unregistered or changed-input observations are blocked;
changed outputs become false Lean propositions. Base64 spelling, byte bounds,
source census and exact pin values are checked. Generated code uses structural
nodes and shared byte dictionaries, not repeated expanded whole bundles.
`sha256Observed` is an explicit finite interpretation computed independently
with hashlib on exact preimages. Its unknown-input result is empty and cannot
satisfy a nonempty content-addressed ID. JDK/hashlib SHA-256 correctness and
collision resistance remain TRUSTED, not Lean-proved.

There are 13 false-observation Lean controls and 12 source controls. Source
controls change writer sorting/preimages/byte lengths; table order, empty IDs,
content validation, retained children and witness policy; codec byte lengths
and UTF-8 errors; and Wire's digest algorithm. They must compile through javac
attribution and fail the exact pin check, not merely fail compilation/crash.

## Integration

Register only this area in the main-owned dispatcher/config:

```python
{"id": "wire", "parents": ("P3-12",),
 "plugin": "fifth_wire_tables_replays.py",
 "proof": "CanonicalWireTables.lean",
 "replay": "CanonicalWireTablesReplay.lean",
 "test": "is.fivefivefive.CanDis.theory.CanonicalWireTablesRegressionTest",
 "trace": "canonical-wire-tables.tsv",
 "extractor": "CanonicalWireTablesExtractor",
 "sourceTrace": "canonical-wire-tables-source.tsv"}
```

The plugin exports `generate(build, formal)`, `negatives(build, formal)` and
no-argument `source_mutations()`, in the existing third/fourth dispatcher tuple
formats. Copy the NEW general proof from the established formal directory;
there are no other proof dependencies. Include the six owned files in the
main manifest and `scripts/test_fifth_wire_tables_replays.py` in area tests.
Compile Java sources from both `src` and `certificate-verifier/src` with local
`lib/*`; compile the extractor separately. Run the regression with the trace
path and the extractor with snapshot root and source-trace path. The existing
runner supplies Git metadata required by TEST_ONLY certificate provenance.
Generate the replay only after both traces exist, compile with Lean 4.33.0,
audit every theorem, and execute all negative/source controls in isolated copies.

## Validation And Failures

Development used installed JDK 17, Python and absolute Lean 4.33.0 paths, local
jars, `/tmp` output directories, and no internet. This candidate does not
change the original five parent statements or strengthen the original ledger.
Local validation is PASS in `/tmp/acgn-wire-validation-v2/report.json`.
The verification-input manifest root is
`0527eae074f36b578a2ef0f6d512cad45f78226b779ad75ec9cd06a693c47f81`.
It freezes the five proof/execution files, their tracked source/dependency
inputs, existing Git HEAD and the local validation driver; this explanatory
notes file is not a local test input. The main closure must freshly include
all six owned files and all other areas in its own manifest.

Both fresh builds passed all 14 Python tests, the 66-row Java regression
(34 additional assertions), four compiler-resolved source pins, 17 general
theorems, 66 replay theorems, 13 false-proposition Lean controls, and 12
javac-attributed source-pin controls. Every source control exited 1 with
the exact `UNMODELED_SOURCE:` pin-mismatch diagnostic and no trace output;
compiler errors and infrastructure failures were not counted as rejection.
Every Lean control exited 1 with the registered false-proposition diagnostic.
There were 71 recorded commands, no final failures, and identical hashes for
all 1,022 compared artifacts, including compiled Java classes, both traces,
proof/replay sources and oleans. The longest command was 7.369 seconds
(second replay compilation), well below the engine's 900-second budget.

The local driver made read-only-object-sharing clones of the existing Git
HEAD into `/tmp` solely for TEST_ONLY provenance. It created no commits,
published nothing, and did not use internet access. Its isolated snapshots
include tracked sources plus this area's execution files, not the other
agents' concurrently developing new files. This is local area validation,
not a substitute for the main harness's complete registered two-build closure.

Development failures were retained and repaired as candidate/test issues:
the initial Java helper lacked a checked-exception declaration; an early
whole-worktree extractor run encountered another agent's unfinished law test;
the first table expectation used a shape code where Java specifies
`UNKNOWN_VARIANT`; the initial Lean recursive encoding would not kernel-reduce;
and the first scratch clean snapshot lacked Git provenance metadata. Initial
Lean proof elaboration failures and a scratch invocation from the wrong root
directory were corrected before successful checks. The generic UTF-8 ordering
model was corrected to explicit UTF-16 conversion, with real named-ID tests.
None of these required production changes or weakened the final acceptance rule.

A separate exploratory 12-class public export exhausted `-Xmx1g` in
`StructuralKey.stableString`, called from
`CertificateBundleWriter$Assembler.build` (line 619 at the frozen source).
This was reported before any production edit; no production edit was made.
The frozen execution census explicitly uses one and three classes, not twelve.
The larger export's memory behavior is unresolved and outside this bounded
census; it must not be represented as a successful stress test or absence of
producer resource issues.
For a separate investigation, the attempted fixture change was solely
`writer(dir, 3)` to `writer(dir, 12)` in an isolated copy, under `-Xmx1g`.
The failed clean-snapshot setup log remains at
`/tmp/acgn-wire-validation-v1/b1-java.log`; the successful v2 report does not
reuse its failed evidence.
