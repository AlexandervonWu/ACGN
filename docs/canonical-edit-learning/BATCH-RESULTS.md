# Effective Batch And Memory Results

These are bounded full-parameter **synthetic fit tests**, not corpus training,
repair-success measurements, or a closed Java/Lean correspondence claim.
The user's current focus is 508M and 710M on the RTX 5080, with approximately
15 GB available beyond the desktop. Further 911M trials are deferred.

## Tested Settings

- 508,313,088 parameters: effective batch **128**, microbatch **8**, 16 chunks
  accumulated before each optimizer step.
- 709,664,256 parameters: effective batch **96**, microbatch **8**, 12 chunks.
- Both use the 128-ID vocabulary (97 assigned), random initialization, BF16
  autocast, FP32 parameters/gradients, block activation checkpointing and
  PyTorch Adafactor with `foreach=False`. No weights are frozen. No INT4
  memory reduction or CPU parameter offload is used.
- Tested sequence lengths: **512 and 2,048 tokens**. Each trial makes two
  updates on one fixed synthetic batch, then evaluates that batch again.
- An 80% PyTorch allocator cap leaves GPU headroom; process and total-device
  memory are also sampled every 0.5 seconds. Sampled peaks are not continuous
  upper bounds, and the device measurement includes desktop/other GPU users.

All requested effective batches completed without OOM. This is accumulation,
not 128 or 96 simultaneously resident examples.

## Initial Measurements

At a learning-rate cap of **0.0001**:

- 508M, 512 tokens: 6.354 GiB sampled process peak, 5.471 GiB allocated peak,
  6.025 GiB reserved peak; losses **4.8382 -> 3.7204 -> 2.9812**.
  Updates took 4.445 and 4.107 seconds.
- 710M, 512 tokens: 8.607 GiB sampled process peak, 7.553 GiB allocated peak,
  8.279 GiB reserved peak; losses **4.3947 -> 3.2727 -> 2.8118**.
  Updates took 4.612 and 4.328 seconds.
- 508M, 2,048 tokens: 8.541 GiB sampled process peak, 7.420 GiB allocated
  peak, 8.213 GiB reserved peak; losses **4.8549 -> 4.0374 -> 3.9117**.
  Updates took 20.198 and 19.399 seconds.
- 710M, 2,048 tokens: 11.146 GiB sampled process peak, 10.054 GiB allocated
  peak, 10.818 GiB reserved peak; losses **4.2303 -> 3.3164 -> 4.2251**.
  Updates took 20.488 and 20.190 seconds.

Each loss sequence is before update 1, before update 2, then after update 2.
The final 710M long-context loss barely improves on its initial value and
rebounds after its first update. Do not interpret `loss_decreased: true` as
monotonic optimization, long-run stability, generalization or repair quality.
One seed, two updates and synthetic targets cannot rank learning efficacy.
Optimizer state alone was 2,473,244 bytes for 508M and 3,440,188 for 710M;
these factored-state sizes exclude the much larger parameters and gradients.

The initial 0.001 cap was too aggressive for this workload: 508M's loss went
from 4.8382 to 31.9146, and 710M's from 4.3947 to 22.1444. Their JSON records
are retained. `PASS_FUNCTIONAL_NOT_REPAIR_EVIDENCE` only says finite execution
completed; `loss_decreased` records the separate numerical outcome.

The 911M/64 initial trial had already completed before the user deferred it.
It used microbatch 4 at 512 tokens and peaked at 9.662 GiB sampled process
memory, but its 0.001-cap loss increased from 4.8840 to 112.9659. No lower-rate
or long-context 911M trial followed. Keeping this failure is not a recommendation
to train that candidate now.

## Evidence And Provenance

Initial records are the seven `results/batch_*.json` files without the
`_provenance` suffix. Their `input_hashes` bind the measured Python and Lean
sources, protocol and installed optimizer export module. Their runner source
is preserved byte-for-byte as [batch_probe_initial.py](results/batch_probe_initial.py).
The model used in that study is also preserved as
[model_batch_study.py](results/model_batch_study.py), SHA-256
`90193432f106cbc3306de6a715d677182273cf66d7cbae02a574a28786358174`.
The current corpus model gathers the last non-PAD query for variable-length
packets; that later padding change is not retroactively part of these measurements.

Inspection found that `inspect.getfile(torch.optim.Adafactor)` resolves to
`torch/optim/__init__.py`, not `_adafactor.py`. The current runner instead
resolves the constructor and unwrapped `step` implementation files, hashes
those files, and reports their paths explicitly in `optimizer_sources`.
This changes reporting only, not the training calculation. The two full-length
trials are repeated in fresh processes with that correction; see their
`_provenance.json` records. Earlier results are not relabeled or overwritten.

The final repeats completed with the same allocated/reserved and sampled
process peaks as the initial long-context trials:

- [508M/128 repeat](results/batch_508m_b128_m8_t2048_lr0001_provenance.json):
  losses 4.8549 -> 4.0374 -> 3.9127; 44.431 seconds for setup, two updates
  and final evaluation; sampled whole-device peak 9.413 GiB.
- [710M/96 repeat](results/batch_710m_b96_m8_t2048_lr0001_provenance.json):
  losses 4.2303 -> 3.3202 -> 4.2274; 46.922 seconds overall; sampled
  whole-device peak 12.240 GiB. The loss rebound remains visible.

Small repeat-to-repeat loss differences are observed GPU floating-point
variation; no bitwise determinism claim is made. Repeating the same seed is
also not an independent validation sample.

The hashes are bounded provenance, not a full reproducible environment or
proof closure manifest. Python/PyTorch/CUDA, the optimizer, driver and numerical
kernels remain declared trust. Synthetic packet hashes and unique packet
counts do not certify an Alloy graph or a correct teacher label.

## Checks And Next Step

- The standalone Lean file compiles with **50 named theorems**, including four
  accumulation/count theorems added before the implementation. Their exact
  scalar model assumes contributions at unchanged parameters; it does not
  prove floating-point autodiff or optimizer convergence.
- **29 Python tests pass**, including full versus accumulated gradients and
  Adafactor updates, uneven final chunks, exactly one optimizer step, and a
  failed second chunk clearing partial gradients without stepping.
- Java canonicalization, certificates, metric semantics, the source corpus and
  publication result directories are unchanged.

Keep **508M/128** as the lower-cost first candidate and **710M/96** as the
capacity comparison. Both fit the tested 2,048-token configuration; there is
no measured memory reason to discard 710M. The next prerequisite is the real
graph/world/action exporter and checked metric-grounded labels, followed by
group-disjoint validation against matched random/search controls. Only then
can repair success choose the winner. The 0.0001 cap is a short-test starting
point, not a tuned real-data schedule.

Commands are in the [runner README](../../experiments/hybrid_edit/README.md);
use `--tokens 2048` for the longer check and a fresh `--output` path each time.
The runner rejects attempts to overwrite prior records.
