# ACGN / CanDis v3

v3 publishes the completed November 15-16, 2026 research evaluation and the
repaired implementation behind it. The full experiment used frozen commit
`2d70f89ab67241cd071387ecedd3b2f432821921`. Subsequent changes update bounded
CI source correspondence and publish the results; they do not change production
Java, Lean proofs, experiment inputs, or measured outcomes.

The [complete report](experimental-results/2026-11-16/README.md),
[machine-readable headlines](experimental-results/2026-11-16/headlines.json),
and [evidence index](experimental-results/2026-11-16/evidence-index.json)
retain the detailed measurements, identities, controls, and scope. Older
release reports remain historical observations, not overwritten baselines.

## Research Results

- **Natural corpus:** all 66,080 original files accounted for. All 61,598
  eligible native paired comparisons match, with zero unchecked, invalid,
  discrepant, or error outcomes. The 4,482 historical AST-identical paired rows
  are accounted separately, not declared exempt from canonical obligations.
- **Canonical equality:** both paths recover 4,174 distinct-AST student/oracle
  zero-distance pairs, with no incorrect zeroes. No old canonical zero is lost;
  84 new zeroes have separate bounded and native-replay controls.
- **Full-reference Augmenter:** 42,386 incorrect predicates searched against
  their complete matching invariant's truth pools: 181 oracle references and
  4,315 unique correct-student references in total. There are 1,894,168 recorded
  comparisons, zero recorded Fast/certified distance discrepancies, zero
  incorrect nearest zeroes, and no parse, pool, ranking, or reward failures.
  Another 21 raw-AST-identical cross-file comparisons are separately accounted.
- **Nearest repair distance:** mean raw-AST distance is 12.267140; both canonical
  paths give 11.505686. Truth pools contain 11,607 unordered distinct-AST zero
  pairs and 2,074 zero-relation components in either canonical path.
- **Ablations:** natural zero-pair counts are 820 raw, 2,160 raw plus De Bruijn,
  820 Java egglog-like, 2,160 egglog-like plus De Bruijn, 2,228 slotted, and
  4,174 in each canonical path. Every arm completes with zero failures and
  zero incorrect zeroes. This is not a monotone hierarchy: the recorded
  De-Bruijn-to-slotted transition loses three zeroes, and slotted-to-Fast loses
  ten while adding 1,956; these observations remain in the published data.
- **Capability:** all 11 families have 500 pairs, and regenerated source bytes
  and pair metadata match the earlier 5,500-pair cohort. Raw and egglog-like
  recover 2,585; their De Bruijn variants recover 3,628; slotted, Fast Rewrite,
  and Certificate-Integrated each recover all 5,500. The composed subset is
  five families / 2,500 pairs.
- **Semantic controls:** bounded Alloy checks cover the union of 4,184 natural
  zero claims with no counterexample or execution error; four negative probes
  remain unmerged. All 29 sampled capability checks, including eight temporal
  checks, complete without counterexamples or inconclusive results.
- **Natural performance:** Fast Rewrite's study arm takes 25.904 seconds;
  Certificate-Integrated takes 406.822 seconds. Their maximum measured file
  times are 0.356519 and 4.114356 seconds, respectively. Every natural study
  arm stays below 60 seconds per file. Separate CanonicalBatch and Augmenter
  runs do not record whole-file wall times, so no such timing claim is inferred
  retrospectively for those runners.
- **Natural typed slots:** both treatments recover the same 2,228 zero pairs.
  Summed engine CPU falls from 20.493 to 11.028 seconds (1.86x), while process
  wall time is essentially unchanged at 20.200 versus 20.180 seconds. Scalar
  distance means differ; equality of every nonzero distance is not claimed.

## Synthetic Scaling

The complete 2..10-binding grid has 270 pairs, 540 predicates, and 1,080 trials.
It uses eight isolated workers, 768 MiB per JVM, and the existing 300-second
deadline. The untyped arm completes 442/540 trials with 98 timeouts. The typed
arm completes 530/540 with ten timeouts. There are no errors or unattempted
trials, and none of the timeout observations is removed.

