# P0 Correct-Pool Kernel Divergence Incident

## Trigger

`Alloy4FunAugmenter` stopped during correct-pool comparison with 14 strict
kernel violations. Every reported source predicate carried the dataset label
`CORRECT`. That label is useful diagnostic metadata but is not proof authority;
the failure was established independently by disagreement between producer
observation equality and zero repair distance.

The violations formed two families:

1. `coursesNew/inv12` had equal producer observations but repair distance one.
   Equivalent presentations placed a `LONE Grade` declaration at different
   lexical paths after safe prenexing.
2. `trash_rl/inv1` had repair distance zero but unequal producer observations.
   One source normalized to `A`; another retained `false or A` only in the
   matrix cloned for certification.

## Root Causes

The repair metric used `QuantiVar.bindingPath` as an extra compatibility test
for prenexed quantifiers other than `ALL` and `SOME`. The certified binder
descriptor had already encoded the semantically relevant owner phase,
order-preserving exchange class, complete declaration payload, dependencies,
and orbit. The lexical path was stale presentation metadata at this boundary.
The first repair then erased that path based only on the caller reaching the
repair API. It did not carry an explicit proof bit showing that the binding had
actually passed the certified prenex projection. The same abstraction carried
coordinate-orbit lists but checked only repeated occurrences inside one view;
it neither required a complete owner-scoped orbit partition nor preserved the
same-orbit relation across a zero-cost alpha mapping.

Separately, Boolean identity and absorber rules ran during later e-saturation
but not in `normalizeGuardedSourceRules`. The certificate-facing matrix is
cloned between those stages, so `false or A` survived in only one observation.

An adversarial follow-up found a fail-open guard shared by both stages:
`CONSTANT` leaves were recognized as Boolean solely from the spelling `true`
or `false`. A malformed relation-typed leaf with that spelling could therefore
be erased as a Boolean identity or absorber before certification.

The full Section 3 harness then found two boundary regressions in the first
repair. The malformed-formula guard treated a legitimate relation-valued ITE
as a Boolean connective and returned without traversing its condition, leaving
an outer binder reference under its temporary `_bind_0` name. Separately, an
early return for a malformed Boolean parent could avoid the incidental sort-key
lookup that had previously validated a descendant CALL's qualified identity.
Fresh falsification then showed that validating only the outer Boolean
container was insufficient: relation-typed operands could still trigger
double-negation, complement, implication, IFF, or Boolean-ITE rewrites.
Two subsequent adversarial witnesses closed the remaining admission and
authority gaps. A malformed descendant CALL could be discarded by an
enclosing Boolean absorber before recursive admission reached it, and a
relation-only JOIN carrying forged Boolean metadata could pass the operand
type check. A separate package-level witness showed that a hand-built
`RepairView` could claim an arbitrary producer observation key.

The first hash-bound Luna review found three further source-admission holes.
The traversal omitted separately allocated e-classes in a reachable union-find
component; temporal negation could rewrite a parent reference before admitting
the referenced child phase; and generic exact `Bool` metadata was accepted as
operator provenance for a hand-built AND or ITE. None of these witnesses
depends on the corpus `CORRECT` label.

The next fresh Luna ballot found two lifecycle holes in that repair. Public
type and child mutation did not revoke an internal Boolean derivation token,
and an exact-Boolean REF could claim the reserved `temporal[index:arity]`
spelling without owner-issued source provenance. Both attacks were independent
of dataset status and reached production certification entry points.

## Repair

- Global alpha compatibility now ignores the obsolete source path only when
  both projected bindings carry explicit prenex path-erasure authority.
  Uncertified bindings retain lexical path equality as an admissibility
  condition. Compatibility still requires matching parameter role, owner phase,
  complete certified declaration payload and dependencies, an order-preserving
  exchange-block alignment, injectivity, and the certified coordinate orbit.
- Every non-parameter orbit ledger must equal the complete set of coordinates
  with the same owner, certified declaration payload, and exchange class.
  Zero-cost alpha pairs preserve the induced same-orbit relation pairwise.
  Paid declaration modifications remain the one explicit metric operation that
  may carry identity across a changed quantifier tuple.
