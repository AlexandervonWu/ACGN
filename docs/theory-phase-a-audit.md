# Phase A Theory-Conformance Audit

## Scope

This audit compares the Java artifact at commit
`a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d` with the formal construction in
`E_Graphs_Draft_LNCS.pdf` (SHA-256
`77ea879143f4b593c62a147ba78ffc4da5854815d73a5437865d11196f532a6d`).
The paper is normative. The attached mission was used only to define the audit
procedure, required evidence, and implementation gates; it was not treated as
an additional formal definition.

Phase A made no behavioral implementation changes. It inspected the complete
paper definitions, Theorem 1 obligations, Appendix C algorithm/rules, current
graph paths, mutation boundaries, and unchanged regression behavior.

## Deliverables

- [Theory-to-artifact obligation matrix](theory-artifact-matrix.md): 120
  individually evidenced obligations.
- [Architecture map](theory-architecture-map.md): current dataflows, formal
  state mapping, complete graph-relevant mutation inventory, required exact
  boundary, and phase dependencies.
- This prioritized mismatch list and baseline report.

## Matrix Summary

| Status | Rows |
| -- | --: |
| `EXACT` | 3 |
| `PARTIAL` | 38 |
| `ABSENT` | 31 |
| `CONTRADICTED` | 47 |
| `UNCERTAIN` | 1 |
| **Total** | **120** |

The three `EXACT` rows concern the existing ordered normalization pipeline,
branch connective/NNF rewriting, and temporal phase discipline (`RW-01`,
`RW-03`, `RW-04`). They do not establish that the graph engine realizes the
formal state.

## Prioritized Mismatches

| Priority | Mismatch | Formal impact | Evidence | First resolving phase |
| -- | -- | -- | -- | -- |
| P0 | Slots, contexts, embeddings, invocations, and outputs are not graph-level typed values | Defs. 1-2, Cor. 2, and all later state invariants cannot be enforced | `TY-*`, `EMB-*`, `INV-*` | B |
| P0 | The implementation conflates embeddings with renamings and stores union-find correspondence in the opposite direction | Inversion, composition, support, `find`, and path compression do not implement Defs. 2 and 5 | `EMB-01`-`EMB-05`, `UF-01`, `UF-04` | B, then D |
| P0 | `One`, `Seq`, `Bag`, `Set`, and `Bind` are not explicit port types; generic constructors bypass normalization | Node grammar, support, and flat-construction premises are not represented | `PORT-*`, `FLAT-*` | C |
| P0 | No concrete e-class state contains all of `(tau_a,S_a,B_a,G_a)`, and no production `H` exists | The artifact cannot currently correspond directly to `G=(U,M,H)` | `STATE-*`, `HC-*` | D |
| P0 | Equality-producing mutations accept no typed certificates | EC, PC, SC and Theorem 1 obligations 4, 8, and 9 cannot be reconstructed | `CERT-*`, `UNION-*`, `T1-04`, `T1-08`, `T1-09` | F |
| P0 | Same-leader unions infer symmetry; endpoint mismatches infer symmetry/redundancy | Directly contradicts Theorem 1 obligations 5 and 7 and can introduce unjustified equalities | `UNION-03`, `UNION-04`, `CONG-01`, `T1-05`, `T1-07` | F |
| P0 | Interfaces shrink by syntactic intersection/compaction without factorization evidence | Violates the certified restriction premise of Theorem 1 obligation 6 | `REST-*`, `T1-06` | F |
| P0 | Canonicalization is untyped, bounded, and does not enumerate one global node-wide free-slot renaming | `canon_G` exactness is not established; independent local keys can collapse the wrong set elements | `CAN-02`-`CAN-06`, `ALPHA-*` | E |
| P0 | Rebuild is a capped whole-graph scan and collision unions lack congruence proofs | Quiescence and hash-cons reconstruction do not implement section 3.7 or Prop. 3 | `REB-*`, `HC-02`, `T1-08` | G |
| P1 | Shape storage omits exact slots, ambient support, exposed interface, and instantiating witness | The `B_a` witness relation and finite-unfolding proof data are unavailable | `STATE-04`, `STATE-05`, `FIN-*` | D, then H |
| P1 | Binder automorphisms omit complete domain/dependency descriptors and provenance | Same-typed but semantically incompatible bindings can be permuted | `BIND-*`, `CAN-07` | E-F |
| P1 | Support is guessed from parser/alpha names instead of defined structurally on typed graph values | Support equivariance and safe restriction cannot be checked | `SUP-*` | B-C |
| P1 | The structural total order omits formal type/schema/witness fields and has one unresolved completeness question | Determinism is observed only for the current representation | `ORD-*`, `CAN-09` | C-E |
| P1 | There is no graph-wide dirty/quiescent query contract or invariant checker | Clients can neither prove nor diagnose the formal quiescent state | `HC-02`, `HC-03`, `CHK-*` | G |
| P2 | Existing tests are primarily handwritten behavior regressions, not generated algebra, mutation fuzzing, or differential canonicalization | Passing legacy tests cannot establish the formal obligations | `TEST-*` | B-H |
| P2 | The Alloy and experiment adapters have no separately named exact engine path or complete theory manifest fields | A future exact engine could be confused with legacy slotted measurements | `INT-*` | I |

