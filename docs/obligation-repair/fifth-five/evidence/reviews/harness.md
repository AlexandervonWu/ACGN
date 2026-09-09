# Independent v2.17 Harness Review

**Verdict: PASS / no bounded counterexample.** No concrete supported path was
established that makes the reviewed harness mark FV-P3-04, FV-P3-05, FV-P3-06,
FV-P3-12 or FV-A2-12 VERIFIED with required missing, incorrect, misbound or
mutated evidence, or promotes their finite repair scopes to universal closure.
No validated defect is being handed off for repair.

This is a bounded review result, not a VERIFIED closure report, mathematical
universal proof, or discharge of any target claim. Unfinished area files were
neither assessed nor treated as defects. No production/shared files were
edited; no commits, releases, online research or static rewrite expansion
were performed. Mechanical-closure-verification was used in audit mode.

## Reviewed Revision

Date: 2026-09-09. Only these five new files were reviewed, with the unchanged
fourth profile, next engine and third dispatcher used as integration references:

| File | SHA-256 |
| --- | --- |
| `scripts/run_fifth_obligation_repairs.py` | `bdad6f07f56699ba2e9e929b8e7ac2228bb50f82d209d12590809f0595b1d4c2` |
| `scripts/fifth_obligation_replays.py` | `c5265e9c9fc52c3f76c349f9350b2c6688d21ff75df031d5792baaae8818226f` |
| `scripts/test_fifth_obligation_repairs.py` | `f9103bf5dcb2c5140db14d8d2850ed95bb613fd17caef06cd54aeba827b3846c` |
| `docs/obligation-repair/fifth-five/closure-config.json` | `c70e832e97fa5d1d02e63af7fee9ef2cd1fc75523896ff40d21ef92b4eb2a457` |
| `docs/obligation-repair/fifth-five/harness-notes.md` | `ed416e9b4dd425fb07374ac632fe5ceb8a3c1560f423127b2d2a4cecabcb2c7a` |

Five-file canonical review manifest hash:
`76d1907c0685cbc97251428548bd79f382bfec009b4964ee9712e6b06aec50ee`.
This is **not** a full closure input root. These hashes and the reference hashes
remained unchanged during the successful probe run.

The inherited engine hash is
`d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55`;
the inherited dispatcher hash is
`79b9d7cf0e69c2dff34ed0630baf7b5ca343b29dcd949d71f8b3095a166cd025`.
Both match their explicit pins. `git diff --exit-code HEAD --` for the fourth
runner/dispatcher/config, next runner and third dispatcher returned 0. Their
complete reference manifest is retained in the machine-readable review result.

## Integration Findings

- `scripts/run_fifth_obligation_repairs.py:104`: the fourth-profile adaptation pattern is retained. Package identities, parent/area tables and rejection-family names change; the meaningful added constraint is exact scope pinning at line 171. The inherited freeze, execution, comparison and final evidence checks are not replaced.
- `scripts/run_fifth_obligation_repairs.py:161`: all five original parent hashes, IDs, bounded scopes, predicates and proof/replay mappings are required. Each phase independently requires its registered trace test, including both phases sharing the records area. All four extractor classes, source paths and trace paths are required. Removing any of the 17 required explicit inputs blocks.
- `scripts/run_fifth_obligation_repairs.py:155`: completion of the inherited plugin-test command schedules all four required area test drivers. This scheduling was inspected; unfinished area suites were not executed. The existing 17 tests exercise synthetic delegation, missing families, errors, ownership, pins and deduplication, not target claim evidence.
- `scripts/fifth_obligation_replays.py:73` and `scripts/third_obligation_replays.py:59`: private delegation retains the pinned dispatcher's exact replay-name checks, positive theorem counts, disjoint qualified namespaces, nonempty negative/source families, error propagation and per-area source-extractor binding. No successful fallback is introduced.
- `scripts/run_next_obligation_repairs.py:273`, `:646`, `:709` and `:781`: reviewed integration retains input/snapshot hashing, detection of changed positive inputs, two-build comparison and final snapshot/artifact/evidence/control/log checks before status promotion. Actual final two-build execution was not run in this review.
- `scripts/run_next_obligation_repairs.py:725` and `:828`: report interpretation expressly limits VERIFIED to the five frozen finite surfaces and denies universal correctness or automatic discharge of broader parents. The reviewed configuration and harness notes preserve that distinction. All five attempted universal scope substitutions were blocked with CLAIM_MUTATION. This review applies to the recorded configuration, not arbitrary replacement trust/exclusion prose or future configurations.

