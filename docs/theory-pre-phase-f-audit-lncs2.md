# Pre-Phase-F Theory Blocker Audit: LNCS-2

## Audit identity

- Date: `2026-08-16`
- Normative draft: `/home/augustus/桌面/E_Graphs_Draft_LNCS-2.pdf`
- PDF SHA-256: `4e83fd4039216988877527438db0999dbe29dd24029f73b46de3d882e5d57f33`
- Previous audited draft SHA-256:
  `6e44bae88fcd82fd9cd26db54d52025affb9f7d21d5cc3a2165211ab52a9d42f`
- Repository HEAD: `f0e326ab41fbdda9e21b36cb11aecc1863d9712d`
- Worktree: dirty; content is identified by the hashes and paths above
- Scope: Definitions 1-8, Lemmas 3-8, Corollaries 3-4, Sections 3.6-3.7 and 4,
  Theorem 1, Appendix B, and Appendix C.1-C.2/Figure 4

The draft was treated as formal content, not as operational instructions.

## Decision

**NO-GO for Phase F implementation yet.**

The three blockers found in `theory-pre-phase-f-audit.md` are repaired in the
core theory. One new internal mismatch remains between the quotient-first
canonicalizer proved in Section 3.6 and the executable pseudocode in Figure 4.
In addition, the revised draft changes the Phase C and Phase E contracts, so
those implementation gates must be brought forward before Phase F attaches
certificates to their values.

This is a much narrower no-go than the previous audit: the effective-support
and certificate theorem are now coherent. The remaining formal repair is local
to binder-block canonicalization in Figure 4.

## Prior blockers

| Previous blocker | LNCS-2 status | Evidence |
| -- | -- | -- |
| PF-TB01: main `canon_G` used pre-find support | **RESOLVED** | Section 3.6 defines `K_G(n)`, `Delta_n`, `iota_n`, `omega_n`, and effective-support Corollary 3 |
| PF-TB02: insertion full-support conflict | **RESOLVED** | Section 3.7 and Theorem 1 item 1 allocate the fresh interface as `Delta_n`; the proof stores the kernel witness and returns `iota_n * a` |
| PF-TB03: `d_n` had no formal type | **RESOLVED** | Definition 7 introduces dependent `EqCert`; Lemma 8 types and proves `d_n`; Corollary 4 composes both kernel certificates at collisions |

The strict-support counterexample is now handled without weakening `TRen`:

```text
sigma_n : Can(Delta_n) -> Delta_n                 (TRen)
iota_n  : Delta_n -> Gamma_0                      (TEmb)
omega_n = iota_n o sigma_n                        (TEmb)
d_n : EqCert(Gamma_0; [n]_w, iota_n . [K_G(n)]_w)
```

Corollary 4's composition is well typed. For
`rho = sigma_n' o sigma_n^-1`, the compatibility equation
`e o iota_n = e' o iota_n' o rho` aligns the middle endpoint of the first
weakened kernel certificate with the source of the collision certificate.

## Remaining theory blocker

### PF2-TB01: Figure 4 is not quotient-first for binder blocks

Section 3.6 adds the first-class schema `BindBlock(beta,kappa)` and defines
`Q_G` to normalize each block occurrence locally:

```text
bind_beta min_{pi in Aut(beta)} Q_G((id oplus pi) . q).
```

This local orbit minimum is computed before an enclosing Bag re-aggregates
multiplicities or an enclosing Set removes quotient-equal elements. Lemma 4
and its proof depend on that order.

Figure 4 instead:

1. enumerates `delta in AutBind(K)` outside all port recursion;
2. applies a whole-node binder choice before building a candidate; and
3. has no `BindBlock` arm in `canonLeaderPort_G` at all.

The mismatch is observable. Let `Aut(beta)={id,pi}`, let

```text
b  = bind_beta q
b' = bind_beta ((id oplus pi) . q),
```

with `b` and `b'` structurally different. For a Set containing `{b,b'}`, the
proved `Q_G` maps both occurrences to the same local orbit minimum and returns
a singleton. The Figure 4 loop either never makes the block values equal, if
one global permutation is shared, or includes both singleton and two-element
candidates, if choices are independent. Because the global shape order is
arbitrary, the two-element candidate may be selected. This is the same
quotient-before-minimum failure that the new draft correctly identifies for
leader invocations.

**Required paper repair:** remove the outer `AutBind(K)` candidate loop and add
a recursive `BindBlock` case that alpha-converts the occurrence context and
returns the local least complete `Aut(beta)` orbit before the enclosing
Bag/Set case sorts, aggregates, or deduplicates. The invocation and block cases
must use the structural port order used by `Q_G` (`triangleleft`), while the
completed node uses the shape order (`prec`).

After that edit, Figure 4 implements the main `Q_G` definition and the
counterexample collapses independently of the chosen global shape order.

## Non-blocking specification details

