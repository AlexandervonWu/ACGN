# Bounded Harness Integration Review

Review date: 2026-09-08. Review disposition: **BLOCKED**, with three concrete
findings below. This is an independent audit, not a closure report, parent-ledger
discharge, or authority to publish certificates. Only this repository file was
edited by the reviewer. Tests created isolated temporary fixtures/evidence.
No internet, agents, production edits, dataset edits, or full package closure run.

The mechanical-closure skill and its normative closure protocol were read.
The reviewed surface is the third-five adapter, aggregator, configuration,
harness notes, tests, and their inherited evidence transitions. CALL/JOIN area
semantics and final integrated runs remain main's responsibility. In particular,
synthetic lifecycle reports saying VERIFIED below are **counterexample/test
outputs, not verification of the actual five repairs**.

## Findings

### H1 [P1]: Exit 1 promotes infrastructure errors to successful controls

Location: [third Commands.run](/home/augustus/ACGN/scripts/run_third_obligation_repairs.py:109),
delegating to [the inherited exit-only decision](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:453).
The two callers are [negative Lean execution](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:663)
and [source rejection](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:677).

Affected claims: all five TF-* phases; their shared
`negative-and-source-controls-exit-1`, `two-fresh-builds`, and
`bound-machine-evidence` checks. Novel evidence: actual JVM/Lean infrastructure
diagnostics passing through the real control/result aggregation path. The
required transition is control PASS to non-PASS, with infrastructure diagnosed
as INFRASTRUCTURE_FAILURE rather than accepted rejection.

In otherwise simulated lifecycles, I executed the actual Java launcher for the
CALL source control against the fixture's intentionally synthetic class output.
Both commands returned 1 with:

```text
Error: Could not find or load main class CallAuthorityTransitionsExtractor
Caused by: java.lang.ClassNotFoundException: CallAuthorityTransitionsExtractor
```

Neither invocation reached the extractor. Nevertheless both control records
were PASS, the report was VERIFIED, and all five claims passed. A second probe
used real pinned Lean for a frozen mock negative program importing an absent
module. It returned 1 for `unknown module prefix
'MissingThirdFiveReviewDependency'`, never checking the target proposition.
Both negative records and the final report again passed.

This is a harness/result-classification defect, not an assertion that the
current area plugins generate malformed controls. Closed namespaces and
independent area tests do not establish the reason for rejection in each later
clean build. Exit 2, timeout, and process-launch exceptions already fail closed;
the uncovered case is an infrastructure failure represented by exit 1.

Smallest fix: keep v2.13 unchanged and add a third-profile rejection contract in
the private Commands subclass. For registered `buildN-reject-*` and
`buildN-source-reject-*` labels, require the intended target false-proposition
or source-pin diagnostic, not merely nonzero/error output. Freeze the accepted
diagnostic/target mapping before execution. Reject absent, unrelated, or mixed
diagnostics; classify known loader/import/tool failures as infrastructure and
keep command metadata consistent with that classification. Add the two cases
below and a wrong-target/syntax-error case. A broad `error:` substring is not a
sufficient fix.

### H2 [P1]: Required PhaseA2 dependency cannot enter the build

Location: [generated dependency audit](/home/augustus/ACGN/scripts/run_third_obligation_repairs.py:154),
[shared scanner](/home/augustus/ACGN/scripts/run_submission_container_closure.py:176),
and [strict declaration-form check](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:360).
The unchanged dependency contains
[productionParserCapability](/home/augustus/ACGN/docs/section3-repair-audit/formal/PhaseA2DependentChains.lean:343)
and [foreignParserCapability](/home/augustus/ACGN/docs/section3-repair-audit/formal/PhaseA2DependentChains.lean:348),
both private theorems.

Affected claims: TF-A2-04 directly, and all five phases through the mandatory
dependency build. Novel evidence: substitute the actual unchanged dependency
into the existing lifecycle fixture. This changes its nominal PASS to BLOCKED
before the PhaseA2 Lean command, independently of unfinished area plugins.

`scan_proof` finds 130 public theorem declarations; the wrapper consequently
appends 130 audits. The strict inventory sees 132 declaration forms and raises
`VERIFIER_NOT_RUN: unsupported theorem declaration syntax`. A real-file proof
build probe hit the same blocker after compiling the first two dependencies.
The one-public-theorem PhaseA2 fixture in the harness tests does not cover this.

