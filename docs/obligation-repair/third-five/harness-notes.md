# Third-Five Harness Candidate

This is a design/repair candidate, not a closure result. No final full closure
is run while area workers are writing. The authoritative future result is the
engine-generated `report.json`, never this note or a manually authored report.
No original parent statement, ledger, CI entry, data or production file is
changed by this harness.

## Frozen Boundary

The five `TF-*` records in `closure-config.json` are the intended finite public
claims. Their parent identities and original matrix hashes are fixed for
P1-06, P1-09, P1-16, P2-19 and A2-04. The phase scopes and `passCondition` /
`blockConditions` records are written before verification. Each phase requires
every registered package check, including all three area censuses and both
builds; there is no partial-area PASS or override. Original parent statements
are not replaced or automatically discharged.

The pass-check IDs denote the v2.13 operations `check_matrix`, `inputs`,
`proof_inventory` / `check_proof_log`, configured Java commands, area-plugin
census validation, generated Lean compilation, exact-exit-1 controls,
`run_build` twice, `compare_builds`, and final evidence/hash checks. These are
executable predicates, not evaluated natural-language assurances. Relevant
mutation requires a fresh candidate/root/closure ID and fresh evidence.

PROVED is limited to the audited model and replay theorems. TESTED is limited
to the configured Java observations and harness tests. CHECKED includes
compiler-resolved mappings, inventories, input/evidence hashes and provenance.
The encoders, extractors, source/type interpretations and execution platform
remain explicitly TRUSTED as listed in config. Unencoded behavior, full Java
or parser refinement, whole-corpus results and new authority are OUT_OF_SCOPE.

## Engine Isolation

`run_third_obligation_repairs.py` executes the existing engine in a fresh
private module, guarded by the exact v2.13 source SHA-256
`d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55`.
Its counted AST-literal allowlist changes only the package path, replay-plugin
default, driver-test path, progress prefix, private plugin-module prefix,
closure-ID prefix, the two package-input wildcard literals, and the Lean
scope-inventory grammar. Both package
globs select only `closure-config.json`; notes are explicit inputs. PARENTS is
rebound only in that private namespace. Function
defaults are compiled for third-five. No verifier body is copied, no process
global in the imported old runner is patched, and no report is relabeled after
execution. Engine drift or changed adaptation sites fail closed.

Integration found that the inherited inventory scanner did not open a scope
for Lean `mutual`, so its closing `end` incorrectly consumed an enclosing
namespace. The private adapter now recognizes `mutual` as an unnamed scope;
qualified theorem names and exact audit coverage are still required. A
regression reproduces the old rejection, checks nested mutual definitions and
theorems, and rejects a missing theorem audit. All 26 harness tests pass at
this integration point. The v2.13 source is unchanged. This was a verifier
inventory defect, not a production semantic change or a weakened proof check.

The explicit, ordered Lean dependencies are `DependentChainSequence.lean`,
`DependentJoinGuard.lean` and `PhaseA2DependentChains.lean`, compiled before
the three area modules in both builds. The first two have existing audits.
PhaseA2 has no audit commands: the wrapper appends mechanically generated
fully qualified `#print axioms` commands to its isolated formal build copy.
Its 130 public and two private theorems are all inventoried. An inventory-only
view exposes private declarations to the existing scanner; the source compiled
by Lean retains their privacy. The two actual `_private.PhaseA2DependentChains.0`
names must appear in the kernel axiom output. Missing or altered audits reject.
The actual unchanged dependency is a regression fixture. Neither
the repository proof nor the frozen source snapshot changes. This generated
audited source and its compiled output participate in artifact determinism.
Dependencies do not create additional parent claims or inherit prior PASS.

The old plugin tests remain a registered compatibility check because the
shared dependency is retained. The driver tests are the new third-five tests,
including aggregator checks. These contain simulated compiler lifecycle
fixtures, explicitly not proof evidence, real temporary Git provenance, and
a small real offline Lean smoke test when that pin is installed. The full
engine still requires its real pinned Lean check before any builds.
After the compatibility plugin tests, the private Commands subclass invokes
every frozen `scripts/test_third_*.py` suite except
`test_third_obligation_repairs.py`, which already ran as the driver. CALL,
JOIN and registry encoder suites are mandatory explicit inputs; absence is
MISSING_INPUT, never a skip. Each additional suite receives a separate bound
command record and log, and any failing suite prevents closure. This avoids
self-recursion and does not merely hash the area tests without running them.

The wrapper additionally requires both reported Java and javac major versions
to be 17 before tests begin; `--release 17` alone is not that runtime guarantee.
Negative controls require exact exit 1 and a complete transcript consisting of
an area-specific source mismatch with hash/stack rows, or complete false-proposition
`decide` blocks and axiom-audit lines. Multiple false propositions are supported.
Mixed or unrelated diagnostics block; missing-module/class/tool and runtime
panic/resource diagnostics are infrastructure failures. A real Lean panic
after a false proposition and a compiler error after an expected source mismatch
are regression cases. The command record retains the corresponding non-PASS status. These
third-only checks repair the review's H1-H3 evidence transitions, without
changing the older engine or broadening production trust.

## Area Contract

| Area | Test Output | Extractor Output | Replay |
| --- | --- | --- | --- |
| CALL | `call-authority.tsv` | `call-authority-source.tsv` | `CallAuthorityReplay.lean` |
| JOIN | `guarded-join-chains.tsv` | `guarded-join-source.tsv` | `GuardedJoinChainReplay.lean` |
| Registry | `registry-admission.tsv` | `registry-admission-source.tsv` | `RegistryAdmissionReplay.lean` |

