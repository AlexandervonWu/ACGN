# Formal Closure Report

Status: **current-workflow review round 2 pending; clean builds and PDF QA are gated**.

## Exact regenerated registry result

- Audit rows: 158
- Active formal units: 146
- Named environments: 27
- Distinct exact compiled declarations: 146
- Exact proofs / definitions / constructors: 83 / 44 / 19
- Source-tag parity: 146/146

## Frozen identities

- Active manuscript graph: `e5ed4bb73d6b1ca664b5428ad22a5d36b460ef67bca180f261d894c2c647203c`
- Formal source/config graph: `1ee980165520906477f21d527631463639833c3bd9f601854a8c74c5982d6299`
- Formal registry: `687f18cf2bc1c361441a4e6b0a99b0e9706904685835d91137403756f672219b`
- Normalization contract: `9b4a84e6b492a65bed6c9446b1c3c9e255e21277caba9cc9d8c31d713c873bc6`
- PaperIndex: `dc10d182fd5e4249b8c67f92cb69b5057ca9a90f8dc82aa8e9ecd299c891fdcb`

## Current layer status

| Layer | Status |
|---|---|
| Paper formal closure | `BLOCKED_PENDING_FINAL_CORRESPONDENCE_REVIEW_AND_BUILDS` |
| Paper--Lean correspondence closure | `PENDING_CURRENT_WORKFLOW_REVIEW_ROUND_2` |
| Abstract-kernel closure | `BLOCKED_PENDING_CORRESPONDENCE_AND_BUILDS` |
| Artifact-refinement closure | `PARTIAL` |
| Experimental-replay closure | `PARTIAL` |
| GitHub publication | `OUT_OF_SCOPE_CURRENT_TASK` |

The first current-workflow review round produced one semantic PASS and one mechanical FAIL. The single permitted bounded metadata repair has been applied. No Java, parser, artifact, experiment, Lean declaration, Lean type, or Lean proof was changed. The second review round is final; only two unanimous fresh passes permit the two clean Lean 4.33.0 builds and full PDF QA.
