# Section 3 Repair: Bounded Assurance Plan

## Assurance Boundary

This plan replaces the non-terminating exhaustive-review protocol with a
finite, requirements-based verification envelope inspired by the software
verification objectives normally associated with DO-178C Level A. The
repository is not an airborne system, no certification authority is involved,
and this document does not claim DO-178C compliance or certification.

The assurance claim is limited to the repaired Section 3 implementation:

- CALL occurrence extraction and semantic identity;
- variadic-port structure and independently authorized algebraic laws;
- dependent typed JOIN and ARROW chains;
- exact Alloy types, semantic profiles, and certificate endpoints;
- collision ownership and rebuild;
- guarded Alloy source rewrites;
- deterministic canonicalization and binder occurrences;
- the certified quotient repair metric; and
- producer, wire, and standalone-verifier paths that carry those results.

Historical empirical trees, the paper, release assets, and protected
reproducibility programs remain outside the modification scope. They may be
used only as explicitly identified historical inputs.

## Finite Verification Objectives

The gate closes when every objective below has deterministic evidence tied to
one frozen artifact manifest.

The generated [claim and proof-process catalog](../section3-assurance-claims.md)
lists every currently scoped requirement and its exact Lean, implementation,
test, and status mapping. Its source of truth is the content-sensitive TSV
matrix described in `traceability-schema.md`.

| ID | Objective | Required evidence |
| --- | --- | --- |
| A-01 | Every scoped high-level requirement has one or more atomic low-level requirements. | Machine-checked traceability matrix with zero unmapped scoped requirements. |
| A-02 | Every low-level requirement traces to implementing code or an explicit unsupported/fail-closed boundary. | Path and symbol mapping checked against the frozen manifest. |
| A-03 | Every implemented low-level requirement has normal, boundary, and robustness tests with an explicit expected result. | Deterministic test manifest and result hashes. |
| A-04 | Every scoped atomic claim has an independently stated Lean obligation. | Pinned Lean command, source hash, explicit assumptions, no admissions, and deterministic success for every requirement ID. |
| A-05 | Java refines the tested formal contract at each parser, IR, adapter, graph, metric, serializer, and verifier boundary in scope. | Independent boundary and mutation tests; formal models are not accepted as Java refinement by themselves. |
| A-06 | Scoped Java decision logic attains statement and decision coverage, plus MC/DC for decisions that admit, reject, normalize, union, flatten, or certify. | Coverage report tied to exact class bytes and test manifest; justified unreachable/deactivated code is reviewed independently. |
| A-07 | Data and control coupling across scoped boundaries is exercised. | Producer-to-verifier positive paths and one-field-at-a-time negative paths, including stale, omitted, duplicated, and cross-context evidence. |
| A-08 | Resource behavior is bounded for the declared test domain. | Explicit time, heap, input-size, and combinatorial limits; timeout or exhaustion is a failing result, not a retry loop. |
| A-09 | Outputs are deterministic for byte-identical inputs and configuration. | At least two fresh-process executions with byte/hash comparison. |
| A-10 | Configuration and provenance identify all source, dependency, toolchain, options, and generated-evidence bytes used by the gate. | Canonical manifest and independent hash verification. |
| A-11 | Every observed discrepancy has a durable problem report and disposition. | Fault register with `OPEN`, `FIXED-AWAITING-RETEST`, `CLOSED`, or `OUT-OF-SCOPE` state. |
| A-12 | Verification is independently repeated after the implementation is frozen. | One independent phase review per phase and one independent integrated review, all bound to the same manifest digest. |

## Requirements-Based Test Classes

Each low-level requirement receives a finite test set drawn from these
classes. A test may cover several requirements only when the traceability
record names the exact assertion for each requirement.

1. Nominal: one positive example for every admitted constructor, law, profile,
   certificate, and metric operation.
2. Boundary: minimum and maximum admitted arity, empty/nonempty boundary,
   unary/binary relation boundary, minimum/maximum supported bitwidth, and
   first/last binder occurrence.
