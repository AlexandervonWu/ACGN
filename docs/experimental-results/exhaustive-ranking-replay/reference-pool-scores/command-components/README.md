# Structural and fixed-command components

Each of the 4,496 reference predicates is a vertex. In each of 181 invariant pools, the first graph connects the predicates whose Fast and Certified structural distances are zero. The second graph also includes the 1,234 fixed-command pairs validated against the original archived Alloy commands. Some rules also apply to a pair that already has zero structural distance. The verifier reads every direct edge, computes both partitions and checks all historical SAT controls for connectivity.

From the release directory, run the following with the ACGN checkout that contains the original classified corpus and historical per-pool table.

    python3 -B reference-pool-scores/command-components/verify.py --archive . --repo /path/to/ACGN

The verifier reopens both engines’ full structural-score audit and the final source/command controls. Its output gives the component sizes across the full catalog. Each per-pool row contains the number of references, structural components, unordered pairs in those components, fixed-command components and unordered pairs in the latter components, in that order. The student–oracle totals come from the separate native student–oracle ledger. File hashes in files.json bind these results to the original sources and the two measured engines.
