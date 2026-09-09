# Flat and Container Records

This is a bounded integration candidate for next-candidates-v2.16, parents
P3-05 and P3-06. It neither changes production behavior nor discharges or
strengthens the original PARTIAL/DIRECT parent statements. The original ledger,
traceability matrix, law registry, and production authority remain unchanged.

## Integration Contract

Area `records`; plugin `scripts/fifth_flat_container_replays.py`:

- `generate(build, formal)` returns one `(name, source, theorem_count)` tuple:
  `FlatContainerRecordsReplay.lean`, 39 named, axiom-audited replay theorems.
- `negatives(build, formal)` returns seven `(label, filename, source)` tuples.
  Each must fail specifically because kernel `decide` proves its proposition
  false, not because of a missing import, timeout, or elaboration failure.
  Negative modules use anonymous examples without a post-failure axiom audit;
  successful named theorems retain their complete audits. Both the standalone
  live runner and aggregate runner use the same strict rejection classifier.
- `source_mutations()` returns eight exact
  `(label, relative_source, old, new, extractor)` tuples. The extractor is
  `FlatContainerRecordsExtractor`; each old site must occur exactly once.
- General proof: `docs/section3-repair-audit/formal/FlatContainerRecords.lean`.
  Namespace `ACGN.FifthFive.FlatContainerRecords`; replay namespace
  `ACGN.FifthFive.FlatContainerRecordsReplay`. Every named theorem has
  `#print axioms`. No extra proof imports are required.
- Java main: `is.fivefivefive.CanDis.theory.FlatContainerRecordsRegressionTest`.
  Optional single argument is its TSV output path. Compile the whole producer
  and independent verifier source sets with JDK17; `lib/*` is required.
- Trace `flat-container-records.tsv`; source trace
  `flat-container-records-source.tsv`. The extractor takes `ROOT OUTPUT.tsv`.

## Exact Scope

PROVED: the total structural record decoder retains every field of the
9-scalar/3-child flat record and 8-scalar/2-child container record. It checks
recursive source-node shapes and arities, five-field splice shapes, complete
trace headers, exact input/output counts, and canonical decimal fiber fields.
Successful decoding re-encodes to the original complete Wire tree. The converse
holds for shape-valid records. Acceptance against the independently rebuilt
record therefore implies complete equality, and any changed complete record
is rejected. These are general statements over arbitrary finite Wire trees,
not an enumeration of Java fixtures.

The executable reconstruction traverses the source recursively, retains source
association and all leaves, emits the preorder splice ledger including nested
source identity, and rebuilds the full trace. Seq retains exact order/repeats;
Bag sorts without dropping multiplicities and covers every source index; Set
quotients sorted equalities and carries every equal source index in its fiber.
The general inventory contains 20 theorems, including arbitrary-identity Bag
multiplicity and occurrence-coverage proofs.

The general contract is parameterized by exact external identities, source-key
interpretation, trace-key interpretation, and bound enclosing metadata. It is
not a general proof of registry admission, term-table resolution, endpoint-key
construction, source-owner authority, or byte parsing. These are explicit
dependencies, not implicit new axioms. Local standard proof dependencies are
`propext`, `Classical.choice`, and `Quot.sound`; there are no declared axioms,
`sorry`, `unsafe`, native evaluation shortcuts, or substituted proof stubs.

TESTED/CHECKED: 311 predeclared Java rows, in fixed order:

- Six FULL-accepted recursive flat records: Set AND and modular Bag IPLUS,
  each with left-deep, right-deep, and balanced four-leaf association, word
  `[1,0,1,0]` under a checked exact structural-key ranking.
- Four FULL-accepted nonflat Bag IFF records, words `[0,0]`, `[0,1]`, `[1,0]`,
  `[1,1]`. Same-typed identities remain distinct and repeats remain occurrences.
- 286 FULL-rejected public Wire-byte mutations. Fixed representative sites
  cover every scalar position by omission/substitution, scalar duplication and
  reordering, child omission/duplication/reordering, and changed tags. Sites
  include enclosing metadata/endpoints/owner, recursive source applications,
  leaves, splice section and splice fields, trace header, inputs and fibers.
- Fifteen LOCAL_TRACE results: Seq/Bag/Set on `[]`, `[0]`, `[1,0,1,0]`, `[0,1]`,
  `[0,0]`. These observe `ContainerApplicationTrace.of` reconstruction, not
  FULL verifier admission or publication authority.

