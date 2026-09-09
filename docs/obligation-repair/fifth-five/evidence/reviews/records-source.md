# v2.17 Records and Source Binding Review

Verdict: **PASS**. No unresolved semantic counterexample found within the
requested bounded scope.

## Boundary

Independent, bounded, read-only review of FV-P3-05, FV-P3-06 and FV-A2-12
under `docs/obligation-repair/fifth-five/closure-config.json`. Repository base
HEAD is `c9475b6e5d5ef2508dc312b667d7bf33783cee9e`; the candidates are uncommitted,
so the file hashes below, not HEAD alone, identify the reviewed implementation.
No repository files were edited by this reviewer. All compilation, mutations,
probes, logs and snapshots are under `/tmp`. No internet research or experiments
were run.

This review evaluates the declared finite producer/public-verifier observations
and their general structural Lean contracts. It is not the aggregate registered
two-build closure verdict and does not automatically discharge an original
parent claim, establish universal Java/parser refinement, or authorize a new
semantic equality. The main runner owns that final closure decision.

## Findings

No lost source/splice/trace field, incorrect Seq/Bag/Set fiber, or phase/content
transfer provenance counterexample was found on the supported paths reviewed.

- The flat record retains all nine scalars and three children. Reconstruction
  retains the recursive source association and leaf order; each splice contains
  path, outer arity, nested arity, position and nested-source identity. The
  public verifier derives these values independently before certificate-key
  acceptance. The typed operator/context and exact arity guards remain present.
- The container record retains all eight scalars and both children. Seq order
  and repetitions, Bag multiplicity and stable occurrence fibers, and Set
  equality fibers remain distinct. No local trace is represented as a FULL
  certificate acceptance. The public corpus here contains six flat Set/Bag
  constructions, four nonflat Bag constructions, and 286 malformed wire-byte
  rejections; the 15 Seq/Bag/Set trace observations are explicitly LOCAL_TRACE.
- The retained-source model separates the certified and repaired commitments.
  The actual adapter retains source lineage, typed source, original occurrence
  path and certified content while checking the admitted transfer preimage.
  Independent valid-Alloy probes preserved phase ownership through temporal
  branches, outer quantified variables, IFF/implication, ACI operand collapse,
  nested JOIN association, and JOIN/ARROW operator barriers.
- Expected observation censuses are independent fixed fixture specifications:
  311 record rows and 171 source rows. Candidate rows cannot add, delete, reorder
  or relabel that census. Record source/trace preimages are reconstructed from
  explicit bound metadata and the fixed source/word requests. External
  metadata resolution is an explicit parameter and is also exercised by the
  actual public verifier, not claimed as a universal Lean parser theorem.
- The source notes correctly limit structural injectivity to `Content` and
  `Commitment` constructors. They explicitly do not infer injectivity of
  `encodeContent`, `encodeCommitment`, arbitrary sort-key strings, or SHA-256.
  UTF-16 framing and complete decoding/re-encoding are checked on the finite
  Unicode/delimiter examples. No unclaimed string-injectivity theorem was
  demanded by this review.

## Execution Evidence

Final independent run root:
`/tmp/acgn-v217-records-source-checks-final`.
Its `inputs.json`, `commands.json`, logs and generated modules identify the
actual execution. `result.json` is written only after the complete area checks
finish. The driver is `/tmp/acgn-v217-records-source-review-run.py`.

| Check | Result |
| --- | --- |
| Clean Java producer/verifier compilation | PASS, JDK 17.0.20 |
| Flat/container Java regression | PASS, 311 rows, 11,666 assertions |
| Source binding Java regression | PASS, 171 rows, 22 explicit assertions plus required rejection transitions |
| Python encoder suites | PASS, 8 records tests and 17 source tests |
| Compiler-resolved source extraction | PASS, 13 records objects and 5 source objects |
| General Lean proofs | PASS, 20 records and 21 source named theorems |
| Generated Lean replays | PASS, 39 records and 187 source named theorems |
| Lean negative controls | PASS, 7 records and 16 source controls, exit 1 with the required false-proposition diagnostic |
| Compiler-resolved source controls | PASS, 8 records and 16 source controls, exit 1 with resolved source mismatch and stale output removed |

Lean was explicitly pinned to 4.33.0, commit
`d8b18978322de05a8f3dba51ef03cf5461676c17`. Axiom inventory uses the registered
fifth-profile adapter and its allowed standard axioms. No `sorry`, new `axiom`,
`unsafe`, or native proof shortcut is accepted. Source controls run only in
the copied snapshot, restore each source afterward, and must reject through
resolved `UNMODELED_SOURCE` diagnostics, not unrelated compiler errors.

Additional reviewer-authored probe:
`/tmp/acgn-v217-records-source-checks/IndependentBoundaryProbe.java`.
It passed 13,531 assertions: all 364 words of lengths 0 through 5 over a
three-identity alphabet, each under Seq, Bag and Set (1,092 actual traces),
plus 14 parsed Alloy predicates and 21 dependent source bindings. Its independent
expected fibers are constructed by scanning each source index by identity.
It does not invoke private APIs, change production state by reflection, or
substitute synthetic observations for the registered Java traces.

Source examples include:

```alloy
all x: A | once some (x.r) implies always some (x.r)
all x: A | some (x.r) iff after some (x.r)
some ((r+r).(r+r))
some ((r.r)->A)
some ((A->A).r)
```

