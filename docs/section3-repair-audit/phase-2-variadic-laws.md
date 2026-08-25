# Phase 2 Audit: Variadic Structure and Algebraic Laws

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Current Review Status

IMPLEMENTED; A CURRENT CROSS-PHASE REVIEW FOUND AND REPAIRED A PARAMETER-TYPING
COUNTEREXAMPLE; REOPENED UNDER THE COMPLETE FORMAL CLAIM CENSUS AND FIVE-REVIEW
ZERO-TRUST GATE. See `adversarial-review-protocol.md`. Phase A2 is documented
separately and does not grant JOIN/ARROW a homogeneous flat law.

## Scope

- Repair branch: `section3-conformance-v2`
- Frozen base: `8ec25613e81d7b3767947db31c60cc4bbed4074d`
- Formal source: `ARTIFACT_REPAIR_PROMPT.md`, Phase 2
- Empirical result directories: unchanged

This phase separates admitted sibling counts, sibling quotient, recursive
same-head flattening, empty-fold units, and the Alloy semantic profile. A
variadic source shape no longer implies associativity.

## Implemented Obligations

| Obligation | Implementation | Regression evidence |
| --- | --- | --- |
| Explicit arity policy | `ArityPolicy` represents finite or lower-bounded admitted cardinalities | exact, K+, K0, set-downward and splice-closure tests |
| Explicit sibling quotient | `SiblingQuotient` distinguishes ordered sequence, multiplicity-preserving commutative bag, and ACI set | equality, disjoint, list, and set tests |
| Explicit flattening | `FlatLicense` names the sole root container port; `OperatorDeclaration` validates one source port, result/element equality, A, and splice closure | flat Seq/Bag/K0 rejection and acceptance tests |
| Explicit unit | `UnitLicense` is independent of arity; only flat K0 requires U | ordinary and nested K0 tests |
| Semantic profile | `SemanticProfile` fingerprints bitwidth, overflow, temporal mode, rewrite mode, and signature version | modular versus overflow-forbidding integer policy tests |
| Exact Alloy matrix | `AlloyOperatorPolicy` is the central opcode/profile policy | exhaustive enum whitelist regression |
| Conservative homogeneous policy | JOIN and every ARROW/product variant remain fixed binary and nonflat in the homogeneous flat-port matrix, even when given a stale variadic hint; Phase A2 is a separate dependent ordered-Seq family | nested JOIN/ARROW saturation and malformed-hint tests |
| C without A | equality, inequality, IFF, and overflow-forbidding integer add/multiply are fixed C-only bags | equality and integer tests |
| Disjoint multiplicity | disjoint operands use a nonflat commutative bag and are not deduplicated | duplicate disjoint-argument regression |
| Positional structures | CALL, ordinary lists, totalOrder roles, binders, and declarations receive no flat license | exact whitelist and role-order tests |
| ACI flat storage | AND, OR, relational union, and intersection flatten and deduplicate only through a Set+ policy | saturation and policy tests |
| Modular-only integer A | IPLUS/MUL get flat Bag+ only in the modular profile | 4-bit policy and nested `(7+1)+(-1)` regression |

## Located Faults and Contradictions

1. Existing JOIN and ARROW tests still demanded variadic flattening. They now
   require fixed binary ordered structure because the current homogeneous
   flat-port theory cannot type their dependent chains.
2. Several theory fixtures treated every K0 container as requiring U. The
   requirement is now limited to flat K0; ordinary and nested K0 are legal
   without U.
3. Canonicalization and leader-kernel fixtures fabricated A and U on every
   ordinary container. Those unused declarations were removed; quotient C/I
   remains structural.
4. The ablation rewrite registry and capability benchmark still advertised
   JOIN associativity. The rule was removed from the registry and the ACI
   capability case now uses the certified homogeneous intersection carrier.
5. A stale `variadic=true` hint could still make JOIN/ARROW structurally
   variadic. `AlloyOperatorPolicy` now overrides the hint with exact arity two.
6. The certified adapter lowered nonflat variadic `disjoint` operands
   positionally. It now constructs a C-only `Bag` with the exact arity policy,
   retaining duplicate occurrences.
