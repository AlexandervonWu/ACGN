# Typed versus untyped binding stress corpus

## Population and purpose

This synthetic dataset contains **250 comparison pairs, or 500 target
predicates**, in 250 self-contained Alloy files. A separate `probes/` directory
contains 25 reduced companion pairs for validation; it is not benchmark input.
Each file defines `stressNNNN` and `stressNNNNC`, compatible with the existing
ablation runner's pair selection and AST-identical exclusion.

There are 25 families at ten size profiles: 8, 16, 32, 64, 96, 128, 160, 192,
224, and 256 outer bindings per predicate. Homogeneous controls use one type;
other profiles use two, four, or eight distinct parser-derived types. Every
outer variable is referenced in cyclic relational constraints and in one
shared n-way intersection atom. The latter keeps a joint binding dependency
instead of only separable pairwise conjuncts. These are not long lists of unused
binders that normalization can simply delete.

The 210 positive pairs cover alpha conversion, same-type permutations within
long disjoint groups, declaration grouping, independent ALL-block exchange,
Boolean ACI, implication/IFF/conditional expansion, let beta reduction,
function inlining, relational algebra, comprehensions, cardinality quantifiers,
integers/sequences, dependent domains, shadowing, and temporal contexts.
Heterogeneous alpha cases include long alternating ALL/SOME prefixes.

The 40 negative pairs distinguish cross-type slot swaps, disjointness groups,
alternating quantifier order, and inherited temporal endpoints. Their directory
label `NEGATIVE` means **expected non-equivalence**, not an Alloy4Fun student
correctness classification. The reference is a comparison partner, not a
claimed oracle for an external specification.

## Grammar boundary

Inputs use Alloy 6.2 syntax, not a reduced Boolean-only DSL. They include
module/open/fact/signature/predicate/function/assert/check/run declarations;
extends and subset types; mutable signatures and fields; scalar, set, lone,
and sequence binding domains; arithmetic, comprehensions, relation products,
join, restriction, override, transpose and both closures. All ten temporal
formula operators are exercised: always, eventually, after, historically,
once, before, until, releases, since, and triggered, plus expression prime.

This is **broad feature coverage, not exhaustive coverage of every grammar
production or every feature combination**. In particular, second-order
domains can be valid Alloy syntax while an engine or bounded solver does not
support their execution. Such outcomes must be reported, not silently removed.
Explicit `univ` occurs only in a relational-algebra feature example, not as a
replacement for missing type information.

## Labels and validation

`manifest.json` records each path, source hash, expected equality, family,
binding count, type histogram, non-vacuity size requirements, and features.
It also records log-factorial permutation envelopes. These are combinatorial
upper envelopes, not measured search counts, admitted symmetry groups, or
runtime predictions. Declaration/scope restrictions remain in the untyped arm.

`StressSchemas.lean` in `docs/slot-typing-ablation/` checks ten general laws
supporting the positive constructions. It uses standard Lean classical axioms
for classical implication normalization; it declares no new axioms and has
no proof placeholders. Temporal examples use alpha/context congruence; they
do **not** move quantifiers across temporal operators. The Lean model does not
prove the generator or Java implementation correct.

Validation checks every long pair's parser/type acceptance, exact outer-binder
and distinct-type counts, usage of every outer variable, and source hash.
The bundled parser also exercises the repository AST adapter and verifies that
no pair is AST-identical. Native validation separately exercises the stock Alloy
distribution. The subsequent dependency refresh upgraded the bundled runtime
from 6.1 to 6.2 and added source compatibility overlays for the repository adapter;
see `docs/dependency-refresh-2026-11.md` for the upgraded checks.

The 25 reduced probes retain four outer bindings. The validator runs bounded
equivalence checks on 23; `integer_sequence` and `dependent_shadowing` are
parse/type-checked but retain schema-only semantic expectations because of
their relational second-order domains. Successful bounded checks are not
unbounded proofs, nor solver certificates for the corresponding long models.

Long disjoint blocks need enough atoms in each type to avoid vacuity. The
manifest records these minima. Default Alloy commands are illustrative small
scopes, **not** evidence of non-vacuous long-prefix equivalence. Do not label a
long disjoint case equivalent merely because an undersized check returns UNSAT.

## Reproduce

Initial, pre-dependency-refresh validation on 2026-11-06 is in `validation/`: 250/250 long pairs
accepted under Alloy 6.2.0 and 250/250 under the bundled 6.1 parser/AST adapter;
zero AST-identical pairs; all outer bindings present and used. All 23 bounded
solver probes matched their labels (19 UNSAT equivalence checks, four SAT
counterexamples); two second-order probes were explicitly not solver-checked.
All ten Lean theorems checked. `SHA256SUMS` covers the 250 target models and
25 reduced probes. This records input validation, not rewriting performance.

From the repository root:

```sh
python3 scripts/generate_slot_binding_stress.py --check
./scripts/validate_slot_binding_stress.sh synthetic-data/slot-binding-stress /tmp/slot-stress-validation
```

Set `ALLOY62_JAR` to a local Alloy 6.2.0 distribution JAR if it is not in the
default Maven cache location. No download or internet connection is required.
Validation uses a 2 GiB heap, 16 MiB Java stacks, and a 60-second process timeout
for each reduced solver probe. A timeout is a validation failure, not a PASS.
Generation is deterministic with seed `20261106` and refuses to overwrite
changed files. Use `--output /tmp/new-slot-corpus` to generate independently.

## Later rewriting benchmark

The controlled arms are `slotted-egraph` and `slotted-egraph-typed`. Both keep
declarations and scopes; only slot type colors differ. Use `models/`, never the
dataset root (which also contains validation probes). Start with a smoke run:

```sh
./scripts/run_egraph_ablation.sh --slot-typing \
  --input synthetic-data/slot-binding-stress/models \
  --output /tmp/slot-binding-smoke --limit 10 --threads 4 --max-heap 4g
```

Then run all 250 pairs in both arms:

```sh
./scripts/run_egraph_ablation.sh --slot-typing \
  --input synthetic-data/slot-binding-stress/models \
  --output /tmp/slot-binding-full --threads 16 --max-heap 8g
```

Use fresh output directories. Join arm rows to the manifest by path relative
to `models/`. Report missed equalities and false merges separately, by family,
binding size, and type count; retain parse/engine failures and resource-limit
outcomes in denominators. A zero-distance count alone is not an accuracy score.
The new rewriting performance benchmark has not been run during dataset creation.
