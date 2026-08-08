# Canonical Rewrite Distance Summary

- Input root: `classified-data`
- Thread count: 32
- Total files: 66080
- Successful distances: 61598
- Skipped identical raw AST predicate pairs: 4482
- Failures: 0
- Average distance: 13.816796
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 21.352495
- Average raw AST size: 24.936102
- Average canonical form size: 17.336212
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.814802
- Average normalized canonical distance: 0.730914
- CORRECT models with canonical distance 0 and raw AST distance > 0: 2180
- Min distance: 0
- Max distance: 141

## Canonical Representation Compression

Compression rate is `100 * (raw AST size - canonical form size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg canonical size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 31.025354 | 17.226415 | 44.476330% |
| classroom_fol | CORRECT | 1613 | 22.090515 | 12.699318 | 42.512348% |
| classroom_fol | OVERCONSTRAINED | 383 | 24.608355 | 14.310705 | 41.846154% |
| classroom_fol | UNDERCONSTRAINED | 311 | 32.742765 | 18.768489 | 42.678975% |
| classroom_rl | BOTH | 1219 | 20.041838 | 12.436423 | 37.947689% |
| classroom_rl | CORRECT | 1118 | 16.245975 | 10.176208 | 37.361669% |
| classroom_rl | OVERCONSTRAINED | 547 | 16.102377 | 10.482633 | 34.900091% |
| classroom_rl | UNDERCONSTRAINED | 499 | 20.356713 | 12.659319 | 37.812562% |
| coursesNew | BOTH | 1803 | 28.258458 | 18.064337 | 36.074583% |
| coursesNew | CORRECT | 1338 | 22.925262 | 14.428251 | 37.063963% |
| coursesNew | OVERCONSTRAINED | 327 | 22.602446 | 13.581040 | 39.913408% |
| coursesNew | UNDERCONSTRAINED | 1453 | 26.898830 | 17.250516 | 35.868898% |
| coursesOld | BOTH | 4001 | 28.817546 | 18.912022 | 34.373238% |
| coursesOld | CORRECT | 2148 | 20.862197 | 13.586127 | 34.876819% |
| coursesOld | OVERCONSTRAINED | 763 | 22.913499 | 15.778506 | 31.138821% |
| coursesOld | UNDERCONSTRAINED | 2576 | 26.246894 | 16.448370 | 37.332130% |
| cv_v1 | BOTH | 258 | 26.217054 | 17.918605 | 31.652868% |
| cv_v1 | CORRECT | 106 | 24.132075 | 16.547170 | 31.430805% |
| cv_v1 | OVERCONSTRAINED | 225 | 27.337778 | 18.008889 | 34.124533% |
| cv_v1 | UNDERCONSTRAINED | 219 | 19.662100 | 14.442922 | 26.544357% |
| cv_v2 | BOTH | 71 | 32.690141 | 29.098592 | 10.986644% |
| cv_v2 | CORRECT | 57 | 27.491228 | 20.105263 | 26.866624% |
| cv_v2 | OVERCONSTRAINED | 105 | 31.733333 | 26.780952 | 15.606242% |
| cv_v2 | UNDERCONSTRAINED | 40 | 28.175000 | 24.425000 | 13.309672% |
| graphs | BOTH | 361 | 17.130194 | 12.506925 | 26.989004% |
| graphs | CORRECT | 820 | 18.193902 | 12.236585 | 32.743481% |
| graphs | OVERCONSTRAINED | 645 | 18.813953 | 12.103876 | 35.665431% |
| graphs | UNDERCONSTRAINED | 326 | 17.628834 | 11.404908 | 35.305377% |
| lts | BOTH | 555 | 20.605405 | 13.477477 | 34.592515% |
| lts | CORRECT | 249 | 20.080321 | 12.477912 | 37.860000% |
| lts | OVERCONSTRAINED | 458 | 18.788210 | 11.753275 | 37.443347% |
| lts | UNDERCONSTRAINED | 254 | 20.716535 | 13.570866 | 34.492588% |
| productionLineNew | BOTH | 656 | 27.629573 | 18.876524 | 31.680000% |
| productionLineNew | CORRECT | 693 | 24.813853 | 17.851371 | 28.058851% |
| productionLineNew | OVERCONSTRAINED | 320 | 27.128125 | 18.809375 | 30.664670% |
| productionLineNew | UNDERCONSTRAINED | 557 | 26.369838 | 17.872531 | 32.223584% |
| productionLine_v1 | BOTH | 107 | 19.336449 | 12.813084 | 33.736104% |
| productionLine_v1 | CORRECT | 145 | 19.275862 | 12.627586 | 34.490161% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 20.840000 | 13.810000 | 33.733205% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 10.627451 | 7.627451 | 28.228782% |
| productionLine_v2 | BOTH | 870 | 26.986207 | 18.406897 | 31.791464% |
| productionLine_v2 | CORRECT | 1124 | 25.467082 | 18.540036 | 27.200000% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 28.115987 | 20.037618 | 28.732300% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 26.048847 | 18.278155 | 29.831232% |
| socialMedia | BOTH | 4982 | 30.027298 | 20.967483 | 30.171930% |
| socialMedia | CORRECT | 4550 | 23.775824 | 15.802857 | 33.533925% |
| socialMedia | OVERCONSTRAINED | 1597 | 30.384471 | 22.094552 | 27.283406% |
| socialMedia | UNDERCONSTRAINED | 2871 | 27.824800 | 19.159178 | 31.143519% |
| trainStationNew | BOTH | 2325 | 25.243871 | 18.518710 | 26.640769% |
| trainStationNew | CORRECT | 1601 | 20.391006 | 15.642723 | 23.286161% |
| trainStationNew | OVERCONSTRAINED | 689 | 22.920174 | 15.519594 | 32.288501% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 18.144393 | 11.815668 | 34.879783% |
| trainStationOld | BOTH | 357 | 27.635854 | 21.801120 | 21.112913% |
| trainStationOld | CORRECT | 111 | 19.018018 | 15.837838 | 16.721933% |
| trainStationOld | OVERCONSTRAINED | 201 | 18.885572 | 16.164179 | 14.409905% |
| trainStationOld | UNDERCONSTRAINED | 207 | 25.685990 | 20.463768 | 20.331014% |
| trash_fol | BOTH | 377 | 16.602122 | 10.687003 | 35.628695% |
| trash_fol | CORRECT | 1667 | 14.949610 | 9.426515 | 36.944745% |
| trash_fol | OVERCONSTRAINED | 217 | 17.483871 | 11.815668 | 32.419610% |
| trash_fol | UNDERCONSTRAINED | 104 | 22.221154 | 14.519231 | 34.660320% |
| trash_ltl | BOTH | 1486 | 15.765141 | 14.610363 | 7.324882% |
| trash_ltl | CORRECT | 863 | 14.683662 | 13.244496 | 9.801136% |
| trash_ltl | OVERCONSTRAINED | 546 | 14.743590 | 13.073260 | 11.329193% |
| trash_ltl | UNDERCONSTRAINED | 835 | 14.780838 | 13.086228 | 11.464917% |
| trash_rl | BOTH | 591 | 12.673435 | 8.661591 | 31.655541% |
| trash_rl | CORRECT | 1009 | 12.201189 | 8.143707 | 33.254813% |
| trash_rl | OVERCONSTRAINED | 334 | 11.997006 | 8.655689 | 27.851260% |
| trash_rl | UNDERCONSTRAINED | 132 | 18.113636 | 11.621212 | 35.842744% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg canonical | Avg relative Levenshtein | Avg relative raw AST | Avg relative canonical |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **21.352495** | **13.816796** | **0.547644** | **0.814802** | **0.730914** |
| classroom_fol | BOTH | 1696 | 54.403302 | 27.541863 | 14.868514 | 0.624351 | 0.867580 | 0.821084 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 18.230006 | 9.494110 | 0.537345 | 0.826573 | 0.684786 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 21.561358 | 12.232376 | 0.596239 | 0.834813 | 0.788317 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 27.382637 | 15.041801 | 0.606512 | 0.822786 | 0.770655 |
| classroom_rl | BOTH | 1219 | 35.016407 | 17.537326 | 9.931091 | 0.574684 | 0.792343 | 0.686259 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 11.600179 | 5.692308 | 0.439188 | 0.658394 | 0.485491 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 13.149909 | 7.720293 | 0.487860 | 0.729021 | 0.634307 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 15.813627 | 8.875752 | 0.495818 | 0.692173 | 0.619083 |
| coursesNew | BOTH | 1803 | 53.808098 | 29.066556 | 17.797560 | 0.614704 | 0.952420 | 0.893635 |
| coursesNew | CORRECT | 1338 | 38.111360 | 20.405082 | 10.689088 | 0.589369 | 0.901084 | 0.739127 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 21.669725 | 10.987768 | 0.664941 | 0.926935 | 0.730344 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 25.195458 | 16.342051 | 0.528858 | 0.877661 | 0.826401 |
| coursesOld | BOTH | 4001 | 57.329168 | 29.029993 | 18.783554 | 0.614074 | 0.914419 | 0.876464 |
| coursesOld | CORRECT | 2148 | 38.013501 | 18.877095 | 10.644786 | 0.591233 | 0.878132 | 0.741399 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 23.201835 | 13.982962 | 0.647316 | 0.914475 | 0.759324 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 23.578028 | 15.561335 | 0.531564 | 0.805373 | 0.780260 |
| cv_v1 | BOTH | 258 | 53.255814 | 30.395349 | 22.279070 | 0.661750 | 0.951615 | 0.843722 |
| cv_v1 | CORRECT | 106 | 27.886792 | 18.396226 | 11.500000 | 0.405510 | 0.666892 | 0.587618 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 26.480000 | 17.982222 | 0.591220 | 0.821625 | 0.731582 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 23.652968 | 15.397260 | 0.687474 | 0.908730 | 0.741047 |
| cv_v2 | BOTH | 71 | 59.929577 | 42.295775 | 37.380282 | 0.599896 | 1.042707 | 1.005123 |
| cv_v2 | CORRECT | 57 | 30.473684 | 27.105263 | 17.210526 | 0.430811 | 0.871917 | 0.707394 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 37.200000 | 31.428571 | 0.572770 | 0.979328 | 0.900781 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 36.975000 | 31.525000 | 0.590867 | 1.057202 | 0.962619 |
| graphs | BOTH | 361 | 24.570637 | 16.379501 | 10.282548 | 0.648332 | 0.866986 | 0.743880 |
| graphs | CORRECT | 820 | 25.169512 | 13.968293 | 8.551220 | 0.594930 | 0.729476 | 0.633555 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 14.547287 | 8.860465 | 0.479910 | 0.696990 | 0.661019 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 16.042945 | 9.223926 | 0.617945 | 0.848430 | 0.752320 |
| lts | BOTH | 555 | 50.536937 | 31.947748 | 19.551351 | 0.641920 | 0.899629 | 0.750054 |
| lts | CORRECT | 249 | 29.991968 | 17.823293 | 7.606426 | 0.550300 | 0.717748 | 0.468825 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 28.930131 | 17.218341 | 0.615166 | 0.837323 | 0.698388 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 24.204724 | 15.681102 | 0.556787 | 0.740294 | 0.686954 |
| productionLineNew | BOTH | 656 | 45.213415 | 27.118902 | 17.160061 | 0.509207 | 0.876007 | 0.787280 |
| productionLineNew | CORRECT | 693 | 34.992785 | 19.497835 | 11.948052 | 0.445274 | 0.732111 | 0.569187 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 22.896875 | 14.875000 | 0.459963 | 0.756245 | 0.700517 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 28.958707 | 17.254937 | 0.528572 | 0.946102 | 0.768948 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 20.177570 | 11.626168 | 0.531859 | 0.902236 | 0.713711 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 15.496552 | 8.958621 | 0.434531 | 0.747618 | 0.666943 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 18.340000 | 12.500000 | 0.451724 | 0.793595 | 0.745238 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 11.503268 | 7.392157 | 0.578122 | 0.685480 | 0.647678 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 26.224138 | 16.645977 | 0.499213 | 0.857505 | 0.774592 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 21.886121 | 14.531139 | 0.477882 | 0.759308 | 0.638611 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 25.315047 | 16.735110 | 0.495962 | 0.822541 | 0.752602 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 26.687924 | 16.793758 | 0.540061 | 0.886516 | 0.749503 |
| socialMedia | BOTH | 4982 | 50.487756 | 27.394018 | 18.780409 | 0.581993 | 0.845781 | 0.814471 |
| socialMedia | CORRECT | 4550 | 28.614945 | 18.061099 | 10.813846 | 0.419222 | 0.650753 | 0.538294 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 27.669380 | 19.248591 | 0.543362 | 0.822909 | 0.773678 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 22.687565 | 17.260188 | 0.533680 | 0.761029 | 0.816095 |
| trainStationNew | BOTH | 2325 | 43.576774 | 21.452903 | 17.289032 | 0.588892 | 0.788251 | 0.808139 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 14.175515 | 8.995003 | 0.461784 | 0.638123 | 0.520230 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 18.731495 | 11.388970 | 0.506348 | 0.725510 | 0.631316 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 13.102151 | 16.408602 | 0.509954 | 0.632455 | 0.832693 |
| trainStationOld | BOTH | 357 | 56.574230 | 38.296919 | 28.549020 | 0.629920 | 1.037705 | 0.922869 |
| trainStationOld | CORRECT | 111 | 29.864865 | 16.477477 | 9.135135 | 0.531537 | 0.831198 | 0.527010 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 22.009950 | 15.422886 | 0.570660 | 0.971965 | 0.744509 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 27.811594 | 19.922705 | 0.602022 | 0.937869 | 0.848151 |
| trash_fol | BOTH | 377 | 27.262599 | 15.273210 | 8.580902 | 0.613723 | 0.920837 | 0.788413 |
| trash_fol | CORRECT | 1667 | 26.151170 | 14.207558 | 6.808038 | 0.649266 | 0.935071 | 0.670235 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 17.064516 | 9.695853 | 0.684851 | 0.916113 | 0.756010 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 19.875000 | 11.500000 | 0.655198 | 0.885178 | 0.777453 |
| trash_ltl | BOTH | 1486 | 29.627187 | 14.327725 | 11.183715 | 0.538142 | 0.847631 | 0.703884 |
| trash_ltl | CORRECT | 863 | 20.166860 | 11.067207 | 7.633835 | 0.385829 | 0.738040 | 0.579895 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 11.591575 | 7.018315 | 0.470347 | 0.755486 | 0.524536 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 13.219162 | 10.726946 | 0.485105 | 0.838913 | 0.776027 |
| trash_rl | BOTH | 591 | 18.964467 | 11.690355 | 6.690355 | 0.577751 | 0.863935 | 0.711053 |
| trash_rl | CORRECT | 1009 | 18.356789 | 11.341923 | 5.712587 | 0.582256 | 0.851210 | 0.639672 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 11.479042 | 6.571856 | 0.612100 | 0.830253 | 0.661506 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 16.651515 | 8.590909 | 0.617090 | 0.872377 | 0.690619 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 10
- Average candidate reward: 0.567082
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.432918
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, distance vs candidate reward: -0.040694

- Pearson correlation, Levenshtein vs candidate reward: -0.089408
- Pearson correlation, raw AST tree distance vs candidate reward: -0.071860

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.048835
- Pearson correlation, normalized canonical distance vs candidate reward: -0.080497

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 14.868514 | 0.244291 | -0.157207 | 1 | 52 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 9.494110 | 1.000000 | 0.000000 | 0 | 64 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 12.232376 | 0.413947 | 0.046897 | 1 | 68 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 15.041801 | 0.204409 | 0.278734 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 9.931091 | 0.280459 | -0.100594 | 1 | 62 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.692308 | 1.000000 | 0.000000 | 0 | 31 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 7.720293 | 0.428192 | 0.113083 | 1 | 53 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 8.875752 | 0.156198 | 0.259120 | 1 | 41 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 17.797560 | 0.204531 | -0.196483 | 1 | 53 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 10.689088 | 1.000000 | 0.000000 | 0 | 47 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 10.987768 | 0.660952 | -0.250012 | 1 | 48 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 16.342051 | 0.540435 | -0.148346 | 1 | 48 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 18.783554 | 0.158800 | -0.130544 | 1 | 129 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.644786 | 1.000000 | 0.000000 | 0 | 41 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 13.982962 | 0.523328 | -0.245471 | 1 | 61 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 15.561335 | 0.492757 | -0.117771 | 1 | 54 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 22.279070 | 0.216721 | -0.079977 | 4 | 50 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 11.500000 | 1.000000 | 0.000000 | 0 | 43 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 17.982222 | 0.185523 | -0.025044 | 1 | 43 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 15.397260 | 0.202292 | 0.320950 | 2 | 34 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 37.380282 | 0.582386 | 0.180753 | 3 | 91 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 17.210526 | 1.000000 | 0.000000 | 0 | 43 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 31.428571 | 0.513380 | 0.267879 | 1 | 92 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 31.525000 | 0.451040 | 0.566291 | 1 | 89 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.282548 | 0.382271 | 0.114472 | 1 | 40 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.551220 | 0.999988 | 0.000000 | 0 | 69 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.860465 | 0.571766 | 0.053473 | 1 | 37 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.223926 | 0.485396 | 0.101414 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 19.551351 | 0.214955 | 0.291292 | 1 | 63 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 7.606426 | 1.000000 | 0.000000 | 0 | 45 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 17.218341 | 0.340648 | 0.156695 | 1 | 88 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 15.681102 | 0.143861 | 0.226788 | 1 | 79 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 17.160061 | 0.320085 | -0.155564 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 11.948052 | 1.000000 | 0.000000 | 0 | 77 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.875000 | 0.309684 | -0.202886 | 1 | 57 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 17.254937 | 0.557468 | -0.155758 | 2 | 76 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.626168 | 0.135144 | 0.478722 | 1 | 36 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 8.958621 | 1.000000 | 0.000000 | 0 | 32 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.500000 | 0.059505 | 0.180981 | 1 | 28 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.392157 | 0.436317 | -0.142197 | 2 | 32 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 16.645977 | 0.304322 | -0.043310 | 1 | 81 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 14.531139 | 1.000000 | 0.000000 | 0 | 80 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 16.735110 | 0.327335 | -0.305067 | 1 | 78 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 16.793758 | 0.696852 | -0.010635 | 1 | 72 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 18.780409 | 0.244656 | 0.153469 | 1 | 106 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.813846 | 0.999560 | 0.000000 | 0 | 141 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 19.248591 | 0.179442 | 0.003089 | 1 | 108 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 17.260188 | 0.633007 | 0.240805 | 1 | 79 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.289032 | 0.390174 | -0.018417 | 1 | 88 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 8.995003 | 1.000000 | 0.000000 | 0 | 113 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 11.388970 | 0.791448 | -0.081365 | 1 | 62 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 16.408602 | 0.609301 | 0.008621 | 1 | 59 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 28.549020 | 0.308898 | 0.104502 | 2 | 100 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 9.135135 | 0.999643 | 0.000000 | 0 | 36 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 15.422886 | 0.605095 | -0.028508 | 1 | 54 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 19.922705 | 0.383461 | -0.291989 | 1 | 76 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.580902 | 0.303636 | 0.163162 | 1 | 37 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 6.808038 | 1.000000 | 0.000000 | 0 | 22 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.695853 | 0.333002 | 0.132789 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 11.500000 | 0.499429 | 0.032128 | 1 | 26 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 11.183715 | 0.360539 | 0.251805 | 1 | 32 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 7.633835 | 1.000000 | 0.000000 | 0 | 19 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 7.018315 | 0.602689 | 0.029381 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 10.726946 | 0.519010 | 0.118878 | 1 | 29 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.690355 | 0.362760 | -0.027537 | 1 | 53 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 5.712587 | 1.000000 | 0.000000 | 0 | 38 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.571856 | 0.450972 | -0.083348 | 1 | 35 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.590909 | 0.368872 | -0.242790 | 1 | 23 |
