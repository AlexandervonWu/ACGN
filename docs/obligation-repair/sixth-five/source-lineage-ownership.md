# A2-14 source lineage ownership

Candidate for `Transfer lineage is functional and one certificate cannot replay over two roots.`
The original ledger statement has SHA-256 `155ae3d4bcacf2992bc8fe1294c8ee5f6f5a550e0f246617a3a284c6e66c39c3` at commit `eb5f4f664f46a23194bf38161a79000cceeff016`.

## Proven ownership property

An original is the Java object that received its own fresh lineage. An authorized snapshot or repair copy can be a different physical object with that same lineage. The formal result concerns the original behind each accepted copy. Equal payloads place no restriction on the number of originals. A structural wire certificate by itself carries no globally unique process identity.

| Construction in the pinned Java source | Lean representation |
|---|---|
| `EGraphNode.nextSourceOccurrenceLineage`, constructor, and identity-visited reseeding | `allocate` uses the positive signed-long serial position of an event. Gaps account for allocations outside the observed sources. Equality of two issued lineages derives equality of allocation position and owner. |
| `NormalForm.normalize` reseeds then snapshots with `cloneEGraph`. `preserveSourceOccurrenceLineageFrom` and `copyPayloadTo` keep lineage. | `Built.birth` and `Built.copy` generate images. Induction derives a common allocation witness. The ghost owner tracks origin; replay guards inspect only lineage and contents. |
| `TheoryAlloyAdapter.Builder.indexSourceOccurrencePaths` traverses retained roots in phase/child order and rejects ambiguous object reuse. | `frozenAt` selects a finite tree position after checking distinct physical object identities. An absent phase, child or matrix fails lookup. |
| `DependentChainSourceBinding` checks positivity and compares the supplied certificate against the committed path, typed key and source content. | `bindOriginal` retains the exact structural commitment. Issuing the same certificate at two positions in one forest forces the two positions to coincide. |
| `transferTo` checks source lineage and transfer content and binds the current repair content. `requireMatches` checks lineage, bound raw content and transfer content again. | `transferTo` and `checkMatches` derive unique original ownership for two successful transfers or rechecks. A copy can change raw contents on transfer if its transfer contents agree. |

The proof uses a single positive counter epoch, so it does not model recovery after the signed atomic counter has wrapped through its entire negative range. It uses immutable finite snapshots, object-identity tokens and equality of structural content values. Repeated physical identities in the retained forest fail its index. Cycles and concurrent mutation are outside the representation. The path theorem is relative to one forest. The runtime guard against substituting a different forest is `Result.requireRepairProjectionSources`, called by `RepairProjection.from`.

## Executable checks and boundary

`SourceLineageOwnershipTest` exercises public Java operations. It checks 64 fresh equal-payload allocations, distinct roots with equal source content at two sibling positions, both cross-binding rejection directions, reseeding and authorized snapshot reuse, frozen-source mutation rejection, a foreign phase object, and a permutation of two parsed temporal phases. Each negative case requires the expected exception class and diagnostic.

The Java runs establish the premises on these fixtures. A general refinement from every mutable JVM heap and rewrite route to the inductive construction remains open. In particular, the proof does not show that every Java lineage assignment is covered by birth or authorized copy, that every normalized shared input has a unique original per retained address, or that the adapter's duplicate-lineage plan merging preserves original paths for all inputs. It also does not reconstruct original identities from exported certificate bytes. Public certification and the parent ledger status remain blocked.

Run `lean docs/obligation-repair/sixth-five/SourceLineageOwnership.lean` with the checkout's Lean 4.35.0. Compile `SourceLineageOwnershipTest.java` alongside the checkout's producer and verifier sources against `lib/*` on JDK 17 and run `is.fivefivefive.CanDis.theory.SourceLineageOwnershipTest` with assertions enabled.
