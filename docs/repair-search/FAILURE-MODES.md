# Repair Learning Failure And Limitation Ledger

This ledger consolidates observed failures, repaired engineering incidents and
open limitations. Possible explanations are not established causes. Exhausting
a bounded search is not proof that its task has no repair.

## Empirical Failures

### F01: Poor Transfer And Seed Instability

The initial pilot solved 16/20 training episodes but 0/3 held-out episodes,
versus random's 2/3. Later graph-family trials had large seed variation. These
observations establish poor transfer in those pilots, not impossibility for
graph ML. Tiny related fixtures, sparse successful trajectories and restricted
observations are plausible causes; the studies did not isolate them.
[Initial evidence](../rl23-initial-verification.md).

### F02: Validation Rankings Reversed On Test Seeds

Selected GCN-1024 scored 9/27 versus its small control's 15/27; selected GAT-256
scored 3/27 versus 9/27. The selected larger transformer and GAT each scored
6/27, below small controls at 9/27 and 12/27. More parameters did not reliably
improve repairs. Width, depth and learning rate sometimes changed together, so
these are configuration outcomes, not a causal width study. Frozen selections
were not changed after observing tests.
[Capacity results](../rl-large-policy-results.md),
[transformer results](../rl-transformer-results.md).

### F03: Corpus Learning Did Not Beat Random Stably

GCN and GAT each scored 0/48 at both completed validation seeds. Transformer
validation was 9/48 then 0/48; its first fresh test was 0/72 versus random 4/72.
The apparent validation win represented three predicates repeated three times.
Seven child runs completed before the user redirected work; the next was
interrupted. There is no completed five-seed result.
[Conclusion](../rl-graph-learning-conclusion.md),
[child records](../rl-corpus-interrupted-runs.json).

### F04: Search Learning Added No Measured Advantage

The policy/value learner found one repair in 16 training searches. Learned PUCT,
uniform PUCT and random tree exploration each scored 0/24 across three seeds on
eight held-out predicates. Sparse positive targets, small unpretrained features
and the restricted edit menu are candidate explanations. No exhaustive
reachability study separated poor ranking from missing menu actions.
[Search records](results/policy/runs.json).

### F05: Base-Model Semantic And Syntax Failures

The local Q3 base solved 1/8. Its 29 proposals comprised one accepted repair,
24 semantic counterexamples and four invalid proposals. Model output and finite
bank agreement alone confer no semantic authority.
[Prompts and responses](results/base/runs.json).

### F06: SFT Degraded Output Formation

SFT solved 0/8: 28/32 proposals failed JSON decoding and four had semantic
counterexamples. Raw responses include 24 `done=false` replies with repetitive
escaped whitespace and four output-token-limit terminations. These overlap the
format-error count; they are not additional trials. Finite gradients, changed
weights and exact reload passed, but that did not imply usable generation.

The cause is unresolved: this run does not distinguish adapter learning,
quantization transfer, template effects or runtime termination behavior. Do not
call all these responses semantic near-misses, complete their JSON silently,
or claim a diagnosed Ollama defect.
[SFT responses](results/sft/runs.json),
[manifest](results/sft-adapter/manifest.json).

### F07: Counterexample Training Improved Format, Not Repair Success

The CE adapter solved 0/8. Thirty proposals reached semantic validation and had
counterexamples; two hit the output-token limit with invalid JSON. Better
formatting did not produce correct repairs. CE had 30 updates versus SFT's 16;
the content benefit is not isolated from training amount. Only one decoding seed
was evaluated. [CE responses](results/ce/runs.json),
[data](results/data/manifest.json).

### F08: TAR Timeouts And Search Exhaustion

TAR repaired 4/8; three tasks hit its internal 60-second timeout and one
exhausted search. These are not infrastructure crashes or proofs of
unrepairability. All reported repairs were rechecked. TAR has a broader mutation
inventory and different budget: its lead is not an equal-action-space result.
[TAR records](results/tar/runs.json).

## Engineering Incidents

### E01: Training Memory Cap, Resolved