Smallest fix: give this explicitly registered dependency an inventory/audit path
that handles its two private declarations and checks their actual Lean-resolved
names, while retaining strict completeness and axiom checks. Add a regression
using the actual unchanged file and then compile its generated audited copy.
Do not globally remove the unsupported-form guard or edit production/theorem
semantics to satisfy the scanner. This is separate from the already fixed
`mutual` scope issue.

### H3 [P2]: The declared JDK 17 boundary is recorded but not enforced

Location: [third Commands.run](/home/augustus/ACGN/scripts/run_third_obligation_repairs.py:109),
[inherited version recording](/home/augustus/ACGN/scripts/run_next_obligation_repairs.py:768),
and [declared TCB](/home/augustus/ACGN/docs/obligation-repair/third-five/closure-config.json:292).

Affected claims: all five phases' frozen verifier/dependency boundary. Novel
evidence: change only the mocked Java/Javac version responses to 21.0.1; retain
the existing otherwise successful two-build lifecycle. Observed: VERIFIED,
five passed claims, and report environment explicitly identifying Java/Javac 21
while trusted dependencies still say `javac/JVM 17`. The intended transition
is PASS to BLOCKED/UNDECLARED_DEPENDENCY for that undeclared environment.

`--release 17` selects Java source/bytecode compatibility; it does not constrain
the running compiler or JVM to version 17. This finding does not allege Java
21 produces wrong results, only that the report certifies outside its stated TCB.

Smallest fix: validate both version-command outputs as major version 17 in the
private wrapper before starting tests/builds, with mismatched and unparseable
outputs blocking. Keep the inherited source and declared TCB unchanged.

## Exact Reproductions

Run the following from `/tmp` using the displayed absolute PYTHONPATH. Running
an inline `<stdin>` module from inside the input repository instead triggers
the unrelated imported-verifier guard before the targeted lifecycle stage.
The fixture helpers write only temporary directories, not repository files.
The real Lean negative probe requires the already installed offline pin.

```sh
cd /tmp
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=/home/augustus/ACGN/scripts python3 - <<'PY'
from pathlib import Path
from types import SimpleNamespace
import hashlib
import json
from test_third_obligation_repairs import LifecycleTests, REAL_RUN, replay, write

ROOT = Path('/home/augustus/ACGN')
LEAN = Path.home() / '.elan/toolchains/leanprover--lean4---v4.33.0/bin/lean'
for case in ('H1-java', 'H1-lean', 'H2-dependency', 'H3-jdk'):
    t = LifecycleTests()
    t.setUp()
    try:
        if case == 'H1-lean':
            path = t.root / 'scripts' / replay.AREAS[0]['plugin']
            source = path.read_text()
            old = repr('example : False := by decide\n')
            new = repr('import MissingThirdFiveReviewDependency\n'
                       'example : False := by decide\n')
            assert source.count(old) == 1
            write(path, source.replace(old, new))
        if case == 'H2-dependency':
            relative = t.runner.FORMAL / 'PhaseA2DependentChains.lean'
            (t.root / relative).write_bytes((ROOT / relative).read_bytes())

        def command(argv, **kwargs):
            cwd = Path(kwargs['cwd'])
            source_control = (argv[0] == 'java'
                and replay.AREAS[0]['extractor'] in argv
                and 'mutated' in (cwd / 'src/Example.java').read_text())
            if case == 'H1-java' and source_control:
                return REAL_RUN(argv, **kwargs)
            if case == 'H1-lean' and 'controls' in cwd.parts and cwd.name == 'call-wrong':
                return REAL_RUN([str(LEAN), *argv[1:]], **kwargs)
            if case == 'H3-jdk' and argv[-1] == '-version':
                kwargs['stdout'].write('javac 21.0.1\n' if argv[0] == 'javac'
                                       else 'openjdk version "21.0.1"\n')
                return SimpleNamespace(returncode=0)
            return t.fake_command(argv, **kwargs)

        exit_code, report = t.execute(command)
        print(json.dumps(dict(case=case, exit=exit_code, status=report['status'],
            claims=report['claimCounts'], errors=report['errors'],
            inputRootHash=report['inputRootHash'],
            reportSha256=hashlib.sha256((t.output/'report.json').read_bytes()).hexdigest())))
        for c in report['commands']:
            if c.get('expectedRejection') and 'call-' in c['id']:
                print(c['id'], c['status'], c['exitCode'],
                      (t.output / c['log']).read_text().strip())
    finally:
        t.doCleanups()
PY
```

