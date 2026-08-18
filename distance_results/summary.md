# Canonical Rewrite Distance Summary

- Input root: `/home/augustus/ACGN/classified-data`
- Thread count: 32
- Canonical engine: `CanonicalAlloyPipeline` (`canonical-alloy-pipeline-v10-three-layer`)
- Exact graph: `TypedSlottedPortEGraph`; invariants: `strict-every-transition`; certificates: required
- Primary metric: established repair metric over the certified quotient; compatibility manifest ID `certified-legacy-repair-distance-v5`
- Canonical representative TED retained only as baseline: `canonical-representative-ted-v1`
- Co-maintained Fast Rewrite IR metric retained as a differential oracle: yes
- Total files: 66080
- Successful distances: 61598
- Skipped identical raw AST predicate pairs: 4482
- Failures: 0
- Average certified repair distance: 14.041998
- Average canonical representative TED baseline: 37.119533
- Average direct reference-metric distance: 14.029027
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 22.841358
- Average raw AST size: 26.787315
- Average repair observation size: 18.117812
- Average canonical representative tree size: 39.169843
- Average reference NormalForm metric size: 18.126871
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.811451
- Average normalized certified repair distance: 0.717861
- Average normalized canonical representative TED: 0.903699
- Average normalized direct reference-metric distance: 0.716832
- CORRECT models with canonical distance 0 and raw AST distance > 0: 2317
- Incorrect zero-distance merges: 0
- Inexact alpha searches: 0
- Average certified repair metric time: 0.104502 ms
- Average canonical representative TED time: 0.498176 ms
- Min distance: 0
- Max distance: 139

## Repair Observation Compression

