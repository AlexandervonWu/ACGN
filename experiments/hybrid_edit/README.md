# Hybrid Edit Policy Prototype

From-scratch GQA transformer with pointer-based action selection, nine-family,
binary-witness and value heads. The token embedding is tied to the optional
token-prediction output. All parameters are trainable; no pretrained weights,
frozen prefix or adapter-only substitution is used.

Read the [specification](../../docs/canonical-edit-learning/SPECIFICATION.md)
and [proof boundaries](../../docs/canonical-edit-learning/OBLIGATIONS.md) first.
The graph/world/action exporter and metric-grounded dataset are NOT implemented
by this prototype. Its input is a batch of already encoded integer packets.
The toy probe has no Alloy repair-success meaning.

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
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m unittest experiments.hybrid_edit.test_model -v
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.hybrid_edit.probe --device cuda --output /tmp/hybrid-edit-smoke.json
```

The meta-device tests count all eight 1.64-4.86B candidates without allocating
their weights. The probe trains only 87,104-parameter fixtures for eight steps
per precision, reporting loss and allocator peaks. It never starts a full-sized
run. PyTorch/CUDA/driver/OS/numerics remain trusted; bounded tests are not a
Java-to-Lean refinement proof. The generated JSON binds the model/probe/tests
and Lean source hashes; it is not a complete environment or closure manifest.