Probe output: `/tmp/acgn-v217-records-source-checks/independent-boundary.log`.
The original Java/proof inputs used by this additional probe are retained in
that run's `snapshot` and `inputs.json`; the relevant production Java did not
change between these checks and the finalized candidate.

## Superseded Review Attempts

The initial review snapshot contained the ordinary Lean definition name
`admit`; the reserved-word scanner correctly blocked it. The author renamed it
`admitOccurrences` before the final run. The original snapshot and
`source-proof-inventory-failure.log` remain under
`/tmp/acgn-v217-records-source-checks` and are not passing evidence.

A subsequent review driver incorrectly called the raw pinned v2.13 inventory
helper on the new `mutual` block. That helper does not count mutual scopes.
The registered fifth-profile adapter does; the reviewer switched to
`load_runner().proof_inventory` instead of weakening the check or changing
the model. This review-driver mismatch is not a remaining candidate defect.
A minimized compiling witness and both outcomes are retained under
`/tmp/acgn-v217-records-source-checks-stable`:
`MutualInventoryWitness.lean`, `mutual-witness-lean.log`,
`mutual-witness-scanner.log`, and `fifth-adapter-mutual-pass.log`.

The final independent run completed with exit 0 and `boundedTests: PASS`.
Its final freshness comparison found no changes to any reviewed target file,
production Java source, extractor, proof or replay. The main agent changed
`scripts/run_bounded_ci_java_tests.sh` and the shared `incidents.md` during
the check. Those files were not executed as part of this review; the main
aggregate closure must snapshot their final versions. This report does not
transfer an aggregate closure status across those changes.

## Hashes

SHA-256 of the reviewed target files:

| File | SHA-256 |
| --- | --- |
| `formal/FlatContainerRecords.lean` | `073e25f7ce9f5e9d4f19e1c927a45c13e959d7dfde450d01350eb64dd18e0f2a` |
| `formal/SourceOccurrenceBindings.lean` | `a71582e72bdd503b8c7a39ae4f439327ce747cbdf6d3511482e0f64f90982a54` |
| `theory/FlatContainerRecordsRegressionTest.java` | `af64a1dd7d813a2a3dea29df316e147e79b655b57aa7a921f0fdd552e801f4e3` |
| `theory/SourceOccurrenceBindingsRegressionTest.java` | `00b8196673ae72c3d558777d567d7b67c8433dcee853b3465776ec128a354f43` |
| `scripts/java/FlatContainerRecordsExtractor.java` | `62b6f01b49924f2dfeaebd67b6908d176ef577ac68aca820950a693f5c1be6b5` |
| `scripts/java/SourceOccurrenceBindingsExtractor.java` | `7bfeefbe51fa914beb64dc9cf08d914e1f20fc1c6acf75e72b497af8d82339b4` |
| `scripts/fifth_flat_container_replays.py` | `14b0b9208376f6daa56fce088816f5a972a9da1f00171adadb578bbeec801fac` |
| `scripts/fifth_source_bindings_replays.py` | `b721116ef80b88b86d23c4f86214b52dbaae13a26e4ddc1ba755fc7b6867efd9` |
| `scripts/test_fifth_flat_container_replays.py` | `3b73132e3bac1b52755b1cee63ecad342cb6514e56e60eb5074bb9f6bcceca52` |
| `scripts/test_fifth_source_bindings_replays.py` | `ef6115af4da1d5e72ee13110e9ab2ca492b756c50de31d449d75d7ca0288d2a1` |
| `fifth-five/flat-container-notes.md` | `7983a38515e5ed3cf8ba98f3b5ce238bde2fa1a7391b98ff0f76eea31ae5aafb` |
| `fifth-five/source-bindings-notes.md` | `5641821d8000ce230e60796f6e697f0996076c7de9956103619c52fcbc1cff71` |

`formal/` above means `docs/section3-repair-audit/formal/`; `theory/` means
`src/is/fivefivefive/CanDis/theory/`; `fifth-five/` means
`docs/obligation-repair/fifth-five/`.

Trace and independent probe hashes:

| Artifact | SHA-256 |
| --- | --- |
| `flat-container-records.tsv` | `7b7058396e3bc1c43e2c4ae1be4c35fca042083618e406a5864c60aae3ff3647` |
| `flat-container-records-source.tsv` | `3c559447b76a63294ce8fbe8f71d615a30e4f6783349e9c062dded73f6a9e058` |
| `source-occurrence-bindings.tsv` | `823699184401598b732d5aa5e2f5bc4af3a08f92e74fc14165a4f353b64b132b` |
| `source-occurrence-bindings-source.tsv` | `b0be7007f94588538afca588af4c7d7f134686e8beeec66a46561c89d8102c13` |
| `IndependentBoundaryProbe.java` | `df10f32b5d9a0ea99eeba400d46b3be2c7eed501138b7a0a8f1359ad468a1223` |
| `independent-boundary.log` | `677c145a3bc2dfdabcfbda81a13c71965033ffc15662c6bd96012d5e5d2d17ad` |

## Trust and Exclusions

Lean's kernel and the explicitly permitted foundational axioms, javac/JVM 17,
local Alloy/parser dependencies, the Python interpretation and strict parsers,
SHA-256 integrity assumptions, OS/filesystem and hardware remain trusted.
Source pins plus finite observed executions do not constitute a universal
Java-to-Lean refinement proof. P1-19 raw-source authority, new laws, arbitrary
leaf-key injectivity, full Unicode/JVM semantics, full-corpus measurements and
release approval are outside this review. Existing fail-closed authority and
phase separation were not broadened. No new rewrite discovery is requested.