7. `RepairProjection` omitted fixed integer C from its admissibility list after
   overflow-forbidding disabled A. It now retains C while continuing to reject
   integer flattening.
8. Exact arity filtering exposed a leaf-classification defect in the Fast
   Rewrite IR: variables, constants, references, shadows, and end markers had
   inherited a binary default. Correct leaf arities restore the established
   zero-cost redundant-domain-guard comparison without changing metric
   semantics.

## Verification Before Independent Review

- `TheoryLawPolicyRegressionTest`: 152 checks pass.
- `TheoryPortsTest`: 1,006 checks pass.
- `TheoryCanonicalizationTest`: 11,186 checks pass.
- `TheoryLeaderKernelTest`: 233 checks pass.
- `TheoryCertificatesTest`: 251 checks pass.
- `EGraphSaturationTest`: passes.
- `EGraphAblationTest`: passes.
- `CanonicalAlloyPipelineTest`: 186 checks pass.

## Independent Adversarial Reviews

### Review 1: FAIL

The reviewer found five production bypasses: adapter-issued law certificates
were trusted without an independently fixed source theory; fixed operator
arity was not validated at the e-node/import boundary; same-opcode flattening
did not compare the complete typed instance; all-neutral Boolean folds could
leave an illegal nullary K+ node; and production construction always selected
the overflow-forbidding profile instead of carrying an explicit profile. The
review also identified missing negative tests for ternary fixed operators,
cross-type splicing, forged/cross-profile evidence, neutral-only folds, and
end-to-end profile selection. The phase was reopened; no later phase is being
credited with these repairs.

### Review 1 Remediation

- Completed fixed arities are checked at construction, mutation, adapter
  import, and saturation boundaries. Ternary JOIN, ARROW, and equality fail
  closed.
- Same-head flattening now compares profile, arity policy, sibling quotient,
  flat/unit licenses, metatype, Boolean result kind, and normalized carrier
  type. Cross-type splicing is rejected.
- Neutral-only Boolean folds smart-construct `true`/`false`; a nullary `K+`
  carrier is never stored.
- `SemanticProfile` is threaded from `IRAgent` through `Canonical`, the
  adapter, certified artifact, e-node structural keys, and repair projection.
  Cross-profile adoption and e-class union fail closed.
- Production container laws are issued only by the fixed
  `AlloyLawRegistry`. Evidence binds the fixed source-theory digest, exact
  profile, operator, result and element schemas, root path, arity policy, law
  index, law parameter, provenance, and distinct source endpoints. The public
  certificate constructor was removed.
- `CertifiedSemanticArtifact` rejects fixture authority and profile/operator
  replay. `RepairProjection` retains and checks exact declarations instead of
  reducing evidence to an opcode-to-container-kind map.
- The adapter retains every distinct exact declaration for one operator;
  declarations sharing only `BAG` or `SET` no longer overwrite one another.

## Verification After Review 1 Remediation

- `TheoryLawPolicyRegressionTest`: 171 checks pass.
- `CanonicalAlloyPipelineTest`: 188 checks pass.
- `TheoryCertificatesTest`: 252 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full.

### Bounded Integration Findings

1. Exact semantic arity was initially applied to source envelope nodes such as
   `PREDICATE`, whose external grammar contains an arbitrary parameter list
   plus a body. The construction and completed-shape checks now exempt only
   the enumerated source wrappers; semantic operators remain exact.
2. The Phase 1 wrong-child-count CALL fixture attempted to manufacture a
   malformed node and wait for the metric boundary to reject it. Exact arity
   now rejects that mutation immediately, so the regression asserts the
   stronger e-node boundary while retaining separate adapter and metric
   authority/arity checks.

### Review 2: FAIL

The second independent reviewer found that the first remediation had not yet
closed the complete law boundary:

1. `NormalForm` retained an opcode-only flattening path for relational union
   and intersection, bypassing the typed/profile-indexed e-node predicate.
2. `ContainerLawDeclaration`, `OperatorDeclaration`, and strict node
   verification did not bind embedded certificates to the enclosing exact
   operator instance. Declaration equality also erased certificate identity.
