# Section 3 Repair Claim Ledger

## Gate State

`INCOMPLETE`. This ledger is an input to the finite requirements traceability
matrix defined by `do178c-assurance-plan.md`; it is no longer an unbounded
census of every possible statement in the repository. A scoped requirement is
not eligible for review until its row has both:

1. a deterministic Lean obligation reconstructed from the stated axioms; and
2. an independent implementation/provenance conformance check where the claim
   concerns Java, serialization, replay, or measured data.

Passing repository tests, prose assertions, producer certificates, and prior
review verdicts do not discharge either requirement. `FORMAL-PARTIAL` means a
related theorem compiles but does not yet establish the complete claim.
`IMPLEMENTATION-PARTIAL` means a regression exists but the refinement to the
formal contract has not yet been independently reproduced. Any `BLOCKED` row
blocks its phase and the complete artifact.

Its closed scope is the Section 3 repair boundary listed in the bounded
assurance plan. Phase A2 remains one ordinary member of the seven-phase gate.
No formal result or conformance probe may discharge a different atomic
requirement without an explicit traceability record. Historical empirical
claims and unrelated repository comments are not silently certified by this
ledger; they remain historical or out of scope. Until every scoped requirement
has code, test, formal evidence where required, coverage, and result mappings,
the assurance run remains `INCOMPLETE`.

## Claim Classes

| Code | Meaning | Required evidence |
| --- | --- | --- |
| `U` | Universal logical or semantic claim | Compiled Lean proof; Z3 may only supplement falsification |
| `F` | Finite structural/policy claim | Deterministic exhaustive Lean enumeration |
| `I` | Implementation-conformance claim | Formal contract plus independent probe over the implementation |
| `P` | Provenance/trust-boundary claim | Formal authenticity/injectivity contract plus independent mutation/replay probe |
| `E` | Empirical aggregate | Recompute from hashed inputs plus formally checked aggregation rule |

## Assurance Process Requirements

These finite process requirements are part of the same formal census. They
prevent the assurance mechanism from exempting its own acceptance criteria.

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| A-01 | F/I | Every scoped high-level requirement has at least one atomic low-level requirement. | `AssuranceTraceability.pass_implies_requirements_decomposed` | Traceability checker over the frozen matrix | `BLOCKED` |
| A-02 | F/I | Every low-level requirement maps to implementing code or an explicit fail-closed unsupported boundary. | `AssuranceTraceability.pass_implies_code_or_unsupported_mapping` | Path and symbol validation | `BLOCKED` |
| A-03 | F/I | Every implemented low-level requirement has nominal, boundary, and robustness tests with explicit expected results. | `AssuranceTraceability.pass_implies_three_test_classes` | Test-manifest and assertion inspection | `BLOCKED` |
| A-04 | F/I | Every scoped atomic claim has a compiled Lean obligation with explicit assumptions and no admission token. | `AssuranceTraceability.pass_implies_formal_evidence` | Pinned Lean execution and admission scan | `BLOCKED` |
| A-05 | F/I | Every Java, wire, or data-boundary claim has direct bounded conformance evidence in addition to its Lean contract. | `AssuranceTraceability.pass_implies_direct_conformance` | Boundary and mutation suites | `BLOCKED` |
| A-06 | F/I | Scoped decision logic has complete statement and decision coverage plus MC/DC for semantic decisions, or an independently reviewed disposition. | `AssuranceTraceability.pass_implies_coverage_or_disposition` | Class-byte-bound coverage report | `BLOCKED` |
| A-07 | F/I | Scoped producer-to-verifier data and control couplings have positive and one-field negative tests. | `AssuranceTraceability.pass_implies_coupling_evidence` | Integration and mutation matrix | `BLOCKED` |
| A-08 | F/I | Every assurance execution has explicit time, heap, input-size, and combinatorial bounds, and exhaustion returns `INCOMPLETE` or `FAIL`. | `AssuranceTraceability.pass_implies_resource_bounds` | Timeout/resource harness | `BLOCKED` |
| A-09 | F/I | Byte-identical inputs and configuration produce byte-identical scoped outputs in at least two fresh processes. | `AssuranceTraceability.pass_implies_determinism_evidence` | Fresh-process hash comparison | `BLOCKED` |
| A-10 | F/P | One canonical manifest identifies all scoped source, dependency, toolchain, option, and evidence bytes. | `AssuranceTraceability.pass_implies_manifest_complete` | Independent manifest/hash verification | `BLOCKED` |
| A-11 | F/I | A passing assurance run has no open scoped problem report. | `AssuranceTraceability.pass_implies_no_open_faults` | Fault-register state checker | `BLOCKED` |
| A-12 | F/P | Each phase and the integrated frozen artifact have one fresh independent review bound to the same manifest. | `AssuranceTraceability.pass_implies_independent_reviews` | Authenticated review records and manifest checks | `BLOCKED` |

