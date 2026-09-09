# Fourth-Five Implementation And Verification Record

## Starting Boundary

The v2.15 candidate starts at v2.14 commit
`91825cff2b7c4b460cb5bc6160bf2df4ff95b089`. The worktree was clean.
Five original requirements are retained, with their exact claim hashes
frozen in `closure-config.json`. Prior publication manifests, certificate
authority and prior repair packages are preserved. The initial scope protected
the current result trees; after the real producer/replay defects below were
found, the author required a fresh full-corpus run before publication.

## Build Compatibility Preflight

The broader experimental scripts compile producer sources independently of
the standalone verifier. New producer-side regression mains therefore must
not introduce compile-time verifier imports. They exercise public verifier
entry points at runtime, while the bounded harness compiles fresh verifier
sources into its test classpath. No experiment runner needs rewiring.

## Review And Run Records

Independent bounded review reports are recorded separately for the harness
and each semantic family. They are evidence-generating reviews, not final
claim authorities. The two-build machine report decides closure. Any blocked
candidate is retained under its own manifest rather than edited into a pass.

## P3-03: Producer/Verifier Context-Version Drift

The new real-source profile census exposed a production integration defect:
`AlloySemanticProfileFactory.CONTEXT_VERSION` emits
`alloy-command-options-v4-independent-search-domain`, while
`SemanticEvidenceVerifier.SOURCE_COMMAND_CONTEXT_VERSION` still required
`alloy-command-options-v2`. Both use the same eleven-scalar, three-child
context shape. The source factory additionally requires parser ownership and
an independent command; the verifier's obsolete literal rejected its output.

The main agent independently reran the profile observer before repair. All
six untouched source-profile bundles, widths 3/4/6 in both overflow modes,
returned `THEORY_MISMATCH` with the exact message
`Source-command semantic context has an unsupported version`. The
[observations](incidents/profile-version-before/observations.tsv) and original
[bundle witnesses](incidents/profile-version-before/witnesses.tar.gz) retain
that counterexample. The Java observation collector's exit zero only means
collection completed: those baseline outcomes fail the separate Lean replay.
They were not reclassified as successful negative controls.

The production correction replaces only the verifier's version literal with
the exact current factory version. It retains every context shape, bitwidth,
overflow, scope, option, fingerprint, registry and provenance check. The
standalone positive fixture is updated to the current version, with explicit
rejection controls for old, truncated and future version strings after
recomputing the profile and enclosing checksums. The profile proof/replay
package supplies the exact version-guard correspondence and source-pin checks.
No permissive version prefix or fallback to obsolete contexts is introduced.

Whole-class verifier pins in the new packages must be regenerated against
this reviewed correction, then all affected evidence rerun. This correction
changes only standalone replay. Rewrite/distance computation and
the archived experiment JAR remain unchanged. The standalone verifier build
is refreshed separately; its old executable is not presented as the repair.

The standalone build also brought its checked-in classes/JAR into agreement
with already tracked source changes from earlier releases. These binary
differences are rebuild outputs, not additional production-source edits.
The first post-fix standalone `VerifierTest` run passed 184 checks, including
the three new unsupported-version controls.

## Profile Observer CLI Integration

The initial profile observer accepted an output directory; the registered
engine supplies a TSV filename, and the broader Java runner supplies no
arguments. The observer is corrected to the same optional-output-file
contract as the other regression mains. Fixture files remain temporary and
are cleaned up. The shared frozen engine and experimental scripts are not
changed to accommodate a test-specific interface.

## P2-20/P2-18: Recursive Splice Replay Order

The container implementation review identified a potential disagreement beyond
the initial one-splice exported fixture. The main agent reduced it to a valid
four-leaf right-nested Boolean construction. The producer emits parent-before-
descendant splice records, but independent `flatInput` replay accumulated
descendant-before-parent records. The original exported FULL bundle rejected
with `THEORY_MISMATCH: Flat splice does not reconstruct from the visible
source tree`. The [pre-repair probe](incidents/splice-order-before/ContainerWitnessTransitionsRegressionTest.java)
and [actual failure log](incidents/splice-order-before/run.log) are retained.

This supported recursive-construction failure is part of the selected repair,
not an excluded deeper case. Independent replay now remembers the splice-list
insertion position before validating a child, then inserts the fully derived
parent record at that position. All fields still come from the validated
child; descendants follow the parent without weakening order, path, arity,
type or authority checks. The new container census covers all five binary
associations of four leaves in Boolean Set and modular integer Bag exports,
plus rejection of reordered splice ledgers. Lean records the corresponding
preorder-list construction contract.

These two replay corrections are confined to `SemanticEvidenceVerifier.java`.
They do not change producer rewrite rules, canonical distances, existing
empirical results or theory-pin authority.

## A2-11: Missing Canonical-Fold Intermediate Types

The chain census and independent reviewer found an unmutated supported export
failure at `JOIN:primitive:0:1`: source `A . ((A->B) . (B->C))`, with the
first operand stored as `AlloyCarrier A`. The source association needs A, C
and binary relation types, but canonical left-fold replay also needs the
unary relation B. The writer collected source-association types only.
FULL verification failed with `THEORY_MISMATCH: A dependent product has no
declared exact relation type` despite successful local certification.