Every FULL acceptance and failure code is read from the actual public
`IndependentVerifier.verify(bytes, FULL, policy)` result. Reflection only bridges
public verifier APIs, preserving producer-only compilation conventions; no
private verifier state or production object is modified. Mutation bytes are
encoded and decoded using the real public codec; manifest content IDs are
recomputed. The complete outcome/code census is frozen by `STAGE_SHA256`.
The original fixtures are test-only, with an independently empty CALL census.

The Python bridge independently reconstructs source and trace structural-key
preimages from the bound operator/context/schema/alphabet, rather than copying
candidate splice or output fields. Enclosing certificate, profile and endpoint
strings are cross-checked against producer objects in Java; their external
identity resolution and acceptance are also exercised by FULL verification.
The fixed metadata is not re-derived from a mutated candidate.

Long strings use a sorted, duplicate-free exact dictionary in each original
row; later rows retain that dictionary. Integer JSON scalars are dictionary
references, while decimal Wire strings remain strings. Missing/out-of-range
references and noncanonical dictionaries block. The Lean bridge interns long
identities bijectively into a reserved namespace, keeps all grammar/numeric/path
strings literal, and rejects reserved-prefix collisions. It never truncates
identities or treats a digest as an injective structural key. SHA256 collision
resistance, the ASCII Python/Java UTF-16 preimage bridge, javac resolution,
JVM, JSON library, Lean kernel, Python, OS and hardware remain explicit TCB.

## Checks and Evidence

Run the fast standalone tests:

```sh
python -B scripts/test_fifth_flat_container_replays.py
```

Run the finite local two-build check in a new directory:

```sh
python -B scripts/test_fifth_flat_container_replays.py --live-root /tmp/acgn-fifth-records-acceptance-v1
```

The optional runner freezes a canonical manifest, copies two fresh source
snapshots, compiles Java and the source extractor, emits real observations,
checks the 20 general and 39 replay theorems using the existing scanner, checks
seven kernel counterexamples, and executes eight javac-resolved source controls
per build. All source controls must emit `UNMODELED_SOURCE:` and remove a stale
output file; compiler-resolution failures are not accepted substitutes. It
compares both trace hashes, generated replay text, proof inventory and both
compiled Lean artifacts, then rechecks frozen inputs. Commands have 180-second
timeouts. No new commits are created: shared Git objects are read only for
test-only fixture provenance. No experimental output or shared runner is edited.

`area-test-report.json`, `manifest.json`, per-command logs and isolated build
directories under that `/tmp` root are authoritative local test artifacts.
They are not the shared closure report. Main's registered frozen two-build
closure, provenance bindings and dependency decisions are still required for
integrated closure. This candidate must not inherit a prior closure root/status.

Development false starts are preserved under `/tmp/acgn-fifth-records-dev`:

- `Eq.lean`: failed attempt to derive nested inductive equality; replaced by
  total recursive equality and a general exactness proof.
- `java-first.log`: misuse of operator-node insertion for a smart-collapsed
  singleton fixture. No production defect was identified or changed.
- `replay-first.log`, `replay-second.log`: wrong working directory and unpinned
  `/tmp` default Lean 4.33.1 versus the repository's 4.33.0. Final runner pins
  `ELAN_TOOLCHAIN` explicitly and runs from each clean formal directory.
- `Natural.lean`, `replay-pinned.log`, `probe.log`: kernel reduction did not
  complete with the library String natural parser. Replaced with a total
  character-fold decoder; no timeout was relabeled as a proof counterexample.
- `java-second.log` records the pre-dictionary producer run. Its raw repeated
  strings exceeded the shared CSV reader's field limit. The exact dictionary
  transport addresses that integration limitation without changing the reader.
- `java-packed.log` and `replay-total-decoder.log` record the repaired development
  producer and replay. They are development evidence, not frozen final evidence.

## Proposed Gaps

FULL SINGLETON export is not observed by this fixture producer; the complete
decoder retains the target-kind field, and local Set traces cover singleton
quotients. Add an authenticated singleton insertion/export workflow separately
before promoting that Java path. Seq and nonflat Set construction authority
are not invented: the fixed law matrix does not provide the corresponding
nonflat law-bearing FULL path. General structural reconstruction and LOCAL_TRACE
observations do not grant that authority.

Universal byte-parser/JVM refinement, independently authenticated raw Alloy
source occurrence authority, every arbitrary context/type/operator, the complete
contract registry, and future revisions remain outside this finite slice.
Law-record authority, canonical table grammar/content-ID preimages and retained
source occurrence commitments belong to the separately owned fifth-five areas.
