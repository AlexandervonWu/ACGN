# Fourth-obligation dependent type DAG source receipt

The A2-21 repair changes `DependentTypeDag.preferAuthenticated`. Before grouping equal ordered product keys, the constructor checks that all live parser authorities belong to the same module and that every carrier has a consistent ancestry. The earlier method selected one entire row using two stream predicates. The corrected loop retains the original authenticated column at each matching index. No product key, tuple index or source column is synthesized. The new array, index operations and copy calls change the attributed class text and its resolved bindings.

On JDK 17.0.21.1, the existing `DependentChainWitnessesExtractor` analyzed the full producer and verifier source trees with the eight tracked classpath JARs. The JARs are byte-identical between the eighth baseline and ninth checkout. Its thirteen-row source receipts differ only for `DependentTypeDag` and the separately repaired standalone `SemanticEvidenceVerifier`. The old checker rejected both changes on ninth sources and emitted no receipt.

| SHA-256 | Eighth | Ninth |
| --- | --- | --- |
| DependentTypeDag.java | `6bfcc55db74a7861fc3801e749dcae2a42653931667c4b88d1f28d30936e0df5` | `007ee9b38389c5db8da16281157861e6a9ae6aeb7a99720e643136103cde3450` |
| Attributed class shape | `b6c18c3ca66eba2bdaba5385211ab9f557419ac6dc6f807659fef0c33acb5c4e` | `d0e5390424a0fcf56368320485e82a1dfe7eae62c4f6a8ca882182532df0c068` |
| Resolved binding ledger | `b52e7b1c6925e177d91e6202f01cd5ceb4786d0ce26d9c01ec8bf2972be90c42` | `1ac8f9b3fab9bcc74ca4712a5b9a3a3e0d3bb2d10f4b0682e1f23796d6bcd5d1` |
| Thirteen-row compiler receipt | `6f2cd96d54e4705562ba446f1674812b138db9940ef07e4d25f56e8737648dd9` | `23da328bf5d8bbff9d992b20c1893851c0a475f59af4861cd0c50520d4c93fb8` |

The Java extractor and `scripts/fourth_chain_replays.py` use the same measured pair. All 19 tests in `test_fourth_chain_replays` passed. The stale-source regression submits the old shape alone, binding alone and both together to Lean, and checks that the expected equality fails in each case. Lean 4.35.0 accepted the thirteen equality theorems generated from the integrated compiler receipt.

For the retained A2-07 and A2-11 surfaces, `DependentChainWitnessesRegressionTest` passed 19,108 checks with 48 bundles, 8,213 controls and 8,741 observation rows. Its output SHA-256 `39ad913f0c66c7e72cb4ff0368db59637b1a7e341e4f983ae9549c82028ffc89` reproduces the published fourth review. The registered replay generator accepted the two observed traces and emitted its 8,754-obligation module. The aggregate fourth two-clean-build gate evaluates that generated replay. [Fourth review](../fourth-five/review-chain.md)
