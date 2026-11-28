# Scalar verification of every correct-reference pool

The released historical correct-pair table identifies 19,271 structural zeros and 112,761 positives. It stores the zero decision for each pair. The positive numeric distances in this package were freshly computed on both the exact historical JAR and the exact final JAR.

Each row of positive-scores.tsv.gz contains six tab-separated decimal fields. They are the original left ID, original right ID, original Fast distance, original Certified distance, final Fast distance, and final Certified distance. The reference catalog identifies each original source, selected predicate and file digest. The order matches the measured source-oriented comparison, including oracle selections. Each baseline and final native output shard can be reconstructed from the corresponding four columns and checked against its independently bound digest. The archive includes the two scalar drivers’ compiled classes and their common Java source.

An initial 400 MiB run exhausted its heap while preparing the productionLine_v2/inv9 references. Both reported engine runs used the same revised memory protocol and started from the first input. cache-repeat.json binds every completed shard from the initial calibration to its independent repeat on the historical JAR.

The remaining 19,271 inputs are linked to freshly checked final native zero traces with the exact selected endpoint IDs and source hashes. The verifier reconstructs all unordered pairs from 4,496 catalog entries in 181 pools, checks the historical classification, and derives the complete zero graph. Structural class counts come from its connected components, including isolated vertices. pools.csv lists each of the 181 pools with both arm-specific zero counts, structural class counts and the number of pairs connected by zero edges. Its Slotted columns compare the complete 132,032 original Slotted scores with both current scalar arms and give each pool’s lost and additional structural zero edges. The fixed-command component count uses a separate experiment.

    python3 -B verify.py . --repo /path/to/ACGN

The checkout supplies the historical correct-pool decisions and original classified reference sources. The overlap check reads both scalar arms, the separate executable identities and the independent retained-zero ledger before computing the count. No Java execution is required to recheck the package. PoolScalars.java, inputs.py and run.py identify the production scalar APIs and preserve the experiment protocol for a fresh replay.

To run a single published pair in Java, pass its two original reference IDs, the checkout, the exact engine JAR and the directory of measured dependencies. The command accepts IDs in either order and restores the original measured comparison orientation. The stage-attribution runtime archive supplies the original JAR and dependencies. Its final archive supplies the final JAR. The replay uses the classpath order read from each live measured JVM.

    python3 -B replay_one.py . --repo /path/to/ACGN --side final --jar /path/to/final/a.jar --lib-dir /path/to/frozen/lib 192 193

In classroom_fol/inv6, references 192 and 193 express `all t: Teacher | some t.Teaches` and `all t: Teacher | #t.Teaches > 0`. Both scalar arms return 7 in both revisions. The original comparison command uses four-bit integers and admits at most three `Class` atoms. Replaying that command on the final JAR returned UNSAT for a disagreement. The predicates therefore contribute two structural forms joined by a fixed-command equivalence edge. The exact command is in [example.als](example.als), with its [native solver outcome](example-command-outcome.json). The comparison command has SHA-256 `424f90357dc04ce0be157dda044e7d1717148772163f1af38fdba32791459faa`.
