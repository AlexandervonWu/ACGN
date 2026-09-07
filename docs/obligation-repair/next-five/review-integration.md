# v2.13 Next-Five Integration Review

**PASS (bounded review)**: the reported census and Git/snapshot integration
findings are resolved by the final same-gap recheck below. The 1,900-row bounded
chain review also passes. Earlier FAIL verdicts and the initial registered
BLOCKED run are retained as historical evidence, not current findings. No false
VERIFIED result or scoped production sequence defect was found. This review
PASS is not a registered closure VERIFIED result; main owns final5.

## Snapshot Git Follow-Up

User-requested bounded note, checked 2026-09-07 20:13-20:15 UTC. Main added
`initialize_fixture_git` in the runner only. It creates a fresh repository in
each source snapshot, commits that snapshot with fixed identity, date, branch
and TEST_ONLY message, disables hooks/signing and external Git config during
initialization, and clears inherited `GIT_*` variables in the runner environment.
It does not copy the worktree's HEAD or weaken `CertificateProvenance.capture`.
The build record separately identifies `fixtureGitCommit` and TEST_ONLY scope;
both participate in the two-build comparison. Production capture has no diff.

The updated runner suite passes **33 tests**, including the real mini-Git check:
two independent directories yield the same commit, each has a clean status,
and no parent repository is created. Earlier failures while the Git mocks were
still being updated were transient and are not current findings.

**[P1] Remaining metadata integration:**
[check_snapshot](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:300)
still includes every file under the snapshot, including newly generated `.git`
files, in its equality comparison with the pre-Git source manifest. A focused
real-Git witness copied the existing pinned `lean-toolchain` into a fresh source
directory and successfully checked its one-file manifest, called the actual
`initialize_fixture_git`, then called the same `check_snapshot` again. Result:

```text
fixtureCommit 284bb66b37606f4ae37970892a4f9b4b1911da64
after real fixture Git: INPUT_MUTATION: snapshot differs from frozen inputs
```

The snapshot and four real Git command logs are retained under
`/tmp/acgn-v213-git-snapshot-review-61uvj8nm`. The current mini-Git test checks Git
determinism but does not compose initialization with the real snapshot checker;
the mocked lifecycle does not create actual `.git` files. Treat generated Git
metadata separately without weakening any source-file hash checks, and cover
that composition before claiming the integrated fix complete. No production
change is needed. This is continuation of the same provenance integration
finding, not a new semantic chain or public FULL claim.

Reviewed runner hash:
`fb5d7fe83fb3a685ea4d2fab0f92d7d9f0ed7183834d43a669a0565ab3d6f097`.
Runner tests hash:
`f03ec6736c0b06f4c79e5e6ea38d11c0d5633853b4e8df6eb898c8395a7ee8ff`.
No second integrated closure was attempted within this review bound. The old
BLOCKED report remains preserved; neither it nor the chain-only PASS is a
VERIFIED result for this newly changed input root.

## Latest Recheck

Rechecked after the user's final-chain handoff, 2026-09-07 20:10-20:12 UTC,
within the original ten-minute review bound. The producer, indexed Lean proof,
28-object extractor and config still match the hashes below. At this recheck the
runner was byte-identical to the failed run; the later snapshot-Git follow-up
above supersedes that statement and identifies the current remaining gap.
The updated plugin hash is
`77a1b5384a9dbb99479a7fec2754f209ba1e02cb87311d22b0d20b8dc053aac2`;
encoder tests hash is
`221978f387a71fad86f8eab5cced7353e906315fac1757305a90425f8c88844d`.

| Latest independently executed check | Result |
| --- | --- |
| Updated encoder suite; current runner suite | 7 passed; 32 passed |
| Unchanged actual 1,900-row TSV and 28-row extraction through latest encoder | Accepted; exactly 1,900 theorem/axiom requests |
| Full generated chain replay under installed Lean 4.33.0 | Exit 0; all 1,900 theorem inventories use no axioms |
| Missing row; duplicate row replacing final row | Both BLOCKED |
| Pipeline falsely labeled FULL; certificate labeled only LOCAL | Both BLOCKED |
| Bag; Set; duplicate deletion; distinct same-type swap; wrong count only | Each exits 1; Lean `decide` proves the actual generated proposition false |
| Latest registered chain-shared-instance-state source control | Extractor exits 1 on construction binding mismatch; no TSV; original bytes restored |

