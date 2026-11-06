# Source-Backed 508M Repair Pilot

A single-seed, bounded one-step study; not a full-corpus or multi-step repair result.

## Data And Training

- Inspected files: 4096; AST-distinct accepted: 1643; exclusions: 2453; failures: 0.
- Train/validation/test records: 1192/221/192.
- Train/validation/test questions: 31/7/5.
- Development-test groups excluded: classroom_fol:inv8, trash_fol:inv10.
- Parameters: 508,313,088; random seed: 19; epochs: 8; selected epoch: 8.
- Effective batch: 128 (except the final partial batch); microbatch: 8; Adafactor rate cap: 3e-05.
- BF16 compute, FP32 parameters/gradients, activation checkpointing. No pretrained weights or frozen layers.
- Question-disjoint splits. Checkpoint selection uses validation success, then validation loss. Test outcomes do not select a checkpoint.
- Teacher: minimum residual canonical distance to the paired oracle among all valid menu edits, retaining ties.

## Held-Out Repair Performance

- Budget 1: learned 0/192 (0.00%); uniform-random expected 0.533/192 (0.28%).
- Budget 3: learned 1/192 (0.52%); uniform-random expected 1.600/192 (0.83%).
- Exhaustive one-step upper bound: 2/192.
- Same-seed untrained model, top 1: 0/192.
- Learned minus random top-1 difference: -0.28 percentage points; paired question-bootstrap 95% interval [-0.49, 0.00], 5 question clusters.
- Random is the exact expectation for uniformly sampling distinct menu edits without replacement, not a favorable random seed.
- Every success has feasible context and UNSAT in both semantic-difference directions at independent run scope 3. This is not unbounded equivalence or standalone certificate replay.
- Candidate-score lookahead results are in JSON. They score every candidate first and are not equal-attempt-cost comparisons.

## By Question

- `classroom_fol:inv10`: learned 0/6; random expected 0.000; one-step upper bound 0.
- `classroom_fol:inv15`: learned 0/55; random expected 0.000; one-step upper bound 0.
- `classroom_fol:inv4`: learned 0/19; random expected 0.000; one-step upper bound 0.
- `socialMedia:inv3`: learned 0/99; random expected 0.533; one-step upper bound 2.
- `trash_fol:inv5`: learned 0/13; random expected 0.000; one-step upper bound 0.

## Resource Use And Limits

- Training/validation/final evaluation elapsed: 20.11 minutes.
- Peak allocated/reserved CUDA memory: 7.151/10.666 GiB, excluding external desktop usage.
- Only four source-replacement templates are tested. Unreachable repairs cannot be solved regardless of policy quality.
- The model sees a certificate-derived repair projection, source graph, schema and labelled user-domain tuples, not the entire proof-heavy e-graph or oracle syntax.
- The corpus slice excludes unsupported inputs, imports, oversized packets and unresolved cases. Reported success rates apply to retained held-out records, not all original files.
- One seed and a small number of question clusters do not establish stable superiority or trained-from-scratch convergence.
- Lean proves 13 abstract corpus contracts plus the prior model contracts; end-to-end Java/Python refinement and numerical backend correctness remain outside these proofs.

## Evidence

- Run directory: `/home/augustus/acgn-hybrid508-20261003/model508`.
- Data directory: `/home/augustus/acgn-hybrid508-20261003/corpus`.
- Checkpoint SHA-256: `0ce94a78c983df5810f9f79f8348d711c78dc841f1d329dcc3f79aa9bf68254d`.
- See manifest.json, history.json, test-predictions.json, comparison.json, and the data ledger plus per-record source/solver sidecars.