- `AND` and `OR` identity/absorber rules run before the certification snapshot:
  `A and true = A`, `A or false = A`, `A and false = false`, and
  `A or true = true`. Empty and unary flexible containers reduce to their
  Boolean identity or sole child at that same boundary.
- Boolean literal recognition now requires all three authorities to agree:
  `CONSTANT` opcode, Boolean metatype, exact Alloy `BOOL` type, and a Boolean
  source-type tag. `IRAgent` derives the Boolean metatype from parser-owned
  exact type evidence. A relation named `true` or `false` remains observable
  and cannot trigger a Boolean rewrite.
- Boolean identity reduction additionally requires exact Boolean evidence on
  the enclosing connective and a noncontradictory Boolean/operator source tag.
  Branch-connective, prenex, and NNF rewrites retain malformed containers.
  Every child insertion and semantic invocation rejects a foreign e-graph
  arena or semantic profile instead of importing or comparing an unowned
  e-class.
- Preserved rewrite snapshots now retain the source e-class arena rather than
  the ambient thread's current arena. Freezing a certification source therefore
  freezes every preserved alternative in the same ownership domain.
- Relation-valued ITE nodes are retained, but normalization still recursively
  alpha-renames and normalizes their children. Only an exact Boolean ITE may be
  expanded into Boolean branches.
- CALL metadata is validated at node admission, before any parent rewrite guard
  can return. Validation no longer depends on sorting or another incidental
  consumer reaching the CALL.
- Normalization now runs a complete read-only admission traversal before any
  branch can be rewritten or discarded. This closes the descendant-CALL
  absorber witness; source LET references are admitted only as named arity-zero
  placeholders pending beta substitution.
- Every Boolean rewrite also requires exact Boolean evidence for each immediate
  formula operand. An explicitly relation-typed operand blocks the rewrite;
  untyped variables remain admissible only as internal rewrite-pattern slots,
  not as parser-derived source evidence.
- Operand authority also checks the opcode family. Relation-only JOIN and
  GLOBALBINDING nodes cannot become formula operands by forged Boolean metadata.
- Public kernel-checked repair evaluation accepts only sealed projections minted
  from a matching frozen adapter result. Hand-built metric fixtures have no
  producer authority and are restricted to named test-only evaluators.
- Reachable-graph admission and certification freezing include every e-class
  in every reachable union-find component. Union roots retain explicit member
  sets, avoiding a scan of the full arena for each visited class.
- Both normalization and temporal-negation entry points admit the complete
  acyclic temporal normal-form tree before changing a parent phase. Live and
  certification matrices are checked independently when both exist.
- Exact Boolean type evidence no longer authorizes a Boolean operator. A
  rewrite requires either concordant parser operator identity or a trusted
  internal derivation token bound to the node's current opcode. Exact-opcode
  clones preserve that token; opcode-changing rewrites issue a new one; leaves
  and relation constants clear it.
- Public source/type/child/call-metadata mutation revokes internal Boolean
  authority. NormalForm uses a package-private normalized-child construction
  path to retain an exact token only while building trusted derived syntax.
- Temporal references are issued by their owning NormalForm against one exact
  temporal source opcode and the already attached child phase identities.
  Reserved temporal REF spellings without that owner-bound record reject in
  both temporal-tree admission and direct theory adaptation. Public mutation
  revokes the record; exact normalized clones preserve it.
- Round 31 showed that owner issuance alone was insufficient while a public
  caller could supply an unreachable, wrong-arity source. The metadata-only
  factory has therefore been removed. Its replacement consumes a private,
  single-use IRAgent evidence object bound to the exact MASG graph, parser
  node, visit, temporal edges, source type/opcode/lineage, owner, child range,
  and arity. Authority IDs are process-global so two owners cannot collide.