3. Fixture-authority certificates could still normalize nodes inside a strict
   graph even though the detached artifact registry rejected them.
4. Relation arity and column types were still collapsed to `AlloyRel`.
5. The source-theory registry admitted caller-invented profiles instead of a
   closed set of independently authorized fingerprints.
6. Generic law-family endpoints did not retain the concrete permutation,
   quotient, splice arities/position, and source endpoints required for an
   individual normalization.
7. Fast-IR flattening did not compose a child invocation's slot map while
   splicing grandchildren.
8. Parsed semantic `disjoint` was conflated with `DISJOINT_LIST` and could
   retain a set metatype although its law family is Boolean.
9. E-class union did not reject underfilled fixed occurrences.
10. Fail-closed omission of container-law serialization was not documented.

The reviewer also required full-pipeline negative tests for each replay and
typing boundary. Phase 2 remains open; this failed review is retained as part
of the audit history.

### Review 2 Remediation

- `NormalForm` now retains a separate post-prenex/NNF, pre-ACI matrix for
  source-law replay. The Fast Rewrite IR matrix continues through its
  established ACI normalization and saturation, while the certified adapter
  sees the actual nested source applications. Relational binder domains no
  longer run an earlier ACI fold that would erase their splice structure.
- `FlatConstructionCertificate` binds one visible `FlatApplication` to the
  exact typed target node. It records the semantic profile, complete
  `InstantiatedOperator`, root `PortPath`, source and target endpoints, every
  outer/nested arity and splice position, and the exact C/I occurrence fibers.
- `ContainerConstructionCertificate` provides the corresponding concrete
  source replay for nonflat C/I containers. Equality, inequality, IFF,
  overflow-forbidding integer add/multiply, and `disjoint` can no longer jump
  directly from ordered source operands to a normalized bag. Every
  ordered-to-bag quotient cites the exact C theory index, including an
  identity permutation; set deduplication additionally requires I.
- Production constructions are checked against the independently fixed
  `AlloyLawRegistry`. The semantic artifact rejects every stored law-bearing
  operator instance that lacks the appropriate concrete flat or nonflat
  construction proof.
- Exact occurrence types now have a visit counter independent of structural
  TOV bookkeeping. Relation arity and column types flow from Alloy `Type`
  through `ExactAlloyType`, `EGraphNode`, `GraphType`, operator schemas, and
  certificate indices. Parsed regressions retain `S->T`, `T->S`,
  `State->Event->State`, and `Event->State` as different structural types.
- `RepairProjection` now carries each certified binding-slot type beside its
  source aliases. This closed a bounded-test failure where a predicate
  parameter was certified as `Parameter0(AlloyCarrier(A))` but reconstructed
  as the weaker `AlloyCarrier(A)` during exact container lookup.
- Fast-IR same-head flattening compares the complete typed/profile policy and
  composes invocation slot maps across a splice. The direct
  `inner->middle->outer` regression observes the composed map.
- E-class union validates completed source arity first; an underfilled fixed
  JOIN occurrence cannot be merged.
- Parsed semantic `DISJOINT` reaches the Boolean result carrier and a nonflat
  bag trace. Duplicate occurrences survive and no I premise is admitted;
  structural `DISJOINT_LIST` remains ordered and law-free.

### Bounded Gate During Review 2 Remediation

The first full bounded run stopped in `CallExtractionRegressionTest`: exact
container lookup exposed the parameter-type reconstruction mismatch described
above. No check was weakened. After carrying certified alias types into the
repair projection, the same complete gate passed.

## Verification After Review 2 Remediation

- `CanonicalAlloyPipelineTest`: 215 checks pass.
- `CallExtractionRegressionTest`: 122 checks pass.
- `TheoryLawPolicyRegressionTest`: 174 checks pass.
- `TheoryCertificatesTest`: 263 checks pass.
- `TheoryPortsTest`: 1,006 checks pass.
- `TheoryCanonicalizationTest`: 11,186 checks pass.
- `TheoryLeaderKernelTest`: 233 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full.

## Deliberate Limitations