3. Robustness: null, missing, malformed, duplicate, stale, foreign, reordered,
   cross-profile, cross-type, cross-path, cross-arity, and unsupported-version
   inputs.
4. Semantic negative: the smallest known counterexample to each deliberately
   unlicensed law, including unary-interior JOIN reassociation and
   overflow-sensitive integer reassociation.
5. Integration: source to MASG to IR to certified graph to repair projection
   to serialization to independent replay.
6. Determinism/resource: repeated fresh-process output, explicit timeout,
   bounded heap, and bounded orbit/collision inputs.

Random or corpus testing is supplemental. It cannot replace a traced
requirements test and it is always executed with a fixed seed and bound.

## Structural Coverage Policy

Coverage is measured only for the scoped implementation and its newly added
verification code. The target is:

- 100% statement coverage;
- 100% decision/branch coverage; and
- MC/DC for each multi-condition decision that changes semantic admission,
  rejection, normalization, flattening, union, canonical selection,
  serialization acceptance, or repair-distance zero/nonzero behavior.

Coverage alone proves neither semantic correctness nor test adequacy. Any
uncovered code requires one of: a new requirements-based test, removal as dead
code, or a reviewed deactivation/unreachability justification. Generated
boilerplate, defensive JVM-impossible branches, and diagnostic-only rendering
may be excluded only by an explicit row in the coverage disposition ledger.

## Formal Evidence Policy

Lean is required for every scoped atomic claim. Z3 may be used as a
supplemental counterexample finder, but it does not replace the Lean
obligation. Each requirement ID maps to one or more named Lean declarations
whose statement captures that exact claim and whose assumptions are recorded
in the traceability matrix. The proof must not use `sorry`, `admit`, a
claim-specific `axiom`, `unsafe`, or producer certificates imported as facts.

Different claim classes use different Lean-to-artifact connections:

- semantic and algebraic claims are proved directly from the stated semantic
  model;
- finite policy claims are proved over an explicit closed enumeration;
- Java, wire, and provenance claims use a Lean contract plus bounded
  conformance and mutation tests against the compiled implementation;
- empirical claims use a Lean proof of the aggregation and compatibility rules
  plus independent recomputation from manifest-bound input bytes.

A compiled abstract theorem alone does not establish Java refinement or an
empirical value. Conversely, a green Java test does not discharge the Lean
obligation. Both sides are required where a claim crosses that boundary.

The formal boundary does not claim parser correctness, solver correctness,
SHA-256 injectivity, JVM correctness, or tool qualification. Those are stated
environmental assumptions or tested interfaces, as appropriate.

## Independent Review

The previous five-review-per-phase and twelve-review-whole-artifact rule is
retired because its universal search obligation had no finite completion
criterion. Under this plan, independence is achieved by one fresh reviewer for
each phase and one fresh integrated reviewer. A reviewer must reproduce the
phase's complete finite test and traceability manifest, inspect every coverage
disposition, and attempt the listed robustness mutations. Reviewers may add a
bounded counterexample, but cannot expand the gate with an unbounded phrase
such as "every possible claim".

Any source, requirement, test, formal proof, or evidence change invalidates the
affected review and the integrated review. A finding blocks closure until it is
fixed and the finite gate is rerun on a new manifest.

## Termination Rule

The assurance run terminates with exactly one of these outcomes:

- `PASS`: A-01 through A-12 are satisfied, all scoped requirements pass, all
  required coverage is attained or dispositioned, and no scoped problem report
  remains open.
- `FAIL`: a deterministic requirement, formal, test, coverage, provenance,
  determinism, resource, or independent-review objective fails.
- `INCOMPLETE`: an external prerequisite or approved tool is unavailable, or
  the declared resource bound expires before the gate completes.

`INCOMPLETE` is not retried indefinitely and is never reported as `PASS`.

## Current State

`INCOMPLETE`. The requirement-to-Lean matrix, structural-coverage harness,
exact source-command semantic profile, and independent frozen-snapshot reviews
are not yet complete. Existing Lean files and focused Java suites are reusable
evidence inputs, but none is grandfathered into a passing result.