**Every typed timeout is at ten bindings and one type.** All 450 multi-type
typed trials complete, including all 90 at ten bindings with multiple types.
Every untyped timeout is also at ten bindings. These are expected stress-test
outcomes: typing cannot partition a single-type binder orbit, leaving the same
type-unrestricted permutation space. They are not natural-corpus timeouts,
invalid proofs, or invalid repair replays.

For the same 442 jointly successful predicates, typed versus untyped median
engine elapsed time is 0.025169 versus 0.670026 seconds, a **26.62x ratio of
medians**. Total elapsed medians are 0.166021 versus 0.849457 seconds, a **5.12x
ratio**. These are elapsed, not CPU, measurements; they neither include censored
runtimes nor estimate a median of per-predicate speedups. The plots retain the
44/54 complete matched cells without interpolating censored cells. Input
replicates are not independent timing reruns.

## Repair And Validation

The old 5,500/5,500 score was genuine. Shared normalization scheduling later
reduced both canonical paths to 5,160 on identical inputs, so cross-path
agreement alone missed the regression. The fix restores the order of existing
typed, scoped, temporal-aware rules. Membership elimination precedes destructive
distribution, and neutral cleanup repeats after unused-binding removal.
No filename dispatch, semantic gate removal, or unsupported-case exemption was
introduced. Fixed-cohort capability recovery and old-zero preservation now
accompany cross-path comparisons.

The candidate passed 570 scheduling checks, 2,464 focused directions, and
4,072 written attempts / 8,144 directions. Two clean Lean builds and compiled
dependency audits agreed under the recorded standard Lean foundations. The
registered Java suites and mutation controls passed. All five remote CI jobs
passed at `873b17bb4cf40ba56678fa7dc1186e850f5a2dff`:
[bound CI run](https://github.com/AlexandervonWu/ACGN/actions/runs/43797295965).
This is the tested predecessor of the documentation/data-only release update;
that run is not relabelled as an execution on a later commit.

## Assurance Boundary

**Publishing v3 is not blocked.** The internal label `publicCertification:
BLOCKED` describes the stronger, separate claim that a result has a complete
independently checkable evidence chain from original Alloy source, through the
Java implementation and certificate serialization, to the relevant Lean
semantics and exported repair sequence. It is not a GitHub release permission,
a requirement for outside approval, or a count of failing benchmark rows.

The current native comparator checks the `FROZEN_NORMALIZED_IR` boundary.
Its reports explicitly retain `sourceCertificateWireReplayChecked: false`,
`javaLeanCorrespondenceChecked: false`, and `publicSequenceLinked: false`.
Likewise, the legacy `publicationAllowed: false` field denies promotion of that
diagnostic receipt to a public end-to-end certificate; it does not prohibit
publication of accurately scoped measurements. These flags are not changed
by this release.

The remaining scope includes general parser/Java-to-Lean correspondence,
source-certificate wire replay and public-sequence linkage, canonical obligations
for the AST-identical paired predicates, and full cross-reference native-action
coverage. The Augmenter audit validates recorded distances/rankings; it does not
replay every cross-reference action or serialize every nonzero truth-pool pair.
Lean theorems, finite correspondence closures, bounded Alloy checks, and empirical
agreement each support their recorded scope; none proves whole-program or
universal Alloy correctness. Synthetic censored timeouts are not the reason
this stronger certification claim remains open.

## Release Contents

The `v3` tag identifies the released source. GitHub supplies source archives;
the release additionally attaches machine-readable headlines, this research
summary, and a compact archive of all published reports, CSV exports, synthetic
trial rows, plots, and evidence indexes, with SHA-256 checksums.

The compact archive is not the full natural corpus or every bulk execution
trace. Those remain retained at their indexed locations, and the data files
included in this release are explicitly enumerated by checksums. No new
experiment execution or binary rebuild is claimed by the packaging step.
