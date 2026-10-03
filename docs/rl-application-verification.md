# RL Application Contract Verification

Date: 2026-10-03. This increment follows the requested order: Lean contracts and
proofs, natural-language assurance ledger, runtime implementation, then bounded
verification. No internet or external theory source was used for this increment.

## Scope and Result

The frozen finite verification gate passed **7/7 claims in two clean builds**.
Whole-application implementation refinement remains **BLOCKED**, not implicitly
trusted. [The claim ledger](rl-repair/APPLICATION-ASSURANCE.md) lists the exact
proof meanings, external TCB, open correspondence bridges, and two implementation
incidents addressed here. PyTorch/CUDA are external TCB; custom application logic
is not silently included in it.

Input root: `9ef03718739260dd8dea5266dc9a6c4ac8e830db07dc099a7de4d073d043ddf5`.
The [machine report](rl-application-verification.json) records environment,
verifier/evidence hashes, limitations, and results. Raw checks, manifests, pilot
traces, compiled proofs, and checkpoints are retained at
`/tmp/acgn-rl-application-check-01`.

Each build checked:

- 15 existing RL-1, 14 feedback, and 33 new application-contract Lean theorems.
- 128 controller and 155 feedback/reward differential matrix rows.
- 64 RL-1 and 38 feedback Java assertions.
- 18 Python/CUDA/Lean-gate tests, without skips or CPU fallback.
- Existing CanonicalAlloyPipelineTest (2,041), QuotientRepairDistanceTest (2,266),
  and SemanticProfileSourceCommandTest (44) assertions.
- 20 actual CUDA optimizer updates with Lean admission receipts; zero aborts.

Both builds produced identical proof objects, learned tensors, and deterministic
episode records. The complete check took about 175 seconds on this host.
Each pilot solved 16/20 training episodes. Held-out results were learned 0/3 and
random 2/3; this is functional evidence, not evidence of policy superiority.
Independent semantic certificate replay was not requested.

## Executable Changes

Lean now checks complete rollout continuity, menu/budget/profile/bank constraints,
policy generation, success-evidence labels, and integer shaping before supplying
exact suffix-return targets to an optimizer update. Rejected or censored traces
cannot take the normal update path. The proof does not establish that the
producer's solver-answer labels describe the right source query.

Checkpoint reload now reconstructs the actual layer count instead of always
assuming two layers, and checks its schema/proof contract. Tests exercise a
three-layer round trip and stale-contract rejection. The loss uses checked
integer sums before numerical conversion, avoiding a separate floating-point
return-accumulation implementation.

The tracked pre-existing Java metric/certificate code, publication data, and
experimental runners have no diff. This work remains in the new RL extension.

## Reproduce

Use a fresh directory:

```bash
./scripts/run_rl_learning_tests.sh /tmp/acgn-rl-application-check-02
```

This uses the isolated pinned PyTorch/CUDA environment and Lean 4.33.0. The
machine report distinguishes the finite gate's `VERIFIED` status from the
explicitly `BLOCKED` whole-application refinement objective. No test result is
promoted into an implementation theorem.
