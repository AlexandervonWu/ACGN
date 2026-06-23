# Alloy4Fun Augmented Dataset Summary

- Generated at: `2026-06-23T23:36:44.498311303Z`
- Input root: `classified-data`
- Output root: `alloy4fun-augmented`
- Source Alloy files: 6601
- Thread count: 32

- Reward pool size: 1000

## Corpus

- Question groups: 71
- Parsed models: 6601
- Parse failures: 0
- CORRECT models: 1774
- Incorrect models: 4827
- Oracle references: 71
- AST-unique CORRECT student references: 721
- Incorrect models with rankings: 4827
- Incorrect models without references: 0

- Reward successes: 4827
- Reward failures: 0
- Average candidate reward: 0.277283
- Average reward error `(1 - reward)`: 0.722717

## Ranking Pools

| Mode | Groups | Incorrect predicates | Min refs | Max refs |
| --- | ---: | ---: | ---: | ---: |
| oracle+correct-student | 64 | 4552 | 2 | 28 |
| oracle-only | 7 | 275 | 1 | 1 |

## Nearest Distance Averages

| Slice | Count | Levenshtein | Raw AST | Canonical |
| --- | ---: | ---: | ---: | ---: |
| All incorrect | 4827 | 32.591672 | 16.158898 | 18.859126 |
| BOTH | 3023 | 35.336421 | 17.737016 | 21.769104 |
| OVERCONSTRAINED | 1062 | 28.839925 | 13.491525 | 13.521657 |
| UNDERCONSTRAINED | 742 | 26.778976 | 13.547170 | 14.642857 |

## Relative Distance Averages

| Slice | Count | Levenshtein / body chars | Raw AST / AST size | Canonical / canonical size |
| --- | ---: | ---: | ---: | ---: |
| All incorrect | 4827 | 0.430827 | 0.689450 | 0.734974 |
| BOTH | 3023 | 0.421308 | 0.683290 | 0.758105 |
| OVERCONSTRAINED | 1062 | 0.514430 | 0.729348 | 0.717302 |
| UNDERCONSTRAINED | 742 | 0.349950 | 0.657443 | 0.666032 |

## Reward Error Correlations

- Rewarded incorrect predicates: 4827

| Metric | Pearson distance vs raw `1 - reward` | Pearson distance vs `log10(1 - reward)` | Pearson relative distance vs raw `1 - reward` | Pearson relative distance vs `log10(1 - reward)` |
| --- | ---: | ---: | ---: | ---: |
| Levenshtein | 0.025151 | 0.095231 | 0.029092 | 0.050666 |
| Raw AST | 0.012220 | 0.080731 | 0.021884 | 0.037653 |
| Canonical | 0.092885 | 0.129623 | 0.043033 | 0.058045 |

- Raw plot: `canonical_distance_vs_reward_error_raw.svg`
- Log plot: `canonical_distance_vs_reward_error_log.svg`
- CSV: `canonical_reward_points.csv`

## By Question Set

| Question set | Groups | CORRECT | Incorrect | References | Ranked incorrect | Oracle-only groups |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| classroom_fol | 15 | 536 | 1504 | 232 | 1504 | 0 |
| classroom_rl | 15 | 536 | 1504 | 232 | 1504 | 0 |
| cv_v1 | 3 | 69 | 241 | 34 | 241 | 0 |
| cv_v2 | 3 | 34 | 73 | 25 | 73 | 0 |
| lts | 6 | 112 | 317 | 45 | 317 | 2 |
| production | 2 | 45 | 83 | 17 | 83 | 0 |
| train | 17 | 102 | 625 | 68 | 625 | 5 |
| trash_rl | 10 | 340 | 480 | 139 | 480 | 0 |
