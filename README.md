# ACGN / CanDis setup and usage

This note matches the final Aug. 7–8, 2026 commit chain on the default `aislop`
branch, through commit [`f067106`](https://github.com/AlexandervonWu/ACGN/commit/f0671061e619af8c397be964d2a5a872d4ecbd77).
It describes the final tree, not the transient states between those commits.

## What changed in this commit series

| Commit | Final documentation consequence |
| --- | --- |
| [`20b93dd` — `ablation`](https://github.com/AlexandervonWu/ACGN/commit/20b93dd2411c2987115342337828cf68dcf18a56) | Added the four-arm e-graph ablation, pair-level metrics, combined reports, inspection, and bounded soundness checks. |
| [`afd215f` — `ablation sh`](https://github.com/AlexandervonWu/ACGN/commit/afd215fb9f73652f084ee1488b7c95b785548f12) | Added `scripts/run_egraph_ablation.sh`, which compiles the full source tree and launches the suite. |
| [`1c3097b` — `update`](https://github.com/AlexandervonWu/ACGN/commit/1c3097b6fc49ab130f0c9b29f8f179d9743641ac) | Corrected binding comparison and carrier handling and refreshed the ablation interpretation. |
| [`78ff144` — `rerun`](https://github.com/AlexandervonWu/ACGN/commit/78ff144f7a651e9ce8a490ece61aaf8de9ad8285) | Refreshed generated distance and augmentation artifacts; it did not add a new command. These results were subsequently superseded by later reruns. |
| [`9cc49c7` — `optimized bookkeeping`](https://github.com/AlexandervonWu/ACGN/commit/9cc49c79f45d07305d3fb8812554dbeab056f6d2) | Moved raw-AST-identical pairs out of eligible comparisons, added focused MASG construction and prepared-form reuse, deduplicated augmentation work, added AST-identity auditing, and expanded CPU/run metadata. The ablation heap default became `3g`. |
| [`88822e2` — `parallelized Ablation`](https://github.com/AlexandervonWu/ACGN/commit/88822e2b8208db456c5197719117ab12834782fe) | Completed the shared ablation worker policy: `min(requested, logical processors, 32)`. |
| [`a104152` — `wrapping up`](https://github.com/AlexandervonWu/ACGN/commit/a1041525c88fb1596c68bf2e5958ac7afcef183d) | Added equivalent-discovery efficiency fields and tables. |
| [`fa08cff` — `clearup of package`](https://github.com/AlexandervonWu/ACGN/commit/fa08cfffc66bfc277f7e855c46f287848aac5197) | Moved the reusable implementation to `is.fivefivefive.CanDis.core` and `.core.egraph`; parser conversion now lives in `.adapter`, while `Canonical` is the MASG compatibility facade. |
| [`f067106` — `documentation`](https://github.com/AlexandervonWu/ACGN/commit/f0671061e619af8c397be964d2a5a872d4ecbd77) | Added `documentation/README.md`. Its nonexistent core-build script reference still needs correction; see the alignment checklist below. |

## Requirements and repository assumptions

- Use a full JDK 17 installation: `java`, `javac`, `jar`, and `jdeps` are needed.
- The full project expects all dependency JARs under repository-root `lib/` and
  uses the classpath wildcard `lib/*`.
- The supplied ablation launcher is POSIX/Linux-oriented. It requires Bash,
  `find`, `mktemp`, and GNU `/usr/bin/time` at that exact path.
- Run the commands below from the repository root unless using
  `scripts/run_egraph_ablation.sh`; that script resolves and changes to its own
  repository root.
- The commands use the Unix classpath separator `:`. Windows needs `;` and does
  not directly support the supplied shell script.

The expected dataset shape is:

```text
classified-data/
  <question-set>/
    CORRECT|BOTH|OVERCONSTRAINED|UNDERCONSTRAINED/
      <prefix>_<invariant>.als
```

`OVER` and `UNDER` are also normalized to their full status names. The first
relative path component is treated as the problem/question class and the second
as the status. Each Alloy file is expected to contain a student/oracle predicate
pair named `X` and `XC` or `Xc`. The filename suffix after the last underscore
is used as the preferred `X`; if that hint fails, the code searches for another
`X`/`X[Cc]` pair.

## Compile once for direct Java runners

```bash
ACGN_BUILD_DIR="$(mktemp -d /tmp/acgn-build.XXXXXX)"
mkdir -p "$ACGN_BUILD_DIR/classes"
find src -name '*.java' -print > "$ACGN_BUILD_DIR/sources.txt"
javac -cp 'lib/*' -d "$ACGN_BUILD_DIR/classes" @"$ACGN_BUILD_DIR/sources.txt"
ACGN_CLASSPATH="$ACGN_BUILD_DIR/classes:lib/*"
```

The ablation shell script performs its own full compilation, so this step is
not required when that script is the only entry point.

Fast regression checks after a full compile:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.ablation.EGraphAblationTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.EGraphSaturationTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBacktranslatorTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest
```

### Build the standalone JDK-only core

The READMEs currently name `scripts/build_candis_core.sh`, but that file is not
present at `f067106`. Until it is added, use:

```bash
ACGN_CORE_DIR="$(mktemp -d /tmp/candis-core.XXXXXX)"
mkdir -p "$ACGN_CORE_DIR/classes"
find src/is/fivefivefive/CanDis/core -name '*.java' -print \
  > "$ACGN_CORE_DIR/sources.txt"
javac -d "$ACGN_CORE_DIR/classes" @"$ACGN_CORE_DIR/sources.txt"
jar --create --file "$ACGN_CORE_DIR/candis-core.jar" \
  -C "$ACGN_CORE_DIR/classes" .
jdeps -summary "$ACGN_CORE_DIR/candis-core.jar"
```

The intended dependency summary is `candis-core.jar -> java.base`.

## Main workflows

Use fresh output directories for smoke tests. The default output directories are
tracked result snapshots in this repository and will be overwritten by a rerun.

### 1. Canonical batch distance

Smoke run:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data /tmp/acgn-distance-smoke \
  --limit 100 --threads 4 --reward-pool 10
```

Full reference command:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data distance_results \
  --threads 32 --reward-pool 10
```

Options are `--limit N`, `--threads N`, `--reward-pool N`, and `--verbose`.
`N <= 0` means no limit. Reward computation is attempted for every eligible
pair; this runner has no `--skip-rewards` option.

This command directly writes only:

- `distance_results/distances.json`
- `distance_results/summary.md`

Raw-AST-identical student/oracle bodies are counted as skipped and are omitted
from the JSON `results` array.

### 2. Alloy4Fun reference-pool augmentation

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.Alloy4FunAugmenter \
  classified-data alloy4fun-augmented \
  --threads 32 --reward-pool 100
```

Additional options:

- `--limit N`: first `N` sorted `.als` paths only; `N <= 0` means full input.
- `--skip-rewards`: build distances and reports without computing rewards.
- `--audit-only`: stop after writing
  `ast_identical_cross_file_comparisons.csv`.
- `--verbose`: retain parser/worker output.

The full run writes `index.json`, `summary.md`,
`correct_ast_diff_canonical_equiv.json`, `canonical_reward_points.csv`, the
`correct/<question-set>/<invariant>.als` pools, four SVG plots, the plotting
script `plot_canonical_rewards.py`, and the AST-identity audit CSV.

Ranking is over AST-distinct references. An incorrect/reference comparison is
skipped when their raw-AST fingerprints match; an incorrect model is omitted
from rankings only when every available truth is AST-identical. Duplicate
incorrect representations within a question group reuse one computed ranking.

### 3. Four-arm e-graph ablation

Smoke run:

```bash
./scripts/run_egraph_ablation.sh \
  --input classified-data \
  --output /tmp/acgn-egraph-ablation-smoke \
  --limit 100 --threads 4 --max-heap 3g
```

Full reference command:

```bash
./scripts/run_egraph_ablation.sh \
  --input classified-data \
  --output egraph_ablation \
  --threads 32 --max-heap 3g
```

The suite runs these arms sequentially in fresh JVMs:

1. `raw-egraph`
2. `java-egglog`
3. `slotted-egraph`
4. `canonical`

`java-egglog` is the repository's Java egglog-like execution-core replica, not
the external egglog binary or a complete language-compatible port.

The effective worker count is
`max(1, min(requested, availableProcessors, 32))`. The `--max-heap` value is
passed to each child JVM as `-Xmx`; `3g` is the default and applies per arm.

Each arm writes `pairs.csv`, `summary.json`, `metrics.properties`, `process.time`,
and `run.log`. The suite then writes `comparison.json`,
`minimum_distances.csv`, `equivalence_disagreements.csv`, and `summary.md` at the
output root.

To rebuild only the combined reports:

```bash
./scripts/run_egraph_ablation.sh \
  --output egraph_ablation \
  --threads 32 --report-only
```

Report-only mode requires all four arms' `metrics.properties`, `process.time`,
and `pairs.csv`. They must come from the same source revision, dataset snapshot,
input path convention, limit, and skip policy. Stored worker counts must equal
the current effective worker count; therefore a 32-thread cache cannot be
regenerated on a host exposing fewer than 32 processors with the current code.

### 4. Diagnostics and bounded validation

Inspect one Alloy pair and all four representations:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.EGraphAblationInspector \
  classified-data/<question-set>/<status>/<model>.als
```

Validate zero-distance claims already present in an ablation result tree:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.EGraphSemanticSoundnessCheck \
  --input classified-data --results egraph_ablation --threads 8
```

This writes `semantic_soundness.json`, `semantic_counterexamples.csv`, and
`semantic_soundness.md`. `--canonical-only` means canonical claims not already
found by `slotted-egraph`; it does not mean all canonical claims. Validation is
bounded by the Alloy commands in each model and is not an unbounded proof.

Backtranslation smoke check:

```bash
java -cp "$ACGN_CLASSPATH" \
  is.fivefivefive.CanDis.CanonicalBacktranslationEquivalenceTest \
  classified-data --limit 100 --scope 3 \
  --output /tmp/acgn-backtranslation/mismatches.json
```

Give `--output` a path with a parent directory; the current implementation
creates `output.getParent()`.

## Result-count and reproducibility semantics

After optimized bookkeeping, these fields are not interchangeable:

- `files`: all discovered `.als` files.
- `skippedIdenticalRawAstPairs`: files whose selected student/oracle bodies have
  identical raw ASTs.
- `eligiblePairs`: `files - skippedIdenticalRawAstPairs`.
- `successes`: successfully processed eligible pairs.
- `failures`: failed eligible pairs.

The committed full ablation at `f067106` is a useful stale-output check:

| Measure | Reference value |
| --- | ---: |
| Discovered files | 66,080 |
| Raw-AST-identical skipped | 4,482 |
| Eligible/successful per arm | 61,598 |
| Zero-distance pairs: raw / Java egglog / slotted / canonical | 823 / 823 / 2,162 / 2,235 |

The generated files record timestamps, input paths, limits, worker counts, Java
version, and rewrite-set metadata, but no run ID, Git commit SHA, or dataset
content hash. Output directories are mutable snapshots, not self-identifying
runs. For archival reruns, encode a run name in the output path and record the
source SHA and dataset revision alongside it.

## Documentation alignment checklist

1. Add `scripts/build_candis_core.sh` or replace both README references with the
   manual core build above.
2. Replace the top-level VS Code starter boilerplate with the actual JDK 17,
   `lib/*`, dataset, and runner requirements; mention that `aislop` is the
   default branch.
3. Keep imports aligned with the package cleanup:
   `CanDis.core`, `CanDis.core.egraph`, and `CanDis.adapter`. Old production
   imports from `CanDis.macros` or `CanDis.ablation` are stale; only the
   executable test remains in the latter package.
4. State that `CanonicalBatchTest` always attempts rewards and directly emits
   only JSON plus Markdown. CSV/SVG files currently present under
   `distance_results/` are not produced by this runner.
5. List the AST-identity audit and plotting artifacts for `Alloy4FunAugmenter`.
6. List `process.time` and `run.log` as per-arm ablation outputs. Treat
   `semantic_soundness.*` as outputs of the separate soundness command.
   `canonical_only_vs_slotted.md` has no producer in the current source tree and
   should be labeled historical/manual or removed.
7. Define counts using `files`, `skipped`, `eligible`, `successes`, and
   `failures`; do not describe all 66,080 files as evaluated distance pairs.
8. Distinguish thread behavior: the two dataset runners default to literal 32,
   while the ablation suite caps requested workers by available processors and
   32. Document positive thread values only; the dataset-runner metadata can be
   misleading for nonpositive inputs.
9. Warn that `--report-only` trusts retained per-arm files and validates only
   their worker counts. It does not verify a shared commit, dataset hash, limit,
   or run identity.
10. Keep the semantic boundary explicit: distance zero means equality under the
    implemented rewrite/canonicalization theory. "Found semantic equivalent"
    in the ablation tables additionally trusts the existing `CORRECT` label;
    the ablation itself does not rerun SAT.
11. Note that default output paths overwrite the repository's committed result
    snapshots and that the supplied launcher assumes Bash, `/tmp`, and GNU
    `/usr/bin/time`.