The paired proofs are `CallAuthorityTransitions.lean`, `GuardedJoinChain.lean`
and `RegistryAdmission.lean`. The Java test and extractor classes are explicit
in config. Existing CallExtractionRegressionTest and
TheoryLawPolicyRegressionTest are included as additional local tests.

Every area plugin must export `generate(build, formal)`,
`negatives(build, formal)`, and `source_mutations()` or
`source_mutations(build, formal)`. Return formats are the unchanged v2.13
tuples. Each area must supply exactly its configured replay, nonempty negative
controls and nonempty source controls targeting its own extractor class.
Replay declarations must have qualified, disjoint namespaces across areas.
Control labels are prefixed with `call-`, `join-` or `registry-`; duplicate
labels within an area still fail. Every theorem needs exactly one local axiom
audit, and each reported positive count must match the scanner inventory.

The workers must freeze exact source-object and observation key sets in their
plugins before the final run. The aggregator delegates every row and every
failure unchanged; it does not infer expected keys from observations, invent
missing records, shrink a census or provide a fallback proof. Census and
semantic checks remain the responsibility of the hashed area plugins and
their tests. Registry implementation and final contract coordination belong
to main. Initial filenames above must be confirmed with workers via main;
changes require coordinated edits to config and the explicit `AREAS` profile
before freeze. Additional Java helpers are compiled by the unchanged engine
from all frozen `scripts/java/**/*.java`; generated Java outputs must be
declared in the relevant extractor's `javaOutputs` before freeze.

Main confirmed the registry filenames above and a helper-free
`RegistryAdmissionExtractor`. `registry-notes.md` is a required explicit input.
The reported registry observation contract is 9,516 requests: 9,504 grid
cases, six schema/authority boundaries and six source cases, with four full
compiler-resolved classes in the source inventory. These are integration
targets; the plugin must enforce its frozen keys mechanically. No changing
theorem total is used as a substitute for the actual audited inventory.
Main subsequently reported 298 grouped propositions over those 9,516
observations, three negative programs, four source controls and nine encoder
unit tests. The plugin now declares `ACGN.ThirdFive.RegistryReplay`; the
aggregator still checks the actual emitted inventory and disjointness.

## Inputs And Reproduction

The existing manifest captures all source, certificate-verifier files,
libraries, Lean modules, Python/shell verifiers, Java extractors and CI inputs.
All three plugins and their encoder suites, the wrapper, aggregator and driver
tests are mandatory explicit inputs. The only automatically frozen package
file is `closure-config.json`; the four explicit frozen notes are
`call-notes.md`, `join-notes.md`, `registry-notes.md` and `harness-notes.md`.
There is no package-wide recursive scan. Explanatory README/reviews and copied
reports, generated evidence or incidents are excluded, so publication copies
do not introduce circular inputs or change the archive replay root. New
verification-relevant notes must be explicitly registered before freeze.

Imported verifier files are checked against the manifest. Any frozen plugin,
note, config, source or proof mutation is blocking, as is mutation of the
current run's traces, evidence or logs. Missing plugins, suites or proofs
cannot become a reduced-census run. The run's writable output directory must
remain outside the input tree even when prior evidence is packaged with it.

The input root does not need `.git`. Each clean snapshot gets its own real
deterministic Git repository with fixed author/committer dates, disabled host
Git config/hooks/signing and the commit subject `TEST_ONLY frozen closure
inputs`. These are temporary test provenance commits, not workspace, release
or experimental provenance. Final commit IDs and clean status are checked,
and the two builds must have identical fixture commits as well as proof
inventories, correspondence/provenance records, artifacts and control data.

Lean is pinned to `leanprover/lean4:v4.33.0` in every environment, including
isolated directories with no elan default. No install/download is attempted:
an elan shim with a missing local pinned toolchain fails before invocation.
An explicit `LEAN_BIN` may point at an installed standalone binary, whose
version is checked by the engine. Verification requires preinstalled Python,
Git, JDK 17, pinned Lean and repository libraries. Offline execution is an
execution-policy/TCB requirement, not an OS-level network sandbox.

After main has reconciled the area contracts and all workers have stopped:

```sh
python3 scripts/test_third_obligation_repairs.py
python3 scripts/run_third_obligation_repairs.py /tmp/acgn-third-five-FRESH --root /path/to/frozen/archive
```

The second command is deliberately deferred during integration. Its output
directory must not exist and must be outside the input tree. It generates
`input-manifest.json`, command logs, two fresh snapshots, inventories, build
evidence and `report.json`. Exit 0 means only the frozen finite surface is
VERIFIED under declared trust; exit 1 is BLOCKED; exit 2 is
INFRASTRUCTURE_FAILURE. Negative/source controls must exit exactly 1, not an
arbitrary nonzero code. Reports and evidence must never be hand-edited.

## Confirmed Integration

The area workers confirmed all trace/source filenames, disjoint replay
namespaces, source extractors, and the three JOIN imports in the profile.
CALL has 91 observations and replay theorems, 43 source objects, 23 general
theorems, 13 Lean negatives and ten source controls. JOIN has 1,021 observations,
1,025 replay theorems, four source objects, 34 general theorems, 12 Lean
negatives and 12 source controls. Registry's census is recorded above. No
generated Java helper is required. These counts are enforced by the area
encoders and audited inventories, not inferred from the number of input rows.
The final two-build result remains the generated report's responsibility.
