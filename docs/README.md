# Documentation Map

Start with the current architecture and measured results; historical development
notes are supporting evidence, not additional installation steps.

## Current Artifact

- [Repository guide](../README.md): installation, experiments and published results.
- [CanDis reference](../documentation/README.md): representation and runner APIs.
- [Rewrite system](../documentation/REWRITE_SYSTEM.md): rules and side conditions.
- [Three-layer architecture](three-layer-canonical-repair-architecture.md).
- [Fast/certificate equality disagreements](fast-rewrite-certificate-equality-disagreements.md).
- [Certificate verifier](../certificate-verifier/README.md).

## Experimental Evidence

- [Latest final results: November 16, 2026](https://github.com/AlexandervonWu/ACGN/blob/v3/docs/experimental-results/2026-11-16/README.md).
- [v3 research summary and assurance boundary](https://github.com/AlexandervonWu/ACGN/blob/v3/docs/release-v3.md).
- [Structured headline data](https://github.com/AlexandervonWu/ACGN/blob/v3/docs/experimental-results/2026-11-16/headlines.json).
- [v3 release and downloadable research data](https://github.com/AlexandervonWu/ACGN/releases/tag/v3).

These links identify the frozen v3 experiment. Earlier reports below retain
their own source and run identities and are not the latest headline results.

### Earlier Experiments

- [Paired-oracle results](../distance_results/summary.md).
- [Nearest-correct-pool results](../alloy4fun-augmented/summary.md).
- [Ablation results](../egraph_ablation/summary.md).
- [Capability results](../capability_benchmark/REPORT.md).
- [Slot-typing controlled ablation](slot-typing-ablation/README.md).
- [Repair-learning findings](repair-search/MULTISTEP-ITERATION-ANALYSIS.md).

## Historical Material

`theory-phase-*`, `obligation-repair/`, `java-lean-refinement/`,
`section3-repair-audit/`, release notes and learning-study directories record
earlier design decisions, failures and bounded checks. Their manifests and
source snapshots identify the version to which each claim applies. A historical
PASS is not a claim about today's source tree.

Do not delete a historical file merely because a later report supersedes it:
proof manifests and published hashes may still refer to it. Untracked source,
Lean proofs and unique experiment evidence are not disposable intermediates.
Python caches and empty build directories may be removed; tracked verifier
artifacts referenced by archived input manifests are retained.

The 2026-11-06 cleanup was deliberately limited to cache/empty-directory
hygiene and new ignore rules. No large reclaimable untracked intermediate was
established in this pass; unique in-progress learning work and hash-bound
historical evidence were preserved. This index reduces navigation overhead
without silently invalidating archived reproductions.