## Global And Cross-Phase Claims

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| G-01 | U/I | Arity policy, sibling quotient, flattening authority, and unit authority are distinct and cannot imply one another accidentally. | `CrossPhaseContract.policy_fields_are_independently_observable` | Policy-constructor and verifier mutation suite | `FORMAL-PARTIAL` |
| G-02 | U/P | A semantic label cannot create its own law authority; every accepted law is derived from an independently fixed theory. | `accepted_authority_is_fixed_theory_authority`; `label_without_fixed_authority_rejects` | Producer/verifier theory substitution attacks | `FORMAL-PARTIAL` |
| G-03 | U/P | Every law certificate is indexed by profile, exact operator instance, path, carrier, arities, law parameter, and exact endpoints. | `accepted_at_retains_the_complete_index` | One-field-at-a-time replay mutations | `FORMAL-PARTIAL` |
| G-04 | U/I | Missing, malformed, ambiguous, cross-profile, cross-path, cross-type, and cross-arity evidence fails closed. | `any_index_mutation_rejects_replay`; endpoint/digest rejection theorems | Independent malformed-bundle matrix | `FORMAL-PARTIAL` |
| G-05 | U/I | Certified semantic equality implies repair distance zero. | `certified_equality_has_zero_distance` | Pairwise certified-equality differential probe | `FORMAL-PARTIAL` |
| G-06 | U/I | Repair distance zero implies certified semantic equality. | `zero_distance_has_certified_equality` | Exhaustive bounded zero-set checker | `FORMAL-PARTIAL` |
| G-07 | U/I | The established repair metric is preserved over only the faithfully certified admissible alignment space. | `RepairMetricSemantics.alpha_distance_is_exact_pairwise_minimum`; `aci_distance_is_exact_minimum_cost_assignment` | Fast/certified operation-by-operation differential harness | `FORMAL-PARTIAL` |
| G-08 | P | Producer evidence, source ownership, transfer lineage, and verifier replay refer to the same exact source occurrences. | `accepted_binding_preserves_exact_occurrence`; occurrence/lineage rejection theorems | Coordinated omission/substitution/mutation attacks | `FORMAL-PARTIAL` |
| G-09 | I | Unsupported semantic cases remain structural and cannot receive equality authority through a fallback. | `unsupported_cases_cannot_receive_law_authority` | Unsupported-op/profile corpus and unit probes | `FORMAL-PARTIAL` |
| G-10 | I | No missing type is silently replaced by `univ`; explicit `univ` remains available only as an actual source type, not fabricated proof. | `PhaseA2DependentChains.absent_type_does_not_invent_univ` plus cross-phase theorem | Missing-type and polymorphic-chain probes | `FORMAL-PARTIAL` |
| G-11 | P | Serialization is canonical, versioned, byte deterministic, and rejects unsupported ambiguous versions. | Canonical-encoding uniqueness theorem | Independent double export and legacy-version rejection | `BLOCKED` |
| G-12 | I | Parser, IR, certified representation, repair projection, and verifier preserve the information each later proof consumes. | Layer-refinement relation | Boundary-by-boundary source fixtures and mutations | `BLOCKED` |
| G-13 | E/P | Every reported empirical claim is tied to immutable input/output hashes, configuration, profile, toolchain, and one run identity. | Manifest aggregation contract | Independent manifest/hash recomputation | `BLOCKED` |
| G-14 | P | Historical result trees, paper, release assets, frozen manifests, and reproducibility terminal programs are unchanged. | Path-set equality contract | Base-to-worktree byte/hash comparison | `BLOCKED` |
| G-15 | I | All eighteen required adversarial policies are executable in the bounded CI entry point and visible to CI. | Finite test-registration model | Script tracing plus exact test census | `BLOCKED` |
| G-16 | I/P/E | Every correctness-bearing artifact statement is present exactly once in a mechanically checked file-to-claim census and maps to an executed formal obligation plus any required independent conformance or empirical recomputation. | Closed-world claim-coverage and zero-unmapped-count model | Repository claim-census checker over the immutable review snapshot | `BLOCKED` |
| G-17 | I/P | Tests, fixtures, comments, names, exceptions, and documentation cannot assert a stronger authority than the executable proof or verifier path establishes. | Claim-authority monotonicity theorem | One-surface-at-a-time authority audit and mutation suite | `BLOCKED` |
| G-18 | E/P | Every nonhistorical numeric or comparative statement is recomputable from named hashed inputs and is rejected when its manifest, configuration, or aggregation contract differs. | Empirical derivation and incompatibility-rejection model | Independent clean recomputation and manifest mutation matrix | `BLOCKED` |

## Phase 1: CALL Extraction And Identity

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| P1-01 | I | A call occurrence captures one stable visit immediately after node creation. | Unique visit ownership model | MASG occurrence probe | `FORMAL-PARTIAL` |
| P1-02 | U/I | Callee, every argument, and END belong to that exact visit. | `ValidVisit` ownership obligations | Cross-visit edge mutations | `FORMAL-PARTIAL` |
| P1-03 | U/I | A valid call has exactly one callee. | `valid_visit_has_one_callee` | Missing/duplicate callee probes | `FORMAL-PARTIAL` |
| P1-04 | U/I | Argument roles are contiguous `0..declaredArity-1`. | `valid_visit_has_contiguous_ordered_roles` | Gap, duplicate, and swapped-role probes | `FORMAL-PARTIAL` |
| P1-05 | U/I | Argument payload order is source order. | `call_term_equality_preserves_argument_order` | `h[a,b]` versus `h[b,a]` at every boundary | `FORMAL-PARTIAL` |
| P1-06 | U/I | Observed children cannot replace independently declared arity. | `observed_arity_cannot_replace_declared_arity` | Truncated/extended argument mutations | `FORMAL-PARTIAL` |
| P1-07 | U/I | Exactly one terminator exists and is owned by the call occurrence. | `valid_visit_owns_exact_terminator` | Missing, duplicate, foreign, and END-as-argument probes | `FORMAL-PARTIAL` |
| P1-08 | U/I | Malformed or incomplete calls reject; no unrelated-visit fallback exists. | Invalid-visit nonacceptance family | Parser/MASG/IR malformed fixtures | `BLOCKED` |`FORMAL-PARTIAL` |
| P1-09 | U/I | A consumed call occurrence cannot be reused. | `occurrence_ledger_prevents_reuse`; `duplicated_occurrence_is_rejected` | Reused nested occurrence probe | `FORMAL-PARTIAL` |
| P1-10 | U/I | Zero-argument calls retain callee, arity zero, and END. | `zero_argument_call_is_valid` | Zero-argument local/imported fixtures | `FORMAL-PARTIAL` |
| P1-11 | U/I | Semantic identity retains call kind. | `equal_call_keys_preserve_kind` | Function/predicate same-name distinction | `FORMAL-PARTIAL` |
| P1-12 | U/I | Semantic identity retains fully qualified callee identity. | `equal_call_keys_preserve_qualified_identity` | Local/imported/module-instantiation fixtures | `FORMAL-PARTIAL` |
| P1-13 | U/I | Semantic identity retains declared arity. | `equal_call_keys_preserve_declared_arity` | Same-name different-arity key probes | `FORMAL-PARTIAL` |
| P1-14 | U/I | Semantic identity retains independent arity authority. | `equal_call_keys_preserve_authority` | Local/pinned-library/unknown-authority probes | `FORMAL-PARTIAL` |
| P1-15 | I/P | Imported callable arity is accepted only from a fixed library ledger. | Ledger-authenticity model | Unpinned member and corrupted `ord/first` attacks | `BLOCKED` |`FORMAL-PARTIAL` |
| P1-16 | I | CALL remains ordered, nonflat, noncommutative, and non-idempotent. | Phase 2 exact-policy matrix | Nested/mixed/multiargument call probes | `FORMAL-PARTIAL` |
| P1-17 | I | Generator output preserves exact call identity and source argument order. | `generation_preserves_source_order` | Parse-generate-reparse comparison | `FORMAL-PARTIAL` |
| P1-18 | U/I | On a two-atom `r` cycle, `f[f[a]] = a` differs semantically from `f[a] = a`. | `nested_call_differs_from_single`; `nested_call_returns_input` | Independent Alloy instance evaluation | `FORMAL-PARTIAL` |
| P1-19 | I | `f[g[a]]` preserves both distinct callees and nested ownership at all boundaries. | Nested-key composition theorem | Parser/MASG/IR/adapter/wire fixture | `BLOCKED` |`FORMAL-PARTIAL` |
| P1-20 | P | Serialized call evidence retains occurrence, callee, kind, arity authority, role, order, and endpoint identity. | Wire injectivity theorem | One-field-at-a-time serialized mutations | `BLOCKED` |`FORMAL-PARTIAL` |

