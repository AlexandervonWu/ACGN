# All temporal ranking comparisons

A fresh replay of each of the 26,673 temporal comparisons in the closed final ranking corpus returned identical Fast Rewrite and Certified scores and ordered block effects. On 26,477 inputs the fresh digest also exactly reproduced the original final-run digest. The other 196 inputs carry a process-local occurrence number for a bound variable inside the ordered effect. All 196 are present in the separate comparison across releases. The archive preserves the literal numerical IDs and both original block arrays for every fresh comparison.

Run this reader from the release directory with the ACGN checkout containing the original classified corpus and the published scores.

    python3 -B temporal-program-replay/full-temporal-scope/verify.py --archive . --repo /path/to/ACGN

For a single run in a fresh JVM, pass its submission path, reference ID, frozen final JAR, runtime dependencies and a new output filename.

    python3 -B temporal-program-replay/full-temporal-scope/replay_one.py SUBMISSION REFERENCE_ID --repo /path/to/ACGN --jar /path/to/final.jar --libs /path/to/lib --output /tmp/native-program.json

The input table selects the complete temporal class from the final ranking archive. Each row retains submission and reference selectors and hashes, positive expected score, original measured shard and ordinal, block count and the measured final digest. Each compact observation records those source identities, both fresh program commitments, a SHA-256 of the complete raw JSON line, local-occurrence counts and the affected endpoint. The ZIP members retain the full native arrays, including entries and effects, with per-shard worker acknowledgments. Fresh replay offsets are measured separately against clean JVM observations. The portable reader checks exact native JSON commitments before calculating any allocator shifts. It compares the entire fresh effect program with the independent cold replay after translating only the named binding-occurrence field. The parent directory holds the separate owner and phase evidence.

The structural and ranking correctness claims use the native comparator within each execution. The archive retains the process-local binding numbers. Translating those numbers by the recorded, pair-specific allocator offsets reproduces the exact archived final commitments for all 196 observations.
