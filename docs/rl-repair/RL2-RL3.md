# RL-2 and RL-3: Feedback and Learned Structured States

Implementation order: the standalone `formal/FeedbackLearning.lean` model was
kernel-checked first, this contract was written second, executable code follows.
The scope remains the source-backed RL-1 action families and atemporal,
self-contained, parameterless predicates. Publication runners, results, rewrite
theory, certificates, and the established distance semantics are unchanged.

The next proof-first increment adds 33 application-contract theorems and an
executable Lean rollout gate. See [APPLICATION-ASSURANCE.md](APPLICATION-ASSURANCE.md)
for the explicit TCB and outstanding Java/Python correspondence obligations.
The [graph encoder extension](GRAPH-ENCODERS.md) adds selectable edge-aware
GCN, multi-head GAT, and GIN alongside the gated-MPNN baseline, with 21 further
model theorems, dense-reference CUDA checks, and a matched multi-seed runner.

## Formal Contract and Correspondence

Fourteen Lean theorems establish the following abstract properties:

- `solved_requires_two_unsat`: success needs a compatible context, a SAT context
  witness, and actual UNSAT answers in both disagreement directions.
- `vacuous_is_not_solved`, `unknown_is_not_unsat`: inconsistent contexts and
  unknown answers cannot count as a repair.
- `two_directions_characterize_equality`: excluding both Boolean disagreement
  directions establishes equivalence on the chosen domain. Solver internals are
  external TCB; application query/domain correspondence is a separate open
  obligation, not proved by this theorem.
- `bank_capacity`, `new_witness_is_retained`: bounded front insertion retains a
  new witness and evicts from the tail; this is FIFO, not the old LFU implementation.
- `changed_bank_ends_rollout`: versioned feedback from different banks is not
  treated as one stationary rollout.
- `shaping_telescopes`, `terminal_shaping_constant`: undiscounted potential
  differences telescope. Every terminal segment has potential zero, so shaping
  adds only the negative initial potential to the segment return.
- `invalid_action_zero_weight`, `allowed_positive_weight`: an abstract masked
  action distribution excludes invalid actions and retains positive valid weights.
- `baseline_sum`, `constant_baseline_cancels`: a state-constant baseline cancels
  against a zero-sum derivative list. This is the algebraic contract, not a proof
  of floating-point softmax, PyTorch autograd, or statistical convergence.
- `oracle_not_a_policy_input`: changing private oracle text does not change a
  fixed public observation. Actual producer feature filtering needs separate tests.

The executable matrix compares 128 feedback classifications and 27 integer reward
triples between Lean and Java/Python. Real Alloy fixtures test query directions,
vacuity, bounds, pool insertion and later iteration. GPU tests check masks,
structural sensitivity, gradients, checkpoint reload, and an actual supervised-by-
solver training run. These are bounded implementation checks, not a whole-program
Java/Python refinement proof. No proof placeholders or new axioms are introduced.

## Semantic Feedback

An evaluator privately owns one parsed source module, the selected independent
`run` command, fixed SAT4J options, the oracle, and two retained instance banks.
The admissible context is model facts AND the selected command's formula, under
that command's scopes and integer settings. Use `run {}` when no additional
restriction is intended. `check` commands are rejected by RL-2 rather than
silently changing assertion polarity. Oracle dependencies on the editable
predicate are rejected, including transitive calls.

The candidate body is reparsed inside the evaluator's unchanged module for
instance evaluation. This preserves signature/field object identity across
retained Alloy solutions; solutions from unrelated modules are never mixed.
RL-1 independently reparses/prepares the full emitted candidate first.

Queries use the selected command's search domain:

1. Context satisfiability, to detect vacuity.
2. `context and candidate and not oracle` (underconstraint witnesses).
3. `context and oracle and not candidate` (overconstraint witnesses).