The full generated source is
[acgn-v213-chain-latest-review.lean](/tmp/acgn-v213-chain-latest-review.lean),
SHA-256 `0d4117cc86fdd1d46aacbde878ef2dd1ffb064115021f308c1d2ce9d50e62a5e`.
It imports the fresh base proof from the preserved run's `build1/formal` using
`LEAN_PATH`. The five generated negative programs and raw rejection logs are
under `/tmp/acgn-v213-chain-replay-controls-div3y2l5`. Only candidate fields were
changed; source trees/expected values were not rewritten to agree with them.

The registered static-state control ran against a separate copied snapshot under
`/tmp/acgn-v213-chain-state-review-uwm0b05v`, using the fresh extractor classes
from the actual run. It changed only the already-registered `portSchemas`
private-final-to-static declaration, rejected, and restored exact source bytes.
Observed mutant construction binding hash:
`2e68e8167d5e3528c40a549773bf4a4d85824acd649b2a7263936355e2a8a4c7`.
The failed run and its manifest were not modified. No production source changed.

The latest consumer correctly enumerates typed, pipeline, separate TEST_ONLY
certificate and barrier surfaces. Only certificate rows require FULL; parsed
pipeline and barrier rows require LOCAL. Unsupported parsed-instance export is
explicitly excluded and is not a finding. The current plugin also registers
chain static-storage, reordered-source and deduplicated-source controls. The
static-storage control was directly rerun here; no claim is made that the full
runner reached these controls or completed either closure build.

## Findings

### [P1] Clean-snapshot execution cannot capture certificate provenance

[run_next_obligation_repairs.py:583](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:583)
runs Java tests from the frozen source snapshot without a provenance-root option.
The snapshot contains no `.git`, and the chain test now calls
[CertificateProvenance.capture](/home/augustus/ACGN/src/is/fivefivefive/CanDis/theory/DependentChainSequenceRegressionTest.java:282)
for each supported public certificate. `testOverride=true` allows TEST_ONLY
provenance but does not bypass Git-root discovery.

The unmodified real runner compiled all producer/verifier sources, all three
extractors and all three base proofs, then failed at `build1-test-02`:

```text
java.io.IOException: Cannot locate the Git repository for certificate provenance
CertificateProvenance.repositoryRoot(CertificateProvenance.java:205)
CertificateProvenance.capture(CertificateProvenance.java:82)
DependentChainSequenceRegressionTest.certificateCase(...:282)
```

This blocks NF-A2-01/NF-A2-02 and consequently the five-phase closure. The same
freshly compiled classes pass with the existing explicit
`-Dacgn.repo.root=/home/augustus/ACGN` option. That diagnostic is not a closure
repair: integration must explicitly account for provenance inputs and Git trust
while preserving the same-source hash-to-build boundary. Merely pointing at an
unrelated mutable checkout must not establish that boundary.

### Resolved: [P1] The replay plugin consumed the obsolete chain contract

The following describes the preserved initial snapshot only. The latest
1,900-row change and added tests resolve this finding, as rechecked above.

[next_obligation_replays.py:105](/home/augustus/ACGN/scripts/next_obligation_replays.py:105)
enumerates only 1,872 `typed` and 12 `pipeline` rows, requires 1,884 total rows,
and requires `FULL_VERIFIED` on pipeline rows. The actual regression and current
chain handoff specify **1,900** rows:

| Surface | Rows | Actual replay boundary |
| --- | ---: | --- |
| typed | 1,872 | LOCAL_VERIFIED |
| pipeline | 12 | LOCAL_VERIFIED |
| certificate | 12 | FULL_VERIFIED |
| barrier | 4 | LOCAL_VERIFIED |

Feeding the unchanged, successfully generated TSV to the frozen plugin produces
`Blocked: incomplete chain observation census`. As a diagnostic only, filtering
to its old typed/pipeline census produces
`Blocked: chain replay not verified at declared boundary`.

