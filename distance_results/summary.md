# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 6601
- Successful distances: 6318
- Skipped identical raw AST predicate pairs: 283
- Failures: 0
- Average distance: 23.524217
- Average predicate-body Levenshtein distance: 52.536087
- Average raw AST tree distance: 24.199114
- Average raw AST size: 27.069326
- Average canonical form size: 27.386198
- Average normalized raw AST distance: 0.875323
- Average normalized canonical distance: 0.821393
- CORRECT models with canonical distance 0 and raw AST distance > 0: 14
- Min distance: 0
- Max distance: 86

## Reward Comparison

- Rewarded files: 6304
- Reward failures: 14
- Reward pool size: 10
- Average candidate reward: 0.451937
- Average ground-truth self reward: 0.999683
- Average reward gap: 0.547746
- Pearson correlation sample: non-CORRECT rewarded predicates (4815 files)
- Pearson correlation, distance vs candidate reward: -0.127843

- Pearson correlation, Levenshtein vs candidate reward: -0.068036
- Pearson correlation, raw AST tree distance vs candidate reward: -0.097545

- Pearson correlation, normalized raw AST distance vs candidate reward: 0.006427
- Pearson correlation, normalized canonical distance vs candidate reward: -0.045845

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1115 | 1115 | 0 | 0 | 30.309417 | 0.236126 | -0.218856 | 1 | 79 |
| classroom_fol | CORRECT | 536 | 495 | 41 | 0 | 19.109091 | 1.000000 | 0.000000 | 0 | 74 |
| classroom_fol | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 19.843049 | 0.358411 | 0.212912 | 1 | 56 |
| classroom_fol | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 21.963855 | 0.225521 | -0.076754 | 1 | 73 |
| classroom_rl | BOTH | 1115 | 1115 | 0 | 0 | 30.309417 | 0.236248 | -0.217126 | 1 | 79 |
| classroom_rl | CORRECT | 536 | 495 | 41 | 0 | 19.109091 | 1.000000 | 0.000000 | 0 | 74 |
| classroom_rl | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 19.843049 | 0.358411 | 0.212912 | 1 | 56 |
| classroom_rl | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 21.963855 | 0.225969 | -0.077103 | 1 | 73 |
| cv_v1 | BOTH | 68 | 68 | 0 | 0 | 30.705882 | 0.201212 | 0.032693 | 7 | 69 |
| cv_v1 | CORRECT | 69 | 52 | 17 | 0 | 25.173077 | 1.000000 | 0.000000 | 1 | 53 |
| cv_v1 | OVERCONSTRAINED | 118 | 118 | 0 | 0 | 26.830508 | 0.206796 | -0.167476 | 3 | 58 |
| cv_v1 | UNDERCONSTRAINED | 55 | 55 | 0 | 0 | 25.254545 | 0.101278 | 0.018524 | 4 | 55 |
| cv_v2 | BOTH | 21 | 21 | 0 | 0 | 36.523810 | 0.346685 | -0.112806 | 11 | 66 |
| cv_v2 | CORRECT | 34 | 31 | 3 | 0 | 28.419355 | 1.000000 | 0.000000 | 10 | 55 |
| cv_v2 | OVERCONSTRAINED | 40 | 40 | 0 | 0 | 34.100000 | 0.278267 | -0.334091 | 14 | 68 |
| cv_v2 | UNDERCONSTRAINED | 12 | 12 | 0 | 0 | 26.083333 | 0.108333 | -0.321521 | 2 | 66 |
| lts | BOTH | 138 | 138 | 0 | 0 | 26.072464 | 0.146087 | 0.162885 | 1 | 86 |
| lts | CORRECT | 112 | 65 | 47 | 0 | 7.630769 | 1.000000 | 0.000000 | 0 | 32 |
| lts | OVERCONSTRAINED | 113 | 113 | 0 | 0 | 23.212389 | 0.298135 | -0.052566 | 4 | 80 |
| lts | UNDERCONSTRAINED | 66 | 66 | 0 | 0 | 14.712121 | 0.083033 | 0.212464 | 1 | 38 |
| production | BOTH | 22 | 22 | 0 | 0 | 13.954545 | 0.089563 | 0.532110 | 8 | 38 |
| production | CORRECT | 45 | 25 | 20 | 0 | 8.600000 | 1.000000 | 0.000000 | 1 | 14 |
| production | OVERCONSTRAINED | 25 | 25 | 0 | 0 | 10.120000 | 0.000000 | 0.000000 | 1 | 17 |
| production | UNDERCONSTRAINED | 36 | 36 | 0 | 0 | 8.388889 | 0.880088 | 0.019751 | 2 | 32 |
| train | BOTH | 277 | 277 | 0 | 0 | 30.296029 | 0.394328 | 0.063027 | 2 | 83 |
| train | CORRECT | 102 | 76 | 26 | 0 | 18.842105 | 0.995152 | 0.000000 | 0 | 52 |
| train | OVERCONSTRAINED | 170 | 170 | 0 | 0 | 22.717647 | 0.696567 | -0.004313 | 1 | 59 |
| train | UNDERCONSTRAINED | 178 | 178 | 0 | 0 | 24.286517 | 0.302345 | -0.180382 | 1 | 68 |
| trash_rl | BOTH | 267 | 267 | 0 | 0 | 9.363296 | 0.313037 | -0.109360 | 1 | 41 |
| trash_rl | CORRECT | 340 | 252 | 88 | 0 | 11.849206 | 1.000000 | 0.000000 | 0 | 35 |
| trash_rl | OVERCONSTRAINED | 150 | 150 | 0 | 0 | 8.920000 | 0.393347 | -0.033433 | 1 | 35 |
| trash_rl | UNDERCONSTRAINED | 63 | 63 | 0 | 0 | 17.476190 | 0.363508 | -0.197957 | 1 | 43 |
