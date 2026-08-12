# Canonical Memory Attribution

- Deterministic seed: `55520260811`
- Requested sample size: 2000 files
- Normal-path explicit GC: none
- Separate post-run diagnostic GC: enabled
- Cross-worker output mismatches: 0

The phase hooks are opt-in and no-op in production. Heap is process-global, so phase-boundary samples under concurrency are attribution evidence rather than per-object retained-size measurements.

## Worker Scaling

| Workers | Successful / selected | Wall s | Throughput | Process CPU s | Max RSS MiB | Peak heap MiB | Before clear MiB | After clear MiB | Post-GC MiB |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 1887 / 2000 | 3.533 | 534.132 | 16.170 | 606.547 | 299.643 | 153.606 | 153.617 | 82.768 |
| 8 | 1887 / 2000 | 1.040 | 1813.632 | 20.100 | 1122.309 | 553.391 | 221.913 | 221.913 | 82.742 |
| 32 | 1887 / 2000 | 1.045 | 1805.584 | 25.490 | 1083.539 | 544.259 | 410.354 | 410.371 | 82.739 |

## Structural And Scratch Proxies

| Workers | AST nodes | MASG vertices / edges | Max normalized nodes | Canonical size | Eclasses / enodes | Metadata entries | Scratch allocated MiB | Largest scratch KiB |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 85365 | 46708 / 74144 | 49158 | 54411 | 45118 / 45356 | 45066 | 1.721 | 1.305 |
| 8 | 85365 | 46708 / 74144 | 49158 | 54411 | 45118 / 45356 | 45066 | 1.721 | 1.305 |
| 32 | 85365 | 46708 / 74144 | 49158 | 54411 | 45118 / 45356 | 45066 | 1.721 | 1.305 |

## One-Worker Phase Attribution

The one-worker run gives the least-confounded phase deltas. Positive heap delta is allocation pressure observed between paired begin/end hooks; objects can die before collection.

| Phase | Samples | Total phase s | Avg phase ms | Positive heap delta MiB | Max single delta MiB |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-ast | 2000 | 2.965 | 1.482 | 3065.100 | 9.000 |
| masg | 1887 | 0.154 | 0.082 | 124.966 | 1.000 |
| normalize-temporal-skeleton | 3774 | 0.061 | 0.016 | 69.191 | 1.000 |
| normalize-saturation | 4152 | 0.053 | 0.013 | 58.946 | 1.000 |
| normalize-alpha-beta-branch | 4152 | 0.049 | 0.012 | 222.810 | 1.000 |
| normalize-prenex | 4152 | 0.044 | 0.010 | 71.969 | 1.000 |
| distance | 1887 | 0.033 | 0.018 | 7.000 | 1.000 |
| normalize-post-prenex-nnf | 4152 | 0.024 | 0.006 | 149.935 | 1.000 |
| normalize-aci | 4152 | 0.019 | 0.005 | 58.000 | 1.000 |
| normalize-nnf | 4152 | 0.019 | 0.004 | 91.915 | 1.000 |
| canonical-metadata | 3774 | 0.013 | 0.003 | 11.000 | 1.000 |
| normalize-reachable-egraph | 3774 | 0.008 | 0.002 | 9.000 | 1.000 |
| normalize-temporal-negation | 4152 | 0.002 | 0.000 | 4.000 | 1.000 |
| canonical-prepared | 1887 | 0.000 | 0.000 | 0.000 | 0.000 |
| result-bookkeeping | 1887 | 0.000 | 0.000 | 0.000 | 0.000 |

## Diagnosis

- Peak used heap scales by 1.816x from 1 to 32 workers. This is the signature of overlapping parser/MASG/normalization working sets, not a representation-size increase.
- After the timed work and diagnostic GC, retained heap is 15.202% of peak. The peak is predominantly transient allocation/retention until collection.
- Post-GC heap is 82.768 MiB at 1 worker and 82.739 MiB at 32 workers. Its worker independence points to JVM/parser-wide state rather than retained worker-local canonical forms.
- The largest tracked edit-distance scratch buffer is 1.305 KiB; cumulative scratch allocation is 1.721 MiB. This separates temporary DP churn from live canonical graph size.
- Pair results are primitive records and are cleared before diagnostic GC; all worker settings use the same selection hash.
- Cross-worker semantic-output mismatches: 0.

## Full-Corpus Context

The current production canonical arm reports 2846.031 MiB sampled peak heap and 3629.090 MiB maximum RSS. The deterministic subset above isolates how much of that peak scales with concurrent working sets.

## Reproduce

```bash
./scripts/run_canonical_memory_attribution.sh --input classified-data --output canonical_memory --limit 2000 --seed 55520260811
```