## Phase A2: Dependent JOIN And ARROW Chains

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| A2-01 | U/I | JOIN and ARROW chain carriers are ordered `Seq`, never `Bag` or `Set`. | `arrow_order_is_observable` plus JOIN order theorem | Role-swap certificate attacks | `FORMAL-PARTIAL` |
| A2-02 | U/I | Duplicate chain operands are retained. | `arrow_duplicate_is_preserved` plus JOIN analogue | Duplicate-operand probes | `FORMAL-PARTIAL` |
| A2-03 | U | ARROW/product reassociation preserves ordered column concatenation. | `arrow_reassociation` | Parsed association pair | `FORMAL-PARTIAL` |
| A2-04 | U | Relational JOIN reassociation is licensed only when every interior relation has arity at least two. | `guarded_join_relation_reassociation` | Parsed guarded association pairs | `FORMAL-PARTIAL` |
| A2-05 | U | Unguarded JOIN reassociation is unsound when an interior relation is unary. | `unguarded_join_is_not_associative` | Exact finite Alloy counterexample | `FORMAL-PARTIAL` |
| A2-06 | F/I | The implementation's JOIN guard accepts binary interiors and rejects unary interiors. | `unary_interior_join_has_no_flat_license`; `binary_interior_join_has_flat_license` | Theory and pipeline probes | `FORMAL-PARTIAL` |
| A2-07 | U/I | Each chain leaf has an independent exact stored-type-to-relation-view proof. | `exact_relation_leaf`; primitive leaf theorems | Leaf rule/proof mutation matrix | `FORMAL-PARTIAL` |
| A2-08 | U/I | Only exact relation and primitive singleton stored-type-to-relation-view rules are admitted; source spelling such as `ParameterN` has no independent typing authority. | `successful_relation_view_has_only_two_rule_families`; `parameter_spelling_has_no_independent_authority` | Unsupported constructor and forged parameter probes | `FORMAL-REPAIRED` |
| A2-09 | U/I | Missing or unsupported leaf typing cannot invent `univ` or a flat certificate. | `unsupported_leaf_has_no_proof`; `absent_type_does_not_invent_univ`; `explicit_polymorphism_receives_no_flat_certificate` | Null/missing/polymorphic probes | `FORMAL-PARTIAL` |
| A2-10 | U/I | Every adjacent chain boundary type matches exactly and determines the exact result columns. | Dependent fold soundness theorem | Boundary/result mutation probes | `BLOCKED` |`FORMAL-PARTIAL` |
| A2-11 | P | Certificate identity binds kind, profile, source association, exact operand types, result, target, theory version, and digest. | `ChainIndex` injectivity plus full certificate theorem | One-index-at-a-time replay attacks | `FORMAL-PARTIAL` |
| A2-12 | P | A certificate binds one deterministic source occurrence path and exact source content. | `accepted_binding_has_exact_path_and_content` | Same-typed source swap and post-cert mutation | `FORMAL-PARTIAL` |
| A2-13 | P | Certificate source commitment includes the independently replayed typed source, not an opaque producer token. | `accepted_binding_certificate_commits_to_source` | Typed-source and certificate-source substitutions | `FORMAL-PARTIAL` |
| A2-14 | P | Transfer lineage is functional and one certificate cannot replay over two roots. | `lineage_transfer_is_functional`; `one_certificate_cannot_replay_over_two_roots` | Transfer/reuse attacks | `FORMAL-PARTIAL` |
| A2-15 | I/P | Construction occurs only for a concrete source application already recorded in the source ledger. | Source-ledger admission theorem | Omitted/extra/unreferenced evidence probes | `BLOCKED` |`FORMAL-PARTIAL` |
| A2-16 | I | Unsupported chains fall back to exact fixed-binary structure and receive no equality authority. | Nonadmission theorem | `x.*r`, unary-interior JOIN, malformed chain probes | `BLOCKED` |`FORMAL-PARTIAL` |
| A2-17 | U/I | Repair projection flattens only an artifact-admitted immutable occurrence binding and rechecks every bound index. | Binding acceptance theorems | Projection swap/mutation/detached-cert probes | `FORMAL-PARTIAL` |
| A2-18 | U/I | Readable source spelling is not an edit, while exact semantic type change is one edit. | `readable_spelling_is_not_an_edit`; `exact_type_change_is_one_edit` | Metric atom probes | `FORMAL-PARTIAL` |
| A2-19 | U/I | Licensed reassociations are certified equal and have distance zero; unlicensed associations remain nonzero. | Cross-phase metric-kernel theorem | Parsed JOIN/ARROW distance probes | `BLOCKED` |`FORMAL-PARTIAL` |
| A2-20 | P | Wire replay independently reconstructs commitments, source trees, leaf rules/proofs, applications, and dependent positional schemas. | Wire grammar/replay theorem | Complete scalar/tree mutation matrix | `BLOCKED` |`FORMAL-PARTIAL` |

