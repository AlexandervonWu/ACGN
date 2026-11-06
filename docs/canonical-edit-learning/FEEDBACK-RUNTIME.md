# Feedback Runtime Migration

Contract: [feedback-intent-path-v1](INTENT-PATH-SPECIFICATION.md).
This is an implementation work log, not a new empirical success claim.

## Proof Before Implementation

`formal/FeedbackSession.lean` proves eleven controller properties: initially
empty feedback; private-contract projection independence; query fuel consumption;
exact response append; fixed private contract; exhausted-query identity; rejected
attempts preserving source and feedback while consuming fuel; chronological prefix
retention; and equal public responses preserving public-state equality.
The controller model compiled before the runtime changes. Three further model
lemmas cover the empty-relation Boolean constants and source interval containment.
Four further lemmas cover public mask filtering and pre-action replay causality,
for eighteen controller/model lemmas in this file.
The subsequent declaration-group extension adds two prefix-scope lemmas and
one returned-signature membership lemma, bringing the file to twenty-one.
The printed dependencies are standard
Lean logical principles; there are no additional axioms, placeholders, or unsafe
proofs. This does not prove Alloy, SAT4J, Java, tensor conversion, or a learned
policy correct. Those remain explicit correspondence/test obligations.

## Shared Controller Boundary

The new session must not initialize the historical seeded reward bank. A
validation request consumes one decision and returns only witnesses from that
request's two directional solver checks. Earlier responses are retained in
chronological order, not fetched from a mutable bank. An initial observation
does not run a target query. The evaluator owns the fixed module and reference;
the public observation does not contain either, their hashes, rewards, target
distances, task names, private facts, or a module-wide declaration inventory.

Source transactions use a separate draft, deterministic source rendering,
revision-scoped occurrences, and parser/type/canonical preparation before atomic
commit. Invalid or stale decisions consume budget without changing committed
source. STOP performs validation rather than declaring success. Unsupported
source/type features are reported, not encoded as text escapes or `univ`.

The migration adds an opt-in parameterless-predicate task adapter with temporal
support. The historical static adapter and its rejection behavior are unchanged.
The new source tables cover every unary/binary Alloy temporal operator, including
postfix PRIME. Temporal children receive distinct phase IDs and distinct local
binder-import rows, with explicit links to their original declaration. Copying
across those contexts checks the actual enclosing declaration; it does not merge
the phase-local identities. New query feedback includes complete finite traces,
time-indexed tuples and the loop index. Explicit imports and CALL tables remain
unsupported and must stay visible in coverage.
Historical trainers and their results retain their historical interface; a new
runtime must pass information, representation, execution, learnability and
comparison gates before any trainer can be labelled contract-compliant.

## Training Order

Feedback-symbol choices are addressed only through the ordered namespace of
actually returned witnesses and their explicit type columns. The private module
resolver can realize those already-returned addresses; it may not enumerate extra
choices. Before any response, that namespace and action head are empty. A source
commit rechecks the resulting expression in the unchanged task context.

1. Shared executor, causal observations, replay and finite gates.
2. Small GNN learnability checks on 1, 8, then 64 real tasks.
3. GNN comparisons, then Qwen adaptation, then the roughly 500M scratch model.

The user's explicit choice is to finish the new executor and gates first, not
rerun information-clean variants of the historical action menus. No historical
checkpoint or historical success count can stand in for a new gate result.

## Action Mask And Replay Contract

The action interface publishes a single next-hole record and factorized numeric
choice tables. Hole sorts distinguish Boolean, relational and integer operands;
exact relational column inference and overload resolution still happen at commit.
Masks remove structurally unavailable controls, out-of-scope pointers, unsupported
constructors and clear Boolean/relational sort mismatches. They do not promise
that every allowed cross-product of choices parses, nor query the private target.
The authoritative acceptance check is still reparsing and typed preparation.

Replay accepts bounded sequences of the same public semantic decisions, records
each observation **before** its decision, checks each consumed revision/turn,
and performs the same explicit final solver validation. The path is an offline
label channel, never part of a policy observation. Replaying a hand-written or
searched teacher path is not a free-running learned repair. The new four Lean
lemmas cover public mask filtering/private independence and pre-action key
causality; actual Java/Python correspondence is a bounded regression obligation.

