# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 66080
- Successful distances: 61598
- Skipped identical raw AST predicate pairs: 4482
- Failures: 0
- Average distance: 13.670622
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 21.332186
- Average raw AST size: 24.936102
- Average canonical form size: 16.922676
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.814194
- Average normalized canonical distance: 0.744060
- CORRECT models with canonical distance 0 and raw AST distance > 0: 2089
- Min distance: 0
- Max distance: 141

## Canonical Representation Compression

Compression rate is `100 * (raw AST size - canonical form size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are included.

| Problem class | Correctness division | Models | Avg raw AST size | Avg canonical size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 31.025354 | 17.222877 | 44.487733% |
| classroom_fol | CORRECT | 1884 | 20.010085 | 11.701699 | 41.520995% |
| classroom_fol | OVERCONSTRAINED | 383 | 24.608355 | 14.310705 | 41.846154% |
| classroom_fol | UNDERCONSTRAINED | 311 | 32.742765 | 18.768489 | 42.678975% |
| classroom_rl | BOTH | 1219 | 20.041838 | 12.436423 | 37.947689% |
| classroom_rl | CORRECT | 1764 | 13.557823 | 8.714853 | 35.720856% |
| classroom_rl | OVERCONSTRAINED | 547 | 16.102377 | 10.473492 | 34.956857% |
| classroom_rl | UNDERCONSTRAINED | 499 | 20.356713 | 12.633267 | 37.940539% |
| coursesNew | BOTH | 1803 | 28.258458 | 18.018303 | 36.237488% |
| coursesNew | CORRECT | 1371 | 22.671043 | 14.275711 | 37.031079% |
| coursesNew | OVERCONSTRAINED | 327 | 22.602446 | 13.507645 | 40.238127% |
| coursesNew | UNDERCONSTRAINED | 1453 | 26.898830 | 17.209222 | 36.022413% |
| coursesOld | BOTH | 4001 | 28.817546 | 18.738815 | 34.974284% |
| coursesOld | CORRECT | 2284 | 20.334501 | 13.227671 | 34.949617% |
| coursesOld | OVERCONSTRAINED | 763 | 22.913499 | 15.608126 | 31.882400% |
| coursesOld | UNDERCONSTRAINED | 2576 | 26.246894 | 16.395186 | 37.534757% |
| cv_v1 | BOTH | 258 | 26.217054 | 17.914729 | 31.667652% |
| cv_v1 | CORRECT | 155 | 21.774194 | 14.548387 | 33.185185% |
| cv_v1 | OVERCONSTRAINED | 225 | 27.337778 | 18.004444 | 34.140790% |
| cv_v1 | UNDERCONSTRAINED | 219 | 19.662100 | 14.442922 | 26.544357% |
| cv_v2 | BOTH | 71 | 32.690141 | 28.788732 | 11.934511% |
| cv_v2 | CORRECT | 64 | 26.328125 | 19.000000 | 27.833828% |
| cv_v2 | OVERCONSTRAINED | 105 | 31.733333 | 26.295238 | 17.136855% |
| cv_v2 | UNDERCONSTRAINED | 40 | 28.175000 | 24.175000 | 14.196983% |
| graphs | BOTH | 361 | 17.130194 | 12.506925 | 26.989004% |
| graphs | CORRECT | 1058 | 16.558601 | 11.131380 | 32.775843% |
| graphs | OVERCONSTRAINED | 645 | 18.813953 | 12.102326 | 35.673671% |
| graphs | UNDERCONSTRAINED | 326 | 17.628834 | 11.404908 | 35.305377% |
| lts | BOTH | 555 | 20.605405 | 11.965766 | 41.928996% |
| lts | CORRECT | 577 | 14.870017 | 8.528596 | 42.645688% |
| lts | OVERCONSTRAINED | 458 | 18.788210 | 10.388646 | 44.706566% |
| lts | UNDERCONSTRAINED | 254 | 20.716535 | 11.299213 | 45.458001% |
| productionLineNew | BOTH | 656 | 27.629573 | 18.864329 | 31.724138% |
| productionLineNew | CORRECT | 818 | 23.416870 | 16.954768 | 27.595928% |
| productionLineNew | OVERCONSTRAINED | 320 | 27.128125 | 18.809375 | 30.664670% |
| productionLineNew | UNDERCONSTRAINED | 557 | 26.369838 | 17.865350 | 32.250817% |
| productionLine_v1 | BOTH | 107 | 19.336449 | 12.570093 | 34.992750% |
| productionLine_v1 | CORRECT | 239 | 16.903766 | 10.573222 | 37.450495% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 20.840000 | 13.360000 | 35.892514% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 10.627451 | 7.522876 | 29.212792% |
| productionLine_v2 | BOTH | 870 | 26.986207 | 18.382759 | 31.880910% |
| productionLine_v2 | CORRECT | 1326 | 24.171192 | 17.659125 | 26.941437% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 28.115987 | 20.037618 | 28.732300% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 26.048847 | 18.261872 | 29.893739% |
| socialMedia | BOTH | 4982 | 30.027298 | 20.960458 | 30.195326% |
| socialMedia | CORRECT | 4945 | 23.137513 | 15.310212 | 33.829480% |
| socialMedia | OVERCONSTRAINED | 1597 | 30.384471 | 22.088917 | 27.301954% |
| socialMedia | UNDERCONSTRAINED | 2871 | 27.824800 | 19.145942 | 31.191087% |
| trainStationNew | BOTH | 2325 | 25.243871 | 18.516989 | 26.647584% |
| trainStationNew | CORRECT | 1953 | 18.979519 | 14.810036 | 21.968328% |
| trainStationNew | OVERCONSTRAINED | 689 | 22.920174 | 15.519594 | 32.288501% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 18.144393 | 11.809524 | 34.913647% |
| trainStationOld | BOTH | 357 | 27.635854 | 19.056022 | 31.046017% |
| trainStationOld | CORRECT | 185 | 14.902703 | 10.659459 | 28.472978% |
| trainStationOld | OVERCONSTRAINED | 201 | 18.885572 | 14.278607 | 24.394099% |
| trainStationOld | UNDERCONSTRAINED | 207 | 25.685990 | 16.642512 | 35.207824% |
| trash_fol | BOTH | 377 | 16.602122 | 10.681698 | 35.660649% |
| trash_fol | CORRECT | 1982 | 13.458628 | 8.702321 | 35.340206% |
| trash_fol | OVERCONSTRAINED | 217 | 17.483871 | 11.815668 | 32.419610% |
| trash_fol | UNDERCONSTRAINED | 104 | 22.221154 | 14.451923 | 34.963219% |
| trash_ltl | BOTH | 1486 | 15.765141 | 12.111036 | 23.178384% |
| trash_ltl | CORRECT | 1440 | 12.359028 | 9.921528 | 19.722425% |
| trash_ltl | OVERCONSTRAINED | 546 | 14.743590 | 11.655678 | 20.944099% |
| trash_ltl | UNDERCONSTRAINED | 835 | 14.780838 | 10.538922 | 28.698752% |
| trash_rl | BOTH | 591 | 12.673435 | 8.642978 | 31.802403% |
| trash_rl | CORRECT | 1649 | 9.808369 | 6.982414 | 28.811673% |
| trash_rl | OVERCONSTRAINED | 334 | 11.997006 | 8.652695 | 27.876217% |
| trash_rl | UNDERCONSTRAINED | 132 | 18.113636 | 11.318182 | 37.515684% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg canonical | Avg relative Levenshtein | Avg relative raw AST | Avg relative canonical |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **21.332186** | **13.670622** | **0.547644** | **0.814194** | **0.744060** |
| classroom_fol | BOTH | 1696 | 54.403302 | 27.541863 | 15.031250 | 0.624351 | 0.867580 | 0.829177 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 18.230006 | 9.580285 | 0.537345 | 0.826573 | 0.689662 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 21.561358 | 12.308094 | 0.596239 | 0.834813 | 0.794820 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 27.382637 | 15.469453 | 0.606512 | 0.822786 | 0.788755 |
| classroom_rl | BOTH | 1219 | 35.016407 | 17.537326 | 10.007383 | 0.574684 | 0.792343 | 0.690640 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 11.600179 | 5.754919 | 0.439188 | 0.658394 | 0.491245 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 13.146252 | 7.808044 | 0.487860 | 0.728890 | 0.642064 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 15.813627 | 9.068136 | 0.495818 | 0.692173 | 0.630031 |
| coursesNew | BOTH | 1803 | 53.808098 | 29.019967 | 18.135885 | 0.614704 | 0.951285 | 0.914025 |
| coursesNew | CORRECT | 1338 | 38.111360 | 20.403587 | 10.989537 | 0.589369 | 0.901034 | 0.754913 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 21.651376 | 11.110092 | 0.664941 | 0.926437 | 0.738424 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 25.157605 | 16.791466 | 0.528858 | 0.876489 | 0.856445 |
| coursesOld | BOTH | 4001 | 57.329168 | 28.970757 | 18.951512 | 0.614074 | 0.912964 | 0.895379 |
| coursesOld | CORRECT | 2148 | 38.013501 | 18.872905 | 10.709963 | 0.591233 | 0.878017 | 0.744910 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 23.150721 | 13.833552 | 0.647316 | 0.913388 | 0.761660 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 23.530280 | 16.045419 | 0.531564 | 0.803909 | 0.814441 |
| cv_v1 | BOTH | 258 | 53.255814 | 30.104651 | 22.236434 | 0.661750 | 0.943270 | 0.844962 |
| cv_v1 | CORRECT | 106 | 27.886792 | 18.226415 | 11.622642 | 0.405510 | 0.662621 | 0.600833 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 26.084444 | 17.626667 | 0.591220 | 0.810403 | 0.723206 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 23.456621 | 15.470320 | 0.687474 | 0.902422 | 0.747131 |
| cv_v2 | BOTH | 71 | 59.929577 | 42.098592 | 37.295775 | 0.599896 | 1.037055 | 1.007284 |
| cv_v2 | CORRECT | 57 | 30.473684 | 26.947368 | 17.561404 | 0.430811 | 0.867645 | 0.724271 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 36.904762 | 31.714286 | 0.572770 | 0.971157 | 0.918535 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 36.900000 | 32.025000 | 0.590867 | 1.055093 | 0.993454 |
| graphs | BOTH | 361 | 24.570637 | 16.379501 | 10.274238 | 0.648332 | 0.866986 | 0.743359 |
| graphs | CORRECT | 820 | 25.169512 | 13.954878 | 8.545122 | 0.594930 | 0.728748 | 0.632894 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 14.520930 | 8.834109 | 0.479910 | 0.695867 | 0.659326 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 16.039877 | 9.214724 | 0.617945 | 0.848302 | 0.751778 |
| lts | BOTH | 555 | 50.536937 | 31.924324 | 9.790991 | 0.641920 | 0.898916 | 0.713462 |
| lts | CORRECT | 249 | 29.991968 | 17.795181 | 6.253012 | 0.550300 | 0.716662 | 0.506871 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 28.930131 | 7.873362 | 0.615166 | 0.837323 | 0.661730 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 24.192913 | 8.700787 | 0.556787 | 0.739971 | 0.651638 |
| productionLineNew | BOTH | 656 | 45.213415 | 27.118902 | 17.179878 | 0.509207 | 0.876007 | 0.789141 |
| productionLineNew | CORRECT | 693 | 34.992785 | 19.497835 | 12.141414 | 0.445274 | 0.732111 | 0.577935 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 22.896875 | 14.943750 | 0.459963 | 0.756245 | 0.704496 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 28.958707 | 17.346499 | 0.528572 | 0.946102 | 0.774220 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 20.121495 | 11.504673 | 0.531859 | 0.900086 | 0.710008 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 15.496552 | 8.986207 | 0.434531 | 0.747618 | 0.673265 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 18.330000 | 12.320000 | 0.451724 | 0.793195 | 0.741716 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 11.503268 | 7.372549 | 0.578122 | 0.685480 | 0.650231 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 26.214943 | 16.694253 | 0.499213 | 0.857331 | 0.776088 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 21.875445 | 14.650356 | 0.477882 | 0.759099 | 0.644439 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 25.313480 | 16.811912 | 0.495962 | 0.822480 | 0.755008 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 26.683853 | 16.858887 | 0.540061 | 0.886382 | 0.752659 |
| socialMedia | BOTH | 4982 | 50.487756 | 27.382979 | 18.894219 | 0.581993 | 0.845408 | 0.825032 |
| socialMedia | CORRECT | 4550 | 28.614945 | 18.061099 | 11.056264 | 0.419222 | 0.650753 | 0.554074 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 27.669380 | 19.398873 | 0.543362 | 0.822909 | 0.784437 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 22.633925 | 17.315918 | 0.533680 | 0.759227 | 0.823274 |
| trainStationNew | BOTH | 2325 | 43.576774 | 21.433118 | 17.279140 | 0.588892 | 0.787580 | 0.810086 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 14.149282 | 8.988132 | 0.461784 | 0.637074 | 0.521950 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 18.725689 | 11.650218 | 0.506348 | 0.725258 | 0.654114 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 13.092166 | 16.443932 | 0.509954 | 0.632091 | 0.835028 |
| trainStationOld | BOTH | 357 | 56.574230 | 38.296919 | 26.666667 | 0.629920 | 1.037705 | 0.968020 |
| trainStationOld | CORRECT | 111 | 29.864865 | 16.387387 | 8.774775 | 0.531537 | 0.826480 | 0.620323 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 21.990050 | 14.626866 | 0.570660 | 0.970794 | 0.845401 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 27.811594 | 17.555556 | 0.602022 | 0.937869 | 0.907191 |
| trash_fol | BOTH | 377 | 27.262599 | 15.273210 | 8.538462 | 0.613723 | 0.920837 | 0.785465 |
| trash_fol | CORRECT | 1667 | 26.151170 | 14.207558 | 6.818836 | 0.649266 | 0.935071 | 0.671068 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 17.064516 | 9.686636 | 0.684851 | 0.916113 | 0.755370 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 19.875000 | 11.211538 | 0.655198 | 0.885178 | 0.763613 |
| trash_ltl | BOTH | 1486 | 29.627187 | 14.327725 | 10.020861 | 0.538142 | 0.847631 | 0.753796 |
| trash_ltl | CORRECT | 863 | 20.166860 | 11.067207 | 7.435689 | 0.385829 | 0.738040 | 0.678471 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 11.591575 | 7.042125 | 0.470347 | 0.755486 | 0.608087 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 13.219162 | 9.377246 | 0.485105 | 0.838913 | 0.823775 |
| trash_rl | BOTH | 591 | 18.964467 | 11.690355 | 6.683587 | 0.577751 | 0.863935 | 0.710921 |
| trash_rl | CORRECT | 1009 | 18.356789 | 11.340932 | 5.719524 | 0.582256 | 0.851169 | 0.640573 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 11.479042 | 6.577844 | 0.612100 | 0.830253 | 0.662504 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 16.651515 | 8.363636 | 0.617090 | 0.872377 | 0.682861 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 10
- Average candidate reward: 0.567082
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.432918
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, distance vs candidate reward: -0.038551

- Pearson correlation, Levenshtein vs candidate reward: -0.089408
- Pearson correlation, raw AST tree distance vs candidate reward: -0.071385

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.048080
- Pearson correlation, normalized canonical distance vs candidate reward: -0.068489

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 15.031250 | 0.244291 | -0.139917 | 1 | 52 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 9.580285 | 1.000000 | 0.000000 | 0 | 64 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 12.308094 | 0.413947 | 0.044552 | 1 | 68 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 15.469453 | 0.204409 | 0.284638 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 10.007383 | 0.280459 | -0.101561 | 1 | 62 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.754919 | 1.000000 | 0.000000 | 0 | 31 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 7.808044 | 0.428192 | 0.111299 | 1 | 53 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 9.068136 | 0.156198 | 0.255576 | 1 | 41 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 18.135885 | 0.204531 | -0.195589 | 1 | 52 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 10.989537 | 1.000000 | 0.000000 | 0 | 47 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 11.110092 | 0.660952 | -0.243459 | 1 | 48 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 16.791466 | 0.540435 | -0.143380 | 1 | 48 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 18.951512 | 0.158800 | -0.132931 | 1 | 128 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.709963 | 1.000000 | 0.000000 | 0 | 41 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 13.833552 | 0.523328 | -0.252612 | 1 | 61 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 16.045419 | 0.492757 | -0.099911 | 1 | 53 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 22.236434 | 0.216721 | -0.088289 | 4 | 50 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 11.622642 | 1.000000 | 0.000000 | 0 | 43 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 17.626667 | 0.185523 | -0.005097 | 1 | 43 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 15.470320 | 0.202292 | 0.315178 | 3 | 36 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 37.295775 | 0.582386 | 0.194932 | 3 | 91 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 17.561404 | 1.000000 | 0.000000 | 0 | 43 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 31.714286 | 0.513380 | 0.276611 | 1 | 92 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 32.025000 | 0.451040 | 0.577686 | 2 | 89 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.274238 | 0.382271 | 0.115645 | 1 | 40 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.545122 | 0.999988 | 0.000000 | 0 | 69 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.834109 | 0.571766 | 0.050552 | 1 | 37 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.214724 | 0.485396 | 0.101572 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 9.790991 | 0.214955 | 0.272615 | 1 | 30 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 6.253012 | 1.000000 | 0.000000 | 0 | 41 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 7.873362 | 0.340648 | 0.132979 | 1 | 55 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 8.700787 | 0.143861 | 0.338272 | 1 | 41 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 17.179878 | 0.320085 | -0.152407 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 12.141414 | 1.000000 | 0.000000 | 0 | 77 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.943750 | 0.309684 | -0.201085 | 1 | 57 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 17.346499 | 0.557468 | -0.156830 | 2 | 76 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.504673 | 0.135144 | 0.474548 | 1 | 36 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 8.986207 | 1.000000 | 0.000000 | 0 | 31 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.320000 | 0.059505 | 0.179649 | 1 | 27 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.372549 | 0.436317 | -0.141244 | 2 | 32 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 16.694253 | 0.304322 | -0.037311 | 1 | 82 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 14.650356 | 1.000000 | 0.000000 | 0 | 81 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 16.811912 | 0.327335 | -0.301788 | 1 | 77 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 16.858887 | 0.696852 | -0.007632 | 1 | 72 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 18.894219 | 0.244656 | 0.154683 | 1 | 106 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 11.056264 | 0.999560 | 0.000000 | 0 | 141 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 19.398873 | 0.179442 | 0.004670 | 1 | 107 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 17.315918 | 0.633007 | 0.241927 | 1 | 79 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.279140 | 0.390174 | -0.018258 | 1 | 87 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 8.988132 | 1.000000 | 0.000000 | 0 | 112 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 11.650218 | 0.791448 | -0.068691 | 1 | 61 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 16.443932 | 0.609301 | 0.015530 | 1 | 57 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 26.666667 | 0.308898 | 0.097890 | 2 | 97 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 8.774775 | 0.999643 | 0.000000 | 0 | 40 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 14.626866 | 0.605095 | -0.031916 | 1 | 55 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 17.555556 | 0.383461 | -0.272636 | 1 | 74 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.538462 | 0.303636 | 0.164876 | 0 | 37 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 6.818836 | 1.000000 | 0.000000 | 0 | 22 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.686636 | 0.333002 | 0.131240 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 11.211538 | 0.499429 | 0.021112 | 1 | 26 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 10.020861 | 0.360539 | 0.192578 | 1 | 30 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 7.435689 | 1.000000 | 0.000000 | 0 | 18 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 7.042125 | 0.602689 | 0.054001 | 1 | 20 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 9.377246 | 0.519010 | 0.112179 | 0 | 29 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.683587 | 0.362760 | -0.029092 | 1 | 53 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 5.719524 | 1.000000 | 0.000000 | 0 | 38 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.577844 | 0.450972 | -0.084918 | 1 | 35 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.363636 | 0.368872 | -0.215112 | 1 | 23 |
