# Corpus Training And Stable Random-Walk Comparison

## Frozen Intent

The eight model theorems in `formal/CorpusProtocol.lean` were compiled before
this document and the corpus extension. They cover exact sorted schedule
admission, positive schedule dimensions, identical split-key assignment, and
the five-seed comparison predicate with bounded counts and no aborts. They do
not prove statistical generalization, dataset extraction or learning efficacy.

Use genuine incorrect student predicates from `classified-data`, unchanged.
Create derived copies outside that directory with one appended independent
`run {} for 3` command. Preserve the rest of each source byte-for-byte; record
both hashes and the appended command index obtained by the Alloy parser.
This is an explicitly new bounded scope-3 repair profile, not the original
dataset-wide equivalence classification. Record initially solved/vacuous cases
and unsupported inputs as preflight exclusions, not training failures or repairs.

Only the existing atemporal, import-free, parameterless-predicate repair profile
is supported. Use deterministic source-path ordering by hash and a per-question
cap. No selection by learned/random success or distance-to-oracle is allowed.
Use only one version of duplicated question sets in this first subset. Assign
whole `(problemClass, invariantId)` groups to train/validation/evaluation by a
fixed hash; forbid source-hash or group overlap across splits. This guarantees
disjoint declared questions, not universal semantic-clone detection.

## Training

The existing task-block schedule remains the default. An optional bounded chunk
schedule shuffles task order deterministically between rounds and interleaves
the same number of episodes per task. Flattened `(task, episode)` indices must
sort to exactly the complete task-by-episode range, checked by executable Lean
before training. Each chunk creates a fresh task worker and instance bank;
bank state is retained within the chunk only. Random/learned evaluation workers
remain independent and receive the same initialization and action horizon.
All changes to a rollout remain governed by the existing proof gate. No replay
buffer, off-policy update, teacher action or oracle body is supplied to the policy.

The experiment retains five supported encoder families and fixes finite grids
before training. Choose configurations only from validation repair counts, with
smaller parameter count breaking ties. Test the chosen configurations using five
fresh seeds. Do not revisit model selection after observing final test scores.
All trials, failed runs and exclusions must remain in the record.

## Stable Improvement Criterion

The primary outcome is solver-checked repair within the supported profile and
fixed action horizon. Uniform random action selection is the random-walk baseline,
including invalid proposals and STOP; both models have the same menu and budget.

Call a model empirically stable on this held-out subset only when:

1. Every one of five fresh seeds has strictly more learned repairs than random.
2. All paired budgets match; all trials completed; none began already solved.
3. A deterministic 10,000-resample, question-cluster percentile bootstrap of the
   paired repair-rate difference has its 2.5th percentile strictly above zero.

The Lean predicate checks item 1 and the count/abort parts of item 2. Python checks
seed/task identity and matching protocols. The bootstrap is a numerical reporting
procedure, not a theorem of generalization; correlated tasks and the sampled
question population limit interpretation. Report per-seed and per-question results,
even when the criterion fails. Multiple selected families are exploratory
comparisons, not multiplicity-adjusted confirmatory statistical claims.

## Verification And Trust

Add finite tests for schedule coverage/determinism, split isolation, five-seed
rejection cases, bootstrap pairing, parser-produced independent command metadata,
and unchanged source copies. Run the existing two-clean-build Lean/Java/Python/CUDA
gate before the corpus experiment. Freeze source/proof/configuration hashes and
retain run manifests. No static semantic rewrites or certificate rules change.

Lean runtime, PyTorch/CUDA, the solver, hashing and the platform remain the declared
TCB. Full application refinement remains open. Passing registered bounded tests
does not prove all future corpora are supported. Preflight exceptions are logged;
training/evaluation exceptions invalidate that run rather than count as negatives.
