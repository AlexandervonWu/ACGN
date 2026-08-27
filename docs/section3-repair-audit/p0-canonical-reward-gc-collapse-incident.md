# P0 Canonical Reward GC-Collapse Incident

## Symptom

The rewarded full-corpus `CanonicalBatchTest` run under
`/home/augustus/acgn-luna-full-20260827T072427Z` slowed near item 62,144 of
66,080 while using 32 scheduling workers, a 4 GiB heap, and reward pool 100.
Luna deliberately killed PID 789776 after collecting diagnostics. The JVM did
not independently report `OutOfMemoryError`.

## Live Evidence

The two retained diagnostic windows establish sustained full-GC collapse:

- used heap remained between 4,174,354 KiB and 4,180,073 KiB of 4,194,304 KiB;
- old generation remained between 99.95% and 100%;
- full-GC count increased from 1,874 to 2,254 over approximately 212 seconds;
- full-GC time increased from 989.448 to 1,197.972 seconds, consuming 98.4% of
  that wall-time interval;
- only 17 additional files completed while the active set remained between 40
  and 60 tasks;
- the thread dump contained all 32 workers: 18 in Rewarder/SAT work, 13 in
  certificate-integrated preparation, and one in other batch work;
- no deadlock was reported; process CPU was approximately 2,180% because G1
  full collection and surviving workers used many cores;
- the killed writer left `distances.json` unterminated, so the run is not a
  reportable partial result.

This is GC-bound in-flight working-set amplification. It is not a one-task
tail, a deadlock, ordinary productive CPU saturation, or corpus-sized result
retention. `CanonicalBatchTest` streams JSON, retains aggregate summary
counters, and bounds submitted work to four tasks per requested worker. A
reward-free 32-worker replay on the same repaired pipeline completed all
66,080 files with zero failures, which also distinguishes this incident from
the earlier static MASG sentinel leak.

## Root Cause

Each source task previously performed certificate-integrated graph
construction and then generated up to 100 positive and 100 negative Alloy
solutions for Rewarder without a shared memory budget. At the captured point,
both phases occupied all scheduling workers concurrently. Their live parser,
graph, solver, and `A4Solution` working sets collectively filled old
generation. Increasing CPU utilization could not recover space because the
objects belonged to still-running tasks.

## Repair

`CanonicalBatchTest` now uses one fair, heap-derived semaphore for both
memory-intensive phases. Both experiment drivers use one shared budget:
384 MiB per active phase, a 512 MiB reserve, at most 16 active phases, and no
more than the requested worker count. A 4 GiB JVM therefore schedules 32
ordinary workers but permits at most nine certificate/reward phases at once.

Distance preparation was extracted into a helper scope. Its proof graphs and
prepared observations become unreachable before the task acquires a permit
for Rewarder. JSON ordering, metric minimization, certificate checks, reward
pool size, and SAT queries are unchanged. Generated JSON and Markdown record
the effective memory-intensive limit and maximum heap.

The augmenter already used this heap calculation for certified construction,
but its later reward-only stage still created the full requested 32-worker
pool. That reachable recurrence is closed by sizing only the reward executor
to the same heap-derived limit. Its reports record the requested thread count,
effective reward-worker limit, and maximum heap separately.

This is an operational resource claim, not a new semantic equality. It does
not require or justify a semantic Lean theorem. Semantic regression suites
remain the authority for unchanged canonical and reward results; the new Java
test pins only the deterministic resource calculation.

## Run Disposition

The supervised run is genuinely failed and must not be resumed or published.
Its diagnostics should be retained, but its partial JSON is invalid. The next
attempt must rebuild from the repaired source and restart at Stage 1 in a new
run root.
