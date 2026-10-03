# Verifier-Guided Repair Pilot Results

## Conclusion

The graph-learning direction is closed as unsuccessful under the tested setup:
it did not establish stable improvement over random exploration. See the
[separate graph-study conclusion](../rl-graph-learning-conclusion.md), which
preserves the interrupted study's denominators and limitations.

The replacement pilot is also predominantly negative. TAR is the strongest
observed method on these eight held-out predicates. Neither the small
AlphaProof-inspired search learner nor either Qwen adapter demonstrates a repair
advantage. This does not establish that larger verifier-guided training or
language-model fine-tuning cannot work.

## Completed Experiment

Run root: `/tmp/acgn-search-study-01`, completed on 2026-10-03. The retained
[machine-readable comparison](results/comparison.json),
[generated summary](results/summary.md), and [evidence audit](results/audit.json)
record the actual outcomes. The input was fixed before training: first 16
training and first 8 evaluation entries of `docs/rl-corpus-data/tasks.json`.
These span 10 training question groups and 5 disjoint evaluation question groups.

- **TAR: 4/8** checked repairs, 190.83 seconds total evaluation time. Three tasks
  reached its internal 60-second timeout; one exhausted search. Every claimed
  repair passed the common validator. No TAR infrastructure failure was recorded.
- **Unadapted local Q3 model: 1/8**, 70.10 seconds. Of 29 proposals, one was
  accepted, 24 had semantic counterexamples, and four were invalid.
- **Supervised LoRA: 0/8**, 104.24 seconds. Of 32 proposals, 28 failed JSON
  decoding and four had semantic counterexamples. The raw responses include
  24 `done=false` replies and four output-token-limit terminations. Repetitive
  escaped whitespace is visible in the incomplete replies. This is an
  end-to-end generation failure, not 32 demonstrated semantic near-misses.
- **Counterexample-guided LoRA: 0/8**, 99.90 seconds. Of 32 proposals, 30 had
  semantic counterexamples and two reached the output-token limit with invalid
  JSON. Better output formatting did not produce a successful repair.
- **Learned PUCT: 0/24**, 328.67 seconds. Each of three search seeds scored 0/8.
- **Uniform PUCT: 0/24**, 345.04 seconds; **random tree exploration: 0/24**,
  332.39 seconds, also 0/8 per seed.

The search denominator repeats the same eight predicates across seeds 711-713.
It is not 24 distinct predicates or three independently trained policies. The
Qwen arms use one deterministic decoding configuration, seed 801. Evaluation
times include orchestration, loading where applicable, and common validation;
they are not isolated neural-kernel or SAT-solver times.

## What Was Trained

The AlphaProof-inspired implementation is policy/value-guided PUCT with
verifier-labelled search experience. It uses a small 512-feature, 64-hidden-unit
network, not a GNN or a pretrained proof model. Sixteen training searches found
one checked repair and produced 384 optimizer updates. Training-search time was
38.94 seconds. Failed bounded searches provide an empirical zero value target,
not a proof that the state has no repair.

Both language adapters were genuinely trained, saved, reloaded, exported, and
evaluated. They each have 2,162,688 trainable LoRA parameters on the last four
decoder MLP layers, rank 8, learning rate 0.0002, and one epoch:

- SFT used 16 checked target examples and 16 updates: 84.46 seconds.
- Counterexample-guided training used those same 16 examples plus 14 actual
  counterexample-feedback examples: 30 updates, 146.48 seconds.

These training times exclude base-checkpoint loading and adapter export.
The CE dataset is larger, so its content effect is not isolated from training
amount. All targets belong to training questions; no evaluation target entered
gradient updates. Model prompts receive schema, facts, faulty body and labelled
instances, not oracle source. They do not contain natural-language question
descriptions, every helper declaration, or the full structural Alloy context.

Training used the locally installed NF4 checkpoint; inference used adapters
exported onto `aix-qwen3.8:27b-ud-q3_k_xl`. This is not training through the Q3
GGUF. The local `Qwen3.8` alias has configuration architecture
`Qwen3_5ForConditionalGeneration`; the actual checkpoint and runtime digests are
recorded instead of inferring provenance from the alias. The new model tags are
`acgn-repair-search-01-sft:pilot` and `acgn-repair-search-01-ce:pilot`.
The existing AIx default model was not replaced.

The first SFT attempt exceeded the 13-GiB allocator cap and remains in the run's
`failed/sft-cap13` directory. Non-reentrant activation checkpointing on the four
trainable suffix layers fixed that resource failure without dropping examples
or truncating sequences. CE peak reserved PyTorch memory was 11,603,542,016 bytes
(10.81 GiB); total inference GPU use was observed at approximately 13.4 GiB.
CUDA/PyTorch, checkpointing and quantization remain explicit trusted components.

## Interpreting The Comparison

This is a practical feasibility comparison, not an equal-compute ablation.
Search uses 32 simulations at depth 3 over the existing restricted typed edit
menu. TAR uses its broader typed mutation inventory, depth 3 and a 60-second
search allowance. Qwen gets up to four whole-body proposals of at most 512
generated tokens, with concrete counterexample feedback at inference in all
three language arms. Search currently sees aggregate witness scores instead.
No unified cross-tool total of all internal solver calls is claimed.

TAR can therefore reach repairs outside the policy's menu. The policy received
very sparse successful training experience, and 16/30 suffix-only LoRA updates
are a small adaptation experiment. Quantization transfer, formatting behavior,
limited training diversity and restricted observations are plausible
limitations, not causally isolated explanations. The SFT runtime's incomplete
responses require investigation before using that score as an algorithm-level
estimate. Pretraining overlap with this public corpus is also unknown.

The implementation borrows the verifier-guided search/learning loop from
[AlphaProof](https://www.nature.com/articles/s41586-025-09833-y). It does not
replicate its proof decomposition, pretrained proof network or large curriculum.
TAR was executed from the supplied SEFM'22 package, not reimplemented and called
equivalent: [binary/source provenance](results/tar/provenance.json). Its bundled
JAR was not rebuilt, so source-to-binary correspondence remains unproved.

## Formal And Experimental Boundaries

Lean proofs were written and compiled first, followed by the specification and
implementation. Eight model-level theorems cover two-direction equivalence,
counterexample filtering and bounded admission. Five Python integration/report
tests pass, alongside 64 environment and 38 learning Java checks. Full Java
compilation succeeds. A fresh-build audit rechecks all five successful evaluation
results and all 16 supervised targets from source.

Every success requires satisfiable context and both directional Alloy queries
UNSAT under the fixed scope-3 profile. These are **bounded checked repairs**,
not unbounded correctness claims. Lean admissions check solver-produced records;
they are not independent proofs of each Alloy predicate. Whole-application
Java/Python-to-Lean refinement remains **BLOCKED**, as recorded in
[the proof/evidence ledger](CLAIMS.md). The existing certification authority and
empirical publication directories are unchanged.

## Reproduce

With the existing local installations and Ollama service running:

```bash
bash scripts/run_repair_search_study.sh /tmp/acgn-repair-study-next
```

Stages run serially. Use a new output directory and retain failed runs. The
[README](README.md) lists dependencies and resource limits. The compact evidence
copy here includes prompts, responses, training data and manifests; bulky
checkpoints, tokenizer copies, compiled classes and worker logs remain in the
run root. `results/output-hashes.json` indexes the full run;
`results/retained-hashes.json` indexes only the copied evidence.