- Round 32 then found that a claimed source visit could borrow another visit's
  edge bucket and that consumed claims no longer observed destructive source
  graph mutation. A consumed claim is now retained in the owner ledger and
  revalidated against the exact root-to-source path, source-visit bucket,
  graph-edge counterparts, positions, parser metadata/type, profile, and child
  range before every rewrite or adaptation. Fast-metric preparation and
  certification freezing perform one final validation, then seal the private
  owner-bound occurrence and release the parser graph. This bounds retained
  memory while preserving fail-closed checks during the mutable lowering
  interval.
- Round 33 found an independent certification race: the NormalForm frozen flag
  became visible before its e-graph arena was frozen, leaving a concurrent
  post-admission mutation window. Admission and reachable-component freezing
  now share one arena monitor with direct, non-overridable arena dispatch, and
  the NormalForm publishes frozen only after every owned source is immutable.
  Fast metric preparation crosses the same boundary.
- Round 34 then showed that direct arena dispatch was insufficient while the
  e-node class itself remained extensible: an ordinary subclass override could
  report a different opcode and bypass the underlying CALL's arity check.
  EGraphNode is now a final concrete trusted-representation type, closing that
  accidental Java extension surface rather than enumerating individual
  methods.
- Round 35 found that the memory-release boundary did not actually prune
  disconnected registered union components: cleanup treated registration as
  reachability. Cleanup now computes the child-edge and union-component closure
  of the retained roots, removes every other registered class, and reports the
  exact removal count. The direct fixture removes a disconnected two-class
  component while preserving both members of a reachable component.
- Round 36 found one remaining live-graph premise absent from temporal
  evidence: removing a downlink target vertex while retaining its edge did not
  revoke the claim. Each recorded downlink now requires its exact target to
  remain a graph vertex until sealing. Child-only removal rejects through both
  owner admission and direct adaptation; restoring the target restores the
  valid pre-seal graph.
- Round 37 found the symmetric path-origin omission: a non-temporal captured
  graph root could be removed while a retained root-to-source edge kept path
  continuity intact. The ticket now requires the captured root itself to remain
  a live graph vertex until sealing. Root-only removal rejects through owner
  admission and direct adaptation, and restoring it restores admission.
- Round 38 passed Luna but failed at Terra because recursive saturation checked
  only the unfrozen entry root. A second parent could therefore rewrite a
  shared descendant frozen through a certified parent, and a mutable sibling
  could change before a later frozen sibling caused failure. Saturation now
  preflights mutability over the complete reachable child/union closure before
  its first rewrite and rechecks every recursive node.
- Round 39 found two independent completeness boundaries. First, temporal child
  coverage was vacuous when no authority had been issued; every child index now
  belongs to exactly one exhaustive, nonoverlapping owner-issued range and each
  authority must still appear in every retained matrix. Second, rewrite-created
  nodes selected the executing thread's builder arena; generated rewrite and
  snapshot nodes now explicitly inherit the existing source graph's final arena.

## Bounded Evidence

- `QuotientRepairDistanceTest`: the prenexed non-`ALL` path witness has distance
  zero only with explicit path-erasure authority; an uncertified distinct-path
  witness has positive distance, a split orbit ledger rejects, and distinct
  exchange blocks remain unable to cross-permute. Parameters cannot claim a
  binder orbit, and uncertified quantified bindings cannot omit their lexical
  path. An independent bounded oracle also checks every length-three usage word
  over all permutations of one, two, and three certified coordinates. The suite
  passes 2,266 checks.
- `CanonicalAlloyPipelineTest`: parser-backed prenex and Boolean-neutral pairs
  have equal producer observations and distance zero.
- `EGraphSaturationTest`: relation-metatype and relation-exact-type forgeries
  named `true` or `false`, inconsistent source tags, relation-typed Boolean
  containers, malformed branch connectives, foreign children/comparisons, and
  cross-arena snapshot mutation do not cross the guarded boundary.
- `AlloySourceRuleRegressionTest`: a quantified relation-valued ITE
  backtranslates without an escaping temporary binder and remains
  solver-equivalent to its source.
- `CallExtractionRegressionTest`: a metadata-incomplete CALL under a malformed
  Boolean parent rejects at node admission.
