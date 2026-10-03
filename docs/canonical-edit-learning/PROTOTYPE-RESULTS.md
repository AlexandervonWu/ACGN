# Bounded Hybrid Prototype Results

Scope: specification, model-level proofs, and a from-scratch neural prototype.
This is not a corpus training result or an end-to-end closure claim.

## Checks Run

- The standalone `HybridRepair.lean` compiled with 30 named theorems. They cover
  the limited model contracts listed in [OBLIGATIONS.md](OBLIGATIONS.md), not a
  proof of Python/Java/CUDA or learned repair effectiveness.
- Ten Python unit tests passed. They cover architecture rejection, all eight
  full-sized parameter counts on the meta device, all 256 packed nibble pairs,
  odd/zero-length packing and invalid padding, quantized zero groups, the
  chosen STE gradient, action masks, optimal-set loss, nonzero finite gradients
  for every parameter, checkpoint backward agreement, and dense save/reload.
- On the RTX 5080, three 87,104-parameter randomly initialized models completed
  eight SGD steps each, with BF16 CUDA autocast and FP32 master weights.
  W16, W8 and W4 all had decreasing fixture loss and finite nonzero gradients
  for every parameter at every step. None uses frozen weights or adapters.
- The mixed-precision runs are recorded in [the generated JSON](results/tiny_cuda.json),
  including configuration, versions, model/probe/test/Lean hashes and peaks.
  The approximately 65-MiB allocated / 66-MiB reserved peaks are allocator-only,
  tiny-fixture measurements, NOT total GPU residency or a large-model estimate.

The first precision includes CUDA startup overhead, so these elapsed times are
not a speed comparison. The tests use synthetic integer packets and arbitrary
classification/regression labels: lower loss does not establish reasoning over
real counterexamples, correct actions, generalization, or repair success.

## Candidate Study

- W16A16: 1,642,208,256; 2,447,563,776; 3,252,919,296 parameters.
- W8A16: 3,252,919,296; 4,058,274,816 parameters.
- W4A16: 3,252,919,296; 4,058,274,816; 4,863,630,336 parameters.

W4/W8 apply only to backbone linear forward weights. The current implementation
dequantizes dense weights and retains dense masters/gradients. It supplies a
QAT reference and packing codec, not a memory-efficient trainable INT4 kernel.
Reported packed-weight sizes are proposed checkpoint sizes, not training peaks.
All large candidates remain NOT RUN, with backend and data gates open.

## Remaining Work

Connect exact graph/world/action encoders and metric-grounded real-data labels;
measure executable menu coverage; implement and test the genuinely bounded
memory backend; then fit-test eligible sizes before training. Preserve ordinary
small rankers and matched random/search controls. Select by validation repair
success with smaller parameter count breaking ties, and keep test groups sealed.

No existing Java semantics, certificates, distance units, publication result
directories, corpus files or prior experimental outcomes were changed here.