Compression rate is `100 * (raw AST size - repair observation size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg repair observation size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 33.897406 | 20.631486 | 39.135502% |
| classroom_fol | CORRECT | 1613 | 24.099814 | 14.551767 | 39.618759% |
| classroom_fol | OVERCONSTRAINED | 383 | 26.671018 | 16.187990 | 39.304944% |
| classroom_fol | UNDERCONSTRAINED | 311 | 35.546624 | 21.099678 | 40.642243% |
| classroom_rl | BOTH | 1219 | 21.272354 | 13.739130 | 35.413212% |
| classroom_rl | CORRECT | 1118 | 17.205725 | 10.982111 | 36.171761% |
| classroom_rl | OVERCONSTRAINED | 547 | 17.093236 | 11.544790 | 32.459893% |
| classroom_rl | UNDERCONSTRAINED | 499 | 21.615230 | 13.829659 | 36.018913% |
| coursesNew | BOTH | 1803 | 30.561287 | 20.677205 | 32.341839% |
| coursesNew | CORRECT | 1338 | 24.857250 | 14.631540 | 41.137737% |
| coursesNew | OVERCONSTRAINED | 327 | 24.660550 | 14.987768 | 39.223710% |
| coursesNew | UNDERCONSTRAINED | 1453 | 29.090158 | 19.919477 | 31.525031% |
| coursesOld | BOTH | 4001 | 31.062484 | 21.650587 | 30.299885% |
| coursesOld | CORRECT | 2148 | 22.381750 | 13.649441 | 39.015309% |
| coursesOld | OVERCONSTRAINED | 763 | 24.693316 | 16.595020 | 32.795499% |
| coursesOld | UNDERCONSTRAINED | 2576 | 28.365295 | 19.086180 | 32.712915% |
| cv_v1 | BOTH | 258 | 27.833333 | 17.918605 | 35.621780% |
| cv_v1 | CORRECT | 106 | 25.726415 | 16.547170 | 35.680235% |
| cv_v1 | OVERCONSTRAINED | 225 | 29.266667 | 17.875556 | 38.921792% |
| cv_v1 | UNDERCONSTRAINED | 219 | 20.917808 | 14.538813 | 30.495525% |
| cv_v2 | BOTH | 71 | 35.450704 | 28.718310 | 18.990862% |
| cv_v2 | CORRECT | 57 | 29.017544 | 20.105263 | 30.713422% |
| cv_v2 | OVERCONSTRAINED | 105 | 34.333333 | 26.761905 | 22.052705% |
| cv_v2 | UNDERCONSTRAINED | 40 | 30.350000 | 24.800000 | 18.286656% |
| graphs | BOTH | 361 | 18.094183 | 12.484765 | 31.001225% |
| graphs | CORRECT | 820 | 19.539024 | 12.218293 | 37.467233% |
| graphs | OVERCONSTRAINED | 645 | 19.862016 | 12.097674 | 39.091406% |
| graphs | UNDERCONSTRAINED | 326 | 18.773006 | 11.610429 | 38.153595% |
| lts | BOTH | 555 | 22.138739 | 14.142342 | 36.119476% |
| lts | CORRECT | 249 | 21.534137 | 12.433735 | 42.260351% |
| lts | OVERCONSTRAINED | 458 | 20.034934 | 11.853712 | 40.834786% |
| lts | UNDERCONSTRAINED | 254 | 22.303150 | 13.748031 | 38.358341% |
| productionLineNew | BOTH | 656 | 29.251524 | 18.763720 | 35.853875% |
| productionLineNew | CORRECT | 693 | 26.637807 | 17.842713 | 33.017335% |
| productionLineNew | OVERCONSTRAINED | 320 | 28.875000 | 19.034375 | 34.080087% |
| productionLineNew | UNDERCONSTRAINED | 557 | 27.996409 | 17.798923 | 36.424266% |
| productionLine_v1 | BOTH | 107 | 20.345794 | 12.794393 | 37.115296% |
| productionLine_v1 | CORRECT | 145 | 20.372414 | 12.627586 | 38.016249% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 22.000000 | 13.810000 | 37.227273% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 11.326797 | 7.614379 | 32.775534% |
| productionLine_v2 | BOTH | 870 | 28.722989 | 18.497701 | 35.599664% |
| productionLine_v2 | CORRECT | 1124 | 27.223310 | 18.467082 | 32.164450% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 29.799373 | 19.943574 | 33.073848% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 27.697422 | 18.002714 | 35.002204% |
| socialMedia | BOTH | 4982 | 32.315937 | 20.830189 | 35.542056% |
| socialMedia | CORRECT | 4550 | 25.487912 | 15.757802 | 38.175390% |
| socialMedia | OVERCONSTRAINED | 1597 | 32.652473 | 21.891672 | 32.955548% |
| socialMedia | UNDERCONSTRAINED | 2871 | 29.847092 | 19.299896 | 35.337433% |
| trainStationNew | BOTH | 2325 | 27.021935 | 19.505806 | 27.814917% |
| trainStationNew | CORRECT | 1601 | 21.845097 | 16.608370 | 23.972094% |
| trainStationNew | OVERCONSTRAINED | 689 | 24.709724 | 17.383164 | 29.650514% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 19.366359 | 13.155914 | 32.068213% |
| trainStationOld | BOTH | 357 | 28.591036 | 21.753501 | 23.914960% |
| trainStationOld | CORRECT | 111 | 19.981982 | 15.927928 | 20.288548% |
| trainStationOld | OVERCONSTRAINED | 201 | 19.741294 | 16.139303 | 18.245968% |
| trainStationOld | UNDERCONSTRAINED | 207 | 26.676329 | 19.120773 | 28.323071% |
| trash_fol | BOTH | 377 | 17.997347 | 11.063660 | 38.526161% |
| trash_fol | CORRECT | 1667 | 16.296341 | 9.743251 | 40.212030% |
| trash_fol | OVERCONSTRAINED | 217 | 18.903226 | 11.949309 | 36.786933% |
| trash_fol | UNDERCONSTRAINED | 104 | 24.009615 | 15.009615 | 37.484982% |
| trash_ltl | BOTH | 1486 | 16.545087 | 14.973755 | 9.497275% |
| trash_ltl | CORRECT | 863 | 15.442642 | 14.315180 | 7.300968% |
| trash_ltl | OVERCONSTRAINED | 546 | 15.584249 | 13.719780 | 11.963803% |
| trash_ltl | UNDERCONSTRAINED | 835 | 15.538922 | 13.995210 | 9.934489% |
| trash_rl | BOTH | 591 | 13.314721 | 9.008460 | 32.342102% |
| trash_rl | CORRECT | 1009 | 12.935580 | 8.435084 | 34.791603% |
| trash_rl | OVERCONSTRAINED | 334 | 12.565868 | 8.733533 | 30.497975% |
| trash_rl | UNDERCONSTRAINED | 132 | 19.310606 | 12.136364 | 37.151824% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg direct reference metric | Avg representative TED | Avg certified repair metric | Avg relative Levenshtein | Avg relative raw AST | Avg relative direct reference metric | Avg relative representative TED | Avg relative certified repair metric |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **22.841358** | **14.029027** | **37.119533** | **14.041998** | **0.547644** | **0.811451** | **0.716832** | **0.903699** | **0.717861** |
| classroom_fol | BOTH | 1696 | 54.403302 | 29.843750 | 17.307193 | 43.257665 | 17.323703 | 0.624351 | 0.860807 | 0.805077 | 0.929331 | 0.805978 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 19.522009 | 10.019839 | 27.625542 | 9.973342 | 0.537345 | 0.811881 | 0.630509 | 0.926789 | 0.629619 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 23.219321 | 13.543081 | 35.154047 | 13.553525 | 0.596239 | 0.824708 | 0.766016 | 0.926950 | 0.766582 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 29.591640 | 16.263666 | 40.463023 | 16.270096 | 0.606512 | 0.816431 | 0.746184 | 0.850195 | 0.746416 |
| classroom_rl | BOTH | 1219 | 35.016407 | 18.521739 | 11.292043 | 29.200164 | 11.299426 | 0.574684 | 0.779269 | 0.718892 | 0.887124 | 0.719253 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 12.228086 | 6.158318 | 17.563506 | 6.120751 | 0.439188 | 0.652025 | 0.482459 | 0.780307 | 0.482130 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 13.672761 | 8.862888 | 23.288848 | 8.864717 | 0.487860 | 0.706261 | 0.651964 | 0.824748 | 0.652040 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 16.621242 | 9.625251 | 25.218437 | 9.635271 | 0.495818 | 0.681461 | 0.621689 | 0.769334 | 0.622154 |
| coursesNew | BOTH | 1803 | 53.808098 | 31.171381 | 19.210205 | 50.678869 | 19.249584 | 0.614704 | 0.950469 | 0.880972 | 1.063422 | 0.883039 |
| coursesNew | CORRECT | 1338 | 38.111360 | 21.863229 | 10.769806 | 29.055306 | 10.850523 | 0.589369 | 0.890632 | 0.739204 | 0.956583 | 0.742201 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 23.553517 | 12.538226 | 33.235474 | 12.547401 | 0.664941 | 0.924123 | 0.782128 | 1.015519 | 0.782933 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 27.038541 | 17.811425 | 48.327598 | 17.814866 | 0.528858 | 0.871782 | 0.835806 | 1.023427 | 0.835988 |
| coursesOld | BOTH | 4001 | 57.329168 | 31.169958 | 20.091477 | 54.405149 | 20.104224 | 0.614074 | 0.913088 | 0.867145 | 1.045648 | 0.868230 |
| coursesOld | CORRECT | 2148 | 38.013501 | 20.067970 | 10.426443 | 27.229981 | 10.442272 | 0.591233 | 0.867271 | 0.733488 | 0.919133 | 0.734108 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 24.905636 | 14.298820 | 40.031455 | 14.314548 | 0.647316 | 0.908805 | 0.766205 | 1.015361 | 0.766781 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 25.468556 | 17.484472 | 47.614130 | 17.495730 | 0.531564 | 0.805671 | 0.830344 | 1.011220 | 0.830723 |
| cv_v1 | BOTH | 258 | 53.255814 | 33.003876 | 21.542636 | 58.395349 | 21.492248 | 0.661750 | 0.949859 | 0.817379 | 0.970500 | 0.816137 |
| cv_v1 | CORRECT | 106 | 27.886792 | 19.839623 | 11.018868 | 33.933962 | 10.905660 | 0.405510 | 0.670888 | 0.572052 | 0.775416 | 0.574244 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 28.657778 | 16.977778 | 47.595556 | 16.853333 | 0.591220 | 0.821782 | 0.701165 | 0.877467 | 0.697703 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 25.315068 | 14.931507 | 42.260274 | 14.894977 | 0.687474 | 0.900138 | 0.725309 | 0.936045 | 0.724427 |
| cv_v2 | BOTH | 71 | 59.929577 | 46.126761 | 36.197183 | 83.253521 | 35.957746 | 0.599896 | 1.051092 | 0.970263 | 0.982957 | 0.967788 |
| cv_v2 | CORRECT | 57 | 30.473684 | 28.719298 | 15.877193 | 50.982456 | 15.894737 | 0.430811 | 0.871002 | 0.667861 | 0.936715 | 0.670841 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 40.314286 | 30.533333 | 76.161905 | 30.647619 | 0.572770 | 0.983074 | 0.873420 | 0.977610 | 0.877211 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 40.150000 | 31.275000 | 77.150000 | 31.325000 | 0.590867 | 1.065550 | 0.955092 | 1.094321 | 0.956656 |
| graphs | BOTH | 361 | 24.570637 | 17.404432 | 10.202216 | 28.551247 | 10.202216 | 0.648332 | 0.867783 | 0.738373 | 0.986100 | 0.738373 |
| graphs | CORRECT | 820 | 25.169512 | 15.212195 | 8.510976 | 26.423171 | 8.503659 | 0.594930 | 0.736133 | 0.630423 | 0.952117 | 0.630384 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 15.305426 | 8.762791 | 27.502326 | 8.762791 | 0.479910 | 0.696726 | 0.651575 | 0.968512 | 0.651575 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 17.156442 | 9.340491 | 25.907975 | 9.340491 | 0.617945 | 0.848759 | 0.744298 | 0.998768 | 0.744298 |
| lts | BOTH | 555 | 50.536937 | 35.338739 | 21.700901 | 43.758559 | 21.277477 | 0.641920 | 0.895019 | 0.755090 | 0.933836 | 0.744306 |
| lts | CORRECT | 249 | 29.991968 | 19.634538 | 10.156627 | 23.807229 | 9.939759 | 0.550300 | 0.726068 | 0.537863 | 0.810913 | 0.532090 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 31.982533 | 20.159389 | 41.080786 | 19.877729 | 0.615166 | 0.839382 | 0.737521 | 0.939234 | 0.731752 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 26.740157 | 16.783465 | 38.208661 | 16.464567 | 0.556787 | 0.744322 | 0.689935 | 0.928211 | 0.682236 |
| productionLineNew | BOTH | 656 | 45.213415 | 28.455793 | 15.954268 | 41.532012 | 15.914634 | 0.509207 | 0.868169 | 0.743016 | 0.891551 | 0.742920 |
| productionLineNew | CORRECT | 693 | 34.992785 | 20.793651 | 11.401154 | 29.141414 | 11.408369 | 0.445274 | 0.726740 | 0.551477 | 0.696584 | 0.551642 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 24.296875 | 14.196875 | 35.615625 | 14.246875 | 0.459963 | 0.754725 | 0.674293 | 0.785955 | 0.675846 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 30.574506 | 16.346499 | 42.095153 | 16.357271 | 0.528572 | 0.944749 | 0.742429 | 0.889029 | 0.742811 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 21.149533 | 11.345794 | 32.682243 | 11.429907 | 0.531859 | 0.881969 | 0.699621 | 0.944453 | 0.704048 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 16.193103 | 9.013793 | 24.255172 | 9.020690 | 0.434531 | 0.735868 | 0.669433 | 0.832158 | 0.669733 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 19.050000 | 12.400000 | 33.770000 | 12.440000 | 0.451724 | 0.773732 | 0.739445 | 0.907931 | 0.741478 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 12.196078 | 7.241830 | 18.470588 | 7.241830 | 0.578122 | 0.676481 | 0.640722 | 0.761656 | 0.640722 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 27.693103 | 15.765517 | 40.274713 | 15.766667 | 0.499213 | 0.849087 | 0.739810 | 0.876863 | 0.740128 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 23.161922 | 13.292705 | 33.899466 | 13.283808 | 0.477882 | 0.749846 | 0.598381 | 0.788628 | 0.598563 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 26.752351 | 15.815047 | 38.608150 | 15.838558 | 0.495962 | 0.818031 | 0.723442 | 0.841094 | 0.724270 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 28.146540 | 15.720488 | 39.188602 | 15.721845 | 0.540061 | 0.880043 | 0.719730 | 0.852143 | 0.720346 |
| socialMedia | BOTH | 4982 | 50.487756 | 29.238659 | 18.321758 | 51.320955 | 18.381373 | 0.581993 | 0.839846 | 0.801043 | 1.010104 | 0.803402 |
| socialMedia | CORRECT | 4550 | 28.614945 | 19.426813 | 10.467033 | 28.463736 | 10.478681 | 0.419222 | 0.659936 | 0.522576 | 0.629469 | 0.523181 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 29.633062 | 18.643707 | 53.036318 | 18.714465 | 0.543362 | 0.821751 | 0.756253 | 0.961189 | 0.759313 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 24.183211 | 17.128875 | 48.590387 | 17.137931 | 0.533680 | 0.756691 | 0.808999 | 1.016476 | 0.809567 |
| trainStationNew | BOTH | 2325 | 43.576774 | 22.907527 | 17.312258 | 44.766022 | 17.332903 | 0.588892 | 0.783639 | 0.780863 | 0.915260 | 0.782030 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 15.271081 | 7.660212 | 22.649594 | 7.663960 | 0.461784 | 0.637859 | 0.420129 | 0.580637 | 0.420653 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 20.496372 | 10.312046 | 28.833091 | 10.341074 | 0.506348 | 0.735398 | 0.519572 | 0.678641 | 0.520816 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 13.814900 | 16.030722 | 41.753456 | 16.041475 | 0.509954 | 0.624067 | 0.805107 | 0.928027 | 0.805530 |
| trainStationOld | BOTH | 357 | 56.574230 | 39.745098 | 28.005602 | 67.946779 | 28.333333 | 0.629920 | 1.044956 | 0.902924 | 1.017636 | 0.912278 |
| trainStationOld | CORRECT | 111 | 29.864865 | 17.909910 | 8.927928 | 24.774775 | 9.342342 | 0.531537 | 0.853222 | 0.513796 | 0.749379 | 0.534337 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 23.398010 | 15.263682 | 35.646766 | 15.502488 | 0.570660 | 0.985240 | 0.739541 | 0.930885 | 0.752866 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 29.111111 | 18.772947 | 43.816425 | 19.130435 | 0.602022 | 0.946283 | 0.819032 | 0.929484 | 0.830157 |
| trash_fol | BOTH | 377 | 27.262599 | 16.522546 | 8.493369 | 20.580902 | 8.564987 | 0.613723 | 0.918588 | 0.761753 | 0.919811 | 0.766442 |
| trash_fol | CORRECT | 1667 | 26.151170 | 15.433713 | 6.892621 | 18.780444 | 6.886623 | 0.649266 | 0.930253 | 0.650950 | 0.977089 | 0.650923 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 18.377880 | 9.714286 | 23.894009 | 9.737327 | 0.684851 | 0.911574 | 0.747088 | 0.926213 | 0.748861 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 21.403846 | 11.336538 | 27.240385 | 11.346154 | 0.655198 | 0.883013 | 0.753390 | 0.887843 | 0.755512 |
| trash_ltl | BOTH | 1486 | 29.627187 | 15.105653 | 11.432032 | 23.086137 | 11.536339 | 0.538142 | 0.847314 | 0.698016 | 0.856706 | 0.705243 |
| trash_ltl | CORRECT | 863 | 20.166860 | 11.491309 | 7.210892 | 14.767092 | 7.195829 | 0.385829 | 0.730754 | 0.518810 | 0.654440 | 0.518286 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 12.260073 | 7.353480 | 17.994505 | 7.456044 | 0.470347 | 0.756828 | 0.522912 | 0.772041 | 0.533044 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 14.005988 | 11.414371 | 22.214371 | 11.431138 | 0.485105 | 0.844662 | 0.778704 | 0.920831 | 0.780654 |
| trash_rl | BOTH | 591 | 18.964467 | 12.240271 | 6.593909 | 16.453469 | 6.607445 | 0.577751 | 0.860063 | 0.686402 | 0.880772 | 0.687278 |
| trash_rl | CORRECT | 1009 | 18.356789 | 11.993062 | 5.616452 | 15.355798 | 5.616452 | 0.582256 | 0.845125 | 0.614281 | 0.945453 | 0.614281 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 12.017964 | 6.586826 | 16.335329 | 6.577844 | 0.612100 | 0.827469 | 0.660078 | 0.886704 | 0.660477 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 17.810606 | 8.772727 | 24.962121 | 8.757576 | 0.617090 | 0.869380 | 0.682282 | 0.914802 | 0.682647 |

## Reward Comparison

- Rewarded files: 0
- Reward failures: 0
- Reward pool size: 10
- Rewards enabled: false
- Average candidate reward: 0.000000
- Average ground-truth self reward: 0.000000
- Average reward gap: 0.000000
- Pearson correlation sample: non-CORRECT rewarded predicates (0 files)
- Pearson correlation, certified repair distance vs candidate reward: 0.000000

- Pearson correlation, canonical representative TED vs candidate reward: 0.000000
- Pearson correlation, direct reference-metric distance vs candidate reward: 0.000000
- Pearson correlation, Levenshtein vs candidate reward: 0.000000
- Pearson correlation, raw AST tree distance vs candidate reward: 0.000000

- Pearson correlation, normalized raw AST distance vs candidate reward: 0.000000
- Pearson correlation, normalized canonical distance vs candidate reward: 0.000000

- Pearson correlation, normalized canonical representative TED vs candidate reward: 0.000000

- Pearson correlation, normalized direct reference-metric distance vs candidate reward: 0.000000

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 17.323703 | 0.000000 | 0.000000 | 1 | 56 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 9.973342 | 0.000000 | 0.000000 | 0 | 61 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 13.553525 | 0.000000 | 0.000000 | 1 | 68 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 16.270096 | 0.000000 | 0.000000 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 11.299426 | 0.000000 | 0.000000 | 1 | 61 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 6.120751 | 0.000000 | 0.000000 | 0 | 31 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 8.864717 | 0.000000 | 0.000000 | 1 | 50 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 9.635271 | 0.000000 | 0.000000 | 1 | 31 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 19.249584 | 0.000000 | 0.000000 | 1 | 55 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 10.850523 | 0.000000 | 0.000000 | 0 | 44 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 12.547401 | 0.000000 | 0.000000 | 1 | 44 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 17.814866 | 0.000000 | 0.000000 | 1 | 46 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 20.104224 | 0.000000 | 0.000000 | 1 | 126 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.442272 | 0.000000 | 0.000000 | 0 | 38 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 14.314548 | 0.000000 | 0.000000 | 1 | 58 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 17.495730 | 0.000000 | 0.000000 | 1 | 47 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 21.492248 | 0.000000 | 0.000000 | 4 | 44 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 10.905660 | 0.000000 | 0.000000 | 0 | 43 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 16.853333 | 0.000000 | 0.000000 | 1 | 43 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 14.894977 | 0.000000 | 0.000000 | 2 | 35 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 35.957746 | 0.000000 | 0.000000 | 3 | 91 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 15.894737 | 0.000000 | 0.000000 | 0 | 43 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 30.647619 | 0.000000 | 0.000000 | 1 | 92 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 31.325000 | 0.000000 | 0.000000 | 1 | 89 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.202216 | 0.000000 | 0.000000 | 1 | 40 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.503659 | 0.000000 | 0.000000 | 0 | 67 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.762791 | 0.000000 | 0.000000 | 1 | 35 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.340491 | 0.000000 | 0.000000 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 21.277477 | 0.000000 | 0.000000 | 1 | 67 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 9.939759 | 0.000000 | 0.000000 | 0 | 42 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 19.877729 | 0.000000 | 0.000000 | 1 | 84 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 16.464567 | 0.000000 | 0.000000 | 1 | 67 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 15.914634 | 0.000000 | 0.000000 | 1 | 69 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 11.408369 | 0.000000 | 0.000000 | 0 | 75 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.246875 | 0.000000 | 0.000000 | 1 | 52 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 16.357271 | 0.000000 | 0.000000 | 2 | 70 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.429907 | 0.000000 | 0.000000 | 1 | 34 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 9.020690 | 0.000000 | 0.000000 | 0 | 32 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.440000 | 0.000000 | 0.000000 | 1 | 28 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.241830 | 0.000000 | 0.000000 | 2 | 30 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 15.766667 | 0.000000 | 0.000000 | 1 | 80 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 13.283808 | 0.000000 | 0.000000 | 0 | 73 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 15.838558 | 0.000000 | 0.000000 | 1 | 72 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 15.721845 | 0.000000 | 0.000000 | 1 | 71 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 18.381373 | 0.000000 | 0.000000 | 1 | 100 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.478681 | 0.000000 | 0.000000 | 0 | 139 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 18.714465 | 0.000000 | 0.000000 | 1 | 100 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 17.137931 | 0.000000 | 0.000000 | 1 | 75 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.332903 | 0.000000 | 0.000000 | 1 | 78 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 7.663960 | 0.000000 | 0.000000 | 0 | 101 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 10.341074 | 0.000000 | 0.000000 | 1 | 53 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 16.041475 | 0.000000 | 0.000000 | 1 | 52 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 28.333333 | 0.000000 | 0.000000 | 2 | 101 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 9.342342 | 0.000000 | 0.000000 | 0 | 33 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 15.502488 | 0.000000 | 0.000000 | 1 | 58 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 19.130435 | 0.000000 | 0.000000 | 1 | 77 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.564987 | 0.000000 | 0.000000 | 1 | 36 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 6.886623 | 0.000000 | 0.000000 | 0 | 17 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.737327 | 0.000000 | 0.000000 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 11.346154 | 0.000000 | 0.000000 | 1 | 26 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 11.536339 | 0.000000 | 0.000000 | 1 | 34 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 7.195829 | 0.000000 | 0.000000 | 0 | 20 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 7.456044 | 0.000000 | 0.000000 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 11.431138 | 0.000000 | 0.000000 | 1 | 30 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.607445 | 0.000000 | 0.000000 | 1 | 51 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 5.616452 | 0.000000 | 0.000000 | 0 | 37 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.577844 | 0.000000 | 0.000000 | 1 | 34 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.757576 | 0.000000 | 0.000000 | 1 | 23 |
