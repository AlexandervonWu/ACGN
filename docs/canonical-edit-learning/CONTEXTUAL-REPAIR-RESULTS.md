# Contextual Repair Prototype: Results

2026-10-04. **Synthetic training fixtures only. No held-out or corpus result.**

The new graph/GRU policy can retain context across construction decisions and
failed attempts. The controller requests a real check initially and after each
committed attempt; it cannot convert a predicted outcome into semantic acceptance.
The original Java executor, canonical metrics and certification remain unchanged.
See the [specification and proof correspondence](CONTEXTUAL-REPAIR.md).

## Actual Episodes

All three inputs have `sig S {}` and the faulty predicate `some S`, checked at
scope three. Only the private evaluator receives the oracle predicate. The
public demonstrator enumerates `no S`, `one S`, then `lone S` and sees genuine
feedback between candidates. Its labels never read the oracle body.

After 120 updates, the learned model reproduced these paths:

- Oracle `one S`: initial failure, failed `no S` attempt, successful `one S`.
  Three real queries; eleven charged construction/controller decisions.
- Oracle `lone S`: initial failure, failed `no S`, failed `one S`, successful
  `lone S`. Four real queries; sixteen charged decisions.
- Oracle `#S = 2`: all four checks return counterexamples. The run ends at the
  query limit, **not success**. This unsuccessful episode is retained and is
  freshly replayed as training data, not discarded from the denominator.

Both the public enumerator and the trained model solve two of three fixtures.
There are zero learned-worker errors. This verifies an executable multi-attempt
loop, not an improvement over the enumerator or over previous corpus studies.
The model can be imitating the same enumeration regardless of witness contents;
contextual repair reasoning has not been demonstrated by these three cases.

## Model And Training

- Typed GIN-style graph encoder, width 32, one message layer.
- GRU memory across public packets; no reset between attempts, reset per episode.
- Existing structured action/pointer decoder, plus pre-query outcome prediction.
- 119,277 parameters; AdamW at 0.001; 120 finite nonzero-gradient updates on CPU.
- Whole-episode imitation of public search plus outcome classification, not RL.
- Failed attempts remain in context. Future check results are labels, not inputs.
- STOP/VALIDATE are not learned choices in this prototype: real validation is
  controller-scheduled. ABSTAIN remains an explicit non-success choice.
- All query and decision charges still come from the existing Java interface.

This changes the control protocol, so it is not a matched ablation against the
previous model-controlled STOP policy. It also does not establish that a larger
model will improve performance. No Qwen or roughly 500M training was started.

## Verification And Evidence

The new standalone Lean file compiled before the natural-language specification
and runtime code. Its 16 model declarations compiled again in two fresh builds
with matching proof inventories and only the declared standard Lean foundations.
The new ten-test runtime suite passed. Together with the unchanged base preflight,
352 Java/Python check executions passed. The base preflight also rebuilt its
78 existing Lean model/fixture declarations; none of these proofs establishes
universal implementation refinement or neural learning effectiveness.

The tests cover a real failed attempt followed by a checked repair, retention of
an unsuccessful episode, fresh replay, held-out refusal, source identity,
counterfeit feedback rejection, forced verification, prefix-only memory, reset,
historical pointers and gradients through memory/encoder/outcome parameters.
The small saved checkpoint reloads strictly and has finite parameters.

The final run is `/tmp/acgn-contextual-20261004-v2` and took about 71 seconds,
including the full base preflight. A prior prototype run had the same fixture
outcomes; v2 reran everything after tightening proof-dependency checks and
manifest bookkeeping. This was not a response to a worse repair score.

Curated evidence is in `results/contextual_repair_20261004/`. The audit verifies
445 frozen input hashes and 1,068 output hashes. The archive includes the small
checkpoint, full observations/actions/outcomes, proof/test logs and frozen source
versions, including proof-bound documents before later index updates. Compiled
Java classes and dependency JARs are excluded; rebuild using the existing `lib/`
dependencies. Source HEAD is `67cb5f3dfe226b15e2647fe6d18534fa03995cbc`, with a
dirty worktree; content hashes identify the actual implementation.

## Next Gate

Before another large run, require branching problems where the same faulty
structure and candidate need different next repairs after different returned
counterexamples. Compare persistent memory, reset memory and blinded-feedback
policies with identical verification schedules and budgets. Include diverse
unsuccessful attempts and query-budget failures. Only then test question-disjoint
held-out repair. The present prototype does not satisfy that next gate.

Reproduce with the command in [the specification](CONTEXTUAL-REPAIR.md#reproduction).
