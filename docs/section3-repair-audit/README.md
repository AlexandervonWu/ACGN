# Section 3 Assurance Evidence Index

This directory contains the finite, DO-178C Level A-inspired verification
work for the repaired Section 3 implementation. It is not a certification
claim. The current assurance state is `INCOMPLETE`.

## Controlling Records

- [Bounded assurance plan](do178c-assurance-plan.md): scope, objectives,
  evidence classes, coverage policy, and termination rule.
- [Atomic claim ledger](claim-ledger.md): the 154 scoped requirements.
- [Traceability schema](traceability-schema.md) and
  [matrix](requirements-traceability.tsv): content-sensitive mapping from each
  exact claim to Lean, code, tests, and status.
- [Generated all-claims catalog](../section3-assurance-claims.md): every claim
  and its proof process in one Markdown document. This is generated from the
  ledger and matrix and is not an independent authority.
- [Global fault register](global-fault-register.md): every located
  contradiction and its current disposition.

## Execution And Review

- [Assurance runner](assurance-runner.md): the nonprotected bounded entry point
  `scripts/run_section3_assurance.sh`.
- [Run log](bounded-assurance-run-log.md): preserved `FAIL` and `INCOMPLETE`
  development runs with exact evidence hashes.
- [Bounded phase audit log](bounded-phase-audit-log.md): conjunct-level results
  and hashes from independent finite reviews.
- [Focused adversarial reviews](focused-adversarial-reviews.md): persistent
  P3-16 and P4-01 falsification records, exact report hashes, and closure
  obligations.
- [Structural coverage dispositions](structural-coverage-dispositions.tsv):
  currently open statement/decision/MC/DC obligations.

## Focused Proof Processes

- [Source-command semantic profiles](semantic-profile-proof-process.md)
- [Quiescent collision buckets](collision-bucket-proof-process.md)
- [Prenex ACI scheduling](prenex-aci-scheduling-proof-process.md)
- [Formal Lean sources](formal/)

## Current Machine State

The latest generated catalog contains 154 claims, zero fully ready rows, and
1,154 open diagnostics. Development run D executed 42 bounded steps with zero
executable failures but therefore terminated `INCOMPLETE`, not `PASS`. The
additional diagnostic is intentional: independent review showed that P4-01's
compiled static Lean model did not prove the exact determinism/transition
claim, so its formal status was corrected from `PROVED` to `REFUTED`.

The protected historical empirical result trees and protected reproduction
scripts are outside this repair directory and were not modified by this
assurance work.
