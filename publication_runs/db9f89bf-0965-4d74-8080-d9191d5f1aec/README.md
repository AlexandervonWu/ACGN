# v2.15 Publication Snapshot

Run `db9f89bf-0965-4d74-8080-d9191d5f1aec` completed on September 8, 2026.
It reruns all four stages after three certificate producer/replay defects were
repaired. The source commit is `8ad5fead39b687d2cadc79b01ac27743c1ece990`,
with a clean worktree throughout the run. The later release packaging commit
is recorded by the annotated `v2.15` tag and GitHub release.

| Setting | Value |
| --- | --- |
| Source Alloy files | 66,080 |
| AST-identical skips before evaluation and pools | 4,482 |
| Eligible pairs | 61,598 |
| Incorrect predicates ranked and rewarded | 42,386 |
| Workers / JVM heap / reward pool | 16 / 8 GiB / 100 |
| Seed / capability target per family | 55520260811 / 500 |
| JVM | OpenJDK 17.0.20 |
| Dataset SHA-256 | `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689` |

CanonicalBatchTest, Alloy4FunAugmenter, seven-arm ablation with semantic
checking, and capabilities ran strictly serially with one unchanged JAR.
Every stage gate passed. There were no terminal distance, parsing, ranking,
reward or ablation failures. Both canonical paths had zero incorrect
nearest-truth zeroes. All seven arms covered all 61,598 eligible pairs.
The bounded Alloy checker found no counterexample or error in 4,088
claimed-equal pairs; all four targeted negative probes remained unmerged.
Slotted, Fast Rewrite and Certificate-Integrated IR each captured all 5,500
capability pairs. Six temporal solver checks remain explicitly inconclusive,
including the retained static-reduction solver report; this is finite
experimental evidence, not an unbounded semantic proof.

The current result trees mirror exactly 5,808 manifest-bound stage artifacts:
`distance_results/`, `alloy4fun-augmented/`, `egraph_ablation/` and
`capability_benchmark/`. The manifest additionally binds stage gates and
supervision receipts. Original absolute paths identify the producing host;
portable identity comes from relative paths, byte sizes and SHA-256 hashes.
The originating run remains at
`/home/augustus/acgn-v215-full-20260908T190500Z/run`.

```bash
git lfs pull
./scripts/verify_imported_publication_snapshot.sh
```

The frozen JAR is retained without rebuilding at
`release-assets/acgn-experiments.jar`: 2,540,041 bytes, SHA-256
`a053e40e64faa2ecffb0f4999b57aa661eae51933d6daf93a95d973144a71abf`.
Use its sibling `SHA256SUMS` for verification. The preceding v2.11 manifest
and JAR remain unchanged in their original publication-run directory.

## Supervision Record

`supervision/control.tar.gz` retains command logs, progress checkpoints,
completion receipts and their hashes. The supervisor and its bounded tests
are retained for audit; their original preparation notes describe the state
before launch. `planned-commands.json` records the exact executed plan.

Two external supervisor preflights stopped before any experiment: Python 3.10
lacked `hashlib.file_digest`, then the fatal-error scanner matched the JVM's
`ExitOnOutOfMemoryError` option echo. Streaming SHA-256 and an error-token
boundary fixed those compatibility issues. Both failed records are preserved
in `supervision/preflight-failures.tar.gz`. They did not change repository
source, gate predicates, dataset, JAR semantics or the successful run's inputs.

The new run reproduces the previous distance, equality-coverage and reported
reward headline values. Performance numbers were remeasured: Fast Rewrite
23.990 seconds, Certificate-Integrated IR 2,684.110 seconds. These are one-run
measurements, not evidence of a general speedup from certificate repairs.
