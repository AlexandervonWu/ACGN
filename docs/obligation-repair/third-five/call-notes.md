# Third-five CALL authority and transitions

This is a bounded assurance candidate and implementation handoff, not a closure
report, a release, or an amendment to the parent claims. The mechanical-closure
skill and its normative closure protocol were read before implementation.
Main owns the registry, manifest, runner integration, public provenance, and any
subsequent closure decision. Local development checks cannot assign VERIFIED
to the original broad parents or inherit another package's closure status.

## Original claims

The original `claim-ledger.md` statements and their starting statuses were:

| Parent | Exact original claim | Original status |
| --- | --- | --- |
| P1-06 | Observed children cannot replace independently declared arity. | PARTIAL/DIRECT |
| P1-09 | A consumed call occurrence cannot be reused. | PARTIAL/DIRECT |
| P1-16 | CALL remains ordered, nonflat, noncommutative, and non-idempotent. | PARTIAL/DIRECT |

The original `requirements-traceability.tsv` claim hashes are respectively
`30fb21fcb2a524cc57aa6a240c4380ce349da552b012527be9e41ff988e810f9`,
`88fab51f179dd66df7b0703a9e3d93dac32ffde6432e699709e6ce3ab9bb02d3`, and
`2ff9bdd7b3b7112086c0a821d74da9c49a16620a39e6ab62f8b348e4a8d6e052`.
All three original matrix rows started as PARTIAL, DIRECT. Their stated gaps were
declaration/ledger provenance outside the model, establishment of uniqueness
not mechanized, and full policy-to-observation refinement open. This candidate
adds general authority/transition/representation proofs and compiler/executable
bounded conformance, not a universal Java or parser refinement theorem.

P1-19 coordinated source-row-plus-anchor omission remains OUT_OF_SCOPE. These
fixtures check their own independently counted parser/capture/IR/certificate
occurrences; they do not provide independent occurrence authority for arbitrary
certificates. No claim closes coordinated omission or complete source coverage.

## Owned paths and APIs

Only these new repository files belong to this work:

```text
docs/section3-repair-audit/formal/CallAuthorityTransitions.lean
src/is/fivefivefive/CanDis/CallAuthorityTransitionsRegressionTest.java
scripts/java/CallAuthorityTransitionsExtractor.java
scripts/third_call_replays.py
scripts/test_third_call_replays.py
docs/obligation-repair/third-five/call-notes.md
```

```text
java -ea -Xmx1g -cp CLASSES:ROOT/lib/* \
  is.fivefivefive.CanDis.CallAuthorityTransitionsRegressionTest [OUTPUT.tsv]
java -Xmx1g -cp EXTRACTOR_CLASSES \
  CallAuthorityTransitionsExtractor snapshotRoot outputTSV
```

Compile the extractor together with the unchanged
`scripts/java/JoinGuardExtractor.java`. The extractor analyzes all snapshot
`src/**/*.java` against sorted snapshot `lib/*.jar`, with JDK 17, `--release 17`,
`-encoding UTF-8`, `-proc:none`, and `-implicit:none`. Tests require a full-source
javac invocation; implicit source discovery alone misses a package-private
sealed-class implementation in an existing differently named source file.

The standalone area plugin exposes exactly the runner's delegation API:

```python
generate(build, formal) -> [("CallAuthorityReplay.lean", source, 91)]
negatives(build, formal) -> [(label, "RejectCallAuthority.lean", source), ...]
source_mutations() -> [(label, sourceRelative, old, new,
                       "CallAuthorityTransitionsExtractor"), ...]
```

`build` and `formal` are path-like; `formal` is presently unused. Inputs default
to `build/call-authority.tsv` and `build/call-authority-source.tsv`. No files are
written by the plugin. Positives and each complete isolated negative module use
`namespace ACGN.ThirdFive.CallReplay`, closed explicitly. There is one generated
theorem and one axiom audit per observed occurrence, exactly 91 of each.
The base proof namespace is `ACGN.ThirdFive.CallAuthorityTransitions`.

## General proof boundary

The base proof imports only `Std` and contains 23 generally quantified theorems,
each with exactly one `#print axioms`. It compiles offline with installed
`leanprover/lean4:v4.33.0`. No admitted proof, new axiom declaration, unsafe
definition, or native-decision shortcut is used. The printed dependency union
is `propext`, `Quot.sound`; these standard axioms and the kernel remain trusted.

P1-06: `declaredArity` consumes declaration parameter-group sizes, while
`resolve` filters an independent signature table and accepts exactly one match.
Acceptance proves table membership and matching callee, kind, and arity;
missing authority cannot be manufactured by an observed argument count.
Overloads are modeled as independent entries. The source table and independently
observed target metadata are not constructed from the parser's argument list.
An explicit authority enum is never inferred from a name's spelling.