The required repair was to update the consumer's explicit census and
surface-specific status contract to the final producer interface, retaining the
certificate and mixed-head barrier observations. The latest change does so
without relabeling LOCAL pipeline observations as FULL. The supported
public certificate witnesses are valid for the stated bounded scope; exports
of the parsed repeated-field cases are explicitly excluded in chain-notes.md.
The initial test gap was missing focused chain encoder tests:
[test_next_obligation_replays.py](/home/augustus/ACGN/scripts/test_next_obligation_replays.py:8)
then exercised only flat encoding and shared primitives, so all four tests
passed despite the incompatible producer/consumer contract. The latest suite
adds chain and CALL coverage; additional direct boundary controls passed above.

## Initial Run Evidence

Real command, executed offline with no implementation edits:

```sh
env PYTHONDONTWRITEBYTECODE=1 python3 scripts/run_next_obligation_repairs.py /tmp/acgn-v213-integration-review-20260907-2006
```

Machine authority:
[report.json](/tmp/acgn-v213-integration-review-20260907-2006/report.json),
[input manifest](/tmp/acgn-v213-integration-review-20260907-2006/input-manifest.json),
[failure log](/tmp/acgn-v213-integration-review-20260907-2006/build1-test-02.log).
Closure ID: `next-five-v2.13-ed9e077aeae6e0ea`.
Input root: `ed9e077aeae6e0ea3d909efc02564fce53f355628e82fbd756000420e900728d`.
Exit 1, BLOCKED, 0/5 claims passed, 0/2 completed clean builds; determinism,
integrated replay witnesses and final provenance remain unresolved.
Environment: javac/JVM 17.0.20, Lean 4.33.0, Python 3.10.11.

| Independently executed check | Result |
| --- | --- |
| Runner tests | 32 passed; lifecycle compiler calls are simulated |
| Replay encoder tests | 4 passed |
| Actual fresh producer and standalone verifier Java compile | Exit 0 |
| Actual three source extractors | Exit 0; chain has 28 mapped objects |
| Actual three base Lean proofs | Exit 0 |
| Chain theorem/axiom inventory | 18; only propext, except construction_is_seq uses none; no warnings |
| Fresh chain classes with explicit existing provenance-root option | Exit 0; 55,204 checks, 1,900 observations, 12 FULL positives and 24 REJECTED:THEORY_MISMATCH controls |
| Unmodified generated chain TSV through frozen chain_program | BLOCKED: incomplete chain observation census |
| Old two-surface filter, diagnostic only | BLOCKED: chain replay not verified at declared boundary |

The diagnostic chain command used `build1/classes` and `build1/source/lib/*`
from the failed run, from its snapshot working directory. It wrote only
[/tmp/acgn-v213-integration-chain-observations.tsv](/tmp/acgn-v213-integration-chain-observations.tsv),
outside the preserved run. Its provenance-root override reads the working
repository for TEST_ONLY provenance; this is not two-build frozen evidence.

Observation TSV SHA-256:
`17c36bcff8ca50261cd44c860afcc244710e8c0e41f6a6e80bae0a5eecb2668b`.
Fresh extraction TSV SHA-256:
`b229d1c0ace85a39c1ea25579cd8911846336bc06a94cfe8921fae33767cc120`.
All reviewed input hashes are retained in the machine manifest. Key hashes:

```text
runner     d007fbd2ed2b555e962b53f19c511d563adfb44b314397a9dc5c4ac192f54b93
plugin     17beeeff7effd5172881bdf5b69840a61b0ce38fa13b8f65ae14e5a15e6615b3
chain Lean e46aebdc2ecb6ff7d27c46baefba4fcf545c07403d721618317c6792f4a6d988
extractor  f1824d846fb0f9555a75e78c8acc6bfd328706b405b8add3240522dac253545a
chain test 2cf0ad63a96447939efac5b7106baa3253ac87890fad0ed55bf3d336ea136fe1
```

## Scope Assessment

- The indexed homogeneous Lean tree excludes mixed-kind child applications;
  supported adapter barriers are opaque complete operand identities. This is
  sequence projection, not a new relational associativity or JVM theorem.
- `accepted_iff_source_sequence` requires Seq and exact source-list equality;
  accepted length and per-identity counts follow. Distinct same-type operands
  are not merged by the observation encoder. The independent verifier checks
  exact positional schema, Seq carrier, length and each operand ID.
