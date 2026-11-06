# Slot-Typing Ablation

## Controlled Treatment

Compare `slotted-egraph` (untyped slots) with `slotted-egraph-typed`
(parser-derived exact slot types). Both use the same slotted engine, rewrite
inventory, iteration limits, scope renaming, declaration permutation search,
and edit-distance algorithm. Only the latter preserves type colors on variable
leaves, in slot identity, and in admissible slot mappings. This is not the
Certificate-Integrated typed-port arm: neither arm issues semantic certificates.

Declaration domains remain present in both arms. "Untyped" means erasing slot
type metadata, not erasing the Alloy declarations, scope, or operator structure.
Consequently identical corpus equality counts are possible and informative.
Exact type equality is deliberately used, not inferred subtype compatibility.
Missing/unknown parser types reject typed input; `univ` is not a fallback.

## Proof Before Runtime

Run `lean docs/slot-typing-ablation/Model.lean`. The eight axiom-free lemmas
establish that erasure retains scope but can identify differently typed slots,
that typed mappings restrict rather than enlarge an alignment space, and that
identity, composition, and inverse preserve type colors. The abstract model
does not prove Alloy semantic soundness or whole-program Java refinement.

Java correspondence obligations: variable equality/hash/order include the color;
alpha renaming and substitution retain it; slotted interning includes it;
union and symmetry generators preserve it; fallback distance cannot erase it.
Executable regressions exercise these obligations and parsed Alloy witnesses.
The parser's type extraction and the existing rewrite inventory are unchanged
dependencies, not newly proved by these lemmas.

The correspondence is tested, not a machine-checked extraction/refinement of
Java from Lean. The existing finite permutation/rewrite limits and limitations
of the raw slotted baseline remain. This experiment makes no universal
semantic-completeness or certification claim.

## Reproduction

Use a fresh output directory, leaving published snapshots untouched:

```sh
./scripts/run_egraph_ablation.sh --slot-typing --input classified-data \
  --output /tmp/acgn-slot-typing --threads 16 --max-heap 8g
```

Add `--limit 100` for a bounded smoke run. Omit `--slot-typing` to retain the
existing seven-arm study. Use the same flag with `--report-only` to reconstruct
the paired report. Both arm manifests retain the common dataset, source,
resource configuration, and generated-output hashes.

## Bounded Validation

`./scripts/run_slot_typing_ablation_tests.sh` checks all eight Lean lemmas,
compiles the Java sources, runs 28 new slot-typing checks (including parsed
Alloy, shadowing, beta reduction, same-type permutation, and cross-type
negative controls), and runs the existing e-graph ablation regression suite.
All passed on 2026-11-06.

The first 100 sorted natural-corpus inputs and the first 100 capability inputs
were also run through both arms in fresh JVMs with four workers and a 2 GiB
heap. Both arms had zero failures and zero AST-identical skips in each sample.
The natural sample had zero zero-distance pairs in either arm; the capability
sample retained all 100 zero-distance pairs in both. These prefix samples are
functional checks, not representative corpus estimates or speed rankings.
Report-only regeneration was checked for the natural sample.

The final natural smoke output is `/tmp/acgn-slot-typing-final-20261106`, run
`98a19348-8ce2-48d7-8031-86f935567670`; capability output is
`/tmp/acgn-slot-capability-final-20261106`, run
`539d16fd-620a-43e8-b0ef-b0a48daddfee`. Their manifests describe a dirty source
tree. The seven-arm default also completed a two-file regression with zero
failures in every arm (`/tmp/acgn-seven-arm-regression-20261106`). Published
seven-arm results were not rerun or replaced by these checks.
