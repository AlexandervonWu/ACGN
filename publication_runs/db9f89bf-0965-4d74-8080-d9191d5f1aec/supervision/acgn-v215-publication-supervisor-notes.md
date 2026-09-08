# v2.15 Publication Supervisor

Preparation only. No builds or experiments were launched. Repository files were
only read. The supplied source commit must be clean when main launches.

## Usage

Plan only (no writes or subprocesses):

```sh
python3 -B /tmp/acgn-v215-publication-supervisor.py --source-commit "$SOURCE_COMMIT" --run-root "$NEW_EXTERNAL_ROOT"
```

Launch after inspection, with the exact 40-character clean source commit:

```sh
python3 -B /tmp/acgn-v215-publication-supervisor.py --source-commit "$SOURCE_COMMIT" --run-root "$NEW_EXTERNAL_ROOT" --execute
```

The external root must not exist and must not contain whitespace. No resume or
reuse is supported. Failure or interruption preserves `control/BLOCKED.json`,
all logs, and partial outputs. The process group receives TERM, then KILL.

`run/run-manifest.json` is the publication manifest. `control/status.json` and
`control/checkpoints.jsonl` update every 60 seconds, including recent log tails.
Live control files are outside the sealed `run/` artifact tree. Publication
command receipts contain command, result, and log SHA-256 hashes and are bound
through the existing manifest tool. Post-seal finalize/verify receipts remain in
`control/command-results.json`; `control/completion.json` binds its hash and the
final manifest hash without a circular self-hash.

Stage order: canonical; augmentation; seven-arm ablation AND semantic checker;
capabilities. One source JAR, Java 17, UTF-8, 16 workers, 8g, reward pool 100,
all 66080 files, seed 55520260811, target 500. No CPU/GC policy.

## Validation

```sh
python3 -B /tmp/test-acgn-v215-publication-supervisor.py
python3 -B /tmp/test-acgn-v215-publication-supervisor.py --snapshot
```

Both completed successfully. Five tiny structural tests cover label mapping,
missing/mistyped counters, final retry status, semantic errors/missing arms, and
temporal inconclusives/fatal JVM failures. Read-only full old-snapshot checks
passed canonical (61598 rows), augmentation (entire 1.3 GB JSON), seven ablation
arms, 4088 semantic checks, and 5500 capability pairs / 77 cells. A synthetic
Fast Rewrite incorrect-nearest-zero mutation was rejected. No experiment
subprocesses are called by these tests. Old output identity is used only for
schema testing, never reused as fresh publication evidence.

`under`/`over` follow DatasetConventions. All 4482 old omissions happened to be
CORRECT; launch gates preserve actual skip labels rather than assume that.
Both certified and Fast Rewrite incorrect-nearest-zero counts must be zero;
either result blocks for investigation. Legal misses by the four baseline arms
are allowed; slotted, Fast Rewrite, and certified must capture all 5500 pairs.
Six finite temporal checks remain explicitly inconclusive, including retained
SAT reports; these are neither conclusive semantic contradictions nor proofs.

Not executed: build, launch, process interruption integration, or manifest
finalization. These remain operational checks for main's reviewed fresh run.
