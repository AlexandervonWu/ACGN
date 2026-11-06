# Feedback Training Preflight

Status: **BLOCKED BEFORE TRAINING**. This is an executor migration and coverage report,
not a new learning result and not a completed migration.

- Frozen pilot inputs: 104. These are not the full corpus.
- Observation plus one explicit validation query: 104/104.
- Training-only replay-validated teachers: 64/64.
- Teacher validation is not a learned repair score; unavailable paths remain in coverage.
- Optimizer updates: GNN 0; Qwen adaptation 0; roughly 500M transformer 0.
- Java, Alloy, SAT4J, Lean and the OS remain trusted dependencies.

## Bounded Checks

- FeedbackRepairTest: 114 checks.
- RepairEnvironmentTest: 64 checks.
- RepairLearningTest: 38 checks.
- CausalReplayTest: 14 checks.

## Remaining Gates

- Certified canonical projection numeric tables and round-trip/transport checks are not yet implemented.
- Draft masks expose coarse sorts; exact incremental dependent type inference remains a commit-time check.
- Training-only teacher coverage is measured; 1/8/64 free-running learnability and matched controls have not run.
- All three model consumers still require migration; historical trainers are not invoked.

Historical results are unchanged. A passed source/query check is not a repaired
predicate, a learnability result, or proof of complete Java/Lean correspondence.
