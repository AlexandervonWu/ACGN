# Artifact Closure Audit (2026-08-19)

## Scope And Baseline

The requested baseline was commit `44debafda1aa9a86a301780cd1bc2ca873ec3531` on
`aislop`. Work continued from its direct child `6a33d3fb`, which contains only
the certificate-runner script that the repository owner confirmed should have
been tracked. Existing experimental result directories were treated as
historical evidence and were not regenerated or overwritten.

## Defect-To-Fix Map

| Located fault or contradiction | Resolution | Regression gate |
| --- | --- | --- |
| The documented producer runner did not provide a clean, independent, two-JVM build and comparison. | Rebuilt the runner around fresh producer/verifier/test class directories, exact output-set checks, byte and SHA-256 comparisons, verifier execution, PAIR checks, and source export smoke. | `scripts/run_certificate_bundle_writer_tests.sh` |
| Certificate fixtures could claim hard-coded commit and dirty-state provenance. | Provenance is captured from Git and binds source, producer/verifier JARs, dependencies, input, configuration, and versions. Dirty publication export fails closed; fixtures require the visible `TEST_ONLY` override. | `CertificateProvenanceTest`, `ProducerBundleInspectionTest`, `VerifierTest` |
| Per-input schemas and operators changed the theory digest, making PAIR compatibility accidental. | The reviewed theory identity and its admitted axioms remain under the external theory pin; content-addressed typed vocabulary is separately integrity-hashed and declarations used by a common PAIR representative must agree exactly. | Distinct producer-backed equivalent, non-equivalent, incompatible-theory, and separate-JVM PAIR cases |
| Export smoke repeatedly exercised an empty adapter input. | Smoke now parses representative Alloy source and reports a status/reason census for nullary, slot-bearing, and deliberately unsupported predicates. The producer fixture separately verifies a supported parent path. | `CertificateVerifierExportSmoke` |
| Browser cancellation did not carry whether cancellation or timeout won. | The client sends `{requestId,cause}` with the closed `cancelled | timeout` enum; server and runner preserve the first cause, including pre-registration requests. | `apiClient.test.ts`, `VisualizationProcessRunnerTest` |
| Runner registration and shutdown could race, and repeated terminal paths could repeat process termination. | Closure and registration share one lock; close snapshots under that lock and cancels afterward; each job has a one-shot kill latch. | Barrier-controlled execute-versus-close regression |
| Explicit graph edges were accepted without owner/child validation and could be omitted from reachability. | Schema validation checks e-node ownership and child targets; ownerless structural edges participate directly in reachability. | `schema.test.ts`, `visibleGraph.test.ts` |
| SVG bounds and routing did not cover loops, back edges, reciprocal edges, or parallel edges. | Export uses external cubic routes where required, parallel offsets, and bounds derived from nodes, controls, and labels. | `graphCanvas.test.tsx` |
| Experiment scripts could silently compile different classes in different stages. | A clean publication entry point compiles one frozen JAR, passes it through `ACGN_EXPERIMENT_JAR`, verifies identities after stages, binds semantic and report inputs, and finalizes an exact output manifest. | `run_publication_manifest_tests.sh` |
| Frontend runtime tests passed while the production TypeScript build rejected assignment to an optional fixture field. | The explicit-edge test fixture now declares its optional edge shape without changing the payload. | `npm test -- --run`, `npm run build` |

## Certificate Coverage Census

The bounded real-source smoke reached three representative predicates:

| Predicate | Outcome | Reason |
| --- | ---: | --- |
| `nullary` | `VERIFIED` | The full profile independently verified. |
| `slotBearing` | `UNCHECKABLE` | SEQ, BAG, and SET law registries are not exportable by the current bridge. |
| `deliberatelyUnsupported` | `UNCHECKABLE` | SEQ, BAG, and SET law registries are not exportable by the current bridge. |

Totals: `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`. `UNCHECKABLE` is an
explicit proof-producing-fragment boundary, not malformed evidence. The
separate producer-backed parent-path fixture verifies under the full profile.

## Bounded Verification

The following commands passed from clean temporary build directories or
bounded local build directories:

```bash
./scripts/run_bounded_ci_java_tests.sh
./scripts/run_certificate_bundle_writer_tests.sh /tmp/acgn-certificate-closure-final
./scripts/run_certificate_verifier_tests.sh
./scripts/run_publication_manifest_tests.sh
(cd frontend && npm test -- --run)
(cd frontend && npm run build)
```

The publication-manifest test intentionally mutates a bound report and passes
only when the verifier detects the resulting hash drift.

## Remaining Boundary

The current producer bridge does not serialize certificates for flexible
SEQ/BAG/SET container-law registries. Extending that slice requires explicit
serializer records and independent replay support. Treating producer claims as
proof, dropping the laws, or weakening the external theory pin would violate
the trust boundary, so these inputs remain `UNCHECKABLE`.

## Later Publication Run

After committing this work and checking out a clean frozen commit, run the
full experiment only into a new directory outside the repository:

```bash
./scripts/run_publication_experiments.sh \
  --run-root /absolute/path/to/acgn-publication-run \
  --dataset "$PWD/classified-data" \
  --threads 32 \
  --max-heap 4g
```

The chain is: clean Git/source/dependency/dataset identity, one compiled JAR,
canonical batch, augmentation, ablation plus semantic checker, capability
study, report bindings, exact artifact inventory, and final manifest
verification. Use `--limit 100` first for a bounded archival preflight. The
full corpus run was intentionally not launched during this closure patch.
