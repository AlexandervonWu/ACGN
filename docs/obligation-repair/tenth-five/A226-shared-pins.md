# A2-26 shared compiler fingerprints

The two changed methods in `TheoryAlloyAdapter.Builder` are `dependentChainInput/7` and `dependentTypeDagForSource/2`. The former now sends PLUS and INTERSECT operands to the recursive checker even when Alloy reports a unary integer family. The latter reconstructs that family with the existing primitive lift, recursively checks homogeneous operands and refuses a mixed representation with no common authority. The ordered operand walk, typed empty arity, occurrence-evidence comparison and cycle guard are covered by the [A2-26 source and proof correspondence](A226SourceAgreement.md).

The ninth base is `8b068de6199f561f683681e9a74f4c400a43c640`. The raw adapter source changed from `12990ed5fce6717a72f0fd15f2dc3eb580a4c121acef8cd9360b536e8f14a76a` to `d528e9b39ade3879af3dda6482647e55a1ce7fdc3fdb1ba93a819ce08521f33f`. The focused run checked the SHA-256 of all 608 producer Java inputs and eight compiler JARs against the tenth producer manifest. The ordinary A2-26 witness ran against the resulting JAR `7c971f3e8d4c03b73c37be441c1fb04697f8197d9f393a343c435942aa4705f4`. The standalone verifier JAR was `5079aac45b9205fc834b980bf76fabe110fcba0ce75f64f721efe0a960f124d8`.

## Registered compiler changes

| Object | Ninth shape or aggregate | Ninth bindings | Tenth shape or aggregate | Tenth bindings |
|---|---|---|---|---|
| Whole adapter, fourth container and fifth flat-container/source-occurrence | `b583b8d4c87dc505d5391eafeffa3e2927c504dd29836a4a185481eb77f9e7c5` | `c7e96284672950a308c81ed1e6741ba5b626e0988cf58aa2dc9854b290500fec` | `f1fa121d2b059147dc2af5bf7e44531585c147cf827a7aa6138aec658bca9d6c` | `d9551bea070c3fd486e496ba2e9daacaae558c862bddbffae0fb9bbd9104bdb5` |
| Next adapter barrier, `dependentChainInput/7` | `e85148fc525fbd3f0976e00ae778add3109d3435f9c13e5f08a9eb7e6a9fa650` | `2a28bdf9a25d77fa01eba72bf7a70c4874dd0b0afdf0c98299064284b7dbc8a2` | `c90cc7354bb910cafe1298406bb1061b9530115c733a0b0b73de57baacf58830` | `3bf71ec4f6e4ec545f68daa851d156d8421bfaabe66f46025f6e666d5c89d2d5` |
| A2-22's 37 attributed methods including `dependentTypeDagForSource/2` | `5b2051216c1dbc4774eca5f013538389cd6e2e98ae152968cf6108863352cc63` | Included in aggregate | `b4708dea1cc5e281292dccc8007282a16e68c2d7ea17033993809c071e24995b` | Included in aggregate |

For the A2-22 lower-level comparison, hashing each registered method key and its existing observations separately with the checker's four-byte length prefix found one change. The recursive adapter method went from 35 observations (`44aac4379e5d937115dd45d04e8588afaf2ac09fecd73d59826ec0955a47f99b`) to 48 (`3c21c90d4ebc4fbf3779a346d984bcae64bddcf808b01eb635b3763fde78d73a`). The other 36 method records were byte-identical. The original and refreshed strictly pinned checkers were also run separately in both directions on the two raw adapter sources. Each checker accepted its registered source and refused the other with no fresh receipt.

## Integrated focused checks

| Normal entry | Observed rows | Receipt SHA-256 |
|---|---:|---|
| Next chain compiler | 28 | `9e5a89639b23be77c779d4d0b1482ab554fc8d746c151c0de363433aee9e6a16` |
| Fourth container compiler | 14 | `3d07c5a7fd83fef7c428dd00a5d8d6d9c8ee4a4b229cd0f61fd3043b3a106a3c` |
| Fifth flat-container compiler | 14 | `3d07c5a7fd83fef7c428dd00a5d8d6d9c8ee4a4b229cd0f61fd3043b3a106a3c` |
| Fifth occurrence compiler | 7 | `076371e31e5491d55149fe654730578b6c4d356e28a93ae791529d7415029126` |
| Third CALL compiler | 43 | `b54d6a5b9f47c2b878e7fab4aba3e6abca1f3aeb7e2ae6aff9a2f2a820066568` |
| Sixth retained-read compiler | 229 | `4060c2797d27e1622c281e994ccadaaabfce9f611d637d2cf743f6e0ec5cf25e` |
| Ninth A2-22 parser and compiler interchange | 139 | `21a3b9eb679b9a052fd7f1a7edd1f9b3ecbee64f5819b45d92c3286813faf1f0` |

The four Python suites passed all 55 tests. Their superseded adapter controls independently substitute the old shape, the old resolved bindings and both together into each current inventory. The next replay checks owner, method and arity as well. Its two pre-existing verifier-method pins and previous rejection cases remain registered.

```sh
cd scripts
python3 -B -m unittest test_next_obligation_replays test_fourth_container_replays test_fifth_flat_container_replays test_fifth_source_bindings_replays
```

The normal A2-26 witness passed 15 attributed methods, the genuine compiler program and five rejected omissions, plus 21 source and boundary observations. All four output hashes matched the tenth registration. The A2-22 witness passed its 100 parser coordinate decisions, 15 family cases and five input controls against the same tenth producer. The focused check covers the registered sources and observations. The multi-build qualification remains the responsibility of the ordinary release gate.

The live ninth registry accepts the new A222Javac helper SHA-256 `c75533fbc6710d4a67c75e09b3cbbd7d5b49a109f50c99093ed87012e4828cfe`. The registry hashes to `d7cd09092a883932a9b81c74787d61c819cbfbad2c349353cfb6e8bbe194199c`. Its driver hashes to `55c93a6c7dcd7fa74275a04c5997901200e22b18b1f27ef51943c7efb3abbd5d` and continues to pass `-j1` to Lean. The actual driver's `--check-registration` accepted the five ninth original rows, 18 Lean modules and 39 source inputs.
