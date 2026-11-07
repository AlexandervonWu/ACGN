# Canonical Rewrite Distance Summary

- Input root: `/home/augustus/ACGN/classified-data`
- Thread count: 16
- Memory-intensive worker limit: 16
- Maximum JVM heap bytes: 8589934592
- Certificate-Integrated IR engine: `CanonicalAlloyPipeline` (`canonical-alloy-pipeline-v38-phase-local-bindings`)
- Fast Rewrite IR engine: `Canonical` / `CanonicalDistance`
- Exact graph: `TypedSlottedPortEGraph`; invariants: `strict-every-transition`; certificates: required
- Primary metric: established repair metric over the certified quotient; compatibility manifest ID `certified-fast-rewrite-repair-distance-v12`
- Canonical representative TED retained only as baseline: `canonical-representative-ted-v1`
- Co-maintained Fast Rewrite IR metric retained as a differential oracle: yes
- Total files: 66080
- Successful distances: 61598
- Skipped identical raw AST predicate pairs: 4482
- Failures: 0
- Average Certificate-Integrated IR repair distance: 14.021721
- Average canonical representative TED baseline: 32.255544
- Average Fast Rewrite IR distance: 13.970096
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 17.086902
- Average raw AST size: 19.668561
- Average Certificate-Integrated IR repair observation size: 17.990130
- Average canonical representative tree size: 33.198773
- Average Fast Rewrite IR NormalForm size: 18.235235
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.833664
- Average normalized Certificate-Integrated IR distance: 0.711513
- Average normalized canonical representative TED: 0.916525
- Average normalized Fast Rewrite IR distance: 0.696100
- CORRECT models with canonical distance 0 and raw AST distance > 0: 4088
- Incorrect zero-distance merges: 0
- Inexact alpha searches: 0
- Average certified repair metric time: 0.115972 ms
- Average canonical representative TED time: 0.367840 ms
- Min distance: 0
- Max distance: 180

## Repair Observation Compression