Every successful claim is `SOLVED_WITHIN_PROFILE`, never unbounded equivalence or
independent certificate replay. Sample accuracy 1 only triggers both solver
queries; it does not itself establish success. `STOP` and exhausted episodes also
request validation. Solver errors/timeouts abort a rollout and are excluded from
gradient updates, but retained in experiment failure counts.

Capacity defaults to 100 actual instances per positive/negative class. Initial
seeding may use fewer instances and records its counts. Empty classes are
reported explicitly. Sample potential is the integer mean of available class
accuracies, each scaled to [0,1000]. Retained objects are iterated explicitly;
new solver witnesses must be visible on the next evaluation. The bank ID includes
the task profile and retained instance keys. Exact serialized-valuation duplicate
removal is not isomorphism reduction.

Each rollout holds a snapshot. New witnesses are committed only at a validation
boundary, and a changed bank ends the segment before further policy updates.
The next reset preserves the evaluator's bank but creates a fresh RL-1 state.

## Structured Policy Input

The public observation contains two graphs: the certified repair projection
(matrix/container/binding structure) and the editable source occurrence tree.
Nodes have categorical operator/type/container/binding-role features and bounded
numeric shape features. Edges distinguish children, ordered positions, binding
uses, declaration dependencies, phases, and certified alternatives. Repeated Bag
operands remain repeated occurrences; Set order is not an identity feature.
Source variable spellings and arbitrary e-class IDs are not semantic identity.

Actions point to source occurrence nodes and carry kind/operator/shape features.
The policy receives only structured feature arrays and budget/feedback counts.
It does not consume oracle bodies, full paired source, canonical distance to a
truth, source hashes, candidate IDs, or task names as learned inputs. Protocol and
audit metadata remain outside the neural input. No inverse of normalization is
assumed: source and canonical graphs are independently encoded and pooled.

The CUDA model learns categorical embeddings, message-passing layers, an action
scorer, and a state-value head. Typed edge/position features distinguish ordered
containers; sum aggregation supports unordered containers and multiplicities.
The Java-issued menu is the action mask. Padded actions, when tested, receive
negative-infinite logits. Learned outputs can select actions, never forge theory
authority or merge meaning-changing repair states.

## Learning and Budgets

Use finite episodic on-policy actor-critic (REINFORCE with a detached state-value
baseline), gamma=1, Adam, clipped gradient norm, and optional entropy regularization.
The terminal reward is +1000 for bounded success; an ordinary step costs 10 and
a rejected proposal costs 50. Add `Phi(next)-Phi(current)`; terminal Phi is zero.
Scale integer rewards by 1000 only for optimization. Do not backpropagate through
solver results. No claim of learning convergence or advantage over search follows
from passing a smoke test.

Before every update, the Lean gate checks the complete step chain, profile,
budget, menu index, bank versions, policy generation, success-evidence labels,
and shaping equation. It computes exact integer suffix returns. The loss consumes
those checked targets, then converts/scales them at the PyTorch boundary.
Gate failure censors the segment rather than proceeding without a checker.
The run retains gate/proof hashes and each accepted request hash. These are
application-contract receipts, not Alloy semantic certificates.

Manifest tasks explicitly declare train/evaluation split, question-family group,
target, oracle, independent command index, and source file. Reject groups shared
across splits and duplicate source contents across splits. Dataset-wide ancestry/
near-clone audits remain a prerequisite for publishing corpus generalization
results; fixture pilots alone are not such an audit. Evaluation never updates
weights. Random and learned policies use the same actions, horizon, evaluator,
seed schedule, and solver budgets. Report failures in the denominator.

The Python supervisor owns a bounded Java worker process, using JSON-line replies
on stdout and diagnostic logs on stderr. A response timeout kills and reaps the
whole process group; it does not leave a solver thread running. JVM heap and
observation/source/menu sizes are bounded. GPU memory is reserved for the policy,
not Alloy. Each task keeps one worker; no nested worker pools are introduced.

