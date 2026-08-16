# Phase E Graph-Relative Canonicalizer Report

This report records Phase E against Definition 6, Proposition 2, Corollary 3,
Section 3.7, and Appendix C.2 of `E_Graphs_Draft_LNCS.pdf`. The normative PDF
SHA-256 is
`77ea879143f4b593c62a147ba78ffc4da5854815d73a5437865d11196f532a6d`.
The audited repository commit is
`a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d`; Phase E remains an isolated
worktree addition under `is.fivefivefive.CanDis.theory`.

No reproducibility program, runner, script, manifest, legacy engine, dataset
processor, or terminal-facing package was changed. The exact engine exposes a
stable public canonicalization boundary for eventual Phase I integration.

### Implemented

| Formal object or step | Java representation | Enforced semantics |
| -- | -- | -- |
| Indexed structural alpha | `TypedAlphaEquivalence.structuralNodes/Ports` | One typed free renaming, structural operator/type equality, Seq position, Bag occurrence matching, Set mutual matching, and capture-avoiding same-typed binder extension |
| Graph-relative alpha | `TypedAlphaEquivalence.graphRelativeNodes/Ports` | Quiescent typed find, common leader, and exact equation against one stored leader permutation; separate from Java equality and class membership |
| Leader-first normalization | `LeaderNormalizer` | Replaces every invocation by its composed leader invocation before orbit construction and never opens the leader |
| Typed free orbit | `TypedRenamingEnumerator` | Deterministic uncapped streaming enumeration of all and only type-preserving bijections |
| Reference `canon_G` | `ExhaustiveGraphCanonicalizer` | Enumerates the full Cartesian product of free renamings and every leader-symmetry choice, then chooses the least complete key |
| Production `canon_G` | `ProductionGraphCanonicalizer` | Streams free renamings and performs bottom-up orbit minimization; no factorial candidate collection beyond the required free orbit |
| Port normalization | Both canonicalizers plus explicit port constructors | Seq preserves order/multiplicity, Bag sorts and retains multiplicity, Set sorts and deduplicates only after one whole-node renaming |
| Canonical result | `CanonicalizationResult` | Stores source, least `CanonicalShape`, and canonical-to-source `TypedRenaming`; constructor validates endpoints/output and canonicalizers replay the graph-relative witness |
| Exact engine API | `TypedSlottedPortEGraph.canonicalize` | Quiescence-guarded production path with engine ID `typed-slotted-port-egraph` and canonicalizer version `canon-g-production-v1` |
| Formal-domain guard | `CanonicalizationDomainException` | Rejects support loss after a proper parent embedding rather than forging a non-bijective "renaming" |

The reference and production implementations are intentionally independent at
the orbit-combination level. The reference materializes every recursive
symmetry product. Production chooses the least occurrence representative and
relies on complete Seq/Bag/Set structural ordering. Their complete
`CanonicalizationResult` values, including witness tie-breaking, are compared
differentially.

Binder alpha-renaming is implemented. Descriptor-indexed binder-block
automorphisms are not guessed from same-typed coordinates: until Phase F
provides certified `Aut(beta)`, their admissible group is identity.

### Formal obligations discharged

The living matrix now marks these additional rows `EXACT`:

- `ALPHA-01` through `ALPHA-03`
- `GEQ-02` and `GEQ-03`
- `CAN-01` through `CAN-03`
- `CAN-06` through `CAN-09`
- `TEST-01`

The differential criterion of Gate E passes for every representable
support-preserving generated state. Total Gate E acceptance remains blocked by
E-TB01 below, so `CAN-10`, `TEST-02`, and `TEST-04` remain `PARTIAL`.
Certificate-dependent `GEQ-01`, `CAN-04`, and `CAN-05` also remain `PARTIAL`
until Phase F.

| Status | Current rows |
| -- | --: |
| `EXACT` | 54 |
| `PARTIAL` | 35 |
| `ABSENT` | 9 |
| `CONTRADICTED` | 22 |
| `UNCERTAIN` | 0 |
| **Total** | **120** |

There are 66 unresolved rows. The count includes all nine `T1-*` theorem
obligations; earlier snapshots were corrected after their aggregation command
was found to exclude IDs containing digits.

### Tests

Executed at `2026-08-16T14:48:26-05:00` on OpenJDK 17.0.19:

| Check | Result | Evidence |
| -- | -- | -- |
| Theory package with `javac -Xlint:all` | PASS | No compiler warnings |
| `TheoryFoundationsTest` | PASS | 1,052 checks; seed `55520260816` |
| `TheoryPortsTest` | PASS | 956 checks; seed `55520260817` |
| `TheoryStateTest` | PASS | 4,193 checks; seed `55520260818` |
| `TheoryCanonicalizationTest` | PASS | 11,162 checks; seed `55520260819` |
| Full repository compilation | PASS | Every Java source compiled against `lib/*` |
| `EGraphSaturationTest` | PASS | Existing test main completed unchanged |
| `EGraphAblationTest` | PASS | Existing test main completed unchanged |
| `CanonicalBacktranslatorTest` | PASS | Existing test main completed unchanged |
| `MASGVisitorTypeRegressionTest` | PASS | Existing test main completed unchanged |
| Bounded backtranslation equivalence | PASS | 20 predicates from 10 files at scope 3; 0 mismatches; 0 failures |

