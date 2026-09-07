# A-01 First Repair: Results And Remaining Work

## Disposition

**A-01 remains OPEN. The original 132 diagnostics have not been discharged.**
This pass repairs a missing acceptance check and implements a structural
decomposition prerequisite. It does not claim closure of the parent requirement
or any later item in the ordered queue.

Current assessment: 191 requirements, 191 matrix rows, 87 ready rows, and
**133 diagnostics**. The new diagnostic is
`A-01 MISSING_LOW_LEVEL_REGISTRY`. The original `A-01 conformance_status is PARTIAL`
remains. The added failure exposes evidence that the previous checker did not
inspect; it is not a newly broken Alloy predicate or a new rewrite family.

## Repairs

1. `Section3AssuranceTraceability` checks the A-01 missing-evidence boundary
   independently of declared statuses. A `PROVED/DIRECT` label and a theorem
   name cannot make an undecomposed parent ready. A proposed child registry
   without the required parent-contract and reconstruction authority also
   rejects. There is deliberately no full admission path yet.
2. `assurance/ContractDecomposition` provides immutable formula/skeleton data,
   ordered atomic occurrences, exact reconstruction, and rejection of an
   undersized or oversized atom tape. It preserves every connective, negation,
   quantifier, sort, argument index, duplicate occurrence, and shared scope.
   It performs no rewriting or primitive-authority inference.
3. The generated claim catalog now ends with exactly one newline. Previously,
   regeneration reintroduced a second trailing newline, making the runner's
   byte-freshness check disagree with the whitespace-clean checked-in catalog.
4. `report_obligation_repairs.py` retains the original ordered 132 diagnostics,
   records new failures separately, and never treats a missing old diagnostic
   as proof of repair. It rebuilds the checker and executes the prerequisite
   tests/proofs with a 60-second per-command bound and a 256 MiB Java heap.

## Verification

Two fresh compilations and proof builds were run in
`/tmp/acgn-obligations-a01-C` and `/tmp/acgn-obligations-a01-D`.

| Check | Result in each build |
| --- | ---: |
| Contract decomposition tests | 4,863 passed |
| Traceability gate regressions | 40 passed |
| Diagnostic reporting tests | 8 passed |
| Lean decomposition theorems | 11 compiled and assumption-audited |
| Lean unsupported-admission theorems | 4 compiled and assumption-audited |
| Compared Java class / Lean proof artifacts | 27, byte-identical |

The bounded contract enumeration covers 2,378 depth-two formulas, plus targeted
cases for implication polarity, IFF, quantifier alternation, source argument
order, duplicate occurrences, lost conjuncts, and one existential witness
being incorrectly split into two. The latter has a separate Lean semantic
witness: over Booleans, `exists x, x and not x` is false, while separately
choosing witnesses for `x` and `not x` makes both existential claims true.

The Lean round-trip theorem is general in tree size and atom/scope payloads;
the Java enumeration is bounded. Java rejection by `IllegalArgumentException`
for malformed tapes corresponds to Lean reconstruction returning `none`.
Both prevent acceptance, but their raw return/exception interfaces are not
claimed identical. Constructor input validation and the Java iteration/heap
semantics are tested, not universally refined to Lean. Predicate and sort
payloads remain declared data, not proofs of primitive or source authority.

The [input manifest](evidence/inputs.json) has SHA-256
`273560ff6a914349d673fad64b4e583b18ac94056ae5fdceaf6511857aab65f7`.
The matching [artifact inventory](evidence/artifacts.json) has SHA-256
`6439fd0724c2c09c934a0741dd30b1f1df61bf10cb21ad7e2542b465ed865cc7`.
Raw logs and the second build's inventory/report are retained in `evidence/`.
These are bounded prerequisite results; the current report remains
`INCOMPLETE`, not a whole-artifact mechanical closure.

The full `run_bounded_ci_java_tests.sh` suite also passed. Its archived log has
SHA-256 `3ff0ceca06d64006fac537c230004c7a1c0b6a2c4b0dad255bfb59f179b60e0e`.
The previous seven-claim constructor refinement was rerun after the source
changes and remains **VERIFIED within its original scope**:

- Closure ID: `java-lean-smart-construction-v1-a50d30eb64e7ccf0`.
- Input root: `a50d30eb64e7ccf0005529bfb15e67086c3d07fc34c215e37c496cc5b39452dd`.
- Two matching builds, 2,356 constructor inputs each.
- Archived report and hashes: [constructor regression](evidence/constructor-regression/closure-report.json).

## Next Required Work

A-01 needs exact typed contracts for all 191 original parent requirements,
explicit primitive definitions and context, and reconstruction evidence binding
each complete parent to its atomic children. The current partial theorem
mappings cannot substitute for that inventory. Formalizing the requirements
must preserve their unbounded statements, shared binders, and hypotheses; it
must not replace a parent with a weaker bounded example or unrelated `True`.

The independent [design review](a01-design-review.md) identified this prerequisite
before implementation. This pass implements its fail-closed recommendation and
the structural reconstruction building block; no LLM opinion was used to
promote an assurance status. The subsequent diagnostics remain in their
original order in [current.md](current.md).

No experimental result directories, datasets, production rewrite semantics,
certificate authority, or publication manifests were modified.