Observed exits/statuses: H1-java `0/VERIFIED`, H1-lean `0/VERIFIED`,
H2-dependency `1/BLOCKED`, H3-jdk `0/VERIFIED`. H1/H3 had 5/5 passed claims;
H2 had 0/5. Synthetic fixture roots can change as workers update copied scripts;
the preserved manifests below identify the exact executed bytes. No mock
report may be reused as evidence for the real repair claims.

## Preserved Evidence

These are unedited engine outputs under temporary fixture roots, retained for
main's inspection. Each directory contains `input-manifest.json`, raw command
logs, `report.json`, and whatever build evidence that run reached.

| Probe | Evidence Directory | SHA-256 of report.json |
| --- | --- | --- |
| Nominal mock lifecycle | `/tmp/tmpz23fqugv/evidence` | `37d937312e5d01630ecc64ecbf73598f75282a3460bcf9cb4f8bdf7de36ef8ca` |
| H1 real Java launcher | `/tmp/tmp5gz841te/evidence` | `914214579180e86824f29923b67703709e0336b7be214c39b7a4b16008194627` |
| H1 real Lean import failure | `/tmp/tmpsw_o806e/evidence` | `07285535337799c48a811e08b10f80a93191ee6aad145429fbe494f723426df5` |
| H2 actual PhaseA2 dependency | `/tmp/tmpih08cm1o/evidence` | `c8101699e5992dd4dcc3f120389610a2fc4d99119693cfd5b597cfa6ebd66fd9` |
| H3 simulated JDK 21 | `/tmp/tmp65jyixi6/evidence` | `560cea61e0734b63bd9f133eade14566fe5609439d024b57b5146b189a8ca493` |

Nominal/H1-Java/H3 input root:
`5ef69ff296dae5e801c966b11599140c93183ddb37bce2a899333bd9b93cb75d`;
closure ID `third-five-v1-5ef69ff296dae5e8`.
H1-Lean input root:
`6418f7681687bc10f68f75a2e762dfbe3e3dad964400a974f3b5dbd3130c33bc`;
closure ID `third-five-v1-6418f7681687bc10`.
H2 input root:
`ed1eb3210b558f5690a057dc81d8f43fca1ca1d708f15779f89fcca52fa2af40`;
closure ID `third-five-v1-ed1eb3210b558f56`.

H1 Java control logs, both builds:
`dc1d558b267c8848f3e773b0677c493900705843ab90aff1c2a05d39b8a86ea0`.
H1 Lean build1 control log:
`46bf93c4b1648ae2bcac6295cd904e852c428cfada0c3d082283aab46a97aaf0`.
H2 unchanged PhaseA2 source:
`06ec3fc185582f02dc578d74ce9f78002686a90fa19f48ce253b426475e1e4e8`;
generated 130-audit copy:
`76348ff916510b15a47b89293b52d9066deaeaf5fa2d9cbda390a14043a9581c`.

## Checks That Passed

- `PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_third_obligation_repairs.py -v`:
  initially 25 tests, then **26 passed** after main's mutual-scope repair,
  including actual offline Lean smoke compilation and negative rejection.
- `PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_third_registry_replays.py -v`:
  **9 passed**. This is encoder testing, not registry semantic closure.
- Separate normal script invocations of `test_next_obligation_repairs.py` and
  `test_next_obligation_replays.py`: **33 + 7 passed**. An exploratory combined
  unittest process instead produced 12 failures/1 error because its imported
  real old plugin conflicts with the lifecycle's intentionally replaced plugin.
  The harness uses separate subprocesses, so that unsupported combined test
  invocation is not a third-five blocker.
- Parent mappings and predicates reject weakening. Original parent hashes:
  P1-06 `30fb21fcb2a524cc57aa6a240c4380ce349da552b012527be9e41ff988e810f9`;
  P1-09 `88fab51f179dd66df7b0703a9e3d93dac32ffde6432e699709e6ce3ab9bb02d3`;
  P1-16 `2ff9bdd7b3b7112086c0a821d74da9c49a16620a39e6ab62f8b348e4a8d6e052`;
  P2-19 `19ae22028dc1c50a3f7b92d54a236e8696c1b389ef204e6c5ae764cdab60a354`;
  A2-04 `e5ed1e70cefbc417e2046ae878201b4c371f9e2223ed11f91e371d4658541e3d`.
