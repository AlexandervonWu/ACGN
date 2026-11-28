# Native replay through the repair stages

The original census found 386 submissions paired with a particular reference whose two checked native programs differed. Those 386 pairs span 61 submissions, 125 references and 13 invariant pools. Both arms returned the same scalar distance on every pair. The pair table gives each submission, selected predicate, reference ID, source revision and native verdict through the four repair stages.

    python3 -B verify.py .

The reader requires Python 3.9+ and a temporary directory with 400 MB free. It reopens the complete original negative programs and the recorded stage results, verifies their input selections and costs, recomputes both ordered commitments for every negative replay, and regenerates the stage tables. Each full source file, the five exact engine JARs, all native failure payloads, native worker acknowledgments and the independent registered checker are included. Positive rows record both engine commitments; the JAR and driver support independent replay. The original complete 1,894,168-row census is available in the adjacent original archive.

The original replay passed in reverse on 371 pairs. The four stages restored 136, 47, 5 and 188 additional forward programs, respectively. The third stage also restored five reverse programs. Ten pairs remained divergent in both directions at stage four. To look up a pair, use its submission path and reference ID in tables/pairs.csv or tables/directions.csv. tables/unresolved.csv lists the ten pairs at that stage. The gzip JSONL table contains complete directional histories and failure details.

When a final checkpoint is included, tables/final-directions.csv reports both directions on all 386 original pairs and 83 disjoint historical controls. To verify the 469 forward commitments against the complete repaired ranking archive, run the following command once the complete archive is distributed.

    python3 -B verify.py . --full-archive ../repaired

All source and native distance claims are bound to the registered candidate. Revisions assigned to a transition are the first observed engines with a restored directional witness in the measured stage series.
