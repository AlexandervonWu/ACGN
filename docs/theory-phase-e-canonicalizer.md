# Phase E Quotient-First Canonicalizer Report

> Historical gate report. Structural `canon_G` remains unchanged, while the
> formerly blocked coherent wrapper and source insertion are now implemented;
> see [`theory-pre-phase-h-unblocked.md`](theory-pre-phase-h-unblocked.md).

This report records the Phase E reimplementation against the controlling
mission text and the coherent main-text contract of the current LNCS-3 draft.

- Mission SHA-256: `53f7fec4db8ff7aefb0192120739a2c1fc47e2d71153571be6c8e5b56ba33fbd`
- LNCS-3 SHA-256: `6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`
- Date: `2026-08-16`
- Scope: isolated package `is.fivefivefive.CanDis.theory`

No reproducibility program, terminal package, experiment runner, manifest,
dataset processor, Fast Rewrite or comparison e-graph, or Alloy adapter was changed.

## Result

The structural Gate E passes. The implementation now has two independent
canonicalizers over the exact Phase DA kernel:

- `ExhaustiveGraphCanonicalizer` materializes each finite local leader or
  binder orbit and selects its least member.
- `ProductionGraphCanonicalizer` streams the same local orbits and retains only
  the current least member.

Both return the same complete structural result

```text
(K_G(n), p, sigma, iota, omega, xi)
```

where `sigma : Can(Delta) -> Delta`, `iota : Delta -> Gamma_0`, and
`omega = iota o sigma`. Only `p` is a `CanonicalShape` and therefore eligible
as a hash-cons key. `xi` remains certificate-free structural provenance.

## Algorithm

```text
canon_G(n):
  require G quiescent
  require context(n) = support(n) = Gamma_0

  (K, iota, xi) := leaderKernelTrace_G(n)
  Delta := context(K) = support(K)
  C := Can(Delta)

  best := none
  for each typed bijection sigma : C -> Delta:
    rho := inverse(sigma)
    p := rebuild K in C by applying Q_G to every port under rho
    require support(p) = C
    retain the least (p, sigma), breaking equal-shape ties by sigma

  omega := sigma.andThen(iota)
  return (K, p, sigma, iota, omega, xi)

Q_G(port, rho):
  Slot(x):
    return Slot(rho(x))

  Invocation(mu * leader):
    require leader is current
    return min { (rho o mu o pi) * leader | pi in G_leader }

  Seq(values):
    return Seq([Q_G(value, rho) in source order])

  Bag(values):
    return Bag(sort([Q_G(value, rho) for every occurrence]))

  Set(values):
    return Set(unique(sort([Q_G(value, rho) for every element])))

  Bind(x, body):
    b := least fresh canonical bound slot
    return Bind(b, Q_G(body, rho union {x -> b}))

  BindBlock(beta, alpha, body):
    nu := beta.freshOccurrenceRenaming(codomain(rho))
    return min {
      BindBlock(beta, nu,
        Q_G(body,
          rho union (alpha^-1 ; pi ; nu)))
      | pi in Aut(beta)
    }
```

The `BindBlock` minimum is computed before returning to an enclosing container.
Thus a Set containing `{b, pi.b}` becomes a singleton after local quotienting,
while a Bag retains two equal occurrences. A recursive call never allocates a
new free context; nested binders only extend the one global free renaming with
fresh bound coordinates.

## Enforced Invariants

1. Leader lookup and exact support contraction happen once in Phase DA before
   the free orbit is allocated.
2. Quotient normalization sees only current leader invocations and never calls
   `find` or unfolds an e-class.
3. One typed free-slot bijection is shared by the entire node.
4. Unary and block binders extend that bijection capture-safely and locally.
5. A block ranges over exactly its declared descriptor-preserving `Aut(beta)`;
   same type alone never creates a permutation.
6. Invocation and block minima are selected before parent container behavior.
7. Seq preserves order and multiplicity.
8. Bag discards order but retains every occurrence.
9. Set deduplicates exact locally normalized structural classes only.
10. Complete structural keys decide every minimum; unequal key collisions fail
    closed.
11. Strict support contraction is represented by proper `iota` and `omega`
    embeddings, never by weakening `TypedRenaming`.
12. The result validates operator, output type, canonical/effective contexts,
    and `omega = iota o sigma`.
13. Witness replay compares the canonical shape with the exact kernel, not the
    larger pre-find source context.
14. Dirty graphs and non-exact source nodes remain rejected.
15. No structural trace is labeled as an equality certificate.

## Located Faults And Corrections

