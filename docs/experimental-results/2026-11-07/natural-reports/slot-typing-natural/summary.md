# Untyped Versus Typed Slots

- Run: `72ae4fba-0a46-4fb9-9260-28929ab11be6`
- Source: `3ef7d93bcab87ecd30ffba4c02e01c690981a137`; dirty: false
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Workers: 16; heap: 8g; file limit: 0 (0 means full corpus)

Same raw ASTs, scope handling, variadic rewrite rules, permutation bounds and distance algorithm. The treatment preserves exact parser-derived variable type colors in slot identity and mappings. Declaration domains remain in both arms. Neither arm is certificate-bearing.

| Arm | Successful | Skipped AST-identical | Failures | Zero distance | Avg distance | Wall s | Engine CPU s | Peak heap MiB | Max RSS MiB | Avg eclasses | Avg enodes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| slotted-egraph | 61598 | 4482 | 0 | 2228 | 16.324 | 20.160 | 18.210 | 962.976 | 1776.691 | 31.844 | 34.311 |
| slotted-egraph-typed | 61598 | 4482 | 0 | 2228 | 16.421 | 19.560 | 10.391 | 969.297 | 1796.422 | 32.771 | 35.238 |

## Slot Census

Successful AST-distinct pairs only; both source predicates are counted separately. Source slots count binding occurrences (parameters, quantifiers/comprehensions, and lets), including unused and shadowed bindings, not repeated usages. Callee bodies are not expanded. Exact parser type strings are labels local to source models, not globally identical signatures. Interface slots sum live e-class interface arities; one source binding can occur in many interfaces. Untyped interface colors are reported as `<erased>`, never as `univ`.

| Arm | Counted pairs | Student slots | Oracle slots | Total source slots | Total interface slots | Adapter CPU s | Comparison CPU s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| slotted-egraph | 61598 | 106382 | 63730 | 170112 | 1549823 | 0.262 | 17.910 |
| slotted-egraph-typed | 61598 | 106382 | 63730 | 170112 | 1619994 | 0.881 | 9.471 |

### slotted-egraph Slots Per Type

| Exact type label | Source bindings (both predicates) | Interface slots |
| --- | ---: | ---: |
| `<erased>` | 0 | 1549823 |
| `EMPTY_RELATION[arity=1]` | 91 | 0 |
| `EMPTY_RELATION[arity=2]` | 3 | 0 |
| `RELATION[10:Influencer]` | 5434 | 0 |
| `RELATION[11:Institution]` | 28 | 0 |
| `RELATION[11:Institution][4:User]` | 3 | 0 |
| `RELATION[11:Workstation]` | 5602 | 0 |
| `RELATION[2:Ad]` | 2829 | 0 |
| `RELATION[2:Id]` | 92 | 0 |
| `RELATION[3:Day]` | 1670 | 0 |
| `RELATION[4:File]` | 10002 | 0 |
| `RELATION[4:Node]` | 3423 | 0 |
| `RELATION[4:User]` | 28971 | 0 |
| `RELATION[4:Work2:Id]` | 1 | 0 |
| `RELATION[4:Work4:Work4:Work6:Source]` | 1 | 0 |
| `RELATION[4:Work]` | 2493 | 0 |
| `RELATION[4:univ]` | 977 | 0 |
| `RELATION[5:Class6:Person]` | 3 | 0 |
| `RELATION[5:Class]` | 7518 | 0 |
| `RELATION[5:Event5:State]` | 7 | 0 |
| `RELATION[5:Event]` | 1503 | 0 |
| `RELATION[5:Grade]` | 1388 | 0 |
| `RELATION[5:Group]` | 1807 | 0 |
| `RELATION[5:Human]` | 214 | 0 |
| `RELATION[5:Human][5:Robot]` | 3 | 0 |
| `RELATION[5:Photo]` | 6740 | 0 |
| `RELATION[5:Robot]` | 170 | 0 |
| `RELATION[5:Speed]` | 210 | 0 |
| `RELATION[5:State5:Event]` | 13 | 0 |
| `RELATION[5:State5:State]` | 789 | 0 |
| `RELATION[5:State]` | 5288 | 0 |
| `RELATION[5:Track]` | 14213 | 0 |
| `RELATION[5:Train]` | 954 | 0 |
| `RELATION[6:Course]` | 11851 | 0 |
| `RELATION[6:Person5:Class]` | 3 | 0 |
| `RELATION[6:Person]` | 32354 | 0 |
| `RELATION[6:Signal]` | 1199 | 0 |
| `RELATION[6:Source]` | 77 | 0 |
| `RELATION[6:Worker]` | 1512 | 0 |
| `RELATION[7:Product]` | 1388 | 0 |
| `RELATION[7:Project]` | 11702 | 0 |
| `RELATION[8:Junction]` | 21 | 0 |
| `RELATION[8:Material]` | 817 | 0 |
| `RELATION[8:Position]` | 42 | 0 |
| `RELATION[9:Component7:Product]` | 1 | 0 |
| `RELATION[9:Component]` | 6180 | 0 |
| `RELATION[9:Semaphore]` | 525 | 0 |