- The flat model still requires exact `One(result)` admission and one shared
  substitution. No constructor widening or new certificate authority is needed.
- Public FULL controls use ordinary public Wire/Codec/verifier APIs; reflection
  is solely a public API linkage bridge. No private-field heap attacks are used.
  Rejections are semantic-source consistency controls, not proof that every
  variant reaches the positional loop: source keys can reject earlier.
- The runner hashes relevant source/proof/config/verifier inputs, checks fresh
  snapshots, compares two builds and deterministic artifacts, preserves positive
  evidence around controls, and checks final input/log/evidence hashes before
  setting VERIFIED. Executed lifecycle tests reject wrong/missing census,
  changed inputs, absent witnesses, accepted negatives and build drift. These
  are bounded controls, not a universal no-false-acceptance proof.
- The flat review's private-final-to-static finding is fixed, not reopened.
  The reviewed chain extractor now includes sorted field/owner modifiers and
  explicitly binds retained `InstantiatedOperator.portSchemas` state; its fresh
  28-object extraction passes. The chain regression's retained-state interleaving
  checks pass. The initial pass read the chain agent's static-mutant evidence;
  the latest recheck also independently executed the registered source control.

TRUSTED: declared Lean kernel/standard axioms, javac/JVM/collections, hashed
extractors and observation interpretation, admitted parser/type/provenance
decoding, Python/SHA-256/filesystem/OS/hardware. OUT_OF_SCOPE: arbitrary hostile
Java heaps/custom implementations, private reflection, universal parser/JVM
refinement, unlisted authority claims, production publication provenance, and
unregistered revisions. No broader claim is discharged by this review.

The initial attempt did not reach generated replay; the follow-up above checked
the complete chain replay only. No full-package replay or completed two-build
closure is claimed. The
preserved failed run predates this review document; adding this manifest-covered
document itself changes the next input root. Only this report is review-owned;
no workspace production, proof, test, config, extractor or runner source was edited.
No internet or new production/static rewrite was used. The only source mutation
was the existing registered verifier control in a separate temporary snapshot.

## Same-Gap Recheck: Final Snapshot Audit

**FAIL**, bounded to the existing Git/snapshot composition gap, rechecked
2026-09-07 20:17-20:18 UTC at the user's request. The checker fix itself passes:
`fixture_git=True` requires a real nonsymlink top-level `.git` directory,
excludes only that generated metadata subtree, and retains full source-file
census/hash equality. The real mini-Git test now exercises pre-init and post-init
checks, changed-source rejection and unexpected-file rejection. That targeted
test and the complete **33-test runner suite** both pass.

**[P1] One post-init call site still omits the option:**
[run_next_obligation_repairs.py:783](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:783)
performs the final post-build audit as
`check_snapshot(directory / "source", manifest)`. In contrast, the per-build
call at line 680 correctly passes `fixture_git=True`. The pre-init call in
`make_snapshot` correctly retains the default. The final audit would therefore
block after two otherwise successful real builds because each source contains
its generated `.git` directory.

Reused the retained real repository under
`/tmp/acgn-v213-git-snapshot-review-61uvj8nm/source`, without modifying it:

```text
per-build fixture_git=True: PASS
final execute call without fixture_git: INPUT_MUTATION: snapshot differs from frozen inputs
```

The new per-build final HEAD equality and clean-status checks are present, and
fixture commit/scope still participate in the two-build comparison. They do not
change the behavior of the missed final snapshot call. The same-gap completion
needed is enabling fixture metadata handling at that final post-init audit and
covering it with real metadata. No production capture change is requested.

Reviewed runner SHA-256:
`1653855b88028fd2938158ddcc247be18e9e037db38973c5f333f95e4a19b481`.
Runner tests SHA-256:
`b34f5174a00efbe194f47f2b75639b432475e9c8b2b93b0292683831f9bc1b49`.
This recheck made no implementation edits, no new witness source mutation,
no internet request and no broader search. Main's `final3` registered run was
not inspected, changed or duplicated. Its eventual closure state is not claimed
here. This appendix itself is a manifest-covered document update, so main must
freeze the final document before relying on a completed input-root check.