## Implemented Surface And Limits

`FeedbackRepairSession` supports BEGIN/COPY/SYMBOL/VARIABLE/DRAFT_VARIABLE,
CONSTANT/OPERATOR/QUANTIFIER/DECLARATION/FEEDBACK_SYMBOL, COMMIT/DELETE,
ABORT_DRAFT/VALIDATE/STOP/ABSTAIN.
Temporal, binding and matrix insert/delete/update transactions have bounded source
tests. Quantifier drafts introduce ordered declaration groups with their uses
atomically, including dependent domains and joint ONE/LONE. Matrix drafts
can build nested Boolean/relational expressions; they are not the old four-choice
replacement menu. Static literals 0-4 and relational/Boolean constants are explicit
choices, while existing source literals can be copied. All commits reparse and
prepare through the unchanged canonicalizer.

The source tables contain exact integer fields, shared type products, signatures
and referenced fields, declaration scopes, phase imports and source occurrences.
Names and character offsets remain private. There is no hashing into embedding
buckets, clipping, textual type serialization, or fallback of unknown types to
`univ`. Each public symbol originates in the predicate/type closure or an actually
returned world. Feedback-only declarations are available through a separate
FEEDBACK_SYMBOL head after actual responses, with their world origin retained.

This is **partial runtime migration**, not completion of the new contract:

- Bounded certified canonical projection tables and graph-address/alpha/phase
  transport tests are implemented. Local canonical declarations and complete
  source/type/world round trips remain open.
- Public factorized masks and coarse Boolean/relational/integer hole heads are
  implemented. Exact dependent draft-type inference remains a commit-time check.
- CALL and some source constructors remain unsupported. Normal ARROW multiplicity
  variants retain their multiplicities; ISSEQ remains unsupported.
- A separate offline teacher compiler rebuilds supported oracle expressions using
  semantic choices and already-visible source/returned-world pointers. Every admitted label path
  is replayed in a fresh public worker with causal observations and final checking.
  Missing source symbols, constructors and declaration shapes are reported, not
  filled from private inventory. These are bounded feasible paths, not optimal
  metric plans. A small graph adapter has now been trained: the 1-task gate passes,
  the 8-task gate fails, and the 64-task gate was not run. Larger adapters remain
  open; see `FEEDBACK-TRAINING-REPORT.md` for measurements and limitations.
- Final validation is bounded Alloy checking, not independent certificate replay
  and not a universal proof of the Java implementation.

The readiness runner intentionally exits 2 while these gates remain open. This
must not be renamed to a successful training run or used to bypass the gates.

## Reproduction

Run from the repository root, using a fresh external output directory:

```bash
python3 -m experiments.feedback_repair.run_gates /tmp/acgn-feedback-preflight-new
```

It compiles all three Lean models and Java, runs the new and historical regressions,
then checks the frozen 104-task pilot with a separate killable JVM per task and
a 30-second request deadline. It also attempts offline teachers for the frozen
training split only, followed by independent replay in a fresh worker. Validation
and evaluation tasks never become training labels. It never invokes a trainer. Input hashes are frozen
before compilation and checked again afterward. Reports, command logs, coverage
and output hashes are written to the output directory. A source/query coverage
success is not a learned repair. No full-corpus or GPU experiment is performed.
The separate `experiments.feedback_repair.train_gates` runner consumes a verified
preflight directory and performs the bounded GPU training/evaluation sequence.
It stops at the first failed gate; neither runner invokes historical trainers.

## Source Range Correspondence

Multi-domain drafts retain one Alloy quantifier and an ordered list of declaration
groups. DECLARATION may extend that list only at the unfilled body hole. Each
domain sees preceding groups, while the body sees all groups. ONE/LONE are never
silently replaced by nested quantifiers. Built-in signature memberships are
included in returned worlds, so an integer/universe expression has its concrete
world interpretation available. These additions have model-level scope/membership
lemmas and require source-to-solver regressions; they do not prove the parser.

