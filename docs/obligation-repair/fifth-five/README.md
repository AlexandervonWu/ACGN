# Complete Certificate Records And Source Bindings

This package implements the bounded v2.17 follow-up to
[the v2.16 candidates](../next-candidates-v2.16.md). The original five parent
requirements and their hashes are preserved. General Lean contracts,
compiler-resolved source bindings, observed Java executions and independent
rejection controls remain separate evidence.

## Registered Work

| Requirement | General proof | Implementation boundary |
| --- | --- | --- |
| P3-04 | `LawRecordWire.lean` | Complete law-record writer and independent registry-based verification |
| P3-05 | `FlatContainerRecords.lean` | Complete flat source, splice ledger and application-trace reconstruction |
| P3-06 | `FlatContainerRecords.lean` | Ordered inputs, normalized outputs and exact container fibers |
| P3-12 | `CanonicalWireTables.lean` | Canonical wire-table grammar, ordering and content-ID preimages |
| A2-12 | `SourceOccurrenceBindings.lean` | Deterministic retained-source phase/child paths and dependent content bindings |

Proof files are in `docs/section3-repair-audit/formal/`. Each area note
records its exact finite observation census, correspondence, supported
negative controls and interpretation boundary. The fixed
[configuration](closure-config.json) and [harness boundary](harness-notes.md)
control verification; this narrative cannot turn an incomplete run into
VERIFIED.

## Reproduction

Install the pinned `lean-toolchain` before verification, then run from the
repository or an extracted assurance archive:

```bash
elan toolchain install "$(cat lean-toolchain)"
python3 -B scripts/run_fifth_obligation_repairs.py /tmp/acgn-fifth-five
```

The output must be new and outside the source directory. The runner freezes
inputs, builds twice, checks Lean contracts and observed replays, executes
negative controls and compares deterministic artifacts and provenance.
Its `report.json` is authoritative. A syntax failure, missing dependency,
timeout or unrelated exception cannot count as a semantic rejection.

## Status

The [local prepackaging report](evidence/prepackaging/report.json) is
**VERIFIED** for all five frozen claims, with two passing builds and 1,106
matching artifacts. Its closure ID is `fifth-five-v1-6b954bee861f2fa1`, input
root `6b954bee861f2fa1844b7bd402fca2b76fcc64d346fc95d7295853c74dde3322`.
The final packaging corrects a matrix note from FULL to KERNEL for the
law-record observation level and removes trailing blank lines from two
extractors. The proof, execution and claim scopes are
unchanged, but that metadata edit changes the input root. Exact-commit CI
and extracted-archive verification regenerate evidence for the packaging
inputs; the release notes identify that final root without transferring
this report's status across the edit.

| Check per clean build | Count |
| --- | ---: |
| General Lean theorems | 85 |
| Generated Lean replay propositions | 538 |
| Predeclared Java observation rows | 700 |
| Lean false-proposition controls | 96 |
| Compiler-resolved source controls | 54 |

The new Python orchestration/encoder suites contain 75 tests. All 50 shared
bounded Java entry points, artifact-regeneration smoke tests and the separate
producer/verifier harness passed. The matrix has 112 ready requirements and
105 open diagnostics; `PROVED/DIRECT` denotes general model contracts with
bounded direct conformance, not complete Java/parser refinement.

Independent [harness](evidence/reviews/harness.md),
[law/wire](evidence/reviews/law-wire.md) and
[records/source](evidence/reviews/records-source.md) reviews passed their
bounded checks. The [review addendum](evidence/reviews/records-source-addendum.md)
supplies the strict diagnostic check missing from the original records
review. The blocked first aggregate run, fixes and superseded evidence are
retained in the [incident ledger](incidents.md). Anonymous negative examples
do not replace the complete audits of accepted named theorems.

## Experimental Impact

The [compiled-class comparison](evidence/experimental-class-comparison.json)
matches all 898 existing v2.16 experimental JAR classes byte-for-byte.
Only new regressions, proofs and validation orchestration were added; no
production or experimental-runner behavior changed. Consequently, no corpus
rerun is needed or claimed. The 5,808 imported empirical files, their original
JAR and manifests, and the separate v2.16 validation run remain unchanged.
No rewrite law, theory authority, or universal Java refinement claim is
introduced by this verification package. SHA-256 collision resistance
remains an explicit assumption.

The evidence archives retain logs, generated proof/replay artifacts, input
manifests and comparison results. Repeated build-source trees and compiled
Java classes are omitted from these compact archives; their hashes remain
in the manifests. Superseded input deltas are retained where needed, while
the final tagged source supplies unchanged inputs. The failed-run archive
is diagnostic evidence, not a successful closure.
