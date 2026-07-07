# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 6601
- Successful distances: 6318
- Skipped identical raw AST predicate pairs: 283
- Failures: 0
- Average distance: 12.466920
- Average predicate-body Levenshtein distance: 52.536087
- Average raw AST tree distance: 24.199114
- Average raw AST size: 27.069326
- Average canonical form size: 15.921494
- Average normalized raw AST distance: 0.875323
- Average normalized canonical distance: 0.746579
- CORRECT models with canonical distance 0 and raw AST distance > 0: 15
- Min distance: 0
- Max distance: 94

## Reward Comparison

- Rewarded files: 6318
- Reward failures: 0
- Reward pool size: 10
- Average candidate reward: 0.452061
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.547939
- Pearson correlation sample: non-CORRECT rewarded predicates (4827 files)
- Pearson correlation, distance vs candidate reward: -0.029143

- Pearson correlation, Levenshtein vs candidate reward: -0.068562
- Pearson correlation, raw AST tree distance vs candidate reward: -0.097240

- Pearson correlation, normalized raw AST distance vs candidate reward: 0.007276
- Pearson correlation, normalized canonical distance vs candidate reward: 0.045509

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1115 | 1115 | 0 | 0 | 14.209865 | 0.236341 | -0.146388 | 1 | 51 |
| classroom_fol | CORRECT | 536 | 495 | 41 | 0 | 10.060606 | 1.000000 | 0.000000 | 0 | 64 |
| classroom_fol | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 11.529148 | 0.358411 | 0.133882 | 1 | 44 |
| classroom_fol | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 12.680723 | 0.225969 | 0.124693 | 1 | 43 |
| classroom_rl | BOTH | 1115 | 1115 | 0 | 0 | 14.209865 | 0.236341 | -0.146388 | 1 | 51 |
| classroom_rl | CORRECT | 536 | 495 | 41 | 0 | 10.060606 | 1.000000 | 0.000000 | 0 | 64 |
| classroom_rl | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 11.529148 | 0.358411 | 0.133882 | 1 | 44 |
| classroom_rl | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 12.680723 | 0.225969 | 0.124693 | 1 | 43 |
| cv_v1 | BOTH | 68 | 68 | 0 | 0 | 17.897059 | 0.203547 | -0.210896 | 1 | 31 |
| cv_v1 | CORRECT | 69 | 52 | 17 | 0 | 19.038462 | 1.000000 | 0.000000 | 1 | 42 |
| cv_v1 | OVERCONSTRAINED | 118 | 118 | 0 | 0 | 19.296610 | 0.206796 | -0.268161 | 3 | 43 |
| cv_v1 | UNDERCONSTRAINED | 55 | 55 | 0 | 0 | 18.109091 | 0.101278 | 0.010752 | 3 | 37 |
| cv_v2 | BOTH | 21 | 21 | 0 | 0 | 22.571429 | 0.346685 | -0.153494 | 12 | 39 |
| cv_v2 | CORRECT | 34 | 31 | 3 | 0 | 20.774194 | 1.000000 | 0.000000 | 7 | 42 |
| cv_v2 | OVERCONSTRAINED | 40 | 40 | 0 | 0 | 25.225000 | 0.278267 | -0.198180 | 12 | 45 |
| cv_v2 | UNDERCONSTRAINED | 12 | 12 | 0 | 0 | 16.833333 | 0.108333 | -0.385959 | 2 | 43 |
| lts | BOTH | 138 | 138 | 0 | 0 | 7.833333 | 0.146087 | 0.160564 | 1 | 25 |
| lts | CORRECT | 112 | 65 | 47 | 0 | 5.338462 | 1.000000 | 0.000000 | 0 | 27 |
| lts | OVERCONSTRAINED | 113 | 113 | 0 | 0 | 7.088496 | 0.299921 | 0.068993 | 1 | 20 |
| lts | UNDERCONSTRAINED | 66 | 66 | 0 | 0 | 7.287879 | 0.083033 | 0.259705 | 1 | 24 |
| production | BOTH | 22 | 22 | 0 | 0 | 7.409091 | 0.089563 | 0.523127 | 1 | 24 |
| production | CORRECT | 45 | 25 | 20 | 0 | 6.840000 | 1.000000 | 0.000000 | 0 | 10 |
| production | OVERCONSTRAINED | 25 | 25 | 0 | 0 | 6.400000 | 0.000000 | 0.000000 | 1 | 17 |
| production | UNDERCONSTRAINED | 36 | 36 | 0 | 0 | 6.805556 | 0.880088 | 0.182063 | 2 | 21 |
| train | BOTH | 277 | 277 | 0 | 0 | 21.064982 | 0.393268 | 0.154983 | 2 | 94 |
| train | CORRECT | 102 | 76 | 26 | 0 | 9.710526 | 0.995215 | 0.000000 | 0 | 40 |
| train | OVERCONSTRAINED | 170 | 170 | 0 | 0 | 14.411765 | 0.697817 | -0.002259 | 1 | 47 |
| train | UNDERCONSTRAINED | 178 | 178 | 0 | 0 | 15.696629 | 0.302345 | -0.144203 | 1 | 62 |
| trash_rl | BOTH | 267 | 267 | 0 | 0 | 5.981273 | 0.313037 | -0.095787 | 1 | 29 |
| trash_rl | CORRECT | 340 | 252 | 88 | 0 | 6.468254 | 1.000000 | 0.000000 | 0 | 37 |
| trash_rl | OVERCONSTRAINED | 150 | 150 | 0 | 0 | 5.686667 | 0.393347 | 0.020431 | 1 | 24 |
| trash_rl | UNDERCONSTRAINED | 63 | 63 | 0 | 0 | 9.698413 | 0.363508 | -0.229267 | 1 | 22 |
