# ACGN v2.12

This is an assurance and reproducibility update, not a new experimental run.
Production canonicalization, repair distances, rewards, and certificate
semantics are unchanged. The empirical tables and archived experiment JAR
remain those published with v2.11.

## Included Work

- Finite Java-to-Lean container replay and compiler-extracted Boolean
  smart-construction correspondence, with their separately scoped evidence.
- Explicit rejection of unsupported A-01 decomposition claims; presence of
  theorem names or status labels does not discharge the missing contracts.
- General proofs and direct bounded conformance for P2-02 (nominal policy
  fields), A2-06 (JOIN interior guard), P2-05 (single root port), P1-10
  (zero-argument CALL), and P5-15 (built-in identity and empty cardinality).
- Registered bounded CI entry points, source/observation rejection controls,
  and retained review records and hashed evidence.

The [five-claim repair report](obligation-repair/bounded-five/README.md) records
two identical clean builds, 77 general and 93 generated Lean theorems per
build, 370,365 assertions in the five new Java tests per build, and all 17
required rejection controls per build. Its input root is
`5c9400cca03d749ba25568b406ec968bc0b02d7a8904652f4f57de954b613de6`.
Older evidence packages retain their original input hashes; their historical
results are not silently reassigned to this release's source tree.

## Assurance Boundary

The current ledger has 92 ready requirements and 128 diagnostics: 127 original
diagnostics remain, plus the explicitly exposed A-01 missing-registry issue.
The full assurance matrix is still `INCOMPLETE`. `PROVED/DIRECT` pairs a
matching Lean statement with bounded direct Java conformance; it does not
mean whole-parser or whole-JVM refinement.

The bounded Java regressions and standalone producer/verifier harness pass.
The exported certificate census remains one `VERIFIED`, two `UNCHECKABLE`,
and zero `REJECTED`. Coverage is fixture-scoped and does not certify the
entire corpus. Lean, Java/library contracts, the tested extractors/observers,
Alloy/SAT4J, and the execution platform remain declared trust dependencies.

## Assets and Provenance

- `acgn-experiments.jar` is the existing, unrecompiled v2.11 experiment JAR:
  2,292,989 bytes, SHA-256
  `361b33ef56f6ccb1089a7a6fdda2a92bf621e501166c5a1c73330a0cc1686807`.
- `acgn-v2.12-assurance.tar.gz` contains the tagged source, libraries, scripts,
  proofs, and retained evidence needed for the bounded closure commands. It
  does not include corpus/result directories or the frontend. It is not a
  replacement corpus snapshot.
- `SHA256SUMS` records hashes of both release assets. The GitHub release body
  records the exact packaging commit and its successful Actions run.
- Result-producing source commit remains
  `fbd9b1497a9036c55780da777f56581bc1c6bcec` and the clean publication run
  remains `df4d8d4c-6265-4fe7-88d5-3aceee60398b`.

Reviewers using the full repository must run `git lfs pull` before checking
the large empirical JSON files. `verify_imported_publication_snapshot.sh`
checks the unchanged 5,808 manifest-bound stage outputs. Rewards and their
correlations remain available from the v2.11 run with reward pool 100; none
were recomputed for this release.

## Bounded Reproduction

From the extracted assurance package or the v2.12 checkout, with Java 17,
Python 3, and the pinned Lean toolchain available:

```bash
python3 -B scripts/run_bounded_obligation_repairs.py /tmp/acgn-v212-five
python3 -B scripts/run_java_lean_refinement.py /tmp/acgn-v212-refinement
python3 -B scripts/run_submission_container_closure.py /tmp/acgn-v212-containers
python3 -B scripts/report_obligation_repairs.py --output /tmp/acgn-v212-obligations
```

Each output directory must be fresh. The last command reports the remaining
obligations and does not convert missing diagnostics into proof closure.
