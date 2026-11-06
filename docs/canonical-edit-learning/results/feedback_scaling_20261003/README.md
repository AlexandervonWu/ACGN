# Expanded Feedback GNN Evidence

This directory contains a curated copy of bounded-study evidence. Full working
directories on the execution host are:

- `/tmp/acgn-feedback-scale-preflight-20261003-v2`
- `/tmp/acgn-feedback-scale-data-20261003-v2`
- `/tmp/acgn-feedback-scale-study-20261003-v2`

`preflight/` retains proof and regression logs, coverage, reports and manifests.
`dataset/` retains frozen selection, preparation outcomes, task records, operator
catalog, teacher coverage and manifests. Training evidence is stored in `study/`.
`dataset/replay-data.tar.gz` contains all derived sources, training teacher
packets and teacher coverage; `study/sampling-schedules.tar.gz` contains all seven
sampling schedules. Generated Java classes, verbose worker logs and model weights
remain in the full working directories. The copied
`output-hashes.json` manifests describe those **full original directories**, not
only the curated subset. Do not claim all their files are present here.

The source archive contains **private oracle code for the executor**, not policy
features. Model inputs must use the public observation interface; training labels
and task metadata remain separate. No validation/evaluation teachers are included.
`superseded/` records the interrupted performance attempt and its teacher coverage;
it is not part of model selection or reported learning results.

`audit.py` verifies full working-directory hashes, archive members, paired sampling,
the frozen selection, split membership and rollout budgets, then regenerates
`audit.json`:

```bash
python3 docs/canonical-edit-learning/results/feedback_scaling_20261003/audit.py \
  /home/augustus/ACGN /tmp/acgn-feedback-scale-preflight-20261003-v2 \
  /tmp/acgn-feedback-scale-data-20261003-v2 /tmp/acgn-feedback-scale-study-20261003-v2
```

Assertions are mandatory; do not invoke this checker with `python -O`.
`curated-hashes.json` hashes the actual retained subset, including these archives.

The preflight records the source HEAD and dirty-tree flag. Input hashes identify
the checked working source; HEAD alone does not identify this experiment. Dataset
source hashes and split assignments are preserved. No source corpus or historical
publication result directory is modified by this run.

These measurements are bounded to the declared source/action slice and fixed
Alloy scope. A successful model theorem compilation is not a universal proof of
the Java/Python implementation, PyTorch/CUDA, or learned repair effectiveness.