## Phase 2: Variadic Structure And Algebraic Laws

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| P2-01 | U/I | Flexible arity does not imply associativity. | `ordinary_seq_plus_has_no_associativity_license` | Constructor and registry probes | `FORMAL-PARTIAL` |
| P2-02 | U/I | `ArityPolicy`, `SiblingQuotient`, `FlatLicense`, and `UnitLicense` are represented independently. | Policy product/separation theorem | Java API construction matrix | `BLOCKED` |
| P2-03 | U | Set ports satisfy positive downward closure. | `invalid_set_downward_closure_rejects` | Invalid arity-set constructors | `FORMAL-PARTIAL` |
| P2-04 | U | Flat ports satisfy splice closure. | `invalid_flat_splice_closure_rejects` | Invalid splice-set constructors | `FORMAL-PARTIAL` |
| P2-05 | U/I | A flat port has exactly one root-container source argument. | Flat-source schema theorem | Multi-port/cross-argument flatten attacks | `BLOCKED` |
| P2-06 | U/I | Flat element type equals result type at the same exact operator instantiation. | Homogeneous flat typing theorem | Cross-type/operator mutations | `BLOCKED` |
| P2-07 | U/I | A zero-admitting flat port requires both A and exact U; ordinary nonflat zero arity requires neither. | `ordinary_zero_arity_needs_no_unit`; flat-zero theorems | Constructor/replay matrix | `FORMAL-PARTIAL` |
| P2-08 | U/I | Nonempty variadic policies reject an empty stored container. | `nonempty_variadic_rejects_empty_storage` | Empty container probes | `FORMAL-PARTIAL` |
| P2-09 | F/I | Formula AND/OR and relation UNION/INTERSECTION are exactly flat nonempty ACI `Set` operators. | Exact whitelist and `flat_set_plus_is_ACI_without_unit` | Opcode/profile registry census | `FORMAL-PARTIAL` |
| P2-10 | F/I | Modular integer ADD/MUL are exactly flat nonempty AC `Bag` operators in the proved modular profile. | `integer_flattening_is_profile_bounded` | Bitwidth/profile registry census | `FORMAL-PARTIAL` |
| P2-11 | U/I | Overflow-forbidding integer mode disables reassociation. | `no_overflow_addition_reassociation_is_unsound` | 4-bit `(7+1)+(-1)` parsed regression | `FORMAL-PARTIAL` |
| P2-12 | F/I | Homogeneous policy keeps JOIN and ARROW fixed binary and nonflat; dependent A2 authority is separate. | Exact whitelist exclusion | Registry and cross-family evidence attacks | `FORMAL-PARTIAL` |
| P2-13 | F/I | Equality, inequality, and pre-elimination IFF are nonflat `Bag=2` with C only. | `equality_inequality_and_iff_are_C_not_A_or_I` | Association/flatten mutation probes | `FORMAL-PARTIAL` |
| P2-14 | U/I | The semantic `DISJOINT` operator is a nonflat commutative bag retaining multiplicity. | `disjoint_is_nonflat_bag`; `bag_retains_duplicate_occurrences`; `semantic_disjoint_and_structural_disjoint_list_are_distinct` | Parser-to-IR semantic-disjoint duplicate/order fixtures | `FORMAL-PARTIAL` |
| P2-15 | F/I | CALL, LIST, the distinct structural `DISJOINT_LIST`, TOTALORDER_LIST, binders, declarations, and all other role-sensitive forms are ordered and nonflat. | `calls_joins_arrows_lists_binders_and_decls_are_not_flat`; `semantic_disjoint_and_structural_disjoint_list_are_distinct` | Exact registry negative census and structural-list order probe | `FORMAL-PARTIAL` |
| P2-16 | U/I | Boolean empty/singleton forms collapse only by smart constructors; stored flat Boolean carriers remain nonempty and mint no U. | Boolean smart-constructor theorem | Empty/singleton certificate census | `BLOCKED` |
| P2-17 | U/I | Bag normalization preserves multiplicity; Set normalization is idempotent; Seq preserves order. | multiplicity/idempotence/order theorems | Duplicate and role-swap differential probes | `FORMAL-PARTIAL` |
| P2-18 | P | C binds an exact permutation; I binds an exact quotient surjection; A binds outer/nested arities and splice position; U binds exact empty/deletion endpoints. | Law-witness typing theorem | One-field-at-a-time certificate mutations | `BLOCKED` |
| P2-19 | P | A law can be issued only for the exact fixed registry entry and semantic profile fingerprint. | Registry-authenticity theorem | Cross-op/profile/theory attacks | `BLOCKED` |
| P2-20 | I | Recursive same-head flattening occurs iff exact typed A evidence is present. | Flatten iff authority theorem | Positive and negative recursive fixtures | `BLOCKED` |

