# Canonical Rewrite Distance Summary

DIAGNOSTIC ONLY: bounded native operation replay; unchecked pairs are not matches. Public certification and publication remain BLOCKED.

- Input root: `/home/augustus/ACGN/classified-data`
- Thread count: 16
- Memory-intensive worker limit: 16
- Maximum JVM heap bytes: 8589934592
- Certificate-Integrated IR engine: `CanonicalAlloyPipeline` (`canonical-alloy-pipeline-v40-domain-variable-evidence`)
- Fast Rewrite IR engine: `Canonical` / `CanonicalDistance`
- Exact graph: `TypedSlottedPortEGraph`; invariants: `strict-every-transition`; certificates: required
- Primary metric: established repair metric over the certified quotient; compatibility manifest ID `certified-fast-rewrite-repair-distance-v25-retained-phase-representation`
- Canonical representative TED retained only as baseline: `canonical-representative-ted-v1`
- Co-maintained Fast Rewrite IR metric retained as a differential oracle: yes
- Total files: 66080
- Native operation replay coverage (not certification): {"schema":"acgn-native-operation-comparison-v1","mismatches":0,"uncheckedReasons":{},"examples":[],"invalidReplay":0,"unchecked":0,"matched":61598,"attempted":61598,"certificationStatus":"BLOCKED","errors":0,"coverageUnit":"completed pair comparison attempts; workers may finish ahead of ordered result writing"}
- Successful distances: 61598
- Skipped identical raw AST predicate pairs: 4482
- Failures: 0
- Average Certificate-Integrated IR repair distance: 13.960405
- Average canonical representative TED baseline: 32.125215
- Average Fast Rewrite IR distance: 13.960405
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 17.086902
- Average raw AST size: 19.668561
- Average Certificate-Integrated IR repair observation size: 17.965600
- Average canonical representative tree size: 33.272687
- Average Fast Rewrite IR NormalForm size: 17.965600
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.833664
- Average normalized Certificate-Integrated IR distance: 0.708853
- Average normalized canonical representative TED: 0.909333
- Average normalized Fast Rewrite IR distance: 0.708853
- CORRECT models with canonical distance 0 and raw AST distance > 0: 4413
- Incorrect zero-distance merges: 0
- Inexact alpha searches: 0
- Average certified repair metric time: 113.113902 ms
- Average canonical representative TED time: 0.438421 ms
- Min distance: 0
- Max distance: 166

## Repair Observation Compression

