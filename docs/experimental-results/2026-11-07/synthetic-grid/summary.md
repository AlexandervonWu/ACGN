# Synthetic Typed/Untyped Representation Runtime

- Run: `232dea4d-0814-4c6e-8a1d-7e00eed953fd`
- Complete schedule: `True`
- Deadline: 300.0 seconds per predicate per arm.
- Child heap: 768m; concurrent isolated JVMs: 8.
- Permutation, symmetry, alpha-pass, rewrite-pass, term-size and rebuild caps: disabled in this synthetic path.
- Success means completed representation construction, not semantic equivalence or repair correctness.
- Runtime includes JVM startup, parsing, construction and output; engine excludes parsing/startup but includes adaptation.
- Median/P95 use successes only; P95 is nearest rank. Failures and unfinished trials remain in the rate denominator.
- These independent-success statistics may have survivorship bias; compare the matched subset too.

## All Selected Predicates

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 540 | 443 | 82.04% | 0.800978 | 44.647240 | 0.671134 | 44.440920 |
| typed | 540 | 530 | 98.15% | 0.164246 | 1.965355 | 0.026833 | 1.803044 |

## Failure Statuses

- untyped: `{"SUCCESS": 443, "TIMEOUT": 97}`
- typed: `{"SUCCESS": 530, "TIMEOUT": 10}`

## Matched Successful Predicates

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 443 | 443 | 100.00% | 0.800978 | 44.647240 | 0.671134 | 44.440920 |
| typed | 443 | 443 | 100.00% | 0.164231 | 1.114538 | 0.025220 | 0.923250 |

## By Family

### alpha

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 89 | 82.41% | 0.765012 | 30.324855 | 0.625753 | 30.185355 |
| typed | 108 | 106 | 98.15% | 0.164216 | 1.965355 | 0.024098 | 1.803044 |

### boolean_aci

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 90 | 83.33% | 0.800776 | 31.575976 | 0.652452 | 31.402876 |
| typed | 108 | 106 | 98.15% | 0.164262 | 1.864658 | 0.024283 | 1.702251 |

### future_temporal

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.914729 | 43.529116 | 0.771882 | 43.338640 |
| typed | 108 | 106 | 98.15% | 0.164256 | 2.201112 | 0.027025 | 2.081888 |

### implication

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 0.800818 | 41.929281 | 0.665075 | 41.744938 |
| typed | 108 | 106 | 98.15% | 0.164188 | 1.801251 | 0.026707 | 1.653356 |

### past_temporal

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 108 | 88 | 81.48% | 1.000779 | 54.583988 | 0.846596 | 54.416835 |
| typed | 108 | 106 | 98.15% | 0.164285 | 3.032961 | 0.031598 | 2.883988 |

## By Binding Count

### 2

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 20 | 20 | 100.00% | 0.164163 | 0.164394 | 0.012305 | 0.016065 |
| typed | 20 | 20 | 100.00% | 0.164038 | 0.164487 | 0.015680 | 0.018913 |

### 3

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 30 | 30 | 100.00% | 0.164127 | 0.201141 | 0.016043 | 0.022147 |
| typed | 30 | 30 | 100.00% | 0.164111 | 0.201288 | 0.017890 | 0.023357 |

### 4

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 40 | 40 | 100.00% | 0.164117 | 0.200904 | 0.023301 | 0.032331 |
| typed | 40 | 40 | 100.00% | 0.164154 | 0.164418 | 0.020023 | 0.029456 |

### 5

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 50 | 50 | 100.00% | 0.200659 | 0.215919 | 0.044126 | 0.078534 |
| typed | 50 | 50 | 100.00% | 0.164080 | 0.200925 | 0.020588 | 0.056477 |

### 6

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 60 | 60 | 100.00% | 0.364244 | 0.432047 | 0.199600 | 0.280818 |
| typed | 60 | 60 | 100.00% | 0.164199 | 0.364340 | 0.025036 | 0.236690 |

### 7

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 70 | 70 | 100.00% | 0.914482 | 1.114552 | 0.752011 | 0.947731 |
| typed | 70 | 70 | 100.00% | 0.164371 | 0.964385 | 0.028614 | 0.809989 |

### 8

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 80 | 80 | 100.00% | 4.133779 | 5.915765 | 3.979007 | 5.753182 |
| typed | 80 | 80 | 100.00% | 0.164461 | 4.633558 | 0.031097 | 4.500382 |

### 9

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 90 | 90 | 100.00% | 36.776180 | 54.583988 | 36.616677 | 54.416835 |
| typed | 90 | 90 | 100.00% | 0.200664 | 44.728866 | 0.034656 | 44.574124 |

### 10

| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| untyped | 100 | 3 | 3.00% | 288.902202 | 299.909507 | 288.759348 | 299.780746 |
| typed | 100 | 90 | 90.00% | 0.164458 | 2.201112 | 0.033463 | 2.081888 |