## Mechanical Checks

Reproduction, from the unchanged reviewed revision:

```sh
cd /home/augustus/ACGN
python3 -B scripts/test_fifth_obligation_repairs.py -v
python3 -B /tmp/acgn-v217-harness-checks/probe.py
```

The existing suite passed **17/17** tests, both independently and inside the
probe. The probe passed **93/93** boundary assertions: 85 expected BLOCKED
outcomes and eight expected PASS outcomes, with 11 real subprocess commands.
The 78 config mutations cover nine required fields for each of five phases,
three mapping fields for each of four extractors, omission of each required
input, one-build weakening, foreign plugin, missing extractor and missing
proof-dependency declaration. All 78 were rejected.

Novel boundary witnesses use the actual profile/engine APIs, installed Lean
4.33.0 and JDK 17.0.20, without patched process outcomes, reflective state
tampering or JVM hardening. Fixtures are explicitly review-only, not area
implementations or evidence for the five repair claims.

| Witness | Observed Result | Potential Invalidated Predicate |
| --- | --- | --- |
| Real Lean false proposition under `build1-reject-source-false` | Exit 1; expected rejection PASS | Correct classification of the new source-family Lean control |
| Real Lean false proposition plus unrelated unknown-tactic/unsolved-goal diagnostics | Exit 1; BLOCKED / VERIFIER_FAILURE | `negative-and-source-controls-exit-1`; unrelated failures cannot masquerade as registered rejection |
| A successful Lean program supplied as a negative control | Exit 0; BLOCKED / VERIFIER_FAILURE | Required rejection must actually fail |
| Real mutual-scope proof and qualified axiom audit | Exit 0; accepted | `audited-lean-proofs` |
| The same real axiom log checked against `Foreign.valid` | BLOCKED / VERIFIER_FAILURE | `bound-machine-evidence`; audit must name the inventoried theorem |
| Frozen temporary Java input changed through `mutated_source` | `check_snapshot` BLOCKED / INPUT_MUTATION | `frozen-inputs-and-verifiers` |
| Real Java fixture extractor under `build1-source-reject-source-review` | Exit 1 with registered UNMODELED_SOURCE diagnostic; accepted | New source-family source-control classification |
| Normal and exceptional source-control exits | Original snapshot restored and accepted in both cases | Mutation isolation and restoration |
| Foreign source extractor, omitted fixed TSV row, foreign replay basename | All BLOCKED | Extractor ownership, fixed census and replay correspondence |

The shared checks concern all five FV claims; label names do not imply actual
area evidence ran. An initial probe attempt stopped on Lean's input-root rule
because its positive fixture was invoked from the wrong temporary directory.
Only the review fixture's working directory was corrected. That aborted log
is preserved at `/tmp/acgn-v217-harness-checks/run-nr554p2l/`; it is not a harness
defect or target-claim failure. The complete successful run is:

`/tmp/acgn-v217-harness-checks/run-iya5_k3o/review-checks.json`

Result SHA-256:
`4d047611a46d96fb1f5f765aa06e1eb574f7bbe7db26425381bcd0e3dcc14207`.
Probe SHA-256:
`a774c68f2bb3f9e3e07c8b705c856d541201c33be6562ef7b89ecef2c9b06aa3`.
The JSON records the checked manifests, fixture hashes, all assertions, actual
command exits/states and log hashes. It is evidence for these review checks
only; its `REVIEW-ONLY-NOT-A-CLOSURE` command bindings are not closure bindings.

## Boundary and Stop

- **TESTED:** 17 existing harness tests and the 93 recorded boundary assertions.
- **CHECKED:** the five new files and named unchanged integration paths.
- **TRUSTED:** Python/standard library, installed Lean kernel/toolchain, JDK, SHA-256, filesystem, OS and hardware; inherited behavior beyond those integration paths. English trust declarations and encoders/extractors are not proved by this review.
- **OUT_OF_SCOPE:** unfinished area implementations and semantic/control adequacy, complete target witnesses, full provenance/correspondence, universal Java/parser refinement, arbitrary reflection/JVM hardening, normalization discoveries and static rewrite expansion. No new normalization discovery was established or expanded.

Target claims: five. Claims discharged: zero. Full closure builds executed:
zero. Full closure ID/input root, determinism, provenance, correspondence and
witness validity: not evaluated. There is no defect repro to hand off because
no bounded counterexample survived the checks. Stop at this bounded PASS; do
not interpret LLM review as mathematical universal proof or future-revision
assurance. Main retains ownership of integration and any later targeted fixes.