- Private engine namespaces/defaults and counted AST adaptation remain isolated;
  unsupported engine hash/adaptation counts block. The new single regex literal
  adds `mutual` scope tracking without modifying the old module or its source.
  Actual CALL inventory passed with five mutual blocks and 22 audited theorems
  at source SHA `543009c35024c6030096e8687ee520df27c73d7467a6abbd552beba531dfc73d`.
  A later worker revision had 23 and also inventoried successfully. These are
  scanner results, not claims about theorems or final area freeze.
- The no-.git tar/unpack lifecycle test passed using real deterministic Git
  commits only in the two TEST_ONLY snapshots. Nominal preserved builds have
  equal fixture commit `02ec91e51d8f973d00a75d20422fbfbfcf8a3d02`, with subject
  `TEST_ONLY frozen closure inputs`. This supplies local test provenance, not
  workspace/release provenance or certificate/publication authority.
- Nominal mock report bindings were independently rechecked: 51 manifest files,
  78 command records, all three area suite commands, nine proof/replay inventory
  entries per build, and 27 identical artifacts per build. Recomputed canonical
  root, command-log hashes, snapshot hashes, artifact/evidence hashes, fixture
  commits, and deterministic metadata agreed. Java/Lean artifacts in this
  lifecycle are synthetic; the real Lean smoke test is separate.
- Missing/duplicate observations, namespace collisions, missing control families,
  plugin crashes, source restoration, mutated notes/plugins, artifact drift,
  omitted second build, and evidence overwrite attempts fail closed in tests.
  Additional probes made the registry area suite exit 1 and 2: respectively
  BLOCKED and INFRASTRUCTURE_FAILURE with zero passed claims. Area suites run,
  not just enter the manifest; the driver is excluded from recursive discovery.
- Missing pinned elan installation fails before invocation; explicit pin
  overrides absent/conflicting defaults. No install/download was used. Offline
  behavior is an execution/TCB policy, not an OS network sandbox.
- Explicit area plugins/tests/notes and relevant inherited source/verifier inputs
  are included; package README/reviews/reports/evidence/incident copies do not
  change the fixture manifest. Adding this review is not a circular input.

## Authority And Boundary

No additional semantic-authority or ledger overclaim was found in the reviewed
configuration/harness notes. They distinguish model/replay PROVED, finite Java
TESTED, mappings/hashes/provenance CHECKED, source interpretation and tooling
TRUSTED, and broader Java/parser/corpus claims OUT_OF_SCOPE. Original parents
remain PARTIAL/DIRECT in the unchanged ledger; the repair scopes explicitly do
not automatically discharge them. H1 is the concrete improper evidence
promotion found here. This review does not independently validate each area
encoder's semantic correspondence or certify the completed CALL/JOIN controls.

`git diff --exit-code HEAD` was clean for the v2.13 engine, supporting bounded
and submission runners, old driver/plugin tests, original matrix, claim ledger,
and assurance scope. Other workers' preexisting/new changes were left alone.
Relevant original hashes: matrix
`eb628f64e11fb4c139d481803b60975a1ca344fa45109f3ea98c6be06e3109bb`;
claim ledger `6e4af2af2dde06037d71d7c51ee6c9ee885b2fcff417eb1d8c60cb96165b2071`;
assurance scope `35af1f85302ac791de4ec1fa2136ee97f009123b330bf7c67c464f7a97670b58`.

## Reviewed Revisions

| File | SHA-256 at review handoff |
| --- | --- |
| `scripts/run_third_obligation_repairs.py` | `c859a49c22a383aa00ac7a1be827b85bbd2798236d722ddc36f4120d2bf00b32` |
| `scripts/third_obligation_replays.py` | `79b9d7cf0e69c2dff34ed0630baf7b5ca343b29dcd949d71f8b3095a166cd025` |
| `scripts/test_third_obligation_repairs.py` | `72e4048c0c3000e997409a26518404306574710b7b51b25d4ab442e13504e0d3` |
| `docs/obligation-repair/third-five/closure-config.json` | `91071acb845a2252eaa267d67b84439b1383883fac151b5dd94a3fbdb1b3a667` |
| `docs/obligation-repair/third-five/harness-notes.md` | `1b639fa0f78517027cb0bc2dba48d4b4b0c3bedeb4657f69b7847657435591be` |
| `scripts/run_next_obligation_repairs.py` | `d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55` |
| `scripts/run_bounded_obligation_repairs.py` | `7c24c0f4ab49ed68777a7261ad58a15e3c01ac5b64f34f84f363186a2b0bcb59` |
| `scripts/run_submission_container_closure.py` | `1cb237fdf9e59f021a3906375b43eed68697d0ae1d9f5eae7f7fb9fe2acba528` |

