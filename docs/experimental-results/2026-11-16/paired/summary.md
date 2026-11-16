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
- Average Certificate-Integrated IR repair distance: 14.010974
- Average canonical representative TED baseline: 32.232069
- Average Fast Rewrite IR distance: 14.010974
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 17.086902
- Average raw AST size: 19.668561
- Average Certificate-Integrated IR repair observation size: 17.990925
- Average canonical representative tree size: 33.307770
- Average Fast Rewrite IR NormalForm size: 17.990925
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.833664
- Average normalized Certificate-Integrated IR distance: 0.711563
- Average normalized canonical representative TED: 0.913071
- Average normalized Fast Rewrite IR distance: 0.711563
- CORRECT models with canonical distance 0 and raw AST distance > 0: 4174
- Incorrect zero-distance merges: 0
- Inexact alpha searches: 0
- Average certified repair metric time: 112.524652 ms
- Average canonical representative TED time: 0.430015 ms
- Min distance: 0
- Max distance: 178

## Repair Observation Compression

Compression rate is `100 * (raw AST size - repair observation size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg repair observation size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 25.447524 | 22.303656 | 12.354318% |
| classroom_fol | CORRECT | 1613 | 17.719777 | 14.979541 | 15.464278% |
| classroom_fol | OVERCONSTRAINED | 383 | 19.600522 | 17.308094 | 11.695751% |
| classroom_fol | UNDERCONSTRAINED | 311 | 26.649518 | 21.311897 | 20.028958% |
| classroom_rl | BOTH | 1219 | 14.843314 | 13.984413 | 5.786449% |
| classroom_rl | CORRECT | 1118 | 11.771020 | 10.965116 | 6.846505% |
| classroom_rl | OVERCONSTRAINED | 547 | 11.683729 | 11.647166 | 0.312940% |
| classroom_rl | UNDERCONSTRAINED | 499 | 15.248497 | 13.679359 | 10.290446% |
| coursesNew | BOTH | 1803 | 23.073766 | 21.217970 | 8.042883% |
| coursesNew | CORRECT | 1338 | 18.127055 | 15.041106 | 17.023996% |
| coursesNew | OVERCONSTRAINED | 327 | 18.122324 | 14.856269 | 18.022275% |
| coursesNew | UNDERCONSTRAINED | 1453 | 21.972471 | 19.993118 | 9.008332% |
| coursesOld | BOTH | 4001 | 23.503624 | 22.273932 | 5.231928% |
| coursesOld | CORRECT | 2148 | 16.009777 | 13.348231 | 16.624502% |
| coursesOld | OVERCONSTRAINED | 763 | 17.989515 | 16.356488 | 9.077663% |
| coursesOld | UNDERCONSTRAINED | 2576 | 21.341615 | 19.078804 | 10.602808% |
| cv_v1 | BOTH | 258 | 20.422481 | 18.422481 | 9.793130% |
| cv_v1 | CORRECT | 106 | 18.990566 | 16.594340 | 12.617983% |
| cv_v1 | OVERCONSTRAINED | 225 | 21.773333 | 17.662222 | 18.881404% |
| cv_v1 | UNDERCONSTRAINED | 219 | 15.365297 | 14.616438 | 4.873700% |
| cv_v2 | BOTH | 71 | 27.169014 | 27.859155 | -2.540176% |
| cv_v2 | CORRECT | 57 | 20.421053 | 20.122807 | 1.460481% |
| cv_v2 | OVERCONSTRAINED | 105 | 25.980952 | 26.971429 | -3.812317% |
| cv_v2 | UNDERCONSTRAINED | 40 | 22.900000 | 25.200000 | -10.043668% |
| graphs | BOTH | 361 | 12.340720 | 12.332410 | 0.067340% |
| graphs | CORRECT | 820 | 13.404878 | 12.114634 | 9.625182% |
| graphs | OVERCONSTRAINED | 645 | 13.258915 | 11.866667 | 10.500468% |
| graphs | UNDERCONSTRAINED | 326 | 12.941718 | 11.125767 | 14.031761% |
| lts | BOTH | 555 | 15.396396 | 14.452252 | 6.132241% |
| lts | CORRECT | 249 | 14.987952 | 12.610442 | 15.862808% |
| lts | OVERCONSTRAINED | 458 | 13.665939 | 11.866812 | 13.165042% |
| lts | UNDERCONSTRAINED | 254 | 15.562992 | 13.716535 | 11.864407% |
| productionLineNew | BOTH | 656 | 20.971037 | 18.431402 | 12.110198% |
| productionLineNew | CORRECT | 693 | 19.378066 | 17.222222 | 11.125177% |
| productionLineNew | OVERCONSTRAINED | 320 | 20.768750 | 18.996875 | 8.531447% |
| productionLineNew | UNDERCONSTRAINED | 557 | 20.484740 | 16.953321 | 17.239264% |
| productionLine_v1 | BOTH | 107 | 14.280374 | 12.514019 | 12.369110% |
| productionLine_v1 | CORRECT | 145 | 14.151724 | 12.537931 | 11.403509% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 15.450000 | 13.430000 | 13.074434% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 7.960784 | 7.352941 | 7.635468% |
| productionLine_v2 | BOTH | 870 | 20.481609 | 18.152874 | 11.369886% |
| productionLine_v2 | CORRECT | 1124 | 19.501779 | 17.925267 | 8.083942% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 21.119122 | 19.666144 | 6.879917% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 19.852103 | 17.540027 | 11.646504% |
| socialMedia | BOTH | 4982 | 24.202328 | 20.281012 | 16.202229% |
| socialMedia | CORRECT | 4550 | 18.673626 | 15.398681 | 17.537810% |
| socialMedia | OVERCONSTRAINED | 1597 | 24.428929 | 21.395116 | 12.418937% |
| socialMedia | UNDERCONSTRAINED | 2871 | 22.559387 | 18.554511 | 17.752594% |
| trainStationNew | BOTH | 2325 | 19.703656 | 19.071828 | 3.206653% |
| trainStationNew | CORRECT | 1601 | 15.620237 | 16.399750 | -4.990403% |
| trainStationNew | OVERCONSTRAINED | 689 | 17.805515 | 17.280116 | 2.950766% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 13.921659 | 12.686636 | 8.871235% |
| trainStationOld | BOTH | 357 | 20.532213 | 21.803922 | -6.193724% |
| trainStationOld | CORRECT | 111 | 14.342342 | 15.621622 | -8.919598% |
| trainStationOld | OVERCONSTRAINED | 201 | 14.069652 | 16.124378 | -14.603960% |
| trainStationOld | UNDERCONSTRAINED | 207 | 19.420290 | 17.502415 | 9.875622% |
| trash_fol | BOTH | 377 | 12.641910 | 10.819629 | 14.414603% |
| trash_fol | CORRECT | 1667 | 11.346131 | 8.811038 | 22.343238% |
| trash_fol | OVERCONSTRAINED | 217 | 13.382488 | 11.751152 | 12.190083% |
| trash_fol | UNDERCONSTRAINED | 104 | 17.336538 | 13.192308 | 23.904603% |
| trash_ltl | BOTH | 1486 | 11.643338 | 14.810229 | -27.199168% |
| trash_ltl | CORRECT | 863 | 10.899189 | 13.922364 | -27.737614% |
| trash_ltl | OVERCONSTRAINED | 546 | 10.882784 | 13.388278 | -23.022551% |
| trash_ltl | UNDERCONSTRAINED | 835 | 10.937725 | 13.331737 | -21.887660% |
| trash_rl | BOTH | 591 | 8.737733 | 8.840948 | -1.181255% |
| trash_rl | CORRECT | 1009 | 8.536174 | 7.815659 | 8.440729% |
| trash_rl | OVERCONSTRAINED | 334 | 8.149701 | 8.374251 | -2.755327% |
| trash_rl | UNDERCONSTRAINED | 132 | 13.515152 | 11.454545 | 15.246637% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg Fast Rewrite IR | Avg representative TED | Avg Certificate-Integrated IR | Avg relative Levenshtein | Avg relative raw AST | Avg relative Fast Rewrite IR | Avg relative representative TED | Avg relative Certificate-Integrated IR |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **17.086902** | **14.010974** | **32.232069** | **14.010974** | **0.547644** | **0.833664** | **0.711563** | **0.913071** | **0.711563** |
| classroom_fol | BOTH | 1696 | 54.403302 | 23.034788 | 19.305425 | 39.056604 | 19.305425 | 0.624351 | 0.887834 | 0.828617 | 0.989350 | 0.828617 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 14.737756 | 10.191569 | 23.365158 | 10.191569 | 0.537345 | 0.839291 | 0.577028 | 0.794196 | 0.577028 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 17.605744 | 14.992167 | 31.331593 | 14.992167 | 0.596239 | 0.848067 | 0.793905 | 0.982333 | 0.793905 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 22.768489 | 16.752412 | 37.048232 | 16.752412 | 0.606512 | 0.839564 | 0.752908 | 0.947405 | 0.752908 |
| classroom_rl | BOTH | 1219 | 35.016407 | 13.497129 | 11.811321 | 26.866284 | 11.811321 | 0.574684 | 0.803115 | 0.744397 | 0.951433 | 0.744397 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 8.852415 | 5.876565 | 15.609123 | 5.876565 | 0.439188 | 0.699531 | 0.427460 | 0.683164 | 0.427460 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 9.968921 | 9.517367 | 22.851920 | 9.517367 | 0.487860 | 0.731131 | 0.686602 | 0.899783 | 0.686602 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 12.152305 | 10.088176 | 24.591182 | 10.088176 | 0.495818 | 0.714155 | 0.660873 | 0.862116 | 0.660873 |
| coursesNew | BOTH | 1803 | 53.808098 | 23.124792 | 19.339434 | 44.221852 | 19.339434 | 0.614704 | 0.941881 | 0.879445 | 1.072596 | 0.879445 |
| coursesNew | CORRECT | 1338 | 38.111360 | 16.027653 | 12.721973 | 27.144245 | 12.721973 | 0.589369 | 0.895927 | 0.794493 | 1.039624 | 0.794493 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 17.171254 | 13.107034 | 29.547401 | 13.107034 | 0.664941 | 0.915757 | 0.812960 | 1.062908 | 0.812960 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 19.990365 | 17.483138 | 40.070200 | 17.483138 | 0.528858 | 0.856754 | 0.838773 | 1.009003 | 0.838773 |
| coursesOld | BOTH | 4001 | 57.329168 | 23.793302 | 20.263684 | 47.356161 | 20.263684 | 0.614074 | 0.925301 | 0.868648 | 1.074479 | 0.868648 |
| coursesOld | CORRECT | 2148 | 38.013501 | 14.661080 | 10.641527 | 23.313315 | 10.641527 | 0.591233 | 0.892638 | 0.735720 | 0.993153 | 0.735720 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 18.336828 | 14.416776 | 34.082569 | 14.416776 | 0.647316 | 0.919405 | 0.780645 | 1.052622 | 0.780645 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 19.390916 | 16.837345 | 38.523292 | 16.837345 | 0.531564 | 0.814440 | 0.828510 | 1.007793 | 0.828510 |
| cv_v1 | BOTH | 258 | 53.255814 | 24.891473 | 21.794574 | 53.108527 | 21.794574 | 0.661750 | 0.948298 | 0.823361 | 1.022024 | 0.823361 |
| cv_v1 | CORRECT | 106 | 27.886792 | 15.877358 | 10.481132 | 27.858491 | 10.481132 | 0.405510 | 0.719290 | 0.576606 | 0.783469 | 0.576606 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 22.284444 | 16.666667 | 43.208889 | 16.666667 | 0.591220 | 0.844972 | 0.700501 | 0.922980 | 0.700501 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 18.602740 | 15.009132 | 38.196347 | 15.009132 | 0.687474 | 0.900143 | 0.733033 | 0.976804 | 0.733033 |
| cv_v2 | BOTH | 71 | 59.929577 | 34.309859 | 35.436620 | 75.802817 | 35.436620 | 0.599896 | 1.025868 | 0.960363 | 1.018580 | 0.960363 |
| cv_v2 | CORRECT | 57 | 30.473684 | 17.140351 | 16.298246 | 45.421053 | 16.298246 | 0.430811 | 0.762514 | 0.676564 | 0.942225 | 0.676564 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 30.571429 | 31.190476 | 70.923810 | 31.190476 | 0.572770 | 0.992836 | 0.876949 | 1.012896 | 0.876949 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 29.625000 | 32.900000 | 70.650000 | 32.900000 | 0.590867 | 1.066017 | 0.999730 | 1.129248 | 0.999730 |
| graphs | BOTH | 361 | 24.570637 | 12.360111 | 10.235457 | 26.581717 | 10.235457 | 0.648332 | 0.920265 | 0.753380 | 1.007426 | 0.753380 |
| graphs | CORRECT | 820 | 25.169512 | 11.375610 | 8.424390 | 22.773171 | 8.424390 | 0.594930 | 0.798086 | 0.628513 | 0.956903 | 0.628513 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 10.218605 | 8.666667 | 26.010853 | 8.666667 | 0.479910 | 0.713761 | 0.661820 | 0.989029 | 0.661820 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 12.245399 | 9.039877 | 22.595092 | 9.039877 | 0.617945 | 0.877245 | 0.743181 | 1.012696 | 0.743181 |
| lts | BOTH | 555 | 50.536937 | 26.234234 | 21.513514 | 37.115315 | 21.513514 | 0.641920 | 0.923262 | 0.790936 | 0.993429 | 0.790936 |
| lts | CORRECT | 249 | 29.991968 | 14.582329 | 10.200803 | 20.538153 | 10.200803 | 0.550300 | 0.747385 | 0.563691 | 0.792999 | 0.563691 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 23.364629 | 20.545852 | 36.277293 | 20.545852 | 0.615166 | 0.856865 | 0.816644 | 1.027320 | 0.816644 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 19.862205 | 17.157480 | 33.696850 | 17.157480 | 0.556787 | 0.783206 | 0.783860 | 1.026813 | 0.783860 |
| productionLineNew | BOTH | 656 | 45.213415 | 20.420732 | 17.592988 | 39.178354 | 17.592988 | 0.509207 | 0.874209 | 0.781846 | 0.953070 | 0.781846 |
| productionLineNew | CORRECT | 693 | 34.992785 | 15.523810 | 11.028860 | 24.549784 | 11.028860 | 0.445274 | 0.744545 | 0.543847 | 0.741210 | 0.543847 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 17.987500 | 14.884375 | 34.731250 | 14.884375 | 0.459963 | 0.780481 | 0.694962 | 0.880881 | 0.694962 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 22.021544 | 18.594255 | 39.886894 | 18.594255 | 0.528572 | 0.948695 | 0.793313 | 0.963907 | 0.793313 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 15.785047 | 11.130841 | 30.457944 | 11.130841 | 0.531859 | 0.904081 | 0.698121 | 1.000046 | 0.698121 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 11.868966 | 9.151724 | 22.924138 | 9.151724 | 0.434531 | 0.765052 | 0.680297 | 0.874241 | 0.680297 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 14.100000 | 12.820000 | 33.360000 | 12.820000 | 0.451724 | 0.785496 | 0.768150 | 0.985399 | 0.768150 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 9.032680 | 7.124183 | 17.039216 | 7.124183 | 0.578122 | 0.708447 | 0.649054 | 0.799825 | 0.649054 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 19.970115 | 16.748276 | 37.680460 | 16.748276 | 0.499213 | 0.853255 | 0.764284 | 0.946010 | 0.764284 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 16.917260 | 13.243772 | 29.040036 | 13.243772 | 0.477882 | 0.760295 | 0.597448 | 0.834340 | 0.597448 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 19.641066 | 16.598746 | 37.568966 | 16.598746 | 0.495962 | 0.844679 | 0.750232 | 0.935415 | 0.750232 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 20.054274 | 17.132972 | 35.659430 | 17.132972 | 0.540061 | 0.880948 | 0.754384 | 0.932013 | 0.754384 |
| socialMedia | BOTH | 4982 | 50.487756 | 22.307507 | 17.615415 | 42.231433 | 17.615415 | 0.581993 | 0.859294 | 0.790173 | 1.027460 | 0.790173 |
| socialMedia | CORRECT | 4550 | 28.614945 | 14.883736 | 10.089011 | 24.020220 | 10.089011 | 0.419222 | 0.695863 | 0.522532 | 0.679809 | 0.522532 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 22.495304 | 18.661240 | 43.849718 | 18.661240 | 0.543362 | 0.841129 | 0.774858 | 1.009981 | 0.774858 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 18.908743 | 16.196796 | 41.180425 | 16.196796 | 0.533680 | 0.785731 | 0.798107 | 1.053433 | 0.798107 |
| trainStationNew | BOTH | 2325 | 43.576774 | 17.474839 | 17.335054 | 40.624086 | 17.335054 | 0.588892 | 0.819806 | 0.788792 | 0.939806 | 0.788792 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 11.334791 | 7.352904 | 17.933167 | 7.352904 | 0.461784 | 0.658098 | 0.389951 | 0.513420 | 0.389951 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 15.364296 | 11.552975 | 29.164006 | 11.552975 | 0.506348 | 0.767370 | 0.575123 | 0.779878 | 0.575123 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 10.981567 | 16.018433 | 35.905530 | 16.018433 | 0.509954 | 0.682687 | 0.815655 | 0.897476 | 0.815655 |
| trainStationOld | BOTH | 357 | 56.574230 | 29.459384 | 28.039216 | 60.739496 | 28.039216 | 0.629920 | 1.059249 | 0.906764 | 1.026019 | 0.906764 |
| trainStationOld | CORRECT | 111 | 29.864865 | 13.441441 | 8.873874 | 21.729730 | 8.873874 | 0.531537 | 0.877128 | 0.502137 | 0.712600 | 0.502137 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 17.547264 | 15.417910 | 33.955224 | 15.417910 | 0.570660 | 1.019222 | 0.736848 | 0.979612 | 0.736848 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 21.826087 | 17.961353 | 39.217391 | 17.961353 | 0.602022 | 0.976935 | 0.804880 | 0.940768 | 0.804880 |
| trash_fol | BOTH | 377 | 27.262599 | 11.514589 | 8.368700 | 17.769231 | 8.368700 | 0.613723 | 0.916050 | 0.748026 | 0.900326 | 0.748026 |
| trash_fol | CORRECT | 1667 | 26.151170 | 11.079184 | 5.415717 | 12.534493 | 5.415717 | 0.649266 | 0.966178 | 0.447057 | 0.594357 | 0.447057 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 12.834101 | 9.663594 | 21.497696 | 9.663594 | 0.684851 | 0.904688 | 0.748302 | 0.950671 | 0.748302 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 15.557692 | 10.317308 | 22.038462 | 10.317308 | 0.655198 | 0.892703 | 0.741459 | 0.889608 | 0.741459 |
| trash_ltl | BOTH | 1486 | 29.627187 | 10.890983 | 11.024899 | 22.662853 | 11.024899 | 0.538142 | 0.868419 | 0.678147 | 0.858118 | 0.678147 |
| trash_ltl | CORRECT | 863 | 20.166860 | 8.126304 | 6.490151 | 13.454229 | 6.490151 | 0.385829 | 0.736275 | 0.427683 | 0.530217 | 0.427683 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 8.930403 | 7.137363 | 18.573260 | 7.137363 | 0.470347 | 0.801440 | 0.517980 | 0.834929 | 0.517980 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 9.972455 | 10.816766 | 21.061078 | 10.816766 | 0.485105 | 0.862441 | 0.756233 | 0.902411 | 0.756233 |
| trash_rl | BOTH | 591 | 18.964467 | 8.086294 | 6.521151 | 15.247039 | 6.521151 | 0.577751 | 0.876816 | 0.685143 | 0.883134 | 0.685143 |
| trash_rl | CORRECT | 1009 | 18.356789 | 8.499504 | 4.676908 | 12.071358 | 4.676908 | 0.582256 | 0.916752 | 0.500772 | 0.771359 | 0.500772 |
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
- Pearson correlation, Certificate-Integrated IR distance vs candidate reward: -0.064380

- Pearson correlation, canonical representative TED vs candidate reward: -0.060299
- Pearson correlation, Fast Rewrite IR distance vs candidate reward: -0.064380
- Pearson correlation, Levenshtein vs candidate reward: -0.090795
- Pearson correlation, raw AST tree distance vs candidate reward: -0.087821

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.071160
- Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward: -0.082789

- Pearson correlation, normalized canonical representative TED vs candidate reward: -0.093771

- Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward: -0.082789

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 19.305425 | 0.221406 | -0.082857 | 1 | 79 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 10.191569 | 1.000000 | 0.000000 | 0 | 39 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 14.992167 | 0.418354 | 0.129011 | 1 | 60 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 16.752412 | 0.275754 | 0.397682 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 11.811321 | 0.258242 | -0.021179 | 1 | 58 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.876565 | 1.000000 | 0.000000 | 0 | 43 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 9.517367 | 0.422926 | 0.132658 | 1 | 47 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 10.088176 | 0.174385 | 0.355224 | 1 | 31 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 19.339434 | 0.246501 | -0.185658 | 1 | 61 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 12.721973 | 1.000000 | 0.000000 | 0 | 50 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 13.107034 | 0.540050 | -0.058872 | 1 | 61 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 17.483138 | 0.425532 | -0.147491 | 1 | 51 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 20.263684 | 0.203963 | -0.152741 | 1 | 178 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.641527 | 1.000000 | 0.000000 | 0 | 43 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 14.416776 | 0.446171 | -0.140759 | 1 | 69 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 16.837345 | 0.415217 | -0.143698 | 1 | 58 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 21.794574 | 0.228550 | 0.022118 | 4 | 50 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 10.481132 | 1.000000 | 0.000000 | 0 | 41 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 16.666667 | 0.147501 | -0.107825 | 2 | 42 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 15.009132 | 0.194329 | 0.252546 | 3 | 37 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 35.436620 | 0.205966 | -0.041376 | 3 | 101 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 16.298246 | 1.000000 | 0.000000 | 0 | 53 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 31.190476 | 0.299230 | 0.182448 | 1 | 102 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 32.900000 | 0.437210 | 0.546222 | 3 | 99 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.235457 | 0.304664 | 0.091915 | 1 | 36 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.424390 | 0.999999 | 0.000000 | 0 | 60 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.666667 | 0.443294 | -0.062241 | 1 | 30 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.039877 | 0.487304 | 0.206515 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 21.513514 | 0.189667 | 0.349983 | 1 | 64 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 10.200803 | 1.000000 | 0.000000 | 0 | 35 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 20.545852 | 0.321068 | 0.261116 | 1 | 64 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 17.157480 | 0.172204 | 0.276914 | 1 | 64 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 17.592988 | 0.294607 | -0.146576 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 11.028860 | 1.000000 | 0.000000 | 0 | 80 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.884375 | 0.329941 | -0.199311 | 1 | 55 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 18.594255 | 0.552549 | -0.201467 | 1 | 79 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.130841 | 0.144778 | 0.539633 | 1 | 26 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 9.151724 | 1.000000 | 0.000000 | 0 | 31 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.820000 | 0.047098 | 0.158300 | 1 | 29 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.124183 | 0.440088 | -0.208624 | 2 | 23 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 16.748276 | 0.307091 | -0.040216 | 1 | 83 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 13.243772 | 1.000000 | 0.000000 | 0 | 105 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 16.598746 | 0.352790 | -0.329292 | 1 | 68 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 17.132972 | 0.693635 | -0.018125 | 1 | 75 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 17.615415 | 0.187684 | 0.001756 | 1 | 115 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.089011 | 0.999560 | 0.000000 | 0 | 124 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 18.661240 | 0.108430 | 0.019423 | 1 | 117 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 16.196796 | 0.645759 | 0.214036 | 1 | 86 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.335054 | 0.372981 | 0.040507 | 1 | 97 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 7.352904 | 1.000000 | 0.000000 | 0 | 102 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 11.552975 | 0.796660 | -0.080735 | 1 | 53 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 16.018433 | 0.648703 | -0.083613 | 1 | 50 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 28.039216 | 0.276158 | 0.135468 | 2 | 93 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 8.873874 | 0.999996 | 0.000000 | 0 | 33 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 15.417910 | 0.550904 | -0.056154 | 1 | 61 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 17.961353 | 0.330656 | -0.139547 | 1 | 61 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.368700 | 0.302927 | 0.263257 | 1 | 55 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 5.415717 | 1.000000 | 0.000000 | 0 | 19 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.663594 | 0.337689 | 0.244639 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 10.317308 | 0.487209 | 0.042524 | 1 | 20 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 11.024899 | 0.366455 | 0.173749 | 1 | 31 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 6.490151 | 1.000000 | 0.000000 | 0 | 18 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 7.137363 | 0.633484 | -0.133357 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 10.816766 | 0.578260 | 0.093320 | 1 | 30 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.521151 | 0.342525 | 0.219862 | 1 | 34 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 4.676908 | 1.000000 | 0.000000 | 0 | 28 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.320359 | 0.366014 | -0.111958 | 1 | 24 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.606061 | 0.370073 | -0.208886 | 1 | 23 |