- JOIN and ARROW are semantically associative in suitable relational type
  chains, but the current homogeneous one-port flat schema cannot certify that
  dependent typing. They therefore remain nonflat until a separate typed-chain
  certificate family exists.
- Associativity for integer addition and multiplication is enabled only by the
  explicit modular profile. The default Alloy overflow-forbidding profile
  retains binary commutativity but no flattening.
- The standalone certificate format does not yet encode Seq/Bag/Set law or
  concrete construction certificates. Export therefore fails closed as
  `UNCHECKABLE`; no such evidence may be silently omitted.

### Review 3: FAIL

The third independent reviewer confirmed the earlier flattening, typing, and
CALL repairs, but found five remaining enforcement defects:

1. A default strict graph could consume `TEST_ONLY` container-law authority;
   production authority was enforced only when the final semantic artifact
   was assembled.
2. Construction coverage was keyed by operator type rather than by the exact
   normalized target node, allowing one occurrence to cover a distinct
   same-headed occurrence.
3. The fixed Alloy registry did not reject Boolean operators over non-Boolean
   carriers or relational operators over non-relational carriers.
4. A Set quotient deduplicated `A op A` to a unary stored operator instead of
   smart-constructing the sole operand.
5. An unrelated concrete construction certificate could be dropped by the
   currently unsupported export slice instead of forcing `UNCHECKABLE`.

The reviewer also identified an ambiguity in the supplied prose, which names
the semantic disjoint-operand collection as a commutative duplicate-retaining
bag while requiring `DISJOINT_LIST` to remain an ordered role-bearing list.
The moving implementation now assigns distinct identities: formula-level
`DISJOINT` is a C-only Bag+, while `DISJOINT_LIST`, declaration, argument, and
total-order list structures remain ordered. This resolution is guarded by permutation,
duplicate-preservation, and role-swap regressions.

Phase 2 remains open until all Review 3 findings are remediated and a fresh
independent reviewer returns PASS.

### Review 3 Remediation

- Graph authority is now part of graph state. The default certified graph
  requires an authorized production `SemanticProfile` and validates every
  law-bearing node at canonicalization and insertion time with production
  authority. A separate certificate-enforcing `TEST_ONLY` graph exists only
  for synthetic law fixtures; structural mode still cannot manufacture
  proof-bearing results. The bounded gate exposed and corrected three tests
  that had inserted fixture evidence through the production constructor.
- Construction coverage is now a multiset equality over exact canonical
  target shapes, not an operator-name inventory. Missing, duplicate, and
  extraneous source-occurrence evidence are rejected. Targets are
  canonicalized under the artifact's coherent witness family so alpha-context
  presentation cannot weaken or spuriously fail the comparison.
- `AlloyLawRegistry` now enforces carrier-specific signatures: AND, OR, and
  IFF are Boolean; PLUS and INTERSECT are homogeneous exact relation
  operators; formula-level `DISJOINT` consumes exact relations and
  returns Boolean. Negative policy tests reject every cross-carrier variant.
- ACI Set construction now smart-collapses a one-element quotient to that
  operand. `TypedCertificateEndpoint.ONE_TERM` and a singleton
  `FlatConstructionCertificate` retain a concrete proof from the original
  application to the returned operand. Parsed duplicate AND, OR, union, and
  intersection regressions certify equality and repair distance zero against
  their bare operand.
- Standalone certificate export now rejects every artifact carrying a flat or
  nonflat concrete construction certificate. Because the present bundle
  format cannot encode those proof objects, export is explicitly
  `UNCHECKABLE`; unsupported evidence can no longer disappear from an
  apparently complete bundle.

### Bounded Gate After Review 3 Remediation

- `CanonicalAlloyPipelineTest`: 242 checks pass.
- `CallExtractionRegressionTest`: 122 checks pass.
- `TheoryLawPolicyRegressionTest`: 180 checks pass.
- `TheoryCertificatesTest`: 273 checks pass.
- `TheoryStateTest`: 4,205 checks pass.
- `TheoryCanonicalizationTest`: 11,186 checks pass.
- `TheoryRebuildTest`: 104 checks pass.
- `TheoryFiniteUnfoldingTest`: 424 checks pass.
- `TheoryDeterminismTest`: 47 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full, including the
  distance-artifact regeneration smoke test.