Initial pre-mutual wrapper/test hashes were
`090cf50312cc944020b3a44bbe35dcae76fd396470c4f81ee1c190f9c7077271` and
`a482452e5b96d9afde3a9b356d00ce7b152f4555cac7c4743ec9a40b941f8ae6`.
The initial notes hash was
`8476937e254855881bbac1055927d6a0278921c590460a90005912ce5e022e29`;
the final notes add the mutual repair explanation. No final package root was
frozen during concurrent integration.

Recheck is limited to H1-H3 after main repairs them, followed by main's final
frozen two-build integration run with the completed area plugins. A future
review PASS means only this bounded reviewed surface, never whole-Java or a
new global-theory closure.

## Targeted Recheck R1

2026-09-08, after main's third-only diagnostic, private-inventory, and version
patches. The initial review above is preserved unchanged. **Current bounded
disposition: BLOCKED on the remaining H1 mixed-output cases; H2 and H3 resolved.**
This recheck adds no claim or obligation and does not execute full closure.

Tested wrapper SHA-256:
`39dd022af8da9f298e18112fa118b1fb33b1a192c8f7af52435d3194c8016881`.
Test suite SHA-256:
`ea1f0d6bff43e7aea5e2ac4240d97f59fe1ac707cdbfac5ca1ca70dc4f38cef6`.
Notes at recheck handoff:
`7c74b497e0f39177408c0762e68ee1cf2cfac794a54ae7e6be1923bbb877f577`.
Aggregator, config, and base engine retain their previously recorded hashes.
`python3 scripts/test_third_obligation_repairs.py -v` passed **31 tests**;
the earlier diagnostic-only revision passed 28. No tests were skipped.

### H1: Original Cases Fixed; Mixed Diagnostics Still Pass

The original actual JVM loader failure and actual Lean missing-import failure
now return `2/INFRASTRUCTURE_FAILURE`, with the affected command record also
INFRASTRUCTURE_FAILURE and zero passed claims. Source-area prefix mismatches,
plain syntax errors, and false-proposition errors mixed with a normal Lean
`unknown identifier` diagnostic block. These portions of H1 are repaired.

However, [check_rejection](/home/augustus/ACGN/scripts/run_third_obligation_repairs.py:59)
still accepts two same-gap counterexamples:

1. Real pinned Lean compiles a mock control containing
   `example : False := by decide` followed by
   `#eval (panic! "review-control-runtime-failure" : Nat)`. It returns 1 with
   the expected false-proposition diagnostic followed by a real `PANIC` and
   backtrace. The helper's known-infrastructure expression does not include
   that diagnostic, and its false-proposition search accepts the entire tail.
   In the mocked lifecycle both real Lean control executions receive PASS and
   all five claims receive VERIFIED.
2. Append `Example.java:1: error: cannot find symbol` after the fixture's valid
   CALL `IllegalArgumentException: UNMODELED_SOURCE:` first line. The source
   branch only checks the first line and ignores the unrelated compiler error.
   Both source controls and the full mocked lifecycle still pass.

These are result-classification probes, not claims that actual area control
programs contain a panic or currently emit mixed source errors. They exercise
the already required H1 rule that mixed/unrelated failures cannot support PASS.
The first is actual Lean output, not a fabricated diagnostic transcript.

Smallest remaining fix: require the complete control transcript to satisfy the
registered rejection contract. Detect runtime panic/resource failures as
infrastructure even when another expected rejection is present. Reject an
unrelated compiler diagnostic anywhere in a source-control transcript, not just
before its first line. Preserve the matching non-PASS command/report state.

A related helper edge, not an additional package blocker: two legitimate
false-`decide` diagnostics are rejected. With `re.S`, the lookahead's `^.*?`
crosses lines and stops the first captured error before its `False/is false`
body whenever another error follows. Real Lean on two consecutive
`example : False := by decide` commands reproduces this. Use line-bounded
diagnostic headers to partition complete multiline bodies; this also makes
the intended all-errors check meaningful. No current control is alleged to
require multiple failed propositions.