The first SFT attempt requested another 150 MiB after reaching 12.85 GiB
allocated under a 13-GiB cap; about 1.16 GiB device memory remained free.
Non-reentrant activation checkpointing on the four trainable suffix layers
reduced retained activations. The frozen streamed prefix was excluded. Full
sequences, examples and the cap were preserved; both final arms completed.
CUDA gradient comparison and exact adapter save/reload passed. This is tested
ML-TCB behavior, not a floating-point refinement proof.
[Failure](results/failed/sft-cap13/failure.json),
[wrapper checks](results/ce-adapter-wrapper.json).

### E02: Earlier Resolved Incidents

- Old CUDA wheels lacked RTX 5080 support; use the separate compatible runtime.
- Candidate expressions from another Alloy module could misbind stored-instance
  signatures. Evaluation now parses in the bank's fixed module, with separate
  full-source acceptance.
- Initial Lean proofs used unavailable tactics/reserved names. Failed
  compilations never counted as proof evidence.
- Early updates accepted unannotated rewards. Later updates require checked
  traces and model-level Lean-computed targets, not full refinement.
- Checkpoint loading assumed two layers; actual architecture and contract hashes
  now bind loading. Obsolete checkpoints are rejected rather than guessed.
- Parser spans could omit closing parentheses. Actions restrict incomplete
  spans and preserve the parser-owned negation token.
- Binary-token edits could change precedence. Realization parenthesizes operands
  and replacement, or omits an incomplete action.
- Context scans missed an inlined editable predicate. Source-span checks now
  supplement call dependencies; independent commands are required.
- Invalid attempts could leave unlimited retries. They now consume fuel without
  changing the committed candidate.
- The encoder wrapper stringified numeric metadata and confused `30` with
  `30.0`. Typed comparisons repaired reporting without changing child runs.
- The allocator API required an explicit CUDA index. The fix received an actual
  set/get/allocation/restore regression.
- The transformer verifier counted load records as model transitions. Corrected
  verification counts actual steps and checks their recorded receipts.
- A temporary audit used `hashlib.file_digest`, absent in Python 3.10. Streaming
  SHA-256 fixed the audit without changing experimental inputs.

Detailed ledgers and retained failure locations:
[RL-1](../rl-repair/README.md#failure-and-review-ledger),
[RL-2/3](../rl-repair/RL2-RL3.md#incident-ledger),
[assurance](../rl-repair/APPLICATION-ASSURANCE.md#incident-and-migration-notes),
[encoder wrapper](../rl-repair/GRAPH-ENCODERS.md#incident-ledger),
[allocator](../rl-repair/WIDE-POLICIES.md),
[transformer](../rl-transformer-results.md).

## Open Boundaries

- Repeated episodes share tasks and evolving banks: not independent predicates.
- Observations are a repair projection, not the whole e-graph; hashed features
  and aggregate witness scores lose information relevant to ranking.
- Readable canonical edit explanations are not executable inverse mappings.
  Learning their strings alone cannot establish source realizability.
- Action-menu coverage has not been exhaustively measured on held-out tasks.
- Qwen receives partial schema/instances, not all helpers or natural-language
  requirements. Comparison arms have unequal observations and budgets.
- NF4 training and Q3 inference are numerically different. Their transfer is
  tested end-to-end, not proved equivalent; aliases are not provenance.
- Scoped Lean proofs do not close Java/Python refinement, numerical correctness,
  independent certificate replay or unbounded Alloy validity.
- TAR's bundled JAR is hashed but not proven identical to a fresh source build.
- Temporal/imported/parameterized tasks are preflight exclusions in this repair
  slice, not learned failures or successful repairs.
- `/tmp` checkpoints/logs are local evidence, not durable public archives. Hashes
  cannot recreate omitted bytes. No unresolved cause is a proved diagnosis.

## Publication Scope

This commit archives documentation, Lean specifications and compact evidence.
The experimental runtime code and launchers remain local untracked development
work, not part of this documentation commit. Reproduction commands describe the
tested author workspace, not a self-contained release at this commit. Historical
verification claims remain attached to their recorded input roots.
