# Phase DA Leader-Kernel Extraction Report

> **Later status (2026-08-16):** Phase E now consumes this result, accepts
> strict support contraction and `BindBlock`, applies local quotient-first
> normalization, and returns `(K,p,sigma,iota,omega,xi)`. See
> `theory-phase-e-canonicalizer.md`. Counts below record the Phase DA gate at
> the time it was run.

This report records the prerequisite between Phase D graph state and Phase E
canonicalization. It implements the structural operation called
`leaderKernelTrace_G` in Section 3.6 and step 1 of Section 3.7 of
`E_Graphs_Draft_LNCS-3.pdf`. The normative PDF SHA-256 is
`6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`.
The repository review target is HEAD
`f0e326ab41fbdda9e21b36cb11aecc1863d9712d` in a dirty worktree; paths and
content identify this implementation pass.

Phase DA is deliberately structural. It produces

```text
leaderKernelTrace_G(n) -> (K_G(n), iota_n, xi_n)
```

and does not claim to produce the witness-dependent equality certificate
`d_n^w`. No reproducibility program, experiment runner, script, manifest,
legacy e-graph engine, dataset processor, or terminal-facing package was
changed.

## Implemented

| Formal object or step | Java representation | Enforced semantics |
| -- | -- | -- |
| Structural extraction boundary | `LeaderKernelExtractor` | Requires a quiescent graph and exact source context, visits every opaque invocation through typed `find`, and never unfolds an e-class |
| Effective result | `LeaderKernelResult` | Retains source, ambient post-find syntax, exact kernel, `iota_n`, and `xi_n` as separate immutable fields |
| Structural provenance `xi_n` | `LeaderKernelTrace`, `LeaderPortTrace` | Mirrors all six port constructors and retains every `TypedFindResult`, including its ordered primitive `ParentPath` |
| Container-law provenance | `ContainerNormalizationTrace` | Retains normalized source tokens and a total output-to-input fiber partition for Seq, Bag, and Set |
| Exact-context view | `ExactContextRestrictor` | Narrows only caller contexts and invocation codomains to effective support; preserves slot identity and every unary/block binder occurrence |
| Public graph boundary | `TypedSlottedPortEGraph.extractLeaderKernel` | Synchronized, quiescence-guarded access with version `leader-kernel-trace-v1` |
| Compatibility projection | `LeaderNormalizer` | Delegates to Phase DA and exposes ambient post-find syntax for package compatibility; current Phase E consumes `LeaderKernelResult` directly |

The implemented operation is:

```text
extract(G, n):
  require G is quiescent
  require context(n) = support(n) = Gamma_0
  recursively for each port occurrence:
    slot: retain it
    invocation m*a: retain find_G(m*a), replace it by the returned leader
    Seq/Bag/Set: recurse on every source token, normalize the declared
                 container, and retain its output fibers
    Bind/BindBlock: recurse under the unchanged fresh occurrence context
  let n_hat be the reconstructed node in Gamma_0
  Delta_n := support(n_hat)
  K_G(n) := the same port syntax with caller context narrowed to Delta_n
  iota_n := inclusion(Delta_n, Gamma_0)
  validate all dependent endpoints and return (K_G(n), iota_n, xi_n)
```

For an invocation in the exact kernel, narrowing reconstructs a
`TypedEmbedding` with the same source and mapping and codomain `Delta_n`. It
does not invert `iota_n`, fill a missing coordinate, or cast a proper embedding
to `TypedRenaming`.

## Preserved Invariants

1. Slots and contexts remain typed, finite, immutable, and deterministically
   ordered.
2. Every embedding remains a total type-preserving injection; only an onto map
   reports `isRenaming()`.
3. Invocation maps have direction `S_a -> caller`; parent maps have direction
   `S_parent -> S_child`; `find` composes in that direction.
4. Extraction requires `Gamma_0 = support(n)` and computes
   `Delta_n = support(n_hat) subseteq Gamma_0` after all finds.
5. `iota_n` is exactly `TypedEmbedding.inclusion(Delta_n, Gamma_0)` and is
   never inverted when proper.
6. Every invocation occurrence is opaque and contributes one retained find
   result; no representative or child node is inspected.
7. Seq fibers are pointwise and ordered. Bag fibers are a bijection on
   occurrence tokens and retain multiplicity. Set fibers partition all source
   tokens and retain every idempotence collapse.
8. Container normalization is bottom-up, so child provenance exists before an
   enclosing commutativity or idempotence step.
9. Unary binders retain their fresh bound slot and subtract it only from free
   support.
10. Binder blocks retain the complete descriptor-to-occurrence renaming and
    their entire fresh occurrence context.
11. Context narrowing cannot deduplicate a Set; such a change fails closed.
12. Structural provenance `xi_n` is not an equality certificate. Replaying it
    as `d_n^w` remains a Phase F operation requiring coherent witnesses and
    certified parent/container steps.
13. Neither trace nor ambient transport is a canonical shape hash key.
14. Dirty graphs, non-exact source nodes, unknown e-classes, and malformed
    dependent endpoints fail before a result is returned.
15. The exact package remains isolated from every current evaluation and
    reproducibility path until Phase I.

## Formal Obligations Discharged

Phase DA completes the structural prerequisite inside `CAN-01`: leader
replacement, composed embeddings, effective kernel, typed inclusion, and
retained trace now have one checked result boundary. `CAN-01` remains
`PARTIAL`, because its full row also requires replayed `d_n^w` and consumption
by Phase E.