Exact lifecycle reproduction of the remaining H1 cases:

```sh
cd /tmp
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=/home/augustus/ACGN/scripts python3 - <<'PY'
from pathlib import Path
import json
from test_third_obligation_repairs import LifecycleTests, REAL_RUN, replay, write

lean = Path.home() / '.elan/toolchains/leanprover--lean4---v4.33.0/bin/lean'
for case in ('panic', 'mixed-source'):
    t = LifecycleTests()
    t.setUp()
    try:
        if case == 'panic':
            path = t.root / 'scripts' / replay.AREAS[0]['plugin']
            source = path.read_text()
            old = repr('example : False := by decide\n')
            new = repr('example : False := by decide\n'
                       '#eval (panic! "review-control-runtime-failure" : Nat)\n')
            assert source.count(old) == 1
            write(path, source.replace(old, new))

        def command(argv, **kwargs):
            cwd = Path(kwargs['cwd'])
            if case == 'panic' and 'controls' in cwd.parts and cwd.name == 'call-wrong':
                return REAL_RUN([str(lean), *argv[1:]], **kwargs)
            result = t.fake_command(argv, **kwargs)
            if (case == 'mixed-source' and argv[0] == 'java'
                    and replay.AREAS[0]['extractor'] in argv
                    and 'mutated' in (cwd / 'src/Example.java').read_text()):
                kwargs['stdout'].write('Example.java:1: error: cannot find symbol\n')
            return result

        code, report = t.execute(command)
        print(json.dumps(dict(case=case, exit=code, status=report['status'],
                              claims=report['claimCounts'], errors=report['errors'])))
    finally:
        t.doCleanups()
PY
```

Observed for both: exit 0, status VERIFIED, five passed claims, empty errors.
The generated reports remain synthetic lifecycle evidence only.

### H2: Resolved By Real Audited Builds

The inventory-only virtual view recognizes both private declarations, while
the compiled file retains the unchanged original source as an exact byte
prefix and only appends audits. The adaptation is restricted to the registered
generated-audit dependency; the inherited module/file is not changed.

Two fresh temporary formal directories were independently inventoried and
compiled using the installed Lean 4.33.0 binary with explicit pinned environment.
Both compilations exited 0; the unchanged strict `check_proof_log` accepted all
132 names, including:

```text
_private.PhaseA2DependentChains.0.ACGN.Section3.PhaseA2.productionParserCapability
_private.PhaseA2DependentChains.0.ACGN.Section3.PhaseA2.foreignParserCapability
```

Evidence: `/tmp/acgn-third-harness-h2-recheck-z3nbg8j3/build1/formal` and
`/tmp/acgn-third-harness-h2-recheck-z3nbg8j3/build2/formal`.
Both builds have the following identical SHA-256 values:

| Artifact | SHA-256 |
| --- | --- |
| `PhaseA2DependentChains.lean`, original source prefix | `06ec3fc185582f02dc578d74ce9f78002686a90fa19f48ce253b426475e1e4e8` |
| `PhaseA2DependentChains.lean`, generated audited copy | `84f92684a1551476d0487b7549c3e658b8afa5e211624abdf79e81fd091ebcbe` |
| `PhaseA2DependentChains.olean` | `dd82e8f457a35b1b128ff35bfe71cfe416ab64b2aa11291065e2d5d9d497c1e3` |
| `axioms.log` | `5d07c854830b52af36e326e21900163fd62bd34d1474c017c59feb37d63fb22b` |

The actual-file substitution from the original H2 lifecycle reproduction also
now completes both mocked builds. The suite checks that removing a private
audit blocks. This resolves the registered dependency/inventory gap, not any
additional theorem semantics or full-package closure.

### H3: Resolved Before Driver Execution

The private Commands wrapper gates both `java-version` and `javac-version` and
reclassifies a failed gate's command record as BLOCKED. The suite verifies
wrong JVM, wrong compiler, and unparseable JVM output. An independent
compiler-only `javac 21.0.1` probe, retaining the nominal Java 17 response,
now returns `1/BLOCKED`, `UNDECLARED_DEPENDENCY: JDK 17 required: javac-version`,
zero passed claims, and no driver/area/build commands. Thus H3 does not rely
on a later area extractor happening to reject another JVM version.

### R1 Bound Evidence