Phase 2 remains open pending a fresh independent adversarial review of this
remediation.

### Review 4: FAIL

The fourth independent reviewer reproduced three remaining defects with a
standalone adversarial probe:

1. Public `TypedENode.flatConstruct` could flatten and deduplicate an
   authorized ACI operator without returning concrete construction evidence.
   The resulting unary operator was accepted by production canonicalization
   and insertion instead of smart-collapsing to its operand.
2. Singleton flat certificates were checked only for a reachable leaf, not
   against an exact required-source ledger. An unrelated OR singleton proof
   could be appended to an AND artifact. Nonflat constructions also lacked the
   flat ledger's duplicate-source check.
3. A valid heterogeneous Alloy formula such as `disj[S,T]` parsed but failed
   certification: the adapter produced an explicit comparable-carrier type
   while the fixed registry admitted only a homogeneous relation carrier.

The reviewer confirmed that production rejects `TEST_ONLY` laws, malformed
Boolean/relational law carriers fail closed, ordinary node-target construction
coverage is exact, certified singleton collapse works on the adapter path, and
unsupported construction export is `UNCHECKABLE`. Phase 2 remains open while
the three surviving defects are repaired.

### Review 4 Remediation

- The proof-free `flatConstruct` entry now accepts only structural declarations
  or `TEST_ONLY` law evidence. An `ALLOY_PROFILE_THEORY` operator must use
  `flatConstructCertified`, which returns the concrete source replay together
  with either the normalized node or its smart-collapsed singleton. A direct
  duplicate-AND regression proves the raw production path rejects and the
  certified path returns the sole operand.
- `ConstructionSourceLedger` is collected independently by the Alloy adapter
  from every flat and nonflat source application before certificate creation.
  Artifact publication requires exact source-endpoint multisets for both
  certificate families in addition to exact stored-node target coverage.
  Singleton, duplicate, omitted, cross-artifact, and extra nonflat evidence now
  fail closed. Singleton invocations must also match the complete registered
  e-class interface, and every construction must cite an exact law present in
  the artifact registry.
- The fixed disjoint law admits either one exact relation carrier or an
  explicitly represented family whose alternatives are all relations of one
  arity. `disj[S,T]` now parses, adapts, and retains concrete C evidence;
  comparable carriers containing a nonrelation or mixed arities reject.
  Equality keeps its broader established alignment carrier. The first full
  gate caught an over-broad shared-carrier restriction, and the restriction was
  narrowed to disjoint law admission without weakening its guard.

### Bounded Gate After Review 4 Remediation

- `CanonicalAlloyPipelineTest`: 249 checks pass.
- `TheoryLawPolicyRegressionTest`: 182 checks pass.
- `TheoryCertificatesTest`: 275 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full, including all prior
  theory suites and distance-artifact regeneration smoke.

Phase 2 remains open pending another fresh independent adversarial review.

### Review 5: NO VERDICT

The independent-agent service rejected the review request as a possible
cybersecurity task before returning findings. It made no workspace changes and
provided neither PASS nor FAIL. This execution failure is retained in the
record and does not close Phase 2; a separately instantiated reviewer follows.

### Review 6: FAIL

The replacement reviewer confirmed the Review 4 repairs, then found two
remaining public-boundary defects:

1. A production C-only operator such as equality could be constructed directly
   with an already normalized `BagPort`. Strict graph canonicalization and
   insertion checked its fixed law declaration but did not require the
   `ContainerConstructionCertificate` that retains ordered source endpoints.
2. A legal unary `Set+` application reached singleton construction, but the
   certificate builder incorrectly required an actual duplicate quotient.
   Unary smart collapse should require no I step.

The reviewer separately confirmed source-ledger multiplicity, singleton and
nonflat omission/duplication rejection, heterogeneous disjoint typing,
production-versus-fixture law authority, typed registry guards, and fail-closed
unsupported export. Phase 2 remains open.

### Review 6 Remediation

