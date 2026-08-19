# Independent Certificate Verifier: Parent-Path Export Handoff

Date: 2026-08-19

Branch: `aislop`

Resolved baseline: `e0e4320766518c110ab0b8c37fe772e02eb04249`

Tracked worktree at entry: clean; unrelated untracked files were preserved

## Result

`CertificateBundleWriter` now exports and the standalone verifier accepts the
smallest retained parent-path slice requested after Phase J. The existing
nullary export remains supported. The extension adds a rigid nonempty typed
context, `ONE_SLOT`, recursive `ONE_TERM`, one direct certified parent edge,
the exact five-event trace, and one complete height-two unfolding.

This remains a finite vertical slice. It is not a claim that every producer
history can be certified.

## Supported Producer Histories

| History | Exact support |
| --- | --- |
| Single fresh | One nullary or slot-only source; identity maps; one height-one root unfolding |
| Parent path | Two `ONE_SLOT` leaves, one direct ground union from the second to the first, unchanged `REBUILD_COMPLETE`, one fresh `ONE_TERM` wrapper, one height-two root unfolding |

The nonempty context has at most one free slot of each type. Its complete
type-preserving renaming orbit is therefore rigid identity. Source context,
support, effective support, class interface, inclusion, sigma, omega, and
shape renaming are equal. No contraction or nontrivial symmetry is inferred.

For the wrapper, the writer emits occurrence path `0/0`, initial and leader
witnesses, the final leader invocation, and every retained edge in producer
order. The edge is reconstructed from an origin-derived ground axiom and is
lifted through `ONE_TERM` and APP with checked `CONGRUENCE` and `TRANS` nodes.
The `KERNEL_REPLAY` premise order is parent paths in reverse term-path order,
edges in path order, then container and structural evidence.

## Trust Boundary

The verifier remains a JDK-17, `java.base`-only module. Producer classes,
`verifyLocal()`, the canonicalizer, and producer hashes are untrusted. Every
proof record is synthesized bottom-up. Snapshot parent records must agree
with the exact witnesses and embedding in their `PARENT_EDGE`; stored shapes
must equal the right endpoint of their replay proof.

The theory digest inside a bundle is only an integrity field. Successful
verification requires the caller to supply the same externally declared
digest out of band. A changed manifest under the old external pin is
`REJECTED`.

Missing exhaustive evidence is `UNCHECKABLE`. Supplied malformed, false,
ill-typed, contradictory, misplaced, duplicate, or noncanonical evidence is
`REJECTED`. The parent-path classifier treats a strict subset of required
occurrences as missing evidence and a path naming a nonexistent occurrence as
malformed evidence.

## Deterministic And Atomic Export

Contexts, embeddings, terms, proofs, snapshots, canonical records, and
unfoldings use collision-checking intern tables and canonical ID order. Term
keys recursively include kind, context, sort, symbol, ordered attributes, and
children. Context slots use verifier order `(type,name)` and embeddings carry
one typed image for every source slot.

All scope/history checks and all encoding complete in memory before the target
path is touched. A successful export writes a sibling temporary file and uses
atomic replacement. Every representable unsupported fixture starts with a
sentinel target and confirms that `IOException("UNCHECKABLE: ...")` leaves its
bytes unchanged.

## Positive Fixtures

`CertificateBundleWriterTest` builds:

1. the original nullary fresh insertion;
2. a nonempty `ONE_SLOT` insertion over `canonicalFree(T,0)`; and
3. `left`, `right`, their direct ground union, rebuild, and `wrap(ONE_TERM
   invoke(right))`, retaining one edge and a complete height-two tree.

`ProducerBundleInspectionTest` decodes producer bytes only through the
standalone codec. It checks byte determinism, FULL and nullary PAIR results,
typed contexts, exact schemas/operators, one ground axiom, recursive terms,
proof variants, the sole nonempty `0/0` path, leader resolution, all five
events and six snapshots, and the exact child of the height-two unfolding.

## Adversarial Matrix

