# A2-25 wire commitments

Original claim SHA-256 is `a216882498a514d63ccf4a77326d4b68e46ca2296012892d295bb0ec23687c0a`. The requirement covers the complete correlated type DAG, the dependent combination matrix, and rejection of pre-v10 inputs. The live matrix maps this structural requirement as `PROVED/DIRECT`. The ninth qualification decision depends on the frozen two-build result and original-claim checks.

## Admitted inputs and observations

The producer emits the application’s kind, context, output type, and structural key, followed in order by left input, right input, output DAG, and combination matrix. Child paths in the formal composition select an application of that exact arity inside the tree belonging to the schema-checked envelope.

| Wire value | Fields whose order and identity are retained | Independent replay |
| --- | --- | --- |
| DAG | Relation family, common type or `NONE`, positive arity, DAG key and indexed alternatives | Resolves relation, verifies empty arity or product cardinality and order, recomputes normalized alternatives, common ancestor and key |
| Product | Alternative index, product relation type, key and ordered columns | Checks the exact expected index and type. Uses index `-1` for a case result |
| Column | Exact atomic type, key and ordered ancestry steps | Checks every step, starts at the exact column, rejects repetition, registers consistent ancestry, checks key |
| Matrix | Decimal cardinality and ordered pair records | Derives the complete Cartesian index grid from the two operand DAGs. Checks its cardinality and every cell |
| Pair | Left and right index, decision, key, boundary and optional result | Compares each position to its independently derived pair, expected decision, witness, resulting product and derived key |
| Boundary | Rule, left, right, meet or `NONE`, common ancestor, key, ordered left and right witness paths | Replays both endpoints and paths. The distinct absent-boundary tag carries only `ARROW`; the distinct absent-result tag carries only `DISJOINT` |
| Schema | Bundle tag, one exact scalar `acgncert-schema-v10`, 12 sections | `Bundle` checks the version ahead of section interpretation. The direct bare-header controls observe `UNSUPPORTED_FORMAT_VERSION` for each v0 through v9 |

Published profiles resolve exact structural type IDs in the bound type table. The TEST_ONLY profile also accepts display names. Admitted atomic column and boundary types are INT or a validated `AlloySig:` constructor. The exact type's published ID and its admitted TEST_ONLY display are distinct from the optional `NONE` sentinel. The two lexical forms under TEST_ONLY can resolve to the same exact type. Their different raw spellings remain visible in the payload.

The 16 Lean declarations establish field-model left inverses and injectivity, coverage and ordering for every admitted pair using the A2-24 grid, and the schema-qualified read at the selected address. `admitted_payload_commitment` also composes the fifth canonical binary decoder’s exact-reencoding theorem for the same tree and eighth P6-11’s schema guard. The independent decoder requires canonical UTF-8 and compares the re-encoded payload in its ordinary public opening path. The model and linked code checks are scoped to admitted inputs within JVM resource and size limits. Trust includes the pinned Lean kernel, standard library, JDK, JVM and codec execution. External JOIN hierarchy authority is a separate semantic premise.

The JDK resolves 41 complete method bodies and their call targets. The reviewed inventory also freezes 15 emitted constructors, 13 decoder shape checks and 53 scalar/child observations. The binary field witness passes actual decoded producer subtrees to the executable Lean decoder, then re-encodes and compares the full trees, including every key, field, order and sentinel. Twenty-nine complete subtrees from five fixtures passed.

The integrated JOIN leaf reconstruction changed the compiler-resolved body of `SemanticReplay.dependentChainInput` and the positions of its field and shape checks. Comparing the earlier 122-row inventory with the combined source failed before wire replay. The final register retains 122 observations and has SHA-256 `cced611814829f1db504f26073f2f1cd09f6eb4f615b96ab12967766eb838808`. The independently rebuilt producer, verifier and five fixtures reproduced both registered output hashes.

