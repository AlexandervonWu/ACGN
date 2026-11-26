# Proven Rewrite Rules

The catalog groups rules by their mathematical justification, not by where they
may be used. Each entry names its scope and Lean source anchors. Looking up an
entry does not establish that its premises hold for a particular Alloy term.

- **During normalization:** `R0-BIND-003` moves a universal quantifier through
  `always` when its domain is static and the existing source, binder and phase
  checks succeed. It is unsound in general to do this for a changing domain.
  The implementation and the default v3.1 distances are unchanged.
- **For one fixed command:** `fiber` reads a selected row or column;
  `difference` recognizes bounded relation differences; `role` and `mixedRole`
  recognize selections constrained by owner and role; `classifier` recognizes
  threshold and witness formulations of the same classification. Each reader
  checks its own typed source shape. Cardinality, width, temporal frames and
  carrier bounds are taken from the actual command where required. A match for
  one command cannot be used as a global normalization rule.

## Use

No flag is required in the source-aware pipeline. `CanonicalBatchTest` reports
one `commandComparisons` entry per applicable fixed check on the selected
student and oracle. A positive rule result has comparison distance zero
**for that command**; a nonmatch retains the measured structural distance.
An empty list means no applicable check. This does not bypass the batch
runner's structural replay or certification gates.

`Alloy4FunAugmenter` applies the same comparison to the correct-reference
pool, including pairs with different graph sizes. It rebinds the selected
predicates and their local callees, verifying their typed bodies, facts,
imports and effective command bounds. Its default results are
`default_correct_pool_equivalences.jsonl` (pair decisions) and
`default_correct_pool_counts.json` (counts by question set and invariant).
`NO_COMMON_COMMAND` is distinct from `NO_RULE_MATCH`; a pool with a missing
common command does not receive a complete scoped component count.
Structural distance reports and incorrect-predicate rankings keep their
original meaning.

From the repository root, with JDK 17 and Bash:

```sh
bash scripts/proven-rules.sh list
bash scripts/proven-rules.sh check classified-data/trainStationNew/correct/2j59AQ2mBXJ3HFHRu_inv5.als correct
```

The second command checks the named assertion and prints JSON: the two
predicate names, parsed source hashes, width, trace bounds, native outcome and
matching rule IDs. It requires an equivalence of two local nullary predicates.
It does not rewrite the source. Both orientations must produce the same witness;
a native SAT counterexample contradicting a match is an error. Native UNSAT
alone is **not** a rule match. An unmatched equivalence is not proof of
inequivalence.

The command compiles into a temporary directory and uses a separate JVM with
the call-aware parser and solver. In production the source comparison uses
the Analyzer's scope computation without SAT search to test rule premises;
it runs the native solver only for a proposed match. Ordinary graph-only
Fast Rewrite does not invoke this comparison or a certificate search. For repeated calls, compile once with
`bash scripts/proven-rules/build.sh /path/to/new/classes` and run
`is.fivefivefive.CanDis.augmentation.ProvenRulesCommand` with that directory
first on the classpath, followed by `lib/*`.

## Verification

`bash scripts/proven-rules/test.sh` runs source-positive and negative controls
and compiles the release theories with the repository's pinned Lean toolchain.
It inventories theorem constants from the compiled modules and rejects local
axiom declarations and dependencies other than the named standard foundations
(`propext`, `Quot.sound`, `Classical.choice`). This is not a general proof that
the Java reader implements Alloy semantics. The [pooled study](experimental-results/2026-11-25/README.md)
separately records what the implementation did on actual inputs.

`bash scripts/run_bounded_ci_java_tests.sh` exercises both default runners
against original natural examples using the production parser. To check the
entire correct-reference pool, run
`bash scripts/proven-rules/replay-default-pool.sh`. It verifies the sealed
ledger and structural baseline, rebinds all 4,496 original reference sources,
and compares current rule decisions with both recorded orientations of all
132,032 pairs. It does not rerun structural distances or incorrect rankings.
