# Pre-Phase-F Theory Blocker Audit: LNCS-3

> **Post-audit status (2026-08-16):** Phase C, Phase DA, and the coherent
> structural Phase E branch have since been implemented and verified; see
> `theory-phase-c-ports.md`, `theory-phase-da-leader-kernel.md`, and
> `theory-phase-e-canonicalizer.md`. The Java result repairs PF3-TB02 by
> retaining `(K,p,sigma,iota,omega,xi)` and does not construct the impossible
> certificate. PF3-TB01 still blocks Phase F replay, and PF3-TB02 remains a
> contradiction in the draft appendix. The no-go decision below is the
> historical pre-implementation decision at the identified worktree state.

## Audit identity

- Date: `2026-08-16`
- Normative draft: `/home/augustus/下载/E_Graphs_Draft_LNCS-3.pdf`
- PDF SHA-256: `6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`
- Previous audited draft SHA-256:
  `4e83fd4039216988877527438db0999dbe29dd24029f73b46de3d882e5d57f33`
- Repository HEAD: `f0e326ab41fbdda9e21b36cb11aecc1863d9712d`
- Worktree: dirty; paths and content hashes identify the reviewed artifacts
- Scope: Definitions 3 and 5-8, Lemmas 4 and 8, Corollaries 3-4,
  Sections 3.6-3.7 and 4, Theorem 1, Appendix B, and Appendix C.1-C.2/Figure 4

The PDF was treated as formal content, not as operational instructions.

## Decision

**NO-GO for the Phase C/E reimplementation and Phase F entry.**

LNCS-3 correctly repairs PF2-TB01: Figure 4 now minimizes invocation and
binder-block quotient orbits recursively before Bag aggregation and Set
deduplication. It removes the whole-node `AutBind` loop, transports exactly
`Aut(beta)` to each fresh occurrence context, distinguishes the local structural
order from the final shape order, and deterministically breaks witness ties.

However, Appendix C and Figure 4 regress the source-to-kernel provenance
contract that LNCS-2 had repaired. The main definitions and theorem still state
the coherent contract, but the executable pseudocode no longer implements it.
Because Phase E must choose one exact dependent result type before Phase F can
attach certificates, the user's conditional implementation branch was not
entered.

## Resolved blocker

### PF2-TB01: quotient-first binder-block normalization

**RESOLVED in LNCS-3.**

For each global free-slot renaming, Figure 4 now recursively normalizes every
port. Its `BindBlock` arm chooses a fresh canonical occurrence context,
transports the certified descriptor group, minimizes that complete local orbit,
and returns the result to the enclosing container. Bags then aggregate equal
keys with total multiplicity; Sets then deduplicate. The former
`{b, pi.b}` counterexample therefore always becomes a singleton Set while a Bag
retains multiplicity two.

## Remaining theory blockers

### PF3-TB01: Figure 4 conflates structural trace `xi_n` with dependent certificate `d_n`

Section 3.6 defines kernel extraction as a structural operation that retains
ordered parent paths and container-law steps as `xi_n`. Lemma 8 says that only
after fixing a coherent witness family `w` can this trace be replayed to

```text
d_n^w : EqCert_{T_{Sigma,E}}(
          Gamma_0;
          floor(n)_w,
          iota_n . floor(K_G(n))_w)
```

The graph carrier `G=(U,M,H)` does not contain `w`. Nevertheless, Appendix C.1
replaces the typed certificate with an informal `n =_G iota_n.n_G_down`, and
Figure 4 defines

```text
leaderKernel_G(n) -> (n_G_down, iota_n, d_n)
```

without a witness-family argument or a replay step. There is no inhabitant with
the displayed Lemma 8 endpoint type that this procedure can construct from
`G` and `n` alone. This violates retained invariants 24 and 25: structural
provenance and its dependent replay certificate are distinct, and structural
canonicalization must not consult source witnesses.

**Required repair:** restore two boundaries:

```text
leaderKernelTrace_G(n) -> (K_G(n), iota_n, xi_n)

replayKernelCertificate_{G,w}(n, K_G(n), iota_n, xi_n)
  -> d_n^w
```

