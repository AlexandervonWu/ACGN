# Feedback Training Preflight

Status: **BOUNDED LEARNING PREFLIGHT**. This is an executor coverage report,
not a learned repair result or permission for large model runs.

- Frozen pilot inputs: 104. These are not the full corpus.
- Observation plus one explicit validation query: 95/104.
- Training-only replay-validated teachers: 62/64.
- Teacher validation is not a learned repair score; unavailable paths remain in coverage.
- Optimizer updates: GNN 0; Qwen adaptation 0; roughly 500M transformer 0.
- Java, Alloy, SAT4J, Lean and the OS remain trusted dependencies.

## Bounded Checks

- FeedbackRepairTest: 132 checks.
- RepairEnvironmentTest: 64 checks.
- RepairLearningTest: 38 checks.
- CausalReplayTest: 14 checks.
- LearningBoundaryTest: 7 checks.
- GNNTest: 7 checks.

## Remaining Gates

- Canonical numeric export is bounded: local binders and unrepresentable domains explicitly fail coverage.
- Draft masks expose coarse sorts; exact dependent type checking remains a mandatory commit-time check.
- Training-only teacher coverage is measured; 1/8/64 free-running learnability and matched controls have not run.
- The small graph policy is available in train_gates; Qwen and large scratch consumers remain gated.

Historical results are unchanged. A passed source/query check is not a repaired
predicate, a learnability result, or proof of complete Java/Lean correspondence.
