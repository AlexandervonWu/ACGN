# Application Proof Boundary

## Objective

PyTorch and CUDA are external trusted computing base (TCB) components. Our
application code is not made trusted merely because it calls them. The target
is proof of the application contracts relative to explicitly stated backend
contracts, with separate correspondence obligations for the actual producers,
consumers, and process boundaries.

**Whole-application refinement remains open.** Kernel-checked abstract
properties, bounded differential tests, and a Lean runtime admission decision
have different meanings. None independently establishes that a Java solver
reply describes the right Alloy query, or that every Python operation refines
its mathematical specification. Previous finite verification reports retain
their original, narrower scope.

## Trusted Foundations

- Lean's kernel, standard logical foundations, compiler, and runtime. No new
  `axiom`, `sorry`, `unsafe`, or `native_decide` is used in the application proof.
- PyTorch tensor operations, indexing, autograd, distributions, optimizer, and
  serialization under their actual finite-precision semantics; CUDA, its
  runtime/driver, and hardware. Floating-point addition is not assumed
  associative. This does not prove convergence, policy quality, or exact
  permutation invariance of GPU reductions.
- CPython/JVM execution, standard JSON and cryptographic implementations, OS
  process/file operations, and hardware. Custom parsers, feature extraction,
  and glue remain application obligations, not additional trust assumptions.
- Existing Alloy parser/type checker and SAT solver boundaries, relative to a
  fixed source command/profile. Application construction of queries and
  association of answers with source states remain correspondence obligations.

An error, missing checker, rejected trace, timeout, or absent semantic evidence
does not authorize an optimizer update or certify an Alloy equivalence.

## Proof and Execution Chain

`formal/ApplicationCore.lean` first defines and proves the admission contract.
`formal/ApplicationGate.lean` decodes a bounded JSON request, executes that
decidable contract, and computes exact integer suffix returns only from an
accepted proof-bearing request. The Python supervisor records the checker and
proof hashes, binds the response to the submitted request, and supplies the
checked returns to the loss implementation before invoking PyTorch.

Admission requires a nonempty terminal rollout of at most 32 steps. Each step
selects an existing menu action, consumes exactly one attempt, preserves the
semantic profile, advances its token, and satisfies the integer reward
equation. Continuing steps retain the instance bank and a positive remaining
budget. A terminal step has zero bootstrap potential. Adjacent records must
agree on tokens, budgets, bank versions, profile, and potential. A reported
solution requires recorded satisfiable context and both UNSAT directions.
Evaluation, censored trajectories, and changed policy generations are rejected.

The solver-answer fields are evidence *labels*, not SAT proofs. Admission
certifies their required presence and consistency, not their truth or the
Alloy-to-query correspondence. Independent semantic certificate replay remains
`NOT_REQUESTED` in this learning pilot.

The exact integer suffix-return computation is executed in Lean. Division by
1000 and tensor conversion occur at the trusted numerical boundary. The
potential telescope holds over integers before this conversion; it is not a
claim of exact real-number GPU arithmetic. The model loss description uses
separate data inputs and differentiable inputs, so the detached baseline has
no direct actor gradient path while the critic retains its value path. Actor
and critic still share encoder parameters.

## Claim Ledger

- APP-01: admission preserves the exact submitted request and implies all
  rollout constraints. Proved by `admitted_request_is_input`,
  `admitted_request_has_valid_rollout`, and the `admitted_*` step theorems.
  Runtime consumer: `ApplicationGate`. JSON/worker correspondence remains open.
- APP-02: suffix returns have the same length as the rollout and each target
  is its exact remaining reward sum. Proved by `returns_length`,
  `return_at_suffix`, `target_count`, and `target_suffix_total`. Lean executes
  these integer computations; Python response/trajectory binding is tested.
- APP-03: terminal-zero shaping telescopes to base return minus the initial
  potential. Proved by `rollout_shaping_constant`. This assumes the checked
  step potential values; it does not prove the Java bank scoring function.
