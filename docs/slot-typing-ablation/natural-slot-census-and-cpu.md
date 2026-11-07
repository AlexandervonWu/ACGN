# Natural-Corpus Slot Census and CPU Investigation

## Next-Run Measurements

The existing `--slot-typing` command now records two distinct populations:

- **Source slots:** one count per binding occurrence in each selected predicate,
  including parameters, quantified formulas, comprehensions, and let bindings.
  Unused bindings count; repeated usages do not. Shadowed and sibling-scope
  declarations count separately even when names match. Temporal usages of an
  outer binder do not introduce extra source bindings. Calls are not expanded.
- **Interface slots:** sum of live/root e-class interface arities after comparison.
  These are the existing engine `slots` statistic, now with a type histogram.
  A source binding can be represented in multiple interfaces; this is not a
  count of unique source variables.

Only successful AST-distinct pairs contribute. Student and oracle source counts
are separate in `pairs.csv`, together with their exact-type histograms. Type
labels use `ExactAlloyType` and preserve relation arity/union information. A
missing source type is explicitly `<unknown>`, not coerced to `univ`. Untyped
interface slots are `<erased>` because that arm intentionally discards colors.
Both arms retain identical parser-derived **source** histograms as observations;
these observations do not feed the untyped engine or its matching decisions.
Type names from different files are local labels, not evidence that their
signatures belong to a common semantic universe.

Outputs:

- Each arm's `pairs.csv`: `leftSourceSlots`, `rightSourceSlots`,
  `leftSourceSlotsByType`, `rightSourceSlotsByType`, `interfaceSlotsByType`,
  `adapterCpuNanos`, and `comparisonCpuNanos`, appended after existing columns.
- Each arm's `summary.json`: `slotCensusPairs`, student/oracle/total source slots,
  source/interface histograms, total interface slots, and both CPU components,
  overall and per problem/status group.
- Combined `comparison.json`: `slotObservations` for each measured arm.
- Combined `summary.md`: source/interface totals, slots per type, and the CPU
  breakdown. Older reports without observations say unavailable, not zero.

The paired reducer rejects inconsistent aggregate source counts/histograms.
The graph counter checks that its per-type histogram sums to the existing slot
total. Source census is collected **after** engine timing. It still contributes
to total task/process time. Adapter and comparison CPU are nested components of
engine CPU, not additional costs to add to it. Comparison includes graph
construction, rewriting, matching, and structural-statistics collection; it is
not a saturation-only timer. New histogram bookkeeping itself has a cost, so
compare equally instrumented arms in future runs. Existing unsupported CPU-clock
handling is unchanged; use a JVM with worker-thread CPU measurement enabled.

No rewrite, alignment, pruning, certificate, or resource-limit semantics change.
The existing slot-typing Lean model remains unchanged; arithmetic partitions,
scope-counting examples, and reporting are checked by executable regressions.
This does not claim a Lean refinement proof of the new observation code.

## Evidence From the Completed Natural Run

Input: `acgn-full-20261106T204318Z-resume01/results/slot_typing_natural`.
Both arms completed 61,598 eligible pairs with 4,482 AST-identical skips and
zero failures. These retained outputs predate the new census/timing components.

- Engine CPU: untyped 14.972800952 s; typed 20.064835315 s, **34.01% more**.
- Mean rewrite rounds: 2.8850 versus 3.8566, **33.68% more**.
- Pairs reaching 32 rounds: 2,689 versus 4,680. Reaching the limit is a diagnostic,
  not by itself proof that further semantic progress remained possible.
- Mean e-classes: 50.5113 versus 51.4497, **1.86% more**.
- Mean interface slots: 36.7264 versus 37.8834, **3.15% more**.
- Mean rewrite applications: 16.5768 versus 17.8979, **7.97% more**.
- The 2,527 pairs with different round counts account for 3.3100 s of the
  5.0920 s aggregate CPU increase (65.00%). This association is not causal
  attribution of every nanosecond.
- Parsing dominates: 149.404 versus 148.446 worker CPU seconds. Whole-process
  wall time is almost unchanged: 19.770 versus 19.810 seconds.

This is one run per arm in fixed order, with no repeated or balanced-order
timing experiment. It establishes observed work differences, not a stable
hardware-independent speed ratio. No additional full-corpus timing run was
started during the active synthetic benchmark for this investigation.

## Concrete Repeated-Work Witness

`classified-data/socialMedia/under/x9CXb8pLEAhJgTSFk_inv5.als` contains:

```alloy
all u: User, i: Influencer | i in u.follows or i = u
```

Here `Influencer extends User`. The untyped arm finishes after one rewrite round;
the typed arm records 32. A bounded probe of the actual adapter/rewrite/alpha
pipeline shows:

```text
untyped: round 0 applications=6, frontier changes
         round 1 applications=0
typed:   round 0 applications=6, frontier changes
         round 1 applications=1, canonical frontier UNCHANGED
```

The two normalizers choose conflicting deterministic orderings:

1. `AlloyRewriteSystem` sorts commutative operands using `AlloyTerm.compareTo`,
   where the variable atom/name precedes its type. Equality becomes
   `EQUALS(@free:0:User, @free:1:Influencer)`.
2. `SlotCanonicalizer.sortCommutative` compares local slot keys. Both single
   variable operands have local name `@local:0`, so type breaks the tie and
   reverses the equality back to
   `EQUALS(@free:1:Influencer, @free:0:User)`.
3. `SlottedEGraph.compare` stops when the rewrite application's count is zero,
   not when the rewrite-plus-alpha frontier is unchanged. It repeats the same
   work until the 32-pass bound. In the untyped version the local keys tie and
   the ordering becomes stable.

This is a demonstrated scheduling inefficiency, not evidence that equality's
commutativity is unsound. The source witness, unchanged frontier, and distinct
sort keys support the diagnosis independently of wall-clock measurements.
The probe source is `/tmp/SlotRoundProbe.java`; it was run against the frozen
continuation JAR, not the newly instrumented implementation.

## Other Costs and Next Optimization

Types also add per-variable-occurrence `ExactAlloyType` extraction/serialization,
type-bearing term hashing/comparison, per-class color arrays, and color/coverage
checks in union. More distinct type-bearing shapes slightly enlarge the graph.
These are supported code paths, but this run has no separate measurements to
quantify their individual CPU contribution. The new adapter/comparison timers
will distinguish the first cost from the rest.

The current declaration permutation search is declaration-local and does not
prepartition candidate groups by type. Alloy variables in one declaration share
a domain already, so type metadata does not automatically deliver an n! search
reduction. It is incorrect to promise that typed slots must always be faster.

The subsequent requested repair is implemented and documented in
[typed-pass-repair.md](typed-pass-repair.md). The evidence above describes the
pre-repair run; no retained measurements have been overwritten.
