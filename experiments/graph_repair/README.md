# Graph To Repair Program

This study replaces the four-template one-step ranker with complete supervised
graph construction patches. It does not modify canonicalization or certificate
admission. Read the [study and proof boundary](../../docs/canonical-edit-learning/GRAPH-PATH-STUDY.md).

From the repository root:

```bash
bash scripts/run_graph_path_training.sh /absolute/fresh/run-root 4096 8
```

Requirements: existing Java 17 `lib/*`, Lean, and the CUDA PyTorch environment
at `$HOME/.venvs/acgn-rl-cu130` (override with `ACGN_RL_PYTHON`). No downloads or
reward solver run is performed. Compile/export uses 12 bounded Java workers;
training uses one GPU, about 504M parameters, BF16 compute, FP32 master weights,
Adafactor, effective batch 128 and microbatch 8. Checkpointing preserves memory.
The context is 4096 tokens and the complete output is bounded to 1536 tokens.
Whole out-of-bound examples are logged, never silently truncated.

The 128-ID alphabet encodes DAG node references, a source-only string table,
generic signature/field/slot tokens and arbitrary labels by lossless escapes.
No fixed semantic edit menu is constructed. Keys contain faulty graphs and the
module declaration schema; values contain COPY/BUILD/EOS programs. The module's
facts, commands and helper source bodies are not full-text input modalities.

Outputs retain sources' hashes, raw exported graph pairs, replay-checked packets,
split/exclusion ledger, training history, checkpoint, complete generated programs
and results. Question-disjoint split and within-question graph-pair deduplication
precede training. Mirrored classroom datasets share a split. The validation
and test splits additionally exclude identical input keys already in an earlier
split (train first, then validation, then test). The validation
token loss selects the checkpoint; evaluation graph-match never selects it.
This loss criterion is recorded, not claimed to optimize behavioral repair.

Greedy generation has syntax-only masks, not a semantic action menu. Invalid
references/UTF-8 and unfinished programs are failures. The maximum generation
budget is min(1536, 4096 - longest source prefix in the decode batch); length
sorting limits padding, and every prediction records its actual budget.
The target never determines that budget. Replay validity does not assert
type correctness. Exact graph reconstruction is not an Alloy solver success:
source realization and the existing two-direction equivalence gate remain open.
