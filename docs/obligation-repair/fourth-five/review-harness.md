# Independent v2.15 Harness Review

**Verdict: PASS, bounded harness review only.** No concrete supported false-PASS,
omitted-work, stale-evidence, hidden-synthetic-evidence, failure-classification,
or reproducibility defect was established in the reviewed revision. There are
no validated defects requiring a targeted recheck.

This is not a VERIFIED closure report or discharge of P2-20, P2-18, A2-07,
A2-11, or P3-03. Area agents were still implementing. Missing area files were
not counted as defects, and neither area semantics nor a complete closure run
was audited. No implementation files were modified.

## Boundary and Revision

Reviewed on 2026-09-08 using the mechanical-closure-verification skill and its
normative `references/closure-protocol.md`, in audit mode, without internet.
The review is limited to the following five files and their integration with
the unchanged, byte-pinned v2.13 engine and v2.14 dispatcher:

| File | SHA-256 |
| --- | --- |
| `scripts/run_fourth_obligation_repairs.py` | `da67171f7bf453398f028a3ccc866da02f6422d87cf9059a46a3cf1fd090d371` |
| `scripts/fourth_obligation_replays.py` | `07302a01dd29a21101f031e4c821ae00bd19dabecb205b3bdcb442a206ce0a54` |
| `scripts/test_fourth_obligation_repairs.py` | `9986b451213b2df0af9df73af65dd65450b34f2047b7a8a5fba9e4dd2faf624d` |
| `docs/obligation-repair/fourth-five/closure-config.json` | `0695e99e9117a81c4e7b9e161a146ebbd556ac2a94867ac9c76da79c092898cc` |
| `docs/obligation-repair/fourth-five/harness-notes.md` | `66ab130653c17ff0d0105079418a093634a8e1a165cb3813ec4aa87fb8bb973c` |

The canonical five-file review manifest hash is
`401dd42003addfcb24b131084c17b1657468ee45327de270aaab5961fb32b045`.
It is **not** the full closure input root. All five hashes remained unchanged
during the recorded checks. Both inherited file hashes matched their pins:

- `scripts/run_next_obligation_repairs.py`: `d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55`.
- `scripts/third_obligation_replays.py`: `79b9d7cf0e69c2dff34ed0630baf7b5ca343b29dcd949d71f8b3095a166cd025`.

## Integration Checks

All five frozen claims share the following reviewed infrastructure. Each check
was admitted only for its potential to change a required PASS to BLOCK; no
general engine hardening or repeated speculative discovery was performed.

| Surface | Source anchor | Bounded result |
| --- | --- | --- |
| Original parent hashes and required work | `scripts/run_fourth_obligation_repairs.py:153` | Fixed parents, predicates, proof/replay mappings, required area trace tests, extractor mapping and required inputs are validated; the 17-test suite passes. |
| Area tests are scheduled | `scripts/run_fourth_obligation_repairs.py:147` | The inherited plugin-test command triggers all three required area test drivers. This path was inspected, not run against unfinished area files. |
| Snapshot and evidence integration | `scripts/run_fourth_obligation_repairs.py:96` | Counted literal adaptation preserves the inherited input, snapshot, import, log and artifact checks; explicit inputs include the new harness, dispatcher, encoders, tests and notes. No weakening was identified at these adaptation sites. |
| Two-build comparison | `scripts/run_fourth_obligation_repairs.py:130` | Existing build execution/comparison remains inherited; `scripts/test_fourth_obligation_repairs.py:142` exercises required comparison fields. Actual two-build determinism was not executed here. |
| Dispatcher delegation | `scripts/fourth_obligation_replays.py:39` | Pinned dispatcher receives only the new table and namespace label. Its existing nonempty-family and mapping checks remain in use. |
| Synthetic evidence boundary | `scripts/test_fourth_obligation_repairs.py:33` | Synthetic plugins are confined to orchestration tests; the runtime adapter delegates to real area plugins. No substitute successful replay was found in the five reviewed files. |
| Rejection classification | `scripts/run_fourth_obligation_repairs.py:57` | Real subprocess checks below confirm the new diagnostic hook distinguishes the tested semantic, invalid-witness and infrastructure outcomes. |
| Mutual-scope inventory | `scripts/run_fourth_obligation_repairs.py:105` | A real Lean mutual-scope fixture compiles and its qualified theorem inventory matches the axiom log. |

