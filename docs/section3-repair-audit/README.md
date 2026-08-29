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
- [Repair metric assurance record](repair-metric-assurance.md)
- [Fast Rewrite and Certificate-Integrated equality disagreements](../fast-rewrite-certificate-equality-disagreements.md):
  source-level characterization of the 14 certified-only paired zeroes and
  the repaired historical ten Fast-only incorrect-to-truth zeroes.
- [Phase 6 streaming and occurrence audit](phase-6-streaming-occurrences.md)
- [Formal Lean source tree](formal/), including the
  [claim-traceability model](formal/AssuranceTraceability.lean) and the
  claim-specific files named by the
  [requirements matrix](requirements-traceability.tsv).
- [Rewrite-rule catalog boundary](rewrite-rule-lean-java-closure.md), its
  [rule-to-proof reference table](rewrite-rule-traceability.tsv), and the
  catalog's [Lean source-rule obligations](formal/Phase5SourceRules.lean).

These are cross-references to bounded evidence only. A compiled Lean declaration
proves its stated proposition; neither its presence here nor a traceability row
establishes general Java--Lean refinement, whole-artifact correctness, or a
complete executable-branch census.

## Current Machine State

The generated catalog records its own claim, ready-row, and diagnostic counts.
Those values are valid only for the exact source matrix from which that catalog
was generated; this overview deliberately does not duplicate them. Run
`Section3AssuranceTraceability` or the bounded assurance entry point to obtain
the current values and an input-bound report. Any nonzero diagnostic count
means `INCOMPLETE`, never `PASS`.

The prior archived publication run remains intact. The four current empirical
result trees were intentionally refreshed from clean publication run
`df4d8d4c-6265-4fe7-88d5-3aceee60398b` and are checked against its 5,808
manifest-selected stage artifacts. Reproduction programs were not altered by
the experiment itself; the snapshot verifier and result-regeneration test were
advanced only to recognize the newly imported run.
