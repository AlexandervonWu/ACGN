# Minimal source-local cardinality expansion

Executed 2026-10-17 UTC (2026-10-16 America/Chicago). Base `aislop` commit:
`7c4d66c13820462053f07560a06c785b2b9421ee`.

This is an executable deterministic candidate-coverage experiment, not a new
learning result. The original 104-input audit, historical experiments, Lean
models, frozen evidence and search baselines are unchanged.

## Scope and actual result

| Metric | Result | Meaning |
|---|---:|---|
| Historical whole-predicate grammar | 0/104 | Original result remains unchanged |
| New local shape coverage | 4/104 | Four previously loaded, grammar-rejected inputs match the new shape |
| Proposed single edits | 12 | Three alternatives for each matched input |
| Legally committed edits | 12/12 | Existing Java parser/type/scope checks plus source-AST preservation guard |
| Full-predicate candidate checks | 12/12 | All conclusive: eleven counterexamples and one bounded acceptance |
| Actual repaired inputs | 1/4 attempted | One distinct input returns closed `SOLVED_WITHIN_PROFILE` |
| Other inputs | 91 + 9 | 91 shape refusals and nine unchanged `GENERICRELDECL` load refusals |

All four matched inputs belong to the original **train** split. The one repaired
input is one of the original 104 IDs; this is not held-out generalization. The
remaining 100 inputs did not undergo candidate repair checks. It would be wrong
to describe them as 100 failed repair executions, or to describe 4/104 grammar
support as four successful repairs. The current scope is deliberately small.

| Input | Original operator | Alternatives checked | Repairs |
|---|---|---|---:|
| `be563a3a9ebe9062107c` | `no` | `one`, `lone`, `some` | 0 |
| `ae1005bc105b6803a89e` | `no` | `one`, `lone`, `some` | 0 |
| `9a4a7746df4e4f77a4e7` | `some` | `no`, `one`, `lone` | 0 |
| `c44a0fb82108da00c1a0` | `some` | `no`, `one`, `lone` | 1 (`one`) |

The repaired source is:

```alloy
// Before
all x : Photo | some posts.x
// After: one local operator change, quantifier and operand preserved
all x : Photo | one posts.x
```

Acceptance is bounded by the existing `run {} for 3` evaluation profile. It
is neither an unbounded equivalence proof nor a claim about natural Alloy
repair in general. The first input in the audit (`all n : Node | no n.*adj`)
was the source-only shape-selection example; all three edits to it still fail.
The successful input was not used to choose candidates or their order.

## Candidate and legality contract

The public source AST must have root `Q:ALL`, exactly one binding and one
declaration, one static phase, and a direct unary body in `NO/ONE/LONE/SOME`
with a relational operand. Both body and operand must have source occurrences.
The candidate list replaces only that unary operator with the other three,
in fixed `NO, ONE, LONE, SOME` order; it is independent of truth labels and
oracle source. No names, identifiers or source strings are synthesized.

Each candidate is bound to the exact source graph and revision. The controller
uses the archived `BEGIN(MATRIX_UPDATE) -> OPERATOR -> COPY -> COMMIT` sequence,
checking each public action head through the existing replay guard. COPY retains
binding scope; COMMIT uses `FeedbackSourceSpans`, reparses and type-checks the
complete predicate. After COMMIT, all noncanonical source tables must be equal
to their originals except the chosen opcode. A failure stops that candidate.
This is a runtime correspondence check, not a new Lean theorem.

The controller then always calls VALIDATE. `RepairEvaluator.validate` solves
both `context & candidate & !oracle` and `context & oracle & !candidate`, where
candidate is the **entire reconstructed predicate**. Whole-predicate labels are
never repurposed as local labels. Candidates start in fresh sessions and are
not cumulatively applied. No retained-world approximation or Python evaluator
can authorize acceptance. This uses full solver queries rather than an
incremental evidence-consistency prefilter; the historical query budgets and
baseline results are not directly comparable.

## Producer boundary and reproduction

The public branch has the matching JARs but does not expose this Java/Python
producer as ordinary runtime source. The nested archive was obtained and its
outer SHA-256 matched
`257367661fec4b029da476ed9bb7006d32a19e35ed5bd87a30643cba2a86b2ec`.
All **549** manifest entries, including seven JARs, matched. The recorded
producer HEAD was `67cb5f3dfe226b15e2647fe6d18534fa03995cbc` with a dirty tree;
content hashes identify the inputs. The archived Java sources compiled with
OpenJDK 17.0.20, and the new restore/compile command was also smoke-tested in a
second fresh directory. No archived input was edited.

Reproduction commands and exact interfaces are in
[`experiments/source_local/README.md`](../../experiments/source_local/README.md).
The new Python module needs only the standard library. Java/Alloy execution
still requires the retained LFS archive, matching JARs and Java compiler module.
An unavailable archive or dependency causes an explicit failure; an offline
regression pass alone is not a new solver result. No training was run, and no
new formal proof, release-level assurance or learning improvement is asserted.

## Evidence

New evidence is isolated under [`source-local-20261017/`](source-local-20261017/):

- `report.json`: separate coverage, generation, legal-commit and repair counts.
- `coverage.json`: all 104 original IDs, splits, prior refusal reasons and new outcomes.
- `candidate-traces.json.gz`: all twelve actual candidate traces, including original queries,
  each edit decision, post-commit source graphs and final full-context checks.
- `coverage-observations.json.gz`: public source/action observations from an independent
  second loading pass, enabling a deterministic offline coverage regression over 95 inputs.
- `provenance.json` and `hashes.json`: input identity, preparation evidence and new file digests.

The initial development run exposed an incorrect controller assumption that
BEGIN must return APPLIED; the existing executor correctly returns READY during
draft construction. That run was interrupted and excluded. The reported complete
run accepts READY during construction, requires APPLIED after COMMIT, and checks
all twelve candidates without edit or execution errors.
