# v3.0 Candidate Rerun

This is a new measurement, not a replacement of the final November 7 evidence.
Freeze the source commit before launch; use a fresh external output directory.
All relevant source and dependency identities, stage commands, outputs and
reports are bound by `publication_manifest.py`. A completed schedule is not
automatically an approved release.

## Schedule And Resources

Serial stages: CanonicalBatchTest, Alloy4FunAugmenter, seven-arm ablation and
semantic checks, 5,500-pair capability generation/validation, natural typed vs
untyped slots, then the bounded synthetic grid and figures. Natural stages use
16 workers, an 8 GiB heap and reward pool 100. Synthetic uses the existing
270-pair / 540-predicate grid (2..10 variables, 1..N nonempty types, five paired
shapes per cell), seed 20261107, eight isolated workers, 768 MiB heaps and a
**60-second timeout per predicate per arm**, totaling 1,080 observations.
The previous grid used 300 seconds; keep the cohorts and censoring explicit.

Keep the host memory reserve at 6 GiB, require 18 GiB available at startup,
retain 32 GiB external and 10 GiB internal disk reserves, and keep OOM exit
safeguards. The workstation service uses MemoryHigh=10G, MemoryMax=12G and no
swap. External-drive paths remain in machine-local configuration, not portable
runner defaults. Keep timeout evidence; do not count it as successful rewriting
or substitute 60 seconds as an exact completion time in speedup statistics.

## Finite Empirical Release Gates

`scripts/verify_v3_release_gates.py` records deterministic empirical gates:

1. 66,080 files, 61,598 successful AST-distinct comparisons, 4,482 AST-identical
   exclusions, no processing/reward failures and no inexact stored-orbit search.
2. The same paired source population, predicate identities and raw AST distances
   as the retained natural baseline, not merely the same aggregate count.
3. Both full-eligible-corpus paired-oracle mean distances (all 61,598 successful
   AST-distinct comparisons, not a sampled or CORRECT-only subset) in [13,15], the
   operational interpretation of "around 14" approved by the author before launch. A later
   user refinement must be recorded; never tune this range to observed results.
   Separately report both all-66,080 means including the 4,482 AST-identical
   pairs as zero. Keep these denominators distinct; the gate uses the same
   denominator as the prior 13.9701 / 14.0217 measurements.
4. No non-CORRECT zeroes in either paired arm or incorrect-to-any-truth rankings.
5. Identical paired zero subsets and identical per-pair distances between Fast
   and Certificate-Integrated; matching means or counts is insufficient.
6. 181 question groups, 4,315 AST-unique student references plus 181 oracles,
   42,386 ranked incorrect predicates, and zero parse/reference/ranking failures.
7. Identical unordered correct-pool zero-pair sets in both arms, with exact
   endpoint identities; equal nearest-truth distances on every incorrect row.
8. All seven natural ablation arms complete; Fast/certified per-row results
   agree with their batch results. Both capability arms recover 5,500/5,500;
   all scheduled arms have no execution errors or unexpected failures.
9. Natural and capability semantic checks have no errors, counterexamples or
   unresolved outcomes. Bounded solver checks are not unbounded proofs.
10. Both natural slot arms have the same complete eligible population and zero
    subset. Synthetic covers all 1,080 unique scheduled observations under the
    declared limits; only SUCCESS/TIMEOUT are acceptable completed outcomes.

Gate reports bind raw input hashes and the verifier hash. `--record-only`
allows a complete measurement schedule to preserve a **BLOCKED** report; it
does not convert that report to release approval. Parse/schema/tool failures
are INFRASTRUCTURE_FAILURE, never a pass. Unit tests cover equal-count/different-
subset mistakes, duplicate records, timeout censoring, identity and grid bounds.

## Known Open Issues And Publication

The [parity ledger](distance-parity-20261107/IMPLEMENTATION.md) remains applicable.
Two correct-pool partial-JOIN pairs are known to return Fast 0 / certified 8;
binary/flat and temporal edit geometry still differ. Thus this candidate is
expected to fail some parity gates. The documented module-less prelude export
defect is also unresolved: successful distance computation does not establish
that all exported Alloy files parse. Do not publish with this unresolved defect.
Do not interpret passing empirical gates as proof of the unfinished common
representation minimum or complete Java-Lean refinement.

Publish `v3.0` only after all gates, output-manifest verification, documented
open-issue resolution and exact-commit CI pass. Record source/run/JAR hashes,
update reports from raw evidence, and retain previous final results. Create an
annotated tag at the tested packaging commit; never move or overwrite an
existing local or remote `v3.0`. Attach the frozen run JAR and checksums using
the repository's artifact packaging workflow. Do not rebuild a different JAR
and describe it as the measured one. A failure or unresolved gate means no tag
and no release, with preserved evidence and a concrete blocker report.

Terra checks one bounded cycle every five minutes, correlating live processes,
systemd and logs. Quiet or RUNNING JSON alone is not proof of liveness. Remain
quiet on unchanged healthy checks; notify on failure, required action, recovery
or completion. No competing supervisors, unchanged blind retries, or weakening
of gates. A repair requires stopped descendants, source/Lean correspondence
where semantics change, bounded regression checks, a fresh commit and run root.
