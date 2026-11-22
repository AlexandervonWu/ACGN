# P5-08 and A2-16 inherited compiler inventories

The measurement starts from tenth source commit `9f7c75a99b534dc5c490e23a314c0bb0d8d45a06`. The ordinary JDK 17 fifth source-occurrence extractor rejected the eleventh input at precisely two classes before its observed fingerprints were admitted. The independently compiled eleventh producer JAR has SHA-256 `bceecd047bcb38057a91993bb8f3f8d53def7087f91a6f1583525942973df7d9`. All 1,487 class files on the focused test classpath matched the corresponding entries in that JAR byte for byte. This includes 63 class files recompiled for these three source units. The standalone verifier JAR remains `5079aac45b9205fc834b980bf76fabe110fcba0ce75f64f721efe0a960f124d8`.

| Producer source | Tenth SHA-256 | Eleventh SHA-256 | Reason for the change |
| --- | --- | --- | --- |
| NormalForm.java | `2b0f5c32da07a665a16334b9eb23fd39deaf81aac395179d56582d34e7ef7601` | `6f14261e583c47d80c414e7530d903447b23ad27085d5818f8d521cf391e307c` | The domain descriptor records whether multiplicity is known. Canonical empty-binding reductions require real variable slots and a known nonempty-binding multiplicity. Bare, typed nonunary empty relations admit the empty binding. |
| AlloyRewriteSystem.java | `a98040889ff893a1676e5b108cb4924c86f4761bf4a85faeb0114b8c16e5b424` | `0244f0a37a11badc6e105ae74dc167590454053b7411d5df5d85f6d4d28cc4f6` | The raw rewrite retains the authenticated declaration domain needed to recognize the unary case and restores the application count for a discarded child rewrite. |
| TheoryAlloyAdapter.java | `d528e9b39ade3879af3dda6482647e55a1ce7fdc3fdb1ba93a819ce08521f33f` | `4b28a5b29e8c626a2692b46eaa7dd36dfbf69df054986d81b8a9df1233819226` | Builder.requirePristineCertificationSources now checks the e-class identifier against its original object during the existing source preflight before the integer-keyed downstream caches are used. |

## Class and method measurements

| Governed class | Tenth shape | Eleventh shape | Tenth compiler bindings | Eleventh compiler bindings |
| --- | --- | --- | --- | --- |
| NormalForm | `1d474aa7f9f55da081178b49c447d4fe419dc47ef110688b0b3bf7d69759b80d` | `9201ffa8694acaee24f9ad339f45e408d2bf2ad7a2487acb89f9aea5b2f0a4d0` | `8894eeeffd4d64552180d580618f16d4a05e85d29fb849026a02e74c9cedce80` | `9d13dee91fcd9bf8134f6dbf254c12a4b6e21b024b94ae6cf789271185ef3018` |
| TheoryAlloyAdapter | `f1fa121d2b059147dc2af5bf7e44531585c147cf827a7aa6138aec658bca9d6c` | `89e33afd140ddd409f2650d21242d63879af171ac61b67e2009b52f71064756f` | `d9551bea070c3fd486e496ba2e9daacaae558c862bddbffae0fb9bbd9104bdb5` | `bc3842ae59efb585a3b27fd0e02406f16f5db8e446ec51dd5844d437da2e3aaf` |

Three Java inventories and their corresponding Python inventories observe the adapter. The fourth container and fifth flat-container extractors each returned 14 objects, with exactly the adapter changed. Their TSVs share SHA-256 `007259510a31d30ca8e079dc56a25972007eb9b4f60390ef4e52bfcfbeba0916`. The fifth source-occurrence extractor returned seven objects, with exactly the two table rows changed, TSV SHA-256 `4de0e433c2f5d887c53bffe9ee06b0b1f8c1ab753b25c1190d428f077348f2db`. Their 48 Python unit tests passed. Each affected encoder rejects the old shape, old binding and complete old pair for each affected object. All earlier historical rejections are retained. The A2-16 edit is confined to the pristine-source preflight. It does not edit the separately selected recursive dependent-type or next-chain methods.

The ninth P5-06 compiled-method inspector rejected the real candidate specifically at NormalForm.domainDescriptor. Its old method SHA-256 was `2310aa75c11589f4a723125e1580b2051d1cd67c3d0ed3b52f37d107bfa85161` and the candidate is `af2cf4fb6a99482b67146b4acbac1742bef85a33e52818f937b7247253164a7b`. Its 55-method inventory now hashes to `e4c3937126add5bec9f9401d2fdbb036faacef077e0727536fbfe5adab833fb7`; all 54 other registered methods passed their original tests. An explicit previous-domain rejection joins the existing stale guard and shallow-adapter rejections. The real eleventh inspector rejects the tenth class in the reverse comparison.

The tenth P5-11 compiler frontier grew from 145 methods and 1,361 resolved symbols to 146 methods and 1,380 symbols. The real tenth inspector rejected the candidate aggregate `b24b9913d7f940e51c9b818e8db806bf7ca0c121ecedad37ae5dfb4060a95b1a`. The refreshed inspector rejected the genuine tenth aggregate `416f8582fbb0f215ceb3a7386e894303a25761cb4330a81bc7b9de51cf992e2b` against its original source and immutable producer JAR.

## Focused outcomes

The prior source-binding and lexical outputs were compared row by row to both builds in the checksum-verified tenth release archives. Only the compiler inventory line changed in each file. P5-06 still passes 24 cases; P5-11 still passes its six methods, 17 cases, and 145 reported observations.

| Original witness | New raw evidence SHA-256 | Comparison with tenth |
| --- | --- | --- |
| P5-06 source-binding-nonempty.tsv | `c39c494b856050db1d0de302a55761dec17f91ffff48a81082a72f65beb9358d` | Only compiler-methods changes; old file `4e9399cbba3d0896b4ce4b1c8ef8cc033754465febdccbbfc7aad121fa3a3d99`. |
| P5-11 p511.tsv | `5b87be0341b8f5b8ba6440b8cd889313de9ef0e556f4be26d14913c244b40e33` | Only source/JAVAC changes; old file `20084238bdffdb87d319aa7d95833173ab57ab9fa9130edcea525b3ae5a64ede`. |
| P5-11 p511-frontiers.tsv | `5df485f28d5fc9ec08c500295e993e1283d67593b17a877e9b883797ec5d01aa` | Identical. Lean replayed 108 frontiers, 66 authorized, 42 guarded and three controls. |

The unchanged P5-05 and P5-07 checks retained their 27-method binding and all 432 compiler decisions. Each replay passed its four stale controls and its original case file, with 24 and 27 observations respectively across six raw configurations. The rewrite dispatch parity check passed. The P3-13 retained-read census matched all 229 rows, SHA-256 `4060c2797d27e1622c281e994ccadaaabfce9f611d637d2cf743f6e0ec5cf25e`.

The normal retained-source fixture produced 171 observations and passed 22 checks, TSV `823699184401598b732d5aa5e2f5bc4af3a08f92e74fc14165a4f353b64b132b`. The updated strict source rows and actual observations generated 189 Lean replay statements, all accepted. The flat-container fixture emitted 311 rows and passed 11,666 checks (`7b7058396e3bc1c43e2c4ae1be4c35fca042083618e406a5864c60aae3ff3647`). The combined container fixture emitted 1,617 rows and passed 106,624 checks (`39099895569fd04e6015fe55f0c4bfee995b75ae0efaa54df504906dc5203e32`).

These measurements cover the named source inventories and focused witnesses. The full registered clean-build reports have their own input roots, outcomes and retention records.
