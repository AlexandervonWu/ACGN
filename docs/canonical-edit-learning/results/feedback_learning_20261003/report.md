# Structured Feedback Learnability

Status: **STOPPED_AT_FAILED_GATE**.

- Seed: 17; encoded teachers: 62/64 training tasks.
- Real Java execution and final two-direction bounded Alloy checks; two-query maximum.

## Gate 1

- Updates: 1000; repairs: 1/1; pass: True.
- Controls: {'noop': {'repairs': 0, 'tasks': 1, 'queries': 1}, 'uniform': {'repairs': 0, 'tasks': 1, 'queries': 0}}.

## Gate 8

- Updates: 1000; repairs: 0/8; pass: False.
- Controls: {'noop': {'repairs': 0, 'tasks': 8, 'queries': 8}, 'uniform': {'repairs': 0, 'tasks': 8, 'queries': 5}}.

## Boundaries

- Training-set diagnostic, not held-out or three-seed evidence.
- Draft masks use coarse sorts; exact dependent types are mandatory at commit.
- Local canonical binders/unrepresentable domains and old revision histories fail explicitly.
- Bounded search control and larger model consumers are not yet migrated.

Qwen adaptation and roughly 500M scratch training were not started by this diagnostic runner.
