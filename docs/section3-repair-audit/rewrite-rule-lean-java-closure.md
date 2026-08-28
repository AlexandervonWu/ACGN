# Rewrite Rule Lean/Java Closure

## Scope

This record covers the immutable `R0` semantic rewrite vocabulary used by the
Fast Rewrite IR and the shared e-graph ablation engines. It does not claim that
Lean has verified Java bytecode. It establishes a checked correspondence among
the semantic law, its independently compiled Lean theorem, the Java producer
method that applies it, and a bounded executable regression.

The authoritative inventory is
`docs/section3-repair-audit/rewrite-rule-traceability.tsv`:

- 61 semantic rule families;
- 24 shared bootstrap rules, exactly equal to `JavaEgglog.ruleNames()`;
- 37 production-only alpha, binder, and relational rule families;
- 243 referenced Lean declarations, 64 Java methods, and 32 regression entry
  points;
- status `PROVED_AND_CONNECTED` on every row.

## Located Gap

The claim-level requirements matrix grouped many source normalizations under
large Phase 5 obligations. That was enough to locate supporting formal files,
but it did not provide a one-rule-family reverse check. In particular, a Java
method could be named by a broad requirement without declaring which exact
equations it implemented, and the 24 runtime ablation rule names were not
compared mechanically with the formal inventory.

No new semantic rewrite was admitted while closing this gap. The change is a
direct inventory and executable connection for the existing rules, plus
foundational Lean theorems where a Java family previously relied only on a
larger derived theorem.

## Repair

1. `LeanVerifiedRewrite` attaches stable `R0-*` identifiers to each governed
   Java rewrite method.
2. `RewriteRuleTraceability` parses the TSV catalog, resolves every Lean
   theorem, Java declaration, annotation, and regression method, and performs
   the reverse annotation check.
3. The checker requires exact equality between the catalog's 24 bootstrap
   names and the names exported by `JavaEgglog`.
4. The Section 3 assurance runner executes the checker as an independent step
   and runs `RewriteRuleTraceabilityTest` in its Java suite.
5. `Phase5SourceRules.lean` now states the foundational Boolean, temporal,
   quantifier, prenex, ACI, relational-difference, guard, END-erasure, and
   exact single-membership laws used by the catalog.

The first integrated run exposed a source-audit parser defect: a Java
declaration preceded by an annotation array was reported as absent even though
reflection resolved the compiled method. `Section3AssuranceTraceability` now
erases balanced Java annotations before declaration matching, and its fixture
checks an annotation containing both an array and a nested call.

## Verification

The focused closure run produced:

```text
R0 rewrite-rule traceability
rules=61
baselineRules=24
failures=0
```

Lean 4.33.0 compiles `Phase5SourceRules.lean`, and the governed formal tree has
no `sorry`, `admit`, `axiom`, or `unsafe` token. The focused Java run passes:

- `AlloySourceRuleRegressionTest`: 332 checks;
- `EGraphSaturationTest`;
- `CanonicalAlloyPipelineTest`;
- `MASGVisitorTypeRegressionTest`;
- `EGraphAblationTest`;
- `RewriteRuleTraceabilityTest`: 61 families, 24 bootstrap rules, zero
  correspondence failures.

The complete bounded assurance runner then executed 64 steps with zero
executable failures. Its outcome remains `INCOMPLETE`, not `PASS`, because the
pre-existing broader Section 3 matrix deliberately reports 212 open
traceability diagnostics outside this rewrite-rule closure. Evidence is under
`/tmp/acgn-rewrite-rule-assurance-20260827-v3` for this working-tree run; it is
not a publication result directory.

## Exact Claim Boundary

The Lean theorems prove the equations under their stated mathematical
assumptions. The annotation/catalog gate proves that the named Java and test
declarations are present and mutually linked. Parser-backed positive and
negative regressions test the Java guards on bounded witnesses. This evidence
does not constitute a proof that arbitrary Java execution refines Lean, nor
does it close unrelated open diagnostics in the broader Section 3 assurance
matrix. Those obligations remain visible instead of being silently promoted.
