# ACGN v2.15

This release continues v2.14 with the next five bounded Java-to-Lean
correspondence repairs. It does not introduce a new rewrite family.
The repairs exposed real producer/replay interoperability defects, so
publication is gated on a fresh full-corpus four-stage run after the bounded
checks pass. That run completed on September 8, 2026; all four stage gates passed.

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

## Bounded Verification

The final [machine report](obligation-repair/fourth-five/evidence/final/report.json)
is VERIFIED at `fourth-five-v1-188b4a84db91aeff`, input root
`188b4a84db91aeff0f921e687a4093fc49fd9268d46647b98c7de4a052943575`.
Two clean builds passed all five claims with 1,076 identical artifacts each:
66 general Lean theorems, 9,128 replay propositions/blocks, 10,630 Java
observations, 126,489 assertions, 36 Lean rejection controls and 42 source
controls per build. All four independent bounded reviews passed; their
original findings and executed evidence remain in the package.

The first hosted closure exceeded its 300-second Lean compilation limit and
is retained as an infrastructure failure. The final configuration permits
900 seconds per command and 120 minutes for CI; proofs, counters and pass
criteria are unchanged. The release requires successful CI on its exact
packaging commit in addition to the local frozen-input result.

## Full-Corpus Results

Clean result-producing source: `8ad5fead39b687d2cadc79b01ac27743c1ece990`.
Publication run: `db9f89bf-0965-4d74-8080-d9191d5f1aec`.

| Gate | Result |
| --- | --- |
| CanonicalBatchTest | 66,080 files; 61,598 successes; 4,482 AST-identical skips; zero distance/reward failures |
| Alloy4FunAugmenter | 42,386 incorrect predicates ranked and rewarded; zero parse, pool, ranking or reward failures |
| Incorrect nearest-truth zeroes | Zero for both Fast Rewrite and Certificate-Integrated IR |
| Natural-corpus ablation | Seven arms, 61,598 eligible pairs each, zero failures or incorrect zeroes |
| Bounded semantic checks | 4,088 claimed-equal pairs, zero counterexamples/errors; four negative controls unmerged |
| Capabilities | 5,500/5,500 captured by slotted, Fast Rewrite and Certificate-Integrated IR; 77 cells present |
| Imported snapshot | Exactly 5,808 generated stage files pass manifest hashes |

The run used 16 workers, an 8 GiB heap, reward pool 100 and one unchanged JAR.
The distance and equality-coverage headline values match the preceding
snapshot: mean certified repair distance 14.021721, 4,088 CORRECT paired
zeroes, and 14 more CORRECT zeroes than Fast Rewrite. Rewards were freshly
computed: mean candidate reward 0.554601 in paired evaluation and 0.352766
for incorrect predicates. Six temporal capability solver checks remain
inconclusive, including a retained static-reduction solver report. They
are not counted as proofs or conclusive semantic failures.

Performance was measured again: Fast Rewrite took 23.990 seconds and
Certificate-Integrated IR 2,684.110 seconds. No performance improvement is
inferred from a single rerun. The [new publication record](../publication_runs/db9f89bf-0965-4d74-8080-d9191d5f1aec/README.md)
retains the source/JAR identity, stage gates and supervision history.

## Certificate Boundary

The bounded certificate harness passes 184 standalone-verifier checks,
109 writer checks in each of two processes, 68 producer-inspection checks,
31 trust-pin checks and ten parsed-source PAIR checks. Its real-source export
census remains **1 VERIFIED, 2 UNCHECKABLE, 0 REJECTED**. The parsed PAIR binds
two distinct source hashes. Fixture approval remains limited to the declared
test scopes; no corpus-wide authority or complete Java-to-Lean refinement is
claimed. The two trusted theory digests remain unchanged.

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
  run, 2,540,041 bytes, SHA-256
  `a053e40e64faa2ecffb0f4999b57aa661eae51933d6daf93a95d973144a71abf`.
  The v2.11 archived JAR is not overwritten.
- `SHA256SUMS`: hashes both attached assets. The public release records its
  exact packaging/tag commit and successful Actions run.
- Previous result-producing source: `fbd9b1497a9036c55780da777f56581bc1c6bcec`.
- Previous publication run: `df4d8d4c-6265-4fe7-88d5-3aceee60398b`.

Run `git lfs pull` in a full checkout before reading the large experimental
JSON files. The checked-in empirical snapshot and its 5,808 checked stage
outputs now come from the completed v2.15 rerun. The rerun uses all
66,080 files, reward pool 100, 16 workers and an 8 GiB heap, with stages
strictly serial and one unchanged source/JAR identity. The complete assurance matrix
has 107 ready requirements and 111 diagnostics and remains incomplete; the
P1-19 external occurrence-authority prerequisite and
A-01 complete contract-registry prerequisite are separate work.