| ID | Located fault | Correction | Remaining dependency |
| -- | -- | -- | -- |
| E2-F01 | The old canonicalizers consumed ambient post-find syntax and required find to preserve support | Both consume `LeaderKernelResult.kernel()` and enumerate over its exact `Delta` | None structurally |
| E2-F02 | Proper parent embeddings caused a domain exception because the old witness targeted `Gamma_0` | `sigma` targets `Delta`; `iota` and `omega` retain the proper ambient embedding | Phase F certifies/replays the parent path |
| E2-F03 | `BindBlock` was rejected despite being a first-class Phase C port | Both recursions transport and minimize exactly `Aut(beta)` in a fixed fresh occurrence context | Phase F certifies nonidentity generators |
| E2-F04 | The reference arm used whole-candidate Cartesian products instead of the LNCS-3 local quotient order | Reference now materializes each local orbit and selects its least member before container reconstruction | None structurally |
| E2-F05 | The production arm had local invocation minimization but no uniform recursive `Q_G` contract | All six port constructors now follow one quotient-first recursion | None structurally |
| E2-F06 | Set behavior could not test the decisive `{b,pi.b}` block adversary | Added Set-collapse, Bag-multiplicity, identity-only, and nested-block differential cases | None structurally |
| E2-F07 | The old result omitted `K`, `iota`, `omega`, and `xi` | `CanonicalizationResult` now exposes the complete structural tuple and formal aliases | Coherent `d^w` wrapper remains Phase F |
| E2-F08 | Witness verification compared a shape directly with the original ambient source | Replay now compares `p` with exact `K` under `sigma`; source transport remains in `xi/iota` | Phase F supplies dependent source-to-kernel replay |
| E2-F09 | Canonicalizer version identifiers still named the provisional algorithm | Versions are `canon-g-exhaustive-v4` and `canon-g-production-v4`; v4 additionally separates global free-renaming candidates from local quotient work | Phase I records them in manifests |
| E2-F10 | Premature integration would invalidate empirical reproducibility artifacts | Exact Phase E remains isolated; no harness or terminal path changed | Phase I only |

## Theory Blockers

### E2-TB01: certificate-before-canonicalizer phase ordering

- **Exact conflict:** mission Section 11 steps 5-6 require certified leader and
  binder groups, while Section 37 schedules the certificate hierarchy only in
  Phase F, after Gate E.
- **Smallest counterexample:** a two-slot leader or two-coordinate block whose
  intended group is generated by one swap. Gate E must enumerate that swap,
  but no Phase E value can prove its witness equation.
- **Why implementation alone cannot satisfy both:** consuming the declaration
  violates Section 11; restricting every group to identity cannot implement
  `canon_G` on a legal nontrivial certified state that the phase order provides
  no way to represent.
- **Required correction:** move certificate carriers and verified group
  admission into a prerequisite Phase F0, or state Gate E parametrically over
  an already certified group interface and defer public graph admission to F.

The current groups are finite, typed, and descriptor-preserving, but their
nonidentity generators do not carry semantic certificates. Phase E is complete
relative to declared groups; `CAN-04`, `CAN-05`, `GEQ-01`, and related theorem
rows remain `PARTIAL`. Relabeling declarations as certificates is forbidden.

### PF3-TB01: structural trace is not a dependent certificate

- **Exact conflict:** Section 3.6 defines structural `xi_n`; Lemma 8 defines
  `d_n^w` only after fixing coherent `w`; Appendix C Figure 4 constructs `d_n`
  from `G,n` alone.
- **Smallest counterexample:** one source invocation whose `find` path contains
  one parent step. The graph records the structural step, but contains neither
  the endpoint witness terms nor an equality certificate interpreting it.
- **Why implementation alone cannot satisfy it:** the dependent endpoint
  `floor(n)_w` changes with `w`, so no value computed solely from `G,n` can
  inhabit the displayed certificate type for every coherent family.
- **Required correction:** keep
  `leaderKernelTrace_G(n) -> (K,iota,xi)` and add
  `replayKernelCertificate_{G,w}(K,iota,xi) -> d_n^w` in Phase F.

The implementation follows that coherent split and returns `xi_n`, never an
uncertified `d_n`.

### PF3-TB02: draft appendix still omits structural fields

- **Exact conflict:** Section 3.6 defines the six-field structural result
  `(K,p,sigma,iota,omega,xi)`, while Appendix C Figure 4 returns a different
  five-field value that omits `K` and `xi` and substitutes `d`.
- **Smallest counterexample:** every input node, including an empty-context
  leaf, produces a result from which a typed insertion cannot project the
  formally required kernel or replay trace.
- **Why implementation alone cannot satisfy it:** one Java return type cannot
  simultaneously have both incompatible dependent product shapes.
- **Required correction:** make Figure 4 return the Section 3.6 structural
  tuple, then define a separate coherent-prefix wrapper containing `d_n^w` and
  retaining `xi_n` as insertion provenance.

The artifact-side omission is repaired in `CanonicalizationResult`; the draft
contradiction remains a camera-ready blocker, not a reason to weaken the Java
result.

## Matrix

Phase E moves `CAN-01`, `CAN-06`, `CAN-09`, `CAN-10`, `CAN-11`, `TEST-02`,
and `TEST-04` from `PARTIAL` to `EXACT`.

| Status | Rows |
| -- | --: |
| `EXACT` | 59 |
| `PARTIAL` | 36 |
| `ABSENT` | 9 |
| `CONTRADICTED` | 21 |
| `UNCERTAIN` | 0 |
| **Total** | **125** |

Certificate-dependent rows deliberately do not move.

## Verification

The focused Phase B-E suites pass on OpenJDK 17.0.19:

| Suite | Checks |
| -- | --: |
| `TheoryFoundationsTest` | 1,053 |
| `TheoryPortsTest` | 1,006 |
| `TheoryStateTest` | 4,193 |
| `TheoryCanonicalizationTest` | 11,186 |
| `TheoryLeaderKernelTest` | 233 |
| **Total** | **17,671** |

The theory package compiles with `javac -Xlint:all` and no warnings. The full
repository compiles against `lib/*`. The unchanged `EGraphSaturationTest`,
`EGraphAblationTest`, `CanonicalBacktranslatorTest`, and
`MASGVisitorTypeRegressionTest` all pass.

## Next Boundary

Phase F must introduce certificate-bearing group admission and replay
`xi_n -> d_n^w` without changing the structural `canon_G` orbit algorithm.
Only after that gate should certified insertion consume this result, and only
Phase I should connect the exact engine to the existing experimental workflow.
