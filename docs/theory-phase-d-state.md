# Phase D State and Renamed Union-Find Report

This report records Phase D against Definition 5, Lemma 5, and Theorem 1
obligation 9 of `E_Graphs_Draft_LNCS.pdf`. The normative PDF SHA-256 is
`77ea879143f4b593c62a147ba78ffc4da5854815d73a5437865d11196f532a6d`.
The audited repository commit is
`a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d`; the Phase D implementation is an
isolated worktree addition under `is.fivefivefive.CanDis.theory`.

No reproducibility program, runner, script, manifest, Fast Rewrite or comparison e-graph engine,
dataset processor, or terminal-facing package was changed or wired to the new
state. Phase I remains the sole integration point.

### Implemented

| Formal object | Java representation | Enforced semantics |
| -- | -- | -- |
| Canonical stored shape | `CanonicalShape` | Typed node whose caller context is exactly its canonical free-slot support; recursive canonical free/bound alphabets and least-fresh binders |
| Shape membership witness | `ShapeWitness` | Separately retains exact slots, ambient support, exposed interface, and exact-to-ambient typed renaming |
| Class payload `M(a)` | `TypedEClassRecord` | Immutable `(tau_a,S_a,B_a,G_a)` with dependent shape/witness checks and deterministic collision rejection |
| Symmetry carrier `G_a` | `TypedSymmetryGroup` | Exact finite typed subgroup closure on `S_a`; public construction is identity-only until certificates exist |
| Primitive parent assignment | `ParentStep` | Formal `U(a)=m*b` direction with `m:S_b -> S_a`, exact endpoint contexts, and equal output types |
| Parent derivation path | `ParentPath`, `ParentAssignment` | Ordered primitive history and its checked composite survive path compression |
| Typed find result | `TypedFindResult` | Original invocation, leader invocation, parent path, and recomputed formal composite embedding |
| Renamed union-find `U` | `TypedRenamedUnionFind` | Total forest, identity roots, leader-only links, cycle rejection, typed find, and provenance-retaining compression |
| Hash-cons `H` and graph state | `TypedSlottedPortEGraph`, `GraphStatus` | Private graph-owned U/M/H, exact quiescent `H(p)=a` iff leader `a` owns `p`, explicit dirty state, and stale-H query rejection |
| Runtime audit | `TypedSlottedPortEGraph.checkInvariants()` | Checks current metadata, forest, paths, child ownership, groups, witnesses, and quiescent hash-cons consistency |
| Deterministic state identity | `StructuralKey` implementations | Complete Phase B-D state key independent of registration and map iteration order |

The composition direction follows Definition 5 literally. For an original
invocation `m0*a` and a parent path whose composite is `mpath:S_leader -> S_a`,
find returns the leader invocation with embedding `m0 o mpath`. No partial map
is inverted or silently completed.

`ParentPath` is provenance-retaining state, not an equality proof. Its steps do
not claim to discharge EC, PC, or SC. Phase F must attach verified
`ParentEdgeCertificate` values before certified union is available.

### Formal obligations discharged

The living matrix now marks these Phase D rows `EXACT`:

- `STATE-01` through `STATE-05`
- `UF-01` through `UF-04`
- `HC-01`

Gate D is **PASS** for the Definition 5 state carriers, typed parent-edge
direction, total forest, typed find, embedding composition, path compression,
and quiescent hash-cons invariant. Claims that intrinsically require
certificates or rebuild remain `PARTIAL`.

| Status | Current rows |
| -- | --: |
| `EXACT` | 41 |
| `PARTIAL` | 36 |
| `ABSENT` | 13 |
| `CONTRADICTED` | 30 |
| `UNCERTAIN` | 0 |
| **Total** | **120** |

There are 79 unresolved rows. This is expected at Gate D: global
canonicalization, proof certificates, certified mutations, rebuild, finite
unfolding, and Alloy integration are later gates.

### Tests

Executed at `2026-08-16T13:59:50-05:00` on OpenJDK 17.0.19:

