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

## Preservation

Production rewrite and distance semantics, certificate authority, and the
previously archived experiment JAR remain unchanged by this proof package.
The three producer/replay fixes are documented in [the incident record](incidents.md).
At the author's request, a fresh serial full-corpus run is required before
v2.15 publication; old snapshots remain intact until its gates pass.
SHA-256 collision resistance remains explicitly
trusted. P1-19's external occurrence-authority prerequisite and the A-01
complete contract-registry prerequisite are not discharged by this package.