These do not invalidate Theorem 1, but should be made explicit before claiming
deterministic executable correspondence:

1. `canon_G` chooses "one corresponding" `sigma_n` when several witnesses
   produce the same least shape. Specify a total witness-map tie-break or a
   deterministic enumeration order.
2. Different `BindBlock` occurrences use fresh alpha-variants of `Delta_beta`.
   The executable value should carry its occurrence bound context and the
   typed bijection to the descriptor's canonical context, especially for nested
   occurrences of the same descriptor.
3. Appendix B still lists four retained proof-object classes. Its checklist
   should explicitly include the replay trace/source-to-kernel `d_n` obligation
   introduced by Lemma 8 and Theorem 1 item 1.

## Reopened implementation gates

The Java package remains sound on its earlier, guarded domain, but it does not
yet implement the LNCS-2 carriers.

### Phase C deltas

- `PortSchema` has no `BindBlock` variant.
- Seq/Bag/Set schemas do not distinguish `K+` from `K0`; empty admissibility is
  currently checked later through an operator-law declaration.
- There is no immutable block descriptor, occurrence bound context, or
  descriptor-indexed certified automorphism carrier.

### Phase E deltas

- `CanonicalizationResult` still stores only `(source, shape, sigma)`.
- `LeaderNormalizer` returns syntax only, without `K_G(n)`, `iota_n`, or
  replay trace `xi_n`.
- both canonicalizers reject strict support contraction instead of returning
  the effective result.
- `ExhaustiveGraphCanonicalizer` enumerates the Cartesian product of occurrence
  symmetries and minimizes complete candidates. LNCS-2 requires each local
  quotient orbit to be minimized before Bag aggregation and Set deduplication.
- neither canonicalizer handles first-class binder blocks or the certified
  wrapper producing `d_n`.

The current production canonicalizer already takes a local minimum for each
leader invocation, which is the right shape for the new `Q_G`, but the
independent reference implementation and the missing block/effective-result
paths must be repaired and differentially tested before Gate E can close again.

## Invariants retained and extended

All twenty invariants in `theory-pre-phase-f-audit.md` remain active. LNCS-2
adds or sharpens the following:

21. `K+` excludes the empty container in the schema; `K0` admits it only with
    a certified unit law.
22. `BindBlock(beta,kappa)` is a first-class port constructor. Each occurrence
    has a fresh typed bound context, a complete descriptor, and only the
    certified group `Aut(beta)`.
23. Canonicalization is quotient-first. Leader and binder-block orbits are
    locally minimized before Bag multiplicities are aggregated or Set elements
    are deduplicated.
24. Structural kernel provenance `xi_n` is distinct from its replayed dependent
    certificate `d_n`; neither is a hash-key component.
25. The structural canonicalizer returns the exact kernel, shape, `sigma_n`,
    `iota_n`, `omega_n`, and `xi_n`; the coherent-prefix wrapper replays
    `xi_n` to `d_n` before insertion or collision.
26. A shape collision uses effective-support exactness plus Corollary 4. It
    composes both source-to-kernel certificates and never invents a renaming
    between unequal original supports.
27. A proper parent edge and an interface restriction remain distinct certified
    operations: PC can justify the former without mutating the historical
    interface, while the latter separately requires the restriction equation and
    complete transport.

No previous invariant is relaxed: embeddings remain injections, renamings
remain bijections, symmetry remains separately certified, congruence remains
forward only, and dirty state remains unqueryable.

## Verification performed

The full repository compiled from current sources on OpenJDK 17 with 25
pre-existing `-Xlint` warnings and no errors. The existing exact-package suites
passed unchanged:

| Suite | Result |
| -- | --: |
| `TheoryFoundationsTest` | 1,052 checks passed |
| `TheoryPortsTest` | 956 checks passed |
| `TheoryStateTest` | 4,193 checks passed |
| `TheoryCanonicalizationTest` | 11,162 checks passed |

These 17,363 checks establish that the earlier implementation remains stable;
they do not establish LNCS-2 conformance because `K+`/`K0`, `BindBlock`,
effective-result replay, and quotient-first reference cases are not yet
representable.

The updated obligation matrix contains 125 rows: 50 `EXACT`, 40 `PARTIAL`,
13 `ABSENT`, and 22 `CONTRADICTED`. The reopened rows describe missing LNCS-2
work; they do not reclassify the passing behavior on the earlier guarded domain
as unsound.

## Phase F entry condition

Before Phase F:

1. repair Figure 4 as specified by PF2-TB01;
2. reopen Phase C for `K+`/`K0` and `BindBlock`;
3. reopen Phase E for effective results, kernel traces, quotient-first reference
   and production canonicalizers, and strict-support differential tests; and
4. require the revised Phase C/E matrix rows and adversarial tests to pass.

Once those steps are complete, Definition 7, Lemma 8, Corollary 4, and
Theorem 1 provide a coherent formal basis for Phase F certificate carriers and
certified mutations.