- `EGraphSaturationTest`: forged relation operands cannot trigger double
  negation, complement elimination, implication/IFF expansion, or Boolean ITE
  expansion.
- `EGraphSaturationTest`: a malformed descendant CALL under an absorbing
  Boolean parent rejects before rewriting, while exact forged JOIN and
  GLOBALBINDING formula operands remain observable.
- `EGraphSaturationTest`: a malformed alternative in a reachable union
  component rejects before absorption, and freezing one visible invocation
  freezes the complete component. Saturation through another parent cannot
  mutate a shared frozen descendant or partially rewrite an earlier sibling.
  Reachability cleanup removes a disconnected registered component without
  dropping a reachable union peer. A forged generic-`Bool` AND and ITE remain
  explicit. A malformed CALL in a temporal child rejects before either parent
  normalization or temporal dualization.
- `QuotientRepairDistanceTest`: raw fixture keys cannot authorize the public
  kernel check; only certified projections can do so. Invalid negative and
  absent binding indices reject at construction.
- Fresh review found that the first Lean abstraction admitted a crossing block
  list even though Java enumerates only injective, order-preserving mappings.
  A second review found that those IDs were still modeled globally even though
  Java scopes them per binding role and temporal owner. `ExchangeAlignment`
  now carries owner-keyed injectivity and monotonicity proofs, separates
  positional parameters, records payload/dependency/orbit evidence, and pins
  the continuous `ALL`/`SOME` versus path-separated nonexchangeable grouping
  rule. The concrete same-owner `(0,1),(1,0)` crossing is contradictory while
  equal local IDs in distinct owners remain separate keys.
- The concrete `coursesNew/inv12` witness now has the binding map `[1,0,2]`,
  equal digest, and distance zero.
- The concrete `trash_rl/inv1` witness now has one shared digest and distance
  zero.
- A fresh temporary 11-file corpus containing every source named by the 14
  failures completed all 13 AST-distinct correct-pool comparison tasks without
  a strict kernel violation after the Round-39 repairs. The latest run used two
  workers, skipped rewards, and completed the latest comparison stage in
  0.020 s. All
  11 files parsed and both correct-reference groups were built successfully.
- `Phase5SourceRules.lean` independently checks component-wide alternative
  admission, temporal-descendant admission, rejection of generic Boolean type
  as operator authority, and acceptance of parser-concordant or internally
  derived authority. It also distinguishes child/union closure from mere
  registration during retained-arena pruning. It additionally checks exact
  temporal-child coverage and existing-graph arena inheritance for synthesized
  rewrite nodes.
- Rejected fixed-arity child replacement, child/invocation append, and invalid
  CALL metadata updates preserve their complete prior state. Empty-root cleanup
  removes both registered e-classes and their union-find bookkeeping rather
  than treating registration as reachability.
- Pruned e-class handles are permanently retired and reject reuse before a
  canonical or union-find lookup. NormalForm clones inherit the source arena,
  and temporal dualization stages operation and matrix changes before commit;
  a parser-backed cross-thread `NOT ALWAYS` witness completes coherently.
- Admission now rejects a retired root before reading occurrences, and the
  retired tombstone releases its node/child, shape, symmetry, and slot payload.
- Temporal construction, rewrite, admission, and recursive freeze now share one
  tree lifecycle monitor. A parser-backed freeze/rewrite race permits only a
  complete rewrite followed by freeze or a complete freeze followed by rewrite
  rejection; child construction also rejects after freeze. Derived e-node
  creation checks owner mutability while holding the owning arena monitor.
- Empty and all-null retained-root lists now denote the same empty closure and
  retire every registered class plus its union-find state.
- Round 44 rejected identity-only recognition of Alloy's reserved `none` and
  `univ` constants. Public metadata cannot mint their internal authority;
  parser/factory construction and trusted derivation can carry it, and only an
  unchanged nullary normalized rebuild preserves it. The retained forgery does
  not fold, while authenticated `x in univ` and empty-domain quantifiers still
  apply their source rules.
