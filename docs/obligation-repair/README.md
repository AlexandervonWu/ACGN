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

The [v2.13 continuation](next-five/README.md) addresses P2-06, A2-01, A2-02,
P1-08, and P1-05 with exact flat typing, ordered dependent chains and their
multiplicity, and arbitrary-arity CALL validation and payload order. The
separate source/proof/observation package records the limits of each result.

The [v2.14 continuation](third-five/README.md) addresses P1-06, P1-09, P1-16,
P2-19 and A2-04 with independent CALL authority, executable nonreuse,
ordered CALL representations, complete registry admission and arbitrary-length
guarded relational JOIN proofs. Its separately frozen two-build package is
VERIFIED under the documented bounded conformance and trust assumptions.

The [v2.15 continuation](fourth-five/README.md) addresses P2-20, A2-07, A2-11,
P2-18 and P3-03: typed recursive flattening, exact leaf and chain witnesses,
container indices, and profile wire reconstruction. It also records three
concrete producer/replay corrections and their before/after regressions.
Its machine report, not the assessment labels, determines bounded closure.

The [v2.17 continuation](fifth-five/README.md) addresses P3-04, P3-05, P3-06,
P3-12 and A2-12 with complete law/flat/container records, canonical wire tables
and retained-source occurrence commitments. It separates general structural
contracts from finite Java correspondence and retains every original claim hash.

The current assessment reports **112 ready requirements and 105 diagnostics**.
Twenty-eight original diagnostics are absent; their evidence belongs to the
five separate five-claim packages. The original queue has 104 remaining diagnostics,
plus the explicitly exposed A-01 missing-registry diagnostic. The full assurance
matrix remains `INCOMPLETE`; its original 132-entry baseline is not rewritten.

The [v2.14 candidate list](next-candidates-v2.14.md) records the original scope
of that continuation; the [v2.16 list](next-candidates-v2.16.md) records the
fifth package's acceptance boundary. A lower diagnostic count is not full
artifact closure. Each package's machine report applies only to its own
frozen inputs, not automatically to future packaging revisions.

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
