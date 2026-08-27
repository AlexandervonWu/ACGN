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
- Average Certificate-Integrated IR repair distance: 14.021251
- Average canonical representative TED baseline: 32.254732
- Average Fast Rewrite IR distance: 13.938342
- Average predicate-body Levenshtein distance: 39.261064
- Average raw AST tree distance: 22.841358
- Average raw AST size: 26.787315
- Average Certificate-Integrated IR repair observation size: 17.989285
- Average canonical representative tree size: 33.198204
- Average Fast Rewrite IR NormalForm size: 18.195169
- Average normalized predicate-body Levenshtein distance: 0.547644
- Average normalized raw AST distance: 0.811451
- Average normalized Certificate-Integrated IR distance: 0.711525
- Average normalized canonical representative TED: 0.916517
- Average normalized Fast Rewrite IR distance: 0.696300
- CORRECT models with canonical distance 0 and raw AST distance > 0: 4088
- Incorrect zero-distance merges: 0
- Inexact alpha searches: 0
- Average certified repair metric time: 0.107564 ms
- Average canonical representative TED time: 0.364594 ms
- Min distance: 0
- Max distance: 180

## Repair Observation Compression

Compression rate is `100 * (raw AST size - repair observation size) / raw AST size`. Negative values indicate expansion. Sizes are for the student predicate associated with the directory label; identical-AST pairs are excluded.