All preserved files below are unedited engine outputs. Canonical roots and
verifier hashes are in their respective manifests/reports; they differ from
the initial review and cannot inherit its evidence.

| Probe | Evidence Directory | SHA-256 of report.json |
| --- | --- | --- |
| H1 original real JVM loader | `/tmp/tmp3ou3u03j/evidence` | `b50fc834918f07c29387f14a17b3621441173ac59e1d0cdd9d938c59c958d130` |
| H1 original real Lean missing import | `/tmp/tmpw_rgnr_h/evidence` | `00df36d527298ada5a04b6820fded3b446281f03a962755bd5fbfcef895d7e03` |
| H1 real Lean mixed panic | `/tmp/tmpswmqhhiu/evidence` | `d809840a6f992bba068b09dc65ddd8f2931ae667e6303db9efdc9a6a0808a097` |
| H1 mixed source diagnostic | `/tmp/tmpbh_vc2e0/evidence` | `90fce3403c5709f8fe8c37a35944eb7fa092bdba2d52e6278f6027784fd95815` |
| H2 actual dependency in mock lifecycle | `/tmp/tmpienq6pce/evidence` | `7b7af1ad831f6e0631767ea9f4341eab26f32e1a9e0b98502257a48871940c26` |
| H3 compiler-only version mismatch | `/tmp/tmpqbf2sucp/evidence` | `ab4d9a1fe08ac3c869e7ca0afad646157cdebbab82799957283fba833a860837` |

R1 base fixture root (JVM loader, mixed source, compiler-only mismatch):
`502b7e6f7dd48546567dde0d937be5f98ddabc961d200471cf6de77d25ba7f72`.
Missing-import fixture root:
`5bfc2f35a5ba4556f64d5e8bbb49119c3a3d756eadfb9953873ed6667fd9251a`.
Panic fixture root:
`9fc55d6074076760f42874d15e659bdef88ceb6d03923702c29b652dead3652f`.
Actual-dependency fixture root:
`5e148f4c08139ba16c26f9465173ea1b7ab50ca88c0c0618376caabbfbab52f1`.

`git diff --exit-code HEAD` still reports no change to the original engine,
supporting runners, or `PhaseA2DependentChains.lean`. Only this review document
was changed by the reviewer. The remaining recheck is H1's already declared
diagnostic contract, followed by main's final frozen integration run.

## Targeted Recheck R2: Bounded PASS

2026-09-08. **Current review disposition: PASS for the bounded reviewed harness
surface. H1, H2, and H3 are resolved; no finding remains open within this
targeted recheck.** This supersedes the review dispositions above, while
preserving their findings, reproductions, and historical hashes verbatim.
Review PASS is not a package VERIFIED result, a parent-ledger discharge, or
whole-Java/theory closure. Main's fresh frozen integration run remains required.

This recheck was limited to original H1 and its R1 mixed-output counterexamples.
AST comparison confirmed that the H2 dependency-inventory and H3 version-gate
functions are unchanged from the R1 repairs; their bounded resolutions stand.
No production behavior, area semantics, or new obligation was examined.

### H1 Resolution

The line-based parser now consumes complete false-proposition blocks instead
of searching across multiline diagnostic headers. The source branch checks
its entire tail against registered hash-row/stack-line syntax. Known panic,
memory, stack, loader, and import failures are checked before either acceptance
branch, and command metadata is reclassified consistently with the terminal
failure state.

The exact original/R1 probes were rerun through the lifecycle with actual JVM
or pinned Lean execution for the indicated control, while other compilation
and area observations remained explicit mocks:

| Probe | Engine Exit / State | Target Command | Passed Claims |
| --- | --- | --- | --- |
| Actual JVM missing extractor class | 2 / INFRASTRUCTURE_FAILURE | INFRASTRUCTURE_FAILURE | 0/5 |
| Actual Lean missing import | 2 / INFRASTRUCTURE_FAILURE | INFRASTRUCTURE_FAILURE | 0/5 |
| Actual Lean false proposition followed by `panic!` | 2 / INFRASTRUCTURE_FAILURE | INFRASTRUCTURE_FAILURE | 0/5 |
| Expected CALL source error followed by unrelated compiler error | 1 / BLOCKED | BLOCKED | 0/5 |
| Two actual Lean false-proposition errors | 0 / VERIFIED, synthetic lifecycle only | PASS in both builds | 5/5 synthetic |