| Fixture | FULL | DAGs | Matrices | Pairs | Disjoint | Empty DAGs |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Relation columns | UNCHECKABLE / MISSING_EVIDENCE | 5 | 2 | 2 | 0 | 0 |
| Correlated family | UNCHECKABLE / MISSING_EVIDENCE | 3 | 1 | 4 | 2 | 0 |
| Empty JOIN | UNCHECKABLE / MISSING_EVIDENCE | 3 | 1 | 1 | 1 | 1 |
| Typed-empty interior JOIN | VERIFIED | 5 | 2 | 0 | 0 | 3 |
| Nested raw Alloy ARROW | VERIFIED | 5 | 2 | 2 | 0 | 0 |

The three subtype-dependent fixtures have internally consistent evidence and lack independent hierarchy authority. The nested ARROW receives independently derived source and CALL pins from the exact raw predicate. All five runs use the registered TEST_ONLY fixture theory. Qualification pins are `737eab9f85c388af00a8cfe45bf662738580d710d3359799bbdd493ca066b45a` for `wire.tsv` and `f717dbb72cf9ff4c8008923fc623a7ad000fb5aba559f7ef0564ef717d89d357` for `controls.tsv`.

## Numeric spelling and fifth regression

The shared `Bundle.parseUnsignedLong` first rejected empty and ASCII-leading-zero forms, then called `Long.parseLong`. The JDK accepts a leading plus, signed zero and Unicode decimal digits. The integrated decoder compares a successfully parsed nonnegative value’s ASCII decimal rendering to the input. Negative values and overflows retain `INTEGER_OVERFLOW`. The direct scalar test checked five canonical values, seven noncanonical spellings and four invalid or overflowing forms.

JDK 17 resolved the four fifth-extractor source owners against the integrated producer, verifier and library JARs. The extractor from `e901db10` rejected the `Bundle` fingerprint and emitted no TSV. The integrated extractor accepted all four owners and emitted TSV SHA-256 `1679130624064a5551b4a87fa833f8ba3d118a7dcc01fbd8a2729c1e4593086a`. The other three owners retained their earlier fingerprints.

| Bundle inventory | Source AST SHA-256 | JDK binding SHA-256 |
| --- | --- | --- |
| Before | `ff78efef7d57a6ddc37bc35609a758d3ae1d5c7b453f75ae1851540d8dc11131` | `6d2831b66e4cb1a1741ae5a8131914dad3c9ac1f3da953d36fb6bc67f0851e88` |
| Integrated decoder | `b5ab7ad78b5ae92241ca41a0289bc50627d2a61147373b5bbb53cfeb5a256844` | `14faf8f16f685d2d728a031f4a60445144f6dd3702a48bac25abe1609a67659f` |

The fifth Java extractor and Python replay inventory use the same values. All 16 fifth wire-table unit tests passed on the integrated checkout. They include `test_previous_bundle_numeric_decoder_pins_are_rejected`, which rejects each old fingerprint separately and both together, and the existing writer stale-pin checks. The complete two-build fifth closure has its own result.

The focused A225 run used the integrated producer JAR `3d4d221eca9ef1eb0678b5c05f4e46312a7bfa779cbaa8abaa51a80dc71d814d` and its fresh schema-coverage fixtures. The independent verifier build and the distributed `certificate-verifier/build/acgn-certificate-verifier.jar` both had SHA-256 `5079aac45b9205fc834b980bf76fabe110fcba0ce75f64f721efe0a960f124d8`. Using their compiled classes, the focused Java witness reproduced the five fixture outcomes and both output hashes above.

## Replay

Compile `CanonicalWireTables.lean`, `P611SchemaAdmission.lean` and `A224Join.lean` as fresh modules under Lean 4.35.0, then compile `A225WireCommitment.lean` into the same private import directory. The runtime Lean witness receives only that directory through `LEAN_PATH`. Compile the three A225 Java classes with the ordinary producer/verifier classes, libraries, and the seventh `RawArrowSourcePin` and `RawArrowOccurrenceAuthority` sources. Run with the governing TEST_ONLY JAR and epoch properties.

```text
org.acgn.cert.A225WireCommitmentTest SOURCE METHOD_INVENTORY COVERAGE LEAN LEAN_WITNESS OUTPUT_TSV
```

No full corpus or remote run is involved in this focused candidate evidence.