| Problem class | Correctness division | Models | Avg raw AST size | Avg repair observation size | Compression rate |
| --- | --- | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 33.897406 | 22.303656 | 34.202470% |
| classroom_fol | CORRECT | 1613 | 24.099814 | 14.990081 | 37.800015% |
| classroom_fol | OVERCONSTRAINED | 383 | 26.671018 | 17.295039 | 35.154185% |
| classroom_fol | UNDERCONSTRAINED | 311 | 35.546624 | 21.350482 | 39.936680% |
| classroom_rl | BOTH | 1219 | 21.272354 | 13.992617 | 34.221588% |
| classroom_rl | CORRECT | 1118 | 17.205725 | 10.970483 | 36.239343% |
| classroom_rl | OVERCONSTRAINED | 547 | 17.093236 | 11.683729 | 31.647059% |
| classroom_rl | UNDERCONSTRAINED | 499 | 21.615230 | 13.707415 | 36.584461% |
| coursesNew | BOTH | 1803 | 30.561287 | 21.235164 | 30.516134% |
| coursesNew | CORRECT | 1338 | 24.857250 | 15.028401 | 39.541177% |
| coursesNew | OVERCONSTRAINED | 327 | 24.660550 | 14.822630 | 39.893353% |
| coursesNew | UNDERCONSTRAINED | 1453 | 29.090158 | 20.019959 | 31.179616% |
| coursesOld | BOTH | 4001 | 31.062484 | 22.232942 | 28.425101% |
| coursesOld | CORRECT | 2148 | 22.381750 | 13.332402 | 40.431816% |
| coursesOld | OVERCONSTRAINED | 763 | 24.693316 | 16.339450 | 33.830476% |
| coursesOld | UNDERCONSTRAINED | 2576 | 28.365295 | 19.017081 | 32.956521% |
| cv_v1 | BOTH | 258 | 27.833333 | 18.027132 | 35.231862% |
| cv_v1 | CORRECT | 106 | 25.726415 | 16.301887 | 36.633663% |
| cv_v1 | OVERCONSTRAINED | 225 | 29.266667 | 17.551111 | 40.030372% |
| cv_v1 | UNDERCONSTRAINED | 219 | 20.917808 | 14.237443 | 31.936258% |
| cv_v2 | BOTH | 71 | 35.450704 | 27.859155 | 21.414382% |
| cv_v2 | CORRECT | 57 | 29.017544 | 20.070175 | 30.834341% |
| cv_v2 | OVERCONSTRAINED | 105 | 34.333333 | 27.038095 | 21.248266% |
| cv_v2 | UNDERCONSTRAINED | 40 | 30.350000 | 24.950000 | 17.792422% |
| graphs | BOTH | 361 | 18.094183 | 12.337950 | 31.812615% |
| graphs | CORRECT | 820 | 19.539024 | 12.115854 | 37.991512% |
| graphs | OVERCONSTRAINED | 645 | 19.862016 | 11.869767 | 40.238857% |
| graphs | UNDERCONSTRAINED | 326 | 18.773006 | 11.177914 | 40.457516% |
| lts | BOTH | 555 | 22.138739 | 14.436036 | 34.792871% |
| lts | CORRECT | 249 | 21.534137 | 12.602410 | 41.477061% |
| lts | OVERCONSTRAINED | 458 | 20.034934 | 11.834061 | 40.932868% |
| lts | UNDERCONSTRAINED | 254 | 22.303150 | 13.570866 | 39.152692% |
| productionLineNew | BOTH | 656 | 29.251524 | 18.417683 | 37.036844% |
| productionLineNew | CORRECT | 693 | 26.637807 | 17.246753 | 35.254605% |
| productionLineNew | OVERCONSTRAINED | 320 | 28.875000 | 19.025000 | 34.112554% |
| productionLineNew | UNDERCONSTRAINED | 557 | 27.996409 | 16.935368 | 39.508785% |
| productionLine_v1 | BOTH | 107 | 20.345794 | 12.514019 | 38.493339% |
| productionLine_v1 | CORRECT | 145 | 20.372414 | 12.524138 | 38.524035% |
| productionLine_v1 | OVERCONSTRAINED | 100 | 22.000000 | 13.430000 | 38.954545% |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 11.326797 | 7.366013 | 34.968263% |
| productionLine_v2 | BOTH | 870 | 28.722989 | 18.168966 | 36.744167% |
| productionLine_v2 | CORRECT | 1124 | 27.223310 | 17.920819 | 34.171051% |
| productionLine_v2 | OVERCONSTRAINED | 638 | 29.799373 | 19.713166 | 33.847044% |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 27.697422 | 17.552239 | 36.628619% |
| socialMedia | BOTH | 4982 | 32.315937 | 20.299679 | 37.183692% |
| socialMedia | CORRECT | 4550 | 25.487912 | 15.376923 | 39.669742% |
| socialMedia | OVERCONSTRAINED | 1597 | 32.652473 | 21.385723 | 34.505044% |
| socialMedia | UNDERCONSTRAINED | 2871 | 29.847092 | 18.578544 | 37.754257% |
| trainStationNew | BOTH | 2325 | 27.021935 | 19.093333 | 29.341355% |
| trainStationNew | CORRECT | 1601 | 21.845097 | 16.439101 | 24.746955% |
| trainStationNew | OVERCONSTRAINED | 689 | 24.709724 | 17.301887 | 29.979442% |
| trainStationNew | UNDERCONSTRAINED | 1302 | 19.366359 | 12.692012 | 34.463613% |
| trainStationOld | BOTH | 357 | 28.591036 | 21.829132 | 23.650436% |
| trainStationOld | CORRECT | 111 | 19.981982 | 15.585586 | 22.001803% |
| trainStationOld | OVERCONSTRAINED | 201 | 19.741294 | 16.149254 | 18.195565% |
| trainStationOld | UNDERCONSTRAINED | 207 | 26.676329 | 17.632850 | 33.900761% |
| trash_fol | BOTH | 377 | 17.997347 | 10.859416 | 39.661017% |
| trash_fol | CORRECT | 1667 | 16.296341 | 8.865627 | 45.597438% |
| trash_fol | OVERCONSTRAINED | 217 | 18.903226 | 11.723502 | 37.981472% |
| trash_fol | UNDERCONSTRAINED | 104 | 24.009615 | 13.336538 | 44.453344% |
| trash_ltl | BOTH | 1486 | 16.545087 | 14.812921 | 10.469373% |
| trash_ltl | CORRECT | 863 | 15.442642 | 13.920046 | 9.859683% |
| trash_ltl | OVERCONSTRAINED | 546 | 15.584249 | 13.397436 | 14.032201% |
| trash_ltl | UNDERCONSTRAINED | 835 | 15.538922 | 13.362874 | 14.003854% |
| trash_rl | BOTH | 591 | 13.314721 | 8.837563 | 33.625620% |
| trash_rl | CORRECT | 1009 | 12.935580 | 7.830525 | 39.465216% |
| trash_rl | OVERCONSTRAINED | 334 | 12.565868 | 8.383234 | 33.285680% |
| trash_rl | UNDERCONSTRAINED | 132 | 19.310606 | 11.545455 | 40.211848% |