- Strict graph canonicalization, certified canonicalization, and insertion now
  have explicit overloads for `CertifiedFlatConstruction` and
  `CertifiedContainerConstruction`. In production mode every law-bearing node
  is rejected by the generic entry point and accepted only when the supplied
  concrete certificate proves that exact node under the graph's semantic
  profile. Law-free nodes remain on the ordinary typed path; test-only graph
  modes remain explicit.
- The Alloy adapter keeps the construction wrapper through insertion instead
  of adding a normalized node and relying on artifact publication to notice
  missing evidence. Ambient unused coordinates are narrowed only after the
  original construction endpoint has been checked. Stored-target replay uses
  a package-private path and cannot claim a new source occurrence.
- Unary Set construction now smart-collapses without an I premise. A
  many-to-one singleton still requires an exact idempotent quotient. Tests
  distinguish unary collapse from duplicate collapse and reject the generic
  nonflat equality path while accepting its proof-carrying counterpart.
- Structural/test flat construction checks every visible nested application,
  preventing a production-authority child from being hidden beneath a fixture
  root and passed to a sealer.

### Bounded Gate After Review 6 Remediation

- `TheoryCertificatesTest`: 280 checks pass.
- `TheoryCoherentInsertionTest`: 18 checks pass after its graph-induced Set
  deduplication fixture was migrated to the proof-carrying API.
- `CanonicalAlloyPipelineTest`: 249 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full, including all theory
  suites and distance-artifact regeneration smoke.

Phase 2 remains open pending a new independent review.

### Review 7: FAIL

The next reviewer confirmed the proof-carrying ordinary canonicalization and
insertion APIs, unary-versus-idempotent singleton behavior, recursive fixture
authority check, source ledgers, disjoint typing, and fail-closed export. It
then located two alternate public surfaces:

1. Direct leader-kernel extraction and the public production/exhaustive
   canonicalizer classes could consume a raw normalized law-bearing node
   without the construction wrapper required by the graph facade.
2. Fixed-batch certified record admission checked generic operator laws and a
   shape equation but had no exact construction-evidence argument for
   law-bearing shapes.

Phase 2 remains open until internal replay is inaccessible as source admission
and fixed-batch construction coverage is exact.

### Review 7 Remediation

- Leader-kernel extraction and the exhaustive reference canonicalizer are now
  package-confined already-authorized replay. The production canonicalizer
  remains a public version-bearing type for experiment manifests, but its
  singleton accessor is package-confined; source callers enter through the
  construction-aware graph facade. Reflection regressions guard these
  visibility boundaries.
- Fixed-batch admission is also package-confined and computes the exact set of
  law-bearing shapes. Its construction map must match that set exactly. Each
  concrete source certificate is verified under the graph profile and its
  target is independently canonicalized to the claimed batch shape before any
  class, hash owner, or equation is installed.
- `CertifiedCanonicalizationResult` now retains both the concrete source
  construction and the composed proof from that source endpoint through
  ambient-context narrowing to the leader kernel. Insertion provenance retains
  this replay rather than merely checking and dropping the wrapper.

### Bounded Gate After Review 7 Remediation

- `TheoryCertificatesTest`: 287 checks pass, including fixed-batch rejection,
  proof-carrying acceptance, and API visibility checks.
- `TheoryCoherentInsertionTest`: 19 checks pass, including retained ordered
  source replay.
- `CanonicalAlloyPipelineTest`: 249 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full.

Phase 2 remains open pending another independently instantiated review.

### Review 8: FAIL

The fresh independent reviewer confirmed the Review 7 API-confinement,
construction-replay, source-ledger, singleton, arity, typing, and export
repairs. It found one remaining transactional defect in fixed-batch admission:

- construction-target validation used ordinary production canonicalization;
  when a target referred to the bottom of a multi-edge union-find chain, that
  lookup could path-compress the chain before a later malformed shape equation
  rejected the batch. No class or hash owner was installed, but the rejected
  transition had still mutated union-find state without a fixed-batch trace.

The reviewer required either a read-only preflight or a complete snapshot
validation before mutation. It also recorded the residual trust assumption
that package confinement is an implementation boundary, not a Java-module or
hostile-classloader security boundary. Phase 2 remains open while rejected
fixed-batch admission is made observationally pure.

