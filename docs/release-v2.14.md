# ACGN v2.14

This assurance release continues v2.13 without changing production
canonicalization, repair distances, rewards, certificate semantics, the
empirical snapshot, or the archived experiment JAR.

## Five Repairs

1. P1-06: independent declaration/ledger arity and callable authority.
2. P1-09: executable allocation and consumption without occurrence reuse.
3. P1-16: ordered CALL representation preserving nesting and repeated operands.
4. P2-19: exact fixed-registry admission and complete profile/index binding.
5. A2-04: arbitrary-length guarded relational JOIN reassociation.

The [repair package](obligation-repair/third-five/README.md) separates general
Lean proofs, resolved Java source checks, finite observations, generated
replays, and rejection controls. Original claim statements and hashes remain
unchanged. `PROVED/DIRECT` means proved models with bounded direct conformance,
not universal Java/parser refinement or full artifact closure.

The matrix reports **102 ready requirements and 118 diagnostics**, compared
with 97 and 123 in v2.13. Of the original 132 diagnostics, 117 remain; the
additional A-01 missing-registry diagnostic remains visible. The full matrix
is `INCOMPLETE`. The standalone certificate census remains fixture-scoped:
**one verified, two uncheckable, zero rejected**.

## Verification

The new five-claim package is **VERIFIED** in two clean builds, each with
1,053 identical artifacts, 74 new general Lean theorems, 166 imported theorem
audits and 1,414 generated replay propositions. The three new Java tests
execute 18,800 assertions across 10,628 observations. All 28 Lean negative
and 26 source-mutation controls reject for their registered reasons in each
build. The 33 harness and 34 area encoder unit tests pass.

Input root:
`4d63586625ff6c0a4f5bc923ed19ecbb377b88d2c768ea504a39b965f9393003`.
The broader bounded Java tests and certificate/snapshot checks also pass.
The package retains review-discovered scanner, private-theorem inventory,
rejection-diagnostic and JDK-version fixes, including interrupted/blocked
candidate reports. The v2.13 engine and both previous five-claim packages
remain unchanged.

## Reproduction

With Java 17, Python 3, and the installed pinned Lean 4.33.0 toolchain:

```bash
python3 -B scripts/run_third_obligation_repairs.py /tmp/acgn-v214-third-five
python3 -B scripts/run_next_obligation_repairs.py /tmp/acgn-v214-next-five
python3 -B scripts/run_bounded_obligation_repairs.py /tmp/acgn-v214-first-five
python3 -B scripts/report_obligation_repairs.py --output /tmp/acgn-v214-obligations
```

Use fresh output directories outside the source tree. The three bounded repair
runners support tagged checkouts and extracted assurance packages, create two
isolated builds, and require deterministic artifacts. The status reporter
does not equate absent diagnostics with proof closure. The two older container
and Java-Lean refinement runners still require a Git checkout for provenance.

## Assets And Provenance

- `acgn-v2.14-assurance.tar.gz`: tagged source, libraries, bounded runners,
  proofs, documentation, and retained evidence. Corpus/results and frontend
  files are excluded; obtain the full checkout for those surfaces.
- `acgn-experiments.jar`: unchanged v2.11 JAR, 2,292,989 bytes, SHA-256
  `361b33ef56f6ccb1089a7a6fdda2a92bf621e501166c5a1c73330a0cc1686807`.
- `SHA256SUMS`: hashes both attached assets. The public release records the
  exact packaging/tag commit and its successful Actions run.
- Result-producing source: `fbd9b1497a9036c55780da777f56581bc1c6bcec`.
- Publication run: `df4d8d4c-6265-4fe7-88d5-3aceee60398b`.

Run `git lfs pull` in a full checkout before reading the large experimental
JSON files. The unchanged imported snapshot contains 5,808 checked stage
outputs. Rewards and correlations remain those of the v2.11 pool-100 run.
No full-corpus rerun or JAR rebuild is part of this release.

## Next Work

The [next five candidates](obligation-repair/next-candidates-v2.14.md) are
P2-20, A2-07, A2-11, P2-18, and P3-03. They target typed recursive flattening,
leaf proofs, chain indices, law-witness indices, and profile serialization.
They remain partial and are not newly certified by this release.