Compression rate is `100 * (raw AST size - repair observation size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg repair observation size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 25.447524 | 22.311321 | 12.324197% |
| classroom_fol | CORRECT | 1613 | 17.719777 | 14.990081 | 15.404800% |
| classroom_fol | OVERCONSTRAINED | 383 | 19.600522 | 17.295039 | 11.762355% |
| classroom_fol | UNDERCONSTRAINED | 311 | 26.649518 | 21.350482 | 19.884170% |
| classroom_rl | BOTH | 1219 | 14.843314 | 13.992617 | 5.731182% |
| classroom_rl | CORRECT | 1118 | 11.771020 | 10.970483 | 6.800912% |
| classroom_rl | OVERCONSTRAINED | 547 | 11.683729 | 11.683729 | 0.000000% |
| classroom_rl | UNDERCONSTRAINED | 499 | 15.248497 | 13.707415 | 10.106453% |
| coursesNew | BOTH | 1803 | 23.073766 | 21.235164 | 7.968367% |
| coursesNew | CORRECT | 1338 | 18.127055 | 15.028401 | 17.094088% |
| coursesNew | OVERCONSTRAINED | 327 | 18.122324 | 14.822630 | 18.207897% |
| coursesNew | UNDERCONSTRAINED | 1453 | 21.972471 | 20.019959 | 8.886174% |
| coursesOld | BOTH | 4001 | 23.503624 | 22.232942 | 5.406325% |
| coursesOld | CORRECT | 2148 | 16.009777 | 13.332402 | 16.723371% |
| coursesOld | OVERCONSTRAINED | 763 | 17.989515 | 16.339450 | 9.172374% |
| coursesOld | UNDERCONSTRAINED | 2576 | 21.341615 | 19.017081 | 10.892026% |
| cv_v1 | BOTH | 258 | 20.422481 | 18.027132 | 11.728981% |
| cv_v1 | CORRECT | 106 | 18.990566 | 16.301887 | 14.157973% |
| cv_v1 | OVERCONSTRAINED | 225 | 21.773333 | 17.551111 | 19.391713% |
| cv_v1 | UNDERCONSTRAINED | 219 | 15.365297 | 14.237443 | 7.340267% |
| cv_v2 | BOTH | 71 | 27.169014 | 27.859155 | -2.540176% |
| cv_v2 | CORRECT | 57 | 20.421053 | 20.070175 | 1.718213% |
| cv_v2 | OVERCONSTRAINED | 105 | 25.980952 | 27.038095 | -4.068915% |
| cv_v2 | UNDERCONSTRAINED | 40 | 22.900000 | 24.950000 | -8.951965% |
| graphs | BOTH | 361 | 12.340720 | 12.337950 | 0.022447% |
| graphs | CORRECT | 820 | 13.404878 | 12.115854 | 9.616084% |
| graphs | OVERCONSTRAINED | 645 | 13.258915 | 11.869767 | 10.477081% |
| graphs | UNDERCONSTRAINED | 326 | 12.941718 | 11.177914 | 13.628822% |
| lts | BOTH | 555 | 15.396396 | 14.436036 | 6.237566% |
| lts | CORRECT | 249 | 14.987952 | 12.602410 | 15.916399% |
| lts | OVERCONSTRAINED | 458 | 13.665939 | 11.834061 | 13.404697% |
| lts | UNDERCONSTRAINED | 254 | 15.562992 | 13.570866 | 12.800405% |
| productionLineNew | BOTH | 656 | 20.971037 | 18.417683 | 12.175620% |
| productionLineNew | CORRECT | 693 | 19.378066 | 17.246753 | 10.998585% |
| productionLineNew | OVERCONSTRAINED | 320 | 20.768750 | 19.025000 | 8.396028% |
| productionLineNew | UNDERCONSTRAINED | 557 | 20.484740 | 16.935368 | 17.326906% |
| productionLine_v1 | BOTH | 107 | 14.280374 | 12.514019 | 12.369110% |
| productionLine_v1 | CORRECT | 145 | 14.151724 | 12.524138 | 11.500975% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 15.450000 | 13.430000 | 13.074434% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 7.960784 | 7.366013 | 7.471264% |
| productionLine_v2 | BOTH | 870 | 20.481609 | 18.168966 | 11.291318% |
| productionLine_v2 | CORRECT | 1124 | 19.501779 | 17.920819 | 8.106752% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 21.119122 | 19.713166 | 6.657266% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 19.852103 | 17.552239 | 11.584991% |
| socialMedia | BOTH | 4982 | 24.202328 | 20.309514 | 16.084461% |
| socialMedia | CORRECT | 4550 | 18.673626 | 15.376923 | 17.654328% |
| socialMedia | OVERCONSTRAINED | 1597 | 24.428929 | 21.380088 | 12.480455% |
| socialMedia | UNDERCONSTRAINED | 2871 | 22.559387 | 18.579937 | 17.639884% |
| trainStationNew | BOTH | 2325 | 19.703656 | 19.093333 | 3.097509% |
| trainStationNew | CORRECT | 1601 | 15.620237 | 16.439101 | -5.242322% |
| trainStationNew | OVERCONSTRAINED | 689 | 17.805515 | 17.310595 | 2.779589% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 13.921659 | 12.703533 | 8.749862% |
| trainStationOld | BOTH | 357 | 20.532213 | 21.829132 | -6.316508% |
| trainStationOld | CORRECT | 111 | 14.342342 | 15.585586 | -8.668342% |
| trainStationOld | OVERCONSTRAINED | 201 | 14.069652 | 16.149254 | -14.780764% |
| trainStationOld | UNDERCONSTRAINED | 207 | 19.420290 | 17.632850 | 9.203980% |
| trash_fol | BOTH | 377 | 12.641910 | 10.859416 | 14.099874% |
| trash_fol | CORRECT | 1667 | 11.346131 | 8.865627 | 21.862113% |
| trash_fol | OVERCONSTRAINED | 217 | 13.382488 | 11.723502 | 12.396694% |
| trash_fol | UNDERCONSTRAINED | 104 | 17.336538 | 13.336538 | 23.072657% |
| trash_ltl | BOTH | 1486 | 11.643338 | 14.812921 | -27.222286% |
| trash_ltl | CORRECT | 863 | 10.899189 | 13.920046 | -27.716351% |
| trash_ltl | OVERCONSTRAINED | 546 | 10.882784 | 13.397436 | -23.106698% |
| trash_ltl | UNDERCONSTRAINED | 835 | 10.937725 | 13.362874 | -22.172342% |
| trash_rl | BOTH | 591 | 8.737733 | 8.837563 | -1.142525% |
| trash_rl | CORRECT | 1009 | 8.536174 | 7.830525 | 8.266574% |
| trash_rl | OVERCONSTRAINED | 334 | 8.149701 | 8.383234 | -2.865540% |
| trash_rl | UNDERCONSTRAINED | 132 | 13.515152 | 11.545455 | 14.573991% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg Fast Rewrite IR | Avg representative TED | Avg Certificate-Integrated IR | Avg relative Levenshtein | Avg relative raw AST | Avg relative Fast Rewrite IR | Avg relative representative TED | Avg relative Certificate-Integrated IR |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **17.086902** | **13.970096** | **32.255544** | **14.021721** | **0.547644** | **0.833664** | **0.696100** | **0.916525** | **0.711513** |
| classroom_fol | BOTH | 1696 | 54.403302 | 23.034788 | 19.881486 | 38.972877 | 19.299528 | 0.624351 | 0.887834 | 0.825987 | 0.989098 | 0.827986 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 14.737756 | 10.632362 | 23.610663 | 10.207688 | 0.537345 | 0.839291 | 0.588401 | 0.806334 | 0.579809 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 17.605744 | 15.120104 | 31.211488 | 14.960836 | 0.596239 | 0.848067 | 0.781317 | 0.977595 | 0.789224 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 22.768489 | 17.768489 | 36.971061 | 16.797428 | 0.606512 | 0.839564 | 0.773383 | 0.946592 | 0.756786 |
| classroom_rl | BOTH | 1219 | 35.016407 | 13.497129 | 11.609516 | 27.009844 | 11.812961 | 0.574684 | 0.803115 | 0.719625 | 0.959445 | 0.743210 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 8.852415 | 5.837209 | 15.590340 | 5.879249 | 0.439188 | 0.699531 | 0.419245 | 0.685546 | 0.427355 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 9.968921 | 9.131627 | 22.908592 | 9.506399 | 0.487860 | 0.731131 | 0.652467 | 0.904878 | 0.684512 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 12.152305 | 9.567134 | 24.667335 | 9.931864 | 0.495818 | 0.714155 | 0.616535 | 0.860191 | 0.645422 |
| coursesNew | BOTH | 1803 | 53.808098 | 23.124792 | 19.220189 | 44.193566 | 19.341653 | 0.614704 | 0.941881 | 0.861811 | 1.078822 | 0.877928 |
| coursesNew | CORRECT | 1338 | 38.111360 | 16.027653 | 12.517937 | 27.192825 | 12.709268 | 0.589369 | 0.895927 | 0.776149 | 1.044557 | 0.794218 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 17.171254 | 12.923547 | 29.486239 | 13.003058 | 0.664941 | 0.915757 | 0.794712 | 1.058538 | 0.804409 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 19.990365 | 16.869924 | 40.235375 | 17.481074 | 0.528858 | 0.856754 | 0.803459 | 1.018515 | 0.837698 |
| coursesOld | BOTH | 4001 | 57.329168 | 23.793302 | 20.487128 | 47.440890 | 20.319670 | 0.614074 | 0.925301 | 0.859099 | 1.081314 | 0.866641 |
| coursesOld | CORRECT | 2148 | 38.013501 | 14.661080 | 10.439944 | 23.313315 | 10.611732 | 0.591233 | 0.892638 | 0.719106 | 0.993930 | 0.734742 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 18.336828 | 14.228047 | 34.258191 | 14.331586 | 0.647316 | 0.919405 | 0.761368 | 1.054668 | 0.774542 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 19.390916 | 16.564441 | 38.813276 | 16.769022 | 0.531564 | 0.814440 | 0.802771 | 1.020833 | 0.826837 |
| cv_v1 | BOTH | 258 | 53.255814 | 24.891473 | 21.624031 | 53.813953 | 21.968992 | 0.661750 | 0.948298 | 0.816502 | 1.036696 | 0.835126 |
| cv_v1 | CORRECT | 106 | 27.886792 | 15.877358 | 10.443396 | 29.613208 | 10.849057 | 0.405510 | 0.719290 | 0.555689 | 0.810301 | 0.590081 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 22.284444 | 16.706667 | 43.768889 | 16.982222 | 0.591220 | 0.844972 | 0.690915 | 0.934027 | 0.712222 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 18.602740 | 14.858447 | 38.881279 | 15.146119 | 0.687474 | 0.900143 | 0.722996 | 0.989236 | 0.744558 |
| cv_v2 | BOTH | 71 | 59.929577 | 34.309859 | 35.014085 | 75.873239 | 35.436620 | 0.599896 | 1.025868 | 0.942980 | 1.024762 | 0.960363 |
| cv_v2 | CORRECT | 57 | 30.473684 | 17.140351 | 15.982456 | 45.754386 | 16.368421 | 0.430811 | 0.762514 | 0.658256 | 0.947185 | 0.679077 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 30.571429 | 30.933333 | 69.971429 | 31.276190 | 0.572770 | 0.992836 | 0.862179 | 1.021943 | 0.879879 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 29.625000 | 32.175000 | 69.600000 | 32.525000 | 0.590867 | 1.066017 | 0.956407 | 1.131278 | 0.977747 |
| graphs | BOTH | 361 | 24.570637 | 12.360111 | 10.207756 | 26.565097 | 10.235457 | 0.648332 | 0.920265 | 0.745510 | 1.006964 | 0.753627 |
| graphs | CORRECT | 820 | 25.169512 | 11.375610 | 8.434146 | 22.773171 | 8.425610 | 0.594930 | 0.798086 | 0.626456 | 0.956903 | 0.628522 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 10.218605 | 8.477519 | 26.007752 | 8.665116 | 0.479910 | 0.713761 | 0.642395 | 0.989184 | 0.661519 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 12.245399 | 9.073620 | 22.585890 | 9.085890 | 0.617945 | 0.877245 | 0.748888 | 1.012368 | 0.751033 |
| lts | BOTH | 555 | 50.536937 | 26.234234 | 23.800000 | 37.207207 | 21.509910 | 0.641920 | 0.923262 | 0.752035 | 1.003735 | 0.789588 |
| lts | CORRECT | 249 | 29.991968 | 14.582329 | 11.012048 | 20.080321 | 10.248996 | 0.550300 | 0.747385 | 0.522202 | 0.782595 | 0.565298 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 23.364629 | 22.823144 | 36.403930 | 20.480349 | 0.615166 | 0.856865 | 0.783764 | 1.044072 | 0.811016 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 19.862205 | 18.208661 | 33.779528 | 17.122047 | 0.556787 | 0.783206 | 0.683787 | 1.041958 | 0.765880 |
| productionLineNew | BOTH | 656 | 45.213415 | 20.420732 | 17.539634 | 39.181402 | 17.557927 | 0.509207 | 0.874209 | 0.767917 | 0.958285 | 0.780491 |
| productionLineNew | CORRECT | 693 | 34.992785 | 15.523810 | 11.180375 | 24.679654 | 11.098124 | 0.445274 | 0.744545 | 0.547697 | 0.746482 | 0.547620 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 17.987500 | 14.815625 | 34.490625 | 14.906250 | 0.459963 | 0.780481 | 0.680570 | 0.879209 | 0.695164 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 22.021544 | 18.509874 | 39.804309 | 18.563734 | 0.528572 | 0.948695 | 0.788133 | 0.966036 | 0.792173 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 15.785047 | 10.719626 | 30.813084 | 11.280374 | 0.531859 | 0.904081 | 0.669025 | 1.019581 | 0.705752 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 11.868966 | 8.848276 | 24.593103 | 9.110345 | 0.434531 | 0.765052 | 0.649179 | 0.949957 | 0.677572 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 14.100000 | 12.390000 | 33.340000 | 12.840000 | 0.451724 | 0.785496 | 0.730869 | 0.985651 | 0.769202 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 9.032680 | 6.954248 | 16.954248 | 7.019608 | 0.578122 | 0.708447 | 0.627536 | 0.791425 | 0.634593 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 19.970115 | 16.696552 | 37.977011 | 16.741379 | 0.499213 | 0.853255 | 0.753313 | 0.955483 | 0.763661 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 16.917260 | 13.318505 | 29.012456 | 13.230427 | 0.477882 | 0.760295 | 0.594457 | 0.833628 | 0.596238 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 19.641066 | 16.727273 | 37.858934 | 16.702194 | 0.495962 | 0.844679 | 0.746085 | 0.941565 | 0.752203 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 20.054274 | 17.105834 | 35.559023 | 17.142469 | 0.540061 | 0.880948 | 0.752403 | 0.931339 | 0.755666 |
| socialMedia | BOTH | 4982 | 50.487756 | 22.307507 | 17.429546 | 42.090124 | 17.638499 | 0.581993 | 0.859294 | 0.766845 | 1.024772 | 0.787641 |
| socialMedia | CORRECT | 4550 | 28.614945 | 14.883736 | 9.680000 | 23.990330 | 10.034286 | 0.419222 | 0.695863 | 0.485425 | 0.680160 | 0.520622 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 22.495304 | 18.331246 | 43.599249 | 18.623669 | 0.543362 | 0.841129 | 0.743644 | 1.007011 | 0.771043 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 18.908743 | 15.907001 | 40.969349 | 16.169627 | 0.533680 | 0.785731 | 0.767083 | 1.050125 | 0.795181 |
| trainStationNew | BOTH | 2325 | 43.576774 | 17.474839 | 17.243441 | 40.547097 | 17.323441 | 0.588892 | 0.819806 | 0.779958 | 0.939888 | 0.786138 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 11.334791 | 7.274204 | 18.062461 | 7.404747 | 0.461784 | 0.658098 | 0.379462 | 0.517705 | 0.392190 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 15.364296 | 11.317852 | 29.104499 | 11.584906 | 0.506348 | 0.767370 | 0.557559 | 0.779636 | 0.575398 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 10.981567 | 15.925499 | 35.910138 | 15.963902 | 0.509954 | 0.682687 | 0.805372 | 0.899485 | 0.810753 |
| trainStationOld | BOTH | 357 | 56.574230 | 29.459384 | 28.464986 | 60.492997 | 28.151261 | 0.629920 | 1.059249 | 0.902966 | 1.024048 | 0.911120 |
| trainStationOld | CORRECT | 111 | 29.864865 | 13.441441 | 8.234234 | 21.612613 | 8.738739 | 0.531537 | 0.877128 | 0.461446 | 0.711739 | 0.491552 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 17.547264 | 15.368159 | 33.975124 | 15.636816 | 0.570660 | 1.019222 | 0.726474 | 0.979846 | 0.749935 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 21.826087 | 18.516908 | 39.231884 | 18.106280 | 0.602022 | 0.976935 | 0.808107 | 0.944789 | 0.816088 |
| trash_fol | BOTH | 377 | 27.262599 | 11.514589 | 8.360743 | 17.801061 | 8.432361 | 0.613723 | 0.916050 | 0.747546 | 0.901545 | 0.752275 |
| trash_fol | CORRECT | 1667 | 26.151170 | 11.079184 | 5.506899 | 12.756449 | 5.497301 | 0.649266 | 0.966178 | 0.460439 | 0.618039 | 0.460151 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 12.834101 | 9.622120 | 21.460829 | 9.649770 | 0.684851 | 0.904688 | 0.748064 | 0.952956 | 0.750298 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 15.557692 | 10.365385 | 21.923077 | 10.346154 | 0.655198 | 0.892703 | 0.746171 | 0.884591 | 0.746610 |
| trash_ltl | BOTH | 1486 | 29.627187 | 10.890983 | 10.971063 | 22.665545 | 11.296097 | 0.538142 | 0.868419 | 0.674700 | 0.857860 | 0.695148 |
| trash_ltl | CORRECT | 863 | 20.166860 | 8.126304 | 6.500579 | 13.458864 | 6.509849 | 0.385829 | 0.736275 | 0.428312 | 0.530207 | 0.429121 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 8.930403 | 7.177656 | 18.604396 | 7.298535 | 0.470347 | 0.801440 | 0.518842 | 0.835167 | 0.528814 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 9.972455 | 10.844311 | 21.053892 | 10.926946 | 0.485105 | 0.862441 | 0.759129 | 0.903312 | 0.764417 |
| trash_rl | BOTH | 591 | 18.964467 | 8.086294 | 6.463621 | 15.245347 | 6.517766 | 0.577751 | 0.876816 | 0.679416 | 0.883351 | 0.684958 |
| trash_rl | CORRECT | 1009 | 18.356789 | 8.499504 | 4.751239 | 12.122894 | 4.701685 | 0.582256 | 0.916752 | 0.507160 | 0.777312 | 0.503665 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 8.149701 | 6.326347 | 15.356287 | 6.347305 | 0.612100 | 0.872160 | 0.657213 | 0.913242 | 0.661408 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 12.848485 | 8.590909 | 21.780303 | 8.575758 | 0.617090 | 0.893899 | 0.680254 | 0.917462 | 0.683715 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 100
- Rewards enabled: true
- Average candidate reward: 0.554601
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.445399
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, Certificate-Integrated IR distance vs candidate reward: -0.063966

- Pearson correlation, canonical representative TED vs candidate reward: -0.059931
- Pearson correlation, Fast Rewrite IR distance vs candidate reward: -0.061345
- Pearson correlation, Levenshtein vs candidate reward: -0.090795
- Pearson correlation, raw AST tree distance vs candidate reward: -0.087821

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.071160
- Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward: -0.080314

- Pearson correlation, normalized canonical representative TED vs candidate reward: -0.092155

- Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward: -0.063230

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 19.299528 | 0.221406 | -0.084690 | 1 | 79 |
| classroom_fol | CORRECT | 1884 | 1613 | 271 | 0 | 10.207688 | 1.000000 | 0.000000 | 0 | 39 |
| classroom_fol | OVERCONSTRAINED | 383 | 383 | 0 | 0 | 14.960836 | 0.418354 | 0.130057 | 1 | 60 |
| classroom_fol | UNDERCONSTRAINED | 311 | 311 | 0 | 0 | 16.797428 | 0.275754 | 0.394211 | 1 | 43 |
| classroom_rl | BOTH | 1219 | 1219 | 0 | 0 | 11.812961 | 0.258242 | -0.019930 | 1 | 58 |
| classroom_rl | CORRECT | 1764 | 1118 | 646 | 0 | 5.879249 | 1.000000 | 0.000000 | 0 | 43 |
| classroom_rl | OVERCONSTRAINED | 547 | 547 | 0 | 0 | 9.506399 | 0.422926 | 0.135582 | 1 | 47 |
| classroom_rl | UNDERCONSTRAINED | 499 | 499 | 0 | 0 | 9.931864 | 0.174385 | 0.334452 | 1 | 31 |
| coursesNew | BOTH | 1803 | 1803 | 0 | 0 | 19.341653 | 0.246501 | -0.186406 | 1 | 61 |
| coursesNew | CORRECT | 1371 | 1338 | 33 | 0 | 12.709268 | 1.000000 | 0.000000 | 0 | 50 |
| coursesNew | OVERCONSTRAINED | 327 | 327 | 0 | 0 | 13.003058 | 0.540050 | -0.041217 | 1 | 61 |
| coursesNew | UNDERCONSTRAINED | 1453 | 1453 | 0 | 0 | 17.481074 | 0.425532 | -0.147824 | 1 | 52 |
| coursesOld | BOTH | 4001 | 4001 | 0 | 0 | 20.319670 | 0.203963 | -0.153777 | 1 | 180 |
| coursesOld | CORRECT | 2284 | 2148 | 136 | 0 | 10.611732 | 1.000000 | 0.000000 | 0 | 45 |
| coursesOld | OVERCONSTRAINED | 763 | 763 | 0 | 0 | 14.331586 | 0.446171 | -0.134235 | 1 | 69 |
| coursesOld | UNDERCONSTRAINED | 2576 | 2576 | 0 | 0 | 16.769022 | 0.415217 | -0.150182 | 1 | 53 |
| cv_v1 | BOTH | 258 | 258 | 0 | 0 | 21.968992 | 0.228550 | -0.018190 | 4 | 44 |
| cv_v1 | CORRECT | 155 | 106 | 49 | 0 | 10.849057 | 1.000000 | 0.000000 | 0 | 41 |
| cv_v1 | OVERCONSTRAINED | 225 | 225 | 0 | 0 | 16.982222 | 0.147501 | -0.118106 | 2 | 42 |
| cv_v1 | UNDERCONSTRAINED | 219 | 219 | 0 | 0 | 15.146119 | 0.194329 | 0.267138 | 3 | 37 |
| cv_v2 | BOTH | 71 | 71 | 0 | 0 | 35.436620 | 0.205966 | -0.041376 | 3 | 101 |
| cv_v2 | CORRECT | 64 | 57 | 7 | 0 | 16.368421 | 1.000000 | 0.000000 | 0 | 53 |
| cv_v2 | OVERCONSTRAINED | 105 | 105 | 0 | 0 | 31.276190 | 0.299230 | 0.182348 | 1 | 102 |
| cv_v2 | UNDERCONSTRAINED | 40 | 40 | 0 | 0 | 32.525000 | 0.437210 | 0.542315 | 2 | 99 |
| graphs | BOTH | 361 | 361 | 0 | 0 | 10.235457 | 0.304664 | 0.092538 | 1 | 36 |
| graphs | CORRECT | 1058 | 820 | 238 | 0 | 8.425610 | 0.999999 | 0.000000 | 0 | 60 |
| graphs | OVERCONSTRAINED | 645 | 645 | 0 | 0 | 8.665116 | 0.443294 | -0.063059 | 1 | 30 |
| graphs | UNDERCONSTRAINED | 326 | 326 | 0 | 0 | 9.085890 | 0.487304 | 0.195904 | 1 | 29 |
| lts | BOTH | 555 | 555 | 0 | 0 | 21.509910 | 0.189667 | 0.347697 | 1 | 64 |
| lts | CORRECT | 577 | 249 | 328 | 0 | 10.248996 | 1.000000 | 0.000000 | 0 | 35 |
| lts | OVERCONSTRAINED | 458 | 458 | 0 | 0 | 20.480349 | 0.321068 | 0.262166 | 1 | 64 |
| lts | UNDERCONSTRAINED | 254 | 254 | 0 | 0 | 17.122047 | 0.172204 | 0.289268 | 1 | 64 |
| productionLineNew | BOTH | 656 | 656 | 0 | 0 | 17.557927 | 0.294607 | -0.142173 | 1 | 70 |
| productionLineNew | CORRECT | 818 | 693 | 125 | 0 | 11.098124 | 1.000000 | 0.000000 | 0 | 80 |
| productionLineNew | OVERCONSTRAINED | 320 | 320 | 0 | 0 | 14.906250 | 0.329941 | -0.196085 | 1 | 55 |
| productionLineNew | UNDERCONSTRAINED | 557 | 557 | 0 | 0 | 18.563734 | 0.552549 | -0.201894 | 1 | 79 |
| productionLine_v1 | BOTH | 107 | 107 | 0 | 0 | 11.280374 | 0.144778 | 0.542490 | 1 | 26 |
| productionLine_v1 | CORRECT | 239 | 145 | 94 | 0 | 9.110345 | 1.000000 | 0.000000 | 0 | 31 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 100 | 0 | 0 | 12.840000 | 0.047098 | 0.157814 | 1 | 29 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 153 | 0 | 0 | 7.019608 | 0.440088 | -0.190374 | 2 | 23 |
| productionLine_v2 | BOTH | 870 | 870 | 0 | 0 | 16.741379 | 0.307091 | -0.038480 | 1 | 83 |
| productionLine_v2 | CORRECT | 1326 | 1124 | 202 | 0 | 13.230427 | 1.000000 | 0.000000 | 0 | 105 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 638 | 0 | 0 | 16.702194 | 0.352790 | -0.316445 | 1 | 68 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 737 | 0 | 0 | 17.142469 | 0.693635 | -0.019596 | 1 | 75 |
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 17.638499 | 0.187684 | 0.002815 | 1 | 115 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.034286 | 0.999560 | 0.000000 | 0 | 124 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 18.623669 | 0.108430 | 0.020826 | 1 | 117 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 16.169627 | 0.645759 | 0.221956 | 1 | 86 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.323441 | 0.372981 | 0.038100 | 1 | 97 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 7.404747 | 1.000000 | 0.000000 | 0 | 102 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 11.584906 | 0.796660 | -0.080971 | 1 | 53 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 15.963902 | 0.648703 | -0.091404 | 1 | 50 |
| trainStationOld | BOTH | 357 | 357 | 0 | 0 | 28.151261 | 0.276158 | 0.136281 | 2 | 94 |
| trainStationOld | CORRECT | 185 | 111 | 74 | 0 | 8.738739 | 0.999996 | 0.000000 | 0 | 33 |
| trainStationOld | OVERCONSTRAINED | 201 | 201 | 0 | 0 | 15.636816 | 0.550904 | -0.054113 | 1 | 61 |
| trainStationOld | UNDERCONSTRAINED | 207 | 207 | 0 | 0 | 18.106280 | 0.330656 | -0.147095 | 1 | 61 |
| trash_fol | BOTH | 377 | 377 | 0 | 0 | 8.432361 | 0.302927 | 0.257337 | 1 | 55 |
| trash_fol | CORRECT | 1982 | 1667 | 315 | 0 | 5.497301 | 1.000000 | 0.000000 | 0 | 19 |
| trash_fol | OVERCONSTRAINED | 217 | 217 | 0 | 0 | 9.649770 | 0.337689 | 0.243717 | 1 | 24 |
| trash_fol | UNDERCONSTRAINED | 104 | 104 | 0 | 0 | 10.346154 | 0.487209 | 0.035042 | 1 | 20 |
| trash_ltl | BOTH | 1486 | 1486 | 0 | 0 | 11.296097 | 0.366455 | 0.182450 | 1 | 31 |
| trash_ltl | CORRECT | 1440 | 863 | 577 | 0 | 6.509849 | 1.000000 | 0.000000 | 0 | 18 |
| trash_ltl | OVERCONSTRAINED | 546 | 546 | 0 | 0 | 7.298535 | 0.633484 | -0.141126 | 1 | 22 |
| trash_ltl | UNDERCONSTRAINED | 835 | 835 | 0 | 0 | 10.926946 | 0.578260 | 0.089534 | 1 | 30 |
| trash_rl | BOTH | 591 | 591 | 0 | 0 | 6.517766 | 0.342525 | 0.214656 | 1 | 34 |
| trash_rl | CORRECT | 1649 | 1009 | 640 | 0 | 4.701685 | 1.000000 | 0.000000 | 0 | 28 |
| trash_rl | OVERCONSTRAINED | 334 | 334 | 0 | 0 | 6.347305 | 0.366014 | -0.106033 | 1 | 24 |
| trash_rl | UNDERCONSTRAINED | 132 | 132 | 0 | 0 | 8.575758 | 0.370073 | -0.198306 | 1 | 23 |
