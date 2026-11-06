# Fast Rewrite parity repair

This repair targets the 14 source-backed CORRECT pairs in
`../fast-rewrite-certificate-equality-audit.json`. That file records the
before-repair evidence, not new experimental results.

## Specification

Fast comparison receives a detached matrix projection after NormalForm has
finished normalization and frozen its source evidence. The original matrices,
temporal ownership, parser evidence, and certificate input remain unchanged.
The metric still uses its existing binding alignment, ordered edits, and
minimum-cost unordered assignment. There is no certificate-zero shortcut.

1. Unary Boolean relation tests have one operand regardless of the source
   parser's variadic presentation. Normalize that presentation before existing
   Boolean Set flattening, duplicate removal, and singleton elimination.
2. Normalize JOIN to left association only when the middle relation has at
   least two columns and all four relevant applications agree with exact,
   parser-authenticated relational type equations from the same module.
   Preserve order; a unary middle relation remains a barrier.
3. Alpha-normalize matrix-local binders by lexical depth and coordinate.
   Split nondisjoint comprehension declarations into individual coordinates;
   keep coordinate order, domain, multiplicity, and disjoint groups intact.
   Preserve prenex and temporal-import identities. Local binders containing
   temporal references are outside this additional alpha normalization.

## Proof correspondence

`Model.lean` checks presentation erasure, Boolean idempotence, ordered
declaration grouping, comprehension extensionality, lexical shadowing and
coordinate retention. Its JOIN theorem imports the existing typed relational
reassociation proof, together with the unary-middle counterexample, from
`PhaseA2DependentChains.lean`. The only reported standard axiom is `propext`;
there are no new axioms, `sorry`, or `unsafe` declarations.

These are mathematical laws, not a machine-checked refinement of arbitrary
Java execution. Java correspondence is checked by source-backed regressions,
type/provenance guards, distinct-slot negative tests, and unchanged certified
observation digests. No static bootstrap certificate theory is extended.

Run `./scripts/run_fast_rewrite_parity_tests.sh` from the repository root.

## Implementation correspondence

- `EGraphNode.FastComparison.copy` materializes invocation slot maps, uses a
  lexical scope environment for local names, and preserves ordered declaration
  domains. Disjoint declaration blocks and temporal-import identities remain
  distinct. Unary presentation erasure precedes the existing duplicate-key
  operation, so recursively equal Boolean operands can finally collapse.
- `FastComparison.leftAssociateJoin` implements only the guarded relation law.
  It derives both intermediate types and compares both resulting types using
  `ExactAlloyType.parserCertifiedRelationalJoin`; absent or incompatible parser
  evidence leaves the original association in place.
- `NormalForm.fastComparisonView` and `CanonicalDistance.prepare` supply the
  detached comparison matrices to the established metric. Sizes, distance,
  and edit descriptions use that same projection. `CanonicalAlloyPipeline`
  renders the retained source forms for certificate input, not the Fast view.

## Bounded validation

Verified on 2026-11-06 with the reproduction script (exit 0):

- Lean: all 12 local theorem declarations checked, plus the imported dependent
  chain development; no new axioms or proof placeholders.
- `FastRewriteParityTest`: 199 checks passed.
- `EGraphSaturationTest`: passed.
- `TheoryDependentChainTest`: 149 checks passed.
- `CanonicalAlloyPipelineTest`: 2,041 checks passed.

The regression checks all 14 archived sources against their SHA-256 values,
zero distance in both directions, matching comparison sizes, no-op edit paths,
unchanged certified observation digests, unchanged retained input text, and
the source Alloy equivalence assertions (SAT4J, at each source command's scope).
The same suite covers unary-middle JOIN nonassociativity, comprehension column
order, grouping, disjointness, differing domains, lexical shadowing, field
ownership, and temporal endpoints. It also rechecks the ten historical
incorrect-to-truth pairs: all remain positive under both paths.

This is a targeted repair validation, not a full-corpus rerun or a claim that
Fast Rewrite and Certificate-Integrated equality coincide globally. The
published results and the pre-repair audit JSON are deliberately unchanged.