Runs use new output directories and retain configuration, dependency versions,
input/code hashes, episode/transition logs, checkpoints, and summaries. Frozen
checkpoints include model/optimizer/RNG/configuration state; reloading a policy
must reproduce its logits. Evaluation defaults to explicit CUDA and must not
silently fall back to CPU. CPU is an explicit test/debug choice.
Checkpoint architecture records actual hidden width and layer count, observation
schema, and application-proof contract hash. Older checkpoints without the
contract are rejected; inference does not guess the default layer count.

## Incident Ledger

- Preflight: PyTorch 2.0.1+cu117 cannot execute `sm_120` kernels on the local RTX
  5080. Use an isolated current CUDA wheel environment; preserve the old runtime.
- Proof development: Std has no `by_contra` tactic here; use explicit case splits.
  The bounded-bank proof uses `Nat.min_le_left`. Failed development compilations
  are not verification evidence.
- Type/instance boundary: reusing solutions with an expression parsed in another
  module can misbind Alloy signatures. Parse candidate expressions in the bank's
  fixed module; keep full fresh-source preparation as a separate acceptance gate.

## Reproduction

Install/update only the isolated environment (network needed for this installation;
proof checks, tests, and training use local files afterwards):

```bash
./scripts/setup_rl_cuda.sh
./scripts/run_rl_learning_tests.sh /tmp/acgn-rl23-check-01
./scripts/run_rl_learning.sh \
  --manifest docs/rl-repair/fixtures/pilot.json \
  --output /tmp/acgn-rl23-pilot-01 --device cuda \
  --episodes 20 --eval-episodes 3 --horizon 4 --capacity 100
```

Use fresh output directories. The local environment is
`~/.venvs/acgn-rl-cu130`; override `ACGN_RL_PYTHON` to select another compatible
environment. Pins are in `rl/requirements-cuda.txt`. The local RTX 5080 was tested
with PyTorch `2.14.1+cu130`, CUDA wheel runtime 13.0, and driver 610.43.02.
See [official installation instructions](https://pytorch.org/get-started/locally/)
for platform setup; no external theory material is used by the proofs.

The test runner reuses both fresh builds from the RL-1 gate, checks the additional
Lean model first, and executes the new Java, GPU, and pilot tests twice. It compares
the additional Lean object, feedback matrix, episode results, and learned parameter
tensors, allowing recorded timings and output paths to differ. Its machine-readable
report is the authority for the bounded checks, not this prose.

The manifest is deliberately explicit; `pilot.json` illustrates its schema.
Real dataset tasks must provide an independent source `run` command, group/split,
target and oracle. Unsupported temporal/imported/parameterized tasks are not
silently transformed. Do not use the illustrative two-task manifest to claim
dataset generalization. This runner does not automatically construct a leakage-
audited split of `classified-data`.

Outputs include `run-manifest.json`, `episodes.json`, `transitions.jsonl`, worker
logs, `policy.pt`, and JSON/Markdown summaries. Full paired sources and oracle text
are not neural inputs. Feature token hashing and bounded numeric encodings are
approximations for learning, never equality keys or certificate evidence.

`acgn_repair.experiment.load_policy(path, device)` reloads a checkpoint for
inference. Checkpoints retain optimizer/RNG state, but exact resumption of an
interrupted evaluator bank is not implemented; the run is not silently resumed.

## Remaining Assurance Boundary

External TCB: Lean and its standard libraries/runtime, JDK/CPython, Alloy parser
and SAT4J primitives, PyTorch/CUDA and the GPU driver, hashing/JSON/OS/hardware.
Custom Java/Python application logic is not silently made trusted. Its remaining
refinement obligations are recorded in APPLICATION-ASSURANCE.md and
`application-claims.json`; whole-application refinement is explicitly `BLOCKED`.
GPU numerical identity across devices, unbounded Alloy equivalence, policy
optimality, full-corpus repair coverage, and independent semantic replay are not
established by this pilot. The learner adds no certificate authority.
