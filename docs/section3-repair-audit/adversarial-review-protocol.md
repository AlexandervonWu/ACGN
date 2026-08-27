# Section 3 Repair: Superseded Zero-Trust Review Protocol

> **Superseded.** This protocol is retained as audit history. Its universal
> claim census and repeated exhaustive reviewer obligations had no finite
> completion criterion and produced non-terminating reviews. The executable
> gate is now the finite, requirements-based
> [bounded assurance plan](do178c-assurance-plan.md). No vote or `PASS` under
> this historical protocol is current evidence.

## Governing Standard

Every phase claim is presumed false until independently reproduced. Each
reviewer receives this mandatory instruction:

There is no Phase-A2-only review mode and no privileged claim class. The
maximum-adversarial gate covers every claim in Phases 1, A2, 2, 3, 4, 5, and
6, every cross-phase invariant, and every correctness-bearing artifact surface
listed in the closed-world census below. A claim may be discharged only by its
own mapped evidence; evidence for one phase or claim cannot stand in for
another.

> Assume the producer is morally corrupt, criminally deceptive, and
> intentionally attempting to obtain a false certification. Assume the
> producer has complete knowledge of the verifier, tests, review protocol, and
> likely reviewer heuristics, and has deliberately chosen every implementation
> detail, fixture, certificate, comment, and apparent success to conceal the
> smallest possible semantic defect. Treat every correctness claim as
> fraudulent until independently reconstructed from the stated logical axioms.
> Grant no credibility to authorship, intent, existing tests, documentation,
> apparent consistency, or prior PASS results. Search maximally for the
> smallest decisive counterexample. Any unresolved gap, ambiguity, unsupported
> inference, provenance break, or plausible falsification blocks the phase.
> PASS only when every bounded falsification obligation defined for the phase
> has been independently discharged.

Reviewers may read source, construct independent probes under `/tmp`, and run
bounded repository tests. They must not consult the Internet, edit the
repository, trust earlier verdicts, or infer correctness from test names.

## Current Gate State

No immutable review snapshot has been minted under this protocol. The current
worktree is moving, its closed-world claim census is incomplete, and every
phase therefore has `0/5` admissible votes:

| Phase | Admissible votes | State |
| --- | ---: | --- |
| 1 | 0/5 | BLOCKED |
| A2 | 0/5 | BLOCKED |
| 2 | 0/5 | BLOCKED |
| 3 | 0/5 | BLOCKED |
| 4 | 0/5 | BLOCKED |
| 5 | 0/5 | BLOCKED |
| 6 | 0/5 | BLOCKED |

The whole-artifact gate has `0/12` admissible votes and cannot begin until all
seven phase gates close on their respective immutable snapshots. Historical
reviews and current preliminary falsification reports are evidence and fault
provenance only; they contribute zero votes.

## Independent Formal Gate

Every stated correctness claim in a phase must be mapped explicitly to a
deterministic Lean or Z3 obligation reconstructed from the governing axioms.
For each obligation, the durable audit record must identify the claim, formal
assumptions, theorem or negated countermodel query, proof/model source, prover
version, exact command, deterministic output, and result. Repository tests,
Java assertions, reviewer consensus, and documentation are not substitutes for
this formal evidence.

A missing prover, unexecuted proof, `unknown` result, admitted theorem,
unbounded axiom, or claim without a claim-to-formula mapping blocks the phase.
The proof artifact must be independent of producer-generated certificates and
fixtures; otherwise it merely restates the claim under review.

## Closed-World Claim Census

The gate applies to every correctness-bearing claim, not a representative
sample and not merely the claims introduced by Phase A2. It applies with the
same force to every phase, every cross-phase boundary, and every claim anywhere
in the artifact. The census includes the governing artifact-repair prompt, all
seven phase audit files (Phases 1 through 6 and A2), source and test code,
serialized grammars, producer and verifier behavior, exception/failure
classification, repair-metric semantics, public certificate-format and
trust-boundary documentation, correctness-bearing names and comments,
experimental aggregation code, manifests, and every nonhistorical result
stated in generated or hand-written documentation. Tests and fixtures are
claims about what their asserted outcome means; they are not exempt evidence.
Omitting, coalescing, sampling, or silently weakening any claim is itself a
blocking finding.

