# Requested Batch-Size Study

Protocol: `hybrid-batch-fit-v1`. This run tests the requested effective batches
at real model size; it does not replace the open source/export/teacher bridge
with synthetic repair claims. Packets and labels in the fit workload are
synthetic, explicitly marked as such, using only the v2 assigned token IDs.

Initial settings:

- 508M: effective batch 128, microbatch 8, 16 accumulation passes.
- 710M: effective batch 96, microbatch 8, 12 accumulation passes.
- 911M: effective batch 64, microbatch 4, 16 accumulation passes.

Start at 512 tokens per packet and two optimizer updates per model. Each update
uses every example in the requested batch once. The fixed batch is replayed for
the second update to make numerical regression visible; this is not two batches
of new training data. Shapes, seeds, unique packet count, losses, actual batch
partition, memory, optimizer state and timing must be retained in the JSON.

All runs use BF16 autocast, FP32 trainable parameters/gradients, block activation
checkpointing and PyTorch Adafactor (`foreach=False`, relative-rate cap 0.001,
default beta2 decay/eps/clipping, zero weight decay). Adafactor's local installed
implementation and CUDA numerics are part of the TCB, not newly Lean-proven
optimization rules. It is used consistently across all three sizes. Full Adam
would require about 13.57 GiB of nominal state alone at 911M, before activations
and workspace; the earlier no-momentum SGD fit did not cover adaptive state.

## Accumulation Contract

For each microbatch with `m` examples out of effective batch `N`, backpropagate
`(m / N) * mean_loss(microbatch)`. This also handles a shorter final chunk.
Zero gradients once before the whole batch. Do not update parameters, clip
gradients or advance optimizer state between chunks. After the final chunk,
require finite gradients, clip the accumulated gradient once and take one
optimizer step. Failed/incomplete accumulation clears its partial gradients and
does not step. No batch-dependent normalization or cross-example objective is
used by this architecture. Dropout is zero.

Lean establishes preservation of exact scalar sums, sample count and normalized
sum under partitioning, plus the three requested batch products. It assumes
per-example contributions are computed at the same parameters; it does not
prove autograd or bitwise floating-point equality. Python tests compare real
full-batch and accumulated gradients/updates, including uneven partitions.

## Resource And Failure Policy

Use an 80% CUDA allocator cap with separate-process model runs. Capture both
allocated/reserved peaks and, where available, whole-process/device memory
samples. These measurements cover only the tested sequence length, optimizer
and microbatch. Record OOM/failure with configuration and progress; never
silently reduce the effective batch or call an incomplete update successful.
If needed, rerun with a smaller microbatch as a separately recorded attempt.
Any loss comparison uses the same fixed batch, not a held-out repair score.

No large checkpoints or long training runs are produced by this bounded study.
Real-data repair success, full 2,048-token fit, optimizer efficacy and convergence
remain separate evaluation obligations.
