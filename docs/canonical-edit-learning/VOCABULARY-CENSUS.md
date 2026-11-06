# Compact Vocabulary Census

The historical `node_id.csv` was recovered read-only from commit
`0e0cdc8745b3f92b6ad98f4ef1dec519f177dc97` (the parent of the cleanup commit
`edbae587`). It contains **67 distinct symbol names**, with IDs 0-66.
Its SHA-256 is
`ea291a2c911aa31079dd5f28d2f4c8261dbcc12ed78f2371af36feefcd1ef12c`.

The requested built-in/literal set is `none`, `univ`, `iden`, `true`, `false`,
and integers 0-4. Exactly **four** are absent from that snapshot:
`none`, `univ`, `true`, and `4`.

- Historical collapsed semantic names: 67.
- After adding those four constants: 71.
- Replacing each of `Dummy for sig`, `Dummy for var`, and `Dummy for field`
  with eight distinct generic names: `71 - 3 + 24 = 92` semantic names.

This supports the author's under-128 budget for that inventory and extension.
It is not a complete language/corpus census: a different dataset may exercise
additional operators. Record unknowns and revise the versioned dictionary;
never hash them into an existing token or silently identify them with a generic.

## Relation To The Current Pilot

The raw-AST inventory and pilot alphabet are different representations. The
old inventory includes temporal, call, comprehension, branch and traversal
symbols such as `<END>` that are not admitted pilot matrix operators. The pilot
also needs record tags, action templates and numeric reference digits. It is
not assigned by copying the historical integer IDs.

The current scoped alphabet has **97 assigned IDs within 128**, including all
structural and numeric tags. Collapsing its three eight-entry banks back to the
already present SIG/VAR/FIELD operator categories leaves 73 assigned IDs. The
92 above instead counts the expanded *historical semantic names only*; do not
confuse that number with the pilot's complete transport-token budget.

Compact one-token banks:

- IDs 80-87: `$sig0`-`$sig7`.
- IDs 88-95: `$0`-`$7`, certified owner-scoped alpha coordinates.
- IDs 96-103: `$rel0`-`$rel7`, for fields and other named relations.
- ID 51: `iden`; IDs 52-56: integer literals 0-4.
- Existing IDs 27, 28, 43, 44: `true`, `false`, `none`, `univ`.

The three banks are disjoint, use canonical coordinates supplied by the
certified exporter, and preserve exact type/owner references in records and
sidecars. In particular, `$rel0` does not denote every field of the same type.
The actual source-to-coordinate exporter remains an open correspondence.
An encoding helper accepting a coordinate does not certify that coordinate.

`EdgeCounter.getSymbolForPretrain` is the earlier symbol-collapse mechanism;
it intentionally replaced signature/field/variable identities with generic
categories for counting. Separately, the more recent `rl/acgn_repair/model.py`
uses 4,096 hashed feature buckets. That is not a 4,096-symbol language census,
and those bucket IDs are not suitable identity keys for this token dictionary.

## Reproduction And Checks

[Generated census](results/vocabulary_census_v2.json) retains all historical rows,
source commit/hash, the current token map, accounting and verifier input hashes.
It can be regenerated from the repository root:

```bash
python -m experiments.hybrid_edit.audit_vocabulary \
  --output /tmp/vocabulary_census_v2.json
```

46 standalone Lean theorems compile; 23 Python tests pass, including the compact
bank round trips/disjointness, literal/reference distinction, bitwidth rejection,
schema-version rejection and historical CSV ambiguity checks. These are bounded
codec/model tests, not a proof of full Java/Alloy exporter correspondence. No
training was rerun for this vocabulary extension; model dimensions are unchanged.