## Distance Averages Overall And By Problem Class And Status

Raw columns use edit-distance units. Relative columns divide each distance by the larger corresponding representation of the student-oracle pair: body characters for Levenshtein, raw AST nodes for AST distance, and canonical-form size for canonical distance. Identical raw-AST pairs skipped by the test are excluded.

| Problem class | Semantic correctness class | Comparisons | Avg Levenshtein | Avg raw AST | Avg Fast Rewrite IR | Avg representative TED | Avg Certificate-Integrated IR | Avg relative Levenshtein | Avg relative raw AST | Avg relative Fast Rewrite IR | Avg relative representative TED | Avg relative Certificate-Integrated IR |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **All problem classes** | **All statuses** | **61598** | **39.261064** | **22.841358** | **13.938342** | **32.254732** | **14.021251** | **0.547644** | **0.811451** | **0.696300** | **0.916517** | **0.711525** |
| classroom_fol | BOTH | 1696 | 54.403302 | 29.843750 | 19.874410 | 38.955189 | 19.291863 | 0.624351 | 0.860807 | 0.826010 | 0.989074 | 0.827951 |
| classroom_fol | CORRECT | 1613 | 34.698078 | 19.522009 | 10.632362 | 23.610663 | 10.207688 | 0.537345 | 0.811881 | 0.588401 | 0.806334 | 0.579809 |
| classroom_fol | OVERCONSTRAINED | 383 | 44.506527 | 23.219321 | 15.120104 | 31.211488 | 14.960836 | 0.596239 | 0.824708 | 0.781317 | 0.977595 | 0.789224 |
| classroom_fol | UNDERCONSTRAINED | 311 | 56.729904 | 29.591640 | 17.768489 | 36.971061 | 16.797428 | 0.606512 | 0.816431 | 0.773383 | 0.946592 | 0.756786 |
| classroom_rl | BOTH | 1219 | 35.016407 | 18.521739 | 11.619360 | 27.009844 | 11.812961 | 0.574684 | 0.779269 | 0.720114 | 0.959445 | 0.743210 |
| classroom_rl | CORRECT | 1118 | 21.346154 | 12.228086 | 5.847048 | 15.590340 | 5.879249 | 0.439188 | 0.652025 | 0.420591 | 0.685546 | 0.427355 |
| classroom_rl | OVERCONSTRAINED | 547 | 23.131627 | 13.672761 | 9.135283 | 22.908592 | 9.506399 | 0.487860 | 0.706261 | 0.652728 | 0.904878 | 0.684512 |
| classroom_rl | UNDERCONSTRAINED | 499 | 30.961924 | 16.621242 | 9.571142 | 24.667335 | 9.931864 | 0.495818 | 0.681461 | 0.616702 | 0.860191 | 0.645422 |
| coursesNew | BOTH | 1803 | 53.808098 | 31.171381 | 19.206323 | 44.193566 | 19.341653 | 0.614704 | 0.950469 | 0.861164 | 1.078822 | 0.877928 |
| coursesNew | CORRECT | 1338 | 38.111360 | 21.863229 | 12.516442 | 27.192825 | 12.709268 | 0.589369 | 0.890632 | 0.776092 | 1.044557 | 0.794218 |
| coursesNew | OVERCONSTRAINED | 327 | 43.134557 | 23.553517 | 12.923547 | 29.486239 | 13.003058 | 0.664941 | 0.924123 | 0.794712 | 1.058538 | 0.804409 |
| coursesNew | UNDERCONSTRAINED | 1453 | 44.737784 | 27.038541 | 16.860977 | 40.235375 | 17.481074 | 0.528858 | 0.871782 | 0.803099 | 1.018515 | 0.837698 |
| coursesOld | BOTH | 4001 | 57.329168 | 31.169958 | 20.457886 | 47.451387 | 20.319670 | 0.614074 | 0.913088 | 0.857775 | 1.081313 | 0.866641 |
| coursesOld | CORRECT | 2148 | 38.013501 | 20.067970 | 10.431564 | 23.313315 | 10.611732 | 0.591233 | 0.867271 | 0.718857 | 0.993930 | 0.734742 |
| coursesOld | OVERCONSTRAINED | 763 | 46.423329 | 24.905636 | 14.222805 | 34.258191 | 14.331586 | 0.647316 | 0.908805 | 0.761153 | 1.054668 | 0.774542 |
| coursesOld | UNDERCONSTRAINED | 2576 | 47.348602 | 25.468556 | 16.547748 | 38.813276 | 16.769022 | 0.531564 | 0.805671 | 0.801676 | 1.020833 | 0.826837 |
| cv_v1 | BOTH | 258 | 53.255814 | 33.003876 | 21.581395 | 53.813953 | 21.968992 | 0.661750 | 0.949859 | 0.815157 | 1.036696 | 0.835126 |
| cv_v1 | CORRECT | 106 | 27.886792 | 19.839623 | 10.443396 | 29.613208 | 10.849057 | 0.405510 | 0.670888 | 0.555689 | 0.810301 | 0.590081 |
| cv_v1 | OVERCONSTRAINED | 225 | 48.715556 | 28.657778 | 16.728889 | 43.768889 | 16.982222 | 0.591220 | 0.821782 | 0.691666 | 0.934027 | 0.712222 |
| cv_v1 | UNDERCONSTRAINED | 219 | 44.013699 | 25.315068 | 14.867580 | 38.881279 | 15.146119 | 0.687474 | 0.900138 | 0.723361 | 0.989236 | 0.744558 |
| cv_v2 | BOTH | 71 | 59.929577 | 46.126761 | 35.507042 | 75.873239 | 35.436620 | 0.599896 | 1.051092 | 0.957918 | 1.024762 | 0.960363 |
| cv_v2 | CORRECT | 57 | 30.473684 | 28.719298 | 15.982456 | 45.754386 | 16.368421 | 0.430811 | 0.871002 | 0.658256 | 0.947185 | 0.679077 |
| cv_v2 | OVERCONSTRAINED | 105 | 53.790476 | 40.314286 | 31.066667 | 69.971429 | 31.276190 | 0.572770 | 0.983074 | 0.866220 | 1.021943 | 0.879879 |
| cv_v2 | UNDERCONSTRAINED | 40 | 51.525000 | 40.150000 | 32.175000 | 69.600000 | 32.525000 | 0.590867 | 1.065550 | 0.956407 | 1.131278 | 0.977747 |
| graphs | BOTH | 361 | 24.570637 | 17.404432 | 10.202216 | 26.565097 | 10.235457 | 0.648332 | 0.867783 | 0.745048 | 1.006964 | 0.753627 |
| graphs | CORRECT | 820 | 25.169512 | 15.212195 | 8.434146 | 22.773171 | 8.425610 | 0.594930 | 0.736133 | 0.626456 | 0.956903 | 0.628522 |
| graphs | OVERCONSTRAINED | 645 | 17.427907 | 15.305426 | 8.472868 | 26.007752 | 8.665116 | 0.479910 | 0.696726 | 0.642007 | 0.989184 | 0.661519 |
| graphs | UNDERCONSTRAINED | 326 | 24.696319 | 17.156442 | 9.073620 | 22.585890 | 9.085890 | 0.617945 | 0.848759 | 0.748888 | 1.012368 | 0.751033 |
| lts | BOTH | 555 | 50.536937 | 35.338739 | 22.214414 | 37.207207 | 21.509910 | 0.641920 | 0.895019 | 0.761543 | 1.003735 | 0.789588 |
| lts | CORRECT | 249 | 29.991968 | 19.634538 | 10.333333 | 20.080321 | 10.248996 | 0.550300 | 0.726068 | 0.523103 | 0.782595 | 0.565298 |
| lts | OVERCONSTRAINED | 458 | 46.735808 | 31.982533 | 21.207424 | 36.403930 | 20.480349 | 0.615166 | 0.839382 | 0.788108 | 1.044072 | 0.811016 |
| lts | UNDERCONSTRAINED | 254 | 39.291339 | 26.740157 | 17.216535 | 33.779528 | 17.122047 | 0.556787 | 0.744322 | 0.690368 | 1.041958 | 0.765880 |
| productionLineNew | BOTH | 656 | 45.213415 | 28.455793 | 17.556402 | 39.181402 | 17.557927 | 0.509207 | 0.868169 | 0.768444 | 0.958285 | 0.780491 |
| productionLineNew | CORRECT | 693 | 34.992785 | 20.793651 | 11.222222 | 24.679654 | 11.098124 | 0.445274 | 0.726740 | 0.549092 | 0.746482 | 0.547620 |
| productionLineNew | OVERCONSTRAINED | 320 | 39.903125 | 24.296875 | 14.815625 | 34.490625 | 14.906250 | 0.459963 | 0.754725 | 0.680570 | 0.879209 | 0.695164 |
| productionLineNew | UNDERCONSTRAINED | 557 | 44.946140 | 30.574506 | 18.529623 | 39.804309 | 18.563734 | 0.528572 | 0.944749 | 0.788884 | 0.966036 | 0.792173 |
| productionLine_v1 | BOTH | 107 | 32.962617 | 21.149533 | 10.719626 | 30.813084 | 11.280374 | 0.531859 | 0.881969 | 0.669025 | 1.019581 | 0.705752 |
| productionLine_v1 | CORRECT | 145 | 24.048276 | 16.193103 | 8.848276 | 24.593103 | 9.110345 | 0.434531 | 0.735868 | 0.649179 | 0.949957 | 0.677572 |
| productionLine_v1 | OVERCONSTRAINED | 100 | 27.890000 | 19.050000 | 12.390000 | 33.340000 | 12.840000 | 0.451724 | 0.773732 | 0.730869 | 0.985651 | 0.769202 |
| productionLine_v1 | UNDERCONSTRAINED | 153 | 24.973856 | 12.196078 | 6.954248 | 16.954248 | 7.019608 | 0.578122 | 0.676481 | 0.627536 | 0.791425 | 0.634593 |
| productionLine_v2 | BOTH | 870 | 44.462069 | 27.693103 | 16.719540 | 37.977011 | 16.741379 | 0.499213 | 0.849087 | 0.753965 | 0.955483 | 0.763661 |
| productionLine_v2 | CORRECT | 1124 | 40.614769 | 23.161922 | 13.351423 | 29.012456 | 13.230427 | 0.477882 | 0.749846 | 0.595507 | 0.833628 | 0.596238 |
| productionLine_v2 | OVERCONSTRAINED | 638 | 45.692790 | 26.752351 | 16.738245 | 37.858934 | 16.702194 | 0.495962 | 0.818031 | 0.746278 | 0.941565 | 0.752203 |
| productionLine_v2 | UNDERCONSTRAINED | 737 | 46.293080 | 28.146540 | 17.172320 | 35.575305 | 17.142469 | 0.540061 | 0.880043 | 0.754579 | 0.931319 | 0.755666 |
| socialMedia | BOTH | 4982 | 50.487756 | 29.238659 | 17.425532 | 42.067644 | 17.630269 | 0.581993 | 0.839846 | 0.766795 | 1.024589 | 0.787528 |
| socialMedia | CORRECT | 4550 | 28.614945 | 19.426813 | 9.679560 | 23.990330 | 10.034286 | 0.419222 | 0.659936 | 0.485388 | 0.680160 | 0.520622 |
| socialMedia | OVERCONSTRAINED | 1597 | 46.153413 | 29.633062 | 18.345648 | 43.613651 | 18.638698 | 0.543362 | 0.821751 | 0.744176 | 1.007083 | 0.771795 |
| socialMedia | UNDERCONSTRAINED | 2871 | 43.909091 | 24.183211 | 15.910484 | 40.969349 | 16.168234 | 0.533680 | 0.756691 | 0.767079 | 1.050125 | 0.795164 |
| trainStationNew | BOTH | 2325 | 43.576774 | 22.907527 | 17.245591 | 40.547097 | 17.323441 | 0.588892 | 0.783639 | 0.779987 | 0.939888 | 0.786138 |
| trainStationNew | CORRECT | 1601 | 25.845097 | 15.271081 | 7.274204 | 18.062461 | 7.404747 | 0.461784 | 0.637859 | 0.379462 | 0.517705 | 0.392190 |
| trainStationNew | OVERCONSTRAINED | 689 | 33.788099 | 20.496372 | 11.320755 | 29.104499 | 11.587808 | 0.506348 | 0.735398 | 0.557704 | 0.779636 | 0.575543 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 27.489247 | 13.814900 | 15.927803 | 35.921659 | 15.966206 | 0.509954 | 0.624067 | 0.805487 | 0.899760 | 0.810868 |
| trainStationOld | BOTH | 357 | 56.574230 | 39.745098 | 28.495798 | 60.492997 | 28.151261 | 0.629920 | 1.044956 | 0.902933 | 1.024048 | 0.911120 |
| trainStationOld | CORRECT | 111 | 29.864865 | 17.909910 | 8.225225 | 21.612613 | 8.738739 | 0.531537 | 0.853222 | 0.461189 | 0.711739 | 0.491552 |
| trainStationOld | OVERCONSTRAINED | 201 | 37.885572 | 23.398010 | 15.368159 | 33.975124 | 15.636816 | 0.570660 | 0.985240 | 0.726474 | 0.979846 | 0.749935 |
| trainStationOld | UNDERCONSTRAINED | 207 | 47.159420 | 29.111111 | 18.545894 | 39.231884 | 18.106280 | 0.602022 | 0.946283 | 0.807580 | 0.944789 | 0.816088 |
| trash_fol | BOTH | 377 | 27.262599 | 16.522546 | 8.360743 | 17.801061 | 8.432361 | 0.613723 | 0.918588 | 0.747546 | 0.901545 | 0.752275 |
| trash_fol | CORRECT | 1667 | 26.151170 | 15.433713 | 5.509898 | 12.756449 | 5.497301 | 0.649266 | 0.930253 | 0.460868 | 0.618039 | 0.460151 |
| trash_fol | OVERCONSTRAINED | 217 | 35.138249 | 18.377880 | 9.622120 | 21.460829 | 9.649770 | 0.684851 | 0.911574 | 0.748064 | 0.952956 | 0.750298 |
| trash_fol | UNDERCONSTRAINED | 104 | 38.865385 | 21.403846 | 10.365385 | 21.923077 | 10.346154 | 0.655198 | 0.883013 | 0.746171 | 0.884591 | 0.746610 |
| trash_ltl | BOTH | 1486 | 29.627187 | 15.105653 | 10.973082 | 22.665545 | 11.296097 | 0.538142 | 0.847314 | 0.674734 | 0.857860 | 0.695148 |
| trash_ltl | CORRECT | 863 | 20.166860 | 11.491309 | 6.505214 | 13.458864 | 6.509849 | 0.385829 | 0.730754 | 0.428734 | 0.530207 | 0.429121 |
| trash_ltl | OVERCONSTRAINED | 546 | 23.205128 | 12.260073 | 7.177656 | 18.604396 | 7.298535 | 0.470347 | 0.756828 | 0.518842 | 0.835167 | 0.528814 |
| trash_ltl | UNDERCONSTRAINED | 835 | 25.899401 | 14.005988 | 10.844311 | 21.053892 | 10.926946 | 0.485105 | 0.844662 | 0.759129 | 0.903312 | 0.764417 |
| trash_rl | BOTH | 591 | 18.964467 | 12.240271 | 6.463621 | 15.245347 | 6.517766 | 0.577751 | 0.860063 | 0.679416 | 0.883351 | 0.684958 |
| trash_rl | CORRECT | 1009 | 18.356789 | 11.993062 | 4.789891 | 12.122894 | 4.701685 | 0.582256 | 0.845125 | 0.510595 | 0.777312 | 0.503665 |
| trash_rl | OVERCONSTRAINED | 334 | 20.359281 | 12.017964 | 6.326347 | 15.356287 | 6.347305 | 0.612100 | 0.827469 | 0.657213 | 0.913242 | 0.661408 |
| trash_rl | UNDERCONSTRAINED | 132 | 28.045455 | 17.810606 | 8.590909 | 21.780303 | 8.575758 | 0.617090 | 0.869380 | 0.680254 | 0.917462 | 0.683715 |

