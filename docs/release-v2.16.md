# ACGN v2.16

This is a capability-validation repair release. Canonicalization, repair
metrics, reward computation, e-graph arms and certificate production/replay
are unchanged from v2.15. Their full-corpus measurements are retained.

## Temporal Checks

Alloy 6.1's temporal-mode detector skips predicate/function bodies at calls.
The six generated temporal checks therefore selected a possibly unsound
static reduction. The checker now follows reachable call bodies and, only
when needed, exposes temporal mode with `Q and after true`. No source
predicate, signature, scope, binder or rewrite inventory is changed.

Five constructive Lean theorems prove this guard under total infinite-trace
semantics. The existing six temporal duality proofs are also recompiled.
Errors, missing solutions and inconclusive temporal checks now fail the
runner instead of being exempted by their family label. Reports retain the
actual scope and temporal bounds.

The [incident and bounded evidence](temporal-capability-solver/README.md)
record 95 regression assertions in each of two fresh builds, identical Java
classes, Lean objects and sample CSVs, a passing independent review, and 46
broader bounded Java entry points plus the artifact-regeneration smoke test.
The full deterministic sample has 29 checks, zero counterexamples, zero
errors and zero inconclusive results. Eight commands use temporal solving;
the six repaired cases use overall scope 4 and trace bounds 1 through 10.
This is bounded solver evidence, not an unbounded semantic proof.

## Validation Publication

`scripts/refresh_capability_validation.sh` refreshes validation only. It
requires a clean worktree, freezes one freshly compiled JAR, copies the
selection metadata and proof inputs, and uses the existing publication
manifest tool for source/dependency/dataset identities, command receipts,
report bindings and generated-output hashes. Its manifest has one stage,
`capability-validation`, not a new four-stage corpus experiment.

```bash
./scripts/refresh_capability_validation.sh /tmp/acgn-v216-validation
```

The public release records the completed validation run, clean validation
source commit, final packaging/tag commit, exact-commit CI, and asset hashes.
The attached JAR contains the repaired checker and is the same JAR used by
that validation. It is not presented as the result-producing JAR for the
unchanged full-corpus measurements.

## Preserved Results

The result-producing source for the full-corpus data remains
`8ad5fead39b687d2cadc79b01ac27743c1ece990`, publication run
`db9f89bf-0965-4d74-8080-d9191d5f1aec`. Its original JAR, manifests and all
5,808 imported output files remain byte-for-byte unchanged. Validation is
published separately rather than mixed into that frozen run.

Certificate coverage remains fixture-scoped: 1 VERIFIED, 2 UNCHECKABLE,
0 REJECTED. No new authority is admitted. The broader assurance matrix
remains incomplete; the temporal-check repair is not a new blanket closure.

## Next Work

The [next five bounded candidates](obligation-repair/next-candidates-v2.16.md)
are P3-04, P3-05, P3-06, P3-12 and A2-12. Their original ledger status and
claim statements are preserved, with explicit proof and correspondence
deliverables. P1-19 and A-01 retain their independent prerequisites.