## Phase 3: Exact Types, Profiles, And Endpoints

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| P3-01 | U/I | Every relational occurrence retains all exact parser-proved type information from parser through IR, keys, schemas, and certificates: ordered columns when recoverable, and positive arity without invented columns for a statically empty relation. | Exact-type syntax, arity, ordered-column, and empty-information theorems in `Phase3ExactTypesEndpoints.lean` and `Phase3EmptyRelations.lean`; full layer refinement absent | Boundary-by-boundary typed and empty-relation fixtures | `BLOCKED` |
| P3-02 | I | Missing relational occurrence type fails closed rather than using textual or generic `REL` fallback. | `missing_type_fails_closed`; `missing_type_does_not_invent_relation` | Manual missing-type attack | `FORMAL-PARTIAL` |
| P3-03 | P | Profile fingerprint binds bitwidth, overflow, temporal/rewrite modes, and exact signature version. | `profile_payload_is_injective`; cryptographic/encoding refinement absent | One-field profile mutations | `FORMAL-PARTIAL` |
| P3-04 | P | Law evidence binds exact operator identity, result/element types, path, carrier, policy, parameter, endpoints, and fixed theory digest. | `complete_law_index_is_injective` | Cross-index mutation matrix | `FORMAL-PARTIAL` |
| P3-05 | P | Flat evidence binds source tree, splice ledger, and application trace exactly. | Flat replay soundness theorem | Omission/substitution/reorder attacks | `BLOCKED` |
| P3-06 | P | Container evidence binds ordered inputs, normalized outputs, and exact quotient fibers. | Container replay soundness theorem | Fiber/multiplicity/order attacks | `BLOCKED` |
| P3-07 | U/P | Binder alpha conversion is distinct from nonidentity descriptor automorphism. | `alpha_is_not_nonidentity_automorphism` | Identity/nonidentity substitution attacks | `FORMAL-PARTIAL` |
| P3-08 | U/P | Binder evidence binds complete descriptor, occurrence map, automorphism, source root/path/context, and both endpoints. | `complete_binder_index_is_injective` | Cross-descriptor/path/root/context attacks | `FORMAL-PARTIAL` |
| P3-09 | U/P | The verifier reconstructs complete finite descriptor closure and every occurrence conjugation independently. | Closure/replay theorem | Missing-generator/transitivity/conjugation attacks | `BLOCKED` |
| P3-10 | P | Evidence completeness is derived from decoded source/kernel structure, never only producer-authored references. | `obligationFromSource`; `exact_source_obligation_accepts`; complete Java refinement absent | Coordinated record-plus-reference omission | `FORMAL-PARTIAL` |
| P3-11 | P | Construction records are bound to replay-owned exact source identities. | `stale_owner_rejects` | Cross-owner and stale-owner swaps | `FORMAL-PARTIAL` |
| P3-12 | P | Every wire identifier and ordering is independently canonicalized and checked. | Encoding uniqueness theorem | Arbitrary ID/order/text grammar attacks | `BLOCKED` |
| P3-13 | I/P | Certified artifacts retain all evidence required by Layer 3 and independent replay. | `retained_artifact_payload_is_injective`; completeness of represented fields remains open | Drop/detach evidence probes | `FORMAL-PARTIAL` |
| P3-14 | I/P | Repair projection consumes only the exact frozen normalized source owned by its adapter result, and its digest is derived from that result. Post-certification mutation, foreign source identity, and caller-forged digest reject. | `certified_source_mutation_rejects`; `exact_projection_source_accepts`; `stale_projection_source_rejects`; `forged_projection_digest_rejects` | Ordinary-node, binding, topology, occurrence, foreign-source, digest, and concurrent mutation matrix | `FORMAL-PARTIAL` |
| P3-15 | U/I/P | A statically empty relation retains its parser-proved positive tuple arity but no unrecoverable column type is invented. Cross-arity types and metric keys differ; arityless, malformed, historical arity-free, argument-bearing, and stable-key-inconsistent encodings reject; column-dependent JOIN/ARROW proof remains unavailable. | `Phase3EmptyRelations.parser_retains_arity`; `no_decoder_recovers_both_parent_column_orders`; `arityless_empty_fails_closed`; `empty_graph_arity_is_injective`; carrier, metric, and `decodeEmpty` rejection theorems | Parser/MASG/IR/metric/writer/verifier/visualization/serialization mutation matrix | `FORMAL-PARTIAL` |
| P3-16 | U/I/P | A production profile is derived from exactly one selected source command and its execution options before canonicalization. Width, overflow, temporal bounds, and semantic implementation versions that differ cannot share a profile; missing or ambiguous selection and cross-profile comparison reject. | Fixed-selector counterexamples, exact-selection, parser-ownership, authority, preserved-zero-width, `compact_preserves_profile`, and cross-profile theorems in `Phase3SemanticProfile.lean` | The parser-owned extractor and full/compact rejection are implemented; production defaults, exact options partition, cache inventory, export, and verifier replay remain refuted/open | `REFUTED/IMPLEMENTATION-PARTIAL` |

## Phase 4: Collision Ownership And Rebuild

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| P4-01 | U/I | At every quiescent public observation reachable through supported graph operations, the bucket for each exact canonical shape stored by a live leader is the deterministic finite set of exactly its live leader owners and is therefore nonempty. | Extensional live-owner membership, permutation/duplicate invariance, finite nonempty enumeration, supported-transition preservation, and exact public-observation theorems in `Phase4CollisionBuckets.lean` | Empty, one-owner, two-owner, insertion-order, duplicate-record, dirty-observation, rebuild/union/restriction, and live-leader checks | `FORMAL-REPAIRED/IMPLEMENTATION-PARTIAL` |
| P4-02 | U/I | Equal shape proposes but does not force a union. | `failed_collision_preserves_both_owners` | Incomparable-interface fixture | `FORMAL-REPAIRED/DIRECT-BOUNDED` |
| P4-03 | U/I | Both directed interface orientations are tried deterministically. | `second_orientation_is_considered`; `evaluation_records_both_directed_attempts` | Instrumented two-orientation probe | `FORMAL-REPAIRED/DIRECT-BOUNDED` |
| P4-04 | U/P | A parent is installed only with a typed embedding and exact directed parent-certificate endpoint. | `admission_requires_an_orientation`; complete Java refinement absent | Missing/wrong-direction proof attacks | `FORMAL-PARTIAL/DIRECT-BOUNDED` |
| P4-05 | U/I | If neither direction is inhabitable, both leaders remain live in the same bucket. | `incomparable_decision_preserves_coexistence` | `{x:Int}`/`{y:Bool}` and same-type distinct-coordinate fixtures | `FORMAL-REPAIRED/DIRECT-BOUNDED` |
| P4-06 | U/P | Every absorbed live record is rehomed with rebuilt e-class proof or explicitly retired with evidence. | Finite partition, retirement, and exact transition-frame theorems; universal JVM refinement absent | Post-union deletion, forged ledger, malformed topology, and schema-v8 replay mutations | `FORMAL-PARTIAL/DIRECT-BOUNDED` |
| P4-07 | U/I | Hash ownership and reverse uses are owner-qualified; no shape-only alias remains. | `canonical_preimage_is_injective`; cryptographic refinement absent | Dual-owner and malformed-wire fixtures | `FORMAL-PARTIAL/DIRECT-BOUNDED` |
| P4-08 | U/I | Hash index is rebuilt after interface changes. | Exact finite supported-operation observation theorems; whole-program refinement absent | Interface-change/relookup and invariant fixtures | `FORMAL-PARTIAL/DIRECT-BOUNDED` |
| P4-09 | U/I | Incompatibility memoization is invalidated by every compatibility-bearing record change and cannot suppress a later valid union. | `revision_only_memo_is_unsound`; `changed_record_is_reconsidered` | Same-revision incompatible-then-compatible witness transition and unexpected-error attack | `FORMAL-REPAIRED/DIRECT-BOUNDED` |
| P4-10 | U/I | Rebuild reaches quiescence on every finite tested state without unsound union. | Admitted unions strictly decrease positive leader count; full transition measure absent | Bounded generated state search and dirty-order permutations | `FORMAL-PARTIAL/IMPLEMENTATION-PARTIAL` |
| P4-11 | P | Shape IDs use one canonical `(owner, canonical term ID)` preimage, are deterministically recomputed, and any observed content-ID collision fails closed. No mathematical SHA-256 injectivity is claimed. | `canonical_preimage_is_injective`; cryptographic refinement absent | Arbitrary/reused/colliding ID and malformed-topology mutations | `FORMAL-PARTIAL/DIRECT-BOUNDED` |
| P4-12 | P | Historical ambiguous graph/certificate versions reject or use one explicit tested migration; no silent reinterpretation. | Version-disjointness theorem | v2 through v7 rejection and v8 acceptance matrix | `FORMAL-PARTIAL` |

