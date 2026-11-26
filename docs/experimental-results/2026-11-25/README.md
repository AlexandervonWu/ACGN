# v3.2: Correct reference pools

The same 181 invariant pools contain **4,496 unique raw ASTs, 2,074 v3
canonical forms, and 1,954 v3.2 canonical forms**. Each representation is
counted within a question and invariant, then summed. The v3.2 counts include
command-scoped equality, not global interchangeability. For example,
`trainStationNew/inv5` has **43 / 23 / 1**.

[Figure: every invariant](forms-by-invariant.pdf) · [Download the three counts for all 181 pools](forms-by-invariant.csv).
To rebuild both from the release inputs and check the raw denominator per pool,
run `python3 docs/experimental-results/2026-11-25/render_forms.py` (Matplotlib).

The finite population is 4,496 distinct-AST correct references, including oracle
references. Every unordered pair within each pool was measured: 132,032 pairs,
264,064 reader directions. The five scoped readers matched 1,234 pairs.
Adding a link need not reduce the number of components:
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