- Round 44 also rejected semantic reads through a pruned node or a previously
  escaped child-list view. Retirement now erases node payload and all such
  reads fail at the permanent e-class tombstone.
- Round 45 found a supported scheduling mismatch: `some (A + none)` reduced
  only in the live repair matrix while the certificate snapshot retained the
  union unit. Authenticated `+ none`, `& none`, self-difference, and Boolean
  complement/contradiction now close before the snapshot. Parser-backed ACI
  idempotence controls confirm that certificate-governed ACI normalization
  remains after that boundary.
- Round 46 found the composed scheduling witness
  `some (S + S) or not (some S)`: the inner ACI equality was certified in
  isolation, but the earlier enclosing complement pass could not consume it.
  The source rule now compares typed/profile-indexed operands through the
  certified ACI container quotient without mutating them. Same-operator flat
  regions compose their invocation maps, Set operands alone deduplicate, and
  a quotient singleton is exposed before duality. Associative, commutative,
  idempotent, self-difference, bound-slot, and distinct-operator controls pass
  with producer equality exactly matching repair distance zero.
- Round 47 found three additional supported boundaries. Exact integer
  additions arrived as overloaded surface `PLUS` and were assigned relational
  ACI policy; nested same-symbol binary operands rewound their source visit and
  could leave an empty `PLUS`; and equality duals compared certified
  commutative children positionally. Typed opcode selection, monotone nested
  occurrence visits, and certified multiset comparison now close those paths.
- A distinct nested-union control then showed that parser-inferred intermediate
  result carriers could block relational associativity. A nested `PLUS` now
  splices across a carrier change only with live same-module parser authority,
  equal arity, and proof that every child alternative belongs to the outer
  carrier. Widened leaves remain explicit coercion nodes. Repeated, distinct,
  near-miss, integer-profile, swapped-equality, and bound-slot fixtures pass.
- Round 48 found the remaining occurrence-counter sibling on a supported path:
  a valid nested formula ITE reached fixed-arity admission as an empty `ITE`.
  Ternary traversal now leaves every nested condition/then/else occurrence at
  its monotonically allocated visit and connects only the parent through its
  saved visit. The nested formula agrees with its direct branch expansion at
  certified distance zero, and a nested expression ITE prepares without an
  empty or conflated branch.
- Round 49 invalidated the earlier additive diagnosis. Source `+` and `-`
  retain relational union/difference identities even when their exact unary
  carrier is `Int`; direct SAT checks prove `Int + Int = Int`,
  `no (Int - Int)`, and singleton cardinality operands union to `1` rather
  than arithmetic `2`. The adapter now selects the operation family from the
  parser opcode and uses the certified container schema, not result carrier,
  to distinguish relational Set semantics from arithmetic Bag semantics.
- Round 50 then exercised genuine `fun/add` and found that two separately
  allocated literal `1` nodes shared a structural-equality visit counter. The
  second literal therefore lost its exact type before adaptation. Lowering now
  indexes occurrence visits by parser-node identity: shared operator nodes
  still advance, while equal-valued literal objects each retain visit one.
  Repeated and nested `fun/add`/`fun/sub`, cardinality, and negative literals
  now preserve their exact Int types and non-idempotent arithmetic containers.
- Round 51 exposed a public certificate-boundary type erasure. For valid
  `Int + S`, Alloy's `Type.is_int()` reports that Int participates; it does not
  say the full unary family is exactly Int. The producer discarded `S` and a
  fresh standalone verifier accepted the resulting Int-only union bundle,
  while Alloy satisfies `some S and (Int + S) != Int`. Exact Int
  classification now requires one and only one nonempty unary product headed
  by the built-in `Sig.SIGINT`; mixed alternatives remain explicit in the
  correlated relation-family type. Round 51 is permanently recorded as
  `FAIL`, and its reviews provide no closure credit.
