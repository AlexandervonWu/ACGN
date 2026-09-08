# Third Five Obligation Repairs

This package addresses P1-06, P1-09, P1-16, P2-19 and A2-04 without changing
their original statements or hashes. It continues the v2.13 assurance work,
not the experimental run or the static rewrite inventory.

## Claims

| Requirement | Intended evidence |
| --- | --- |
| P1-06 | Independent declaration/ledger arity, connected to executable resolution |
| P1-09 | Fresh occurrence allocation and consumption without reuse |
| P1-16 | Ordered CALL representation retaining repeated operands and nesting |
| P2-19 | Exact fixed-registry admission and complete profile/index binding |
| A2-04 | Arbitrary-length guarded relational JOIN reassociation |

The [CALL](call-notes.md), [JOIN](join-notes.md), and
[registry](registry-notes.md) records specify each finite conformance surface,
general theorem, implementation connection and excluded boundary. The
[harness record](harness-notes.md) specifies the fixed claim hashes, registered
verifiers, source/observation censuses, two clean builds, rejection controls,
determinism and isolated TEST_ONLY provenance.

## Reproduction

Use Java 17, Python 3 and the installed, repository-pinned Lean 4.33.0 toolchain:

```bash
python3 -B scripts/run_third_obligation_repairs.py /tmp/acgn-third-five
```

The output directory must be fresh and outside the source tree. Verification
is offline and uses two isolated builds. The old v2.13 runner remains unchanged;
the new entry point uses a hash-pinned, separately namespaced adaptation with
explicitly enumerated package/claim configuration changes.

## Verified Evidence

The [machine report](evidence/report.json) is **VERIFIED** for all five frozen
claims, in two clean builds with **1,053 identical artifacts per build**.
Input root: `4d63586625ff6c0a4f5bc923ed19ecbb377b88d2c768ea504a39b965f9393003`.
Closure ID: `third-five-v1-4d63586625ff6c0a`.

| Evidence | Per build |
| --- | ---: |
| New general Lean theorems | 74 |
| Imported theorem audits, including two private declarations | 166 |
| Generated replay propositions | 1,414 |
| Java observations across the three new tests | 10,628 |
| Java assertions across the three new tests | 18,800 |
| Compiler-resolved source objects | 51 |
| False-proposition Lean controls | 28 |
| Source-mutation rejection controls | 26 |

All 33 harness tests, 34 area encoder tests and seven compatibility encoder
tests pass. The broader bounded Java script passes all 42 test entry points
and the distance-artifact smoke. The certificate harness retains 181 verifier,
109 writer (twice), 68 inspection, 31 trust-pin and ten parsed-source PAIR
checks, with census 1 verified / 2 uncheckable / 0 rejected. The two PAIR
source hashes remain distinct. Snapshot verification checks 5,808 unchanged
files. Supporting logs, generated artifacts and hashes are in
[evidence](evidence/SHA256SUMS).

The [CALL](review-call.md), [JOIN](review-join.md), [registry](review-registry.md)
and [harness](review-harness.md) reviews record their independent bounded
checks. The harness's final R2 disposition resolves its original H1-H3 findings;
the earlier findings and failed candidates are retained in
[the incident record](incidents.md). Review opinion alone does not discharge
a claim; the frozen report binds the executed verifiers, inputs and explicit TCB.

The full matrix remains incomplete: **102 ready / 118 diagnostics**. This
package does not resolve P1-19's coordinated source-occurrence omission boundary,
the A-01 contract-registry prerequisite, or universal Java/parser refinement.
The [next five candidates](../next-candidates-v2.14.md) remain partial.

Production behavior, certificate authority, prior publication manifests,
experimental result trees and archived experiment JARs are outside this edit
scope and remain unchanged. No new experimental results are claimed.
