# Phase F Typed Certificates

> **Publication superseding note (2026-08-27):** Dirty-worktree and earlier
> run identities below are retained as historical phase provenance. The current
> authoritative empirical snapshot is clean publication run
> `6000d695-8b5e-4972-b0ea-3d9e55111245` from source commit `ebce8743`, verified
> by `scripts/verify_imported_publication_snapshot.sh`.

> Historical gate report. The PF3 replay blockers recorded here were resolved
> after the Figure 4 repair; see
> [`theory-pre-phase-h-unblocked.md`](theory-pre-phase-h-unblocked.md).

## Audit Identity

Phase F was implemented on 2026-08-16 against:

- mission specification
  `/home/augustus/.codex/attachments/700dd038-fc5b-455b-9e11-c2aaa9aea2eb/pasted-text.txt`,
  SHA-256 `53f7fec4db8ff7aefb0192120739a2c1fc47e2d71153571be6c8e5b56ba33fbd`;
- normative draft `E_Graphs_Draft_LNCS-3.pdf`, SHA-256
  `6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`;
- repository HEAD `f0e326ab41fbdda9e21b36cb11aecc1863d9712d` in a dirty worktree.

The content diff, not HEAD alone, identifies this implementation. Phase F
changes only the isolated `is.fivefivefive.CanDis.theory` package, its theory
tests, and `/docs`. No reproducibility runner, manifest, experiment program,
dataset, generated result, or terminal package was rewired.

## Gate Contract

Gate F requires a typed certificate object for every represented
equality-producing transition and rejection of illegal transitions. The exact
graph therefore defaults to `GraphCertificateMode.REQUIRED`. Earlier Phase D/E
structural fixtures use an explicit package-private mode and cannot be obtained
through the public graph constructor.

The implemented certificate algebra is closed by the sealed
`TypedEqualityCertificate` hierarchy. Every endpoint retains:

- its exact typed slot context;
- its term, port, or law sort;
- a complete structural expression key;
- the successful endpoint context/sort check.

Trusted leaves use `CertificateOrigin`, whose kind, source artifact,
declaration ID, and ordinal are structural data. A free-form reason string is
not a proof.

## Implemented Algebra

| Formal evidence | Java representation | Admission rule |
| --- | --- | --- |
| Input equation or rewrite axiom | `InputEquationCertificate` | Structured origin and equal typed endpoint sorts/contexts |
| Equational rules | `EqualityCertificates` | Exact reflexivity, symmetry, transitivity middle endpoint, and typed renaming source |
| Forward congruence | `CongruenceCertificate` | Same direct constructor and exactly one proof for every changed direct child; no inverse rule |
| Parent equation `w_a = m.w_b` | `ParentEdgeCertificate` | Exact formal-direction embedding and derivation rooted in input/rewrite equality or forward congruence |
| E-class symmetry | `SymmetryCertificate` | Same e-class, bijective endpoint invocations, originating equation, and computed induced permutation |
| Interface factorization | `InterfaceRestrictionCertificate` | Proper typed subcontext, exact inclusion equation, and complete shape-witness transport |
| Container laws | `ContainerLawCertificate` | Explicit signature axiom with Seq=A, Bag=AC, Set=ACI, and unit only for `K0` |
| Binder automorphism | `BinderAutomorphismCertificate` | Explicit signature axiom preserving type, domain, quantifier, multiplicity, disjointness, and dependency fields |

`CertificateVerifier` recursively checks the finite proof DAG, detects cycles,
rechecks every premise, and exposes category-specific admission predicates. Its
stable version is `typed-certificate-algebra-v1`.

## Certified State Transitions

`TypedSlottedPortEGraph.unionCertified` is the sole public exact union path. It
accepts current distinct leaders only, verifies the parent-edge proof before
mutation, stores that proof on the primitive parent step, marks the graph
dirty, and runs the invariant checker. A same-leader equation is rejected and
cannot modify symmetry.

`addSymmetryCertified` is a separate transition. It verifies ownership and the
originating endpoint equation, adds only the induced nonidentity permutation,
reconstructs a proof for every element in the resulting finite group closure,
marks the graph dirty, and checks invariants.

`ParentPath.composedCertificate` transports and transitively composes every
primitive parent proof. `TypedFindResult.parentCertificate` then transports
that proof into the original caller context and checks it against the exact
original and returned leader invocations. Path compression retains the
primitive proof path rather than only its leader ID.

Strict canonicalization and leader-kernel extraction validate all nested
container-law and binder-automorphism certificates before using their
quotients. E-class and binder groups retain generator certificates and
construct derivations for every closure element by identity, inverse, and
composition. Semantic group/law equality remains extensional; proof payloads
have separate deterministic keys and do not alter canonical forms.

