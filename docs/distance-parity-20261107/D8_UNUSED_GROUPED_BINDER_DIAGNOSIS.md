# D8 Unused Grouped Binder Diagnosis

## Scope and Status

Bounded diagnosis of the preexisting comparisons for
`D8Cr9JZoAAGsXSWtu_inv4`, zero-based reference indices 49 and 259.
Both original discrepancies remain OPEN. No production repair, dataset edit,
full4072/full66080 restart, or certification claim is made by this investigation.

Evidence directory on the investigation workstation:
`/media/augustus/8618-0ED0/ACGN/supervision/d8-pattern-check-yYYenq`.
`attempt2/manifest.json` binds the frozen inputs, build and diagnostic sources.

## Extracted Pattern

The references differ only in whitespace and contain the same formula:

```alloy
all u1,u2:User |
  all a:Ad |
    u1->a in posts implies
      (all p:Photo | u1->p in posts implies p in Ad)
```

`u2` is a valid declared but unused member of the grouped universal binding.
The learner formula is:

```alloy
all x:User |
  some y:Photo |
    y in x.posts and y in Ad =>
      (all p:Photo | p in x.posts and p in Ad)
```

Here `Ad extends Photo` and `posts: User -> Photo`. Original source files,
typed slots, owners, construction evidence and native traces are retained in
each case directory. The exact full reference source SHA256 values are:

- 49: `0e1a8ce2aea8ce1ab987b5c574bf1437e84fb231e9c3799c5d7efe503b2cfddc`
- 259: `bc94152e19ec926f941487beae8560e3be0331052de4e025b1bc89796a10d275`

## Demonstrated Boundary

`FastPaidDeclarationAlignment.groupedSlotsMatchSource` ends with
`observed.equals(grouped.keySet())` (line 226 in the tested source).
For the target's grouped declaration, declared names are `_q0,_q1`, but only
`_q0` occurs in the matrix. Consequently the target fails paid-alignment
eligibility. `CanonicalDistance.bestCoherentMatrixAlignment` then bypasses
`paidDeclarationMatrixAlignment` and uses the older alpha-alignment route.

The initial extra-declaration-charge hypothesis is falsified: declaration cost
is 4 in both paths. Matrix cost is 15 Fast versus 14 certified. The Fast matrix
map links `x -> u1` and learner `p -> p`; the certified paid map links
`x -> a`, `y -> p`, and learner `p -> u1`.

In the forward traces, matrix operation indices 4, 12 and 17 have respective
Fast/certified charges 1/0, 1/0 and 0/1. The first is learner `p:Photo` at
`root/child/0/child/0/child/0/child/0` versus reference `u1:User` at
`root/child/0/child/1/child/0/child/0`. Paid declaration updates account for
these matrix comparisons; a zero matrix charge alone does not assert equal
source binder types.

## Executed Checks

- Both original references, both directions: Fast 19, certified 18.
- Both native metric-representation traces replay and reject a changed total
  distance. Certified selected matrix/declaration links are checked; Fast's
  joint correspondence is not checked.
- All four original cross-path comparisons remain `UNCHECKABLE` with
  `MISSING_DECLARATIONSLICE`: no minimum declaration path matches the selected
  Fast correspondence. Native replay alone does not close that obligation.
- A grouping-only control replaces `all u1,u2:User |` with
  `all u1:User | all u2:User |`. All four target binders, domains and body are
  retained. Reference 49 in both directions then gives 18/18 and
  `MATCHED / CHECKED_NATIVE_ACTIONS_EQUAL`, with replay and distance-tamper
  rejection for both arms.
- `GroupedUnusedBinder.lean` was compiled. Its three named theorems have no
  axioms: general grouping equivalence, the reference-body instance, and the
  modeled old observed/declared rejection. These do not establish general Java
  admission soundness or the original paid selected-path correspondence.

The first attempt stopped at the original incident; its failed receipt and
exact original probe source are retained in `attempt1/`. The follow-up was an
explicit bounded diagnostic with four expected open incidents and two controls,
not a passing regression sweep. Both diagnostic services have exited with
MainPID 0 and empty control groups. Resource receipts are retained.

## Review and Next Repair Obligation

Existing Terra reviewer `01a1b7ca-e043-7ad0-8162-0de59a5feda6`, submission
`01a1c3e6-34d1-7052-aaf3-acd3b874d510`, accepted the diagnosis at bounded scope,
verified 1,119 manifest hashes, and confirmed all six comparison outcomes.

A future minimal repair must authenticate unused slots from retained source
declarations, preserving ordered slots, types, owners and dependencies while
checking every actual occurrence. Simply removing the equality check, inventing
body occurrences, or using full certification to replace the Fast result is not
justified by this evidence. Required future controls include forged unused
slots, types and owners, beyond the current distance-tamper checks. General
admission soundness and selected-path correspondence remain proof obligations.