- APP-04: evaluation/censored/changed-policy requests cannot authorize an
  update. Proved at the admission boundary by
  `admitted_request_is_training`. Python caller mode/version fidelity is an
  open implementation correspondence obligation, with negative tests.
- APP-05: typed loss expressions have explicit detached/data dependencies.
  The five gradient-path theorems check the expression model. They do not
  verify PyTorch autograd internals or formally translate Python bytecode.
- APP-06: feature buckets/clipping bounds, selected-index validity, reverse
  edge positions, and preservation of duplicate edge occurrences are proved
  for their core models. Actual Java feature extraction and Python graph
  assembly have bounded tests, not full refinement proofs.
- APP-07: equal checkpoint architecture contracts preserve hidden width,
  layer count, schema, and contract hash. `checkpoint_matches_architecture`
  proves the contract; checkpoint save/load tests exercise the Python bridge.
  It is not a proof of serialized tensor integrity or exact rollout resume.

## Open Correspondence Work

- `RepairTask`, action enumeration, and `RepairEnvironment`: source spans,
  parse ownership, source edits, semantic profile selection, and reconstruction
  into the certified representation. RL-1 proves a transition model, not this
  complete implementation.
- `RepairEvaluator` and `RepairFeedback`: query/source alignment, retained
  instance identities and labels, duplicate retention behavior, exact scoring,
  and snapshot lifecycle. RL-2's existing Boolean/integer model and paired
  test matrix are bounded evidence rather than a full Java translation proof.
- `RepairObservation` and `model.forward`: extraction of all source/binding
  graph features, no forbidden oracle leakage through the producer, typed
  graph assembly, and its correspondence to the tensor computation. Feature
  collisions do not define semantic equality.
- `RepairWorkerMain`, `worker.py`, and the Lean gate adapter: interpretation of
  raw replies, source/profile/token ownership, termination, and linkage of
  checked records to tensors. The new runtime gate narrows this gap; it does
  not prove the producer.
- `experiment.py`: split lineage beyond exact hashes/groups, on-policy tensor
  provenance, policy-generation bookkeeping, exceptional optimizer behavior,
  checkpoint lifecycle, and manifest completeness.
- `model.update_policy`: correspondence of the composed numerical loss to
  the typed loss expression, including entropy and clipping/optimizer calls.
  Backend correctness is trusted; our choice/composition of operations is not.

Closing these requires a verified application interpreter or explicit
implementation-refinement bridges. A green regression suite cannot silently
change these entries to proved. Learning effectiveness, corpus performance,
and training convergence are empirical questions, not admitted theorems.

The graph-encoder increment has its own [proof/test ledger](GRAPH-ENCODERS.md)
and `encoder-claims.json`. Its 21 model theorems establish graph-scheduling and
dimension/normalization obligations, while a 400-row schedule matrix and dense
CUDA references check bounded correspondence. They do not close the full
feature-extraction or neural-composition refinement obligations above. GCN/GAT/
GIN are alternate policies over exactly the same semantic repair environment.
Checkpoint architecture additionally binds encoder family, head count, and the
graph proof/implementation contract hash; obsolete architectures fail closed.

## Incident and Migration Notes

The original learning update accepted unannotated tensor/reward tuples and
accumulated floating-point returns without an executable proof gate. The new
path will require a checked complete trace and Lean-computed integer targets.
This changes numerical evaluation order slightly and requires fresh pilot
evidence; old deterministic training outputs are not reused as current proof.

Checkpoint loading previously reconstructed the default two-layer architecture
even though the public policy constructor/save interface allowed other layer
counts. The architecture contract now includes the actual layer count as well
as width, observation schema, and proof contract hash. Old checkpoints without
that contract must fail closed instead of guessing an architecture.

No canonical metric, semantic certificate rule, published result directory,
or full-corpus experimental program is changed by this RL assurance work.
