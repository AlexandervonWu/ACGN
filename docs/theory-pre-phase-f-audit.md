# Pre-Phase-F Theory Blocker Audit

## Audit identity

- Date: `2026-08-16`
- Normative draft: `/home/augustus/下载/E_Graphs_Draft_LNCS-1.pdf`
- PDF SHA-256: `6e44bae88fcd82fd9cd26db54d52025affb9f7d21d5cc3a2165211ab52a9d42f`
- Repository commit: `a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d`
- Worktree: dirty; this audit identifies content by the PDF hash and paths above
- Scope: Definitions 1-7, Corollary 3, Sections 3.6-3.7 and 4,
  Theorem 1, Appendix B, and Appendix C.1-C.2

The revised Appendix C correctly notices that a proper union-find parent
embedding may reduce support during leader normalization. It introduces an
effective kernel `K_G(n)`, an effective support `Delta_n`, a bijective shape
witness on that support, and a separate embedding/provenance path back to the
original context. Those distinctions preserve the embedding/renaming
invariant. The rest of the paper has not yet been changed to use that contract.

## Decision

**NO-GO for Phase F graph transitions.**

It is safe to retain the existing fail-closed Phase B-E implementation, but it
is not safe to choose certificate endpoints for insertion, collision, or
interface restriction until PF-TB01 through PF-TB03 are resolved in the formal
specification. Phase F must not silently reinterpret a typed embedding as a
renaming, and it must not encode the old two-component result while Appendix C
requires the effective-support result.

After adding the revised appendix obligation, the living matrix has 121 rows:
52 `EXACT`, 37 `PARTIAL`, 10 `ABSENT`, and 22 `CONTRADICTED`.

## Theory blockers

### PF-TB01: two incompatible definitions of `canon_G`

Section 3.6 still takes `Gamma = slots(n)` before find and requires

```text
slots(Shape_G(n)) = Can(Gamma)
sigma_n in TRen(Can(Gamma), Gamma)
Shape_G(n) ==[sigma_n] n.
```

Section 3.7 likewise enumerates bijections `Can(Gamma) -> Gamma`, and
Corollary 3 states exactness directly over the original exact supports.

Appendix C.1-C.2 instead, and correctly, defines

```text
Delta_n = slots(K_G(n)) subseteq Gamma_0
sigma_n in TRen(Can(Delta_n), Delta_n)
iota_n in TEmb(Delta_n, Gamma_0)
omega_n = iota_n o sigma_n in TEmb(Can(Delta_n), Gamma_0).
```

These contracts agree only when leader normalization preserves support. For a
proper parent edge `U(a) = m * leader`, with
`m : S_leader -> S_a`, the node `wrap(id * a)` has support `S_a` while its
leader kernel has support `m[S_leader]`. No bijection can map the smaller
canonical context onto `S_a`.

**Required paper repair:** replace the Section 3.6 postcondition, Corollary 3,
and the four steps in Section 3.7 with the effective-support contract already
stated in Appendix C. The old corollary may remain only as the special case
`Delta_n = Gamma_0` and `iota_n = id`.

### PF-TB02: insertion in Appendix C violates Theorem 1 obligation 1

Theorem 1 requires a fresh class to expose the inserted node's full support.
Its proof chooses the source realization of that node and uses reflexivity to
establish EC. Appendix C.2 instead says that insertion first computes the
leader kernel and that a fresh owner uses the kernel's effective interface.

The smallest strict-support example makes the incompatibility concrete:

```text
slots(n)       = {x, y}
slots(K_G(n))  = {x}
```

- Keeping the fresh interface `{x,y}` cannot produce a valid stored record for
  the one-slot shape: Definition 5 would require a one-slot ambient context
  (because the shape witness is a renaming) that also contains `{x,y}`.
- Choosing `{x}` follows Appendix C but is not a trace satisfying Theorem 1
  obligation 1 as currently written.

The proof of Theorem 1 also invokes the old Corollary 3 at a hash collision and
does not compose the two source-to-kernel derivations required by corrected
effective-support exactness.

**Required paper repair:** define insertion as accepting a certified triple
`(n, K_G(n), d_n)`, make a fresh class expose the full support of `K_G(n)`, and
store the original node only as provenance. Update obligation 1 and the
insertion/hash-collision cases of Theorem 1 accordingly. The alternative is to
restrict every parent edge visible to canonicalization to a typed renaming;
that would discard the intended proper-embedding/interface-restriction model
and is not recommended.

### PF-TB03: `d_n` has no formal certificate type

Appendix C introduces

```text
d_n : n =_G iota_n . K_G(n)
```

but `=_G` is only described informally. Definition 7 and Theorem 1 formulate
certificates as typed `T_{Sigma,E}` derivations between source-term witnesses;
they do not define an e-node equality judgement with the endpoints shown
above. Phase F therefore cannot validate, compose, or replay `d_n` without
choosing an unstated meaning.

**Required paper repair:** give `d_n` one of these explicit types and prove its
construction:

