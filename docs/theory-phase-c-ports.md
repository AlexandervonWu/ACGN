# Phase C Port Representation Report

> **Later status (2026-08-16):** Phase E now canonicalizes `BindBlock`, applies
> its local orbit before enclosing Bag/Set behavior, and returns the complete
> structural result. See `theory-phase-e-canonicalizer.md`. Counts below remain
> the historical Phase C gate snapshot.

This report records the LNCS-3 reimplementation of Phase C against Definitions
3-4, Definition 6's binder-block carrier, Corollary 1, and the flat-construction
contract. The normative draft is `E_Graphs_Draft_LNCS-3.pdf`, SHA-256
`6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`.

The implementation remains isolated in `is.fivefivefive.CanDis.theory`. No
runner, dataset processor, experiment harness, manifest generator, script, or
terminal-facing package was changed.

## Gate Result

**Phase C structural gate: PASS.**

The sealed grammar now represents

```text
kappa ::= One(tau) | K^epsilon(kappa) | Bind(tau,kappa)
        | BindBlock(beta,kappa)
K in {Seq, Bag, Set}, epsilon in {+, 0}.
```

This did not close Phase E or Phase F at the time of the Phase C gate. Phase E
has since consumed this carrier; the structural unit/automorphism declarations
are still not semantic proof certificates.

## Implemented Carriers

| Formal object | Java representation | Enforced semantics |
| -- | -- | -- |
| `K+` / `K0` | `ContainerEmptiness` in every Seq/Bag/Set schema | The index is part of equality and the structural key; empty `K+` is rejected at value construction |
| `K0` signature path | `ContainerLawDeclaration` plus recursive `PortPath` | Every `K0` path requires an explicit matching unit declaration, including nested and flat construction |
| `BindBlock(beta,kappa)` | `BindBlockPortSchema`, `BindBlockPort` | Fresh occurrence-local bound context, typed `Delta_beta`-to-occurrence renaming, exact body context, support subtraction, and capture-free action |
| Complete `beta` | `BinderCoordinateDescriptor`, `BinderBlockDescriptor` | Type, exact domain key, quantifier, multiplicity, normalized disjointness class, and dependency order are immutable and keyed |
| Declared `Aut(beta)` | `BinderAutomorphismGroup` | Finite extensional closure admits only typed generators preserving every descriptor field and dependency edge |
| Structural action | `TypedEmbedding.disjointUnion` and every sealed port `act` method | One global caller embedding is extended by deterministic fresh unary/block bound coordinates |
| Structural support | Every sealed `PortValue` | Containers union support; unary binders remove one slot; blocks remove their complete occurrence context |
| Indexed alpha | `TypedAlphaEquivalence` | Block occurrences align through canonical `Delta_beta` and range over exactly the declared descriptor-preserving group |
| Canonical shape carrier | `CanonicalShape` | Blocks must use the fixed least-fresh occurrence context recursively |

The existing semantics remain unchanged: Seq is ordered and
multiplicity-preserving, Bag is unordered and multiplicity-preserving, and Set
is unordered and duplicate-insensitive under exact structural equality. Set
construction does not perform element-local alpha normalization.

## Certification Boundary

`ContainerLawDeclaration` and `BinderAutomorphismGroup` are structural
declarations, not semantic certificates. Accordingly:

- `PORT-07`, `PORT-08`, `LAW-03`, `ALPHA-04`, and `BIND-02` remain `PARTIAL`;
- Phase F must bind a verified unit-law certificate to each `K0` path;
- Phase F must bind semantic provenance to each nonidentity binder
  automorphism;
- Phase E now implements local block-orbit normalization before Bag aggregation
  and Set deduplication.

The current canonicalizers treat a block as its own constructor and range only
over the descriptor-declared group; they never treat it as unary `Bind` or
infer a same-type permutation.

## Located Faults