## Phase 5: Source-Rule Guards

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| P5-01 | U/I | `set none` admits exactly the empty relation as a binding and is not an empty quantifier domain. | Finite relation-set semantics theorem in `Phase5SourceRules.lean` | Alloy parse/type/lowering regression | `FORMAL-PARTIAL` |
| P5-02 | U/I | `lone none` admits exactly the empty relation as a binding and is not an empty quantifier domain. | Finite relation-set semantics theorem in `Phase5SourceRules.lean` | Alloy parse/type/lowering regression | `FORMAL-PARTIAL` |
| P5-03 | U/I | Bare declaration multiplicity defaults to `one`, not `set`. | Declaration semantics theorem in `Phase5SourceRules.lean` | Bare/one/set parser-lowering fixtures | `FORMAL-PARTIAL` |
| P5-04 | U/I | `none in none` is true because `in` is relational subset. | Empty-subset theorem in `Phase5SourceRules.lean` | Independent Alloy solve and IR rewrite | `FORMAL-PARTIAL` |
| P5-05 | U/I | `x in none -> false` requires a static proof that unary `x` is nonempty. | Subset/nonempty theorems in `Phase5SourceRules.lean` | Unknown, empty, binding-certified-positive probes | `FORMAL-PARTIAL` |
| P5-06 | U/I | Only authenticated ONE or SOME binding tuples authorize static nonemptiness; EXACTLY-of, univ without a separate inhabitant witness, and synthetic opcode labels do not. | Authority enumeration, EXACTLY-of semantics, and empty-universe countermodel in `Phase5SourceRules.lean` | EXACTLY-of, bitwidth-zero, univ, and synthetic opcode-label attacks | `FORMAL-PARTIAL` |
| P5-07 | U/I | `NOT_IN` uses exactly the relational duals and the same nonemptiness authority. | Duality theorems in `Phase5SourceRules.lean` | `none`, `univ`, and binding controls | `FORMAL-PARTIAL` |
| P5-08 | U/I | Empty-domain quantifier simplification fires only after proving the admissible binding set empty. | Quantifier-domain theorem family in `Phase5SourceRules.lean` | `some/all` over bare/set/lone/positive exact `none` | `FORMAL-PARTIAL` |
| P5-09 | U/I | Guarded source rewrites and Boolean negation close before the certified snapshot. | Abstract snapshot-order contract in `Phase5SourceRules.lean` | Certified/fast observation equality probes | `FORMAL-PARTIAL` |
| P5-10 | I | Each higher-order declaration regression reports its command-specific authority: translated SAT/UNSAT, or parser/type/lowering only when translation is unsupported. | Outcome-to-authority and ledger-cardinality theorems | Twelve source-ordered per-command records with mixed translated/unsupported outcomes | `FORMAL-REPAIRED/DIRECT-BOUNDED` |
| P5-11 | U/I | Every ablation engine consumes declaration-derived scoped binding cardinality for guarded `IN`/`NOT_IN`; labels alone never confer authority. | Cross-engine authority-preservation theorem | Five-arm bare/one/some/set/lone, shadowing, and synthetic-label probe | `FORMAL-PARTIAL` |
| P5-12 | U/I | Compound domains statically equal to `none`, including `one (none & A)`, are proved empty before quantifier elimination and certificate lowering. | Intersection-empty and self-difference-empty carrier theorems in `Phase5SourceRules.lean` | Alloy/Kodkod plus raw, Fast Rewrite, and certified differential | `IMPLEMENTATION-PARTIAL` |
| P5-13 | U/P | Standalone certificate equality begins at normalized typed IR; raw Alloy identifiers/hashes are provenance only and grant no source-rewrite authority. | `Phase5SourceRules.existing_trace_kind_cannot_record_source_rewrite` plus trust-boundary separation theorem | Provenance/event-boundary inspection and raw-byte substitution | `FORMAL-PARTIAL` |
| P5-14 | U/I | Alias/De-Bruijn resolution, EXACTLY-of domain equality, and the full guarded quantifier truth table refine the finite relation semantics under nested shadowing. | Complete source-rule refinement theorem | Exhaustive bounded parser/IR differential | `BLOCKED` |
| P5-15 | U/I | Parser encodings of the fixed built-ins `none`/`univ` and unary cardinality tests over `none` normalize identically to their semantic constants without classifying arbitrary signatures as built-ins. | Exact reserved-identity and nonreserved-name theorems in `Phase5SourceRules.lean` plus empty-cardinality semantics | Parser/solver-backed built-in and adversarial `None`/`Univ` differential across certified and five ablation paths | `IMPLEMENTATION-PARTIAL` |