The sole `UNCERTAIN` row is `ORD-02`: current string keys appear deterministic
for observed values, but no complete audit proves that every structurally
relevant field is represented and independent of unspecified collection or JVM
ordering. Phase C must replace this with an explicit total structural order.

## Baseline Tests

The baseline was run before documentation edits, with the implementation
unchanged, at `2026-08-16T12:40:21-05:00` on OpenJDK `17.0.19`.

| Check | Command | Result | Evidence |
| -- | -- | -- | -- |
| Full Java compile | `javac -cp 'lib/*' -d /tmp/acgn-theory-audit-build $(find src -name '*.java')` | PASS | Exit 0 |
| Existing e-graph regressions | `java -cp '/tmp/acgn-theory-audit-build:lib/*' is.fivefivefive.CanDis.EGraphSaturationTest` | PASS | Test main completed without failure |
| Ablation engine regressions | `java -cp '/tmp/acgn-theory-audit-build:lib/*' is.fivefivefive.CanDis.ablation.EGraphAblationTest` | PASS | Test main completed without failure |
| Backtranslator unit regressions | `java -cp '/tmp/acgn-theory-audit-build:lib/*' is.fivefivefive.CanDis.CanonicalBacktranslatorTest` | PASS | Test main completed without failure |
| MASG type regressions | `java -cp '/tmp/acgn-theory-audit-build:lib/*' is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest` | PASS | Test main completed without failure |
| Bounded parser-to-backtranslation smoke | `java -cp '/tmp/acgn-theory-audit-build:lib/*' is.fivefivefive.CanDis.CanonicalBacktranslationEquivalenceTest classified-data --limit 10 --scope 3 --output /tmp/acgn-theory-audit-backtranslation.json` | PASS | 20 predicates from 10 files; 0 mismatches; 0 failures |

These results are a compatibility baseline only. They do not discharge a row
whose required representation, certificate, invariant checker, or adversarial
test is absent.

## Gate A Decision

**PASS for Phase A deliverables.** The required matrix, architecture map,
prioritized mismatch list, and unchanged baseline results now exist and are
cross-linked.

**Theory-faithful engine acceptance remains closed.** There are 117 unresolved
mandatory rows. No claim is made that the current Java graph is an executable
realization of the paper.

## Theory Blockers

`NONE` identified in Phase A. The inspected discrepancies are implementational
obligations or explicitly acknowledged artifact gaps, not contradictions that
make the formal construction impossible to implement.

## Next Dependency

Phase B must begin with the immutable type/slot/context algebra, followed by
typed embeddings, renamings, permutations, invocations, and structural support.
No e-class, canonicalizer, union, or certificate refactor should precede tests
that establish this foundational map algebra and its direction.
