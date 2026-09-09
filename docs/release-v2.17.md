# ACGN v2.17

This is an assurance-only follow-up to v2.16. It implements the five bounded
record and source-binding tasks proposed in
[the v2.16 candidate list](obligation-repair/next-candidates-v2.16.md).
Production canonicalization, repair metrics, reward computation, certificate
production/replay and experimental runners are unchanged.

## Repaired Obligations

| Requirement | New evidence |
| --- | --- |
| P3-04 | Complete 17-field law-record codec, independent registry reconstruction and actual KERNEL verifier outcomes |
| P3-05 | Complete flat-record decoding and recursive source, splice and application-trace reconstruction |
| P3-06 | Complete container inputs, outputs and occurrence fibers, preserving Seq order, Bag multiplicity and Set quotienting |
| P3-12 | Canonical wire grammar, Java UTF-16 table order and exact content-ID preimages |
| A2-12 | Deterministic phase/child paths, retained dependent-source content and supported provenance transitions |

The [fifth-five package](obligation-repair/fifth-five/README.md) keeps general
Lean contracts, finite Java observations, compiler-resolved source identities
and negative controls as separate evidence. Its configuration preserves the
original claim statements and hashes. The matrix uses `PROVED/DIRECT` for
these general contracts with bounded direct conformance, not universal JVM or
parser refinement. It reports **112 ready requirements and 105 diagnostics**;
the full assurance matrix remains incomplete.

The new package contains 85 general Lean theorems and 538 generated replay
propositions over 700 predeclared Java observations. Its closure requires two
isolated builds, audited proof dependencies, 96 Lean negative controls,
54 compiler-resolved source controls and matching deterministic artifacts.
The final machine-report and exact-commit CI records are the release gates;
implementation counts alone do not confer VERIFIED.

## Integration Checks

The shared bounded Java runner now explicitly executes the four new regression
mains. All 50 Java entry points and the distance-artifact regeneration smoke
test pass. The independent certificate harness passes 31 trusted-pin checks,
retains the distinct parsed PAIR source hashes, and reports the unchanged
census: **1 VERIFIED, 2 UNCHECKABLE, 0 REJECTED**. Authority remains fixture-scoped.

Independent bounded reviews cover the harness, law/wire, and records/source
areas. The [incident ledger](obligation-repair/fifth-five/incidents.md) retains
the Unicode model correction, missing test registration, and a blocked first
aggregate run caused by negative-control diagnostic formatting. The repaired
negative emitter uses anonymous failing examples; accepted proof audits and
the strict rejection classifier are unchanged. An independent addendum
corrects the earlier review's weaker diagnostic check.

## Experimental Impact

The fresh assurance build matches all **898** existing classes in the v2.16
experimental JAR byte-for-byte. The only added Java classes are regression
tests; no experimental entry point calls them. Test orchestration and proof
metadata changed, not an experimental pipeline. No full-corpus rerun is needed
or claimed for this release.

The full-corpus result-producing source remains
`8ad5fead39b687d2cadc79b01ac27743c1ece990`, publication run
`db9f89bf-0965-4d74-8080-d9191d5f1aec`. Its 5,808 imported output files, original
JAR, empirical trees and historical publication manifests remain unchanged.
The v2.16 validation refresh remains run
`659e248c-d3d6-4a2b-8d99-67a0ebcf9eb4`, from clean source
`8feab00f9190482af6a25334af5b2716653f8ac9`, with 29 successful sampled checks.

The attached `acgn-experiments.jar` is that existing v2.16 validation JAR,
not a rebuild or a relabeled full-corpus result producer: **2,549,918 bytes**,
SHA-256 `67e7dd088ef864a9170178e6b6c963a2c339836fa88b25cffe8e20788714f04a`.
The assurance archive supplies the new tagged sources, proofs, tests and
evidence separately. Release notes identify the packaging commit, exact-commit
CI, and both asset hashes. Use `git lfs pull` for a full repository checkout.

## Remaining Boundary

SHA-256 implementation and collision resistance remain trusted, not an
injectivity theorem. Structural constructor injectivity is not advertised as
arbitrary encoded-string injectivity. Successful wire decoding is a conditional
contract with finite actual codec observations. Local Seq/Bag/Set traces do
not create new law authority or FULL verification paths. The observed 12-class
export memory limit is documented, not reported as a successful stress test.

P1-19 independent raw-source authority, A-01 complete contract decomposition,
universal Java/parser refinement and the remaining original diagnostics stay
open. No new rewrite family or certificate authority is introduced.