### Review 8 Remediation

- Production canonicalization now has a package-confined non-compressing mode.
  Leader-kernel extraction threads that mode through every nested port and
  uses union-find's existing provenance-preserving read-only lookup.
- Fixed-batch construction preflight uses the non-compressing mode. All
  construction targets, child-leader constraints, and exact shape equations
  are therefore validated before the first union-find registration, class
  insertion, hash-owner update, parent-use update, or revision increment.
- A regression constructs a quiescent strict graph whose bottom class has a
  two-edge parent path, submits exact construction evidence with a malformed
  shape equation, and proves that rejection preserves the complete structural
  graph key, the two-edge path, and the absence of the proposed owner.

### Bounded Gate After Review 8 Remediation

- `TheoryCertificatesTest`: 292 checks pass.
- `TheoryCoherentInsertionTest`: 19 checks pass.
- `CanonicalAlloyPipelineTest`: 249 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full, including all prior
  theory suites and the distance-artifact regeneration smoke test.

Phase 2 remains open pending a newly instantiated independent review.

### Review 9: NO VERDICT

The independent-agent service ran the review for several minutes and then
rejected the request under its automated content filter. It returned no
finding and made no workspace change. This service failure is retained in the
record and does not count as either approval or rejection; the exact green
workspace is being submitted to another independently instantiated correctness
reviewer with neutral terminology.

### Review 10: FAIL

The replacement correctness reviewer confirmed the non-compressing fixed-batch
repair and all other reviewed Phase 2 law, arity, carrier, graph-admission, and
fail-closed export obligations. It found one remaining publication-boundary
defect:

- `ConstructionSourceLedger.builder`, its recording methods, and the complete
  `CertifiedSemanticArtifact` constructor were all public. A caller could
  duplicate or add an unrelated singleton construction certificate, then mint
  a correspondingly inflated ledger. Source-count equality would accept the
  caller's two mutually supporting claims, while singleton collapse has no
  stored operator target whose multiplicity could expose the extra evidence.

The production adapter's own traversal collected the right ledger, but public
callers could replace that independent observation. Phase 2 remains open until
only the trusted adapter publication path can mint source coverage and complete
semantic artifacts; callers may inspect published evidence but may not create
its authority.

### Review 10 Remediation

- `TheoryAlloyAdapter` now resides inside the trusted theory package. This is
  the sole production path that can mint a construction-source ledger and call
  the complete semantic-artifact constructors.
- `ConstructionSourceLedger.builder`, `empty`, its builder type, recording
  operations, and `build` are package-confined. Both
  `CertifiedSemanticArtifact` constructors are package-confined as well.
- Public callers retain read-only artifact access. The two public replacement
  helpers always reuse the artifact's immutable adapter-collected ledger, so
  they are useful for validation and tests but cannot authorize added source
  occurrences.
- Regressions verify that neither artifact constructors nor ledger minting are
  public, and that duplicating an accepted singleton certificate is rejected
  against the original ledger. Existing omitted, cross-artifact, duplicate
  nonflat, and extra flat evidence regressions remain intact.

### Bounded Gate After Review 10 Remediation

- `CanonicalAlloyPipelineTest`: 250 checks pass.
- `TheoryCertificatesTest`: 294 checks pass.
- `TheoryLawPolicyRegressionTest`: 182 checks pass.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full, including every
  prior theory suite and the distance-artifact regeneration smoke test.

Phase 2 remains open pending another independent correctness review.

### Final Review

**PASS.** The independent reviewer reproduced the publication-boundary audit
and found no remaining Phase 2 correctness blocker. It confirmed that ledger
minting and complete artifact construction are package-confined, public
replacement helpers retain the original immutable ledger, duplicate or
extraneous evidence cannot inflate source authority, and fixed-batch rejection
is read-only through its complete preflight. It also reconfirmed arity closure,
flat typing and units, the conservative Alloy matrix, exact profile/type/path
law authority, and fail-closed unsupported export.

## Deliberate Limitations

- Package confinement is an implementation trust boundary, not a Java-module
  or hostile-classloader security boundary.
- JOIN and ARROW remain fixed binary and nonflat until a dependent typed-chain
  certificate family is designed.
