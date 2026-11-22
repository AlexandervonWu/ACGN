# P3-13 retained artifact reads

The frozen parent asks whether certified artifacts retain all evidence required by Layer 3 and independent replay. Its ledger status is PARTIAL/DIRECT. The six formal results concern a finite list of addressed reads. The Java witness exercises twelve outcomes on concrete inputs. Neither scope quantifies over all Java executions or Alloy inputs.

## Consumer boundaries

| Consumer | Retained input and use | Additional inputs |
| --- | --- | --- |
| Layer 3 | RepairProjection reads the profile, container laws and dependent-chain certificates. GuardedJoinSourceFiber reads guarded joins. Source-linked dependent-chain admission checks certificate object identity and the repaired source occurrence. | The adapter Result supplies phase descriptors and coordinates, local binding and dependent-chain maps, certified partitions and the canonical key. Projection also reads the separately supplied normal forms. |
| Certificate writer | The writer reads the root, classes, witnesses, unfoldings, container laws, profile and six construction or occurrence collections. The ledger stays at the producer. Artifact construction compares evidence with ledger occurrence counts. The writer checks matching law registries before export. | CertificateExportSession supplies the recorded events, final snapshot, canonical observation, session law registry, provenance, component versions and artifact. |
| Independent verifier | Consumers read the decoded Bundle tables, metadata and caller-supplied VerificationPolicy. Six ordered semantic evidence sections go to law checking, flat/container/binder replay, exact type parsing and CALL checking. Dependent chains are serialized in the flat-constructions section. | Standalone verification requires the configured theory trust, limits and applicable external occurrence commitments. Guarded JOIN rotation and flat exposure payloads are gated at export. |

## Receipt and checks

The JDK 17 compiler attributes all Java compilation units in src and certificate-verifier/src except files ending in Test.java. The census covers direct calls and method references to the recorded APIs. It includes consumer type and enclosing method, a one-based source site ordinal per kind and method, resolved target and expression. The semantic evidence rows also identify the wire section, producer collection, verifier method and argument position. Ordinals count static source sites. The test separately changes actual payload multiplicity.

The extractor checks the declaration and single-field return of every nonstatic retained field. The driver compares the complete resulting TSV with p3-13-reads.tsv and checks the six section names and dispatch positions. The Lean statements model ordered observation and rejection when a required read disappears or its owner, occurrence or endpoint changes. The Java-to-model correspondence consists of the compiler-resolved census, rather than whole-JVM verification.

- The immutable producer accepts the original flat construction. Removing it, doubling it, or substituting a record with different source grouping each fails ledger equality.
- Public Layer 3 projection accepts an adapted ARROW chain. Its actual chain consumer rejects the same binding paired with a different valid artifact that lacks the certificate. The test invokes this internal consumer directly because the public adapter result seals the pair.
- The writer exports matching law registries. An independently constructed session carrying a SET registry whose artifact omits it yields UNCHECKABLE before creating an output file.
- The standalone FULL verifier accepts two valid AND groupings with fixed TEST_ONLY theory and empty CALL pins. Removing the flat record or replacing it with the other grouping's record yields REJECTED/MISSING_EVIDENCE. Both mutations rebuild the vocabulary digest, and both retain the original verifier policy.
