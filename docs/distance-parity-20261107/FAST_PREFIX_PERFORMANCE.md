# Fast prefix admission: bounded performance repair

## Change

`FastGroupedDeclarationOrbit.orders` no longer constructs a full certified
semantic graph and repair projection merely to authorize outer-prefix swaps.
It obtains the exact same binder descriptor and source-coordinate map through
the shared `TheoryAlloyAdapter.prefixBinderPlan` builder instead.

`FastPrefixSource` checks frozen source identity, pristine occurrence paths,
semantic profile, expression types, lexical slots, original aliases, and
occurrence lineage. Declaration containers require the existing checked local
owner/domain/slot traversal on both source and comparison. Small typed
permutation certificates, dependencies, payload equality and group membership
are still verified. This is not an unchecked fast mode.

The full certified path remains available and unchanged. Specialized replay
fallbacks in `CanonicalDistance.presentationBindings` and
`FastRetainedDeclarationCompletion` still use full certification. This repair
does not claim that every possible Fast replay is certification-free.

## Validation

- Ten ACGN suites passed on the frozen attempt10 candidate, including 27 source
  controls, 19,760 performance checks and 2,041 canonical-pipeline checks.
- Existing both-direction replay, corrupted evidence, grouped-domain, local
  owner, and cache-policy controls passed.
- Three Lean files compiled. The new proof checks independent ALL/SOME exchange,
  capture-free coordinate reads, the exact source fixture and old work-budget
  rejection. Java asserts the source hash, actual typed slots/owners, swap and
  transport/inverse. Named theorem dependencies contain only standard Lean
  foundations, no sorryAx or new axioms. This is a finite correspondence witness,
  not universal Java/Lean refinement.
- AlloyStudio received a seven-file vendor patch preserving its existing
  `WorkBudget.charge(1)` instrumentation and all prior patch metadata.
- A clean isolated AlloyStudio build, 500-check engine self-test, Python
  performance/snapshot tests and vendored Lean compilation passed.
- The existing CI snapshot test's stale four-patch list now checks the five
  existing patches plus this sixth patch and its explicit file provenance.
  New Java tests and the Lean proof are registered in CI. Remote CI is untested
  for these uncommitted changes.

## Measured scope

Cold, one-CPU JVMs used 1 GiB initial/2 GiB maximum heap. Entire reference pools
were retained. These are bounded timings under concurrent workstation load,
not a throughput guarantee or a new full-corpus scan.

- D8Cr9JZoAAGsXSWtu_inv4, 283 references: production Fast 6.600 -> 3.896 s;
  final certified 19.313 s.
- NjPExvsP63cD4FwFP_inv8, 51 references: production Fast 6.028 -> 1.985 s;
  final certified 6.984 s.
- L3GpsvkYjb4d7mbR6_inv14, 31 references: production Fast 5.779 -> 1.523 s;
  final certified 6.204 s.

All nine final staged-Fast/certified/production runs preserved their respective
baseline complete response or per-reference cost vector. Fast and production
runs passed with `acgn.maxCanonicalWorkItems=1`; production JFR samples contained
no full-adapter calls. Sampling alone is not an exhaustive call-count proof.
All certified cases stayed below 60 s. Resource receipts record no incidents
or service swap; final services are inactive with no descendants.

## Open obligations and resumption

Two baseline D8 comparisons, zero-based pool indices 49 and 259, remain Fast=19
versus certified=18. They are unchanged by this patch, not passes or exclusions.
The other 363 scalar comparisons match, but scalar equality is not a proof of
every canonical form or repair path. Full4072/full66080 remain paused and public
certification remains blocked. The active independent AlloyStudio frozen run
was not modified or restarted; it continues to use its own prior source copy.

Changes are local in ACGN and AlloyStudio. Before any later commit, preserve
unrelated AlloyStudio worktree edits and recheck the intended file set. Do not
resume corpus work implicitly from this performance result.

Workstation evidence root:
`/media/augustus/8618-0ED0/ACGN/supervision/fast-prefix-admission-maWouv`.
Useful receipts are `attempt10/complete.json`, `review-attempt10.json`,
`integration2/complete.json`, `integration2/results.json`, and
`review-integration2.json`. Earlier failed controls/setup attempts are retained
separately and are not counted as successes.

- ACGN candidate manifest SHA256:
  `9a47f28c10e683ce27bc0c76441830b7512d2b5c999692ed92a83a44549b2018`.
- AlloyStudio source manifest SHA256:
  `cdc2994f46e420fd937d94d22c0186a920189f85106a70e81e2f7159553ca3c7`.
- AlloyStudio integration input manifest SHA256:
  `604958df1f0e8550f0cf2ece3e262c6c8185e4aeff7d2389f37bf508530c6aa3`.
- Final result SHA256:
  `e4497dca433b7b8b2103eb61fd3965d812ae67afd33a51e7c2d8e03a167f84da`.

The existing Terra reviewer accepted the bounded ACGN candidate and its
AlloyStudio propagation after the expression-type, finite witness and orphan
declaration findings were repaired. Neither acceptance authorizes a full
corpus restart or a public certification claim.
