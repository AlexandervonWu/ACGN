# Verifier-Guided Search And Language-Model Repair

This experimental package follows the unsuccessful graph-policy studies. It
compares a small AlphaProof-inspired search learner, uniform-prior PUCT, random
tree exploration, local Qwen body generation, checked supervised LoRA,
counterexample-guided LoRA, and the locally supplied TAR executable.

Read [the formal specification](SPECIFICATION.md) and [proof/evidence ledger](CLAIMS.md)
first. The Lean theorem file is [SearchLearning.lean](formal/SearchLearning.lean).
This is a 16-training-task / 8-evaluation-task feasibility pilot with disjoint
question groups, not a full-corpus experiment or a claim of stable superiority.

The [completed pilot results](RESULTS.md) are negative for the new learned
methods: TAR 4/8, unadapted Q3 1/8, SFT and counterexample-guided LoRA 0/8;
learned/uniform PUCT and random tree exploration each 0/24 over three seeds on
the same eight tasks. Generation failures are reported separately from semantic
counterexamples. No stable superiority is claimed.

The [failure-mode ledger](FAILURE-MODES.md) separates observations, repaired
engineering incidents, untested explanations and open proof boundaries.
This is a documentation/evidence publication; the new runtime sources and
launchers remain local development work, not packaged by this commit. Commands
below describe that workspace, not a standalone reproducible release.

## Run

From the repository root, with the local AIx Ollama service available on port
11435:

```bash
bash scripts/run_repair_search_study.sh /tmp/acgn-repair-study-new
```

Use a new absolute output directory. The script compiles the proof and Java,
runs the study tests, then executes the search, TAR, data preparation, base-model,
SFT, and counterexample-guided stages serially. It finally generates
`comparison.json`, `summary.md`, and output hashes. Existing model tags are never
overwritten, and the AIx portal's default model is not changed.

Required local installations:

- Lean 4.33.0, JDK 17, and this repository's `lib` directory.
- `/home/augustus/.venvs/acgn-rl-cu130/bin/python` for the search/orchestration code.
- `/home/augustus/AIx/.venv-finetune/bin/python` and its existing streamed-prefix
  training and adapter-export tooling.
- The retained unadapted Ollama tag `aix-qwen3.8:27b-ud-q3_k_xl`.
- The local NF4 training snapshot under `AIx/.local/hf-training` referenced by
  `scripts/train_repair_lora.py`. Its recorded architecture is
  `Qwen3_5ForConditionalGeneration`; model labels are not a substitute for the
  actual configuration and checkpoint provenance.
- `/home/augustus/lp_baselines/TAR/beafix_benchmarks/arepair/atr.jar`.

No model download is requested. LoRA training is bounded to the last four MLP
layers, rank 8, one epoch, and a 13-GiB PyTorch allocation cap. Frozen prefix
weights are streamed from host RAM. The host RAM reserve is enforced by the
existing trainer; approximately 20 GiB of available host RAM is desirable.
The four trainable suffix layers use non-reentrant activation checkpointing;
the streamed frozen prefix does not. A detached-input CUDA gradient test runs
before loading the base checkpoint. PyTorch/Transformers checkpointing remains
part of the declared TCB, not a new theorem of model refinement.
Q3 inference is handled separately by Ollama. The NF4 training checkpoint and
Q3 inference base are different quantizations, explicitly recorded in outputs.

## Comparison Boundaries

Each search arm uses one shared task split and typed edit menu. The learned
policy is a small token-feature policy/value network, not another GNN and not
the large encoder-decoder model from AlphaProof. Three evaluation seeds vary
search decisions for one frozen trained policy; they are not three independent
training runs. Search observations currently use syntax and aggregate witness
scores, whereas language-model prompts include concrete witness valuations.

TAR and Qwen can make repairs outside that restricted edit menu. TAR receives a
60-second search allowance at mutation depth 3; search gets 32 simulations at
depth 3; Qwen receives at most four 512-token proposals. These differences must
remain visible in comparisons. TAR runs with its own upstream Alloy engine,
then its candidate is rechecked by this package's common evaluator.

All successful proposals require satisfiable context and both directional
bounded equivalence checks. Counterexamples are useful feedback, not proofs of
general equivalence. The study never broadens equality-certificate authority.
Failures, invalid proposals and unfinished experiments must not be silently
converted into successful repairs or completed statistical studies.

## Prior Negative Result

See [the graph-learning conclusion](../rl-graph-learning-conclusion.md). The
interrupted larger graph run is preserved separately and must not be included
as a completed five-seed comparison.
