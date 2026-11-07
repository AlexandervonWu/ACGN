# Type-Partitioned Permutation Generator

The following records the initial declaration-local refactor. The subsequent
`slotted-independent-binding-blocks-v3` extension combines eligible independent
blocks before generation; its current scope and Lean laws are specified in
[Independent Bind-Block Combination](independent-binding-blocks.md). Historical
candidate counts and measured results below retain their original scope.

The generator takes a scope-resolved term and constructs its admissible blocks
before enumerating any candidate. A block is one existing symmetric declaration
and one exact slot type. The untyped treatment uses the empty erased type key.
No scope, declaration, quantifier, or disjointness boundary is combined.

For blocks B1 through Bn, candidates range over the Cartesian product of their
permutation groups, not the symmetric group on their union. A mixed eight-slot
interface containing four A and four B slots admits 4! * 4! = 576 mappings,
not 8! = 40,320. Homogeneous groups retain all their permutations. Candidates
are streamed, with the existing 40,320 bound in production and external process
deadlines on the uncapped synthetic path.

`PartitionedPermutation.lean` was checked before the Java refactor. Its four
axiom-free lemmas establish key preservation, cross-partition exclusion,
representation of every key-preserving mapping by fiber-local maps, and joint
scope/type preservation. The key abstracts the declaration/scope and type pair.
The Java test separately exhausts finite example spaces and checks bijectivity,
uniqueness, counts, same-type coverage, and erased controls. The Lean file is
not a machine-checked refinement of Java enumeration or its finite search cap.

This centralizes an existing caller-side partition rule in the generator; it
does not claim that the previous mixed smoke actually enumerated S8 for a
4+4 witness. That smoke already used 576 candidates in each arm, because its
two source declarations were independently homogeneous. This change must not
manufacture a speedup by widening the untyped scope or dropping legitimate
within-type combinations.

## Validation on 2026-11-06

- Four new Lean lemmas passed; all report no axioms.
- `SlotPermutationSearchTest`: 829,672 assertions passed, including 576 typed
  versus 40,320 erased candidates for an internal mixed-color eight-slot block,
  16 candidates for four two-slot type groups, and one for eight distinct types.
- Mixed-color single-declaration terms are generator unit inputs, not a claim
  that Alloy gives different declaration types to names in the same raw decl.
  Parsed Alloy controls separately retain same-domain declaration separation,
  disjointness groups, and alternating quantifier boundaries.
- Existing gates passed: 40 slot tests, 66 mixed/source/solver checks, 18
  synthetic construction checks, and the baseline e-graph regression main.
- Mixed smoke replay completed in 28.21 seconds. All 66 scheduled outcomes
  matched the prior run, including four AST-identical skips. All 30 successful
  comparison rows retained distances and structural counters; all 32 uncapped
  synthetic construction representation hashes were identical.
- Artifact checksum verification and `git diff --check` passed.

Local evidence is under
`/media/augustus/8618-0ED0/ACGN/intermediate/partition-generator-20261106/`.
The new test is registered in the slot-specific test script and bounded Java
CI. The full bounded CI script and the full corpus were not rerun in this pass.

## Requested Confirmation Rerun

A fresh run at `mixed-smoke-partition-confirm-20261106` on the same external
drive completed in 27.88 seconds. Source, compiled-class, library, and proof
hashes matched the prior run. All 66 outcomes matched: 30 successful comparison
rows, four AST-identical skips, and 32 successful independent constructions.
Distances, graph counters, and all representation hashes were unchanged.
Four Lean files and five Java test mains passed again; no timeout, exception,
OOM, or synthetic expected-relation mismatch occurred. Checksums passed.

Median engine times (untyped / typed): natural pair comparison 8.250 / 9.566 ms;
synthetic pair comparison 14.068 / 18.708 ms; independent synthetic construction
12.679 / 14.973 ms. These are another small exploratory sample, not evidence of
a general typed speedup. Same resource policy: one worker, 1 GiB JVM heap,
15-second deadlines, a 3 GiB no-swap scope, and machine-local external outputs.