| Mutation | Result |
| --- | --- |
| Required path omitted | `UNCHECKABLE / INCOMPLETE_PARENT_PATH` |
| Wrong occurrence path | `REJECTED / INCOMPLETE_PARENT_PATH` |
| Wrong initial witness | `REJECTED / INCOMPLETE_PARENT_PATH` |
| Wrong leader witness | `REJECTED / INCOMPLETE_PARENT_PATH` |
| Wrong final invocation | `REJECTED / INCOMPLETE_PARENT_PATH` |
| Duplicate path | `REJECTED / NONCANONICAL_ENCODING` |
| Descending/reordered paths | `REJECTED / NONCANONICAL_ENCODING` |
| Duplicate/reordered edge evidence | `REJECTED / INCOMPLETE_PARENT_PATH` |
| Non-parent proof used as an edge | `REJECTED / INCOMPLETE_PARENT_PATH` |
| Ill-typed, missing, duplicate, or false-kind embedding | `REJECTED` |
| Omitted free renaming/leader coverage | `UNCHECKABLE`, never success |
| False orbit, term, type, context, proof, transition, or unfolding evidence | `REJECTED` |
| Mutated axiom/manifest under the retained external pin | `REJECTED` |
| Unknown or malformed proof evidence | `REJECTED`, never `UNCHECKABLE` |

The standalone suite retains its earlier mutation coverage for proof order,
composed embeddings, orbit generators, contexts/types, manifests, malformed
variants, transitions, and finite unfoldings. No verifier rule was added or
relaxed for producer output.

## Residual `UNCHECKABLE` Producer Matrix

| Producer state | Why it remains outside this patch |
| --- | --- |
| `INSERT_COLLISION` | Requires collision replay and collision transition serialization |
| `ADD_SYMMETRY` | Requires complete nontrivial generator closure and SC history |
| Interface restriction | Requires contraction transport and versioned interface history |
| `REBUILD_RECORD` | Requires exact changed-record/collision replay |
| Path compression | Requires every original edge and composed replacement proof |
| Support contraction | Requires nonidentity support maps and restricted witnesses |
| Nonidentity sigma/omega | Requires complete alpha-action/orbit evidence |
| Repeated same-type free slots | Requires exhaustive type-preserving permutations |
| Seq/Bag/Set | Requires retained occurrence normalization and certified laws |
| Bind/BindBlock | Requires binder descriptors, actions, and automorphism evidence |
| Cyclic unfolding | Not a finite `Rep` witness; rejected by producer constructors/guard |
| Multiple root unfoldings | Current publication slice requires exactly one complete root |
| Indirect parent derivation | Current bridge admits only a direct ground equation/rewrite |
| Any other event/history | Cannot be omitted or invented while preserving exact replay |

## Commands And Results

```bash
scripts/run_certificate_bundle_writer_tests.sh \
  /tmp/acgn-certificate-bundle-writer-final
```

Result: verifier dependency `java.base`; `VerifierTest` 53 checks;
`CertificateBundleWriterTest` 59 checks; `ProducerBundleInspectionTest` 23
checks; three producer fixtures `VERIFIED` under FULL; nullary pair
`VERIFIED`.

```bash
scripts/run_certificate_verifier_smoke.sh \
  10 /tmp/acgn-certificate-verifier-followup-smoke
```

Result: 10 preparations exported twice byte-identically, all FULL verified,
and PAIR verified. Theory digest:
`3e74f5c1f1ea3208245671e0669def6a58cf28b953e7f004a1fa025d568ced7c`.

The full repository compiled with:

```bash
javac --release 17 -encoding UTF-8 -cp 'lib/*' \
  -d /tmp/acgn-phase-j-followup-build \
  $(find src -name '*.java' -type f | sort)
```

Required unchanged theory suites passed:

| Suite | Checks |
| --- | ---: |
| `TheoryCertificatesTest` | 251 |
| `TheoryCoherentInsertionTest` | 18 |
| `TheoryRebuildTest` | 101 |
| `TheoryFiniteUnfoldingTest` | 424 |

`scripts/build_certificate_verifier.sh` and both verifier test scripts compile
with explicit UTF-8. Its `jdeps -summary` result is exactly:

```text
acgn-certificate-verifier.jar -> java.base
```

## Remaining Risk

The positive parent fixture has one rigid slot and one edge. It does not test
permutation enumeration, edge chains, contracted support, containers,
binders, collisions, or history-bearing rebuild records. Extending any of
those cases requires retained producer evidence and matching independent
adversarial tests; it must not be approximated from final hashes or snapshots.
