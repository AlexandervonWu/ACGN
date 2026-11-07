# Final Bounded Slot-Typing Grid

This performance dataset replaces the oversized corpus for the final comparison,
without deleting or changing that corpus or its negative results.

There are 54 cells: every N from 2 through 10, with every M from 1 through N.
Each cell has five seeded paired inputs (270 pairs / 540 predicates total).
Each predicate has exactly N binding occurrences in total, exactly M distinct
parser-derived types, and uses every binder. There are no extra helper binders.

## Allocation and Correspondence

For q = N // M and r = N % M, each type receives q or q+1 bindings. Choose the
r types receiving an extra binding using seeded random sampling, then shuffle
the assignment to variables. This is balanced allocation with randomized
placement, not independent draws that might leave a type empty. All cells receive
equal representation, not a random sample of cells. Seed: 20261107.

BalancedGrid.lean proves the allocation-total identity, positivity under M <= N,
at-most-one difference between loads, remainder bound, and M <= 10. The Python
generator implements the quotient/remainder construction; generator tests check
all 270 instances, and the Java dataset validator independently checks actual
parser counts and histogram balance. This correspondence is tested, not a formal
proof of Python, the PRNG distribution, or the parser.

The five shapes are alpha conversion, Boolean ACI, implication, future temporal,
and inherited past/future temporal references. Structural seeds do not depend
on M, so corresponding cells retain the same graph shape and declaration order.
The partner changes binder names/order while keeping type/domain associations;
ACI and implication partners also use their corresponding equality. Independent
ALL exchange, alpha, ACI, implication, and context laws are in StressSchemas.lean.
No quantifier is moved across a temporal operator. Standard Lean logical axioms
are disclosed by `#print axioms`; no new axioms or proof placeholders are used.

This is controlled performance coverage, not exhaustive Alloy grammar coverage
or fresh solver certification of every instance. Representation completion is
not proof of semantic equivalence. Neither measured slot arm is certificate-bearing.

## Measurement

Run all 540 predicates in both arms: 1,080 isolated JVM trials, eight concurrent
workers, equal 768 MiB heaps, and a 300-second process deadline. Each child uses
one active processor and exits on OOM. This workstation uses an 8 GiB shared
service cap, 6 GiB available-host-memory reserve, and 32 GiB free-disk reserve.
Outputs go to external storage here; portable defaults remain unchanged.

Both arms use uncapped synthetic representation construction. Natural-corpus
measurements use their existing bounded algorithm and remain a separate study.
Pair order is deterministically shuffled, with arm order alternated. Five shapes
per cell are input replicates, not independent repeated timing runs. Concurrent
CPU/cache/GC interference and JVM startup are experimental limitations.

The primary surface has X=N, Y=M, Z=mean log10(untyped/typed engine elapsed time)
for exact matched predicates. Engine time includes adaptation/construction, not
startup/parsing; a secondary surface uses whole-JVM runtime. Z>0 means typed is
faster, and Z=1 means 10x. Equal-weight mean log ratios correspond to geometric
mean speedup. Surface triangles join adjacent measured complete cells only;
there is no smoothing, extrapolation, or replacement of timeouts with 300-second
completion times. A cell enters the surface only when all ten predicates finish
in both arms. Raw statuses, per-cell success rates and successful median/P95
(nearest-rank P95) remain available even for excluded cells.

```sh
python3 scripts/generate_slot_typing_grid.py
python3 scripts/generate_slot_typing_grid.py --check
lean docs/slot-typing-ablation/BalancedGrid.lean
lean docs/slot-typing-ablation/StressSchemas.lean
python3 scripts/run_slot_typing_synthetic.py --dataset synthetic-data/slot-typing-grid \
  --output /path/to/fresh-run --workers 8 --heap 768m --timeout-seconds 300 --seed 20261107
python3 scripts/plot_slot_typing_grid.py --run /path/to/fresh-run --output /path/to/fresh-report
```

Original natural results are final independently of this synthetic schedule.
See `docs/experimental-results/2026-11-07/` for the final reports and evidence index.
