# Local Repair Runtime And Correspondence

Contract: `local-feedback-repair-v1`. Implementation date: 2026-10-04.

This implements a bounded training slice of the
[local-repair specification](LOCAL-REPAIR-SPECIFICATION.md), not a universal
Java/Lean refinement or a claim of complete repair-language coverage. The
metric, certified equivalence rules and original corpus are unchanged.

## Implemented Flow

`LocalFeedbackTeacherMain` is a separate offline training executable. It cannot
be requested through `FeedbackRepairWorker`. It accepts training-only requests,
reconstructs an optional real learner prefix, checks its complete public snapshot,
and proposes a continuation. It aligns structurally matching source contexts,
constructs mismatching occurrences and reuses public COPY operands. Replacements
currently use MATRIX_UPDATE transactions; fine-grained family labels and alternate
minimum-cost local experts remain future variants, not implemented capabilities.

The expert uses a structural alpha key only for proposing/stopping construction.
That key provides no semantic authority: each continuation must still pass the
real source preparation and final two-direction bounded Alloy check. Reference
binders not locally alignable by the current conservative scope matcher are
explicit coverage failures. At most eight edit transactions are proposed; there
is no shortest-path claim, beam enumeration or complete local-search guarantee.
Root replacements are recorded, with counts of reused operands; they are not
relabeled as non-root edits. The protocol's 128-proposal/beam-eight bounds are
upper allowances; this slice uses a deterministic single proposal per step.

`local_runtime.collect_label` repeats the prefix and suffix in a fresh public
worker. Only actual pre-action public observations become model inputs. Oracle
code, paths and private expert records remain controller-side. A snapshot mismatch
is `REPLAY_DIVERGED`, not an invitation to replace the learner's observations.
An admitted structural recovery is a replay-checked ABORT_DRAFT with unchanged
committed graph. It never becomes a positive semantic-success label.

`train_local` trains GIN/GCN/GraphSAGE/GAT/MLP through the same public structured
head interface, then freezes the model for actual learner rollouts. It requests
up to four labelled snapshots per task per aggregation round, prioritizing public
rejected/draft states. Unsuccessful semantic labelling may fall back to structural
recovery; both failures and successful admissions are retained. Two such rounds
follow initial teacher training. The joint loss sums probabilities of complete,
deduplicated alternative actions. The present expert emits singleton alternatives;
the loss API supports sets but no multi-plan expert is claimed.

The optimizer is supervised imitation with on-policy dataset aggregation, not
a reward-based policy-gradient algorithm. Finite nonzero gradients establish
that numerical training occurred, not that the semantic feedback is being used
effectively or that the policy generalizes.

This runner performs the fixed eight-task diagnostic directly. Its historical
`oneTaskGate` report field only records success on the first task in that run;
it is not a separate one-task training experiment. `eightTaskGate` uses the final
round, not the best interim checkpoint. No 64-task gate is executed by this runner.

## Runtime Boundaries

The public worker enables the new behavior only when loaded with the explicit
local contract and query budget. Earlier default session calls keep their existing
behavior. In the local mode, Java enforces the query cap, including rejected
over-budget requests, rather than relying only on a Python action mask.

Stable local retry suppression stores exact candidate source, site and revision
inside a fixed task/context/parser/theory session. Only concrete Alloy syntax/type
errors are cached. Other exceptions, resource failures and UNKNOWN outcomes are
not cached. Abort preserves the cache; successful edits refresh source/pointers.
Suppressed attempts consume a decision but do not call preparation again. The
public action mask removes an identical failed COMMIT while retaining abort.
No private exception strings or new target-derived diagnostics enter the packet.

The graph encoder now optionally consumes historical packets retained from actual
earlier public observations. Revision-qualified addresses resolve history pointers
to their original semantic rows, not to current nodes with reused numeric IDs.
Those addresses are edges, not learned identity features. Missing/misidentified
history fails closed. All encoded rows, including archives, count toward 8,192.
No new source/provenance/type information is fabricated to repair a missing view.

## Proof And Test Correspondence

The 42 general and 20 concrete `LocalRepair` proofs were freshly compiled before
runtime changes. Six additional `LocalRepairArchive` lemmas preceded history
transport. They prove model-level lookup separation, missing-history rejection,
distinct revision addresses, public-only projection and the combined budget bound.
The archive arithmetic theorem also uses Lean's standard `Classical.choice`,
alongside `propext` and `Quot.sound`; there are no proof placeholders or new axioms.
These facts do not prove the entire Java/Python implementation.

The final development preflight (`/tmp/acgn-local-preflight-20261004-v3`) ran:

- 15 new Java checks for stable retry, charged suppression, abort persistence,
  changed candidates, real final solving, query limits, private-target isolation,
  snapshot binding, COPY reuse, alpha termination and a non-root edit.
- 132 existing feedback-executor checks, 64 environment and 38 learning checks.
- 83 Python test executions, including fresh teacher/recovery replay, joint-loss
  deduplication and finite gradients, held-out rejection, snapshot mismatch, and
  a two-commit historical-pointer fixture.
- Fresh two-build local proofs and the six archive lemmas.
- Eight of eight fixed training tasks with independently replayed continuations.

This is finite executable correspondence evidence, not proof of every exception
path, parser behavior, certificate theorem or GPU numerical operation. Solver,
parser, JVM, Lean, PyTorch and CUDA retain their documented trusted roles.

## Development Incidents

The first compile found a local variable-name collision in the new cache code;
it was fixed before any runtime test or training result was admitted.

The next preflight admitted semantically valid but redundant teacher paths:
generated binder names differed from reference names, causing up to eight
reconstructions of the same already-correct quantified program. The expert now
compares explicit structural alpha keys and has an exact regression requiring
one construction. The final eight teachers total 94 decisions and 22 COPY uses.
The superseded preflights remain in `/tmp`; no model was trained on their labels.

An independent replay of two seed-17 MLP repeated-COMMIT episodes found the
existing `CANONICAL_OBSERVATION_UNSUPPORTED:NODE:GENERICRELDECL` limit. The model
wrapped an existing quantified predicate as an implication antecedent. Source
preparation reached the numeric canonical exporter, which declined the new local
declaration form. The original committed state remained intact. These refusals
are not syntax/type errors, so the deliberately narrow retry cache does not
memoize them. The episodes remain unsuccessful and count in the denominator;
no semantic result was falsely certified. This is a remaining representational
coverage/recovery issue, not evidence that every local rejection is suppressed.
The frozen study was not modified in response to these interim model results.

## Remaining Limits

This is still the existing bounded, parameterless-predicate source slice. Import,
CALL-table and certain local canonical-binder representations remain explicit
coverage limits. No full-corpus, held-out, Qwen or 500M model result follows from
this training-set diagnostic. No new numerical/refinement proof is claimed.
Expanded supervision, separately matched Q=2 comparisons, stronger local search
and additional model consumers remain separate, gated work.