P1-09: `advance` implements a per-owner counter update; `allocations` executes
an arbitrary finite owner schedule. Strict increase above the starting counter
and monotonicity under other-owner updates prove allocation-pair nonreuse, with
no input uniqueness assumption. `consume` increments before checking the exact
visit and maximum, including on rejection. A fresh max-visit-1 CALL accepts its
valid first visit and rejects after consumption. The keys are owner/visit pairs
within one traversal, not a global claim about Java long occurrence-ID issuance.

P1-16: `Source`/`SourceArgs` and `Representation`/`Ports` are separate recursive
datatypes. Lowering preserves every ordered port, call head, nesting boundary,
repeat, and arbitrary barrier tag. `restore_lower` proves a left inverse;
representation equality therefore reflects full source-tree equality. Further
theorems give position preservation, repeated lists, distinct-swap separation,
non-deduplication, nested-call shape, impossibility of same-call collapse, and
barrier separation. This is not the old four-boolean policy assertion.

`JavaAritySafe n` is `n + 3 <= 2147483647`, covering arity+2 edges and the
producer's arity+3 array length. `JavaStepSafe before` is
`before + 1 <= 2147483647`, required separately at every executed transition.
These are validity bounds, not production overflow guards. Negative machine
values, wraparound, allocation feasibility, memory exhaustion, concurrent heap
mutation, and long-counter exhaustion are excluded from the natural model.

## Observation schema and census

`CALL_FIELDS`, `CALL_SOURCE_FIELDS`, `CALL_ARITIES`, `CALL_CENSUS`,
`CALL_OCCURRENCES`, `CALL_SOURCE_COUNT`, and `CALL_SOURCE_OBJECTS` are exported
by `third_call_replays.py`. Java also exposes `FIELDS`, `ARITIES`, and
`OCCURRENCES`. The actual separator below is TAB, not space:

```text
schema fixture occurrence owner visit signature_table declaration_groups declared_signature parser_tree masg_tree ir_tree cert_tree before first_visit first_after first_accept second_visit second_after second_accept max_visit ir_arity ir_policy cert_path observation_sha256
```

`schema=call-authority-v1`. Census: seven `arity-N` fixtures for
N in `{0,1,2,3,5,8,16}`, eight occurrences each; `nested` has 30;
`imported` has five. Total: 91. Occurrence IDs are exactly 0..count-1 per fixture;
owner tokens are actual integral MASG semantic IDs and are distinct per fixture.
All are parser-return captures after actual `super.visit`, not fabricated nodes.

Signature JSON arrays are `[qualifiedCallee, kind, declaredArity, authority]`.
Kinds are `call/formula` or `call/expression`; authorities are the explicit
`DECLARATION` or `TYPECHECKED_IMPORT` values. The independent `signature_table`
is read before visiting calls: parser declarations count grouped parameter names;
import declarations select entries read directly from the fixed library ledger,
not from `require(... observedArity)` results. Parser-synthesized `$$Default`
declarations and the automatic util/integer open are included when present.
`declaration_groups` records selected local parameter-group sizes and is `[]`
for imports. Library overload controls exercise both pinned integer/max entries.

The four recursive JSON tree columns have the same external syntax but are
independently observed and encoded into different Lean types:

```text
["atom", nonnegativeInteger]
["call", signatureArray, [childTree, ...]]
["barrier", "CARDINALITY", [childTree]]
```

Parser NOOP wrappers are explicitly erased; cardinality is retained. MASG trees
read actual target symbols and exact ordered visit edges, validating the actual
callee target and END. IR trees traverse `getCertificationMatrixEGraph()`,
never substitute the optimized matrix. Certified trees recursively decode the
actual source endpoint's ordered OnePorts and unique stored e-class shape
witnesses, including repeated invocations. The certified CALL operator's
metadata is decoded from that operator, not copied from the parser or IR.
The finite fixture grammar excludes other payload operators; the general model
allows arbitrary barrier tokens. Token maps include BOTH sources and targets,
so an unseen wrong target never inherits its source's equality token.

`before`, `first_visit`, `first_after`, `first_accept`, `second_visit`,
`second_after`, `second_accept`, `max_visit` come from actual private
`nextTov`/`downlinksFor` calls. The test interleaves another owner's increment,
checks the last valid signed-int increment, and rejects second/past-max uses at
the CALL reuse boundary. The scalar replay records the two same-owner steps;
interleaving and the final signed-int increment remain Java tests. It does not
encode a fictitious uniqueness premise or copy model-computed counters into
the observed columns.

`ir_arity` and `ir_policy` are observed fields; policy is ORDERED_SEQUENCE.
`cert_path` is scoped to its fixture and graph. `observation_sha256` hashes
actual canonical stable-form UTF-8 bytes; actual observation equality/inequality
tests distinguish swaps, repeats, nesting and barriers, and accept identical
tree repetitions. Lean replays the decoded certified representation, not the
hash's preimage or the independent certificate verifier's wire protocol.