## Reward Comparison

- Rewarded files: 61598
- Reward failures: 0
- Reward pool size: 100
- Rewards enabled: true
- Average candidate reward: 0.554601
- Average ground-truth self reward: 1.000000
- Average reward gap: 0.445399
- Pearson correlation sample: non-CORRECT rewarded predicates (42386 files)
- Pearson correlation, Certificate-Integrated IR distance vs candidate reward: -0.063929

- Pearson correlation, canonical representative TED vs candidate reward: -0.059816
- Pearson correlation, Fast Rewrite IR distance vs candidate reward: -0.061337
- Pearson correlation, Levenshtein vs candidate reward: -0.090795
- Pearson correlation, raw AST tree distance vs candidate reward: -0.081877

- Pearson correlation, normalized raw AST distance vs candidate reward: -0.053464
- Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward: -0.080382

- Pearson correlation, normalized canonical representative TED vs candidate reward: -0.092118

- Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward: -0.062626

## By Problem Class And Status

| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | BOTH | 1696 | 1696 | 0 | 0 | 19.291863 | 0.221406 | -0.084104 | 1 | 79 |
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
| socialMedia | BOTH | 4982 | 4982 | 0 | 0 | 17.630269 | 0.187684 | 0.003132 | 1 | 115 |
| socialMedia | CORRECT | 4945 | 4550 | 395 | 0 | 10.034286 | 0.999560 | 0.000000 | 0 | 124 |
| socialMedia | OVERCONSTRAINED | 1597 | 1597 | 0 | 0 | 18.638698 | 0.108430 | 0.020451 | 1 | 117 |
| socialMedia | UNDERCONSTRAINED | 2871 | 2871 | 0 | 0 | 16.168234 | 0.645759 | 0.221857 | 1 | 86 |
| trainStationNew | BOTH | 2325 | 2325 | 0 | 0 | 17.323441 | 0.372981 | 0.038100 | 1 | 97 |
| trainStationNew | CORRECT | 1953 | 1601 | 352 | 0 | 7.404747 | 1.000000 | 0.000000 | 0 | 102 |
| trainStationNew | OVERCONSTRAINED | 689 | 689 | 0 | 0 | 11.587808 | 0.796660 | -0.080757 | 1 | 53 |
| trainStationNew | UNDERCONSTRAINED | 1302 | 1302 | 0 | 0 | 15.966206 | 0.648703 | -0.091984 | 1 | 50 |
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
