# Fast Rewrite and Certificate-Integrated Equality Disagreements

This note characterizes the current disagreement between the Fast Rewrite IR
and Certificate-Integrated IR and retains the preceding false-zero incident as
historical evidence. Current measurements are tied to publication run
`df4d8d4c-6265-4fe7-88d5-3aceee60398b` and natural-corpus ablation run
`f46b5647-7373-4cd7-ac3d-f8fd9b802db6`.

The two measurements use different populations:

- The ablation compares each AST-distinct student predicate with the paired
  oracle predicate in the same Alloy file. Among the 19,212 `CORRECT` pairs,
  Fast Rewrite reports 4,074 zeroes and Certificate-Integrated reports 4,088.
  The latter adds 14 and loses none on this paired population.
- The augmenter compares each of 42,386 incorrect predicates with every
  AST-distinct truth available for that question, including the oracle and
  AST-unique correct student predicates. Both Fast Rewrite and
  Certificate-Integrated now have zero incorrect nearest-truth zeroes.

Consequently, the current observed Fast Rewrite zero set is contained in the
Certificate-Integrated zero set on paired-oracle rows, and neither path admits
an incorrect zero in the larger nearest-truth experiment. These are empirical
claims over the evaluated populations, not a global containment theorem.

## Meaning of Zero

For the `canonical` arm, zero is the zero kernel of the Fast Rewrite repair
metric over its normalized `NormalForm`. For the
`typed-slotted-port-egraph` arm, zero must also agree with equality of the
Certificate-Integrated canonical observation. The latter retains typed port,
container-law, field-owner, binder-scope, temporal-import, and provenance
information and fails closed when the repair projection and exact observation
disagree.

This distinction matters epistemically. A Fast Rewrite zero is a metric result,
not a semantic certificate. Conversely, a positive Certificate-Integrated
distance is a refusal to certify equality, not a proof of semantic inequality.
The corpus labels and source-level Alloy witnesses provide the independent
evidence used below to classify these particular disagreements.

## Fourteen Certificate-Integrated-Only Paired Zeroes

All 14 rows are labeled `CORRECT`. They divide into three normalization
families.

| Family | Count | Certificate-Integrated reason |
| --- | ---: | --- |
| Set ACI/idempotence after recursive normalization | 10 | Operands that become equal only after quantifier, implication, De Morgan, or membership normalization are deduplicated in the certified `Set` quotient. |
| Typed associative JOIN chain | 3 | Parenthesization is erased only after the dependent chain proves every adjacent relational boundary; operand order remains in a `Seq`. |
| Certified binder alpha-equivalence | 1 | Local comprehension binders are compared through typed binder descriptors and occurrence provenance, independent of source spelling. |

The complete rows and measured distances are:

| Family | Paired source | Fast Rewrite | Certificate-Integrated |
| --- | --- | ---: | ---: |
| Set ACI | `classroom_rl/correct/JciokBgXnkPdk9czg_inv2.als` | 5 | 0 |
| Set ACI | `classroom_rl/correct/p4JYisEfRMFCepECC_inv2.als` | 5 | 0 |
| JOIN | `coursesOld/correct/smfDkm59tx3cQ7YQm_inv11.als` | 4 | 0 |
| JOIN | `lts/correct/25aYiS9MBG72qzTtk_inv6.als` | 4 | 0 |
| JOIN | `lts/correct/GTGqqEHPniMaebYx2_inv5.als` | 8 | 0 |
| Binder alpha | `lts/correct/viZeRLo7kTSfXQ6zE_inv4.als` | 5 | 0 |
| Set ACI | `productionLineNew/correct/EmXPfAqaT6gPytThg_inv5.als` | 29 | 0 |
| Set ACI | `productionLine_v2/correct/BfhJLg4KcEzuaj6Qj_inv5.als` | 29 | 0 |
| Set ACI | `trash_fol/correct/WCR5D69gK742b7gav_inv1.als` | 5 | 0 |
| Set ACI | `trash_ltl/correct/cRMZnYefJc4Wc7znp_inv1.als` | 4 | 0 |
| Set ACI | `trash_rl/correct/EaFXvGDyn4yrKr2xg_inv4.als` | 10 | 0 |
| Set ACI | `trash_rl/correct/LDsh3QputAuFYAwk7_inv7.als` | 14 | 0 |
| Set ACI | `trash_rl/correct/N7r5bmzP3cquMsFou_inv4.als` | 10 | 0 |
| Set ACI | `trash_rl/correct/b3LQRvSN97bZcbchu_inv1.als` | 5 | 0 |

Representative Set cases normalize to a duplicate such as:

```alloy
(no Teacher) and (no Teacher)
```

versus `no Teacher`. The source duplication is often less obvious: one
conjunct can begin as `all p: Person | p not in Teacher`, or as one direction
of a mutual-exclusion implication. Recursive certified normalization first
establishes operand equality; ACI idempotence then removes the duplicate. Fast
Rewrite retains two matrix occurrences in these rows and charges for deleting
one.

