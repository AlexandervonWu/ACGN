# Source-Backed 508M Pilot

This protocol extends the hardware study with a finite, one-step source-edit
experiment. It does not claim a full repair search engine or independent
certificate replay. The existing Java parser, canonical repair projection,
metric and two-direction Alloy solver remain authoritative for their respective
roles. No equality admission or canonicalization rule is changed.

## Frozen Experiment Contract

Use the static relational pilot's four replacement templates. The 96-file v1
preflight admitted only two records, so corpus input v2 adds five read-only
operators at IDs 104-108 (IMPLIES, IFF, CLOSURE, RCLOSURE, TRANSPOSE), for 102
assigned IDs out of 128. These are observations, not new edit templates or
rewrite rules. Source binder domains are retained as graphs rather than required
to be primitive syntax; canonical binding types must still resolve to signatures
and cardinality ONE. User-schema relation arities up to three and up to 16
user-domain atoms per world are representable. Token length remains capped at
2,048, so no oversized observation is silently shortened. The older v2 hardware
codec is unchanged; the new corpus codec is explicitly versioned separately.
Inputs contain the complete bounded repair-view graph and its
certified alternatives, source occurrence links, primitive type/binder metadata,
schema and concrete labelled instance tuples. This is the certificate-derived
repair projection, not a dump of the entire underlying proof-heavy e-graph.
Retain source/provenance sidecars. Never place oracle syntax, target distances,
candidate solver verdicts or teacher labels in the model input. Compact symbol
IDs are local schema coordinates with explicit maps, not source-name hashes.
Source-name invariance of arbitrary schema declarations is not asserted.

Each menu is the complete admitted subset of the original menu; reject upstream
truncation, oversized packets and unknown semantic operators instead of clipping
or aliasing. Unknown features remain explicit exclusions. Evaluate all menu
edits by reparsing and the established canonical metric. Training labels are the
set of actions attaining minimum remaining distance to the paired oracle;
ties are retained. These are one-step teacher targets, not shortest repair
traces or proof that a distance-minimizing edit is semantically successful.

Split by question group, not individual file, using the existing deterministic
corpus splitter. Deduplicate AST pairs per question. Never select an example
because one of its edits repairs it. Record attempts, exclusions and failures.
Hold out the test labels while training and selecting checkpoints. Concrete
counterexamples may carry oracle evaluations, but not oracle bodies.

Train a randomly initialized 508,313,088-parameter model with BF16 compute,
FP32 parameters/gradients, Adafactor and effective batch 128 via accumulation.
Keep the 128-ID alphabet. Select checkpoints by validation repair success;
use validation target loss only to break ties. Bound epochs and keep failed
trials. Smaller final training batches use their actual sample count.

Numbers 0-15 use one digit token; larger references use an END escape followed
by the existing four digits. Two additional Lean theorems establish round trip
and injectivity, with exhaustive 16-bit Python tests. This shortens common counts
without adding IDs or discarding structure. Packets are right-padded after QUERY;
the model gathers the last non-PAD query state. Causal attention makes that state
independent of the padding suffix. Action pointers follow the complete replacement
payload. A padding-invariance test checks the implementation; the numerical
attention kernel remains TCB.

Report held-out top-1 and budget-3 one-step repair success. Compare uniformly
random distinct menu choices with the same menu and attempt budget. A separate
counterexample-score ranking uses exhaustive candidate lookahead and is explicitly
not an equal-attempt-cost baseline. Also report the exhaustive one-step upper bound,
not as a deployable baseline. Every successful repair must have feasible context
and UNSAT for both extra and missing behavior at the declared scope. Timeouts,
unknown solver answers and failed transitions never count as success. These are
bounded Alloy results, not unbounded semantic equivalence or certificate replay.

## Proof And Trust

CorpusTraining.lean is written and compiled before implementation. Its eight
initial theorems cover group-consistent splitting, label redaction in a structured
record, retention of tied targets, the two-direction acceptance gate and finite
attempt budgets. They are model-level contracts, not a proof of the Java
exporter, Python parser, SHA grouping, floating-point learning or SAT solver.
Tests must exercise those implementation correspondences separately.
Three further theorems prove the five read-only codes fit, are injective and
are disjoint from the old token region. Existing HybridRepair.lean supplies accumulation, finite-menu and vocabulary
contracts. The full Java-to-Lean refinement remains open.

PyTorch/CUDA/Adafactor remain explicit TCB. Real-data performance must be reported
even if it fails to beat random or if scoped coverage is small. The original
corpus and publication result directories must remain unchanged.