Compression rate is `100 * (raw AST size - repair observation size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg repair observation size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 25.447524 | 22.301297 | 12.363586% |
| classroom_fol | CORRECT | 1613 | 17.719777 | 14.979541 | 15.464278% |
| classroom_fol | OVERCONSTRAINED | 383 | 19.600522 | 17.308094 | 11.695751% |
| classroom_fol | UNDERCONSTRAINED | 311 | 26.649518 | 21.311897 | 20.028958% |
| classroom_rl | BOTH | 1219 | 14.843314 | 13.985234 | 5.780922% |
| classroom_rl | CORRECT | 1118 | 11.771020 | 10.965116 | 6.846505% |
| classroom_rl | OVERCONSTRAINED | 547 | 11.683729 | 11.645338 | 0.328587% |
| classroom_rl | UNDERCONSTRAINED | 499 | 15.248497 | 13.675351 | 10.316730% |
| coursesNew | BOTH | 1803 | 23.073766 | 21.223516 | 8.018845% |
| coursesNew | CORRECT | 1338 | 18.127055 | 15.012706 | 17.180671% |
| coursesNew | OVERCONSTRAINED | 327 | 18.122324 | 14.874618 | 17.921026% |
| coursesNew | UNDERCONSTRAINED | 1453 | 21.972471 | 19.993118 | 9.008332% |
| coursesOld | BOTH | 4001 | 23.503624 | 22.208698 | 5.509475% |
| coursesOld | CORRECT | 2148 | 16.009777 | 13.281192 | 17.043241% |
| coursesOld | OVERCONSTRAINED | 763 | 17.989515 | 16.325033 | 9.252513% |
| coursesOld | UNDERCONSTRAINED | 2576 | 21.341615 | 19.072981 | 10.630093% |
| cv_v1 | BOTH | 258 | 20.422481 | 18.418605 | 9.812109% |
| cv_v1 | CORRECT | 106 | 18.990566 | 16.594340 | 12.617983% |
| cv_v1 | OVERCONSTRAINED | 225 | 21.773333 | 17.662222 | 18.881404% |
| cv_v1 | UNDERCONSTRAINED | 219 | 15.365297 | 14.616438 | 4.873700% |
| cv_v2 | BOTH | 71 | 27.169014 | 27.859155 | -2.540176% |
| cv_v2 | CORRECT | 57 | 20.421053 | 20.122807 | 1.460481% |
| cv_v2 | OVERCONSTRAINED | 105 | 25.980952 | 26.971429 | -3.812317% |
| cv_v2 | UNDERCONSTRAINED | 40 | 22.900000 | 25.200000 | -10.043668% |
| graphs | BOTH | 361 | 12.340720 | 12.332410 | 0.067340% |
| graphs | CORRECT | 820 | 13.404878 | 12.114634 | 9.625182% |
| graphs | OVERCONSTRAINED | 645 | 13.258915 | 11.869767 | 10.477081% |
| graphs | UNDERCONSTRAINED | 326 | 12.941718 | 11.125767 | 14.031761% |
| lts | BOTH | 555 | 15.396396 | 14.452252 | 6.132241% |
| lts | CORRECT | 249 | 14.987952 | 12.610442 | 15.862808% |
| lts | OVERCONSTRAINED | 458 | 13.665939 | 11.862445 | 13.196996% |
| lts | UNDERCONSTRAINED | 254 | 15.562992 | 13.716535 | 11.864407% |
| productionLineNew | BOTH | 656 | 20.971037 | 18.431402 | 12.110198% |
| productionLineNew | CORRECT | 693 | 19.378066 | 17.222222 | 11.125177% |
| productionLineNew | OVERCONSTRAINED | 320 | 20.768750 | 18.996875 | 8.531447% |
| productionLineNew | UNDERCONSTRAINED | 557 | 20.484740 | 16.953321 | 17.239264% |
| productionLine_v1 | BOTH | 107 | 14.280374 | 12.504673 | 12.434555% |
| productionLine_v1 | CORRECT | 145 | 14.151724 | 12.537931 | 11.403509% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 15.450000 | 13.290000 | 13.980583% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 7.960784 | 7.366013 | 7.471264% |
| productionLine_v2 | BOTH | 870 | 20.481609 | 18.144828 | 11.409170% |
| productionLine_v2 | CORRECT | 1124 | 19.501779 | 17.911032 | 8.156934% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 21.119122 | 19.666144 | 6.879917% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 19.852103 | 17.534600 | 11.673843% |
| socialMedia | BOTH | 4982 | 24.202328 | 20.280811 | 16.203059% |
| socialMedia | CORRECT | 4550 | 18.673626 | 15.398242 | 17.540164% |
| socialMedia | OVERCONSTRAINED | 1597 | 24.428929 | 21.395116 | 12.418937% |
| socialMedia | UNDERCONSTRAINED | 2871 | 22.559387 | 18.551028 | 17.768034% |
| trainStationNew | BOTH | 2325 | 19.703656 | 19.071828 | 3.206653% |
| trainStationNew | CORRECT | 1601 | 15.620237 | 16.399750 | -4.990403% |
| trainStationNew | OVERCONSTRAINED | 689 | 17.805515 | 17.280116 | 2.950766% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 13.921659 | 12.682028 | 8.904336% |
| trainStationOld | BOTH | 357 | 20.532213 | 21.815126 | -6.248295% |
| trainStationOld | CORRECT | 111 | 14.342342 | 15.621622 | -8.919598% |
| trainStationOld | OVERCONSTRAINED | 201 | 14.069652 | 16.104478 | -14.462518% |
| trainStationOld | UNDERCONSTRAINED | 207 | 19.420290 | 17.502415 | 9.875622% |
| trash_fol | BOTH | 377 | 12.641910 | 10.819629 | 14.414603% |
| trash_fol | CORRECT | 1667 | 11.346131 | 8.811038 | 22.343238% |
| trash_fol | OVERCONSTRAINED | 217 | 13.382488 | 11.751152 | 12.190083% |
| trash_fol | UNDERCONSTRAINED | 104 | 17.336538 | 13.192308 | 23.904603% |
| trash_ltl | BOTH | 1486 | 11.643338 | 14.652086 | -25.840943% |
| trash_ltl | CORRECT | 863 | 10.899189 | 13.059096 | -19.817138% |
| trash_ltl | OVERCONSTRAINED | 546 | 10.882784 | 13.283883 | -22.063278% |
| trash_ltl | UNDERCONSTRAINED | 835 | 10.937725 | 12.932934 | -18.241542% |
| trash_rl | BOTH | 591 | 8.737733 | 8.840948 | -1.181255% |
| trash_rl | CORRECT | 1009 | 8.536174 | 7.813677 | 8.463950% |
| trash_rl | OVERCONSTRAINED | 334 | 8.149701 | 8.374251 | -2.755327% |
| trash_rl | UNDERCONSTRAINED | 132 | 13.515152 | 11.454545 | 15.246637% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg Fast Rewrite IR | Avg representative TED | Avg Certificate-Integrated IR | Avg relative Levenshtein | Avg relative raw AST | Avg relative Fast Rewrite IR | Avg relative representative TED | Avg relative Certificate-Integrated IR |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **17.086902** | **13.960405** | **32.125215** | **13.960405** | **0.547644** | **0.833664** | **0.708853** | **0.909333** | **0.708853** |
| classroom_fol | BOTH | 1696 | 54.403302 | 23.034788 | 19.302476 | 39.051887 | 19.302476 | 0.624351 | 0.887834 | 0.828578 | 0.989356 | 0.828578 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 14.737756 | 10.191569 | 23.365158 | 10.191569 | 0.537345 | 0.839291 | 0.577028 | 0.794196 | 0.577028 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 17.605744 | 14.992167 | 31.339426 | 14.992167 | 0.596239 | 0.848067 | 0.793905 | 0.981987 | 0.793905 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 22.768489 | 16.752412 | 37.048232 | 16.752412 | 0.606512 | 0.839564 | 0.752908 | 0.947405 | 0.752908 |
| classroom_rl | BOTH | 1219 | 35.016407 | 13.497129 | 11.789992 | 26.828548 | 11.789992 | 0.574684 | 0.803115 | 0.742723 | 0.948135 | 0.742723 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 8.852415 | 5.837209 | 15.172630 | 5.837209 | 0.439188 | 0.699531 | 0.423915 | 0.662395 | 0.423915 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 9.968921 | 9.517367 | 22.824497 | 9.517367 | 0.487860 | 0.731131 | 0.686916 | 0.897327 | 0.686916 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 12.152305 | 10.050100 | 24.304609 | 10.050100 | 0.495818 | 0.714155 | 0.656307 | 0.844807 | 0.656307 |
| coursesNew | BOTH | 1803 | 53.808098 | 23.124792 | 19.341653 | 44.221852 | 19.341653 | 0.614704 | 0.941881 | 0.879389 | 1.072413 | 0.879389 |
| coursesNew | CORRECT | 1338 | 38.111360 | 16.027653 | 12.666667 | 27.012706 | 12.666667 | 0.589369 | 0.895927 | 0.791415 | 1.035799 | 0.791415 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 17.171254 | 13.119266 | 29.541284 | 13.119266 | 0.664941 | 0.915757 | 0.813572 | 1.062758 | 0.813572 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 19.990365 | 17.483138 | 40.072953 | 17.483138 | 0.528858 | 0.856754 | 0.838773 | 1.008908 | 0.838773 |
| coursesOld | BOTH | 4001 | 57.329168 | 23.793302 | 20.189703 | 47.199700 | 20.189703 | 0.614074 | 0.925301 | 0.868156 | 1.073088 | 0.868156 |
| coursesOld | CORRECT | 2148 | 38.013501 | 14.661080 | 10.482775 | 22.892924 | 10.482775 | 0.591233 | 0.892638 | 0.724203 | 0.977325 | 0.724203 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 18.336828 | 14.361730 | 34.011796 | 14.361730 | 0.647316 | 0.919405 | 0.779163 | 1.051973 | 0.779163 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 19.390916 | 16.845885 | 38.502329 | 16.845885 | 0.531564 | 0.814440 | 0.828786 | 1.005249 | 0.828786 |
| cv_v1 | BOTH | 258 | 53.255814 | 24.891473 | 21.817829 | 53.166667 | 21.817829 | 0.661750 | 0.948298 | 0.824292 | 1.022517 | 0.824292 |
| cv_v1 | CORRECT | 106 | 27.886792 | 15.877358 | 10.481132 | 27.886792 | 10.481132 | 0.405510 | 0.719290 | 0.576606 | 0.783314 | 0.576606 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 22.284444 | 16.688889 | 43.355556 | 16.688889 | 0.591220 | 0.844972 | 0.702088 | 0.922415 | 0.702088 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 18.602740 | 14.981735 | 38.461187 | 14.981735 | 0.687474 | 0.900143 | 0.730830 | 0.976520 | 0.730830 |
| cv_v2 | BOTH | 71 | 59.929577 | 34.309859 | 35.464789 | 75.816901 | 35.464789 | 0.599896 | 1.025868 | 0.961536 | 1.018846 | 0.961536 |
| cv_v2 | CORRECT | 57 | 30.473684 | 17.140351 | 16.298246 | 45.421053 | 16.298246 | 0.430811 | 0.762514 | 0.676564 | 0.942225 | 0.676564 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 30.571429 | 31.190476 | 70.923810 | 31.190476 | 0.572770 | 0.992836 | 0.876949 | 1.012896 | 0.876949 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 29.625000 | 32.900000 | 70.650000 | 32.900000 | 0.590867 | 1.066017 | 0.999730 | 1.129248 | 0.999730 |
| graphs | BOTH | 361 | 24.570637 | 12.360111 | 10.235457 | 26.581717 | 10.235457 | 0.648332 | 0.920265 | 0.753380 | 1.007426 | 0.753380 |
| graphs | CORRECT | 820 | 25.169512 | 11.375610 | 8.424390 | 22.820732 | 8.424390 | 0.594930 | 0.798086 | 0.628513 | 0.956865 | 0.628513 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 10.218605 | 8.680620 | 26.012403 | 8.680620 | 0.479910 | 0.713761 | 0.662742 | 0.988932 | 0.662742 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 12.245399 | 9.039877 | 22.595092 | 9.039877 | 0.617945 | 0.877245 | 0.743181 | 1.012696 | 0.743181 |
| lts | BOTH | 555 | 50.536937 | 26.234234 | 21.540541 | 37.122523 | 21.540541 | 0.641920 | 0.923262 | 0.791837 | 0.993601 | 0.791837 |
| lts | CORRECT | 249 | 29.991968 | 14.582329 | 10.200803 | 20.550201 | 10.200803 | 0.550300 | 0.747385 | 0.563691 | 0.792840 | 0.563691 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 23.364629 | 20.550218 | 36.279476 | 20.550218 | 0.615166 | 0.856865 | 0.816980 | 1.027333 | 0.816980 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 19.862205 | 17.165354 | 33.688976 | 17.165354 | 0.556787 | 0.783206 | 0.784647 | 1.025782 | 0.784647 |
| productionLineNew | BOTH | 656 | 45.213415 | 20.420732 | 17.596037 | 39.172256 | 17.596037 | 0.509207 | 0.874209 | 0.781948 | 0.952948 | 0.781948 |
| productionLineNew | CORRECT | 693 | 34.992785 | 15.523810 | 11.028860 | 24.549784 | 11.028860 | 0.445274 | 0.744545 | 0.543847 | 0.741210 | 0.543847 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 17.987500 | 14.884375 | 34.731250 | 14.884375 | 0.459963 | 0.780481 | 0.694962 | 0.880881 | 0.694962 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 22.021544 | 18.603232 | 39.890485 | 18.603232 | 0.528572 | 0.948695 | 0.793612 | 0.963979 | 0.793612 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 15.785047 | 11.112150 | 30.327103 | 11.112150 | 0.531859 | 0.904081 | 0.698881 | 0.998828 | 0.698881 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 11.868966 | 9.165517 | 22.931034 | 9.165517 | 0.434531 | 0.765052 | 0.681022 | 0.874414 | 0.681022 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 14.100000 | 12.800000 | 33.270000 | 12.800000 | 0.451724 | 0.785496 | 0.771760 | 0.986502 | 0.771760 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 9.032680 | 7.228758 | 17.202614 | 7.228758 | 0.578122 | 0.708447 | 0.658751 | 0.802850 | 0.658751 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 19.970115 | 16.748276 | 37.668966 | 16.748276 | 0.499213 | 0.853255 | 0.764284 | 0.945781 | 0.764284 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 16.917260 | 13.226868 | 29.001779 | 13.226868 | 0.477882 | 0.760295 | 0.596389 | 0.833290 | 0.596389 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 19.641066 | 16.598746 | 37.568966 | 16.598746 | 0.495962 | 0.844679 | 0.750232 | 0.935415 | 0.750232 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 20.054274 | 17.138399 | 35.682497 | 17.138399 | 0.540061 | 0.880948 | 0.754565 | 0.932475 | 0.754565 |
| socialMedia | BOTH | 4982 | 50.487756 | 22.307507 | 17.614412 | 42.224408 | 17.614412 | 0.581993 | 0.859294 | 0.790119 | 1.027183 | 0.790119 |
| socialMedia | CORRECT | 4550 | 28.614945 | 14.883736 | 10.089011 | 24.019121 | 10.089011 | 0.419222 | 0.695863 | 0.522532 | 0.679770 | 0.522532 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 22.495304 | 18.663745 | 43.851597 | 18.663745 | 0.543362 | 0.841129 | 0.775001 | 1.009838 | 0.775001 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 18.908743 | 16.197492 | 41.177987 | 16.197492 | 0.533680 | 0.785731 | 0.798105 | 1.053312 | 0.798105 |
| trainStationNew | BOTH | 2325 | 43.576774 | 17.474839 | 17.334624 | 40.618065 | 17.334624 | 0.588892 | 0.819806 | 0.788765 | 0.939638 | 0.788765 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 11.334791 | 7.351655 | 17.925047 | 7.351655 | 0.461784 | 0.658098 | 0.389876 | 0.513168 | 0.389876 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 15.364296 | 11.550073 | 29.166909 | 11.550073 | 0.506348 | 0.767370 | 0.574926 | 0.779966 | 0.574926 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 10.981567 | 16.016897 | 35.899386 | 16.016897 | 0.509954 | 0.682687 | 0.815638 | 0.897391 | 0.815638 |
| trainStationOld | BOTH | 357 | 56.574230 | 29.459384 | 27.621849 | 60.655462 | 27.621849 | 0.629920 | 1.059249 | 0.898985 | 1.025209 | 0.898985 |
| trainStationOld | CORRECT | 111 | 29.864865 | 13.441441 | 7.855856 | 19.027027 | 7.855856 | 0.531537 | 0.877128 | 0.446922 | 0.626460 | 0.446922 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 17.547264 | 14.850746 | 33.398010 | 14.850746 | 0.570660 | 1.019222 | 0.719891 | 0.965662 | 0.719891 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 21.826087 | 17.328502 | 38.657005 | 17.328502 | 0.602022 | 0.976935 | 0.786545 | 0.926755 | 0.786545 |
| trash_fol | BOTH | 377 | 27.262599 | 11.514589 | 8.368700 | 17.769231 | 8.368700 | 0.613723 | 0.916050 | 0.748026 | 0.900326 | 0.748026 |
| trash_fol | CORRECT | 1667 | 26.151170 | 11.079184 | 5.415717 | 12.534493 | 5.415717 | 0.649266 | 0.966178 | 0.447057 | 0.594357 | 0.447057 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 12.834101 | 9.663594 | 21.497696 | 9.663594 | 0.684851 | 0.904688 | 0.748302 | 0.950671 | 0.748302 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 15.557692 | 10.317308 | 22.038462 | 10.317308 | 0.655198 | 0.892703 | 0.741459 | 0.889608 | 0.741459 |
| trash_ltl | BOTH | 1486 | 29.627187 | 10.890983 | 11.004711 | 22.528264 | 11.004711 | 0.538142 | 0.868419 | 0.680813 | 0.857574 | 0.680813 |
| trash_ltl | CORRECT | 863 | 20.166860 | 8.126304 | 4.735805 | 10.212051 | 4.735805 | 0.385829 | 0.736275 | 0.304419 | 0.399556 | 0.304419 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 8.930403 | 7.001832 | 18.351648 | 7.001832 | 0.470347 | 0.801440 | 0.510388 | 0.825902 | 0.510388 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 9.972455 | 10.580838 | 20.536527 | 10.580838 | 0.485105 | 0.862441 | 0.749243 | 0.899974 | 0.749243 |
| trash_rl | BOTH | 591 | 18.964467 | 8.086294 | 6.507614 | 15.250423 | 6.507614 | 0.577751 | 0.876816 | 0.683330 | 0.883125 | 0.683330 |
| trash_rl | CORRECT | 1009 | 18.356789 | 8.499504 | 4.673935 | 12.066402 | 4.673935 | 0.582256 | 0.916752 | 0.500276 | 0.770740 | 0.500276 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 8.149701 | 6.320359 | 15.344311 | 6.320359 | 0.612100 | 0.872160 | 0.660250 | 0.915702 | 0.660250 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 12.848485 | 8.606061 | 21.833333 | 8.606061 | 0.617090 | 0.893899 | 0.687285 | 0.922596 | 0.687285 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 100
- Rewards enabled: true
- Average candidate reward: 0.554601
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.445399
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, Certificate-Integrated IR distance vs candidate reward: -0.064219

- Pearson correlation, canonical representative TED vs candidate reward: -0.060850
- Pearson correlation, Fast Rewrite IR distance vs candidate reward: -0.064219
- Pearson correlation, Levenshtein vs candidate reward: -0.090795
- Pearson correlation, raw AST tree distance vs candidate reward: -0.087821

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.071160
- Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward: -0.079509

- Pearson correlation, normalized canonical representative TED vs candidate reward: -0.093207

- Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward: -0.079509

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 19.302476 | 0.221406 | -0.082632 | 1 | 79 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 10.191569 | 1.000000 | 0.000000 | 0 | 39 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 14.992167 | 0.418354 | 0.129011 | 1 | 60 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 16.752412 | 0.275754 | 0.397682 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 11.789992 | 0.258242 | -0.022276 | 1 | 58 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.837209 | 1.000000 | 0.000000 | 0 | 43 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 9.517367 | 0.422926 | 0.128400 | 1 | 47 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 10.050100 | 0.174385 | 0.342317 | 1 | 31 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 19.341653 | 0.246501 | -0.185844 | 1 | 61 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 12.666667 | 1.000000 | 0.000000 | 0 | 50 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 13.119266 | 0.540050 | -0.060831 | 1 | 61 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 17.483138 | 0.425532 | -0.147491 | 1 | 51 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 20.189703 | 0.203963 | -0.154010 | 1 | 166 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.482775 | 1.000000 | 0.000000 | 0 | 43 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 14.361730 | 0.446171 | -0.138104 | 1 | 69 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 16.845885 | 0.415217 | -0.144780 | 1 | 58 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 21.817829 | 0.228550 | 0.019424 | 4 | 50 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 10.481132 | 1.000000 | 0.000000 | 0 | 41 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 16.688889 | 0.147501 | -0.109367 | 2 | 42 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 14.981735 | 0.194329 | 0.253549 | 3 | 37 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 35.464789 | 0.205966 | -0.042459 | 3 | 101 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 16.298246 | 1.000000 | 0.000000 | 0 | 53 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 31.190476 | 0.299230 | 0.182448 | 1 | 102 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 32.900000 | 0.437210 | 0.546222 | 3 | 99 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.235457 | 0.304664 | 0.091915 | 1 | 36 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.424390 | 0.999999 | 0.000000 | 0 | 60 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.680620 | 0.443294 | -0.064488 | 1 | 30 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.039877 | 0.487304 | 0.206515 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 21.540541 | 0.189667 | 0.351310 | 1 | 64 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 10.200803 | 1.000000 | 0.000000 | 0 | 35 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 20.550218 | 0.321068 | 0.260939 | 1 | 64 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 17.165354 | 0.172204 | 0.276737 | 1 | 64 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 17.596037 | 0.294607 | -0.146755 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 11.028860 | 1.000000 | 0.000000 | 0 | 80 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.884375 | 0.329941 | -0.199311 | 1 | 55 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 18.603232 | 0.552549 | -0.202124 | 1 | 79 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.112150 | 0.144778 | 0.537782 | 1 | 24 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 9.165517 | 1.000000 | 0.000000 | 0 | 33 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.800000 | 0.047098 | 0.159702 | 1 | 29 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.228758 | 0.440088 | -0.181040 | 2 | 23 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 16.748276 | 0.307091 | -0.040211 | 1 | 83 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 13.226868 | 1.000000 | 0.000000 | 0 | 105 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 16.598746 | 0.352790 | -0.329292 | 1 | 68 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 17.138399 | 0.693635 | -0.018826 | 1 | 75 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 17.614412 | 0.187684 | 0.001760 | 1 | 115 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.089011 | 0.999560 | 0.000000 | 0 | 124 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 18.663745 | 0.108430 | 0.019651 | 1 | 117 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 16.197492 | 0.645759 | 0.213951 | 1 | 86 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.334624 | 0.372981 | 0.040544 | 1 | 97 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 7.351655 | 1.000000 | 0.000000 | 0 | 102 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 11.550073 | 0.796660 | -0.080504 | 1 | 53 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 16.016897 | 0.648703 | -0.083823 | 1 | 50 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 27.621849 | 0.276158 | 0.115154 | 2 | 95 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 7.855856 | 0.999996 | 0.000000 | 0 | 31 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 14.850746 | 0.550904 | -0.030289 | 1 | 58 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 17.328502 | 0.330656 | -0.126355 | 1 | 59 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.368700 | 0.302927 | 0.263257 | 1 | 55 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 5.415717 | 1.000000 | 0.000000 | 0 | 19 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.663594 | 0.337689 | 0.244639 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 10.317308 | 0.487209 | 0.042524 | 1 | 20 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 11.004711 | 0.366455 | 0.176368 | 1 | 31 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 4.735805 | 1.000000 | 0.000000 | 0 | 18 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 7.001832 | 0.633484 | -0.133276 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 10.580838 | 0.578260 | 0.117176 | 1 | 30 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.507614 | 0.342525 | 0.223414 | 1 | 34 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 4.673935 | 1.000000 | 0.000000 | 0 | 28 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.320359 | 0.366014 | -0.111958 | 1 | 24 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.606061 | 0.370073 | -0.208886 | 1 | 23 |
