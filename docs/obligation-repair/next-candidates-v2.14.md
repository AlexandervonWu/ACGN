# Next Five Repair Candidates

These are proposed follow-up tasks, not completed repairs or new authority.
They retain their original ledger statements and current partial statuses.
Each needs a general executable Lean contract, a frozen Java/source mapping,
bounded independent observations and rejection controls, and two clean builds.
Existing type, provenance, metric, and certificate boundaries remain intact.

| Order | Requirement | Deliverable | Decisive checks |
| ---: | --- | --- | --- |
| 1 | P2-20 | Recursive same-head flattening linked to exact typed associativity evidence, extending the new registry and existing flat-type work | Mixed heads, missing/wrong A evidence, nested type/path mismatch, preserved order and repeats |
| 2 | A2-07 | Executable exact stored-type-to-relation-view leaf derivation with independent producer/verifier encoding | Mutate every leaf rule, stored type, relation view and proof coordinate; retain explicit `univ` and typed-empty distinctions without fallback authority |
| 3 | A2-11 | Complete dependent-chain index reconstruction connected to the writer and verifier | Independently vary kind, profile, source association, operand types/order, boundary evidence, result, target, version and digest |
| 4 | P2-18 | Witness-specific index construction for permutation, quotient-surjection, splice and unit/deletion evidence | Wrong permutation image, quotient fibers, arities, splice position and exact endpoints; currently unadmitted cases remain unadmitted |
| 5 | P3-03 | Exact profile serialization and independent verifier reconstruction of all five semantic fields | Bitwidth, overflow, temporal/rewrite modes and signature version changed individually; equal spelling must not create profile authority |

## Why These Follow

P2-20 can reuse the fixed registry admission model and the earlier exact flat
typing proof. A2-07 and A2-11 extend the guarded-chain result at its immediate
typed leaf and certificate-index boundaries. P2-18 moves from law admission
to each law's concrete witness. P3-03 isolates the finite profile payload
currently trusted at multiple boundaries. None needs a new rewrite family or
another full-corpus experiment simply to establish the bounded evidence.

The implementation anchors are respectively
`TheoryAlloyAdapter.constructCertifiedFlatOperand`,
`DependentChainTheory.requireLeafTypeProof`,
`DependentChainTheory.proofIndex` / `verifyDependentChain`,
`ContainerLawCertificate.lawIndex`, and
`SemanticProfile.structuralKey` / `verifyAuthorizedProfile`. The original
[traceability matrix](../section3-repair-audit/requirements-traceability.tsv)
records complete source/test references and unchanged claim hashes.

## Boundaries

Do not prove SHA-256 injective: prove structural payload preservation and
check the real digest computation under an explicit cryptographic trust
assumption. Do not promote a finite field-mutation census to whole-JVM or
whole-parser refinement. Any source or evidence change requires a new frozen
input root and new verification; prior PASS does not transfer automatically.

P1-19's coordinated source-row/anchor omission still requires independent
raw-source or external occurrence authority. A-01 still needs authoritative
typed contracts for the complete requirement inventory. Neither is silently
closed by these five candidates. Their wider prerequisites should be handled
as separate work.
