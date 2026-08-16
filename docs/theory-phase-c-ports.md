# Phase C Port Representation Report

This report records Phase C against Definitions 3-4, Corollary 1, the
flat-construction contract, and the structural-order obligations in
`E_Graphs_Draft_LNCS.pdf`. The normative PDF SHA-256 is
`77ea879143f4b593c62a147ba78ffc4da5854815d73a5437865d11196f532a6d`.
The implementation remains in the isolated
`is.fivefivefive.CanDis.theory` package.

No existing runner, experiment harness, manifest generator, dataset processor,
script, or terminal-facing package was changed. `NodeSealer` deliberately keeps
one adapter boundary open for Phase D graph ownership and eventual Phase I
rewiring.

### Implemented

| Formal object | Java representation | Enforced semantics |
| -- | -- | -- |
| Port schemas | Sealed `PortSchema` with `OnePortSchema`, `SeqPortSchema`, `BagPortSchema`, `SetPortSchema`, and `BindPortSchema` | Recursive type substitution, complete structural keys, no generic metadata-tagged container |
| Port values | Sealed `PortValue` with five corresponding final classes | Exact schema and caller-context validation at construction |
| `One(tau)` | `OnePort`, `SlotPortLeaf`, `InvocationPortLeaf` | Same-typed slot in context or same-context typed opaque invocation |
| `Seq(kappa)` | `SeqPort` | Order and multiplicity retained |
| `Bag(kappa)` | `BagPort` | Structural-key sorting removes order while retaining every occurrence |
| `Set(kappa)` | `SetPort` | Structural-key sorting and exact deduplication remove order and duplicate structural classes |
| `Bind(tau,kappa)` | `BindPort` | Fresh same-typed coordinate, body in `Gamma+bound`, support subtraction, capture-avoiding action |
| Typed signatures | `OperatorDeclaration`, `InstantiatedOperator` | Exact type-parameter assignment, recursive schema instantiation, output derived from signature |
| Container-law locations | `PortPath`, `ContainerLawDeclaration` | Exactly one A/AC/ACI declaration for every nested Seq/Bag/Set path; explicit unit bit |
| Typed nodes | `TypedENode` | Private constructor; port count/schema/context checks; output derived from signature; recursive empty-unit checks |
| Flat source boundary | `FlatInput`, `FlatLeaf`, `FlatApplication`, `TypedENode.flatConstruct` | Visible same-headed syntax is spliced before sealing; opaque invocations are never opened |
| Structural order | `StructuralKey`, `TheoryKeys` | Immutable, length-prefixed, total keys covering every Phase B-C field |

The `SetPort` constructor performs only exact structural deduplication under one
shared caller context. It does not alpha-normalize elements independently.
Phase E will apply one global node-wide free-slot renaming before constructing
and comparing graph-relative canonical candidates.

`ContainerLawDeclaration` is intentionally named a declaration. It checks the
shape of a promised law but is not evidence that the law is semantically valid.
Machine-checkable `ContainerLawCertificate` values remain a Phase F obligation.

### Formal obligations discharged

The living matrix now marks these additional rows `EXACT`:

- `INV-04`
- `PORT-01` through `PORT-06`
- `SIG-01` and `SIG-02`
- `FLAT-01` through `FLAT-03`
- `SUP-01` and `SUP-03`

Gate C is **PASS**. The explicit grammar has distinct executable semantics,
support is structural and equivariant, typed nodes cannot bypass the flat
constructor, and complete Phase B-C keys are deterministic by construction.

The matrix moved from 17 to 31 `EXACT` rows:

| Status | Current rows |
| -- | --: |
| `EXACT` | 31 |
| `PARTIAL` | 29 |
| `ABSENT` | 23 |
| `CONTRADICTED` | 37 |
| `UNCERTAIN` | 0 |
| **Total** | **120** |

### Tests

Executed at `2026-08-16T13:37:22-05:00` on OpenJDK 17.0.19:

