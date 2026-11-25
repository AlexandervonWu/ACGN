# v3.2: Correct reference pools

**1,954 command-scoped equivalence classes remain, down from 2,028** (74 fewer,
3.65%). These counts sum the connected components **within** each question and
invariant. They are not counts of globally interchangeable Alloy programs.
26 of the 181 pools changed; `trainStationNew/inv5` went from 23 to one.
See [every pool](question-pools.csv) and [the machine-readable summary](summary.json).

The finite population is 4,496 distinct-AST correct references, including oracle
references. Every unordered pair within each pool was measured: 132,032 pairs,
264,064 reader directions. Both v3.1 routes agreed on 11,882 original zero
pairs. The five scoped readers matched 1,234 pairs, of which 1,107 were not
already zero pairs. Adding a link need not reduce the number of components:
the endpoints may already be connected. All 105 native SAT pairs remained
outside a shared component. No link was added for an UNSAT result alone.

## Reproduce

From the tag's repository root, using Python 3.10 or newer:

```sh
python3 docs/experimental-results/2026-11-25/verify.py
python3 docs/experimental-results/2026-11-25/verify.py --live
```

The first command checks the release hashes, original reference bytes, and
each of the 132,032 generated Alloy modules against its recorded SHA-256. It
checks both orientations, every component and the SAT conflicts and reconstructs
the per-pool table. The second **also runs the packaged Java readers and native
solver** on all 1,234 positive pairs and 105 counterexamples (JDK 17). The other
no-match pairs are recounted from the frozen measurement, not re-solved by this
command. To inspect an individual check, use `verify.py --emit LEFT RIGHT`
with IDs from `pairs.csv.gz`, then use the [rule CLI](../../proven-rewrite-rules.md)
on the emitted module and select `correct`.

The compressed reference archive records the source path, digest, original
predicate name and generated module fragments. The pair archive retains both
reader decisions, native outcome, generated command digest and v3.1 zero flag.
The summary records the original experiment seal and 16 ledger hashes.
These are results for derived, checked pair commands in compatible contexts;
they do not replace the unchanged default metric, claim a 66,080-file reduction,
or establish unconditional equivalence.