1. a source-realization derivation
   `T_{Sigma,E} |-_{Gamma_0} floor(n)^w = iota_n . floor(K_G(n))^w`, built from
   find/PC derivations, certified container laws, and forward congruence; or
2. a syntax-level certificate judgement with a separate realization-soundness
   lemma yielding the source equation above.

Also distinguish the certificate-free orbit minimization of an already
leader-normalized kernel from the certificate-composing kernel extraction.

## Implementation consequences

The exact package remains deliberately fail-closed:

- `LeaderNormalizer` returns only normalized syntax, not `iota_n` or `d_n`.
- `CanonicalizationResult` stores only `(source, shape, sigma)`.
- both canonicalizers reject support loss with
  `CanonicalizationDomainException`.
- the strict proper-parent regression expects that rejection.

These choices conform to the old support-preserving domain and prevent an
unsound witness, but they do not implement revised Appendix C. The result
carrier must eventually distinguish at least:

```text
original source
leader-normalized exact kernel
effective support
canonical shape
sigma : canonical -> effective                 (TRen)
iota  : effective -> original                  (TEmb)
omega = iota o sigma                            (TEmb)
d_n   : certified source-to-kernel derivation
```

No Phase F certificate should use the current three-field result as though it
were the final formal endpoint.

## Invariant register carried into Phase F

The following invariants remain non-negotiable regardless of the blocker
resolution:

1. Slots and every finite context are typed; canonical free and bound
   alphabets are deterministic and disjoint.
2. `TEmb` values are type-preserving injections; `TRen` values are onto their
   stated codomain; only renamings are invertible.
3. Invocation embeddings have direction `S_child -> caller`; parent edges have
   direction `S_parent -> S_child`; find composes in that direction.
4. Support is structural: invocation image, container/node union, and binder
   subtraction. Embedding action preserves support images.
5. `Seq`, `Bag`, `Set`, and `Bind` remain distinct. Seq preserves order and
   multiplicity; Bag preserves multiplicity; Set removes duplicate structural
   classes only after one node-wide free renaming.
6. Associative construction is flat only where visible to the smart
   constructor. Rebuild never opens opaque child e-classes.
7. `M(a)` retains output type, exposed interface, stored canonical shapes with
   exact/ambient/exposed witness contexts, and a certified typed symmetry
   group.
8. Union-find is a typed forest. Roots have identity parents. Find and path
   compression retain composed embeddings and proof provenance.
9. `H(p)=a` iff, at quiescence, leader `a` owns `p`. Canonicalization, equality,
   and measurement reject dirty state.
10. Structural alpha, graph-relative equality, leader membership, symmetry,
    and arbitrary represented equality remain separate relations.
11. Canonicalization uses one global effective free context, complete typed
    free renamings, certified leader symmetries, certified binder-block
    automorphisms, and complete structural keys.
12. A nonidentity symmetry requires its own typed witness equation. Same type,
    same leader, or coincident endpoint images prove no symmetry.
13. A slot restriction requires a restricted witness, typed inclusion equation,
    transport of every incident shape/parent/certificate, and dirtying of all
    affected parents. Syntactic non-use is not a certificate.
14. Every distinct-leader union requires a typed input/rewrite or forward
    congruence derivation. Same-leader union is a no-op unless a separate
    symmetry certificate is supplied.
15. Congruence is forward only. Parent equality never decomposes into child
    equality, symmetry, or independence.
16. Rebuild removes stale keys, finds children with provenance, normalizes
    declared ports, builds child congruence proofs, reinserts, and runs to an
    actually empty deduplicated dirty queue for a fixed finite batch.
17. EC, PC, and SC must be reconstructible from retained provenance. Finite
    unfolding uses fresh same-typed redundant coordinates and only coherent
    states.
18. Binder automorphisms preserve complete descriptors and have a certified
    consumer-invariance obligation; equal primitive type alone is insufficient.
19. Container laws and units are certified separately from schema metadata.
20. The exact package remains isolated from Fast Rewrite experiments and the
    reproducibility/terminal layer until the later integration phase.

## Verification performed

The full repository compiled on OpenJDK 17 with 25 pre-existing `-Xlint`
warnings and no errors. The focused suites passed unchanged:

| Suite | Result |
| -- | --: |
| `TheoryFoundationsTest` | 1,052 checks passed |
| `TheoryPortsTest` | 956 checks passed |
| `TheoryStateTest` | 4,193 checks passed |
| `TheoryCanonicalizationTest` | 11,162 checks passed |

The passing canonicalization suite includes the proper-parent case and confirms
that current behavior is rejection, not revised effective-support
canonicalization.

## Phase F entry condition

Phase F graph mutation work may start only after the normative text chooses one
canonicalization/insertion contract and gives `d_n` a typed derivation. Once
that is done, Phase E must first be repaired and its differential suite extended
to strict-support states. Only then can certificates be attached to stable
canonicalization, insertion, symmetry, union, and restriction endpoints.