### slotted-egraph-typed Slots Per Type

| Exact type label | Source bindings (both predicates) | Interface slots |
| --- | ---: | ---: |
| `EMPTY_RELATION[arity=1]` | 91 | 658 |
| `EMPTY_RELATION[arity=2]` | 3 | 12 |
| `RELATION[10:Influencer]` | 5434 | 36797 |
| `RELATION[11:Institution]` | 28 | 193 |
| `RELATION[11:Institution][4:User]` | 3 | 24 |
| `RELATION[11:Workstation]` | 5602 | 45997 |
| `RELATION[2:Ad]` | 2829 | 24313 |
| `RELATION[2:Id]` | 92 | 533 |
| `RELATION[3:Day]` | 1670 | 10528 |
| `RELATION[4:File]` | 10002 | 67976 |
| `RELATION[4:Node]` | 3423 | 25038 |
| `RELATION[4:User]` | 28971 | 324786 |
| `RELATION[4:Work2:Id]` | 1 | 4 |
| `RELATION[4:Work4:Work4:Work6:Source]` | 1 | 1 |
| `RELATION[4:Work]` | 2493 | 25348 |
| `RELATION[4:univ]` | 977 | 14180 |
| `RELATION[5:Class6:Person]` | 3 | 12 |
| `RELATION[5:Class]` | 7518 | 88152 |
| `RELATION[5:Event5:State]` | 7 | 28 |
| `RELATION[5:Event]` | 1503 | 9871 |
| `RELATION[5:Grade]` | 1388 | 15588 |
| `RELATION[5:Group]` | 1807 | 20849 |
| `RELATION[5:Human]` | 214 | 1830 |
| `RELATION[5:Human][5:Robot]` | 3 | 24 |
| `RELATION[5:Photo]` | 6740 | 60626 |
| `RELATION[5:Robot]` | 170 | 1428 |
| `RELATION[5:Speed]` | 210 | 1022 |
| `RELATION[5:State5:Event]` | 13 | 52 |
| `RELATION[5:State5:State]` | 789 | 4955 |
| `RELATION[5:State]` | 5288 | 31887 |
| `RELATION[5:Track]` | 14213 | 146453 |
| `RELATION[5:Train]` | 954 | 16349 |
| `RELATION[6:Course]` | 11851 | 126286 |
| `RELATION[6:Person5:Class]` | 3 | 12 |
| `RELATION[6:Person]` | 32354 | 341237 |
| `RELATION[6:Signal]` | 1199 | 8026 |
| `RELATION[6:Source]` | 77 | 785 |
| `RELATION[6:Worker]` | 1512 | 10445 |
| `RELATION[7:Product]` | 1388 | 11804 |
| `RELATION[7:Project]` | 11702 | 85151 |
| `RELATION[8:Junction]` | 21 | 152 |
| `RELATION[8:Material]` | 817 | 4035 |
| `RELATION[8:Position]` | 42 | 468 |
| `RELATION[9:Component7:Product]` | 1 | 4 |
| `RELATION[9:Component]` | 6180 | 52387 |
| `RELATION[9:Semaphore]` | 525 | 3688 |

Source census runs outside engine timing; comparison CPU includes graph construction, rewriting, matching, and structural statistics. Adapter/comparison CPU are nested components of engine CPU, not additional totals. Per-pair counts are in each arm's pairs.csv; problem/status aggregates are in summary.json. Older runs without observations are unavailable.

- Retained zeroes: 2228
- Newly zero: 0
- No longer zero: 0

Single runs are not stable performance estimates. Zero distance here is an engine result, not an independently checked semantic certificate. Fresh JVM process time/RSS include parsing; engine CPU excludes parsing. Exact type equality does not implement subtype exchange.

```sh
./scripts/run_egraph_ablation.sh --slot-typing --input /home/augustus/ACGN/classified-data --output /media/augustus/8618-0ED0/ACGN/intermediate/full-corpus-8g-20261107T062202Z/artifacts/slot-typing-natural --threads 16 --max-heap 8g --limit 0
```
