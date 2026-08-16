# Phase B Foundational Types Report

This report records the Phase B implementation against Definitions 1-2,
Proposition 1, and the invocation/support clauses of Definition 4 and
Corollaries 1-2 in `E_Graphs_Draft_LNCS.pdf`. The normative PDF SHA-256 is
`77ea879143f4b593c62a147ba78ffc4da5854815d73a5437865d11196f532a6d`.
The implementation baseline remains commit
`a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d`; this worktree contains the new
uncommitted Phase A-B files.

The instruction not to change reproducibility programs or the terminal package
was treated as protecting all existing command-line entry points, experiment
runners, manifests, scripts, dataset processors, and the existing `ACGN`
packages. No pre-existing implementation file in those areas was modified.
Phase B adds only `is.fivefivefive.CanDis.theory` and updates `/docs`.

### Implemented

| Formal object | Java representation | Construction boundary | Operations | Conformance evidence |
| -- | -- | -- | -- | -- |
| Type grammar `Ty` | `GraphType` | Validated static factories | Structural equality, deterministic order | Primitive, variable, arrow, relation, constructor, malformed shapes |
| Typed slot | `TypedSlot` and `SlotAlphabet` | Type, alphabet, non-negative `BigInteger` ordinal required | Structural identity and order | Cross-type and cross-alphabet distinction |
| Finite context | `TypedSlotContext` | Rejects nulls and duplicate occurrences; immutable sorted copy | Union, addition, removal, subcontext, typed projection/counts | Context laws, deterministic order, immutable-view rejection |
| Canonical alphabets | `CanonicalSlotAlphabet` | Canonical free or canonical bound only | `Can(Gamma)` and least fresh typed slot | Per-type cardinality, free/bound disjointness, deterministic freshness |
| Typed embedding | Sealed `TypedEmbedding` | Exact source keys, codomain membership, type preservation, injection | Apply, image, subcontext image, identity, composition | Valid weakening plus every malformed-map category |
| Typed renaming | Sealed `TypedRenaming` | Embedding validation plus onto codomain | Inverse and renaming-preserving composition | Both inverse equations and proper-injection rejection |
| Typed permutation | Final `TypedPermutation` | One shared source/codomain context | Identity, inverse, composition | Exhaustive permutations through context size five |
| E-class interface carrier | `EClassId`, `TypedEClassInterface` | Immutable ID, output type, exposed context | Structural access only | Invocation construction tests |
| Invocation `m*a` | `TypedInvocation` | Embedding source must equal the e-class interface | Identity, caller action, output, support | Context mismatch, output preservation, composition direction |
| Typed support | Sealed `HasSlotSupport`, `SlotSupport` | Only proven carriers may implement support | Slot singleton, invocation image, union, binder subtraction, typed image | Leaf, union, bind, weakening, equivariance tests |

The embedding API deliberately names composition both as
`before.andThen(after)` and `TypedEmbedding.compose(after, before)`. Both compute
the paper's `after o before`; the endpoint equality check prevents accidental
reversal or partial composition.

### Formal obligations discharged

The living matrix now marks these rows `EXACT`:

- `TY-01` through `TY-04`
- `EMB-01` through `EMB-06`
- `INV-01` through `INV-03`
- `SUP-02`

These statuses cover the standalone carrier algebra. They do not claim that the
legacy engines use typed values. Later matrix rows separately require explicit
ports, graph-table ownership, renamed union-find, certificates, and integration.

Gate B is **PASS**: all foundational algebra/property tests pass, malformed
values fail at construction, proper embeddings cannot be inverted, and the
public subtype boundaries are sealed.

The matrix moved from 3 to 17 `EXACT` rows:

| Status | Current rows |
| -- | --: |
| `EXACT` | 17 |
| `PARTIAL` | 35 |
| `ABSENT` | 25 |
| `CONTRADICTED` | 42 |
| `UNCERTAIN` | 1 |
| **Total** | **120** |

### Tests

Executed at `2026-08-16T13:06:55-05:00` on OpenJDK 17.0.19:

