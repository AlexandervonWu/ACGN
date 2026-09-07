# Bounded Review Record

Reviews are candidate-finding evidence, not mechanical verification or a
substitute for the registered two-build result. They were independent of the
implementation assignments, used local sources/tools, and stayed within the
named execution/certificate/correspondence boundaries. No new rewrite families
or production semantic changes were introduced.

| Review | Finding and disposition | Record |
| --- | --- | --- |
| Flat typing | Extractor initially accepted shared static schema storage; exact per-instance modifiers and a retained Int-after-Bool regression close the concrete witness. Bounded rereview PASS. | [Flat review](review-flat.md) |
| CALL validation/order | No scoped defect found. Actual source/target tuple token separation and generated negative controls were independently checked. Bounded review PASS. | [CALL review](review-call.md) |
| Chains/integration | Homogeneous indexed source trees, complete operand identities, order/count controls, and separate LOCAL/FULL surfaces passed bounded review. The initial producer/consumer census mismatch was corrected. | [Integration review](review-integration.md) |
| Isolated provenance | Missing Git metadata, then its accidental inclusion in the frozen source census, blocked initial runs. Deterministic TEST_ONLY fixture commits are now recorded separately, while source hashes and clean final HEAD remain checked. | [Integration incident](README.md#integration-incident) |

The review documents retain original failures, intermediate hashes and local
paths alongside follow-up results. Historical input hashes must not be read
as the hashes of the final source tree. The closure manifest and generated
report identify the actual published finite verification surface.

## Remaining Boundaries

The proofs do not mechanize the entire Java runtime, Alloy parser, type DAG,
or certificate exporter. The chain theorem is a sequence projection after
admission, not unconditional relational JOIN associativity. Parsed pipeline
exports that hit retired-collision or source-command-version limitations
remain unsupported; they are never relabeled FULL in this package. The
fixture certificate checks use explicitly scoped TEST_ONLY assumptions.

The global matrix remains incomplete. These are the five requested proof and
bounded-conformance repairs, not a claim that every artifact obligation is
closed. Later missing semantic equivalences remain evaluation data for the
existing augmentation mechanism, not additions to the static rewrite list.