The JOIN cases compare forms such as:

```alloy
c.(grades.Grade)
(c.grades).Grade
```

The certified representation flattens both to the same ordered JOIN `Seq` only
after checking the dependent endpoint chain. This is associativity, not
commutativity: changing operand order remains observable.

The binder case uses `{x, y: State | ...}` versus
`{s1, s2: State | ...}`. Its zero follows from one coherent, typed alpha
renaming of the local binder and its occurrences, not from deleting variable
identity.

These 14 rows are completeness gains: Certificate-Integrated equality admits
sound quotient steps that the Fast Rewrite representative and metric do not
fully expose as zero on these inputs.

## Historical Ten Fast-Rewrite-Only Incorrect Nearest-Truth Zeroes

This section records the defect exposed by the preceding clean snapshot,
publication run `57f5a2d8-f501-494d-81d5-b3f1396dbe18`. It is retained as an
incident analysis; these rows are no longer zero under Fast Rewrite in the
current snapshot.

All ten rows are labeled `BOTH`. For each row, both metrics select the same
correct reference, so the disagreement is not an artifact of different
nearest-neighbor choices.

| Cause | Incorrect predicate | Selected truth | Fast Rewrite | Certificate-Integrated |
| --- | --- | --- | ---: | ---: |
| Field-owner loss | `coursesNew/both/xT7fmCyXRAv38zbG7_inv4.als` | `coursesNew/correct/2ahzaJ9AgN9ukD4kt_inv4.als` | 0 | 2 |
| Field-owner loss | `coursesOld/both/4eqsRijCmEQSkCdnn_inv5.als` | `coursesOld/correct/5pcZ6C6yzCZ34zXZM_inv5.als` | 0 | 2 |
| Field-owner loss | `coursesOld/both/4oGQ9xsb3Yt7nnNR6_inv4.als` | `coursesOld/correct/3j9uZWDLpybLZAJLC_inv4.als` | 0 | 3 |
| Field-owner loss | `coursesOld/both/BRxDwiXZRDSqWwaMH_inv5.als` | `coursesOld/correct/5pcZ6C6yzCZ34zXZM_inv5.als` | 0 | 2 |
| Field-owner loss | `coursesOld/both/DzLsxBgpZviTAEpEC_inv5.als` | `coursesOld/correct/ofcoPS2MrsRG5js2r_inv5.als` | 0 | 2 |
| Field-owner loss | `coursesOld/both/EtFytpSuzQ9wqXt9k_inv5.als` | `coursesOld/correct/a2cEgE7g3SAFJhHML_inv5.als` | 0 | 3 |
| Field-owner loss | `coursesOld/both/bHZCYFmX7iTCqHoKw_inv5.als` | `coursesOld/correct/GDANXupGbwonf47iX_inv5.als` | 0 | 3 |
| Field-owner loss | `coursesOld/both/fLctzhA9H7EWbYyzS_inv5.als` | `coursesOld/correct/GDANXupGbwonf47iX_inv5.als` | 0 | 3 |
| Field-owner loss | `coursesOld/both/tHdp2ZvFNwyuQjxRc_inv5.als` | `coursesOld/correct/a2cEgE7g3SAFJhHML_inv5.als` | 0 | 3 |
| Temporal binder incoherence | `trash_ltl/both/7GaRScrfGLJtSRDo9_inv8.als` | `trash_ltl/correct/89pzjDpv7Srmd4ntF_inv8.als` | 0 | 1 |

### Overloaded Field Ownership

The nine courses rows all reduce to one underlying information-loss family.
Both `Person` and `Course` declare an independent field named `projects`:

```alloy
sig Person { projects: set Project }
sig Course { projects: set Project }
```

The smallest witness is:

```alloy
all p: Project | #((Person <: projects).p) = 1
all p: Project | #((Course <: projects).p) = 1
```

These formulas constrain different relations. The Fast Rewrite normal form
retained each field's exact relation type, including its declaring owner, but
the distance comparator projected both atoms to the unqualified payload
`projects`. The comparator therefore ignored information already present in
the IR. Other rows exhibit the same defect through transpose or existential
coverage, for example
`p.~(Person <: projects)` versus `p.~(Course <: projects)`.

The Certificate-Integrated path retains the parser-resolved field declaration,
its exact relational type, and the domain-restriction carrier. Its observations
remain different, so the zero-kernel guard refuses the Fast Rewrite merge and
the repair metric reports distance 2 or 3. Adding an equality rewrite here
would be unsound; preserving qualified field identity is the required action.

### Temporal Binder Coherence

The remaining row differs at the endpoint carried into `eventually`:

```alloy
always all f, f2: File |
  f->f2 in link implies eventually f2 in Trash

always all f1, f2: File |
  f1->f2 in link implies eventually f1 in Trash
```