`verifyInterfaceRestriction` is deliberately read-only. It verifies the
proper subcontext, inclusion/factorization equation, exact shape-key coverage,
and field-by-field witness transport, but cannot publish a partially
restricted state. The atomic mutation of the interface, incident parent
embeddings, groups, certificates, dirty-parent index, and hash-cons belongs to
Phase G.

## Located Faults

The Phase F audit located and corrected these artifact faults:

| ID | Located fault | Correction |
| --- | --- | --- |
| F-F01 | A raw `ParentStep` could be publicly constructed with no proof | Removed the public constructor and added the checked `ParentStep.certified` boundary |
| F-F02 | Find retained embeddings but no composable parent equality | Added primitive certificates, path replay, caller transport, and exact endpoint checks |
| F-F03 | E-class permutations were admitted as unproved generators | Added owner-specific symmetry certificates and strict group admission |
| F-F04 | Binder permutations checked only structural compatibility | Added complete descriptor certificates and closure derivations |
| F-F05 | A/AC/ACI and unit flags were treated as semantic evidence | Added explicit signature-law certificates and strict recursive validation |
| F-F06 | A same-leader equality could be confused with a union-derived symmetry | Split the APIs; exact union rejects same-leader endpoints |
| F-F07 | Canonicalizers could consume raw law/group declarations directly | Routed strict access through graph-owned certificate checks, including the leader-kernel entry point |
| F-F08 | An intermediate implementation included proof payload in semantic group/law identity | Restored extensional semantic keys and retained independent proof keys |
| F-F09 | Initially only generators, not all closure elements, had reconstructable proofs | Added deterministic identity/inverse/composition derivation closure for S2/S3 and arbitrary finite generated groups |
| F-F10 | Initial restriction verification could accept transported witnesses based only on matching shape keys | Replaced it with exact coverage and field-by-field witness transport checks |

## Remaining Contradictions And Blockers

`PF3-TB01` remains a theory-level blocker for whole-node dependent replay. The
LNCS-3 Figure 4 constructs `d_n` from graph state and structural trace `xi_n`,
but the main result types it as `d_n^w`, which also depends on a coherent
witness family `w`. The Java artifact does not invent that missing argument or
relabel `xi_n` as an equality proof. Parent-path fragments are replayable now;
the coherent whole-node wrapper is not.

`PF3-TB02` remains an editorial contradiction in the draft because Figure 4's
result omits fields required by Section 3.6 and Theorem 1. The Java Phase E
result already repairs the artifact side by retaining
`(K,p,sigma,iota,omega,xi)`.

These contradictions do not block the independently specified Gate F
admission algebra. They do block certified insertion based on `d_n^w` and any
claim that the full theorem has been implemented. Phase G must also implement
the all-or-nothing interface-restriction transaction and certificate-bearing
collision rebuild before those transitions exist.

Container and binder law certificates are explicit trusted signature axioms.
This is the intended trust boundary, not a proof that arbitrary Alloy syntax
has those laws. Phase I must issue these origins only for supported operator
signatures and reject unsupported declarations.

## Verification Evidence

The Phase F gate was compiled with `javac -Xlint:all` and exercised together
with every earlier isolated gate:

| Suite | Deterministic checks | Seed |
| --- | ---: | ---: |
| `TheoryFoundationsTest` | 1,053 | 55520260816 |
| `TheoryPortsTest` | 1,006 | 55520260817 |
| `TheoryStateTest` | 4,194 | 55520260818 |
| `TheoryLeaderKernelTest` | 233 | 55520260820 |
| `TheoryCanonicalizationTest` | 11,186 | 55520260819 |
| `TheoryCertificatesTest` | 250 | 55520260821 |
| **Total** | **17,922** | |

The Phase F suite covers legal and malformed proof composition, structured
origins, proper parent embeddings, two-edge and generated compressed paths,
absence of automatic symmetry, certified S2/S3 closures, forward-only
congruence, noninjective-parent adversaries, certified/raw container and binder
contrasts, complete binder descriptors, read-only restriction factorization,
and the public mutation boundary.

The obligation matrix now contains 125 rows: 88 `EXACT`, 26 `PARTIAL`, 5
`ABSENT`, and 6 `CONTRADICTED`.

## Gate Decision

**Gate F passes for every equality-producing transition currently represented
by the exact engine.** Illegal parent, union, symmetry, binder, container-law,
congruence, and restriction-evidence paths fail before state publication.

This is not complete-engine acceptance. Certified insertion, coherent
source-to-kernel replay, atomic interface restriction, dirty-parent rebuilding,
finite unfolding, and Alloy/evaluation integration remain open. The existing
reproducibility layer remains available and intentionally unrewired until those
later gates pass.
