# Synthetic Typed/Untyped Representation Runtime

- Run: `be876171-dabb-4f9f-aff5-9fbea07780fb`
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
| untyped | 540 | 442 | 81.85% | 0.863890 | 43.128686 | 0.695001 | 42.953144 |
| typed | 540 | 530 | 98.15% | 0.200285 | 1.914487 | 0.029615 | 1.709621 |

## Failure Statuses

- untyped: `{"SUCCESS": 442, "TIMEOUT": 98}`
- typed: `{"SUCCESS": 530, "TIMEOUT": 10}`

## Matched Successful Predicates

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 442 | 442 | 100.00% | 0.863890 | 43.128686 | 0.695001 | 42.953144 |
| typed | 442 | 442 | 100.00% | 0.200247 | 1.164194 | 0.028007 | 0.994504 |

## By Family

### alpha

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.800663 | 29.410177 | 0.650189 | 29.211785 |
| typed | 108 | 106 | 98.15% | 0.200227 | 1.803987 | 0.027281 | 1.668591 |

### boolean_aci

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 90 | 83.33% | 0.863827 | 30.873979 | 0.682021 | 30.711987 |
| typed | 108 | 106 | 98.15% | 0.200246 | 1.864554 | 0.027079 | 1.701453 |

### future_temporal

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.982359 | 42.278371 | 0.822346 | 42.147684 |
| typed | 108 | 106 | 98.15% | 0.200311 | 2.364441 | 0.030786 | 2.183929 |

### implication

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.823868 | 40.728536 | 0.675963 | 40.563305 |
| typed | 108 | 106 | 98.15% | 0.200290 | 1.764370 | 0.029860 | 1.601864 |

### past_temporal

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 1.048190 | 53.422600 | 0.883297 | 53.273658 |
| typed | 108 | 106 | 98.15% | 0.200308 | 3.016697 | 0.033215 | 2.869283 |

## By Binding Count

### 2

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 20 | 20 | 100.00% | 0.163762 | 0.165955 | 0.013976 | 0.017061 |
| typed | 20 | 20 | 100.00% | 0.163845 | 0.164329 | 0.016600 | 0.021555 |

### 3

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 30 | 30 | 100.00% | 0.163802 | 0.200431 | 0.016960 | 0.020637 |
| typed | 30 | 30 | 100.00% | 0.163755 | 0.200224 | 0.019531 | 0.025898 |

### 4

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 40 | 40 | 100.00% | 0.163873 | 0.200413 | 0.026002 | 0.031544 |
| typed | 40 | 40 | 100.00% | 0.163809 | 0.200378 | 0.021198 | 0.030801 |

### 5

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 50 | 50 | 100.00% | 0.200368 | 0.215729 | 0.048774 | 0.073065 |
| typed | 50 | 50 | 100.00% | 0.163869 | 0.207678 | 0.024429 | 0.065807 |

### 6

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 60 | 60 | 100.00% | 0.363899 | 0.431945 | 0.207367 | 0.286831 |
| typed | 60 | 60 | 100.00% | 0.163961 | 0.403560 | 0.025549 | 0.255758 |

### 7

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 70 | 70 | 100.00% | 0.963961 | 1.164271 | 0.777860 | 0.984206 |
| typed | 70 | 70 | 100.00% | 0.200379 | 1.001051 | 0.030850 | 0.841266 |

### 8

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 80 | 80 | 100.00% | 3.890133 | 6.002614 | 3.733727 | 5.820890 |
| typed | 80 | 80 | 100.00% | 0.200458 | 4.915233 | 0.034193 | 4.715454 |

### 9

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 90 | 90 | 100.00% | 35.776984 | 53.422600 | 35.603596 | 53.273658 |
| typed | 90 | 90 | 100.00% | 0.200411 | 44.446581 | 0.034797 | 44.296880 |

### 10

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 100 | 2 | 2.00% | 264.700827 | 267.864649 | 264.526711 | 267.686097 |
| typed | 100 | 90 | 90.00% | 0.200412 | 2.364441 | 0.037997 | 2.183929 |
