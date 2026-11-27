# Historical pair coverage

The full publication run compares the candidate with every archived edition on the frozen 66,080-file natural corpus. The check uses the corpus digest, original source path and selected Alloy predicates. Renumbering the displayed references within a pool preserves their identities. For a positive fixed-command decision it checks the command selection (for original files), effective signature bounds, integer bitwidth, temporal trace limits, applicable rule and native UNSAT outcome.

The historical floor combines the tagged artifact freezes, v2.1 through v2.17, the v3.1 natural ablation, the v3.2 reference-pool ledger and all complete v3.3-format releases under `docs/experimental-results`. The v3.1 records include every v3 structural zero according to the published v3-to-v3.1 pair deltas. The v3.2 ledger records the v3.1 structural decision on every unordered reference pair. The v2 release inputs identify each batch, ablation arm and correct-reference report by Git object or LFS digest. The two artifact freezes have distinct measurement histories, recorded separately from the semantic-version releases. Both canonical arms must retain every historical direct structural zero. A fixed-command link or an indirect path cannot discharge that obligation. The release gate also checks the published component relation within each edition and keeps the 105 recorded native SAT pairs separate in the candidate.

Run the verifier on the directory containing the batch, augmenter and ablation outputs. It produces a nonzero exit status on a loss and records every affected identity in the JSON report.

```sh
python3 scripts/verify_historical_pair_coverage.py --artifacts RUN/artifacts \
    --output RUN/historical-coverage.json --write-floor RUN/historical-pairs.json.gz
```

To recount a compact release, replace `--artifacts RUN/artifacts` with `--candidate docs/experimental-results/EDITION`. The full-run mode also reads the separate Fast Rewrite and Certificate-Integrated correct-pool reports and checks equality of their complete zero sets. It compares all 1,894,168 Fast Rewrite and Certificate-Integrated ranking scores by submission and reference identity, including references beyond the nearest. The compact v3.3 correct-pool ledger contains the certificate-integrated zero flag. Use `--latest` to check retention on the compact export with the most recent completed run receipt. Full-run diagnostics and proof replay retain their separate verification requirements.

For each future edition, publish either its complete v3.3-format export or its verified `historical-pairs.json.gz` in a new directory under `docs/experimental-results`. Keep prior directories in place. On subsequent runs the verifier discovers the new edition and includes its gains automatically. Each passing run can write a new floor once. The published denominator remains the frozen natural corpus; evaluate that cohort separately if a later study also enrolls new files.

The publication gate also recompiles each of the 4,496 archived references from its original, hash-checked source and runs original Slotted on all 132,032 within-pool pairs. It checks that both canonical arms cover the 8,952 original Slotted zeros measured with the v3.3 engine and that their structural zero set strictly contains the current Slotted set. The run writes every original distance to `slotted-reference-pairs.csv.gz` and records the identities of any losses in `slotted-reference-pools.json`.

The seven CV reference pairs have individual Lean proofs. The source check reads the original Alloy predicates, verifies their archived hashes and the declared range of `User.visible`, and checks that the Lean goals agree with the transcriptions. Each proof is valid for every interpretation of the typed fields, including empty carriers. Both checks run in bounded CI. [Lean proofs](../section3-repair-audit/formal/HistoricalCVPairs.lean) · [Source check](../../scripts/check_historical_cv_proofs.py)

The pre-v3 floors can be regenerated from the release tags and their Git LFS batch files.

```sh
git lfs fetch --include=distance_results/distances.json origin artifact-freeze-v1 artifact-freeze-v2 v2.1 v2.11 v2.15
python3 -B scripts/import_v2_historical_pair_coverage.py
```

[Original v3-to-v3.1 paired deltas](../experimental-results/2026-11-21/paired-zero-gains.json) · [Reference-pool deltas](../experimental-results/2026-11-21/correct-pool-gains.json) · [v3.2 reference archive](../experimental-results/2026-11-25/README.md)
