# Supervised Full-Corpus Rerun

## Frozen Run Policy

The next run uses the committed independent-bind-block implementation. Natural
corpus stages and every corresponding ablation arm use 16 workers, a 6 GiB JVM
heap, and reward pools of 100 where applicable. Stages run serially:

1. CanonicalBatchTest, retaining Fast Rewrite IR and Certificate-Integrated IR.
2. Alloy4FunAugmenter, with AST-identical exclusions before reference pools.
3. Seven-arm ablation followed by its bounded semantic checks.
4. Capability generation, bounded soundness checks, seven arms, and reporting.
5. Paired natural-corpus untyped/typed slot ablation, including slot/type counts.
6. Full synthetic representation benchmark: 500 predicates, two arms, 1,000
   trials. Each trial has uncapped permutation enumeration and a 300-second
   deadline. One isolated JVM runs at a time with a 4 GiB heap. Median and P95
   use successful trials; timeouts and OOMs remain in the success denominator.

Natural expectations are 66,080 inputs, 4,482 AST-identical exclusions, 61,598
eligible comparisons, and 42,386 incorrect candidates. Capability recovery for
the two canonical paths must remain 5,500/5,500. Baseline incompleteness is
reported separately from execution failure. Explicitly inconclusive temporal
solver checks are retained as inconclusive, never promoted to proof.

## Workstation Safety

This workstation keeps run intermediates and new results on the attached
external drive. A machine-local supervisor under `.git/local-tools/` freezes
its own source into the external run, builds a new JAR from a clean commit,
and uses the existing publication manifest implementation for identity and
output hashes. The machine-local storage policy does not change portable
runner output defaults. Shell build scripts now honor `TMPDIR`.

The service is limited to 8 GiB total memory with no swap. Launch requires
14 GiB host `MemAvailable`; subsequent monitoring stops the run below a 6 GiB
reserve, on a new host OOM kill, on loss/change of the external mount, or below
32 GiB external / 10 GiB internal free space. Logs and status remain external.
The supervisor stops on nonzero exits and failed result gates before advancing
to the next stage. Synthetic deadline/OOM outcomes are measured outcomes;
unexpected synthetic execution errors stop the schedule.

The new full run is not a completed result at the time of this pre-run snapshot.
Only completed, validated outputs may replace published reports. Historical
empirical files are not overwritten by the supervisor.

## Preflight Portability Findings

- The public certificate regression used `fixed:FORBID` in a temporary filename.
  exFAT rejects the colon. Only its test filename now replaces colons with
  hyphens; fixture identity, wire fields, and certificate semantics are unchanged.
- The fresh-JVM determinism regression merged diagnostic stderr with its digest
  result. Java's `JAVA_TOOL_OPTIONS` banner then broke strict parsing. Child
  stderr is now inherited separately; stdout remains strictly parsed and a
  nonzero child exit still fails the test.
- The local supervisor's bounded controls exercise successful summaries,
  changed/missing count rejection, an incomplete then completed failure record,
  low-memory/disk guards, and an increased OOM counter (27 checks). Three
  subprocess controls additionally confirm nonzero-exit rejection, failed-gate
  rejection, and resource-stop child termination (30 controls total).

Lean and implementation correspondence for the bind-block transformation are
documented in [independent-binding-blocks.md](independent-binding-blocks.md).
The final preflight completed the 54-main bounded Java runner and distance
artifact regeneration, the slot-typing suite, and the synthetic suite. Counts
include 1,227,116 permutation assertions, 45 binding checks, 66 rewrite-order
checks, 40 slot-ablation checks, 18 synthetic checks, and 12 Python harness tests.
All five slot-typing Lean files compiled. The successful logs are
`bounded-ci-v3.log`, `slot-tests.log`, and `synthetic-tests.log` in the external
`full-rerun-preflight-20261106/logs/` directory; the preceding two failed logs
are retained to document the portability findings. The supervisor copies these
logs into the run artifacts. This is bounded preflight evidence, not a claim
that the full corpus has completed.
