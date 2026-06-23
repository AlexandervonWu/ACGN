# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 6601
- Successful distances: 6318
- Skipped identical raw AST predicate pairs: 283
- Failures: 0
- Average distance: 25.319880
- Average predicate-body Levenshtein distance: 52.536087
- Average raw AST tree distance: 24.199114
- Average raw AST size: 27.069326
- Average canonical form size: 30.070909
- Average normalized raw AST distance: 0.875323
- Average normalized canonical distance: 0.808910
- CORRECT models with canonical distance 0 and raw AST distance > 0: 13
- Min distance: 0
- Max distance: 95

## Reward Comparison

- Rewarded files: 6318
- Reward failures: 0
- Reward pool size: 10
- Average candidate reward: 0.452061
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.547939
- Pearson correlation sample: non-CORRECT rewarded predicates (4827 files)
- Pearson correlation, distance vs candidate reward: -0.107883

- Pearson correlation, Levenshtein vs candidate reward: -0.068562
- Pearson correlation, raw AST tree distance vs candidate reward: -0.097240

- Pearson correlation, normalized raw AST distance vs candidate reward: 0.007276
- Pearson correlation, normalized canonical distance vs candidate reward: -0.017714

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1115 | 1115 | 0 | 0 | 32.194619 | 0.236341 | -0.185852 | 1 | 75 |
| classroom_fol | CORRECT | 536 | 495 | 41 | 0 | 21.238384 | 1.000000 | 0.000000 | 0 | 80 |
| classroom_fol | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 22.228700 | 0.358411 | 0.211153 | 1 | 56 |
| classroom_fol | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 25.018072 | 0.225969 | -0.002837 | 1 | 62 |
| classroom_rl | BOTH | 1115 | 1115 | 0 | 0 | 32.194619 | 0.236341 | -0.185852 | 1 | 75 |
| classroom_rl | CORRECT | 536 | 495 | 41 | 0 | 21.238384 | 1.000000 | 0.000000 | 0 | 80 |
| classroom_rl | OVERCONSTRAINED | 223 | 223 | 0 | 0 | 22.228700 | 0.358411 | 0.211153 | 1 | 56 |
| classroom_rl | UNDERCONSTRAINED | 166 | 166 | 0 | 0 | 25.018072 | 0.225969 | -0.002837 | 1 | 62 |
| cv_v1 | BOTH | 68 | 68 | 0 | 0 | 30.544118 | 0.203547 | -0.006788 | 8 | 62 |
| cv_v1 | CORRECT | 69 | 52 | 17 | 0 | 26.538462 | 1.000000 | 0.000000 | 1 | 49 |
| cv_v1 | OVERCONSTRAINED | 118 | 118 | 0 | 0 | 27.186441 | 0.206796 | -0.159989 | 3 | 56 |
| cv_v1 | UNDERCONSTRAINED | 55 | 55 | 0 | 0 | 26.454545 | 0.101278 | -0.000484 | 4 | 54 |
| cv_v2 | BOTH | 21 | 21 | 0 | 0 | 37.761905 | 0.346685 | -0.050587 | 13 | 64 |
| cv_v2 | CORRECT | 34 | 31 | 3 | 0 | 30.806452 | 1.000000 | 0.000000 | 12 | 64 |
| cv_v2 | OVERCONSTRAINED | 40 | 40 | 0 | 0 | 35.400000 | 0.278267 | -0.285561 | 16 | 71 |
| cv_v2 | UNDERCONSTRAINED | 12 | 12 | 0 | 0 | 28.250000 | 0.108333 | -0.324889 | 2 | 69 |
| lts | BOTH | 138 | 138 | 0 | 0 | 29.420290 | 0.146087 | 0.146656 | 1 | 95 |
| lts | CORRECT | 112 | 65 | 47 | 0 | 9.061538 | 1.000000 | 0.000000 | 0 | 30 |
| lts | OVERCONSTRAINED | 113 | 113 | 0 | 0 | 26.584071 | 0.299921 | -0.063176 | 7 | 89 |
| lts | UNDERCONSTRAINED | 66 | 66 | 0 | 0 | 16.757576 | 0.083033 | 0.167051 | 1 | 43 |
| production | BOTH | 22 | 22 | 0 | 0 | 14.136364 | 0.089563 | 0.470699 | 6 | 34 |
| production | CORRECT | 45 | 25 | 20 | 0 | 10.480000 | 1.000000 | 0.000000 | 1 | 15 |
| production | OVERCONSTRAINED | 25 | 25 | 0 | 0 | 9.640000 | 0.000000 | 0.000000 | 1 | 16 |
| production | UNDERCONSTRAINED | 36 | 36 | 0 | 0 | 8.805556 | 0.880088 | 0.025562 | 2 | 37 |
| train | BOTH | 277 | 277 | 0 | 0 | 31.776173 | 0.393268 | 0.036425 | 2 | 86 |
| train | CORRECT | 102 | 76 | 26 | 0 | 21.131579 | 0.995215 | 0.000000 | 0 | 55 |
| train | OVERCONSTRAINED | 170 | 170 | 0 | 0 | 24.641176 | 0.697817 | 0.005861 | 1 | 60 |
| train | UNDERCONSTRAINED | 178 | 178 | 0 | 0 | 25.370787 | 0.302345 | -0.146823 | 1 | 70 |
| trash_rl | BOTH | 267 | 267 | 0 | 0 | 9.741573 | 0.313037 | -0.099083 | 1 | 40 |
| trash_rl | CORRECT | 340 | 252 | 88 | 0 | 12.615079 | 1.000000 | 0.000000 | 0 | 33 |
| trash_rl | OVERCONSTRAINED | 150 | 150 | 0 | 0 | 9.653333 | 0.393347 | -0.024942 | 1 | 35 |
| trash_rl | UNDERCONSTRAINED | 63 | 63 | 0 | 0 | 17.095238 | 0.363508 | -0.130470 | 1 | 42 |
