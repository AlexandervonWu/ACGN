# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 66080
- Successful distances: 61598
- Skipped identical raw AST predicate pairs: 4482
- Failures: 0
- Average distance: 13.540131
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 22.841358
- Average raw AST size: 26.787315
- Average canonical form size: 17.328598
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.811451
- Average normalized canonical distance: 0.720049
- CORRECT models with canonical distance 0 and raw AST distance > 0: 2235
- Min distance: 0
- Max distance: 142

## Canonical Representation Compression

Compression rate is `100 * (raw AST size - canonical form size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg canonical size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 33.897406 | 17.226415 | 49.180727% |
| classroom_fol | CORRECT | 1613 | 24.099814 | 12.699318 | 47.305328% |
| classroom_fol | OVERCONSTRAINED | 383 | 26.671018 | 14.310705 | 46.343612% |
| classroom_fol | UNDERCONSTRAINED | 311 | 35.546624 | 18.768489 | 47.200362% |
| classroom_rl | BOTH | 1219 | 21.272354 | 12.436423 | 41.537156% |
| classroom_rl | CORRECT | 1118 | 17.205725 | 10.176208 | 40.855687% |
| classroom_rl | OVERCONSTRAINED | 547 | 17.093236 | 10.482633 | 38.673797% |
| classroom_rl | UNDERCONSTRAINED | 499 | 21.615230 | 12.659319 | 41.433340% |
| coursesNew | BOTH | 1803 | 30.561287 | 18.064337 | 40.891438% |
| coursesNew | CORRECT | 1338 | 24.857250 | 14.428251 | 41.955561% |
| coursesNew | OVERCONSTRAINED | 327 | 24.660550 | 13.581040 | 44.928075% |
| coursesNew | UNDERCONSTRAINED | 1453 | 29.090158 | 17.250516 | 40.699820% |
| coursesOld | BOTH | 4001 | 31.062484 | 18.912022 | 39.116196% |
| coursesOld | CORRECT | 2148 | 22.381750 | 13.586127 | 39.298195% |
| coursesOld | OVERCONSTRAINED | 763 | 24.693316 | 15.778506 | 36.102118% |
| coursesOld | UNDERCONSTRAINED | 2576 | 28.365295 | 16.448370 | 42.012344% |
| cv_v1 | BOTH | 258 | 27.833333 | 17.918605 | 35.621780% |
| cv_v1 | CORRECT | 106 | 25.726415 | 16.547170 | 35.680235% |
| cv_v1 | OVERCONSTRAINED | 225 | 29.266667 | 18.008889 | 38.466211% |
| cv_v1 | UNDERCONSTRAINED | 219 | 20.917808 | 14.442922 | 30.953940% |
| cv_v2 | BOTH | 71 | 35.450704 | 29.098592 | 17.918157% |
| cv_v2 | CORRECT | 57 | 29.017544 | 20.105263 | 30.713422% |
| cv_v2 | OVERCONSTRAINED | 105 | 34.333333 | 26.780952 | 21.997226% |
| cv_v2 | UNDERCONSTRAINED | 40 | 30.350000 | 24.425000 | 19.522241% |
| graphs | BOTH | 361 | 18.094183 | 12.506925 | 30.878751% |
| graphs | CORRECT | 820 | 19.539024 | 12.236585 | 37.373611% |
| graphs | OVERCONSTRAINED | 645 | 19.862016 | 12.103876 | 39.060183% |
| graphs | UNDERCONSTRAINED | 326 | 18.773006 | 11.404908 | 39.248366% |
| lts | BOTH | 555 | 22.138739 | 13.477477 | 39.122650% |
| lts | CORRECT | 249 | 21.534137 | 12.477912 | 42.055203% |
| lts | OVERCONSTRAINED | 458 | 20.034934 | 11.753275 | 41.336094% |
| lts | UNDERCONSTRAINED | 254 | 22.303150 | 13.570866 | 39.152692% |
| productionLineNew | BOTH | 656 | 29.251524 | 18.858232 | 35.530773% |
| productionLineNew | CORRECT | 693 | 26.637807 | 17.851371 | 32.984832% |
| productionLineNew | OVERCONSTRAINED | 320 | 28.875000 | 18.809375 | 34.859307% |
| productionLineNew | UNDERCONSTRAINED | 557 | 27.996409 | 17.872531 | 36.161344% |
| productionLine_v1 | BOTH | 107 | 20.345794 | 12.813084 | 37.023427% |
| productionLine_v1 | CORRECT | 145 | 20.372414 | 12.627586 | 38.016249% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 22.000000 | 13.810000 | 37.227273% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 11.326797 | 7.627451 | 32.660127% |
| productionLine_v2 | BOTH | 870 | 28.722989 | 18.381609 | 36.003842% |
| productionLine_v2 | CORRECT | 1124 | 27.223310 | 18.540036 | 31.896467% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 29.799373 | 20.037618 | 32.758258% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 27.697422 | 18.278155 | 34.007740% |
| socialMedia | BOTH | 4982 | 32.315937 | 20.970494 | 35.107890% |
| socialMedia | CORRECT | 4550 | 25.487912 | 15.802857 | 37.998620% |
| socialMedia | OVERCONSTRAINED | 1597 | 32.652473 | 22.094552 | 32.334215% |
| socialMedia | UNDERCONSTRAINED | 2871 | 29.847092 | 19.160223 | 35.805394% |
| trainStationNew | BOTH | 2325 | 27.021935 | 18.520860 | 31.459905% |
| trainStationNew | CORRECT | 1601 | 21.845097 | 15.642723 | 28.392520% |
| trainStationNew | OVERCONSTRAINED | 689 | 24.709724 | 15.519594 | 37.192364% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 19.366359 | 11.815668 | 38.988697% |
| trainStationOld | BOTH | 357 | 28.591036 | 21.789916 | 23.787597% |
| trainStationOld | CORRECT | 111 | 19.981982 | 15.819820 | 20.829576% |
| trainStationOld | OVERCONSTRAINED | 201 | 19.741294 | 16.164179 | 18.119960% |
| trainStationOld | UNDERCONSTRAINED | 207 | 26.676329 | 20.376812 | 23.614632% |
| trash_fol | BOTH | 377 | 17.997347 | 10.687003 | 40.619013% |
| trash_fol | CORRECT | 1667 | 16.296341 | 9.426515 | 42.155636% |
| trash_fol | OVERCONSTRAINED | 217 | 18.903226 | 11.815668 | 37.493905% |
| trash_fol | UNDERCONSTRAINED | 104 | 24.009615 | 14.519231 | 39.527433% |
| trash_ltl | BOTH | 1486 | 16.545087 | 14.490579 | 12.417636% |
| trash_ltl | CORRECT | 863 | 15.442642 | 13.238702 | 14.271779% |
| trash_ltl | OVERCONSTRAINED | 546 | 15.584249 | 13.064103 | 16.171113% |
| trash_ltl | UNDERCONSTRAINED | 835 | 15.538922 | 12.961677 | 16.585742% |
| trash_rl | BOTH | 591 | 13.314721 | 8.661591 | 34.947261% |
| trash_rl | CORRECT | 1009 | 12.935580 | 8.143707 | 37.044131% |
| trash_rl | OVERCONSTRAINED | 334 | 12.565868 | 8.655689 | 31.117465% |
| trash_rl | UNDERCONSTRAINED | 132 | 19.310606 | 11.621212 | 39.819537% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg canonical | Avg relative Levenshtein | Avg relative raw AST | Avg relative canonical |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **22.841358** | **13.540131** | **0.547644** | **0.811451** | **0.720049** |
| classroom_fol | BOTH | 1696 | 54.403302 | 29.843750 | 14.528892 | 0.624351 | 0.860807 | 0.804265 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 19.522009 | 9.309981 | 0.537345 | 0.811881 | 0.675973 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 23.219321 | 11.838120 | 0.596239 | 0.824708 | 0.765936 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 29.591640 | 14.649518 | 0.606512 | 0.816431 | 0.752761 |
| classroom_rl | BOTH | 1219 | 35.016407 | 18.521739 | 9.785070 | 0.574684 | 0.779269 | 0.676648 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 12.228086 | 5.632379 | 0.439188 | 0.652025 | 0.482008 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 13.672761 | 7.621572 | 0.487860 | 0.706261 | 0.627512 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 16.621242 | 8.805611 | 0.495818 | 0.681461 | 0.614748 |
| coursesNew | BOTH | 1803 | 53.808098 | 31.171381 | 17.479756 | 0.614704 | 0.950469 | 0.881789 |
| coursesNew | CORRECT | 1338 | 38.111360 | 21.863229 | 10.378176 | 0.589369 | 0.890632 | 0.728692 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 23.553517 | 10.761468 | 0.664941 | 0.924123 | 0.722646 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 27.038541 | 15.981418 | 0.528858 | 0.871782 | 0.812824 |
| coursesOld | BOTH | 4001 | 57.329168 | 31.169958 | 18.409398 | 0.614074 | 0.913088 | 0.863002 |
| coursesOld | CORRECT | 2148 | 38.013501 | 20.067970 | 10.350093 | 0.591233 | 0.867271 | 0.730615 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 24.905636 | 13.595020 | 0.647316 | 0.908805 | 0.748620 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 25.468556 | 15.197205 | 0.531564 | 0.805671 | 0.767208 |
| cv_v1 | BOTH | 258 | 53.255814 | 33.003876 | 21.593023 | 0.661750 | 0.949859 | 0.819257 |
| cv_v1 | CORRECT | 106 | 27.886792 | 19.839623 | 11.028302 | 0.405510 | 0.670888 | 0.572402 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 28.657778 | 17.128889 | 0.591220 | 0.821782 | 0.703429 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 25.315068 | 14.936073 | 0.687474 | 0.900138 | 0.725542 |
| cv_v2 | BOTH | 71 | 59.929577 | 46.126761 | 36.239437 | 0.599896 | 1.051092 | 0.969836 |
| cv_v2 | CORRECT | 57 | 30.473684 | 28.719298 | 15.877193 | 0.430811 | 0.871002 | 0.667861 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 40.314286 | 30.504762 | 0.572770 | 0.983074 | 0.872037 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 40.150000 | 31.400000 | 0.590867 | 1.065550 | 0.958782 |
| graphs | BOTH | 361 | 24.570637 | 17.404432 | 10.229917 | 0.648332 | 0.867783 | 0.738758 |
| graphs | CORRECT | 820 | 25.169512 | 15.212195 | 8.528049 | 0.594930 | 0.736133 | 0.630740 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 15.305426 | 8.779845 | 0.479910 | 0.696726 | 0.652139 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 17.156442 | 9.193252 | 0.617945 | 0.848759 | 0.748623 |
| lts | BOTH | 555 | 50.536937 | 35.338739 | 19.526126 | 0.641920 | 0.895019 | 0.749184 |
| lts | CORRECT | 249 | 29.991968 | 19.634538 | 7.542169 | 0.550300 | 0.726068 | 0.467369 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 31.982533 | 17.207424 | 0.615166 | 0.839382 | 0.698132 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 26.740157 | 15.547244 | 0.556787 | 0.744322 | 0.684822 |
| productionLineNew | BOTH | 656 | 45.213415 | 28.455793 | 16.393293 | 0.509207 | 0.868169 | 0.757231 |
| productionLineNew | CORRECT | 693 | 34.992785 | 20.793651 | 11.337662 | 0.445274 | 0.726740 | 0.546945 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 24.296875 | 14.187500 | 0.459963 | 0.754725 | 0.674911 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 30.574506 | 16.820467 | 0.528572 | 0.944749 | 0.753641 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 21.149533 | 11.560748 | 0.531859 | 0.881969 | 0.709790 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 16.193103 | 8.951724 | 0.434531 | 0.735868 | 0.666581 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 19.050000 | 12.450000 | 0.451724 | 0.773732 | 0.742606 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 12.196078 | 7.281046 | 0.578122 | 0.676481 | 0.641830 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 27.693103 | 15.982759 | 0.499213 | 0.849087 | 0.750127 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 23.161922 | 13.536477 | 0.477882 | 0.749846 | 0.605122 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 26.752351 | 16.152038 | 0.495962 | 0.818031 | 0.731624 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 28.146540 | 16.156038 | 0.540061 | 0.880043 | 0.728533 |
| socialMedia | BOTH | 4982 | 50.487756 | 29.238659 | 18.742071 | 0.581993 | 0.839846 | 0.812292 |
| socialMedia | CORRECT | 4550 | 28.614945 | 19.426813 | 10.767033 | 0.419222 | 0.659936 | 0.535726 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 29.633062 | 19.137758 | 0.543362 | 0.821751 | 0.768519 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 24.183211 | 17.265413 | 0.533680 | 0.756691 | 0.815726 |
| trainStationNew | BOTH | 2325 | 43.576774 | 22.907527 | 16.484301 | 0.588892 | 0.783639 | 0.778928 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 15.271081 | 8.166146 | 0.461784 | 0.637859 | 0.489468 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 20.496372 | 10.809869 | 0.506348 | 0.735398 | 0.604979 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 13.814900 | 16.317972 | 0.509954 | 0.624067 | 0.829966 |
| trainStationOld | BOTH | 357 | 56.574230 | 39.745098 | 28.019608 | 0.629920 | 1.044956 | 0.906564 |
| trainStationOld | CORRECT | 111 | 29.864865 | 17.909910 | 8.828829 | 0.531537 | 0.853222 | 0.511462 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 23.398010 | 15.273632 | 0.570660 | 0.985240 | 0.740135 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 29.111111 | 19.497585 | 0.602022 | 0.946283 | 0.837460 |
| trash_fol | BOTH | 377 | 27.262599 | 16.522546 | 8.336870 | 0.613723 | 0.918588 | 0.770692 |
| trash_fol | CORRECT | 1667 | 26.151170 | 15.433713 | 6.770846 | 0.649266 | 0.930253 | 0.667582 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 18.377880 | 9.635945 | 0.684851 | 0.911574 | 0.751372 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 21.403846 | 11.326923 | 0.655198 | 0.883013 | 0.768803 |
| trash_ltl | BOTH | 1486 | 29.627187 | 15.105653 | 11.051817 | 0.538142 | 0.847314 | 0.701696 |
| trash_ltl | CORRECT | 863 | 20.166860 | 11.491309 | 7.256083 | 0.385829 | 0.730754 | 0.558708 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 12.260073 | 6.716117 | 0.470347 | 0.756828 | 0.508514 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 14.005988 | 10.627545 | 0.485105 | 0.844662 | 0.775794 |
| trash_rl | BOTH | 591 | 18.964467 | 12.240271 | 6.514382 | 0.577751 | 0.860063 | 0.697234 |
| trash_rl | CORRECT | 1009 | 18.356789 | 11.993062 | 5.693756 | 0.582256 | 0.845125 | 0.638280 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 12.017964 | 6.550898 | 0.612100 | 0.827469 | 0.659578 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 17.810606 | 8.583333 | 0.617090 | 0.869380 | 0.690078 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 10
- Average candidate reward: 0.567082
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.432918
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, distance vs candidate reward: -0.042870

- Pearson correlation, Levenshtein vs candidate reward: -0.089408
- Pearson correlation, raw AST tree distance vs candidate reward: -0.073326

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.050632
- Pearson correlation, normalized canonical distance vs candidate reward: -0.082022

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 14.528892 | 0.244291 | -0.155214 | 1 | 52 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 9.309981 | 1.000000 | 0.000000 | 0 | 64 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 11.838120 | 0.413947 | 0.013742 | 1 | 68 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 14.649518 | 0.204409 | 0.258604 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 9.785070 | 0.280459 | -0.101181 | 1 | 62 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.632379 | 1.000000 | 0.000000 | 0 | 31 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 7.621572 | 0.428192 | 0.100255 | 1 | 53 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 8.805611 | 0.156198 | 0.267963 | 1 | 42 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 17.479756 | 0.204531 | -0.222207 | 1 | 51 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 10.378176 | 1.000000 | 0.000000 | 0 | 47 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 10.761468 | 0.660952 | -0.259838 | 1 | 48 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 15.981418 | 0.540435 | -0.145646 | 1 | 48 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 18.409398 | 0.158800 | -0.137747 | 1 | 129 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.350093 | 1.000000 | 0.000000 | 0 | 39 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 13.595020 | 0.523328 | -0.263873 | 1 | 61 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 15.197205 | 0.492757 | -0.121121 | 1 | 52 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 21.593023 | 0.216721 | -0.146405 | 4 | 44 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 11.028302 | 1.000000 | 0.000000 | 0 | 43 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 17.128889 | 0.185523 | 0.003420 | 1 | 43 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 14.936073 | 0.202292 | 0.265265 | 2 | 34 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 36.239437 | 0.582386 | 0.150489 | 3 | 91 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 15.877193 | 1.000000 | 0.000000 | 0 | 43 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 30.504762 | 0.513380 | 0.270008 | 1 | 92 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 31.400000 | 0.451040 | 0.564284 | 1 | 89 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.229917 | 0.382271 | 0.119907 | 1 | 40 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.528049 | 0.999988 | 0.000000 | 0 | 69 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.779845 | 0.571766 | 0.055688 | 1 | 37 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.193252 | 0.485396 | 0.099524 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 19.526126 | 0.214955 | 0.290031 | 1 | 63 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 7.542169 | 1.000000 | 0.000000 | 0 | 42 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 17.207424 | 0.340648 | 0.156054 | 1 | 87 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 15.547244 | 0.143861 | 0.226049 | 1 | 78 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 16.393293 | 0.320085 | -0.161877 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 11.337662 | 1.000000 | 0.000000 | 0 | 76 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.187500 | 0.309684 | -0.199771 | 1 | 56 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 16.820467 | 0.557468 | -0.172298 | 2 | 76 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.560748 | 0.135144 | 0.473448 | 1 | 36 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 8.951724 | 1.000000 | 0.000000 | 0 | 32 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.450000 | 0.059505 | 0.182751 | 1 | 28 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.281046 | 0.436317 | -0.126770 | 2 | 32 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 15.982759 | 0.304322 | -0.044189 | 1 | 82 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 13.536477 | 1.000000 | 0.000000 | 0 | 80 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 16.152038 | 0.327335 | -0.303323 | 1 | 75 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 16.156038 | 0.696852 | -0.034718 | 1 | 72 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 18.742071 | 0.244656 | 0.154738 | 1 | 106 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.767033 | 0.999560 | 0.000000 | 0 | 142 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 19.137758 | 0.179442 | 0.006039 | 1 | 109 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 17.265413 | 0.633007 | 0.242837 | 1 | 79 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 16.484301 | 0.390174 | -0.028288 | 1 | 81 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 8.166146 | 1.000000 | 0.000000 | 0 | 106 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 10.809869 | 0.791448 | -0.114111 | 1 | 58 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 16.317972 | 0.609301 | 0.002587 | 1 | 55 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 28.019608 | 0.308898 | 0.104455 | 2 | 100 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 8.828829 | 0.999643 | 0.000000 | 0 | 32 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 15.273632 | 0.605095 | -0.032063 | 1 | 57 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 19.497585 | 0.383461 | -0.290333 | 1 | 76 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.336870 | 0.303636 | 0.181364 | 1 | 37 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 6.770846 | 1.000000 | 0.000000 | 0 | 22 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.635945 | 0.333002 | 0.124321 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 11.326923 | 0.499429 | 0.029292 | 1 | 26 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 11.051817 | 0.360539 | 0.255591 | 1 | 31 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 7.256083 | 1.000000 | 0.000000 | 0 | 19 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 6.716117 | 0.602689 | 0.085506 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 10.627545 | 0.519010 | 0.124940 | 1 | 29 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.514382 | 0.362760 | -0.012841 | 1 | 53 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 5.693756 | 1.000000 | 0.000000 | 0 | 38 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.550898 | 0.450972 | -0.082689 | 1 | 35 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.583333 | 0.368872 | -0.241336 | 1 | 23 |
