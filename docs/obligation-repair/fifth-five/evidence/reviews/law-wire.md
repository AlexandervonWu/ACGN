# v2.17 Law/Wire Independent Bounded Review

**Verdict: PASS. No scoped semantic-correspondence defect found.**

Date: 2026-09-09. Repository: `/home/augustus/ACGN`, starting HEAD
`c9475b6e5d5ef2508dc312b667d7bf33783cee9e`. This was a read-only repository
review: all reviewer programs, snapshots, compiled files and logs are under
`/tmp/acgn-v217-law-wire-review-checks`. No internet was consulted.

Machine-readable review result: `review-result.json` in that directory.
This PASS is a bounded adversarial review verdict, **not** the combined
fifth-five package's two-build `VERIFIED` closure or a publication certificate.

## Frozen Scope

- FV-P3-04: complete decoded law-record codec and independent exact registry
  reconstruction, connected to the registered finite producer/public-verifier
  observations. Original parent hash:
  `3991aa4c4db10ffcd0bcc1bc0197fda0b30377e422d4804b44dd05fd89bdab89`.
- FV-P3-12: canonical wire-table grammar, ordering and content-ID preimages,
  connected to the registered finite writer/public-decoder observations.
  Original parent hash:
  `981e681a6eac0f86c48a4aa9a4c95d01b6dafea2492683b66f22eb05f7fe0313`.
- Only supported producer operations and the public Wire/Codec/Bundle or
  IndependentVerifier boundary were evaluated. No new rewrite family, JVM
  mutation threat model, universal parser/JVM proof, or performance obligation
  was introduced.

## Independently Executed Checks

| Check | Result |
| --- | --- |
| Fresh JDK 17 compilation of source and standalone verifier | PASS |
| Law Java regression | 152 observations, 360 assertions; 48 VERIFIED fixtures and 104 REJECTED mutations |
| Wire Java regression | 66 observations, 34 assertions |
| Compiler-resolved source extraction | Law 10/10 objects; wire 4/4 objects |
| Law general Lean model | 27 audited named theorems PASS |
| Wire general Lean model | 17 audited named theorems PASS |
| Law observation replay | 246 audited propositions PASS: 152 observations plus 94 expected complete law records |
| Wire observation replay | 66 audited propositions PASS |
| Law Python encoder tests | 18/18 PASS |
| Wire Python encoder tests | 14/14 PASS |
| Law false-observation controls | 60/60 exit 1 with genuine false-proposition diagnostics |
| Wire false-observation controls | 13/13 exit 1 with genuine false-proposition diagnostics |
| Law source controls | 18/18 exit 1 at resolved shape/binding mismatch |
| Wire source controls | 12/12 exit 1 at resolved shape/binding mismatch |
| Additional independent public-boundary/Unicode probes | 1,294 audited Lean propositions PASS |

Every Lean command used the explicit installed Lean **4.33.0** executable.
Positive logs contain exactly their stated unique theorem inventories, no
errors or warnings, and only the declared foundational axioms `propext`,
`Classical.choice`, and `Quot.sound`. The final audit reapplied the main
profile's strict `check_rejection` classifier to **all 103** negative/source
control logs. Malformed Lean syntax, missing imports, unrelated Java compiler
errors, and infrastructure failures were not counted as semantic refusals.

The extra reviewer probe exercised 22 strings covering ASCII, NUL, prefixes,
two/three/four-byte boundaries, U+D7FF, U+E000, U+FFFF, U+10000, U+10FFFF,
combining text and mixed supplementary/BMP sequences. It compared every
ordered pair, including duplicates and empty IDs, through actual public
`Codec.decode` and `Bundle.parse`: 484 table/order cases. It also checked
282 UTF-8 vectors, including all 256 single bytes and focused overlong,
surrogate, truncation and Unicode-limit cases. Java outputs were replayed
against the wire model and the law model's independent UTF-16 conversion.
`PublicWireProbe.java`, `public-wire-probe.tsv`, `probe_replay.py`, and
`formal/IndependentReview.lean` retain the exact finite census and results.
The synthetic bundle metadata is TEST_ONLY structural-parser input, not
evidence of accepted semantic or publication authority.

## Semantic Review Results

1. **No Unicode-order counterexample remains in the reviewed versions.**
   Wire text remains UTF-8 bytes; only ID comparison converts to Java UTF-16
   units. Law structural-key lengths and ordering explicitly use UTF-16.
   The U+10000/U+E000 reversal and supplementary boundary probes pass.
2. **No law field or registered observation was silently lost.** All 17 law
   fields, full producer/writer projections, complete table order/cardinality,
   exact vocabulary/type/schema reconstruction, refreshed outer digest, and
   actual public outcome/detail participate in the checks. Registry attacks
   reach exact matrix/type refusal rather than an unrelated earlier failure.
3. **Wire validity is not promoted to equality authority.** Rehashed changed
   content can correctly pass `Bundle.parse` while failing the separately
   designated baseline-preimage claim. Witness IDs are intentionally named,
   not content-addressed. Structural acceptance is not presented as KERNEL,
   FULL, PAIR or publication certification.