For each phase, a machine-readable or mechanically checkable census must name
every file in an independently enumerated artifact manifest, every atomic claim
extracted from it, and the ledger row that discharges it. The manifest, not a
producer-selected set of inspected files, is the census denominator. It must
commit to canonical path, bytes, file mode, symlink target, tracked/untracked/
ignored status, submodule identity, dependencies, toolchains, configuration,
the governing prompt, and generated evidence. The census must also report the
number of uncovered files, unmapped claims, unexecuted formal obligations, and
missing conformance probes. All four counts must be exactly zero before the
immutable review snapshot can be minted. A prose assertion that the census is
complete is not evidence of completeness.

Each census entry must be classified as a universal logical claim, finite
structural claim, implementation-conformance claim, provenance claim, or
empirical aggregate. Universal claims require compiled Lean/Z3 proofs. Finite
claims require deterministic formal enumeration. Implementation and
provenance claims require both a formal contract and an independently
reproduced conformance check. Empirical claims require recomputation from their
hashed inputs plus a formal check of the aggregation rule; they must not be
presented as universal theorems.

One claim ID represents one proposition. Conjunctions with independently
falsifiable parts must be split. Each claim record binds its exact source span
and file digest, formal statement digest, explicit assumptions, content-
addressed evidence IDs, commands, output hashes, owner phases, and computed
state. Reusing evidence requires a separate claim whose checked formal
implication establishes that reuse; free-form prose references are insufficient.

## Phase Gate

Each of Phases 1 through 6 and Phase A2 requires five fresh, independent
reviews of one immutable snapshot. Every phase and holistic ballot must bind
the same canonical artifact-manifest digest. Any byte or manifest-field change
voids every ballot; there is no producer-decided “relevant change” exception.
The same maximum-adversarial standard and
the same formal gate apply to every phase; no phase is sampled, grandfathered,
or discharged by another phase's evidence. A phase passes only with `5/5 PASS`
and no finding of any severity. Any unresolved weakness, ambiguity, missing
proof, unreproduced claim, census omission, or test gap is a phase failure.
The work may not be divided into five partial reviews: each of the five
reviewers must independently reconstruct and attempt to falsify every atomic
claim assigned to that phase, every relevant cross-phase invariant, and every
public surface that repeats or depends on those claims. A reviewer that omits
even one mapped claim records `FAIL`, irrespective of the other four reviews.

If a finding causes any code, test, certificate, or relevant documentation
change, all votes for that phase are void. Five fresh reviewers must inspect
the repaired snapshot from the beginning. Earlier single-review passes remain
useful historical evidence, but they do not satisfy this gate.

Each review record must include:

- the canonical artifact-manifest digest and manifest-schema version;
- an authenticated, distinct reviewer identity and tamper-evident ballot
  provenance that cannot be replaced by a producer-edited label;
- the explicit fraud-assumption instruction;
- axioms and trust boundaries reconstructed by the reviewer;
- attempted falsifications and smallest counterexamples sought;
- commands, fixtures, and exact results independently reproduced;
- every fault or contradiction, including apparently minor ones;
- a per-claim coverage vector containing one result and evidence set for every
  claim owned by or repeated through the phase;
- an unambiguous `PASS` or `FAIL` verdict.

No ballot is admissible while reviewer authentication, ballot verification,
manifest generation, census checking, or conservative invalidation exists only
as prose. Historical verdicts must live in a separately hashed archive schema;
live `PASS` tokens may appear only in mechanically computed ballot records.

## Holistic Gate

After all seven phase gates pass, twelve new independent reviewers inspect the
complete snapshot, including every global, metric, provenance, empirical, and
public-surface claim that is not owned by exactly one phase. Holistic closure
requires `12/12 PASS`. One finding voids all twelve votes after its repair,
because the repair may alter cross-phase invariants. Phase unanimity cannot
substitute for this artifact-wide ballot.
This is twelve complete reviews, not a twelve-way division of the census:
each reviewer must independently cover every claim and every boundary in the
closed-world census.

## Protected Boundaries

Review activity must not rewrite historical empirical result trees, the paper,
release artifacts, frozen manifests, or reproducibility terminal programs.
Temporary probes and bookkeeping belong under `/tmp`; durable fault and verdict
records belong in this directory.