The inherited integration anchors are `scripts/run_next_obligation_repairs.py:273`
(inputs), `:502` (import binding), `:541` (build execution), `:709` (comparison),
and `:781` (final evidence checks), plus `scripts/third_obligation_replays.py:59`
(replay census), `:80` (negative families), and `:89` (source controls).
These are integration references, not a new audit of those engines.

## Independent Mechanical Evidence

Raw witnesses, command logs and the machine-readable result are retained at
`/tmp/acgn-fourth-harness-review-20260908/`. Reproduction command:

```sh
python3 -B /tmp/acgn-fourth-harness-review-20260908/probe.py
```

The probe uses actual subprocesses through the new `Commands` subclass, with
installed Lean 4.33.0 and JVM 17, and no patched process outcomes. Fixtures and
the `REVIEW-ONLY-NOT-A-CLOSURE` command records are explicitly synthetic harness
tests, never transition/certificate evidence for the five target claims.

| Witness | Exit | Observed command state | Novel evidence |
| --- | --- | --- | --- |
| `False.lean`: `example : False := by decide` | 1 | PASS as an expected rejection | Real Lean false-proposition diagnostic accepted by the new hook. |
| `Syntax.lean`: unknown tactic | 1 | BLOCKED / VERIFIER_FAILURE | Real unrelated diagnostic cannot satisfy semantic rejection. |
| `Missing.lean`: unavailable imported module | 1 | INFRASTRUCTURE_FAILURE | Lean module-loading failure is not mislabeled as a valid rejection. |
| Missing JVM main class | 1 | INFRASTRUCTURE_FAILURE | JVM loader failure is not mislabeled as a valid source rejection. |
| `Mutual.lean` | 0 | PASS | Kernel execution and axiom audit agree on `HarnessReview.valid`. |

These shared-harness checks concern P2-20, P2-18, A2-07, A2-11 and P3-03;
the area labels in probe command names do not imply area evidence was run.
`driver-tests.log` also records all 17 harness tests passing.

The authoritative result for these **review checks only** is
`review-checks.json`, SHA-256
`87d05a07670c7eb4610674fa3494ba0fd5d4528f63bb1af4169e3ccb1f1cec01`.
The probe implementation hash is
`0b8fed7d38ce6ec78d506ab3b0a4913630292a6d40cd606b44b197a1acb27949`.
The result contains per-command log hashes, observed exits/states, the review
manifest, and an unchanged-input check. No counterexample survived these
bounded checks. There are no defect witnesses to hand off.

## Trust and Stop

- **TESTED:** the 17 harness tests and five independent checks above.
- **CHECKED:** the new adapters/configuration and their pinned integration paths.
- **TRUSTED:** Python and its standard library, the installed Lean kernel and
  toolchain, JVM, SHA-256, filesystem, OS and hardware; inherited engine behavior
  outside the named integration paths. Area encoders/extractors remain declared
  tested TCB components, not proved implementation correspondence.
- **OUT_OF_SCOPE:** unfinished area implementations, actual claim witnesses,
  universal Java/proof correspondence, source-control semantic adequacy, a full
  closure input root, completed provenance, and actual two-clean-build results.

Target claims in scope: five. Claims discharged by this review: zero. Full
clean builds executed: zero. Full closure determinism, correspondence,
provenance and witness validity: not evaluated. This bounded PASS applies only
to the reviewed hashes under the stated trust; it is not universal correctness
or assurance for future edits. Stop after this report. Any subsequent recheck
should be targeted to a validated repair, not a general discovery expansion.