The main agent independently reproduced the same result with the actual
public verifier. Its [failure log](incidents/chain-ledger-before/run.log)
and [partial trace](incidents/chain-ledger-before/observations.tsv.failed.tsv)
are retained. Separate setup logs record an initial classpath mistake and a
missing explicit TEST_ONLY flag; neither is semantic defect evidence.
The regression's fixture flag is scoped and restored internally for its
registered optional-TSV/no-argument interface.

`CertificateBundleWriter` now collects types from both the original source
association and the exact canonical left fold already required by the
certificate index. Shared helpers register every DAG relation family,
alternative product, exact column and ancestry, common ancestor, and full
combination-case boundary/result, including case products omitted from the
normalized DAG. The existing `DependentTypeDag.combine` derives every step;
the final DAG must equal the certified source result. There is no invented
carrier, `univ` fallback, new subtype assumption or relaxed verifier check.
All declarations are collected before the type table is serialized.

The chain package supplies general fold-ledger coverage proofs, positive
writer/public-verifier examples and removal controls for newly required
intermediate types. Whole writer-class pins are refreshed deliberately and
every affected area rerun. The production changes are limited to this writer
type-ledger completion and the two standalone replay corrections above.

## Exact Reversal-Control Observation

Independent container review found that the new encoder checked whether the
`reverseSplices` observation differed from preorder, but did not require it
to be the specifically registered reversal. Substituting an empty ledger
therefore left its generated rejection proposition true. This is a bounded
observation-to-proof defect, not evidence that the production verifier accepts
an empty splice ledger. The named control must bind the exact reversed source
coordinates, and its encoder tests must reject substituted empty or unrelated
ledgers. The original probe and reviewer disposition are retained with the
review evidence; a targeted recheck is required before freezing the package.

## Publication Rerun Gate

The author's later instruction requires rerunning the experiments because
the checks found real certificate-generation/replay defects. After the bounded
suite passes, freeze a clean source commit and one experiment JAR, then run
CanonicalBatchTest, Alloy4FunAugmenter, seven-arm ablation plus semantic check,
and capabilities serially outside the worktree. Use all 66,080 files, reward
pool 100, 16 workers and an 8 GiB heap. No partial run or pre-repair result may
be substituted. Preserve the previous snapshot until all new stage gates pass;
retain every interrupted or failed attempt with its source identity.

The required rerun completed at clean source `8ad5fead39b687d2cadc79b01ac27743c1ece990`.
Publication run `db9f89bf-0965-4d74-8080-d9191d5f1aec` passed all four gates:
61,598 eligible distances, 42,386 incorrect rankings and rewards, seven full
ablation arms, and 5,500 capability pairs. There were zero terminal failures
or incorrect nearest-truth zeroes. All 5,808 imported stage files match the
new manifest. The previous result-producing JAR remains unchanged.

## Hosted Closure Resource Limit

GitHub Actions run `34266539252` passed all preceding packages, then timed
out after 300 seconds compiling `DependentChainWitnessReplay.lean` in the
first new clean build. This is an `INFRASTRUCTURE_FAILURE`, not a falsified
theorem and not a successful negative control. Its exact log is retained in
`evidence/acgn-v215-ci-first-failure.log`.

The new candidate allows 900 seconds per command and 120 minutes for the
whole CI job. Proofs, observation counts, rejection predicates and production
Java remain unchanged. A fresh input root and two-build closure are required;
the earlier preflight root is retained only as historical evidence.

## Combined Hosted Job Budget

Actions run `34285126819` exhausted its overall 120-minute job budget. It
had completed both builds' positive proofs and replays and was executing
`build2-source-reject-chain-chain-verifier-index` when the host canceled it.
This is a second infrastructure limit, not a failed proof or accepted invalid
certificate. The complete hosted log and the locally VERIFIED report for
that candidate are retained in `evidence/combined-ci-budget/`.

The fourth-five closure now has an independent 120-minute CI job, in parallel
with the unchanged earlier suites. It uses the identical pinned installer,
toolchain, command, 900-second per-command limit, claims and controls. A
structured YAML comparison confirmed that no previous test was removed and
the installer steps are identical. This prevents the earlier packages' run
time from consuming the new package's budget; reports and command logs are
also uploaded. A fresh local two-build closure binds the new workflow. No
producer, verifier, proof, dataset or experimental result changed, so the
completed full-corpus run remains the result source for v2.15.

## Independent Job Cold Start

The independent job in run `34297111939` reported `BLOCKED` with
`UNDECLARED_DEPENDENCY: Lean differs from frozen version`. Its retained
`lean-version.log` actually contained the correct Lean 4.33.0 line preceded
by Elan's first-install messages. The combined job had implicitly warmed
the toolchain through its earlier catalog step; the new job had not.
This is a setup/transcript mismatch, not a theorem or Java semantic defect.
The exact failed report and log are in `evidence/independent-ci-cold-start/`.

An explicit `elan toolchain install` now runs before offline verification.
The strict version checker is unchanged. A fresh local ELAN_HOME using the
exact CI installer (SHA-256
`42b94d4244e8353142c456ec0e4ca6528fd898a6c604d4059f494e706e431f63`)
reproduced a clean single-line Lean 4.33.0 version response after installation.
The candidate is reverified with that isolated toolchain and a fresh input
root. The preceding archive replay and superseded CI run were stopped with
their partial records retained; no such partial run is used as a PASS.