The Phase E suite includes exact `7! = 5,040` same-typed free renamings,
cross-type rejection, indexed alpha groupoid laws, differently named binders,
non-alpha occurrence patterns, leader paths, identity-only and generated `S3`
symmetry groups, Seq/Bag/Set symmetry products, flat ACI nodes, bag
multiplicity, global-set false-dedup adversaries, witness replay, shape
idempotence, deterministic witness selection, dirty-query rejection, and the
proper-parent support-loss counterexample.

### Remaining mismatches

#### Located fault and contradiction ledger

| ID | Located fault or contradiction | Disposition in Phase E | Remaining dependency |
| -- | -- | -- | -- |
| E-F01 | Legacy canonicalization uses bounded/local untyped permutations | Added separate uncapped typed reference and production implementations; legacy code remains honestly labeled and untouched | Phase I comparative integration |
| E-F02 | Independent local alpha keys can collapse distinct elements of one Set | Both implementations share one whole-node renaming before Set uniqueness; `{(x,y),(y,x)}` remains two classes | None |
| E-F03 | The initial Phase E draft selected the canonical free context before explicitly running find | **Corrected:** `LeaderNormalizer` is now a first pass, and support preservation is checked before any free orbit is allocated | E-TB01 for the proper-embedding case |
| E-F04 | Local symmetry minimization in production could have interacted incorrectly with Bag sorting or Set deduplication | The exhaustive implementation enumerates all products; generated identity, swap, and full S3 Seq/Bag/Set cases return exactly the same shape and witness | Continue differential testing as certified groups enter in Phase F |
| E-F05 | A boolean equality helper could conflate structural alpha, graph-relative equality, and arbitrary class membership | Separate named APIs and a four-way adversarial test now preserve the distinction | None |
| E-F06 | Bag alpha-equivalence requires multiplicity-preserving occurrence matching rather than list equality | Implemented deterministic bipartite perfect matching; Seq remains pointwise and Set uses mutual mates | None |
| E-F07 | Canonicalization or graph-relative comparison on dirty U/M/H state could observe stale ownership | Both public operations reject non-quiescent graphs before traversal | Phase G may rebuild instead of rejecting |
| E-F08 | `G_a` and binder-block groups still lack semantic provenance | Canonicalizers consume only the graph-owned typed group and perform no heuristic binder-block permutation; rows remain partial | Phase F certificates and complete descriptors |
| E-F09 | Experimental integration needs stable arm/version identity without premature rewiring | Added stable engine and canonicalizer identifiers plus `graph.canonicalize`; source audit confirms no non-theory import | Phase I manifest/runner arm |
| E-F10 | Historical matrix totals silently omitted the nine `T1-*` rows because the aggregation regex allowed only letters before `-` | **Corrected:** all Phase A-E reports now count the full 120-row matrix | None |

### Theory blockers

`E-TB01: proper parent embeddings conflict with the canonical witness postcondition.`

Definition 5 permits a proper embedding on a parent edge:

```text
U(a) = m * leader,  m : S_leader -> S_a
```

Take `S_a={x,y}`, `S_leader={x}`, and `m(x)=x`. The exact-support node
`wrap(id_{S_a}*a)` has support `{x,y}`. Canonicalization step 1 replaces its
invocation by `m*leader`, whose support is `{x}`. Figure 4 and the canonical
shape postcondition nevertheless require both:

```text
slots(Shape_G(n)) = Can({x,y})
sigma_n in TRen(Can({x,y}), {x,y})
```

No leader-normalized syntax contains the second coordinate, so its structural
support cannot equal the two-slot canonical context. Dropping the coordinate
instead yields a one-slot shape and cannot retain the required bijective
two-slot witness. Relaxing `TypedRenaming` to an injection would violate
Definition 2 and Corollary 3, so the implementation rejects this state with
`CanonicalizationDomainException`.

Two coherent theory-level corrections are available:

1. Restrict `canon_G` and Corollary 3 to leader-normalized nodes, with `Gamma`
   defined after find, and separately retain a typed weakening/provenance map
   from effective support into the original ambient context.
2. Require every `U` edge consumed by `canon_G` to be a typed renaming; handle
   certified interface restriction through a separate transport operation that
   rewrites all incident invocations before quiescence.

The current Java code chooses neither correction silently.

### Next dependency

Resolve E-TB01 at the theory level before claiming total `canon_G` or
Corollary 3. Phase F certificate carriers can otherwise proceed independently:
input equality, parent edge, congruence, symmetry, binder automorphism,
interface restriction, and container-law certificates must bind typed endpoints
to the existing Phase B-E values. The public canonicalizer should then consume
only certified group state without changing its orbit algorithm.
