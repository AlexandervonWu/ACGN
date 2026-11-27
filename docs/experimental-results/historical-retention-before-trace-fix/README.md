# Coverage before the paid witness fix

The full run on clean commit `239fddc01a67477d222c31a6084702ce72083859` retained every structural pair in the archives. Fast Rewrite and Certificate-Integrated recognized 5,137 correct student–oracle pairs and 19,271 direct reference pairs. Their native operation traces matched on all 61,598 distinct-AST student–oracle comparisons and all 19,271 structural reference zeros. Both engines agreed on all 1,894,168 paid reference scores.

A separate native replay checked 4,138 paid reference pairs with repeated quantifiers across an alternating prefix. In 83 cases the engines chose different declaration permutations at the same minimum cost. Replaying those same forward comparisons on v3.3 showed that 57 had matched and 26 already differed. [All 83 source pairs and first differing actions](native-reference-nonmatching.jsonl) · [Trace census](native-reference-summary.json) · [Replay by revision and direction](paid-witness-attribution.jsonl)

The next experiment retains these structural gains and checks the paid witnesses in both directions. The frozen coverage floor below includes this run's positives in every subsequent edition. [Run receipt](run-receipt.json) · [Historical retention](historical-coverage.json) · [Coverage floor](historical-pairs.json.gz)
