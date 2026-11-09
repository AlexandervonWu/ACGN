# Bounded CI Compatibility Update

The November 9 checkpoint changed the certified-constructor entry path and
semantic version identifiers without updating all bounded CI correspondence
models. This update does not change production normalization or repair traces.

- The javac extractor checks the public three-argument delegate, its empty
  exposure map, and the four-argument implementation's exact expansion and
  certificate arguments. The selector proof retains its existing scope.
- Source pins were updated against compiler-resolved current sources. They are
  still exact rejection gates, not substitutes for execution or semantic proof.
- The standalone verifier and Lean registry model now use the producer's exact
  adapter v16-scoped-domains/signature v10 identifiers. Unknown, old and future
  identifiers remain rejected. Independent wire reconstruction is unchanged.
- Negative controls cover changed delegation, expansion profile, certificate
  source, singleton threshold, and unmodeled effects. Source controls must fail
  for their registered reason rather than an unrelated execution error.

## Local Pre-Push Evidence

The final selector validation passed two isolated builds, each with 2,356 input
rows, four expected empty-source rejections and 7,065 audited replay theorems.
The replay-encoder unit suite passed 148 tests.

An intermediate fourth-obligation run passed the positive Java fixtures and
Lean replays for 1,617 container, 8,741 chain and 272 profile observations. It was
stopped after review identified the stale registry model, before all controls
and the second build completed. It is INCOMPLETE, not a full-suite pass. The
final commit requires the complete GitHub workflow, including both clean builds
and all registered negative controls.

Terra's bounded review accepted the exact version alignment conditionally on
those tests, with no identified unsound acceptance in the tested wire scope.
This is not universal source-to-wire compatibility or public certification.

## Retained Open Obligation

A parsed-source probe derived from `LocalDomainSingletonTest` confirmed an
actual support-bearing `LOCAL-BIND-DOMAINS` operand and binder. Export then
stopped at `CertificateBundleWriter.requireSupportedSnapshot` because of
redundant shape coordinates. No bundle reached the independent verifier. That
export/correspondence obligation remains OPEN, not excluded or counted as a pass.

Detailed local evidence is retained in the workstation's external
`ACGN/supervision/ci-fix-20261109-42664873106/` directory. The corpus loop remains
paused. On resume, bind the actual source and verifier hashes afresh; do not
promote historical 4,072-attempt results across this verifier change.
