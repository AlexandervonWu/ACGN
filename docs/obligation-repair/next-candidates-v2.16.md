# Next Five Bounded Repair Candidates

Historical task specification recorded at v2.16. The implementation and
bounded verification record are now in [fifth-five](fifth-five/README.md).
The original proposal and its limitations are retained below.

These follow the five completed v2.15 repairs. The v2.16 temporal solver fix
does not discharge additional original assurance requirements. These remain
proposed, separately scoped tasks, not completed repairs or new authority.

| Order | Requirement | Next deliverable | Decisive checks |
| ---: | --- | --- | --- |
| 1 | P3-04 | Connect the complete law-record wire payload to independently reconstructed registry indices | Change operator, types, carrier, path, policy, parameters, endpoints or theory digest; reject recomputed-but-wrong records |
| 2 | P3-05 | Refine the complete flat-record decoder and recursive replay, beyond the already proved splice indices | Omit, duplicate, reorder or substitute source-tree, splice and trace fields; reconstruct the expected output independently |
| 3 | P3-06 | Refine container-record decoding and exact input/output/fiber reconstruction | Preserve Seq order and Bag multiplicities; distinguish Set quotienting; reject missing occurrences, wrong fibers and mismatched endpoints |
| 4 | P3-12 | Formalize canonical table grammar, ordering and content-ID preimages, then connect writer and verifier | Duplicate IDs, unsorted rows, malformed grammar, changed content with recomputed IDs, and writer/verifier encoding disagreement |
| 5 | A2-12 | Deterministic phase/child occurrence paths and exact dependent-source content commitments | Same-typed source swaps, duplicate occurrence ownership, association/content changes and post-certification mutation |

## Why These Are Feasible

P3-04 can reuse v2.15's exact law-index and profile-payload models; the new
work is the full independently decoded wire record. P3-05 and P3-06 extend
the proven recursive splice and quotient witnesses to the enclosing replay
records. P3-12 supplies the common canonical-table layer these decoders use.
A2-12 connects the already represented phase/child path and source-content
key to actual producer traversal and independently checked content.

The source anchors are respectively:

- `ContainerLawCertificate.lawIndex` and `SemanticEvidenceVerifier.verifyLawRecord`.
- `FlatConstructionCertificate.splices/containerTrace` and `SemanticEvidenceVerifier.verifyFlat`.
- `ContainerConstructionCertificate.inputOccurrences/containerTrace` and `SemanticEvidenceVerifier.verifyContainer`.
- `CertificateBundleWriter.sortedSection`, `Bundle.indexedTable/contentId`, and the wire codec.
- `TheoryAlloyAdapter.indexSourceOccurrencePaths/sourceOccurrenceCommitment/requireMatches` and `EGraphNode.dependentChainSourceContentCommitment`.

The [original claim ledger](../section3-repair-audit/claim-ledger.md) and
[traceability matrix](../section3-repair-audit/requirements-traceability.tsv)
remain authoritative. P3-04/05/06/12 are currently PARTIAL/DIRECT; A2-12 is
PARTIAL/PARTIAL. Delivering a bounded slice must not silently strengthen or
replace those original statements, or duplicate evidence already counted
under P2-18, P2-20, A2-07, A2-11 and P3-03.

## Acceptance Boundary

Each candidate needs an executable general Lean contract, mechanically
resolved Java/source mapping, independent observed vectors, wrong-field
and supported-path counterexample controls, and two clean deterministic
builds under frozen inputs. Any actual producer/verifier fix triggers the
affected regression and experiment reruns before release.

Prove encoding structure and exact preimages; retain SHA-256 as an explicit
trust assumption rather than claim hash injectivity. The A2-12 task binds
the retained certified source tree, not an unauthenticated reconstruction of
every raw Alloy occurrence. P1-19's independent raw-source authority boundary
and A-01's complete contract-registry prerequisite remain separate work.
Universal parser/JVM refinement is not promised by this finite task list.
