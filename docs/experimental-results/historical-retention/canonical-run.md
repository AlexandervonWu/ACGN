# Canonical Rewrite Distance Summary

DIAGNOSTIC ONLY: bounded native operation replay; unchecked pairs are not matches. Public certification and publication remain BLOCKED.

- Input root: `[CHECKOUT]/classified-data`
- Thread count: 16
- Memory-intensive worker limit: 16
- Maximum JVM heap bytes: 8589934592
- Certificate-Integrated IR engine: `CanonicalAlloyPipeline` (`canonical-alloy-pipeline-v42-guarded-image-membership`)
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
- Average Certificate-Integrated IR repair distance: 13.470778
- Average canonical representative TED baseline: 31.382529
- Average Fast Rewrite IR distance: 13.470778
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 17.086902
- Average raw AST size: 19.668561
- Average Certificate-Integrated IR repair observation size: 17.513897
- Average canonical representative tree size: 32.737215
- Average Fast Rewrite IR NormalForm size: 17.513897
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.833664
- Average normalized Certificate-Integrated IR distance: 0.697697
- Average normalized canonical representative TED: 0.896645
- Average normalized Fast Rewrite IR distance: 0.697697
- CORRECT models with canonical distance 0 and raw AST distance > 0: 5137
- Incorrect zero-distance merges: 0
- Inexact alpha searches: 0
- Average certified repair metric time: 154.336834 ms
- Average canonical representative TED time: 0.618097 ms
- Min distance: 0
- Max distance: 166

## Repair Observation Compression

