# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 6601
- Successful distances: 6318
- Skipped identical raw AST predicate pairs: 283
- Failures: 0
- Average distance: 12.201171
- Average predicate-body Levenshtein distance: 52.536087
- Average raw AST tree distance: 24.199114
- Average raw AST size: 27.069326
- Average canonical form size: 15.956790
- Average normalized raw AST distance: 0.875323
- Average normalized canonical distance: 0.732397
- CORRECT models with canonical distance 0 and raw AST distance > 0: 15
- Min distance: 0
- Max distance: 76

## Reward Comparison

- Rewarded files: 6318
- Reward failures: 0
- Reward pool size: 10
- Average candidate reward: 0.452061
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.547939
- Pearson correlation sample: non-CORRECT rewarded predicates (4827 files)
- Pearson correlation, distance vs candidate reward: -0.021312

- Pearson correlation, Levenshtein vs candidate reward: -0.068562
- Pearson correlation, raw AST tree distance vs candidate reward: -0.097240

- Pearson correlation, normalized raw AST distance vs candidate reward: 0.007276
- Pearson correlation, normalized canonical distance vs candidate reward: 0.030608

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1115 | 1115 | 0 | 0 | 13.503139 | 0.236341 | -0.112388 | 1 | 46 |
| classroom_fol | CORRECT | 536 | 495 | 41 | 0 | 9.705051 | 1.000000 | 0.000000 | 0 | 45 |
| classroom_fol | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 10.986547 | 0.358411 | 0.176288 | 1 | 44 |
| classroom_fol | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 10.915663 | 0.225969 | 0.023410 | 1 | 43 |
| classroom_rl | BOTH | 1115 | 1115 | 0 | 0 | 13.503139 | 0.236341 | -0.112388 | 1 | 46 |
| classroom_rl | CORRECT | 536 | 495 | 41 | 0 | 9.705051 | 1.000000 | 0.000000 | 0 | 45 |
| classroom_rl | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 10.986547 | 0.358411 | 0.176288 | 1 | 44 |
| classroom_rl | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 10.915663 | 0.225969 | 0.023410 | 1 | 43 |
| cv_v1 | BOTH | 68 | 68 | 0 | 0 | 16.544118 | 0.203547 | -0.160276 | 1 | 32 |
| cv_v1 | CORRECT | 69 | 52 | 17 | 0 | 16.461538 | 1.000000 | 0.000000 | 1 | 42 |
| cv_v1 | OVERCONSTRAINED | 118 | 118 | 0 | 0 | 17.627119 | 0.206796 | -0.404155 | 1 | 43 |
| cv_v1 | UNDERCONSTRAINED | 55 | 55 | 0 | 0 | 16.581818 | 0.101278 | 0.012469 | 3 | 37 |
| cv_v2 | BOTH | 21 | 21 | 0 | 0 | 20.142857 | 0.346685 | -0.141772 | 7 | 36 |
| cv_v2 | CORRECT | 34 | 31 | 3 | 0 | 18.612903 | 1.000000 | 0.000000 | 6 | 42 |
| cv_v2 | OVERCONSTRAINED | 40 | 40 | 0 | 0 | 23.025000 | 0.278267 | -0.405322 | 6 | 45 |
| cv_v2 | UNDERCONSTRAINED | 12 | 12 | 0 | 0 | 15.583333 | 0.108333 | -0.344285 | 2 | 43 |
| lts | BOTH | 138 | 138 | 0 | 0 | 11.434783 | 0.146087 | 0.161681 | 1 | 38 |
| lts | CORRECT | 112 | 65 | 47 | 0 | 5.338462 | 1.000000 | 0.000000 | 0 | 27 |
| lts | OVERCONSTRAINED | 113 | 113 | 0 | 0 | 10.575221 | 0.299921 | -0.015140 | 1 | 33 |
| lts | UNDERCONSTRAINED | 66 | 66 | 0 | 0 | 8.272727 | 0.083033 | 0.211706 | 1 | 24 |
| production | BOTH | 22 | 22 | 0 | 0 | 7.409091 | 0.089563 | 0.523127 | 1 | 24 |
| production | CORRECT | 45 | 25 | 20 | 0 | 6.840000 | 1.000000 | 0.000000 | 0 | 10 |
| production | OVERCONSTRAINED | 25 | 25 | 0 | 0 | 6.440000 | 0.000000 | 0.000000 | 1 | 17 |
| production | UNDERCONSTRAINED | 36 | 36 | 0 | 0 | 6.861111 | 0.880088 | 0.182854 | 2 | 21 |
| train | BOTH | 277 | 277 | 0 | 0 | 22.574007 | 0.393268 | 0.130498 | 2 | 76 |
| train | CORRECT | 102 | 76 | 26 | 0 | 10.026316 | 0.995215 | 0.000000 | 0 | 34 |
| train | OVERCONSTRAINED | 170 | 170 | 0 | 0 | 14.988235 | 0.697817 | -0.013290 | 1 | 46 |
| train | UNDERCONSTRAINED | 178 | 178 | 0 | 0 | 17.606742 | 0.302345 | -0.153879 | 1 | 61 |
| trash_rl | BOTH | 267 | 267 | 0 | 0 | 5.970037 | 0.313037 | -0.124057 | 1 | 28 |
| trash_rl | CORRECT | 340 | 252 | 88 | 0 | 6.349206 | 1.000000 | 0.000000 | 0 | 16 |
| trash_rl | OVERCONSTRAINED | 150 | 150 | 0 | 0 | 5.646667 | 0.393347 | 0.023927 | 1 | 24 |
| trash_rl | UNDERCONSTRAINED | 63 | 63 | 0 | 0 | 9.777778 | 0.363508 | -0.230459 | 1 | 22 |