Every rejected control's raw process exit remained 1. Thus these results test
the repaired diagnostic/evidence transition rather than a different process
exit. Command log hashes, input-root bindings, and verifier-set bindings were
checked against each generated report. The successful double-false probe also
confirms the R1 multiline-regex edge is fixed: both complete legitimate errors
are accepted, with no unrelated diagnostics.

`PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_third_obligation_repairs.py -v`
passed **33 tests**, including the real Lean panic lifecycle, mixed source
failure, double-false helper check, and existing H2/H3 regressions. No tests
were skipped. The corrected current test fixture no longer contains the
unregistered stray `x` row. The preserved probe manifests below all contain
the same corrected current test-file hash, not the superseded fixture.

### R2 Revisions And Evidence

| Reviewed File | SHA-256 |
| --- | --- |
| `scripts/run_third_obligation_repairs.py` | `e1e7d7b41625e4ba90e24aa815ee6cf1c441066f951a0713d75d280d4b9a6e83` |
| `scripts/test_third_obligation_repairs.py` | `907562bbf4cb581b0cba8b6fabc3f30ca0cb48c89cea40298228337232d13bff` |
| `docs/obligation-repair/third-five/harness-notes.md`, handoff binding | `d7d0c2b139eb96f722216b6736017951f751273cd370effbfd05620365460347` |
| `scripts/run_next_obligation_repairs.py`, unchanged | `d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55` |

Aggregator and config retain their original recorded hashes. Each preserved
directory contains unedited machine reports, manifests, and raw command logs:

| Probe | Evidence Directory | SHA-256 of report.json |
| --- | --- | --- |
| Actual JVM loader failure | `/tmp/tmpqtmvc1a8/evidence` | `9562319e188690b54029a3b6289a1f2ae693294fe8fedc225b6702a985c0d1db` |
| Actual Lean missing import | `/tmp/tmpdtcqhb2w/evidence` | `f60354cc63cafd8cb4f478222b92be0f946ed17a8694731cedc2cc3cb7c89a3e` |
| Actual Lean panic | `/tmp/tmplj_6s29w/evidence` | `e926d34adc3af5577c04b2c06d7e39d6dce89b55c83f08db08c72a85491b97db` |
| Mixed source error | `/tmp/tmp_t4g54lq/evidence` | `334dcb025892c7d48a8f0e0fe752d4338995727f99d42e2e0c8f64652fce64cc` |
| Two actual false propositions | `/tmp/tmpfotcatkk/evidence` | `668496ad492718e6c56011f41406835b1fe447159fc1849499f74436e1a4dc6e` |

Canonical fixture roots, respectively:

- JVM loader and mixed source:
  `e73ca3e0e1ec6dd701f818bbea7047dee3bd2d6023404404debde05713a8a15a`.
- Missing import:
  `663fef4abce2cf0d1d254c82a794f78464759080202f38a2f7a5f8ead6936670`.
- Real panic:
  `ff2de8064251d01e44b28930eee55808a175ce0c32815563c262f8355cc3f1ee`.
- Two false propositions:
  `30639e1301e6941d785451f0bc1da031f75fcd0552a5e939abc7f391edf1009a`.

The double-false control logs in both builds have SHA-256
`152ec13b50ccb5a11797059b4f614e77a511dbe92558665b45760f922cca7fed`.
The actual panic control log has SHA-256
`53115a8b2314f3e14e219b05856a6bf790a5dee56f78754787267f7266db2c2a`.
These are bounded regression artifacts, never claim-discharge evidence for
the real repairs. Earlier stopped/failed final candidates were not modified,
reinterpreted, or promoted by this review. Only this excluded review document
was edited. The requested same-gap review is complete.

### R2 Closeout Scope

**Bounded PASS**, limited to the already found H1 cases: actual Lean panic
cannot pass; mixed source diagnostics block; multiple legitimate false
propositions remain accepted. H2/H3 retain their R1 resolutions. The current
33-test suite passed, including actual Lean PANIC execution. No additional
fresh review was performed for this closeout.

- Runner SHA-256: `e1e7d7b41625e4ba90e24aa815ee6cf1c441066f951a0713d75d280d4b9a6e83`.
- Test SHA-256: `907562bbf4cb581b0cba8b6fabc3f30ca0cb48c89cea40298228337232d13bff`.

Final3 is outside this review closeout and was neither inspected nor modified.
Package closure and v2.14 publication require main's final bound machine
report; this review PASS does not substitute for that result.