| Check | Result | Evidence |
| -- | -- | -- |
| Theory package with `javac -Xlint:all` | PASS | No compiler warnings |
| `TheoryFoundationsTest` | PASS | 1,052 checks; seed `55520260816` |
| `TheoryPortsTest` | PASS | 956 checks; seed `55520260817` |
| Full repository compilation | PASS | Every Java source compiled against `lib/*` |
| `EGraphSaturationTest` | PASS | Existing test main completed |
| `EGraphAblationTest` | PASS | Existing test main completed |
| `CanonicalBacktranslatorTest` | PASS | Existing test main completed |
| `MASGVisitorTypeRegressionTest` | PASS | Existing test main completed |
| Bounded backtranslation equivalence | PASS | 20 predicates from 10 files; 0 mismatches; 0 failures |

The Phase C suite checks malformed schemas and signatures, all five port
semantics, bag multiplicity, set idempotence, binder capture avoidance, nested
unit paths, visible versus opaque flattening, constructor bypass rejection,
structural-key order laws, and 128 deterministic generated container/action
cases.

### Remaining mismatches

#### Located fault and contradiction ledger

| ID | Located fault or contradiction | Disposition in Phase C | Remaining dependency |
| -- | -- | -- | -- |
| C-F01 | Legacy canonical and ablation nodes still encode ports as generic child lists plus arity metadata | A distinct sealed exact hierarchy now realizes the paper; protected legacy paths were not relabeled or changed | Phase I adapter and compatibility evaluation |
| C-F02 | Legacy saturation can open opaque e-class representatives to flatten hidden same-headed alternatives | Exact `FlatLeaf` invocations expose no child alternatives and remain one element | Phase D-G graph operations must preserve this boundary; Phase I replaces the legacy path only after conformance |
| C-F03 | Initial Phase C type substitution treated a present type-variable mapping to `null` as if the variable were unmapped | **Corrected:** `GraphType.substitute` distinguishes absence with `containsKey` and rejects a present null replacement | None |
| C-F04 | Initial law indexing used only a top-level integer port index, so an empty Seq/Bag/Set nested under `Bind` could avoid unit checking | **Corrected:** recursive `PortPath(port,depth)` declarations are exact and `TypedENode` checks every nested value path | None |
| C-F05 | A generic support interface could have admitted an implementation reporting invented support as Phase C grew | **Corrected:** `HasSlotSupport` and `PortValue` are sealed; every permitted carrier computes support internally | None |
| C-F06 | `NodeSealer` can currently be checked only for output type, caller context, and support; Phase C has no graph state or provenance with which to prove that the invocation owns the supplied node | Kept as an explicit temporary adapter obligation, not claimed as a certificate | Phase D graph-owned insertion, then Phase F provenance |
| C-F07 | Structural law declarations are not semantic proofs | Rows `LAW-01` through `LAW-03` remain `PARTIAL`; naming and documentation do not overclaim | Phase F container-law certificates |
| C-F08 | Complete structural ordering cannot yet include e-class shape witnesses, symmetry provenance, or certificates because those values do not exist | Phase B-C keys are complete; `ORD-01` and `ORD-02` remain `PARTIAL` for whole-graph values and replay | Phases D-F, then determinism replay |
| C-F09 | Graph-relative set equality requires one global free-slot renaming; applying local alpha normalization independently would be unsound | Phase C performs no local alpha normalization and only removes exact duplicates | Phase E exhaustive global canonicalizer and differential oracle |
| C-F10 | Reproducibility programs still exercise the legacy implementation | Deliberately unchanged; the new API remains isolated and `NodeSealer` keeps the future wiring point explicit | Phase I only, after Gates D-H |

There are 89 unresolved matrix rows. Most concern the absent `G=(U,M,H)` state,
renamed union-find, global canonicalization, certificates, rebuilding, invariant
checking, finite unfolding, and final Alloy integration. The partial law and
ordering rows above are not promoted merely because their Phase C structural
sub-obligations now pass.

### Theory blockers

`NONE`.

The nested-law ambiguity was an implementation defect, not an inconsistency in
the formal grammar. Unary schema paths identify every nested container without
weakening the paper.

### Next dependency

Phase D must implement the graph-owned state boundary: complete e-class records
for `(tau_a,S_a,B_a,G_a)`, typed parent edges in the formal direction,
`find` returning a leader invocation with a composed embedding, and path
compression that retains an explicit provenance placeholder ready for Phase F.
It must consume `TypedENode` and `TypedInvocation` directly and must not modify
or rewire the reproducibility programs.
