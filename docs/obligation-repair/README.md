# Ordered Obligation Repair

The starting assessment has **132 diagnostics on 104 requirements**, out of
191 requirements. Diagnostics are not interchangeable with test failures:
28 affected requirements have both a formal and a conformance diagnostic.
The original requirements, claim hashes, and meaning remain unchanged.

## Five Bounded Repairs

The next five selected gaps are repaired in order: P2-02, A2-06, P2-05,
P1-10, and P5-15. The [repair record](bounded-five/README.md) explains each
replacement proof, direct implementation test, correspondence boundary, and
review finding. They are `PROVED/DIRECT` under the existing schema: general
Lean statements with **bounded** direct conformance, not whole-JVM refinement.

The fresh assessment reports **92 ready requirements and 128 diagnostics**.
Five original diagnostics are absent; their evidence is in the separate
five-claim closure report. The original queue now has 127 remaining diagnostics,
plus the explicitly exposed A-01 missing-registry diagnostic. The full assurance
matrix remains `INCOMPLETE`; its original 132-entry baseline is not rewritten.

## First Item: A-01

**Status: BLOCKED. Executable acceptance gap repaired; requirement not closed.**

The requirement is: "Every scoped high-level requirement has at least one
atomic low-level requirement."

The previous Java assessment checked only a parent matrix, proof names and
status strings. Its synthetic `PROVED/DIRECT` fixture was reported ready even
though it contained no child requirements and its referenced theorem was
`True`. That fixture tested mapping integrity, not semantic decomposition.
The Lean theorem `pass_implies_requirements_decomposed` simply projects the
assumed count and atomicity flag from `GatePass`. It does not construct a
decomposition of the actual 191 requirements.

The assessment now rejects absent low-level records **independently of status
labels**. A purported registry of theorem names and `atomic=true` also rejects:
the complete authoritative parent-contract inventory is still missing. This
is an explicit unsupported-evidence boundary, not a working full decomposition
admission path.

The new `assurance/ContractDecomposition` helper separates a logical contract
into its connective/quantifier skeleton and an ordered tape of atomic payloads.
It reconstructs the whole original tree, rejects insufficient or surplus
payloads, and requires exact original/reconstruction equality. In particular,
it never splits a shared existential witness or changes implication polarity,
IFF, or quantifier alternation. `ContractDecomposition.lean` proves round-trip
reconstruction for arbitrary trees and gives concrete Boolean-domain
counterexamples to witness splitting and quantifier swapping.

This helper is structural: declared atom and sort payloads do not acquire
primitive or source authority through their spelling. It does not translate
the English requirements automatically. Its Java tests and Lean proofs are
separate evidence; no universal Java-to-Lean compiler refinement is asserted.

The blocker is a missing specification artifact: exact parent contracts, a
defined atom language, and checked reconstruction of every whole parent from
its children. Existing partial Lean mappings cannot fill this inventory
automatically. In particular, splitting a conjunction must retain quantifier
scope and shared witnesses; listing related theorems or substituting `True`
does not preserve the parent requirement. The original English requirements
remain authoritative; a proposed formalization must not silently replace them.

The [independent design review](a01-design-review.md) records the smallest
counterexample, exact prerequisite, and bounded acceptance conditions. No
later item is marked repaired merely because this first guard blocks a run.

## Tracking

`baseline.json` freezes the original 132 diagnostics, their ordered parent IDs,
claim hashes and current proof limitations. `current.md` compares a fresh
assessment to that baseline. New failures remain visible rather than being
mistaken for resolved old failures. A lower count is not itself proof closure.

```bash
python3 scripts/report_obligation_repairs.py --root . --output /tmp/acgn-obligation-status
```

This command compiles and runs the current traceability checker in a fresh
directory; it does not modify statuses or run experiments. It reports
`INCOMPLETE` while any diagnostic remains. Bounded tests and proof records for
the first repair are documented in `a01-results.md`.