Alloy parser spans are not necessarily balanced source expressions: the span of
`all x: S | (((some S)))` can end at the final `S`. The executor must retain the
parser's core interval and extend it to include matching delimiters already
present in the same predicate body. Quoted strings and comments must not count
as delimiters. `enclosing_span_keeps_core` proves the interval-containment step;
the tokenizer/parser correspondence is checked on bounded source regressions,
not claimed as a universal Lean proof. Source preparation and final behavioral
validation remain mandatory. Parser NOOP wrappers are transparent to the source
table, not extra editable semantic operations.

The use-site positions carried by those wrappers must still be retained for
signatures, fields and variables. Their resolved AST objects can point to the
declaration rather than the occurrence. The PRIME insertion regression caught
this distinction. Keeping the use-site position prevents a leaf edit from being
misclassified as outside the predicate, while the table omits the NOOP operator.

## Incident Log

- FR01: the old trainers exposed prefetched target-labelled banks, full-module
  facts/schema, score channels or whole-graph serialization. They remain
  historical implementations and are not rerun as compliant baselines.
- FR02: the first new renderer emitted bare `true`/`false`, which this Alloy parser
  does not accept. Explicit Boolean decisions now render `no none`/`some none`.
- FR03: a transparent root NOOP obscured a matrix deletion site. Transparent
  wrappers are omitted from the new source table.
- FR04: a quantified child's parser span omitted closing parentheses, so temporal
  deletion produced malformed source. Matched-delimiter completion repairs the
  span without dropping its core, with comment-aware regression coverage.
- FR05: removing NOOP wrappers discarded signature use-site positions. Retaining
  those private positions repairs PRIME insertion and leaf addressing.
- FR06: source revision alone did not bind an action to the current draft hole.
  An additional turn stamp rejects stale draft decisions while consuming fuel.
- FR07: initial preflight manifests hashed inputs after compilation. The runner
  now freezes inputs before building and rejects a changed input afterward;
  exploratory runs before that fix are not the final reproducibility evidence.
- FR08: completed drafts initially omitted their disjointness flag and first new
  binder address from the draft table. Both are now explicit integer columns.
- FR09: returned worlds initially omitted built-in signature memberships, losing
  the concrete integer/universe interpretation. The query exporter now includes
  those actual memberships. A 4-bit Int regression checks all sixteen values.
- FR10: initial teacher compilation exposed a single-domain action ceiling. The
  DECLARATION decision adds a domain group within the same quantifier; joint ONE
  and dependent-domain regressions check that no nested-quantifier shortcut occurs.
- FR11: returned-only symbols were observable but not actionable. FEEDBACK_SYMBOL
  now uses only addresses in the actual returned namespace. Its initial mask is
  empty, and a new-symbol repair is tested through fresh-worker causal replay.

## Learning Extension Incidents

- FL01: the repair view retained exact types only inside display/comparison strings.
  Read-only structured type/domain/phase metadata now travels through projection
  copies; metric comparisons and authority checks are unchanged. The learner does
  not reconstruct types by parsing those diagnostic strings.
- FL02: numeric addresses would become identity features if raw tables were fed
  directly to linear layers. The new adapter turns pointers into incidence edges
  and uses explicit group nodes for products, tuples and disjointness classes.
  All bits of literal integers are retained; no hash/clamp/float-ID fallback exists.
- FL03: disjointness class zero means no disjointness, not a shared disjoint
  group. It stays a scalar zero; only positive classes create group incidence.
- FL04: a draft slot number can be reused after aborting a transaction at the
  same source revision. Historical slot groups now also include transaction
  identity. Source snapshots older than initial/current remain unsupported by
  the learner and are explicitly reported rather than redirected to current nodes.
- FL05: joint deletion pointers have distinct site/child roles. Candidate scoring
  preserves pointer position instead of taking an unordered mean.
- FL06: `some (S+T+U)` normalizes beyond its relational union. The ACI regression
  uses a retained AND container and checks its three actual certified operands.

See `FEEDBACK-LEARNING.md` for the proof/model boundary. These additions do not
claim complete local canonical binder export or universal Java/Python refinement.