Compression rate is `100 * (raw AST size - repair observation size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg repair observation size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 25.447524 | 22.069575 | 13.274172% |
| classroom_fol | CORRECT | 1613 | 17.719777 | 14.663360 | 17.248618% |
| classroom_fol | OVERCONSTRAINED | 383 | 19.600522 | 17.114883 | 12.681497% |
| classroom_fol | UNDERCONSTRAINED | 311 | 26.649518 | 21.231511 | 20.330598% |
| classroom_rl | BOTH | 1219 | 14.843314 | 13.887613 | 6.438598% |
| classroom_rl | CORRECT | 1118 | 11.771020 | 10.835420 | 7.948328% |
| classroom_rl | OVERCONSTRAINED | 547 | 11.683729 | 11.619744 | 0.547645% |
| classroom_rl | UNDERCONSTRAINED | 499 | 15.248497 | 13.609218 | 10.750427% |
| coursesNew | BOTH | 1803 | 23.073766 | 20.277870 | 12.117206% |
| coursesNew | CORRECT | 1338 | 18.127055 | 13.934230 | 23.130205% |
| coursesNew | OVERCONSTRAINED | 327 | 18.122324 | 14.605505 | 19.406007% |
| coursesNew | UNDERCONSTRAINED | 1453 | 21.972471 | 19.251893 | 12.381758% |
| coursesOld | BOTH | 4001 | 23.503624 | 21.546363 | 8.327485% |
| coursesOld | CORRECT | 2148 | 16.009777 | 12.150838 | 24.103638% |
| coursesOld | OVERCONSTRAINED | 763 | 17.989515 | 16.019659 | 10.950022% |
| coursesOld | UNDERCONSTRAINED | 2576 | 21.341615 | 18.414984 | 13.713257% |
| cv_v1 | BOTH | 258 | 20.422481 | 18.325581 | 10.267603% |
| cv_v1 | CORRECT | 106 | 18.990566 | 15.981132 | 15.846995% |
| cv_v1 | OVERCONSTRAINED | 225 | 21.773333 | 17.573333 | 19.289651% |
| cv_v1 | UNDERCONSTRAINED | 219 | 15.365297 | 14.515982 | 5.527489% |
| cv_v2 | BOTH | 71 | 27.169014 | 27.718310 | -2.021773% |
| cv_v2 | CORRECT | 57 | 20.421053 | 19.771930 | 3.178694% |
| cv_v2 | OVERCONSTRAINED | 105 | 25.980952 | 26.676190 | -2.675953% |
| cv_v2 | UNDERCONSTRAINED | 40 | 22.900000 | 24.950000 | -8.951965% |
| graphs | BOTH | 361 | 12.340720 | 12.324100 | 0.134680% |
| graphs | CORRECT | 820 | 13.404878 | 11.991463 | 10.544032% |
| graphs | OVERCONSTRAINED | 645 | 13.258915 | 11.817054 | 10.874649% |
| graphs | UNDERCONSTRAINED | 326 | 12.941718 | 11.104294 | 14.197677% |
| lts | BOTH | 555 | 15.396396 | 14.403604 | 6.448215% |
| lts | CORRECT | 249 | 14.987952 | 12.610442 | 15.862808% |
| lts | OVERCONSTRAINED | 458 | 13.665939 | 11.862445 | 13.196996% |
| lts | UNDERCONSTRAINED | 254 | 15.562992 | 13.669291 | 12.167974% |
| productionLineNew | BOTH | 656 | 20.971037 | 17.922256 | 14.538053% |
| productionLineNew | CORRECT | 693 | 19.378066 | 16.997114 | 12.286842% |
| productionLineNew | OVERCONSTRAINED | 320 | 20.768750 | 18.253125 | 12.112549% |
| productionLineNew | UNDERCONSTRAINED | 557 | 20.484740 | 16.411131 | 19.886065% |
| productionLine_v1 | BOTH | 107 | 14.280374 | 12.401869 | 13.154450% |
| productionLine_v1 | CORRECT | 145 | 14.151724 | 12.510345 | 11.598441% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 15.450000 | 13.240000 | 14.304207% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 7.960784 | 7.313725 | 8.128079% |
| productionLine_v2 | BOTH | 870 | 20.481609 | 17.695402 | 13.603457% |
| productionLine_v2 | CORRECT | 1124 | 19.501779 | 17.611210 | 9.694343% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 21.119122 | 19.194357 | 9.113849% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 19.852103 | 17.312076 | 12.794751% |
| socialMedia | BOTH | 4982 | 24.202328 | 19.280008 | 20.338210% |
| socialMedia | CORRECT | 4550 | 18.673626 | 14.905714 | 20.177720% |
| socialMedia | OVERCONSTRAINED | 1597 | 24.428929 | 20.757044 | 15.030887% |
| socialMedia | UNDERCONSTRAINED | 2871 | 22.559387 | 18.062696 | 19.932683% |
| trainStationNew | BOTH | 2325 | 19.703656 | 18.455484 | 6.334723% |
| trainStationNew | CORRECT | 1601 | 15.620237 | 15.735790 | -0.739763% |
| trainStationNew | OVERCONSTRAINED | 689 | 17.805515 | 16.634253 | 6.578089% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 13.921659 | 12.458525 | 10.509765% |
| trainStationOld | BOTH | 357 | 20.532213 | 21.812325 | -6.234652% |
| trainStationOld | CORRECT | 111 | 14.342342 | 15.513514 | -8.165829% |
| trainStationOld | OVERCONSTRAINED | 201 | 14.069652 | 16.099502 | -14.427157% |
| trainStationOld | UNDERCONSTRAINED | 207 | 19.420290 | 17.502415 | 9.875622% |
| trash_fol | BOTH | 377 | 12.641910 | 10.419098 | 17.582879% |
| trash_fol | CORRECT | 1667 | 11.346131 | 8.602879 | 24.177858% |
| trash_fol | OVERCONSTRAINED | 217 | 13.382488 | 11.691244 | 12.637741% |
| trash_fol | UNDERCONSTRAINED | 104 | 17.336538 | 12.971154 | 25.180255% |
| trash_ltl | BOTH | 1486 | 11.643338 | 14.565949 | -25.101144% |
| trash_ltl | CORRECT | 863 | 10.899189 | 12.676709 | -16.308739% |
| trash_ltl | OVERCONSTRAINED | 546 | 10.882784 | 13.228938 | -21.558398% |
| trash_ltl | UNDERCONSTRAINED | 835 | 10.937725 | 12.825150 | -17.256104% |
| trash_rl | BOTH | 591 | 8.737733 | 8.771574 | -0.387297% |
| trash_rl | CORRECT | 1009 | 8.536174 | 7.677899 | 10.054569% |
| trash_rl | OVERCONSTRAINED | 334 | 8.149701 | 8.359281 | -2.571639% |
| trash_rl | UNDERCONSTRAINED | 132 | 13.515152 | 11.439394 | 15.358744% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg Fast Rewrite IR | Avg representative TED | Avg Certificate-Integrated IR | Avg relative Levenshtein | Avg relative raw AST | Avg relative Fast Rewrite IR | Avg relative representative TED | Avg relative Certificate-Integrated IR |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **17.086902** | **13.470778** | **31.382529** | **13.470778** | **0.547644** | **0.833664** | **0.697697** | **0.896645** | **0.697697** |
| classroom_fol | BOTH | 1696 | 54.403302 | 23.034788 | 19.157429 | 38.570165 | 19.157429 | 0.624351 | 0.887834 | 0.828035 | 0.981377 | 0.828035 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 14.737756 | 9.664600 | 21.957223 | 9.664600 | 0.537345 | 0.839291 | 0.526835 | 0.718560 | 0.526835 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 17.605744 | 14.906005 | 31.112272 | 14.906005 | 0.596239 | 0.848067 | 0.793544 | 0.984476 | 0.793544 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 22.768489 | 16.739550 | 37.032154 | 16.739550 | 0.606512 | 0.839564 | 0.753816 | 0.949432 | 0.753816 |
| classroom_rl | BOTH | 1219 | 35.016407 | 13.497129 | 11.716161 | 26.646432 | 11.716161 | 0.574684 | 0.803115 | 0.741976 | 0.944458 | 0.741976 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 8.852415 | 5.683363 | 14.774597 | 5.683363 | 0.439188 | 0.699531 | 0.411601 | 0.642968 | 0.411601 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 9.968921 | 9.491773 | 22.755027 | 9.491773 | 0.487860 | 0.731131 | 0.686863 | 0.897391 | 0.686863 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 12.152305 | 10.048096 | 24.320641 | 10.048096 | 0.495818 | 0.714155 | 0.656815 | 0.846179 | 0.656815 |
| coursesNew | BOTH | 1803 | 53.808098 | 23.124792 | 18.708819 | 43.376595 | 18.708819 | 0.614704 | 0.941881 | 0.881970 | 1.074693 | 0.881970 |
| coursesNew | CORRECT | 1338 | 38.111360 | 16.027653 | 11.369208 | 24.833333 | 11.369208 | 0.589369 | 0.895927 | 0.764403 | 0.999632 | 0.764403 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 17.171254 | 12.914373 | 29.204893 | 12.914373 | 0.664941 | 0.915757 | 0.808619 | 1.058001 | 0.808619 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 19.990365 | 16.726084 | 38.585685 | 16.726084 | 0.528858 | 0.856754 | 0.830130 | 0.994087 | 0.830130 |
| coursesOld | BOTH | 4001 | 57.329168 | 23.793302 | 19.866783 | 46.742314 | 19.866783 | 0.614074 | 0.925301 | 0.873907 | 1.077923 | 0.873907 |
| coursesOld | CORRECT | 2148 | 38.013501 | 14.661080 | 9.127095 | 21.081006 | 9.127095 | 0.591233 | 0.892638 | 0.700509 | 0.952067 | 0.700509 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 18.336828 | 14.083879 | 33.511140 | 14.083879 | 0.647316 | 0.919405 | 0.774832 | 1.047002 | 0.774832 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 19.390916 | 16.232531 | 37.478649 | 16.232531 | 0.531564 | 0.814440 | 0.824124 | 0.997114 | 0.824124 |
| cv_v1 | BOTH | 258 | 53.255814 | 24.891473 | 21.802326 | 53.275194 | 21.802326 | 0.661750 | 0.948298 | 0.824578 | 1.024672 | 0.824578 |
| cv_v1 | CORRECT | 106 | 27.886792 | 15.877358 | 9.009434 | 23.839623 | 9.009434 | 0.405510 | 0.719290 | 0.478493 | 0.638772 | 0.478493 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 22.284444 | 16.511111 | 42.853333 | 16.511111 | 0.591220 | 0.844972 | 0.695578 | 0.911698 | 0.695578 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 18.602740 | 14.844749 | 38.296804 | 14.844749 | 0.687474 | 0.900143 | 0.723213 | 0.978836 | 0.723213 |
| cv_v2 | BOTH | 71 | 59.929577 | 34.309859 | 35.676056 | 76.450704 | 35.676056 | 0.599896 | 1.025868 | 0.967938 | 1.028449 | 0.967938 |
| cv_v2 | CORRECT | 57 | 30.473684 | 17.140351 | 15.578947 | 43.526316 | 15.578947 | 0.430811 | 0.762514 | 0.636333 | 0.881911 | 0.636333 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 30.571429 | 31.142857 | 70.771429 | 31.142857 | 0.572770 | 0.992836 | 0.875413 | 1.010515 | 0.875413 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 29.625000 | 32.550000 | 70.250000 | 32.550000 | 0.590867 | 1.066017 | 0.979015 | 1.136109 | 0.979015 |
| graphs | BOTH | 361 | 24.570637 | 12.360111 | 10.227147 | 26.573407 | 10.227147 | 0.648332 | 0.920265 | 0.753353 | 1.007429 | 0.753353 |
| graphs | CORRECT | 820 | 25.169512 | 11.375610 | 8.275610 | 22.645122 | 8.275610 | 0.594930 | 0.798086 | 0.623911 | 0.955538 | 0.623911 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 10.218605 | 8.582946 | 25.911628 | 8.582946 | 0.479910 | 0.713761 | 0.655735 | 0.985167 | 0.655735 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 12.245399 | 9.018405 | 22.595092 | 9.018405 | 0.617945 | 0.877245 | 0.742943 | 1.012696 | 0.742943 |
| lts | BOTH | 555 | 50.536937 | 26.234234 | 21.520721 | 37.055856 | 21.520721 | 0.641920 | 0.923262 | 0.791006 | 0.993192 | 0.791006 |
| lts | CORRECT | 249 | 29.991968 | 14.582329 | 10.200803 | 20.550201 | 10.200803 | 0.550300 | 0.747385 | 0.563691 | 0.792840 | 0.563691 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 23.364629 | 20.550218 | 36.279476 | 20.550218 | 0.615166 | 0.856865 | 0.816980 | 1.027333 | 0.816980 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 19.862205 | 17.110236 | 33.625984 | 17.110236 | 0.556787 | 0.783206 | 0.782270 | 1.024252 | 0.782270 |
| productionLineNew | BOTH | 656 | 45.213415 | 20.420732 | 16.989329 | 38.442073 | 16.989329 | 0.509207 | 0.874209 | 0.772815 | 0.944657 | 0.772815 |
| productionLineNew | CORRECT | 693 | 34.992785 | 15.523810 | 9.828283 | 21.799423 | 9.828283 | 0.445274 | 0.744545 | 0.477979 | 0.666580 | 0.477979 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 17.987500 | 13.625000 | 32.240625 | 13.625000 | 0.459963 | 0.780481 | 0.642568 | 0.812508 | 0.642568 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 22.021544 | 17.974865 | 39.420108 | 17.974865 | 0.528572 | 0.948695 | 0.775569 | 0.958119 | 0.775569 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 15.785047 | 11.158879 | 30.467290 | 11.158879 | 0.531859 | 0.904081 | 0.702848 | 1.002612 | 0.702848 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 11.868966 | 9.179310 | 22.931034 | 9.179310 | 0.434531 | 0.765052 | 0.681748 | 0.874414 | 0.681748 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 14.100000 | 12.840000 | 33.280000 | 12.840000 | 0.451724 | 0.785496 | 0.773281 | 0.986076 | 0.773281 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 9.032680 | 7.307190 | 17.346405 | 7.307190 | 0.578122 | 0.708447 | 0.662879 | 0.806444 | 0.662879 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 19.970115 | 16.241379 | 36.888506 | 16.241379 | 0.499213 | 0.853255 | 0.754956 | 0.938528 | 0.754956 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 16.917260 | 12.199288 | 26.843416 | 12.199288 | 0.477882 | 0.760295 | 0.544437 | 0.779859 | 0.544437 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 19.641066 | 15.813480 | 35.981191 | 15.813480 | 0.495962 | 0.844679 | 0.715090 | 0.890121 | 0.715090 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 20.054274 | 16.895522 | 35.559023 | 16.895522 | 0.540061 | 0.880948 | 0.748896 | 0.932223 | 0.748896 |
| socialMedia | BOTH | 4982 | 50.487756 | 22.307507 | 16.649538 | 41.479326 | 16.649538 | 0.581993 | 0.859294 | 0.784290 | 1.032115 | 0.784290 |
| socialMedia | CORRECT | 4550 | 28.614945 | 14.883736 | 9.691209 | 23.524396 | 9.691209 | 0.419222 | 0.695863 | 0.519412 | 0.672438 | 0.519412 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 22.495304 | 17.864746 | 43.088291 | 17.864746 | 0.543362 | 0.841129 | 0.764181 | 1.004595 | 0.764181 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 18.908743 | 15.689655 | 40.641937 | 15.689655 | 0.533680 | 0.785731 | 0.790578 | 1.054031 | 0.790578 |
| trainStationNew | BOTH | 2325 | 43.576774 | 17.474839 | 16.497634 | 39.649032 | 16.497634 | 0.588892 | 0.819806 | 0.764634 | 0.925226 | 0.764634 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 11.334791 | 7.161149 | 16.988757 | 7.161149 | 0.461784 | 0.658098 | 0.373723 | 0.474845 | 0.373723 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 15.364296 | 10.827286 | 27.461538 | 10.827286 | 0.506348 | 0.767370 | 0.551844 | 0.743965 | 0.551844 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 10.981567 | 15.873272 | 35.767281 | 15.873272 | 0.509954 | 0.682687 | 0.809924 | 0.895341 | 0.809924 |
| trainStationOld | BOTH | 357 | 56.574230 | 29.459384 | 27.621849 | 60.621849 | 27.621849 | 0.629920 | 1.059249 | 0.898985 | 1.024897 | 0.898985 |
| trainStationOld | CORRECT | 111 | 29.864865 | 13.441441 | 7.756757 | 18.837838 | 7.756757 | 0.531537 | 0.877128 | 0.446581 | 0.626553 | 0.446581 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 17.547264 | 14.835821 | 33.353234 | 14.835821 | 0.570660 | 1.019222 | 0.719299 | 0.964548 | 0.719299 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 21.826087 | 17.328502 | 38.657005 | 17.328502 | 0.602022 | 0.976935 | 0.786545 | 0.926755 | 0.786545 |
| trash_fol | BOTH | 377 | 27.262599 | 11.514589 | 8.180371 | 17.543767 | 8.180371 | 0.613723 | 0.916050 | 0.743864 | 0.910624 | 0.743864 |
| trash_fol | CORRECT | 1667 | 26.151170 | 11.079184 | 5.074985 | 11.684463 | 5.074985 | 0.649266 | 0.966178 | 0.417808 | 0.552714 | 0.417808 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 12.834101 | 9.622120 | 21.502304 | 9.622120 | 0.684851 | 0.904688 | 0.746370 | 0.950541 | 0.746370 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 15.557692 | 10.057692 | 21.644231 | 10.057692 | 0.655198 | 0.892703 | 0.731931 | 0.883330 | 0.731931 |
| trash_ltl | BOTH | 1486 | 29.627187 | 10.890983 | 10.971736 | 22.508748 | 10.971736 | 0.538142 | 0.868419 | 0.678992 | 0.857010 | 0.678992 |
| trash_ltl | CORRECT | 863 | 20.166860 | 8.126304 | 4.095017 | 8.348783 | 4.095017 | 0.385829 | 0.736275 | 0.264727 | 0.332159 | 0.264727 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 8.930403 | 6.941392 | 18.183150 | 6.941392 | 0.470347 | 0.801440 | 0.506524 | 0.820240 | 0.506524 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 9.972455 | 10.459880 | 20.394012 | 10.459880 | 0.485105 | 0.862441 | 0.743248 | 0.899955 | 0.743248 |
| trash_rl | BOTH | 591 | 18.964467 | 8.086294 | 6.461929 | 15.203046 | 6.461929 | 0.577751 | 0.876816 | 0.681638 | 0.884807 | 0.681638 |
| trash_rl | CORRECT | 1009 | 18.356789 | 8.499504 | 4.441031 | 11.491576 | 4.441031 | 0.582256 | 0.916752 | 0.479471 | 0.741796 | 0.479471 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 8.149701 | 6.311377 | 15.248503 | 6.311377 | 0.612100 | 0.872160 | 0.658222 | 0.914488 | 0.658222 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 12.848485 | 8.590909 | 21.818182 | 8.590909 | 0.617090 | 0.893899 | 0.687073 | 0.922564 | 0.687073 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 100
- Rewards enabled: true
- Average candidate reward: 0.554601
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.445399
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, Certificate-Integrated IR distance vs candidate reward: -0.064020

- Pearson correlation, canonical representative TED vs candidate reward: -0.063007
- Pearson correlation, Fast Rewrite IR distance vs candidate reward: -0.064020
- Pearson correlation, Levenshtein vs candidate reward: -0.090795
- Pearson correlation, raw AST tree distance vs candidate reward: -0.087821

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.071160
- Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward: -0.086930

- Pearson correlation, normalized canonical representative TED vs candidate reward: -0.100931

- Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward: -0.086930

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 19.157429 | 0.221406 | -0.101795 | 1 | 54 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 9.664600 | 1.000000 | 0.000000 | 0 | 39 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 14.906005 | 0.418354 | 0.137703 | 1 | 57 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 16.739550 | 0.275754 | 0.397544 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 11.716161 | 0.258242 | -0.024725 | 1 | 57 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.683363 | 1.000000 | 0.000000 | 0 | 43 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 9.491773 | 0.422926 | 0.125793 | 1 | 47 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 10.048096 | 0.174385 | 0.341279 | 1 | 31 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 18.708819 | 0.246501 | -0.209202 | 1 | 61 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 11.369208 | 1.000000 | 0.000000 | 0 | 39 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 12.914373 | 0.540050 | -0.041597 | 1 | 59 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 16.726084 | 0.425532 | -0.117972 | 1 | 51 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 19.866783 | 0.203963 | -0.155435 | 1 | 166 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 9.127095 | 1.000000 | 0.000000 | 0 | 43 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 14.083879 | 0.446171 | -0.137688 | 1 | 69 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 16.232531 | 0.415217 | -0.128169 | 1 | 58 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 21.802326 | 0.228550 | 0.021142 | 4 | 50 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 9.009434 | 1.000000 | 0.000000 | 0 | 41 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 16.511111 | 0.147501 | -0.097678 | 2 | 42 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 14.844749 | 0.194329 | 0.258135 | 3 | 37 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 35.676056 | 0.205966 | -0.050645 | 3 | 101 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 15.578947 | 1.000000 | 0.000000 | 0 | 53 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 31.142857 | 0.299230 | 0.184484 | 1 | 102 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 32.550000 | 0.437210 | 0.550188 | 3 | 99 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.227147 | 0.304664 | 0.091245 | 1 | 36 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.275610 | 0.999999 | 0.000000 | 0 | 51 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.582946 | 0.443294 | -0.068533 | 1 | 30 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.018405 | 0.487304 | 0.203882 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 21.520721 | 0.189667 | 0.348384 | 1 | 64 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 10.200803 | 1.000000 | 0.000000 | 0 | 35 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 20.550218 | 0.321068 | 0.260939 | 1 | 64 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 17.110236 | 0.172204 | 0.279034 | 1 | 64 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 16.989329 | 0.294607 | -0.164679 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 9.828283 | 1.000000 | 0.000000 | 0 | 80 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 13.625000 | 0.329941 | -0.292229 | 1 | 55 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 17.974865 | 0.552549 | -0.194831 | 1 | 79 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.158879 | 0.144778 | 0.519701 | 1 | 24 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 9.179310 | 1.000000 | 0.000000 | 0 | 33 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.840000 | 0.047098 | 0.157725 | 1 | 29 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.307190 | 0.440088 | -0.190899 | 2 | 23 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 16.241379 | 0.307091 | -0.116937 | 1 | 84 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 12.199288 | 1.000000 | 0.000000 | 0 | 76 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 15.813480 | 0.352790 | -0.391390 | 1 | 68 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 16.895522 | 0.693635 | -0.010405 | 1 | 75 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 16.649538 | 0.187684 | 0.026016 | 1 | 92 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 9.691209 | 0.999560 | 0.000000 | 0 | 119 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 17.864746 | 0.108430 | 0.000315 | 1 | 95 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 15.689655 | 0.645759 | 0.203429 | 1 | 86 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 16.497634 | 0.372981 | 0.060891 | 1 | 95 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 7.161149 | 1.000000 | 0.000000 | 0 | 97 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 10.827286 | 0.796660 | -0.090979 | 1 | 55 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 15.873272 | 0.648703 | -0.063164 | 1 | 47 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 27.621849 | 0.276158 | 0.115154 | 2 | 95 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 7.756757 | 0.999996 | 0.000000 | 0 | 31 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 14.835821 | 0.550904 | -0.029497 | 1 | 58 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 17.328502 | 0.330656 | -0.126355 | 1 | 59 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.180371 | 0.302927 | 0.279587 | 1 | 55 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 5.074985 | 1.000000 | 0.000000 | 0 | 19 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.622120 | 0.337689 | 0.255706 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 10.057692 | 0.487209 | -0.012819 | 1 | 20 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 10.971736 | 0.366455 | 0.169101 | 1 | 31 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 4.095017 | 1.000000 | 0.000000 | 0 | 18 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 6.941392 | 0.633484 | -0.140127 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 10.459880 | 0.578260 | 0.115485 | 1 | 29 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.461929 | 0.342525 | 0.232976 | 1 | 34 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 4.441031 | 1.000000 | 0.000000 | 0 | 28 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.311377 | 0.366014 | -0.109155 | 1 | 24 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.590909 | 0.370073 | -0.212454 | 1 | 23 |
