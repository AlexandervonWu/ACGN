# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 6601
- Successful distances: 6601
- Failures: 0
- Average distance: 19.951825
- Average predicate-body Levenshtein distance: 50.283745
- Average raw AST tree distance: 23.161642
- Average raw AST size: 26.371004
- Average canonical form size: 24.766399
- Average normalized raw AST distance: 0.837796
- Average normalized canonical distance: 0.750447
- CORRECT models with canonical distance 0 and raw AST distance > 0: 13
- Min distance: 0
- Max distance: 83

## Reward Comparison

- Rewarded files: 6601
- Reward failures: 0
- Reward pool size: 1000
- Average candidate reward: 0.471510
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.528490
- Pearson correlation sample: non-CORRECT rewarded predicates (4827 files)
- Pearson correlation, distance vs candidate reward: -0.013537

- Pearson correlation, Levenshtein vs candidate reward: -0.017296
- Pearson correlation, raw AST tree distance vs candidate reward: -0.025864

- Pearson correlation, normalized raw AST distance vs candidate reward: 0.016149
- Pearson correlation, normalized canonical distance vs candidate reward: 0.015690

## By Problem Class And Status

| Problem class | Status | Files | Successes | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1115 | 1115 | 0 | 25.363229 | 0.219220 | -0.035505 | 1 | 70 |
| classroom_fol | CORRECT | 536 | 536 | 0 | 16.791045 | 1.000000 | 0.000000 | 0 | 77 |
| classroom_fol | OVERCONSTRAINED | 223 | 223 | 0 | 18.690583 | 0.388036 | 0.132142 | 1 | 56 |
| classroom_fol | UNDERCONSTRAINED | 166 | 166 | 0 | 21.692771 | 0.287392 | 0.101745 | 1 | 60 |
| classroom_rl | BOTH | 1115 | 1115 | 0 | 25.363229 | 0.219220 | -0.035505 | 1 | 70 |
| classroom_rl | CORRECT | 536 | 536 | 0 | 16.791045 | 1.000000 | 0.000000 | 0 | 77 |
| classroom_rl | OVERCONSTRAINED | 223 | 223 | 0 | 18.690583 | 0.388036 | 0.132142 | 1 | 56 |
| classroom_rl | UNDERCONSTRAINED | 166 | 166 | 0 | 21.692771 | 0.287392 | 0.101745 | 1 | 60 |
| cv_v1 | BOTH | 68 | 68 | 0 | 29.044118 | 0.151095 | 0.208524 | 8 | 58 |
| cv_v1 | CORRECT | 69 | 69 | 0 | 18.623188 | 1.000000 | 0.000000 | 0 | 40 |
| cv_v1 | OVERCONSTRAINED | 118 | 118 | 0 | 25.855932 | 0.155034 | -0.300896 | 3 | 46 |
| cv_v1 | UNDERCONSTRAINED | 55 | 55 | 0 | 24.581818 | 0.080436 | 0.195392 | 4 | 48 |
| cv_v2 | BOTH | 21 | 21 | 0 | 35.476190 | 0.208127 | -0.118185 | 12 | 62 |
| cv_v2 | CORRECT | 34 | 34 | 0 | 25.764706 | 1.000000 | 0.000000 | 0 | 59 |
| cv_v2 | OVERCONSTRAINED | 40 | 40 | 0 | 33.400000 | 0.297675 | -0.362163 | 15 | 66 |
| cv_v2 | UNDERCONSTRAINED | 12 | 12 | 0 | 25.666667 | 0.021333 | -0.207258 | 2 | 64 |
| lts | BOTH | 138 | 138 | 0 | 15.695652 | 0.149231 | -0.177507 | 1 | 48 |
| lts | CORRECT | 112 | 112 | 0 | 4.803571 | 1.000000 | 0.000000 | 0 | 28 |
| lts | OVERCONSTRAINED | 113 | 113 | 0 | 13.716814 | 0.260265 | -0.118167 | 2 | 42 |
| lts | UNDERCONSTRAINED | 66 | 66 | 0 | 12.030303 | 0.083530 | 0.023924 | 1 | 38 |
| production | BOTH | 22 | 22 | 0 | 13.363636 | 0.096892 | 0.539919 | 6 | 33 |
| production | CORRECT | 45 | 45 | 0 | 5.511111 | 1.000000 | 0.000000 | 0 | 14 |
| production | OVERCONSTRAINED | 25 | 25 | 0 | 9.120000 | 0.000000 | 0.000000 | 1 | 16 |
| production | UNDERCONSTRAINED | 36 | 36 | 0 | 8.472222 | 0.888888 | 0.036061 | 2 | 34 |
| train | BOTH | 277 | 277 | 0 | 28.873646 | 0.458813 | 0.040482 | 2 | 83 |
| train | CORRECT | 102 | 102 | 0 | 12.980392 | 0.999961 | 0.000000 | 0 | 50 |
| train | OVERCONSTRAINED | 170 | 170 | 0 | 22.352941 | 0.764989 | 0.011838 | 1 | 56 |
| train | UNDERCONSTRAINED | 178 | 178 | 0 | 21.393258 | 0.272264 | -0.066990 | 1 | 68 |
| trash_rl | BOTH | 267 | 267 | 0 | 9.153558 | 0.273612 | 0.076692 | 1 | 37 |
| trash_rl | CORRECT | 340 | 340 | 0 | 8.458824 | 1.000000 | 0.000000 | 0 | 30 |
| trash_rl | OVERCONSTRAINED | 150 | 150 | 0 | 8.913333 | 0.256143 | -0.089832 | 1 | 34 |
| trash_rl | UNDERCONSTRAINED | 63 | 63 | 0 | 15.333333 | 0.394460 | -0.122755 | 1 | 39 |
