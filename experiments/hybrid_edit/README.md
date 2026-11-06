# Hybrid Edit Policy Prototype

From-scratch GQA transformer with pointer-based action selection, nine-family,
binary-witness and value heads. The token embedding is tied to the optional
token-prediction output. All parameters are trainable; no pretrained weights,
frozen prefix or adapter-only substitution is used.

Read the [specification](../../docs/canonical-edit-learning/SPECIFICATION.md)
and [proof boundaries](../../docs/canonical-edit-learning/OBLIGATIONS.md) first.
The source-backed corpus bridge now exports typed source structure, a certified
repair projection, concrete instance tuples and executable candidate edits.
Teacher labels and two-direction solver outcomes remain separate from policy
features. The synthetic toy probe still has no Alloy repair-success meaning.

## Initial Scope

`Config()` and `candidates()` now select the **508M/710M/911M pilot**, with
BF16/W8/W4 variants and 128 embedding IDs (97 assigned). The later large grid
is available only through `candidates("scale")` / `--study scale`.

[Pilot scope](../../docs/canonical-edit-learning/PILOT-SCOPE.md) defines the
static unary/binary relational slice and four replacement templates.
`scope.py` rejects unsupported inventory features, out-of-bound observations,
reserved tokens and truncated menus. Numeric references round-trip in four
digit tokens; variable/symbol spelling does not grow the vocabulary. The
Compact one-token banks cover `$sig0`-`$sig7`, `$0`-`$7`, and `$rel0`-`$rel7`;
integer literals 0-4 are distinct from numeric reference digits. Built-ins
reuse their existing IDs, with `iden` added. Bank exhaustion is an exclusion,
not aliasing. The inventory exporter and full packet parser are still open: this module is an
adapter-contract gate, not an Alloy parser or a source certificate.

## Precision

`weight_bits=16` leaves weights unchanged. Use CUDA BF16 autocast for BF16
linear compute; setting the field alone does not change the tensor dtype.
`4` and `8` fake-quantize backbone linear weights in symmetric groups, using
an identity straight-through gradient. Embedding, norms and task heads remain
unquantized. Masters and gradients are dense. This QAT implementation can use
MORE memory than the unquantized reference and is not a packed training backend.

The INT4 codec separately packs unsigned nibbles (signed code + 8). Tests cover
all 256 pairs and zero padding. Scales are FP32. Checkpoint packing is distinct
from PyTorch's ordinary dense `state_dict` serialization. No native INT4 kernel,
CPU master offload or production optimizer is claimed here.

## Bounded Checks

Run from the repository root with the existing local PyTorch environment:

```bash
lean -o /tmp/HybridRepair.olean docs/canonical-edit-learning/formal/HybridRepair.lean
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m unittest discover -s experiments/hybrid_edit -p 'test_*.py' -v
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.hybrid_edit.probe --device cuda --output /tmp/hybrid-edit-smoke.json
```

The meta-device tests count the nine pilot and eight later scale candidates
without allocating their weights. By default the probe trains only
87,104-parameter fixtures for eight steps per precision. An explicit pilot
candidate enables a short full-parameter **synthetic** memory/functionality test:

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.hybrid_edit.probe \
  --device cuda --candidate 508m-w16a16 --steps 2 --tokens 64 --learning-rate 0.001 \
  --output /tmp/hybrid-pilot-508m.json