The relation antecedent is directional, so replacing the target `f2` with the
source `f1` is not alpha-equivalence. Fast Rewrite's phase-separated comparison
can choose a same-typed variable alignment for the `eventually` phase that is
not the same whole-binder mapping used by the enclosing phase. That locally
maps the two leaves together without consistently swapping the directional
antecedent.

Certificate-Integrated temporal imports retain the owner coordinate through
`(source lineage, phase path, binder context)`. A legal alpha alignment must be
one coherent binder automorphism across the enclosing and inherited temporal
occurrences. The endpoint mismatch therefore costs one edit rather than zero.

## Current Full-Corpus Closure

The source repairs were exercised by the complete four-stage run rather than
only by focused witnesses. The nine field-owner rows now have nearest Fast
Rewrite distance 1; their Certificate-Integrated distances remain 2 or 3. The
temporal endpoint row has distance 1 under both paths. Both metrics select the
same truth references shown above.

| Historical family | Rows | Historical Fast zeroes | Current Fast zeroes | Current certified zeroes |
| --- | ---: | ---: | ---: | ---: |
| Field-owner loss | 9 | 9 | 0 | 0 |
| Temporal binder incoherence | 1 | 1 | 0 | 0 |
| **Total** | **10** | **10** | **0** | **0** |

The current augmenter reports 42,386 ranked and rewarded incorrect predicates,
zero preparation/ranking/reward failures, zero Fast Rewrite nearest-truth
zeroes, and zero Certificate-Integrated nearest-truth zeroes. The natural
paired-oracle ablation still reports the 14 certificate-only `CORRECT` zeroes
and no Fast-only zeroes.

## Interpretation

The two directions reveal different properties of the implementations:

1. The 14 certified-only paired zeroes show additional completeness from
   certified recursive quotienting, dependent JOIN associativity, and scoped
   alpha-equivalence.
2. The historical ten Fast-only nearest-truth zeroes exposed two places where
   the Fast comparator admitted too much: nine owner-erasing field projections
   and one phase-incoherent variable alignment. Both are repaired in the
   current run.
3. Certificate integration is not merely a stricter version of the same
   representative. It can recognize more equality where evidence exists and
   reject equality where the fast projection discarded evidence needed to
   justify it.
4. The reported corpus labels are bounded empirical evidence. The ordinary
   corpus arm performs in-process certificate-integrated construction and
   observation; this table should not be described as standalone replay of an
   exported proof for every row.

The 14 additions and historical ten refusals are compatible. On the paired
`CORRECT` population, Certificate-Integrated equality remains more complete.
The owner and temporal-scope evidence that originally let the certificate path
refuse ten unsupported Fast zeroes has now been ported into the Fast
comparator, so the current nearest-truth experiment has no disagreement at
zero.

## Implemented Repair

The current source repairs both Fast Rewrite defects without modifying the
Certificate-Integrated pathway:

1. A parser field atom without an explicit semantic identity is compared by
   the pair `(source name, exact Alloy relation type)`. Readable spelling is
   still used only in edit rendering. This preserves same-owner alpha cases
   while distinguishing `Person.projects` from `Course.projects`.
2. A quantified slot used in more than one temporal normal form participates
   in one jointly minimized alpha mapping across those phases. Other slots in
   each phase retain the established phase-local exact minimization. A legal
   whole-block permutation therefore remains zero, while independently
   remapping the inherited endpoint costs one.

All nine archived field-owner witnesses now have Fast Rewrite distance 1. The
archived temporal witness also has Fast Rewrite distance 1. Their
Certificate-Integrated distances remain, respectively, 2 or 3 and 1, and all
observations remain unequal. Source-level positive controls retain zero for a
same-owner field alpha rename, a coherent temporal alpha rename, and a
coherent whole-block temporal permutation.

The 14 Certificate-Integrated-only paired zeroes were replayed after the
repair. Their Fast Rewrite distances are unchanged and their certified
distances and digests remain zero/equal. The full-corpus run confirms that this
patch narrows only the two unsupported Fast Rewrite alignments; it does not
remove the certified completeness gains described above.

## Reproduction Queries

The paired disagreements and their distances are recorded in
`egraph_ablation/equivalence_disagreements.csv` and
`egraph_ablation/minimum_distances.csv`:

```bash
awk -F, 'NR == 1 || ($8 == "false" && $9 == "true")' \
  egraph_ablation/equivalence_disagreements.csv
awk -F, 'NR == 1 || ($8 != 0 && $9 == 0)' \
  egraph_ablation/minimum_distances.csv
```

The current query for a Fast-only incorrect nearest-truth zero returns no rows:

```bash
jq '.incorrectNearest[] |
    select(.nearestLegacyCanonical.distance == 0 and
           .nearestCanonical.distance > 0)' \
  alloy4fun-augmented/index.json
```

The historical ten paths and their minimized current distances remain listed
in this document so the repair can be audited without relying on a stale result
tree.
