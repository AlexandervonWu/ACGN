# Cross-Pool Zero-Distance Incident

## Status

`REPAIRED / FULL PUBLICATION REPLAY PASSED`.

The clean run rooted at
`/home/augustus/acgn-publication-20260827T163127Z` completed every scheduled
stage, but it is rejected as a publication snapshot. Its paired-file check had
no incorrect zero, while the augmented correct-pool ranking exposed 19
incorrect predicates whose nearest Certificate-Integrated IR distance was
zero. A release decision must inspect both populations.

The replacement clean publication run
`6000d695-8b5e-4972-b0ea-3d9e55111245`, rooted at
`/home/augustus/acgn-publication-20260827T194941Z`, completed on source commit
`ebce874382c87108a32874149008842a7b0fa528`. It evaluated 61,598 paired
predicates and ranked all 42,386 incorrect predicates against their complete
AST-distinct truth pools with zero failures. The certificate-integrated path
had zero incorrect nearest-distance zeroes, so the release gate passed. The ten
remaining Fast Rewrite zeroes are retained in
`alloy4fun-augmented/incorrect_nearest_zero_distances.csv` as non-certifying
diagnostics.

## Fault 1: Guarded Nested Quantifiers

The minimum family is:

```alloy
all t: Teacher | some c: Class | t->c in Teaches
```

versus:

```alloy
all p: Person | some c: Class |
  p in Teacher implies p->c in Teaches
```

When `Person - Teacher` is nonempty and `Class` is empty, the first formula is
true if `Teacher` is empty and the second is false. Primitive-carrier reduction
correctly changes `t: Teacher` to a `Person` binding plus a membership guard,
but the old scheduling lifted `some c: Class` before accounting for the later
implication. That used the invalid empty-carrier step
`D(x) -> exists y. P(x,y)` to `exists y. D(x) -> P(x,y)`.

The repair keeps the existing primitive carrier and local-binder machinery.
A guarded universal blocks an inner existential lift unless the inner carrier
already has scoped nonemptiness evidence. Conjunctive declaration guards apply
the dual restriction to universal lifting. No `univ` witness is fabricated.

## Fault 2: Temporal Snapshot Membership

The residual witness was:

```alloy
always all t: Trash | after no t
```

versus:

```alloy
always all t: Trash | after no (File & t)
```

Here `File` and `Trash` are mutable signatures. The bound singleton `t` is a
value captured in the owner phase; in the `after` phase it need not remain a
member of the current `File`. Exact type shape is still valid, but it cannot
authorize the value-level absorption `File & t = t` across that phase change.

The repair marks variables imported from an enclosing temporal phase as
snapshot bindings. Their exact relation type remains available to typed slots
and dependent-chain checks. Full-carrier absorption is withheld only when the
candidate depends on such a snapshot and the parser-authenticated carrier is
declared `var`. The same absorption remains admitted for static signatures and
for values bound in the current phase.

## Evidence

- `MASGVisitorTypeRegressionTest` contains both minimum source witnesses,
  positive controls, and direct SAT4J counterexamples.
- `GuardedPrenex.lean` proves the inhabited-inner-carrier equivalence and an
  empty-inner-carrier countermodel.
- `TemporalPhaseLocalBinding.lean` proves the mutable-carrier countermodel and
  the exact three-way admission boundary: imported plus mutable rejects,
  imported plus static admits, and same-phase values admit.
- Replaying all 29 previously observed Fast or certified zero candidates leaves
  zero Certificate-Integrated IR false zeroes. Ten Fast Rewrite IR zeroes
  remain; the certified layer distinguishes every one. They are reported as a
  speed/security tradeoff and cannot support a semantic certificate claim.

`Alloy4FunAugmenter` now writes
`incorrect_nearest_zero_distances.csv` after ranking and aborts before reward
or report publication if any incorrect predicate has zero nearest
Certificate-Integrated IR distance. Fast Rewrite IR zeroes remain visible in
the same audit file but are not certified equality claims.