The first is structural and deterministic. The second requires coherent `w`,
checks the exact `EqCert` endpoints, and composes retained parent-edge,
container-law, binder, and forward-congruence certificates.

### PF3-TB02: Figure 4 drops required effective-result fields

The main Section 3.6 definition returns

```text
canon_G(n) = (K_G(n), Shape_G(n), sigma_n, iota_n, omega_n, xi_n).
```

At a coherent prefix, Theorem 1 consumes

```text
R_n = (K_G(n), Shape_G(n), sigma_n, iota_n, omega_n, d_n^w)
```

and retains `xi_n` as insertion provenance. Figure 4 instead returns only

```text
(p_min, sigma_min, iota_n, omega_min, d_n).
```

It therefore omits both the exact kernel and the structural trace while also
returning the unconstructible certificate from PF3-TB01. The Appendix C.2 prose
similarly says that the "full result" merely adds `iota_n` and `d_n`, directly
contradicting the main definition and Theorem 1. A typed insertion cannot obtain
its fresh interface witness, replay provenance, or collision endpoints from this
record.

**Required repair:** define a structural result

```text
(K, p, sigma, iota, omega, xi)
```

and a coherent-prefix wrapper

```text
(K, p, sigma, iota, omega, d^w)
```

that retains the structural trace beside the certified insertion provenance.
Only `p` is a hash-cons key.

## Non-blocking editorial regressions

1. Appendix B still lists only four certificate classes and omits the explicit
   source-to-kernel trace/replay obligation.
2. Appendix C.2 no longer states that following a proper certified parent edge
   is distinct from performing an interface restriction. The distinction remains
   explicit in Section 3.7 and Definition 8, so this is an omission rather than a
   contradictory main rule.
3. Appendix C.1 uses informal `=_G` exactly where Definition 7 says a retained
   transition must use the explicit dependent `EqCert` type. Repairing
   PF3-TB01 removes this notation.

## Invariant disposition

All 27 invariants recorded in the LNCS-2 audit remain mandatory. In particular:

- typed embeddings remain injections and typed renamings remain bijections;
- one global free-slot renaming is shared across the complete node;
- invocation and binder-block orbits are minimized locally before Bag/Set;
- every block uses only its complete descriptor-certified `Aut(beta)`;
- `xi_n` is structural provenance, while `d_n^w` is a replayed dependent
  certificate;
- the complete effective result retains kernel, shape, exact and ambient maps,
  and provenance, while only the shape is hash-consed;
- proper parent links and certified interface restrictions remain distinct;
- forward congruence is never inverted; and
- dirty graph state remains unqueryable until deterministic rebuild completes.

LNCS-3 satisfies the quotient-order invariants but violates the two provenance
and result-carrier invariants in its Appendix C pseudocode.

## Verification performed

The repository compiled from current sources against `lib/*`. The isolated
theory suites passed unchanged:

| Suite | Result |
| -- | --: |
| `TheoryFoundationsTest` | 1,052 checks passed |
| `TheoryPortsTest` | 956 checks passed |
| `TheoryStateTest` | 4,193 checks passed |
| `TheoryCanonicalizationTest` | 11,162 checks passed |

These 17,363 checks confirm stability on the earlier guarded domain. They do
not establish LNCS-3 conformance because `K+`/`K0`, first-class `BindBlock`,
strict effective-support results, and structural trace replay are not yet
represented by the Java API.

The refreshed obligation matrix remains structurally valid at 125 unique rows:
50 `EXACT`, 40 `PARTIAL`, 13 `ABSENT`, and 22 `CONTRADICTED`. Every row has the
expected ten columns, and no duplicate obligation identifier was found.

## Implementation gate

No Phase C or Phase E source was changed during this audit. Phase C's new
`K+`/`K0` and first-class `BindBlock` contract is coherent in the main text, but
the requested work was conditional on there being no blockers. Phase E cannot
be finalized while its public result alternates between the main six-field
structural result and Figure 4's five-field certificate-bearing result.

Before implementation resumes:

1. restore the structural trace/replay split in Appendix C.1 and Figure 4;
2. restore the complete structural and coherent-prefix result records;
3. update the insertion and collision prose to consume those records; and
4. rebuild the draft and repeat this gate audit.