## Source binding and negative controls

The extractor emits 43 records with this schema:

```text
object owner method arity shapeSha256 bindingsSha256 model
```

`CALL_SOURCE_OBJECTS` freezes every complete record, including both digests.
`arity=-1` denotes the ledger field initializer; other arities count parameters.
The source census covers declaration indexing/lookup/group counts/import lookup,
the complete fixed ledger construction and lookup, signature/CallSymbol storage,
visitor reset/capture/CALL/visit update, IR counter/dispatch/validation/build/
metadata, CALL policy, IR append and sort-key representation, adapter operand/
node/head construction, and exact certified ordered-argument binding.

Like the v2.13 ChainSequenceExtractor, each registered whole-object AST shape
and resolved-symbol inventory is hashed separately. Literal strings are bound,
including semantic tags and diagnostics. Javac resolves owners, overloads,
constructors, enums, locals, referenced fields, signatures and modifiers.
Unknown structure, resolution, missing or ambiguous objects fail closed, and a
failed extractor removes any previous output. Method spelling alone conveys
no source authority. This is finite structural conformance, not a verified
Java-to-Lean compiler or a transitive proof of every called helper's semantics.

The 13 complete Lean negatives independently corrupt MASG/IR/certified heads,
explicit authority, the authority table, counter updates/outcomes, the integer
bound, argument order, multiplicity, nested calls, or barriers. Each must fail
with exit 1 because `decide` proves the target proposition false, not because of
an import, parse, scope, or unknown-name error.

The ten source controls change grouped-name arity, imported arity assignment,
ledger synthesis, instance-to-static arity storage, counter increment, reuse
guard, argument order, repeat traversal, nesting, or CALL commutativity. They
are unique literal replacements applied only in isolated snapshots. Each must
compile successfully and then be rejected with `UNMODELED_SOURCE`; a javac
error is not a successful structural control.

Java invalid controls require exact exception classes and relevant diagnostics:
declaration/import arity, metadata child-count mismatch, certified argument
endpoint mismatch, or consumed-CALL reuse. Sealed IR metadata is deliberately
corrupted by reflection and restored before graph/certificate operations, so
the test reaches CallMetadata rather than mistaking arena immutability for the
intended rejection. All graph mutations are restored in `finally`.

## Trust, evidence, and source control

PROVED: the general Lean models and their stated contracts.
CHECKED: the finite javac-resolved source grammar and strict TSV/token encoding.
TESTED: 91 real parser/MASG/certification-source IR/certified occurrences;
441 boundary-specific Java rejections; 17 synthetic encoder unit tests;
13 false-proposition replays. The ten isolated source mutations are registered
for final local validation; their execution results belong to the generated
evidence below, not this pre-run note.
TRUSTED: installed Lean kernel and standard axioms; JDK17 javac/JVM and Java
collection/array/reflection semantics; local Alloy/parser/JSON jars; the observers,
encoder, source extractor and heap-to-token interpretation; certification and
canonical-observation code outside the checked methods; SHA-256, Python,
filesystem, OS, hardware. All dependencies must be manifested or explicitly
trusted by the integrating closure. No internet or additional agents were used.

Initial development evidence is in `/tmp/acgn-call-authority-dev-cGCInT`:
the model (23 theorems), real Java regression (91 occurrences / 441 rejections /
4487 assertions), source extractor (43 objects), positive replay (91 theorems),
and 17 encoder tests passed. Thirteen negative Lean modules failed with the
expected false-proposition diagnostic. Temporary compiler failures during test
development are not production defects or evidence of a passing negative.

The final isolated verification location is
`/tmp/acgn-call-authority-final-4rvmh1`. Its generated `local-evidence.json`,
manifest, command logs, and build A/B artifact hashes, when present, are the
authority for final local checks; this static note does not preassign their
outcomes. It is not a registered closure report. Full source javac, model/replay
Lean builds, source extraction, and bytewise reproducibility must run from two
fresh copied inputs. Compare TSV/proof/class artifacts, not noisy production
debug stdout. Main must repeat the registered package procedure under its own
frozen root and verifier hashes before making any closure claim.

Source-control base read at start: branch `aislop`, HEAD
`892e001ee9f81fc5cf9ac2f4984c4b8be474e18c`, initially clean tracked worktree.
All six owned files are new; no commit or release was made. Other workers'
registry, harness, documentation and CI edits are unrelated and remain theirs.
Production, existing scripts/helpers, ledger/matrix and experiment directories
were not edited by this work. A later input mutation invalidates the associated
local hashes and requires a new frozen integration run.