- Round 52 showed that preserving alternatives was not sufficient when an
  inner result used a declared subtype and its enclosing PLUS used the parent.
  With `C extends P`, the left and right groupings of `Int + C + P` received
  different observations and distance 4 even though Alloy proved union
  associativity. Literal family containment now gives way to a stricter
  proof: for each correlated inner product, every column must reach the
  corresponding outer column along live ancestry from the identical parser
  module. Reverse, sibling, arity-changing, cross-module, and unproved paths
  remain excluded. Round 52 is permanently `FAIL`; its earlier passes do not
  carry forward.
- Round 53 found another pre-snapshot scheduling mismatch. Alloy proves
  `P & univ = P`, but the producer retained the intersection while repair
  saturation removed it. Authenticated `R & univ`, `R + univ`, `R - none`,
  `R - univ`, and `none - R` now close before the certificate snapshot and
  remain mirrored afterward. Direct Alloy, parser-backed equality/distance,
  and Lean relation equations cover the five supported identities. Round 53
  is permanently `FAIL`; its review result cannot carry forward.
- Round 54 was invalidated by a discovery that two Luna `PASS` reports did
  not promote: with `A, B extends P`, Alloy proves `A + B + P = P`, while the
  producer retained distance 4. The first attempted repair exposed two
  additional implementation faults before review: user-signature leaves are
  represented as `ATOMIC`, not `SET`, and a same-length child replacement was
  ignored when publication compared list sizes only. The repaired rule grants
  full-carrier authority only to the actual parser-authenticated signature
  leaf, consumes same-module ancestry through relational-PLUS association,
  and commits identity-changing replacements. It covers `extends`, subset
  `in`, and arbitrary typed subrelations when the full parent is present;
  siblings, unrelated signatures, and merely parent-typed expressions remain
  controls. Round 54 is permanently `DISCOVERY`/invalid, and its two Luna
  passes carry no closure credit.
- Round 55 was invalidated when both Luna reviewers independently found that
  `sig Y in X` could not be absorbed by the actual subset-signature carrier
  `X`: Alloy proved `Y + X = X`, but production retained distance 3 because
  exact primitive type ancestry had erased the declaration boundary. Actual
  signature leaves now retain runtime-only parser declaration authority, named
  carriers use the same-module declaration DAG, and primitive exact-family
  fallback cannot authorize an arbitrary subset carrier. The same round also
  yielded the mandatory discovery `none in R = true`; exact same-arity
  empty-subset duals and empty plain `ARROW`/`JOIN` annihilation now close
  before certification and remain mirrored in saturation. Round 55 is
  permanently `FAIL`, and no result from it carries closure credit.
- The post-review repair audit rejected `Sig.isSameOrDescendentOf` as direct
  proof authority: for `X in A+B` it admits either parent separately, while
  Alloy permits `X-A`. Declaration containment now requires every subset-parent
  branch to reach the carrier; primitive `extends` remains a unique-parent
  chain. A common-parent positive case and the single-branch SAT countermodel
  are permanent regressions.
- The contemporaneous suspicion that `#A + #B` was integer arithmetic was
  independently refuted. Alloy executes parser `PLUS` as relational union on
  the unary `Int` carrier; `fun/add` supplies genuine parser `IPLUS` arithmetic.
  The implementation retains that operator-identity boundary. The reported
  empty nested `PLUS` was a genuine earlier occurrence-bookkeeping fault and
  remains tracked under GC-F158 with parser-backed repeated-occurrence tests.
- The same Lean module separates public mutation from trusted normalized
  construction and rejects absent, unbound, wrong-arity, wrong-owner, reused,
  wrong-visit, incomplete-edge, duplicate-position, missing-root,
  missing-child-target, mutated-source, or transplanted temporal-reference
  authority.
- The complete bounded Section 3 harness executed 58 steps with zero executable
  failures. Its outcome remains `INCOMPLETE`, not `PASS`, because the global
  traceability ledger intentionally reports 182 pre-existing open obligations.

These checks establish bounded conformance for the observed families. They do
not use the `CORRECT` labels as semantic certificates and do not replace the
open whole-parser and all-candidate refinement obligations in the global fault
register.