## Input-Freeze Recheck

**PASS**, bounded to the explanatory-document/input-manifest correction,
2026-09-07 20:21 UTC. This does not convert the earlier integrated BLOCKED run
or any currently running closure to VERIFIED.

The runner no longer globs package Markdown. The authoritative config explicitly
lists `chain-notes.md` and `call-notes.md` as required inputs; both remain hashed
and missing-file blocking. Config, all source/library roots, proofs, scripts,
extractors, tests, matrix, claim ledger and CI entry points remain covered by
the existing input-selection and full snapshot census/hash checks. The Git
TEST_ONLY trust statement is itself in the hashed config.

Executed the actual `read_config` and `inputs` functions against the current
workspace. The resulting **603-file** manifest contains the two handoffs and
each checked executable/proof/config/claim/CI dependency. It excludes package
`README.md`, `review-integration.md` and `review-flat.md`. The three focused
tests for verifier/source manifest coverage, stale/extra/symlink snapshot
rejection and real fixture-Git composition all passed.

Observed input root before this appendix:
`42fe35775828aaccab8582725baec647442f3ce4a2dc4500a0b550f74d584ade`.
Recomputed after appending: the same 603-file root; this review remained
excluded, and both handoff hashes were unchanged.
Reviewed runner:
`40632a8530d6a50dbbf5204864e341123542b8d73f02dc65775b4943b9cf889a`.
Config:
`9b2e105590c5ab833d1a58238d4b42aa96300177b73230e129a8fde38c53f575`.
Chain handoff:
`330e592b43960a67af20eb73b87b277662b577f099bd42333d4af8ca8ff9f5a6`.
CALL handoff:
`9a23302ca77de83d581d2394b3e810cbfd6408aa7549e9fbcfc97194ab537549`.

The earlier statements that this review document is manifest-covered describe
the historical runner only; this input-selection change supersedes them. The
user reports final3 correctly blocked after a then-hashed README changed. No
final3/final4 report was inspected or altered in this recheck, and no full run
was started. Excluding explanatory prose must not be used to source additional
unhashed verification requirements; the authoritative scope/schema/TCB remain
in the protected config and handoffs.

The previously reported final post-build `check_snapshot` call at runner line
783 still omits `fixture_git=True` in this reviewed hash. That same-gap finding
remains open; the input-freeze PASS is not an overall integration PASS. No new
defect search was performed. Only this review appendix was written; neither
chain/call handoff nor any implementation or running closure was modified.

## Final Same-Gap Recheck

**PASS**, scoped solely to the previously missed final snapshot-audit call,
2026-09-07 20:25 UTC. This supersedes the open-finding statements in the earlier
appendices; no reported review finding remains open at these reviewed hashes.

Confirmed all three runner call sites:

- `make_snapshot`, line 318: strict default check before Git initialization.
- `run_build`, line 680: `fixture_git=True` after initialization and controls.
- `execute`, line 783: `fixture_git=True` in the final post-build audit.

The lifecycle Git mock now creates `.git/HEAD` with the fixture branch reference,
so the end-to-end simulated lifecycle exercises a generated metadata file rather
than an empty directory. The real mini-Git test retains before/after checker
composition, equal commits across separate repositories, changed-source and
unexpected-file rejection, and clean status checks.

Independently executed:

```sh
env PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_next_obligation_repairs.py
```

Result: **33 tests passed**, exit 0. Compiler execution in lifecycle tests remains
simulated; the mini-Git test uses real Git. This verifies the same-gap repair and
does not substitute for two registered clean builds or their complete controls.

Reviewed runner SHA-256:
`d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55`.
Runner tests SHA-256:
`75011fa68ebd020729e21c6e46adb16c9636511af3f8c302eed452f3cddf45b5`.

The user reports final4 completed both builds and all 21 controls before the
old outer call rejected. That run was not independently inspected here. Final5
was not inspected, modified or duplicated, and no result is claimed for it.
Only this explanatory review file was updated; chain/call handoffs, executable
inputs and production capture were untouched. No internet, broader search or
new mutation was used. The scoped review is finished; no additional review gate
is requested after main's registered final5.
