# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 6601
- Successful distances: 6601
- Failures: 0
- Average distance: 20.275867
- Average predicate-body Levenshtein distance: 50.283745
- Average raw AST tree distance: 22.292683
- Min distance: 0
- Max distance: 82

## Reward Comparison

- Rewarded files: 6601
- Reward failures: 0
- Reward pool size: 1000
- Average candidate reward: 0.471510
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.528490
- Pearson correlation sample: non-CORRECT rewarded predicates (4827 files)
- Pearson correlation, distance vs candidate reward: -0.010868

- Pearson correlation, Levenshtein vs candidate reward: -0.017296
- Pearson correlation, raw AST tree distance vs candidate reward: -0.025868

## By Problem Class And Status

| Problem class | Status | Files | Successes | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1115 | 1115 | 0 | 25.872646 | 0.219220 | -0.027476 | 1 | 70 |
| classroom_fol | CORRECT | 536 | 536 | 0 | 17.080224 | 1.000000 | 0.000000 | 0 | 77 |
| classroom_fol | OVERCONSTRAINED | 223 | 223 | 0 | 18.892377 | 0.388036 | 0.126922 | 1 | 56 |
| classroom_fol | UNDERCONSTRAINED | 166 | 166 | 0 | 22.072289 | 0.287392 | 0.108840 | 1 | 60 |
| classroom_rl | BOTH | 1115 | 1115 | 0 | 25.872646 | 0.219220 | -0.027476 | 1 | 70 |
| classroom_rl | CORRECT | 536 | 536 | 0 | 17.080224 | 1.000000 | 0.000000 | 0 | 77 |
| classroom_rl | OVERCONSTRAINED | 223 | 223 | 0 | 18.892377 | 0.388036 | 0.126922 | 1 | 56 |
| classroom_rl | UNDERCONSTRAINED | 166 | 166 | 0 | 22.072289 | 0.287392 | 0.108840 | 1 | 60 |
| cv_v1 | BOTH | 68 | 68 | 0 | 28.911765 | 0.151095 | 0.213810 | 8 | 58 |
| cv_v1 | CORRECT | 69 | 69 | 0 | 18.855072 | 1.000000 | 0.000000 | 0 | 40 |
| cv_v1 | OVERCONSTRAINED | 118 | 118 | 0 | 26.271186 | 0.155034 | -0.323421 | 3 | 46 |
| cv_v1 | UNDERCONSTRAINED | 55 | 55 | 0 | 24.545455 | 0.080436 | 0.184883 | 4 | 48 |
| cv_v2 | BOTH | 21 | 21 | 0 | 35.476190 | 0.208127 | -0.034095 | 12 | 62 |
| cv_v2 | CORRECT | 34 | 34 | 0 | 25.676471 | 1.000000 | 0.000000 | 0 | 59 |
| cv_v2 | OVERCONSTRAINED | 40 | 40 | 0 | 34.425000 | 0.297675 | -0.339071 | 15 | 66 |
| cv_v2 | UNDERCONSTRAINED | 12 | 12 | 0 | 25.333333 | 0.021333 | -0.204211 | 2 | 64 |
| lts | BOTH | 138 | 138 | 0 | 15.739130 | 0.149231 | -0.178804 | 1 | 48 |
| lts | CORRECT | 112 | 112 | 0 | 5.107143 | 1.000000 | 0.000000 | 0 | 28 |
| lts | OVERCONSTRAINED | 113 | 113 | 0 | 13.761062 | 0.260265 | -0.117939 | 2 | 42 |
| lts | UNDERCONSTRAINED | 66 | 66 | 0 | 12.015152 | 0.083530 | 0.024821 | 1 | 38 |
| production | BOTH | 22 | 22 | 0 | 13.681818 | 0.096892 | 0.542475 | 4 | 35 |
| production | CORRECT | 45 | 45 | 0 | 5.844444 | 1.000000 | 0.000000 | 0 | 14 |
| production | OVERCONSTRAINED | 25 | 25 | 0 | 10.720000 | 0.000000 | 0.000000 | 1 | 16 |
| production | UNDERCONSTRAINED | 36 | 36 | 0 | 9.888889 | 0.888888 | 0.106193 | 2 | 34 |
| train | BOTH | 277 | 277 | 0 | 29.039711 | 0.458813 | 0.040182 | 2 | 82 |
| train | CORRECT | 102 | 102 | 0 | 13.039216 | 0.999961 | 0.000000 | 0 | 51 |
| train | OVERCONSTRAINED | 170 | 170 | 0 | 22.735294 | 0.764989 | 0.017779 | 1 | 56 |
| train | UNDERCONSTRAINED | 178 | 178 | 0 | 21.893258 | 0.272264 | -0.087679 | 1 | 68 |
| trash_rl | BOTH | 267 | 267 | 0 | 9.153558 | 0.273612 | 0.076692 | 1 | 37 |
| trash_rl | CORRECT | 340 | 340 | 0 | 8.464706 | 1.000000 | 0.000000 | 0 | 30 |
| trash_rl | OVERCONSTRAINED | 150 | 150 | 0 | 8.913333 | 0.256143 | -0.089832 | 1 | 34 |
| trash_rl | UNDERCONSTRAINED | 63 | 63 | 0 | 15.714286 | 0.394460 | -0.156910 | 1 | 39 |
