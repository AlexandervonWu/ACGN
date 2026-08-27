# Full-Corpus Non-Temporal P0 Repair

## Boundary

This bounded repair inspected the 241 failures emitted by the supervised run at
`/tmp/acgn-luna-supervised-20260826T215920`. It did not modify experimental
outputs or `classified-data`, add a rewrite family, or alter the temporal repair
projection. The main integration agent owns temporal partition remapping and
strict-prenex scope propagation.

## Failure Census

| Family | Count |
| --- | ---: |
| source-lineage / dependent chain | 96 |
| dependent type / stored vs parser | 33 |
| import / missing pin | 27 |
| dependent type / DAG vs exact | 19 |
| dependent type / source vs ACI closure | 14 |
| temporal / missing certification matrix reference | 14 |
| temporal / unreachable phase | 11 |
| BAG / uncertified instance | 7 |
| temporal / missing live matrix reference | 7 |
| binding / unbound normalized variable | 6 |
| law / disjoint commutativity | 3 |
| source-lineage / call | 2 |
| dependent type / Boolean exact sort | 1 |
| source-lineage / local binder | 1 |
| **Total** | **241** |

The four requested non-temporal clusters initially covered 200 failures:
99 source-lineage, 67 dependent-type/DAG, 7 BAG, and 27 imports. The 41
remaining records were 32 temporal, 6 binding-scope, and 3 disjoint-law
failures. A later integrated replay reduced the residual set to 33: 18
`util/integer/max/EXPRESSION/0`, 6 source-vs-repair chain closure, 6 unbound
temporal variables, and 3 disjoint carrier failures.

## Minimal Corpus Witnesses

| Family | Witness |
| --- | --- |
| dependent-chain lineage | `classified-data/graphs/under/oisjGf4FHY7ybsDNY_inv6.als` |
| local-binder lineage | `classified-data/lts/both/hFtGTLM2gs79Rewif_inv4.als` |
| CALL lineage | `classified-data/coursesOld/both/hW9r9W2369vQGhBv5_inv13.als` |
| DAG vs exact type | `classified-data/graphs/under/mwErw7ZWCMusvp6BG_inv7.als` |
| stored vs parser type | `classified-data/lts/under/mqQuos5H6GQBSv375_inv4.als` |
| Boolean exact sort | `classified-data/trainStationNew/both/8gHAegWhaGCAkwRvP_inv5.als` |
| BAG instance | `classified-data/graphs/both/QcRD5957JiXbxbX69_inv3.als` |
| imported nullary call | `classified-data/trainStationNew/under/DMXEQCwkZDKHBrj68_inv4.als` |
| dot-applied integer maximum | `classified-data/coursesOld/over/BELuLQRupeCQWiBYW_inv13.als` |
| transpose/restriction closure | `classified-data/cv_v1/both/BATG5mJQrmFFWErWW_inv4.als` |
| disjoint unary carrier | `classified-data/trash_rl/both/M5ddBc6EYZS233e4n_inv9.als` |
| temporal free variable | `classified-data/trash_ltl/both/7MEWsRCR2QHykYucm_inv12.als` |

## Root Causes And Repairs

1. Trusted normalization may clone one parser occurrence. Identical
   dependent-chain, local-binder, or CALL payloads now reuse the one source
   proof; a differing payload under the same lineage still fails closed.
2. Exact parser unions now project to their parser-authenticated subtype
   antichain. A stored primitive slot is accepted as a relation subfamily only
   with the live parser ancestry that proves it.
3. Relational `some` is classified from the exact parser result sort instead of
   the overloaded opcode spelling.
4. Existing fixed commutative law instances are rebound to the exact repaired
   carrier after normalization. No new BAG equality was admitted.
5. The bundled `models/util/integer.als` declares nullary and unary overloads
   of both `max` and `min`. The imported-call ledger pins exactly those four
   `(module, member, kind, arity)` entries; unknown arities remain rejected.
6. Converse-of-join now closes the already-admitted endpoint-restriction rule
   on its two-child result and contracts an exact double converse produced
   while reversing an operand. This aligns source certification with saturation
   without adding or weakening a rewrite.
7. `AlloyCarrier(S)` is recognized as the unary relation carrier already used
   by dependent-chain leaf typing. Consequently `disj[f, f.link]` receives a
   valid homogeneous unary BAG carrier and the existing commutativity theorem.

## Resolved Temporal Handoff

Six temporal cases exposed `f` or `t` in a child phase whose normalized
form records neither a matrix binding nor an inherited binding. The smallest
example is:

```alloy
eventually some Trash and all f: File |
  f in Trash implies always f in Trash
```

The quantifier dominates the `always` occurrence in the source, so the leaf is
not globally free. GC-F224 now carries an explicit phase-local import from the
actual owner declaration into each temporal child. The certificate binds
source lineage, owner and target phase paths, binder context, coordinate, slot,
and exact graph type. It does not infer scope from the leaf or merge sibling
phases. See `temporal-phase-local-binding-incident.md`.

## Verification Assets

- Java: `FullCorpusNonTemporalP0RegressionTest`
- Lean: `formal/FullCorpusNonTemporalP0.lean`

The Lean model proves exact overload arities, unary primitive-carrier arity,
converse/join and restriction closure, disjointness commutativity, and the rule
that only identical lineage payloads may reuse a proof. It contains no
`sorry`, `axiom`, or `unsafe` declaration.

## Bounded Check Results

| Check | Result |
| --- | --- |
| UTF-8 compile of all `src/**/*.java` | PASS |
| `FullCorpusNonTemporalP0RegressionTest` | PASS, 45 checks |
| `TheoryDependentChainTest` | PASS, 149 checks |
| `CallExtractionRegressionTest` | PASS, 160 checks |
| `EGraphSaturationTest` | PASS |
| six transpose/restriction plus three disjoint corpus replays | PASS, 9/9 |
| `FullCorpusNonTemporalP0.lean` | PASS |
| six phase-local temporal binder replays | PASS, 6/6 |
| complete historical failure replay | PASS, 241/241 |
| complete corpus after temporal handoff | PASS, 61,598 distances, 4,482 skips, 0 failures |
| `git diff --check` | PASS |

`MASGVisitorTypeRegressionTest` remains red at its directly-liftable guarded
binder assertion. That assertion depends on the main agent's currently owned
`NormalForm` carrier-lifting changes and is not caused or bypassed by this
non-temporal adapter patch.
