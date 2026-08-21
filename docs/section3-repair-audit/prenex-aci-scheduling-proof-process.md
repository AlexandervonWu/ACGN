# Prenex ACI Scheduling Proof Process

## Status

`REPAIRED/PENDING IMMUTABLE REVIEW`. The prenex allocation portion covers
GC-F32 and is partial evidence for P5-14. The temporal phase-presentation
portion covers GC-F33 and is partial evidence for G-05. Neither discharges its
broader claim.

## Located Fault

The prenex allocator previously consumed the binary parse association before
ACI normalization. Under `AND`, a same-carrier existential sibling can make a
universal prefix safe on an empty carrier; under `OR`, the dual universal
sibling can make an existential prefix safe. Source order therefore decided
which binders moved during the first pass. A later pass used a fresh slot
allocator, so an equivalent permutation could retain an extra slot.

The bounded witnesses were three-branch `AND` and `OR` formulas over one
signature. SAT4J found their source and normalized formulas equivalent, while
the old canonical observations differed by 2. Guarded-domain variants differed
by 3.

## Repair Contract

1. Before each prenex pass, recursively flatten only a child with the same
   `AND` or `OR` head.
2. Preserve operand order and duplicates. Do not apply commutativity,
   idempotence, or any relational law at this stage.
3. Treat quantifiers, temporal nodes, and every unlike operator as barriers.
4. For allocation only, visit directly liftable `SOME` branches first under
   `AND`, and directly liftable `ALL` branches first under `OR`.
5. Store rewritten children in their original source positions.
6. Never infer an enabling relationship across a different primitive carrier.

## Formal Evidence

[`formal/PrenexAciScheduling.lean`](formal/PrenexAciScheduling.lean) proves:

- `some_before_all_and`: the same-carrier existential-before-universal prefix
  order preserves conjunction, including the empty carrier;
- `all_before_some_or`: the same-carrier dual prefix order preserves
  disjunction;
- `schedule_preserves_membership`: allocation scheduling drops no child;
- `schedule_preserves_length`: allocation scheduling duplicates no child;
- `different_scope_paths_separate_shadowed_bindings`: a scope-qualified
  binding coordinate cannot equal a coordinate from another scope path; and
- `same_spelling_does_not_override_scope_identity`: identical source spelling
  does not erase that distinction.

The proof is an abstract logical contract. It does not prove Java refinement,
cross-carrier scheduling, temporal separation, dependent-domain extraction, or
the complete P5-14 truth table.

[`formal/TemporalAciPhasePresentation.lean`](formal/TemporalAciPhasePresentation.lean)
models the independently ordered phase keys for the exact two- and three-phase
adversarial bounds. It proves that all tested ACI permutations receive one
coherent phase/owner/reference presentation and zero abstract projection
distance. It separately proves that swapping the two roles of an ordered
binary temporal operator remains observable. This finite model does not prove
that Java `StructuralKey` is a total order over all producer values or that all
certified equalities have zero metric distance.

## Direct Conformance Evidence

`AlloySourceRuleRegressionTest` contains the permanent conjunction,
disjunction, temporal-sibling permutations, and four parameter-versus-local
shadowing cases across implication and IFF. It checks bounded SAT equivalence
to the source, canonical equality where asserted, and zero repair distance.
On the repaired bytes it passes 332 checks. The temporal checks use a separate
variable-signature module through four steps, so they do not accidentally run
under Alloy's static-model semantics.

The independent temporary adversary rechecks six reordered pairs, including
guarded domains. All six report certified equality and distance zero, and its
source-versus-normalized SAT checks find no counterexample through scope 3.

## Reproduction

```bash
/home/augustus/.elan/bin/lean \
  docs/section3-repair-audit/formal/PrenexAciScheduling.lean

/home/augustus/.elan/bin/lean \
  docs/section3-repair-audit/formal/TemporalAciPhasePresentation.lean
```

Compile the Java sources into a fresh class directory with Java 17, UTF-8,
`-Xlint:all -Werror`, and the repository `lib/*` class path, then run:

```bash
java -ea -cp '<fresh-classes>:lib/*' \
  is.fivefivefive.CanDis.AlloySourceRuleRegressionTest
```

## Remaining Obligations

- Fresh independent review must attempt reordered mixed quantifier chains,
  different primitive carriers, dependent domains, disjoint declarations,
  nested unlike Boolean regions, and temporal barriers.
- Java-to-Lean refinement is bounded by the named regressions, not universally
  proved.
- Equal-key temporal occurrences, nested ACI/ordered mixtures, all binary
  temporal operators, and larger phase sets remain explicit falsification
  targets.
- The observed raw-source-alias collision is repaired and directly guarded,
  but P5-14 remains blocked until complete alpha/De Bruijn resolution,
  exact-cardinality, guarded truth-table, and implementation-refinement
  conjuncts are split and closed.
