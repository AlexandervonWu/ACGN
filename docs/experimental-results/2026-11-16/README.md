# Frozen Experiment: November 15-16, 2026

Experiment commit: `2d70f89ab67241cd071387ecedd3b2f432821921`.
The report commit is separate: no production source changed while these runs
were active. All 23 primary/study stages completed under their reviewed guards,
and their descendants exited. Raw receipts and bulk outputs remain on external
storage; [evidence-index.json](evidence-index.json) records their paths and hashes.
[headlines.json](headlines.json) contains the machine-readable headline values.

## What Was Repaired

The older 5,500/5,500 capability score was genuine for its revision. The regressed
candidate recovered 5,160/5,500 in both canonical paths on the same model bytes
and pair metadata. Controlled builds isolated a shared normalization scheduling
change: unused-binder simplification ran at different effective points inside
and outside equivalent formulas, and NNF could erase the source shape needed by
an existing guarded rewrite. Agreement between two consumers of that shared
normalizer therefore did not detect the lost equivalences.

The repair reorders existing checked transformations while retaining exact types,
scope/dependency ownership, temporal snapshots, multiplicities and negative
controls. A subsequent full-corpus comparison exposed six lost zeroes caused by
membership distribution and delayed neutral cleanup. Those general interactions
were repaired before this final run. No filename dispatch, removed soundness
gate, scalar copying, or unsupported-predicate exemption was introduced.

The [source scheduling contract](../../distance-parity-20261107/CAPABILITY_SOURCE_SCHEDULING.md)
and its [Lean proofs](../../distance-parity-20261107/CapabilitySourceScheduling.lean)
document the laws and retained premises. Two clean Lean builds agreed; the
compiled dependency audit admitted only the recorded standard Lean foundations.
The final candidate passed the registered Java suite, 570 scheduling-family
checks, 2,464 focused directions and 4,072 written attempts / 8,144 directions.
Disabling either scheduling correction reproduced its corresponding natural
regression. This is bounded proof/test evidence, not a verified Java interpreter.

## Full Natural Corpus

All 66,080 original files are accounted for: 61,598 eligible paired comparisons
and 4,482 historical AST-identical paired rows. Native diagnostics report
61,598 matches, zero unchecked, zero invalid replays, zero discrepancies and zero
errors. Both canonical paths find 4,174 distinct-AST student/oracle zero pairs;
none is labelled incorrect. Comparison with the preceding frozen publication
candidate loses no old canonical zeroes, retains the prior three gains, and adds
84 zero pairs. The 84 additions have source-linked bounded checks, both native
directions and corrupt-receipt controls.

The [paired report](paired/summary.md) is copied unchanged, including its
diagnostic/public-certification warning. Publishing these empirical observations
does not convert that diagnostic evidence into public certification. The 4,482
AST-identical rows are an inherited paired-measurement convention, not permission
to exclude their predicates from canonical-form or correspondence obligations.

## Full-Reference Augmenter

Every incorrect predicate is compared with its complete matching invariant's
AST-distinct oracle-plus-correct-student truth pool, not only a preselected nearest
reference. There are 181 oracle references and 4,315 unique correct-student
references. All 42,386 incorrect predicates were ranked and rewarded; no parse,
pool-preparation, ranking or reward failure was recorded.

- Recorded reference comparisons: **1,894,168**. The producer also separately
  accounts for 21 raw-AST-identical cross-file comparisons.
- Mean nearest raw-AST distance: **12.267140**.
- Mean nearest Fast Rewrite and Certificate-Integrated distance: **11.505686**.
- Recorded Fast/certified distance discrepancies: **0**.
- Incorrect predicates with zero nearest distance: **0** in either path.
- Unordered distinct-AST truth pairs at distance zero: **11,607** in each path;
  the corresponding zero-relation components number **2,074**.

The [Augmenter report](augmenter/summary.md) provides the per-class breakdown.
This audit checks recorded rankings, identities, distances and rewards. It does
not replay every cross-reference native action; nonzero correct-pool comparisons
are not all individually serialized. The prior native-action ledger remains a
separate obligation.

## Ablation And Capability

Each natural arm accounts for the same 66,080 files, measures 61,598 eligible
pairs, and reports zero failures and zero incorrect zeroes. The table's wall time
is the study-arm measurement, not the separate guarded launch or diagnostic run.

| Arm | Natural zero pairs | Capability recovery | Natural wall seconds |
| --- | ---: | ---: | ---: |
| Raw e-graph | 820 | 2,585 / 5,500 | 18.005 |
| Raw + De Bruijn | 2,160 | 3,628 / 5,500 | 18.586 |
| Java egglog-like | 820 | 2,585 / 5,500 | 18.106 |
| Java egglog-like + De Bruijn | 2,160 | 3,628 / 5,500 | 18.270 |
| Slotted e-graph | 2,228 | 5,500 / 5,500 | 18.392 |
| Fast Rewrite IR | 4,174 | 5,500 / 5,500 | 25.904 |
| Certificate-Integrated IR | 4,174 | 5,500 / 5,500 | 406.822 |