4. **Negative evidence is real and appropriately separated.** Java outcomes
   come from public calls; synthetic Python fixtures are encoder unit tests.
   Source controls establish sensitivity of compiler-resolved pins, not
   semantic correctness of arbitrary modified Java implementations.
5. **The documented proof boundaries are accurate.** `decode_exact` is a
   conditional successful-decode/re-encode theorem, not universal codec
   injectivity or roundtrip. Expected registries and exact type interpretation
   remain explicit inputs/trust boundaries. SHA-256 implementation and
   collision resistance are trusted; injectivity is not claimed.

## Revisions Encountered

Authors were finalizing the law area during review. The first snapshot's law
proof (`a1cca03e6393f49774b9524f4d9975a68fda410aee92675065fdd69c53ebd602`)
hit Lean's heartbeat limit in `decode_some_iff` and consequently printed
`sorryAx` in dependent failed elaborations. This failed command was not
accepted as evidence. The author's direct proof replacement, final hash
listed below, passed all 27 audits without that dependency.

The initial law replay encoder
`25f076794562148f92b3ed60243d077c39a10c0e0bca4857d76fbcdb88dddd08`
was superseded during its run. The reviewer explicitly terminated that stale
process after 194.818 seconds (exit -15), preserving its logs. This is not a
semantic counterexample or a successful check. The replacement's structural
dictionary retains exact parse/re-encode equality before lowering text. It
passed the full 246-proposition replay in 150.362 seconds and all 60 negative
controls. No production edit was needed or made by this review.

The law notes and unit-test file arrived during review and were read/tested
before finalization. The original complete snapshot is retained with its
`input-hashes.json`; reviewed law proof/encoder/test overlays are retained
separately. The final audit confirmed the reviewed executable/model files
still matched their listed hashes. Later modifications require checking the
delta; this review cannot automatically approve future revisions.

## Exact Reviewed SHA-256 Hashes

Paths are relative to the repository root.

| File | SHA-256 |
| --- | --- |
| `docs/section3-repair-audit/formal/LawRecordWire.lean` | `68c7580ec2686ba7332680829c383220276b7a5c3f7701b31711e9119cb4b2e1` |
| `docs/section3-repair-audit/formal/CanonicalWireTables.lean` | `e5cad62f2a38525f81d8169c7a9ca68737220cc2e8163ed87d3bedebc386105d` |
| `scripts/fifth_law_record_replays.py` | `4b5db547efcecd5c47bc464bb161682f545d02dcdb96b362134a336a7cca5fe4` |
| `scripts/fifth_wire_tables_replays.py` | `18ff7ab88dabccddf83f549ca90393a81cc86e7d14c6773b0b50f0de3c0e3d84` |
| `src/is/fivefivefive/CanDis/theory/LawRecordWireRegressionTest.java` | `6f81ac709282d7371dfada2c7632d9a61dcabba058fa9b785765de9eb07e8a80` |
| `src/is/fivefivefive/CanDis/theory/CanonicalWireTablesRegressionTest.java` | `a40e861c12a613cbe5351b5d50fc1dcc93f486054a61e12804ea0c2733c63754` |
| `scripts/java/LawRecordWireExtractor.java` | `a69579bcdb204d7da317a56e662b5b52717019c4698314e555d58de3de88b7c5` |
| `scripts/java/CanonicalWireTablesExtractor.java` | `a975291ad3f8ad108abaa3d5885e83cef76c5df629a8d14af38648500a84ce08` |
| `scripts/test_fifth_law_record_replays.py` | `87d2523d9e4c4e84b31408a6c4e146d3de1bd969d13cc454e6fc751e8c26c3bf` |
| `scripts/test_fifth_wire_tables_replays.py` | `119488c56044b8d0867252de7572f5b87e2536892d459af9c7eaece25c1d6f4a` |
| `docs/obligation-repair/fifth-five/closure-config.json` | `c70e832e97fa5d1d02e63af7fee9ef2cd1fc75523896ff40d21ef92b4eb2a457` |
| `docs/obligation-repair/fifth-five/law-record-notes.md` | `29bc0485632cb04aa8e92ada4241e0bac0742ec5a759aff199f16ed1a6e4addd` |
| `docs/obligation-repair/fifth-five/wire-tables-notes.md` | `a296020d6f4c48056e5a6c98ee189f38719c08867177d04862466a583f383a15` |

## Reproduction And Handoff

The retained reviewer drivers are
`/tmp/acgn-v217-law-wire-review-run.py`, `finish_checks.py`,
`current_law_checks.py`, `source_controls.py`, and `final_audit.py`.
Command records and raw logs distinguish the superseded failed/interrupted
runs from the accepted current runs. Run `final_audit.py` to recheck the
current retained inventories, diagnostic classifications and reviewed hashes.
The machine-readable result does not overwrite or claim a package manifest.

**Main-agent handoff:** no semantic repair requested. Freeze the final files
and run the already registered combined closure and ordinary integration
checks. The independently bounded evidence above does not discharge missing
package provenance, replace two isolated clean builds, or extend the claimed
surface beyond these two areas. Review stops here; no additional semantic
rewrite search is proposed.
