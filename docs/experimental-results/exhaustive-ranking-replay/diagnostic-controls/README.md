# Revision-bound diagnostic controls

The full ranking experiment ran on `177500af`. The separate diagnostic revision `2ab010c6` updated two standalone harnesses, restored their pinned Alloy fixture, and added the harnesses to bounded CI. The two JARs have 1,582 distinct class paths in total. The only changed class files are the two harnesses and one nested record in the retained-completion harness. The other 1,579 class files have identical SHA-256 digests.

Run this reader with Python and a Git checkout containing both commits.

```sh
python3 -B diagnostic-controls/verify.py --repo /path/to/ACGN
```

The `disjoint` directory contains 208 parser and source checks, actual Solver SAT/UNSAT results for a grouped disjoint declaration, and the native cost and operation contrast in each direction. The `retained` directory records 113 checks including both SASE orientations, 28 native observations across seven revisions for two historical controls, and the source programs and formulas used to check vacuity and exceptions. `native-receipts.zip` contains the full native evidence behind each historical observation. `build` and `bounded-ci` record the class inventories, registered builds, and exact-source CI output. All individual harnesses and probes ran separately from the ranked-corpus census.

YKy8 genuinely cost 20 on the earlier normalized endpoints. Its old student prefix included unused Class and Group binders. Removing those slots added the two required empty-domain guards to its matrix, giving a distance of 22. Its earlier 20-cost program fails to replay on the new normalized endpoints in either direction. In xJnit, projecting both `all ps:Project-p` clauses into intersection checks preserved the exception and brought the matrix cost from 47 to 33. The declaration cost stayed 2.

JDK 17, Git, and tar can reproduce the registered class files and both standalone harnesses in a fresh output directory.

```sh
python3 -B diagnostic-controls/replay.py --repo /path/to/ACGN --output /unused/output/path
```
