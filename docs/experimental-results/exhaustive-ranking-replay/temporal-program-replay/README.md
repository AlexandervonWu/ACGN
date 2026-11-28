# Process-local occurrence labels in temporal witnesses

Exactly 196 of the 1,893,782 previously matched ranking comparisons changed their raw ordered-program commitment between the two measured runs. All 196 used temporal blocks. We selected these pairs by their full source paths, predicate selectors, reference IDs, source hashes and positive costs. Each retained its block count.

For each pair, two fresh JVMs per exact JAR measured the original selection directly. A third fresh JVM per JAR performed one complete preparation and comparison of the same pair before measuring it again. All 1,176 observations returned exact within-run Fast/Certified agreement at the archived distance. All 196 direct old/new programs and source-owner tables were identical under the same cold preparation. The same held under the warmed preparation. Every cold repetition reproduced its own raw program. A preceding preparation moved the local-use and source-owner occurrence identifiers by a uniform offset of 233 to 1,653. The offsets preserved the complete ordered component/effect arrays, owner tables, phase and binding paths, lexical coordinates, costs, and equality relationships among uses. The two cold and one warm schedules produced raw hashes distinct from the long-running workers' archive hashes for every one of these 196 pairs.

The `localBinding.sourceOccurrence` field identifies a use with a process-local integer. The Java comparator checks its source-owner correspondence and embeds the recorded integer in both arms. The comparator takes the integer from EGraphNode’s process-wide source-occurrence counter. The direct comparison concerns identity and aliasing within an actual prepared endpoint. A fresh run can assign different integers to the same source occurrences.

For every one of the 196 pairs, translating only its local-use occurrence labels reproduced the exact archived ordered program in both editions. All 392 original raw SHA-256 commitments were recovered. The arithmetic offsets from the cold run ranged from 37,446 to 15,696,032. The 196 raw hash differences therefore reflect the JVM allocation context. The 386 earlier within-run Fast/Certified disagreements remain the observed changes in operation choice.

The archive retains every original measured hash. `archived-offsets.jsonl` records only offsets that reconstruct an exact SHA-256 preimage from a directly measured program. Each offset changes positive sourceOccurrence values under source.localBinding or target.localBinding in the effect arrays. Every other value and operation position remains fixed. The package verifier also checks the independently measured owner tables, including parent declarations, slot occurrences and binding paths, under a single uniform offset. A matching archived effect commitment establishes the complete archived effect sequence. The original compact archive did not serialize its full auxiliary owner tables.

For a worked example, the target of classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als against reference 169 has three distinct variable uses. The fresh JVM recorded 386, 390 and 392. A complete prior preparation moved them to 836, 840 and 842. The archived original hash is recovered exactly with 345784, 345788 and 345790. The archived repaired hash is recovered with 581066, 581070 and 581072. The 24-distance program, including every other field of its four ordered blocks, is identical.

## Recheck a source selection

From the release directory, with the JAR recovered from the measured Git commit, run

```sh
python3 -B temporal-program-replay/replay.py repaired /path/to/ACGN \
    classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als 169 --jar /path/to/repaired.jar --warm
```

The result exposes both raw digests, the actual source-owner offset relative to the cold control, and whether the exact archived digest was reconstructed. For a selection outside these 196, the reader runs the registered exact-hash replay directly. To read an archived commitment without generating a new program, use the edition's registered lookup_native.py.

Recount all fresh observations and run the corruption controls with

```sh
python3 -B temporal-program-replay/verify.py --repo /path/to/ACGN
python3 -B temporal-program-replay/test_controls.py
```

The file native-receipts.jsonl.xz contains all distinct native JSON results byte-for-byte. The observations ledger indexes them by table ordinal, edition, preparation schedule, and repetition. The witnesses ledger retains each complete ordered effect array with both source-owner tables and both arms' measured cost components. The example folder contains the complete direct and warmed diagnostics for the worked example.
