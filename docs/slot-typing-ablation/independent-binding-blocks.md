# Independent Bind-Block Combination

## Lean Gate

`IndependentBindingBlocks.lean` proves fifteen lemmas before the corresponding
Java change. All fifteen compile with no axioms reported by `#print axioms`.
No `sorry`, custom axiom, or `unsafe` is used.

The combination laws identify nested independent universal or existential
bindings with a single product binding. Exchange laws allow reordering their
binding/domain pairs, including different carrier types. Guarded versions keep
each original domain predicate attached to its own variable. No nonemptiness
assumption is needed. Applying the binary laws repeatedly covers finite chains.

The phase-indexed laws hold with the same state parameter on both sides,
including domain interpretation. They do not move a quantifier through a
temporal operator. Counterexamples refute exchanging `all` with `some`, dropping
disjointness, and moving a universal quantifier across an eventuality modeled
by existential selection of a trace position. The last is an abstract finite
countermodel, not a new implementation of Alloy temporal semantics.

Constraint-retention laws cover explicitly retained disjointness guards. The
initial Java combination deliberately excludes disjoint declarations rather
than infer new group identities or insert guards. This is a narrower executable
scope than the guarded logical laws.

## Java Contract

1. Resolve variable scopes first, retaining distinct identities for shadowed
   binders. Combining raw source spellings before scope resolution is forbidden.
2. Combine only directly nested equal-kind `ALL` or equal-kind `SOME` blocks.
   Having the same temporal phase is necessary but not sufficient: branches,
   temporal operators, different quantifiers, and dependencies remain barriers.
3. Initially accept only independent scalar signature domains (including
   parser NOOP wrappers), non-variable and non-disjoint declarations. Preserve
   all other declarations unchanged. Dependent/complex domains are not silently
   weakened to `univ` or accepted through a name/type-only inference.
4. Split eligible multi-name declarations into binding/domain pairs. Flatten
   eligible chains, then enumerate canonical renamings for the resulting block.
   Sort renamed binding/domain pairs together, never detach their domains.
5. Typed enumeration partitions the block by exact type before generating
   candidates. The untyped arm uses the same block and retains the same domains
   but erases slot colors. It does not merge unrelated scopes to enlarge search.

For an independent 4A+4B block, this exposes 576 typed versus 40,320 untyped
candidate renamings. These are representation alternatives with attached
domains, not a claim that values of different types may be interchanged freely.
Existing candidate caps and synthetic deadlines remain in force.

This change is confined to experimental `SlottedEGraph` arms. It does not alter
the Certificate-Integrated pipeline, Fast Rewrite IR, or their certificate
authority. Lean establishes the logical schemas; Java source tests and finite
solver controls check their implementation correspondence. No whole-program
Java refinement claim is implied.

## Reselection and Validation

The portable [selection manifest](mixed-block-smoke-selection.json) records
three natural mixed-prefix controls and synthetic 8/16/32-binding cases in
`declaration_grouping` and `independent_block_exchange`, plus a negative control.
These are existing corpus files, not invented mixed-color Java terms. Before
combination, both arms missed all six positive synthetic pairs. A source audit
confirmed independent scalar signature domains; its initial NOOP-wrapper
inspection bug was corrected in a separately retained audit-v2, without altering
timed observations. On this workstation that pre-change run is
`/media/augustus/8618-0ED0/ACGN/intermediate/mixed-block-reselection-20261106/`.

The implementation is versioned `slotted-independent-binding-blocks-v3`.
Post-change gates checked five Lean files and six Java test mains. The new
generator test passed 1,227,116 assertions. `SlotBindingBlocksTest` initially
passed 42 assertions; an additional subset-domain negative control then passed
the expanded 45-assertion test separately. Four source equivalences have no
counterexample at Alloy scope 3; a fifth deliberately inequivalent pair has a
counterexample and positive distance in both arms. That fifth check ensures
`A` and `Sub in A` retain different domain constraints despite sharing the
same primitive slot type.

The post-change corpus smoke used the three natural controls and the 8-binding
synthetic cases. It completed in 66.18 seconds under the same one-worker,
1 GiB heap, 15-second deadline policy. Both arms completed all six comparisons
and all six independent synthetic constructions. No errors, timeouts, OOMs,
or synthetic expected-relation mismatches occurred.

| Synthetic pair | Distance before, untyped / typed | Distance after, untyped / typed | Engine seconds after, untyped / typed |
| --- | ---: | ---: | ---: |
| Declaration grouping, `stress0030` | 57 / 57 | 0 / 0 | 4.441150 / 0.252102 |
| Independent block exchange, `stress0040` | 199 / 199 | 0 / 0 | 4.389593 / 0.269910 |
| Negative cross-type, `stress0210` | 2 / 2 | 2 / 2 | 3.780756 / 0.260371 |

The two positive cases show approximately 17.6x and 16.3x lower typed engine
time in this single cold trial. This is exploratory, not a repeated performance
estimate. Median independent construction time was 2.263880 seconds untyped
versus 0.211956 seconds typed. The small natural controls still show little
pruning benefit (median comparison 15.628 ms untyped, 16.490 ms typed).

Post-change evidence and hashes are under
`/media/augustus/8618-0ED0/ACGN/intermediate/combined-block-corpus-smoke-20261106/`;
the initial gate and additional domain check are under
`/media/augustus/8618-0ED0/ACGN/intermediate/bind-block-proof-smoke-20261106/`.
These paths are workstation-local; repository runners remain portable.
The corpus snapshot contains the initial 42-assertion block test; the expanded
45-assertion test does not change the production classes used for measurements.
Only a source comment changed after that snapshot; manifests retain the exact
source used for execution.

The 16/32-binding cases were selected and measured before combination, but were
not rerun after this implementation. The pre-change uncapped run timed out on
`stress0031C` and `stress0032C` in both arms at the 15-second smoke deadline.
No post-change large-case or full-corpus completion claim is made. Five-minute
synthetic deadlines and production permutation caps are unchanged.