| Check | Result | Evidence |
| -- | -- | -- |
| Theory package with `javac -Xlint:all` | PASS | No compiler warnings |
| `TheoryFoundationsTest` | PASS | 1,050 checks; seed `55520260816` |
| Full repository compilation | PASS | Every Java source compiled against `lib/*` |
| `EGraphSaturationTest` | PASS | Existing test main completed |
| `EGraphAblationTest` | PASS | Existing test main completed |
| `CanonicalBacktranslatorTest` | PASS | Existing test main completed |
| `MASGVisitorTypeRegressionTest` | PASS | Existing test main completed |
| Bounded backtranslation equivalence | PASS | 20 predicates from 10 files; 0 mismatches; 0 failures |

The generated checks include 128 seeded chains of three typed embeddings and
all 154 permutations across homogeneous contexts of sizes zero through five.
Every chain checks identity, associativity, endpoint preservation, and support
image composition.

### Remaining mismatches

#### Located fault and contradiction ledger

| ID | Located fault or contradiction | Disposition in Phase B | Remaining dependency |
| -- | -- | -- | -- |
| B-F01 | Legacy graph types are coarse enums and parser-originated strings | Correct exact carrier added; legacy path deliberately untouched | Phase C signatures and Phase D state must consume `GraphType` |
| B-F02 | Legacy slots are strings or integer positions with no type/alphabet identity | Correct exact carrier and canonical alphabets added | Port and graph adapters must reject legacy slot values |
| B-F03 | Legacy code calls partial injections renamings and can invert/fill them heuristically | Sealed embedding/renaming/permutation distinction added; malformed conversion rejected | Phase D must replace parent maps with this algebra |
| B-F04 | Legacy renamed union-find stores correspondence opposite the formal parent embedding and drops coordinates | Documented, not changed under the Phase B/protected-runner scope | Phase D renamed union-find |
| B-F05 | Legacy invocations do not derive output from a typed class interface | `TypedInvocation` now has no caller-supplied output and validates `S_a` | Phase D class table must uniquely own each interface |
| B-F06 | Legacy support is inferred from parser/alpha names and partial map values | Exact leaf/image/union/subtraction operations added | Phase C must put support directly on sealed port/node values |
| B-F07 | Initial Phase B embedding classes were validated but externally subclassable, permitting an unverified subtype API | **Corrected:** `TypedEmbedding -> TypedRenaming -> TypedPermutation` is sealed/final | None |
| B-F08 | Initial support interface allowed arbitrary implementations to report invented support | **Corrected:** `HasSlotSupport` is sealed to proven carriers | Phase C must explicitly permit only its sealed port/node variants |
| B-F09 | One draft test attempted `removeAll` on the immutable context view while checking disjointness | **Corrected:** test uses non-mutating `Collections.disjoint`; immutable rejection remains separately tested | None |
| B-F10 | Two independently created `TypedEClassInterface` values can presently reuse an ID with different metadata because no graph table exists | Not a Phase B carrier violation; no graph accepts either value yet | Phase D central allocation and invariant checker |
| B-F11 | Typed action/support is complete for invocations but not yet structural over `One`, `Seq`, `Bag`, `Set`, `Bind`, or nodes | Kept `PARTIAL`; no unsupported exactness claim | Phase C explicit port grammar and capture-avoiding binder action |
| B-F12 | Structural typed alpha-equivalence has not been introduced | Kept `TEST-01` and alpha rows unresolved | Phase E canonicalizer |

There are 103 unresolved matrix rows. The most immediate are `PORT-*`, `SIG-*`,
`FLAT-*`, `INV-04`, `SUP-01`, and `SUP-03`; all depend on Phase C. Existing
legacy contradictions remain visible in the matrix and have not been relabeled
as exact merely because a separate correct carrier now exists.

### Theory blockers

`NONE`.

No contradiction was found in Definitions 1-2 or Proposition 1. The distinction
between a proper embedding and an invertible renaming is executable without
weakening the paper.

### Next dependency

Phase C must implement the explicit sealed port grammar `One`, `Seq`, `Bag`,
`Set`, and `Bind`, typed operator signatures, capture-avoiding structural action,
structural support, certified container-law declarations, deterministic keys,
and the single visible-syntax `flatConstruct` boundary. It must reuse the Phase B
types directly and must not reopen opaque invocations.