- Integer associativity is admitted only in the authorized modular profile.
- The current standalone bundle format returns `UNCHECKABLE` for container-law
  and construction evidence. Versioned support is a Phase 3/4 blocker and is
  not represented as completed serialization.
- No corpus experiment was run during Phase 2.

### Post-Review Producer Gate: FAIL

The first v3 producer/verifier harness run exposed a legitimate-source
rejection that the bounded Java gate did not cover. Two distinct OR source
occurrences in `deliberatelyUnsupported` hash-consed to one stored canonical
shape. Source evidence correctly retained multiplicity two, but artifact
validation incorrectly required its target multiplicity to equal the one live
stored shape.

The invariants are different: source coverage is an exact multiset, while
stored target coverage is an exact set because hash-consing may merge many
source occurrences into one live node. Phase 2 is reopened until that
distinction is implemented, the producer/verifier smoke is part of the bounded
gate, and another independent review confirms that loosening target
multiplicity does not reintroduce ledger inflation.

### Post-Review Producer Gate Remediation

- Construction source endpoints remain an exact multiset and are compared
  against the package-confined adapter ledger.
- Live law-bearing targets are now compared as exact sets. Multiple certified
  source occurrences may therefore hash-cons to one live target, while every
  live law-bearing shape still requires at least one concrete source replay.
- Public replacement helpers still cannot alter the original ledger, so an
  added duplicate or unrelated singleton changes the supplied source multiset
  and rejects before target-set coverage can authorize it.
- The standalone verifier and producer/bundle harnesses now run inside
  `run_bounded_ci_java_tests.sh`; this class of producer-only failure is part of
  every future bounded gate.

### Bounded Gate After Producer Remediation

- `CanonicalAlloyPipelineTest`: 250 checks pass.
- `TheoryCertificatesTest`: 294 checks pass.
- Standalone `VerifierTest`: 56 checks pass.
- `CertificateBundleWriterTest`: 62 checks pass in each deterministic run.
- Producer export census: exactly `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.
- `scripts/run_bounded_ci_java_tests.sh`: passes in full, now including the
  standalone verifier, trusted pins, producer inspection, parsed-source PAIR,
  and export-census gates.

Phase 2 remains open pending a final independent review of multiset source
coverage versus set target coverage.

### Final Post-Review

**PASS.** The independent reviewer confirmed that exact source multisets and
exact live-target sets are the correct two coverage domains: genuine repeated
source occurrences may share one hash-consed target, while immutable
adapter-collected ledger counts still reject omitted, duplicate, and unrelated
evidence. It found no regression in authority confinement, fixed-batch
preflight, arity closure, flat typing and units, profiles, carriers, or the
conservative Alloy law matrix. Phase 2 is closed.

That closure statement records the earlier review protocol. It is superseded
by the current five-review gate; Phase 2 is open until `5/5 PASS` is recorded
for one unchanged snapshot.

### Current Cross-Phase Reaudit: FAIL And Remediation

A fresh reviewer found that the semantically equivalent parameterized JOINs
`some ((x.r).r)` and `some (x.(r.r))` received zero and one dependent-chain
certificates respectively. Predicate parameters are stored as
`ParameterN(AlloyCarrier(S))`; the exact leaf prover recognized the inner
carrier but not the authenticated wrapper. This made admissibility depend on
association and produced repair distance `3`.

That attempted v3 repair was later invalidated because readable `ParameterN`
spelling cannot authenticate a semantic type. The live dependent theory is v5;
it retains v4's exact-relation and primitive-singleton leaf proofs, propagates
parameter type evidence independently of spelling, and rejects `ParameterN`
as a typing authority. The A2 fault log retains the failed v3 step as repair
provenance rather than presenting it as a current rule.

`formal/Phase2VariadicLaws.lean` compiles under pinned Lean 4.33.0 and models
the separation of arity, quotient, flat, and unit authority; the exact finite
operator matrix; AC versus ACI multiplicity; and the 4-bit no-overflow
counterexample. It is necessary evidence, not a Java-refinement proof or a
phase PASS. The phase remains open under the complete claim census.
