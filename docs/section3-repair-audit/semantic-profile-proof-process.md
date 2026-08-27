# Source-Command Semantic Profile Proof Process

## Claim Boundary

This evidence addresses the extractor and comparison portion of requirement
`P3-16`. It does not claim that every production caller already supplies a
source-bound profile, nor that a standalone verifier can reconstruct the
selected Alloy command from raw source bytes. The overall requirement remains
`IMPLEMENTATION-PARTIAL`.

## Claim

Given one parsed Alloy module, exactly one command identity owned by that
module, and one valid `A4Options` value, the extractor constructs a
deterministic semantic profile. Changing bitwidth, overflow behavior, temporal
bounds, command scopes, represented execution options, or semantic
implementation versions changes that profile. Missing, ambiguous, foreign,
and invalid selections reject. Full and compact prepared observations reject
cross-profile comparison.

## Construction

`AlloySemanticProfileFactory` first proves by object identity that the command
belongs to the parsed module and that every scoped signature belongs to its
reachable signature set. It then reads the selected command's check/run mode,
overall scope, effective bitwidth, maximum sequence bound, minimum and maximum
temporal prefix, maximum string scope, expected result, per-signature scopes,
and additional exact scopes. It also records the bounded execution options,
including `noOverflow` and temporal unrolling. Only the parser's omitted-width
marker `-1` defaults to 4; explicit width 0 is preserved, and widths above 30
reject. A null solver rejects as an invalid option state. Scope records are sorted by
their complete structural keys before they become children of the context
key, so parser iteration order is not an accidental identity component.

The complete context is retained as a length-prefixed `StructuralKey`; it is
not replaced by a digest-only token. `SemanticProfile` adds the overflow mode
and current rewrite/signature versions to its own structural key and computes
the diagnostic SHA-256 fingerprint from that complete encoding. The method
that attaches parsed-source authority is package-private, and a caller-created
profile with identical text remains unauthorized.

## Formal Evidence

[`Phase3SemanticProfile.lean`](formal/Phase3SemanticProfile.lean) defines a
source command, exact profile derivation, unique-selection function, compact
observation, and cross-profile comparator. Lean 4.33.0 proves:

- width 4 and width 5 profiles differ;
- omitted width defaults to 4 while explicit width 0 is preserved;
- modular and overflow-forbidding profiles differ;
- temporal bounds `(2,3)` and `(2,5)` differ;
- distinct scope contexts differ;
- distinct execution options differ;
- distinct rewrite and signature versions differ;
- zero and multiple command selections reject; and
- a foreign command rejects while a uniquely parser-owned command derives;
- caller-asserted profile text does not acquire parsed-source authority; and
- compaction preserves the profile while cross-profile comparison rejects.

The file contains no `sorry`, `admit`, claim-specific `axiom`, or `unsafe`
declaration. This abstract proof does not by itself prove Java refinement.

## Executable Evidence

`SemanticProfileSourceCommandTest` exercises actual parser-owned commands. Its
31 checks cover deterministic reconstruction, fingerprint stability,
source-bound authority, omitted/preserved-zero/supported/excessive widths, modular
overflow, implementation versions, width/overflow/temporal/unroll/scope
separation, missing/ambiguous/foreign/null selection, null solver, caller-text
impersonation, and separation from the fixed compatibility profile.

`CanonicalAlloyPipelineTest` separately exercises full and compact
cross-profile rejection and verifies that compaction preserves the selected
profile.

## Remaining Falsification Obligations

- Make source-bound extraction mandatory at every production canonicalization
  entry point without changing the protected historical runners in this pass.
- Prove that every cache key includes the complete semantic profile.
- Define and justify the exact semantic subset of every `A4Options` field.
- Carry and independently replay the selected command/options context through
  certificate export.
- Mutate each context field independently at the standalone verifier boundary.
- Obtain structural coverage and a fresh immutable-snapshot independent review.

Until those obligations close, a fixed compatibility profile remains an
explicitly documented escape hatch and `P3-16` is `REFUTED`, not merely
coverage-incomplete.

## Independent Bounded Review

The first fresh review is retained at
`/tmp/acgn-p3-16-review/report.md`, SHA-256
`d8949a6320ef75b44c261797f5124093d862a62c62f966e85a404e442f1c44bf`.
It used 25 shell invocations and returned `REFUTED`. Its explicit-width-zero
and caller-authority counterexamples caused the repairs above. It also found
the still-open production-default, option-partition, cache, and standalone
replay failures, so the review remains blocking after those two local repairs.