## Phase 6: Determinism, Streaming, And Binder Occurrences

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| P6-01 | U/I | Minimum selection has explicit unset state; Boolean bottom is a valid ordinary candidate. | Option-minimum theorem | Bottom-minimum differential fixture | `BLOCKED` |
| P6-02 | U/I | Production canonicalization and certificate export stream orbit candidates, and verifier minimum selection retains only the least `(shape,witness)` under one declared order; bounded verifier group ledgers and the exhaustive differential oracle are outside the candidate-retention claim. | Streaming/reference equivalence theorem | Instrumented nonmaterialization and differential probe | `BLOCKED` |
| P6-03 | U/I | Witness ordering is total, deterministic, and identical in producer, reference implementation, serialization, and verifier. | Order totality/uniqueness theorem | Cross-run and producer/verifier differential | `BLOCKED` |
| P6-04 | U/I | Nested occurrences of one descriptor have fresh distinct contexts and typed descriptor-to-occurrence bijections. | Freshness/bijection theorem | Nested same-descriptor fixture | `BLOCKED` |
| P6-05 | U/P | Occurrence alignment is preserved through actions, alpha comparison, canonicalization, serialization, and replay. | Action/refinement commutation theorem | Path/context/action mutations | `BLOCKED` |
| P6-06 | U/P | Outer actions are extended by identity over caller slots and recursively through nested port syntax without capture. | Capture-avoidance theorem | Nonempty caller-context and nested action probes | `BLOCKED` |
| P6-07 | F/I | Reported input size, kernel size, path/trace length, global renaming candidates, local quotient work, serialized binder candidates, and certificate bytes have one exact definition each. | Counter aggregation definitions/theorems | Production/reference/writer counter differential | `BLOCKED` |
| P6-08 | I | Certificate byte count equals the emitted file size and all counters are deterministic across byte-identical runs. | Serialization-length theorem | Double-export byte/hash/counter comparison | `BLOCKED` |
| P6-09 | U/P | Binder-occurrence identity commits to the enclosing root as well as local path, descriptor occurrence, and automorphism; rootless replay is impossible. | Rootless-collision counterexample and rooted-key injectivity theorem in `Phase6OrbitCanonicalization.lean` | Two-root/same-path FULL fixture plus root/cross-orbit mutations | `FORMAL-PARTIAL` |
| P6-10 | U/I | No production global or local canonicalization traversal retains a complete list of candidate terms; certificate proof ledgers, standalone verifier completeness ledgers, and the exhaustive differential oracle are outside this candidate-term retention claim. | Stream/materialization refinement theorem | Retained-object instrumentation, including `S7` | `BLOCKED` |
| P6-11 | P | The current rooted-binder, CALL-provenance, exact-transition, and witness-unfold contract is admitted only under schema v8; schema v5 rootless, schema v6 provenance-incomplete, and schema v7 transition-incomplete bytes are never reinterpreted. | Schema-disjointness, rooted-key, transition-feature, and definitional-witness theorems in `Phase6OrbitCanonicalization.lean` | Otherwise-valid v5/v6/v7 relabel mutations and v8 two-root FULL replay | `FORMAL-PARTIAL` |
| P6-12 | U/I/P | Producer canonical-shape order and verifier replay order are the same exact order over the same complete `(shape,witness)` candidate set. | Order-preserving refinement and candidate-set equality theorem | Exhaustive production/verifier differential over free, leader, binder, and container actions | `BLOCKED` |
| P6-13 | U/P | A PAIR result compares the exact independently verified least canonical shapes while preserving separate source-to-kernel derivations. | Pair-composition and observation-ownership theorem | Cross-bundle alpha/context/kernel/shape substitution matrix | `BLOCKED` |

## Repair Metric Claims

| ID | Class | Atomic claim | Formal obligation | Independent conformance evidence | State |
| --- | --- | --- | --- | --- | --- |
| M-01 | U/I | Total repair distance is exactly temporal plus quantifier plus matrix distance. | `RepairMetricSemantics.decomposition_is_additive` | `CanonicalDistance.evaluate` differential probe | `FORMAL-PARTIAL` |
| M-02 | U/I | Quantifier or positional parameter insertion, deletion, or modification of the complete `(quantifier,type,cardinality,disjointness-class)` tuple costs one unit; every declaration-derived binding forced into matrix alignment comes injectively from a selected minimum-cost edit plan, either as a paid modified diagonal or an explicit positional-parameter diagonal. | Quantifier edit/update and selected-correspondence theorems in `RepairMetricSemantics.lean` | Exhaustive finite tuple-operation and typed-correspondence probe | `FORMAL-PARTIAL` |
| M-03 | U/I | Pairwise alpha alignment is the exact minimum over all and only maximum-cardinality certified compatible mappings, pre-seeded only by injective declaration correspondences from a selected minimum quantifier/parameter edit plan. | `alpha_distance_is_exact_pairwise_minimum`; proof-carrying `CertifiedAlphaAlignment`; selected-correspondence authority theorems | Brute-force typed mapping differential, including scope/exchange/fallback rejection | `FORMAL-PARTIAL` |
| M-04 | U/I | ACI child comparison is exact minimum-cost assignment including insertion/deletion alternatives, not positional sorting; unsupported integer totals fail closed rather than wrapping. | Exact assignment and checked integer-bound theorems in `RepairMetricSemantics.lean` | Hungarian-versus-brute-force and overflow differential | `FORMAL-PARTIAL` |
| M-05 | U/I | The temporal component is Zhang-Shasha-style ordered tree edit distance over separated temporal phases. | `OrderedTreeEditDistance.ordered_forest_recurrence` and internal-node insertion/deletion witnesses | Independent ancestor/order-preserving mapping enumerator | `IMPLEMENTATION-PARTIAL` |
| M-06 | U/I | Matrix head updates cost one, while insertion or deletion at a sequence, bag, or set operand boundary inserts or deletes that complete operand subtree; these units are evaluated over certified quotient operands. | Subtree-operand recurrence theorem | Independent small-e-graph enumerator and wrapper/child boundary | `FORMAL-PARTIAL` |
| M-07 | U/I | Fast source labels used for readable edit paths do not weaken alpha/type identity. | Readability/identity separation theorem | Rename/path rendering probes | `BLOCKED` |
| M-08 | I | Within declared exact-search bounds, pruning, candidate ordering, and checked Hungarian arithmetic preserve the exact minima above; exhausting a bound fails without returning a partial minimum. | Algorithm refinement, arithmetic, and fail-closed bound invariants | Exhaustive bounded algorithm differential plus forced-bound rejection | `BLOCKED` |