| Check | Result | Evidence |
| -- | -- | -- |
| Theory package with `javac -Xlint:all` | PASS | No compiler warnings |
| `TheoryFoundationsTest` | PASS | 1,052 checks; seed `55520260816` |
| `TheoryPortsTest` | PASS | 956 checks; seed `55520260817` |
| `TheoryStateTest` | PASS | 4,192 checks; seed `55520260818` |
| Full repository compilation | PASS | Every Java source compiled against `lib/*` |
| `EGraphSaturationTest` | PASS | Existing test main completed unchanged |
| `EGraphAblationTest` | PASS | Existing test main completed unchanged |
| `CanonicalBacktranslatorTest` | PASS | Existing test main completed unchanged |
| `MASGVisitorTypeRegressionTest` | PASS | Existing test main completed unchanged |
| Bounded backtranslation equivalence | PASS | 20 predicates from 10 files at scope 3; 0 mismatches; 0 failures |

The Phase D suite includes 96 generated typed chains, 64 generated branching
forests, formal-direction multi-edge composition, compression equivalence,
primitive-path retention, cycle and metadata-spoof rejection, strict ambient
support, canonical binder alphabets, missing-child rejection, atomic hash-cons
collision rejection, dirty-query rejection, and shuffled-registration state
determinism.

### Remaining mismatches

#### Located fault and contradiction ledger

| ID | Located fault or contradiction | Disposition in Phase D | Remaining dependency |
| -- | -- | -- | -- |
| D-F01 | Fast Rewrite renamed union-find stores correspondence in the direction opposite Definition 5 and permits partial-map composition | The isolated exact `ParentStep` uses `S_parent -> S_child`; generated direction-sensitive paths pass | Phase I integrates the certificate path only after Gates E-H while retaining Fast Rewrite IR |
| D-F02 | Reusing an e-class ID with different output/context metadata could make invocations depend on stale snapshots | Graph registration and find now reject every metadata mismatch | None |
| D-F03 | Existing shape storage conflates exact slots, ambient support, and the exposed class interface | `ShapeWitness` stores and validates all three separately | Phase F attaches EC provenance to the witness |
| D-F04 | An initial Phase D ordered-map insertion could have accepted comparator-equal but unequal shape objects | **Corrected:** record construction fails closed on key collision and also rejects a second unequal witness for one shape | None |
| D-F05 | Ordinary path compression would erase the primitive ancestry needed for later proof replay | `ParentAssignment` stores the compressed current edge and the complete primitive `ParentPath` independently | Phase F composes certificates over that path |
| D-F06 | A typed parent path alone is not a parent-edge equality certificate | No class or method labels it a certificate; `UF-05` and `T1-09` remain `PARTIAL` | Phase F certificate hierarchy |
| D-F07 | A typed group closure alone does not prove that generators are semantic symmetries | Nontrivial construction is package-private and uncapped, but `STATE-06`/`SYM-*` remain unresolved | Phase F symmetry certificates and transport |
| D-F08 | Dirty/quiescent status exists without the deduplicated parent-use queue or exact rebuild fixed point | Dirty hash-cons queries reject; no false rebuild/quiescence claim is made | Phase G rebuild |
| D-F09 | `CanonicalShape` can validate canonical alphabets and local typed structure but cannot establish graph-relative orbit minimality | Carrier is complete while `canon_G` rows remain unresolved | Phase E exhaustive reference canonicalizer |
| D-F10 | Phase D needs setup transitions before certified mutation objects exist | Setup registration and leader linking are package-private; raw union-find state is not exposed | Replace callers with certified Phase F operations |
| D-F11 | Historical status aggregation matched only alphabetic ID prefixes and silently omitted all nine `T1-*` theorem rows | **Corrected during the Phase E audit** in every phase snapshot; Gate D has 41 exact and 79 unresolved rows out of 120 | None |
| D-F12 | Reproducibility programs still execute only Fast Rewrite and comparison engines | Deliberately unchanged and import-audited; the exact package remains isolated | Phase I after Gates E-H |

### Theory blockers

`NONE`.

The paper fixes the parent-edge direction and find composition unambiguously.
The missing certificate payloads are planned dependencies, not a theory
contradiction, because Phase D retains the exact typed endpoints and primitive
history required to attach them.

### Next dependency

Phase E must implement `canon_G` twice: first as a slow exhaustive reference
over the whole graph action, then as the production canonicalizer. It must begin
by applying `findWithProvenance` to every child invocation, use one global typed
free-slot renaming, respect exact Seq/Bag/Set semantics, include binder
automorphisms only when descriptors permit them, and return both the least
canonical shape and its complete witness. Differential and idempotence tests
must pass before Phase F introduces certificates.