The capability generator reproduced all 5,500 prior source files and pair
metadata exactly. All 11 families contain 500 pairs. The corrected report groups
the **five composed families / 2,500 pairs**, rather than the old underscore-based
eight-family grouping; the strict 5,500 recovery gate was not weakened.

The natural ablation is not a monotone hierarchy: slotted storage loses three
De Bruijn zeroes, and Fast Rewrite loses ten slotted zeroes while adding 1,956.
Those cross-arm losses are recorded, not relabelled as successes; the preceding
candidate also had ten slotted-to-Fast losses. They are distinct from the
cross-candidate canonical zero-preservation check. See
[transition identities](natural-ablation/equivalence_disagreements.csv).

The bounded semantic checker examined the union of **4,184** natural zero claims,
with no counterexample or execution error. All four negative probes remained
unmerged. The capability subtype sample completed **29** bounded checks,
including eight temporal checks, without counterexamples or inconclusive rows.
These checks use each model's recorded bounds, not universal semantic proofs.

The natural-study maximum measured file times were **0.356519 s** for Fast
Rewrite and **4.114356 s** for Certificate-Integrated; every natural arm stayed
below 60 seconds. CanonicalBatch and Augmenter did not record whole-file wall
times, so their component timings are not used to make the same claim.

Reports: [natural ablation](natural-ablation/summary.md),
[bounded natural checks](natural-ablation/semantic_soundness.md),
[capability matrix](capability/REPORT.md), [capability checks](capability/SOUNDNESS.md).

## Typed Slots

The matched natural treatment changes exact parser-derived slot colors while
retaining the same source corpus and rewrite/distance machinery. Both arms
recover 2,228 zero pairs, with no zero-set disagreement. Summed engine CPU time
falls from **20.493 s untyped to 11.028 s typed** (1.86x); process wall time is
essentially unchanged, **20.200 s versus 20.180 s**. This is not a 1.86x
end-to-end speedup. See the [natural slot census](natural-slot-typing/summary.md).

The complete synthetic grid has 270 source pairs, 540 predicates and 1,080
typed/untyped trials. It uses eight workers, 768 MiB per JVM and the pre-existing
300-second trial deadline. No observations are omitted:

| Arm | Successes | Censored timeouts | Errors / unattempted |
| --- | ---: | ---: | ---: |
| Typed | 530 / 540 | 10 | 0 / 0 |
| Untyped | 442 / 540 | 98 | 0 / 0 |

All ten typed timeouts occur at **10 bindings / one type**. The untyped arm's
98 timeouts also all occur at ten bindings. All **450 typed trials with more
than one type succeed**, including all 90 at ten bindings / multiple types.
This is the intended scaling contrast: type-compatible slot partitions reduce
the renaming search, but a single type leaves the same type-unrestricted
permutation space. These expected benchmark timeouts remain censored runtime
observations, not invalid replays, semantic failures, or omitted inputs. The
derived breakdown is in `synthetic.timeoutAnalysis` in [headlines.json](headlines.json);
the original trial rows and generated summary are unchanged.

On the **same 442 jointly successful predicates**, median engine elapsed time
is **0.025169 s typed versus 0.670026 s untyped**; total elapsed medians are
**0.166021 s versus 0.849457 s**. The respective ratios of medians are **26.62x**
and **5.12x**, not medians of per-predicate speedups and not timeout-inclusive
estimates. These concurrent elapsed measurements are not CPU time.

The surface has **44/54 complete matched cells**. Missing cells remain missing;
the plot does not interpolate across censored cells. Input replicates are not
independent timing reruns. See [raw trial rows](synthetic/trials.jsonl),
[all outcomes](synthetic/summary.md), [audit](synthetic/audit.json), and
[figures and cell data](synthetic/plots/README.md).

## Reproduction And Limits

The natural/capability studies used 16 workers and an 8 GiB heap on an AMD Ryzen
9 9950X3D with 32 logical processors and OpenJDK 17.0.21. Seed: `55520260811`.
The frozen dataset SHA-256 is
`d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`.
Exact ordered runtime jars, source inventories, commands, guard receipts and
auditor hashes are retained through the evidence index. Guards retained zero
service swap, OOM stops, disk checks, a 12 GiB corpus cap and 6 GiB runtime host
reserve. The 17 GiB admission check is startup-only, not a running free-RAM rule.

Public certification remains **BLOCKED**. General source-wire/Java-Lean
correspondence, the historical text assertion, canonical obligations for
AST-identical paired predicates, and the separate full cross-reference
native-action ledger are not discharged by this publication. Unsupported or
unverified predicates remain obligations, never permanent exclusions. Earlier
snapshots and failed-candidate evidence remain retained; this report does not
overwrite their observations.

This is an assurance status, not a publication ban or a claim that the measured
comparisons failed. In particular, native action comparison authenticates its
`FROZEN_NORMALIZED_IR` boundary; it does not establish a general proof of the
parser/normalizer, source-certificate wire replay, or the separately exported
public repair sequence. See the [v3 assurance boundary](../../release-v3.md#assurance-boundary).
