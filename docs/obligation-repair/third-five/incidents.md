# Third-Five Integration Record

This record distinguishes candidate-development failures from final frozen
verification. It does not replace the machine-generated closure report.

## Lean Scope Inventory

The inherited scanner opened namespaces and sections but not `mutual`
blocks. CALL's mutually recursive declarations therefore produced an
`unmatched Lean scope end` rejection even though Lean accepted the proofs.
The new runner's private, counted adaptation recognizes an unnamed mutual
scope. A regression reproduces the old failure, preserves fully qualified
theorem names, and rejects an omitted audit. The v2.13 runner is unchanged.

## Isolated Compatibility Suites

Running both existing next-five test modules through one unittest discovery
process produced 12 failures and one error: the real replay plugin, imported
by discovery, was absent from the lifecycle fixture's deliberately minimal
input manifest. The imported-verifier check correctly blocked that fixture.
The registered isolated script entry points pass separately: 33 driver tests
and seven encoder tests. No import check or prior package was weakened.
Reproduction uses those separate processes, as the registered runner does.

## Registry Schema Stage

The initial registry grid treated every rejection as registry execution.
`SetPortSchema` rejects exact arity two before registry admission because its
arity policy must be positive-downward-closed. The observation schema now
separates `SCHEMA_REJECTED` from `REGISTRY_REJECTED`: 792 grid requests reject
at construction, 8,656 reject at the registry, and 68 issue. Unexpected
exceptions propagate. This repairs evidence attribution, not production
behavior or the admitted registry.

## Independent Harness Review H1-H3

H1 found that exit 1 did not establish the intended rejection reason: real
JVM loader or Lean import errors could pass a simulated complete lifecycle.
The first fix classified these errors but still accepted an expected error
followed by a real Lean panic or unrelated compiler error. The final contract
checks the complete transcript, keeps command/report status consistent, and
tests the actual Lean panic path. This is a verification-tool repair, not a
production certificate change. Original findings and reproductions remain in
[the review](review-harness.md), including subsequent targeted rechecks.

H2 exposed two private theorems omitted by the inherited public-only scanner
in the imported PhaseA2 module. All 132 dependency theorems now receive audits;
the compiled source retains its private declarations and the actual resolved
private names must match Lean's output. The source file is unchanged.

H3 showed that recording JDK 21 did not reject a run declaring JDK 17 trust.
The new entry point validates both JVM/compiler major versions before tests;
wrong or unparseable versions block. `--release 17` is not used as a substitute
for the runtime version check.

The first integrated candidate, `/tmp/acgn-third-five-final1`, was interrupted
after the remaining H1 cases were reported. Its unedited report, input manifest,
and logs are retained as interrupted candidate evidence, never a closure PASS.
All subsequent frozen verification starts at a new root and run directory.

`/tmp/acgn-third-five-final2` then blocked before either build: a synthetic
positive unit transcript still included a placeholder `x` row, which the new
complete-transcript grammar correctly rejected. The fixture now contains only
the registered exception line. All 33 driver tests pass; the full rerun uses
`/tmp/acgn-third-five-final3`. Both earlier reports remain unedited.

## Matrix Comment Token

The diagnostic reporter scans raw Lean text and interpreted the word `admit`
inside a comment as a prohibited proof token, yielding 101 ready/119 diagnostics.
The comment now says `authorize`; declarations and proof terms are unchanged.
The production assessment's conservative forbidden-token check was retained.
