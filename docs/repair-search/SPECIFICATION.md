# Verifier-Guided Repair Learning: Bounded Pilot

## Status And Order

`formal/SearchLearning.lean` compiled before this specification and before the
new implementation. Eight theorems establish the abstract two-direction
equivalence check, counterexample rejection, bank monotonicity, survival of real
solutions, decreasing search fuel, and admission checks for results and training.
The first compilation rejected unavailable tactics; replacing them with explicit
proof terms produced a clean compilation. There are no proof placeholders.

The Java solver, Alloy translation, Lean runtime, Python, PyTorch, CUDA, model
loader, quantization and adapter conversion are trusted dependencies. The Lean
theorems do not prove the full implementation, training convergence, or universal
Alloy equivalence. Java-to-Lean refinement remains an open obligation. Runtime
receipts check recorded facts; they do not independently prove solver answers.

## Common Contract

Use the first 16 training and first 8 evaluation entries of the previously frozen
`docs/rl-corpus-data/tasks.json`, without outcome-dependent selection. Retain
whole-question split isolation. This is a feasibility pilot, not a new stable
superiority claim. Original source files remain unchanged.

Every task fixes its source context, target, excluded oracle and independent
`run {} for 3` command. Only the target predicate body may change. A proposal must
parse, respect existing forbidden-call and source-boundary checks, and preserve
the exact semantic profile. Success requires satisfiable context and UNSAT for
both `context and candidate and not oracle` and
`context and oracle and not candidate`. Unknown, timeout, invalid input and
exhausted search are distinct outcomes. Sample agreement alone never means
success. This study requests no e-graph certificate replay.

Concrete positive/negative witnesses contain relation valuations and their
oracle labels. They may guide search and language-model prompts; oracle source
is never a policy input. The correct body is a supervised target for training
tasks only. Failed candidates can contribute counterexamples, never positive
repair labels. Evaluation cannot update model weights. Counterexamples refute a
particular candidate, not all possible repairs of its descendants.

## Methods

1. **AlphaProof-inspired repair search.** A small policy/value network guides a
   bounded PUCT tree over the existing typed edit menu. Terminal success is a
   solver-checked repair. Search visit distributions and bounded-search outcomes
   train policy/value heads on training tasks. Use a uniform-prior search control
   to separate search benefit from learned guidance. This is an adaptation of
   verifier-guided search/learning, not a replica of AlphaProof: no Lean tactic
   generation, AND-OR proof decomposition, massive autoformalization curriculum,
   or test-time parameter learning is claimed.
2. **Qwen base.** The retained unadapted local Q3 model proposes predicate bodies.
3. **Qwen supervised LoRA.** Response-only training on checked training repairs.
   Train from the existing local NF4 checkpoint, then export the adapter onto
   the retained Q3 inference base. The distinct quantizations must be recorded;
   never describe this as backpropagation through the GGUF Q3 weights.
4. **Counterexample-guided LoRA.** A separate adapter additionally sees failed
   training candidates and their concrete counterexamples, paired with checked
   corrected bodies. Evaluation may request revised proposals with new witnesses
   but cannot use evaluation data in gradient updates.
5. **TAR.** Execute the locally supplied upstream tool with its own typed mutation
   inventory and counterexample-priority pruning. Recheck every claimed solution
   with the common evaluator. Its action space is broader than the existing RL
   menu, so distinguish practical end-to-end comparison from controlled ranking
   comparisons. Record upstream repository commit and exact executable hash.

Search uses depth 3 and at most 32 expansion attempts per task; each invalid
proposal consumes an attempt. Qwen uses at most 4 proposals per task, at most
512 output tokens per proposal, and a 120-second request deadline. TAR uses
depth 3 and a 60-second internal search deadline, with an external process
deadline. Report elapsed time, attempts, solver calls, invalid proposals,
timeouts, checked repairs and training costs; unequal search spaces/budgets
must remain visible. Use three fresh seeds for the cheap policy search; a single
deterministic language-model pilot is not a stability estimate.

## Formal Correspondence Obligations

- `two_direction_check`: common validator's two SAT queries, conditional on
  trusted bounded Alloy semantics and solver answers.
- `counterexample_refutes`: only retain context-valid, oracle-labelled witnesses.
- `bank_extension` and `true_solution_survives_bank`: candidate filtering never
  promotes passing the bank to equivalence or prunes all descendants.
- `budget_decreases`: each attempt reduces remaining finite search allowance.
- `accepted_has_checks`: every reported repair must carry a runtime admission.
- `accepted_training_is_train`: every positive supervised target is admitted
  with split `train`; all other splits are rejected for training admission.
- `accepted_bound`: result admission cannot exceed its declared attempt budget.

Tests must exercise positive and negative admission, wrong profile/source,
oracle calls, boundary escape, invalid syntax, invalid candidate witnesses,
training/evaluation separation, and an actual source-to-solver repair. Numerical
gradient changes and save/reload checks are tests under the ML TCB, not Lean
proofs of optimizer implementation.

## Sources

The AlphaProof paper describes a policy/value network, verifier-grounded search,
and learning from generated experience. This pilot borrows that loop at small
scale: [Hubert et al., Nature](https://www.nature.com/articles/s41586-025-09833-y).

TAR uses typed mutation search with stored counterexamples to avoid redundant
solver calls. Local references are `/home/augustus/lp_baselines/SEFM22.pdf` and
`/home/augustus/lp_baselines/TAR`, especially `Repairer`, `MutationStepper`, and
`RepairCLI`. Its published results are not measurements of this new pilot.