`CERT-05` moves from `ABSENT` to `PARTIAL`: the complete structural trace
grammar exists, while certificate replay remains absent. `CAN-09`, `CAN-10`,
`TEST-02`, and `T1-01` improve in concrete evidence but remain `PARTIAL`
because the canonical result, quotient normalizer, certified insertion, and
replay operations have not been implemented.

The 125-row living matrix now contains:

| Status | Rows |
| -- | --: |
| `EXACT` | 52 |
| `PARTIAL` | 43 |
| `ABSENT` | 9 |
| `CONTRADICTED` | 21 |
| `UNCERTAIN` | 0 |
| **Total** | **125** |

## Tests

Executed on 2026-08-16 with OpenJDK 17.0.19:

| Check | Result | Evidence |
| -- | -- | -- |
| Theory package compilation with `javac -Xlint:all` | PASS | No warnings |
| `TheoryFoundationsTest` | PASS | 1,053 checks; seed `55520260816` |
| `TheoryPortsTest` | PASS | 1,006 checks; seed `55520260817` |
| `TheoryStateTest` | PASS | 4,193 checks; seed `55520260818` |
| `TheoryCanonicalizationTest` | PASS | 11,162 checks; seed `55520260819` |
| `TheoryLeaderKernelTest` | PASS | 232 checks; seed `55520260820` |
| **Focused exact-package checks** | **PASS** | **17,646 checks** |
| Full repository compilation against `lib/*` | PASS | Every Java source compiled |
| `EGraphSaturationTest` | PASS | Existing legacy test completed unchanged |
| `EGraphAblationTest` | PASS | Existing ablation test completed unchanged |

The Phase DA gate includes the smallest strict-support parent embedding,
identity and two-edge retained paths, path compression replay, Seq position,
Bag multiplicity, post-find Set deduplication, empty `K0`, unary binder and
first-class binder-block scope preservation, proper-inclusion typing, unknown
e-class rejection, dirty-state rejection, non-exact source rejection,
immutability, and 32 generated strict-support chains.

## Located Faults And Contradictions

| ID | Located fault or contradiction | Disposition in Phase DA | Remaining dependency |
| -- | -- | -- | -- |
| DA-F01 | `LeaderNormalizer` discarded every parent path after composing its embedding | **Corrected:** each invocation branch owns the complete `TypedFindResult` and primitive path | Phase F adds parent-edge certificates and replay |
| DA-F02 | Proper parent embeddings were visible only as a Phase E rejection | **Corrected structurally:** extraction accepts support contraction and returns exact `K_G(n)` plus proper `iota_n` | **Completed in Phase E:** canonicalization consumes the exact kernel and returns proper `omega_n` |
| DA-F03 | General embedding action is not an exact-context restriction and may alpha-rename bound occurrences | **Corrected:** a dedicated restriction operation preserves binder occurrences and narrows only caller declarations/codomains | Phase E acts on the exact kernel after extraction |
| DA-F04 | Reconstructing a Set after `find` could erase the source occurrences that justified idempotence | **Corrected:** output fibers retain every collapsed source token and child trace | Phase F certifies and replays the declared law |
| DA-F05 | A Bag needed occurrence identity even when multiple post-find values became equal | **Corrected:** singleton fibers form a total occurrence bijection and multiplicity is unchanged | None at the structural layer |
| DA-F06 | Recursive consumers could lose binder/block scope while removing an unused ambient coordinate | **Corrected:** body contexts are narrowed with the complete fresh bound context reattached | **Completed in Phase E:** local block quotient preserves nested scope |
| DA-F07 | Leader extraction could query a dirty graph and retain paths inconsistent with stale `H` | **Corrected:** the public operation shares the canonicalization quiescence guard | Phase G may rebuild rather than reject |
| DA-F08 | LNCS-3 Figure 4 constructs `d_n` from graph structure alone | **Not bypassed:** Phase DA returns only structural `xi_n`; no certificate class or proof claim was introduced | PF3-TB01 and Phase F replay contract |
| DA-F09 | LNCS-3 Figure 4 omits `K_G(n)` and `xi_n` from its returned record | **Corrected in the artifact:** Phase E returns both fields in its complete structural result | PF3-TB02 remains a draft contradiction |
| DA-F10 | Premature integration could invalidate current experimental manifests and measurements | **Prevented:** no reproducibility, terminal, legacy, adapter, dataset, or report-generation code changed | Phase I only |

## Remaining Mismatches

- The two Phase E structural mismatches recorded in the original Phase DA run
  are resolved: the complete result and quotient-first block recursion exist.
- `xi_n` contains structural parent and container provenance, but its steps do
  not yet carry semantic certificates and cannot produce `d_n^w`.
- Certified insertion, group admission, interface restriction, collision
  union, rebuilding, and finite-unfolding conformance remain later gates.
- The exact engine is not connected to Alloy or empirical runners.

## Theory Blockers

PF3-TB01 remains active exactly as recorded in
`theory-pre-phase-f-audit-lncs3.md`. PF3-TB02 is repaired in the Java result,
but remains an inconsistency in the draft appendix. The implementation keeps
structural `xi_n` separate from witness-dependent `d_n^w`.

## Next Dependency

Phase F must attach certificates to parent/container steps and admitted group
generators, then replay `xi_n` to `d_n^w` under coherent witnesses. The
structural Phase E orbit algorithm requires no further weakening or repair.
