# ACGN v2.13

This release continues the bounded assurance work from v2.12. It does not
change production canonicalization, repair metrics, rewards, certificate
semantics, or the empirical snapshot. It adds proof and correspondence
evidence for the next five obligations:

1. P2-06: exact flat element/result typing through shared substitution.
2. A2-01: ordered dependent JOIN/ARROW sequence construction and replay.
3. A2-02: dependent-chain length and operand multiplicity preservation.
4. P1-08: arbitrary-arity CALL validation and exact-visit dispatch.
5. P1-05: source argument order through the retained CALL boundaries.

The [repair record](obligation-repair/next-five/README.md) is the evidence
index. It records general Lean results separately from compiler-extracted
source checks, finite Java executions, generated observation replay, and
negative controls. Existing claim statements and hashes remain unchanged.
`PROVED/DIRECT` means proved models with bounded direct conformance; it does
not establish universal parser/JVM refinement or full assurance closure.

The current matrix has **97 ready requirements and 123 diagnostics**, compared
with 92 and 128 in v2.12. Of the original 132 diagnostics, 122 remain; the
separately exposed A-01 missing-registry diagnostic is also retained. The full
matrix remains `INCOMPLETE`. The standalone census is unchanged at
`VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.

The new five-claim package is **VERIFIED** in two clean builds: 1,026 identical
artifacts per build, 48 general Lean theorems, 2,636 generated propositions,
and all 21 required rejection controls per build. The three new Java tests
execute 66,872 assertions per build. The 33 runner and seven encoding unit
tests pass, including isolated Git provenance and no-default Lean selection.
Input root:
`c627da30a64e66506a1dcb777fd94e9dcbee7e2b5a64ad7bcb7e37557d360da0`.
Review-discovered storage-correspondence and runner integration gaps are
documented together with the repairs and blocked intermediate reports.

## Reproduction

From the tagged checkout or extracted assurance package, using Java 17,
Python 3, and the pinned Lean 4.33.0 toolchain:

```bash
python3 -B scripts/run_next_obligation_repairs.py /tmp/acgn-v213-next-five
python3 -B scripts/run_bounded_obligation_repairs.py /tmp/acgn-v213-prior-five
python3 -B scripts/report_obligation_repairs.py --output /tmp/acgn-v213-obligations
```

Use fresh output directories. The first two commands perform two isolated
builds and require deterministic artifacts. The final command reports the
remaining obligations without treating missing diagnostics as proof closure.
The two older container and Java-Lean refinement runners still require a
Git checkout for provenance, not an extracted archive without `.git`.

## Assets and Provenance

- `acgn-v2.13-assurance.tar.gz` contains tagged source, libraries, bounded
  runners, proofs, and retained evidence. Corpus/results and frontend files
  are excluded; this is not a replacement corpus snapshot.
- `acgn-experiments.jar` remains the unrecompiled v2.11 experiment JAR:
  2,292,989 bytes, SHA-256
  `361b33ef56f6ccb1089a7a6fdda2a92bf621e501166c5a1c73330a0cc1686807`.
- `SHA256SUMS` binds both release assets. The public release body records
  the exact packaging/tag commit and successful exact-commit Actions run.
- Result-producing source remains
  `fbd9b1497a9036c55780da777f56581bc1c6bcec`; the publication run remains
  `df4d8d4c-6265-4fe7-88d5-3aceee60398b`.

Run `git lfs pull` in a full checkout before reading the large experimental
JSON files. The snapshot verifier checks the unchanged 5,808 stage outputs.
The exported certificate census remains fixture-scoped: one verified,
two uncheckable, zero rejected, not corpus-wide certification. Rewards and
their correlations remain those of the v2.11 publication run with pool 100.
No experiments or JAR rebuild are included in this assurance release.
