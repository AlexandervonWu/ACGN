# Synthetic Typed/Untyped Representation Runtime

- Run: `e3d9bc4e-a514-471b-9e01-162562663f2e`
- Complete schedule: `True`
- Deadline: 300 seconds per predicate per arm.
- Child heap: 768m; concurrent isolated JVMs: 8.
- Permutation, symmetry, alpha-pass, rewrite-pass, term-size and rebuild caps: disabled in this synthetic path.
- Success means completed representation construction, not semantic equivalence or repair correctness.
- Runtime includes JVM startup, parsing, construction and output; engine excludes parsing/startup but includes adaptation.
- Median/P95 use successes only; P95 is nearest rank. Failures and unfinished trials remain in the rate denominator.
- These independent-success statistics may have survivorship bias; compare the matched subset too.

## All Selected Predicates

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 540 | 442 | 81.85% | 0.849457 | 43.728568 | 0.670026 | 43.589611 |
| typed | 540 | 530 | 98.15% | 0.166054 | 2.365375 | 0.026477 | 1.776174 |

## Failure Statuses

- untyped: `{"SUCCESS": 442, "TIMEOUT": 98}`
- typed: `{"SUCCESS": 530, "TIMEOUT": 10}`

## Matched Successful Predicates

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 442 | 442 | 100.00% | 0.849457 | 43.728568 | 0.670026 | 43.589611 |
| typed | 442 | 442 | 100.00% | 0.166021 | 1.965836 | 0.025169 | 1.071005 |

## By Family

### alpha

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.784655 | 29.815247 | 0.635467 | 29.672560 |
| typed | 108 | 106 | 98.15% | 0.165917 | 1.866174 | 0.024755 | 1.710088 |

### boolean_aci

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 90 | 83.33% | 0.802954 | 31.726488 | 0.653205 | 31.574457 |
| typed | 108 | 106 | 98.15% | 0.165953 | 1.965836 | 0.025057 | 1.649989 |

### future_temporal

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.966609 | 43.047849 | 0.780926 | 42.902293 |
| typed | 108 | 106 | 98.15% | 0.166299 | 2.403043 | 0.026814 | 2.238495 |

### implication

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.803423 | 41.879113 | 0.658355 | 41.728670 |
| typed | 108 | 106 | 98.15% | 0.166045 | 1.966790 | 0.024641 | 1.829764 |

### past_temporal

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.966771 | 54.532100 | 0.832682 | 54.353757 |
| typed | 108 | 106 | 98.15% | 0.166083 | 2.966678 | 0.029923 | 2.826762 |

## By Binding Count

### 2

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 20 | 20 | 100.00% | 0.165660 | 1.601236 | 0.012695 | 0.016232 |
| typed | 20 | 20 | 100.00% | 0.165691 | 1.564485 | 0.015738 | 0.018756 |

### 3

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 30 | 30 | 100.00% | 0.165954 | 1.416019 | 0.015245 | 0.019062 |
| typed | 30 | 30 | 100.00% | 0.165868 | 1.401322 | 0.016947 | 0.020733 |

### 4

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 40 | 40 | 100.00% | 0.165741 | 0.166333 | 0.023036 | 0.032170 |
| typed | 40 | 40 | 100.00% | 0.165711 | 0.166428 | 0.018378 | 0.028285 |

### 5

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 50 | 50 | 100.00% | 0.201319 | 0.208385 | 0.044079 | 0.072456 |
| typed | 50 | 50 | 100.00% | 0.165633 | 0.202468 | 0.021324 | 0.054647 |

### 6

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 60 | 60 | 100.00% | 0.366122 | 0.516781 | 0.198930 | 0.275947 |
| typed | 60 | 60 | 100.00% | 0.166118 | 0.417816 | 0.024461 | 0.243609 |

### 7

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 70 | 70 | 100.00% | 0.866102 | 1.116316 | 0.720236 | 0.935109 |
| typed | 70 | 70 | 100.00% | 0.166256 | 0.966296 | 0.026771 | 0.794429 |

### 8

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 80 | 80 | 100.00% | 3.985167 | 5.968021 | 3.688415 | 5.796398 |
| typed | 80 | 80 | 100.00% | 0.166272 | 4.717277 | 0.031038 | 4.590353 |

### 9

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 90 | 90 | 100.00% | 36.504852 | 54.532100 | 36.352508 | 54.353757 |
| typed | 90 | 90 | 100.00% | 0.166636 | 44.481089 | 0.033166 | 44.323368 |

### 10

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 100 | 2 | 2.00% | 265.281682 | 266.750753 | 265.144933 | 266.628920 |
| typed | 100 | 90 | 90.00% | 0.166478 | 2.365375 | 0.033769 | 2.238495 |