## Required Test Matrix

The prompt's eighteen tests are obligations, not evidence by themselves. Their
claim mappings are: `T01 -> P2-01`, `T02 -> P2-13`, `T03 -> P2-01/P2-20`,
`T04 -> P2-10`, `T05 -> P2-07`, `T06 -> P2-08`, `T07 -> P2-03/P2-04`,
`T08 -> P2-09/P2-12/P2-15`, `T09 -> P1-01..P1-20`, `T10 -> P2-13`,
`T11 -> P2-14/P2-17`, `T12 -> P2-15`, `T13 -> P2-10/P2-11`,
`T14 -> G-03/P3-03..P3-12`, `T15 -> P6-01..P6-03`,
`T16 -> P6-04..P6-06`, `T17 -> P4-01..P4-12`, and
`T18 -> P5-01..P5-15`.

## Public Claim Surfaces Still To Census

The following surfaces are explicitly unresolved. Their existence here
prevents a false claim of exhaustive coverage while the line-level census is
being completed:

- `certificate-verifier/FORMAT.md` and `certificate-verifier/README.md`;
- trust/pin documentation and parser/verifier diagnostics;
- `docs/theory-*.md` correctness assertions;
- correctness-bearing comments in every modified producer, adapter, graph,
  metric, exporter, and standalone-verifier source file;
- bounded-CI and certificate-writer script comments/claims;
- empirical summaries and manifests that will be created only after the
  immutable reviewed implementation exists.

Each public claim will receive a stable `PUB-*` or `EMP-*` row before any
phase is eligible for a ballot. Until then, all seven phases remain blocked.

### Located Public-Contract Faults

| ID | Surface | Contradiction | Repair | State |
| --- | --- | --- | --- | --- |
| PUB-F01 | `certificate-verifier/FORMAT.md` and intermediate A2 reports | They disagreed with the then-current producer over `PARAMETER_SINGLETON`; the attempted documentation repair later became stale when v4 removed name-based typing authority. | The live contract now lists only `EXACT_RELATION` and `PRIMITIVE_SET_SINGLETON`; `ParameterN` is explicitly nonauthoritative. Historical v3 text is labeled as invalidated repair provenance. | `REPAIRED; RE-REVIEW REQUIRED` |
| PUB-F02 | `certificate-verifier/FORMAT.md` and `README.md` dependent-chain description | They did not state the required interior-arity guard and therefore left the public JOIN associativity boundary ambiguous. | State the exact guard and fixed-binary fallback alongside the unary-interior counterexample rationale. | `REPAIRED; RE-REVIEW REQUIRED` |
| PUB-F03 | `certificate-verifier/TRUST.md` and `README.md` producer boundary | They claimed only one fresh insertion and declared flexible containers and binders unsupported, contradicting current writer validation and fixtures. | Derive and document the two actual history families, recursive supported port forms, exact graph-level restrictions, and mandatory construction/binder evidence. | `REPAIRED; RE-REVIEW REQUIRED` |
| PUB-F04 | `certificate-verifier/FORMAT.md` current history subset | It described a single fresh event although `requireSupportedSlice` admits a nonempty contiguous fresh-only bottom-up history. | State the actual fresh-only family and its final-root/quiescence/unfolding restrictions. | `REPAIRED; RE-REVIEW REQUIRED` |
| PUB-F05 | Phase 4 audit status and evidence sections | They named schema v3 although the standalone parser then accepted exactly schema v5. | Superseded by the rooted-identity version repair in PUB-F07; retain the historical contradiction and its repair record. | `SUPERSEDED BY PUB-F07` |
| PUB-F06 | Phase 4 producer evidence claim | It treated standalone collision/rebuild fixtures as production-writer coverage even though the writer returns `UNCHECKABLE` for those histories. | Separate verifier-only DTO evidence from the bounded producer bridge and leave end-to-end export explicitly blocked. | `REPAIRED; RE-REVIEW REQUIRED` |
| PUB-F07 | Producer, parser, format, and audit schema identity | Rooted binder-occurrence keys were introduced under schema v5 even though v5 had rootless key semantics. | Assign rooted identity to schema v6 and reject v5 explicitly; update the formal accepted-version model and public format. | `REPAIRED; RE-REVIEW REQUIRED` |

## Formal Execution Record

Pinned prover command:

```text
/home/augustus/.elan/bin/elan run leanprover/lean4:v4.33.0 lean <file>
```

Abstract formal files for Phases 1, A2, 2, 4, 5, and 6, the repair metric, the
trust boundary, and selected cross-phase contracts compile. Compilation alone
does not close their `FORMAL-PARTIAL` rows: most are contract models rather
than complete refinements of the Java producer, wire decoder, verifier, and
provenance implementation. Phase 3 has abstract exact-type/endpoints,
empty-relation, and source-profile counterexample/contract models, but it
likewise lacks a complete formal-to-Java-and-wire refinement. No phase has a
claim-complete formal-to-implementation mapping.
Every phase therefore remains blocked.

## Independent Reviews

No current or historical review closes this ledger. Under the bounded
assurance plan, each phase receives one fresh independent requirements-based
review and the frozen integrated artifact receives one additional independent
review. Each review is bound to the same manifest, complete finite test set,
and coverage evidence. A relevant change invalidates the affected phase review
and the integrated review.
