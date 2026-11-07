# Final Natural-Corpus Results

The author designated all completed natural-corpus results from the November 7
run as final. The synthetic stress stage was stopped separately; its cancellation
does not invalidate the completed natural stages. This is a final-results record,
not a claim that the original combined schedule completed or a new release.

## Provenance and Preservation

- Result-producing commit: `3ef7d93bcab87ecd30ffba4c02e01c690981a137`.
- Run: `03817f3e-1542-4ce1-98b2-753bd2b320d1`.
- Natural dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`.
- Settings: 16 workers, 8 GiB heap, reward pool 100.
- Complete raw evidence remains at `/media/augustus/8618-0ED0/ACGN/intermediate/full-corpus-8g-20261107T062202Z`.
- Final retention registration: `/media/augustus/8618-0ED0/ACGN/final-results/natural-corpus-20261107`.

`evidence-index.json` records the final designation, hashes, and locations.
`natural-reports/` contains byte-identical compact copies of the original reports.
Bulk JSONs, per-pair data, manifests, logs, generated models, and build artifacts
are all retained externally; they are not discarded because the original directory
contains the word `intermediate`. The original files and manifest remain unchanged,
including its stale running status. All 7,164 retained regular files passed the
new preservation inventory; all 5,826 originally manifest-bound outputs passed
their original checksums. Preservation in place is not an independent-device backup.

## Main Outcomes

CanonicalBatch considered 66,080 files: 61,598 eligible comparisons succeeded,
4,482 AST-identical pairs were skipped, and there were zero failures, incorrect
zero-distance merges, or inexact alpha searches. Certificate-Integrated IR found
4,088 AST-distinct CORRECT paired-oracle zeroes. Mean distances were 14.021721
(Certificate-Integrated), 13.970096 (Fast Rewrite), and 17.086902 (raw AST).
All 61,598 reward evaluations succeeded.

The augmenter parsed 61,598 models across 181 question groups and ranked all
42,386 incorrect predicates. Parsing, reference preparation, ranking, and reward
failures were zero. Both IRs had zero incorrect-to-any-truth zero matches.
Across 4,496 AST-distinct truths, Fast Rewrite found 11,102 unordered zero pairs
and Certificate-Integrated IR found 11,382, an aggregate difference of 280.
Mean nearest distances were 11.460813 and 11.562709 respectively. These truth-pool
comparisons differ from the paired-oracle experiment.

Every one of the seven ablation arms completed 61,598 eligible comparisons.
Raw and Java egglog each found 820 equalities; their De Bruijn variants each
found 2,160; slotted found 2,228; Fast Rewrite and Certificate-Integrated IR each
found the same 4,088 zero pairs. Every arm had zero incorrect-labelled zeroes.
Fast Rewrite took 23.850 s wall and 71.196 s engine CPU; the certified path took
2,706.990 s wall and 40,805.295 s engine CPU. The certificate assurance path
remains much more expensive despite paired-oracle zero-set agreement.

The retained, separately generated capability suite had 5,500 execution successes
per arm. Slotted, Fast Rewrite, and Certificate-Integrated IR each detected all
5,500 equalities. Raw/egglog detected 2,585, and their De Bruijn variants 3,628.
The bounded soundness check completed 29 checks with zero failures. This capability
suite is not natural-corpus data and is not an unbounded proof.

## Natural Typed Versus Untyped Slots

Both arms completed 61,598 comparisons with zero failures and exactly the same
2,228 zero pairs. Source census: 170,112 binding occurrences across both sides.

- Untyped: wall 20.160 s; engine CPU 18.210 s; adapter CPU 0.262 s;
  comparison CPU 17.910 s; mean distance 16.324.
- Typed: wall 19.560 s; engine CPU 10.391 s; adapter CPU 0.881 s;
  comparison CPU 9.471 s; mean distance 16.421.

Typed used approximately 42.9% less engine CPU and 3.0% less wall time in this
single run. Extra type-adaptation cost was outweighed by lower comparison cost.
These nested CPU components are not additive to the total. Zero-set agreement
does not mean positive distances agree. Neither matched slot baseline is
certificate-bearing; do not conflate it with the exact certified ablation arm.

## Interpretation Boundaries

This is a complete natural-corpus measurement, not repeated-run confidence
intervals. Natural slots retain their existing finite search budgets; synthetic
trials use uncapped construction with an external deadline. Dataset-labelled
incorrect-zero counts and bounded soundness checks are empirical evidence, not
a universal semantic guarantee. Distance/reward linear association is weak:
augmenter raw reward-error Pearson is 0.068209 (Fast) and 0.067416 (certified).

## Final Bounded Synthetic Grid

The [synthetic report](synthetic-grid/RESULTS.md) records the completed 1,080-trial
schedule, separate from the natural results. All 54 combinations of 2..10
variables and 1..N types were included, with five paired shapes per cell.
Typed completed 530/540 predicates (98.15%); untyped completed 443/540 (82.04%).
There were 107 timeouts and no final OOM or execution-error outcomes. All
timeouts were at ten variables. Exact log-speedup surfaces cover the 44 fully
matched cells; the completion map and CSV retain all ten censored cells.

A host-memory reserve stop required continuation of 214 interrupted/unstarted
trials; all 866 already completed observations were preserved unchanged. This
interruption and the identical frozen implementation/settings are documented,
not presented as an uninterrupted run. No natural-corpus experiment was rerun.
