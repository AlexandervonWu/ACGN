# ACGN v2.15

This release continues v2.14 with the next five bounded Java-to-Lean
correspondence repairs. It does not introduce a new rewrite family.
The repairs exposed real producer/replay interoperability defects, so
publication is gated on a fresh full-corpus four-stage run after the bounded
checks pass. This file remains a release candidate until that run completes.

## Five Repairs

1. P2-20: recursive same-head flattening with exact typed associativity evidence.
2. A2-07: independent stored-type-to-relation-view leaf proof derivation.
3. A2-11: complete dependent-chain index reconstruction at producer, writer
   and independent-verifier boundaries.
4. P2-18: exact permutation, quotient, splice and unit/deletion witness indices.
5. P3-03: exact five-field semantic-profile serialization and reconstruction.

The [fourth-five package](obligation-repair/fourth-five/README.md) separates
general Lean contracts, compiler-resolved source checks, finite Java
observations, kernel-checked replays and rejection controls. The original
claim statements and hashes remain unchanged. `PROVED/DIRECT` denotes proved
models with bounded direct conformance, not universal parser/JVM refinement.
SHA-256 collision resistance remains trusted; no hash-injectivity proof is
claimed. Unadmitted laws and source/provenance restrictions remain intact.

## Source-Profile Interoperability Repair

The new producer/verifier tests exposed an obsolete standalone-verifier pin:
the source factory emits `alloy-command-options-v4-independent-search-domain`,
but replay still required `alloy-command-options-v2`. All six untouched
parser-owned source-profile baselines rejected at this check. The verifier
now recognizes only the exact current version, retaining its context shape,
type, overflow, fingerprint and authority checks. Old, truncated and future
version strings reject even after checksums are recomputed.

This is a correction to standalone replay acceptance, not a change to
canonicalization, repair distances or reward computation. The standalone
verifier build is refreshed; the previously archived experiment JAR is preserved. The
[incident record](obligation-repair/fourth-five/incidents.md) retains the
pre-repair observations and bundle witnesses.

Recursive splice replay had a second false-negative: the producer records
parent splices before descendants, while standalone replay reconstructed the
opposite order. A valid four-leaf nested FULL export reproduced the mismatch.
Replay now derives the same preorder without trusting supplied splice fields;
deep association and reordered-ledger tests cover the correction.

The chain writer also omitted exact intermediate types needed by canonical
left-fold replay when the source used a different association. It now publishes
the types derived by that certified fold, including its product and boundary
evidence. No `univ` fallback or relaxed type check is introduced. A real
right-associated primitive JOIN export reproduces the original failure.

## Reproduction

With Java 17, Python 3 and the installed pinned Lean 4.33.0 toolchain:

```bash
python3 -B scripts/run_fourth_obligation_repairs.py /tmp/acgn-v215-fourth-five
python3 -B scripts/run_third_obligation_repairs.py /tmp/acgn-v215-third-five
python3 -B scripts/run_next_obligation_repairs.py /tmp/acgn-v215-next-five
python3 -B scripts/run_bounded_obligation_repairs.py /tmp/acgn-v215-first-five
python3 -B scripts/report_obligation_repairs.py --output /tmp/acgn-v215-status
```

Use unused output directories outside the source tree. The four bounded
repair runners support both checkouts and extracted assurance archives,
create two isolated builds and compare deterministic outputs. The status
reporter distinguishes absent diagnostics from actual proof closure.

## Assets And Provenance

- `acgn-v2.15-assurance.tar.gz`: tagged source, local libraries, bounded
  runners, proofs, documentation and retained evidence. It excludes corpus,
  experimental result directories and frontend files; use the full checkout
  for those surfaces.
- `acgn-experiments.jar`: the frozen JAR from the new completed publication
  run. Its source commit, run ID, size and hash must be recorded here before
  publication; the v2.11 archived JAR is not overwritten.
- `SHA256SUMS`: hashes both attached assets. The public release records its
  exact packaging/tag commit and successful Actions run.
- Previous result-producing source: `fbd9b1497a9036c55780da777f56581bc1c6bcec`.
- Previous publication run: `df4d8d4c-6265-4fe7-88d5-3aceee60398b`.

Run `git lfs pull` in a full checkout before reading the large experimental
JSON files. Until the new run passes, the checked-in empirical snapshot and
its 5,808 checked stage outputs remain those of v2.11. The rerun uses all
66,080 files, reward pool 100, 16 workers and an 8 GiB heap, with stages
strictly serial and one unchanged source/JAR identity. The complete assurance matrix
remains incomplete; the P1-19 external occurrence-authority prerequisite and
A-01 complete contract-registry prerequisite are separate work.
