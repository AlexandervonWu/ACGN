# Fourth Five Obligation Repairs

This package continues v2.14 with P2-20, A2-07, A2-11, P2-18 and P3-03.
Their original statements and hashes remain unchanged. The scope is bounded
Java-to-Lean conformance, not a new rewrite theory or experimental run.

| Requirement | Evidence surface |
| --- | --- |
| P2-20 | Recursive same-head flattening with exact typed associativity evidence |
| A2-07 | Independent exact stored-type-to-relation-view leaf proofs |
| A2-11 | Complete dependent-chain certificate index reconstruction |
| P2-18 | Exact permutation, quotient, splice and unit/deletion witness indices |
| P3-03 | Five-field profile serialization and independent verifier reconstruction |

The [container](container-notes.md), [chain](chain-notes.md), and
[profile](profile-notes.md) records distinguish general Lean theorems,
compiler-resolved Java source mappings, finite production observations,
generated replays, negative controls and excluded surfaces.
The [harness record](harness-notes.md) fixes trust, failure classification,
fresh-build requirements and provenance. Neither source hashes nor tests
alone establish universal implementation refinement.

## Reproduction

Use Java 17, Python 3 and the installed pinned Lean 4.33.0 toolchain:

```bash
python3 -B scripts/run_fourth_obligation_repairs.py /tmp/acgn-fourth-five
```

The output directory must be fresh and outside the source tree. The runner
works from a checkout or an extracted assurance archive and verifies offline.
It retains the previous engine and dispatcher byte-for-byte, instantiating
private modules for this package only. General contracts and bounded direct
conformance are separate; successful replay does not certify arbitrary Java
or Alloy programs.

The [closure configuration](closure-config.json) is authoritative for the
finite claims. A generated machine report records their actual run status;
this description cannot convert a failed or unresolved claim into a pass.

## Prepublication Check

The retained preflight report is `VERIFIED` at input root
`0f5608a4698658c25e3c7f363d24004af04cb7c6d079dfa8cd7f5f3cab4f4edf`.
Two isolated builds each passed five bounded claims, 66 general Lean theorems,
9,128 replay propositions/blocks, 36 rejection controls and 42 compiler-source
controls. Their 1,076 generated artifact hashes match exactly. The Java probes
recorded 10,630 observations and 126,489 assertions per build. The four independent
bounded reviews passed; their raw evidence and earlier failed probes are retained.

This is a source-bound preflight result, not evidence for later changed inputs.
The CI job budget was subsequently raised to 90 minutes to accommodate the
added two-build package. The final release must obtain a new closure report
for its final inputs. The full assurance matrix has 107 ready requirements and
111 diagnostics; its overall status remains `INCOMPLETE`.

## Final Verified Evidence

The [final machine report](evidence/final/report.json) is **VERIFIED** for all
five frozen claims at closure ID `fourth-five-v1-188b4a84db91aeff`, input root
`188b4a84db91aeff0f921e687a4093fc49fd9268d46647b98c7de4a052943575`.
Both clean builds passed, with **1,076 identical artifacts per build**.

| Evidence | Per build |
| --- | ---: |
| General Lean theorems | 66 |
| Generated replay propositions/blocks | 9,128 |
| Java observations | 10,630 |
| Java assertions | 126,489 |
| Compiler-resolved source objects | 33 |
| False-proposition Lean controls | 36 |
| Source-mutation rejection controls | 42 |

The 17 driver tests, 46 area encoder tests and seven compatibility tests pass.
The broader Java suite passes 45 entry points and its distance-artifact smoke.
Certificate checks retain 184 verifier, 109 writer (twice), 68 inspection,
31 trust-pin and ten parsed-PAIR checks, with census 1 verified / 2 uncheckable /
0 rejected. The two parsed-source hashes remain distinct. Raw final evidence
and the earlier preflight/review records are retained with
[checksums](evidence/SHA256SUMS).

The final run uses the explicit 900-second command limit and 120-minute CI
budget. The earlier hosted timeout is retained as an infrastructure failure;
no rejection criterion or theorem changed to obtain this result.

## Preservation

Production rewrite and distance semantics, certificate authority, and the
previously archived experiment JAR remain unchanged by this proof package.
The three producer/replay fixes are documented in [the incident record](incidents.md).
At the author's request, a fresh serial full-corpus run was completed before
v2.15 publication. Run `db9f89bf-0965-4d74-8080-d9191d5f1aec` passed all four
stage gates, and its 5,808 stage files are now imported. The preceding
publication manifest and JAR remain unchanged.
SHA-256 collision resistance remains explicitly
trusted. P1-19's external occurrence-authority prerequisite and the A-01
complete contract-registry prerequisite are not discharged by this package.
