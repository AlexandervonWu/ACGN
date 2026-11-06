# Scoped Pilot Preflight

Run date: 2026-10-03 (America/Chicago). This is a bounded numerical preflight,
not the real-data repair comparison. The source/export/teacher integration
remains open. No existing corpus, Java metric, certificate or publication
result tree changed.

These GPU records predate the v2 compact vocabulary. Their hashes refer to the
v1 source snapshot; they are retained, not relabeled as v2 training. The model
dimensions are unchanged. Current vocabulary checks are in VOCABULARY-CENSUS.md.

## Gates And Tests

- 37 standalone Lean theorems compile, including seven new pilot contracts.
- 17 Python tests pass, including all 65,536 numeric payload round trips,
  reserved-token rejection, all inventory size limits, unsupported operators
  and features, type-mismatched actions and pre-truncated/oversized menus.
- All nine pilot parameter counts match actual PyTorch modules on the meta
  device. The earlier eight larger configurations remain available separately.
- Vocabulary: 128 embedding IDs, 67 assigned tags/digits, four source edit
  templates mapping to two of the nine existing metric families.

These tests do not establish the completeness of an inventory generated from
Alloy source. Full source-to-record correspondence remains an explicit obligation.

## Actual GPU Probes

RTX 5080; FP32 trainable masters and gradients; BF16 autocast; block activation
checkpointing; no-momentum SGD; learning rate 0.001; batch two; 64 tokens per
packet; two complete optimizer steps. Every parameter had a finite, nonzero
gradient on both steps. Losses below are the two training forward observations,
not a held-out score or an evaluation after the final update.

- **508M BF16:** loss 5.562 -> 4.921; peak allocated 3.89 GiB,
  reserved 4.38 GiB. [Raw record](results/pilot_508m_bf16.json).
- **710M BF16:** loss 6.490 -> 5.755; peak allocated 5.39 GiB,
  reserved 6.10 GiB. [Raw record](results/pilot_710m_bf16.json).
- **911M BF16:** loss 5.724 -> 4.876; peak allocated 6.92 GiB,
  reserved 7.81 GiB. [Raw record](results/pilot_911m_bf16.json).
- **508M W8A16 QAT:** loss 5.531 -> 4.933; peak allocated 3.89 GiB,
  reserved 4.04 GiB. [Raw record](results/pilot_508m_w8.json).
- **508M W4A16 QAT:** loss 5.480 -> 4.889; peak allocated 3.89 GiB,
  reserved 4.04 GiB. [Raw record](results/pilot_508m_w4.json).

These are allocator peaks, not whole-device residency. The slightly different
reserved peaks do not establish quantized-training memory savings: all three
508M modes retain dense FP32 masters/gradients, and their live allocated peaks
are essentially the same. The trials do not measure Adam, long contexts,
checkpoint-save peaks, convergence or meaningful cross-precision repair quality.
Only the 508M size received low-bit probes; larger QAT sizes remain untested.
Each raw record binds the relevant Python and Lean file hashes.

## Retained Failure

The first 508M BF16 probe reused the tiny fixture's learning rate 0.03. It fit
in memory with finite gradients but its loss rose from 5.562 to 10.626. The
initial probe raised before writing the result; the runner was corrected to
retain this loss-decrease failure with a nonzero exit and it was reproduced
in [this record](results/pilot_508m_lr003_failed.json). Lowering the rate to
0.001 produced the bounded successful probes above. This diagnoses a smoke-test
hyperparameter transfer failure, not evidence that larger models repair better.

## Next Evaluation Gate

Use the 508M BF16 configuration first. Connect the source-backed scoped exporter
and teacher labels, report actual admission/coverage counts, then compare
graph-only, counterexample-only and joint inputs against matched random/small
ranker controls. Only then compare model capacity/precision using repair success.
Keep solver scope and semantic acceptance unchanged; record every scope exclusion.
