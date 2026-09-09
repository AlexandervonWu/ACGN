# v2.17 Integration Findings

## FV-M01: Unicode Ordering In The Draft Models

The initial law-record model used Lean's native string ordering for the
registry table. Java's `String.compareTo` orders UTF-16 code units; native
Lean string comparison has a different order for some supplementary
characters. A wire-table model must likewise distinguish UTF-8 payload bytes
from UTF-16 identifier comparison. Using the two representations
interchangeably would overstate their correspondence.

Small witness: Java orders U+10000 before U+E000, while Lean's native
comparison orders U+10000 after U+E000. Both are well-formed strings at the
public certificate boundary. The Java execution and pinned Lean theorem
are retained under `evidence/reviews/unicode-order/`.

This finding affects the new verification models, not the existing Java
producer, verifier, canonicalizer or experimental metrics. The repair must
model Java's UTF-16 ordering explicitly, retain actual UTF-8 payloads for
codec reasoning, and cover the distinguishing case in the finite observed
replays. The corrected models passed both local clean builds and the
independent Unicode boundary probes.

## Verification Setup

The standalone Unicode probe initially selected the system-default Lean
4.33.1 because it ran outside the repository. It was repeated with explicit
`ELAN_TOOLCHAIN=leanprover/lean4:v4.33.0`, with the same result. Only the pinned
run is used as v2.17 evidence. The closure runner already selects and checks
the pinned version independently.

The independent harness review also retains an initial temporary-fixture
Lean input-root setup failure. Correcting that fixture's working directory
did not change a verifier or a target claim; its subsequent 93 boundary
checks passed. The review report and raw archive preserve both attempts.

## FV-M02: Missing Shared Regression Registration

The first combined Java smoke run rejected A2-12 because its new regression
was named by a DIRECT matrix row but not executed by the shared bounded
Java entry point. The independent area runner did execute it; that was not
sufficient for the existing repository-wide coverage gate.

All four new Java regression mains are now explicitly registered in
`scripts/run_bounded_ci_java_tests.sh`, in addition to their frozen closure
configuration. The original failed log is retained as
`bounded-java-missing-registration.log`. No coverage check was relaxed.
This correction changes test execution only, not an experimental runner or
production transition. The shared suite is rerun after registration.

## FV-M03: Negative-Control Diagnostic Contract

The first aggregate run, `fifth-five-v1-d28297d31179cca3`, stopped at
`build1-reject-records-records-acceptance`. Lean correctly proved the altered
record proposition false, then printed a multi-line axiom audit for the
failed named theorem. The unchanged strict classifier rejected that extra
format. The failed run and input manifest remain archived; it is BLOCKED,
not a partial success.

The records negative generator now emits an anonymous failing example and
no post-failure axiom audit. Positive named theorems still receive every
registered audit. The proposition, observation census and acceptance rule
are unchanged. The optional records live checker now calls the aggregate
`check_rejection` for both Lean and source controls. A regression preserves
rejection of unrelated errors and wrapped failed-theorem audits.

The initial records area check and independent review inspected the genuine
false-proposition marker and exit code, but did not execute that complete
classifier. Their earlier PASS does not establish the stronger aggregate
diagnostic contract. A separately retained review addendum and fresh aggregate
run check the corrected candidate; no previous VERIFIED status is inherited.

## Experimental Decision

No production behavior change was made. All 898 existing experimental JAR
classes match the fresh build byte-for-byte; the 50-entry-point Java suite
and separate certificate harness pass. The imported 5,808 empirical files,
protected result trees and historical manifests remain unchanged. No corpus
rerun is required or claimed for these assurance-only changes.

## FV-M04: Verifier-Level Label

Final documentation review caught `FULL-verifier` in the P3-04 matrix note.
The executed law-record census uses KERNEL verification, as its Java driver,
scope notes and independent review already state. The matrix note and its
generated Markdown were corrected to KERNEL. No observation, certificate
rule, proof or original claim statement changed. The completed local report
retains its prepackaging input root; exact-commit CI and archive verification
must produce fresh evidence for the corrected packaging root.