| ID | Located fault or contradiction | Disposition | Remaining dependency |
| -- | -- | -- | -- |
| C2-F01 | Seq/Bag/Set schemas did not encode the formal `epsilon` index | **Corrected:** `ContainerEmptiness` is immutable schema/key data | None |
| C2-F02 | Empty `K+` values could be constructed and were rejected only later by node-law inspection | **Corrected:** every container value rejects empty `K+` at its grammar boundary | None |
| C2-F03 | A `K0` schema could be declared without a unit promise | **Corrected structurally:** signature construction requires `hasUnit`; the promise is not mislabeled as proof | Phase F semantic unit certificate |
| C2-F04 | `BindBlock(beta,kappa)`, occurrence contexts, and canonical `Delta_beta` maps were absent | **Corrected:** first-class sealed schema/value and complete descriptor carriers added | None at the structural carrier layer |
| C2-F05 | A same-typed permutation could have been mistaken for a valid block automorphism | **Corrected structurally:** every generator must preserve type, domain, quantifier, multiplicity, disjointness partition, and mapped dependencies | Phase F semantic automorphism certificate |
| C2-F06 | Disjointness source labels could make equal partitions structurally unequal | **Corrected:** class labels are normalized by first occurrence while distinct classes remain distinct | None |
| C2-F07 | An initial group key included the chosen generator basis, so two presentations of the same subgroup could differ | **Corrected before gate close:** equality and keys are extensional in the closed element set | None |
| C2-F08 | Recursive consumers assumed every non-container/non-`One` value was unary `Bind` | **Corrected:** all Phase C-DA consumers and both Phase E canonicalizers have explicit block arms | None structurally |
| C2-F09 | The old canonicalizers had neither quotient-first block minimization nor the revised trace-bearing result | **Corrected in Phase E:** local block orbits and `(K,p,sigma,iota,omega,xi)` are implemented | Phase F certificate provenance only |
| C2-F10 | The legacy experiment path still uses its pre-theory carrier | Deliberately unchanged under the reproducibility invariant | Phase I integration only after Gates E-H |

## Matrix Snapshot

After this pass, the 125-row living matrix contains:

| Status | Rows |
| -- | --: |
| `EXACT` | 52 |
| `PARTIAL` | 42 |
| `ABSENT` | 10 |
| `CONTRADICTED` | 21 |
| `UNCERTAIN` | 0 |
| **Total** | **125** |

The newly exact rows are `PORT-06` and `BIND-01`. `PORT-07`, `PORT-08`, and
`ALPHA-04` move from `ABSENT` to `PARTIAL`; `BIND-02` moves from
`CONTRADICTED` to `PARTIAL`. Their remaining semantic or canonicalization
obligations are stated directly in the matrix.

## Verification

Executed on 2026-08-16 with OpenJDK 17.0.19:

| Check | Result | Evidence |
| -- | -- | -- |
| Full repository compilation against `lib/*` | PASS | Every Java source compiled |
| `TheoryFoundationsTest` | PASS | 1,053 checks; seed `55520260816` |
| `TheoryPortsTest` | PASS | 1,006 checks; seed `55520260817` |
| `TheoryStateTest` | PASS | 4,193 checks; seed `55520260818` |
| `TheoryCanonicalizationTest` | PASS | 11,162 checks; seed `55520260819` |
| **Total exact-suite checks** | **PASS** | **17,414 checks** |

The new Phase C cases cover top-level, nested, and flat `K+`/`K0` behavior for
all three containers; block-nested unit traversal; descriptor substitution;
freshness; proper-embedding support equivariance; action composition; nested
blocks; disjointness partition normalization; positive `S2` automorphisms; and
domain, quantifier, multiplicity, disjointness, dependency, and identity-only
negative cases.

## Next Dependency

Phase DA and structural Phase E are now complete as described in
`theory-phase-da-leader-kernel.md` and `theory-phase-e-canonicalizer.md`.
Phase F is next: it must certify declared laws/groups and replay structural
`xi_n` to dependent `d_n^w`. PF3-TB01 and the draft-side PF3-TB02 contradiction
remain recorded in `theory-pre-phase-f-audit-lncs3.md`.