```

This uses FP32 masters/gradients, BF16 autocast and no-momentum SGD with block
checkpointing and an 80% allocator cap. It does not measure Adam, long-context
fit, checkpoint-save peak or real repair quality. Loss-decrease failures are
saved with a failure status and nonzero exit rather than presented as passes.
The synthetic tokens deliberately do not pretend to be exported Alloy records.

## Effective Batch Trials

`batching.py` implements sample-weighted gradient accumulation, followed by
one finite-gradient check, global clip and optimizer step per effective batch.
No parameter update happens between chunks. A failed chunk clears partial
gradients and does not step. Tests compare full-batch and accumulated gradients
and Adafactor updates, including uneven final chunks. A failed optimizer step
invalidates the run; it is not a rollback guarantee.

The requested pilot batches are 508M/128 (8 examples x 16 chunks) and 710M/96
(8 x 12). Further 911M trials are deferred at the user's request. Start separate
processes sequentially, with fresh output filenames:

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.hybrid_edit.batch_probe \
  --candidate 508m-w16a16 --effective-batch 128 --microbatch 8 \
  --tokens 512 --updates 2 --learning-rate 0.0001 \
  --output /tmp/hybrid-batch-508m.json
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.hybrid_edit.batch_probe \
  --candidate 710m-w16a16 --effective-batch 96 --microbatch 8 \
  --tokens 512 --updates 2 --learning-rate 0.0001 \
  --output /tmp/hybrid-batch-710m.json
```

These use PyTorch Adafactor with BF16 compute, FP32 parameters/gradients,
activation checkpointing and an 80% allocator cap. The requested batch is the
effective batch, not the simultaneous device batch. Each synthetic fixed batch
is repeated for two updates. Results retain source/fixture hashes, individual
step losses/times, optimizer state size, allocator peaks and sampled whole
process/device peaks. The default rate 0.001 is retained for reproducibility of
the initial numerical failures; the commands explicitly use the tested lower
cap. `PASS_FUNCTIONAL_NOT_REPAIR_EVIDENCE` means the finite computation finished,
not that the loss decreased: check `loss_decreased` separately.

Read the [protocol](../../docs/canonical-edit-learning/BATCH-STUDY.md) and
[measurements](../../docs/canonical-edit-learning/BATCH-RESULTS.md). This runner
is bounded to 2-8 updates and is not a corpus trainer or held-out evaluation.

PyTorch/CUDA/driver/OS/numerics remain trusted; bounded tests are not a
Java-to-Lean refinement proof. The generated JSON binds the model/probe/tests
and Lean source hashes; it is not a complete environment or closure manifest.

## Source-Backed Training

Read the [frozen corpus protocol](../../docs/canonical-edit-learning/CORPUS-STUDY.md)
and [incident record](../../docs/canonical-edit-learning/CORPUS-INCIDENTS.md).
`HybridCorpusWorker` exports the Java repair view, source AST, schema, counterexample
worlds and candidate metadata. `corpus_codec.py` uses 102 assigned IDs out of 128,
with explicit exclusions rather than truncated graphs or aliased symbols.
`corpus.py` collects a deterministic question-capped sample and retains all
scope exclusions and failures. It does not select examples by repairability.

From the repository root, using a fresh absolute output directory:

```bash
bash scripts/run_hybrid_corpus_training.sh /tmp/hybrid508-repeat 4096 8
```

This compiles both Lean files and Java, runs bounded tests, exports the corpus,
trains the full 508M model from scratch, selects a checkpoint on validation
questions and evaluates held-out questions. It uses effective batch 128 through
microbatches of 8, BF16 compute, FP32 parameters, Adafactor, and an 80% CUDA
allocator cap. The existing local CUDA environment is required; the script does
not download dependencies. Output includes a weights-only `best.pt`, manifests,
history, per-candidate solver outcomes, held-out rankings and a generated report.
The checkpoint is usable for inference but lacks optimizer state for exact resume.

Question-disjoint validation selects by repair success, then loss. Test metrics
compare top-1 and budget-3 choices against the exact uniform-random expectation
on the same menu. Budget 3 means three independent one-step attempts from the
original state, not a three-edit trajectory. Only feasible, two-direction UNSAT
checks at independent Alloy run scope 3 count as success. The result is bounded
semantic validation, not unbounded equivalence or certificate replay.

The [completed eight-epoch run](../../docs/canonical-edit-learning/CORPUS-RESULTS.md)
records 0/192 top-1 repairs and 1/192 at budget 3, with a one-step upper bound
of only 2/192. It does not beat the matched random expectation. Retained weights,
source-backed labels and reports make this negative result inspectable.
