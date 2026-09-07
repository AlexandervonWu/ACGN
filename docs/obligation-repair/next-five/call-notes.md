# v2.13 CALL obligations: P1-08 and P1-05

This is a bounded implementation/proof handoff, not a closure report or a
matrix-status change. The matrix claims remain unchanged: malformed/incomplete
calls reject without an unrelated-visit fallback; argument payload order is
source order. No production source, matrix, CI, or existing runner is edited.

## Proof boundary

`OrderedCallValidation.lean` imports only `Std`. Namespace:
`ACGN.NextFive.OrderedCallValidation`.

The executable validator reads payloads from a role-ordered exact-visit bucket,
recursing on declared arity. It checks exact owner, visit and position at every
role; the first role is the specified callee, every argument is non-END, and
the final role is exactly END with no remaining edges. Acceptance is proved
equivalent to a complete indexed encoding, not assumed through `AcceptedVisit`.
No distinctness assumption is imposed on payloads. `selectCall` consults only
the requested bucket, or rejects immediately past the maximum visit.

General model theorems quantify over arbitrary natural arity. Java interpretation
is restricted to `JavaIndexSafe n`, namely `n + 3 <= 2147483647`: `n + 2` edges
and the producer's `new MASGEdge[expected + 1]` length fit signed `int`.
This is **not** a production overflow guard or a proof of overflow handling.
It does not establish feasible allocation at that bound. Memory/resource
failures, negative machine values, concurrent mutation, and null edge/target
objects are outside this model. Java fixtures declare and actually parse only
arities `{0,1,2,3,5,8,16}`; each checks this arithmetic envelope with
`Math.addExact`. No claim is made about all parser-supported arities.

The 17 theorem names, each accompanied by `#print axioms`, are:

```text
java_index_bounds
validateArgs_iff
validate_iff
accepted_complete_and_ordered
source_order_complete
malformed_rejects
encodeArgs_length
accepted_edge_count
encodeArgs_index
accepted_payload_at_source_index
duplicates_preserved
reordered_payloads_not_accepted
no_unrelated_visit_fallback
missing_exact_visit_rejects
malformed_exact_visit_rejects
past_max_visit_rejects
checked_observation_contract
```

All compile with explicit `ELAN_TOOLCHAIN=leanprover/lean4:v4.33.0`; the printed
dependency union is `propext`, `Classical.choice`, `Quot.sound`. There are no
admitted proofs, new axiom declarations, unsafe definitions or native-decision
shortcuts. The Lean kernel and these standard axioms remain trusted.

## Java observations

The new test follows `ZeroArgumentCallRegressionTest`: Alloy public parser,
`ModelUnit`, actual `super.visit` CALL return capture, owner graph and visit,
`Canonical.prepare`, traversal of **`getCertificationMatrixEGraph()`**, and
`CanonicalAlloyPipeline.prepare` with actual certified observations. It never
substitutes the optimized matrix for the certification-source matrix.

Seven arities, predicate/function calls, mixed/reversed/all-duplicate payloads,
and repeated equal source sequences give 56 positive occurrences. The payloads
are integer literals, decoded independently from parser `ConstExpr`, MASG target
symbols, IR constant children, and the actual certified argument invocation's
stored nullary `ALLOY/CONSTANT/<value>` e-class shape. The test checks complete
CALL metadata, exact lengths, payload order and multiplicity, and occurrence
coverage at each boundary. Equal sequences have equal canonical observations;
distinct reversals differ. Same-type wrong and swapped `OnePort` argument lists
must be rejected against the actual fixed certified endpoint.

The finite rejection matrix invokes the actual private `IRAgent.downlinksFor`
and `MASGVisitor.validateCompletedCallVisit` via reflection. Valid same-owner
buckets at visits 1 and 3 surround requested visit 2 and are independently
accepted before corrupting the requested bucket. Controls cover missing/empty
buckets, missing callee/END/arguments, extra edges, wrong callee, non-END final
role, foreign owner and visit at every role, gaps, duplicate roles, and END in
each argument role. A complete bucket past maxVisit rejects. Reversed storage
order remains accepted in position order without mutating the input list.
All temporary graph edits are restored in `finally`.

The local successful test summaries are 56 occurrences, 637 rejection checks,
70 order controls, and 5355 assertions; the existing zero-call regression has
13 occurrences / 1160 checks, and existing call extraction has 161 checks.
This is finite testing, not parser or JVM universal refinement, nor independent
certificate-verifier replay. Optimizer survival is asserted only for these
deliberately separate-body fixtures, not universally.

## Runner interface

```text
java -ea -Xmx1g -cp CLASSES:ROOT/lib/* \
  is.fivefivefive.CanDis.OrderedCallValidationRegressionTest [OUTPUT.tsv]
java -Xmx1g -cp EXTRACTOR_CLASSES CallValidationExtractor ROOT OUTPUT.tsv
```

The optional occurrence TSV is UTF-8 with one header and 56 ordered data rows:

```text
schema fixture parser_path occurrence owner visit callee kind arity parser_payloads masg_payloads ir_payloads cert_payloads positions edge_owners edge_visits edge_targets cert_path cert_operator observation_sha256 target_callee target_kind target_arity
```

The separator is TAB, not the spaces shown above. `schema` is `ordered-call-v1`.
Numeric list fields are comma-separated nonnegative decimal integers; the empty
field is `[]`. `edge_targets` is `callee,<literal payloads>,end`, or `callee,end`
at zero arity. Its callee token must be encoded from the independent
`(target_callee,target_kind,target_arity)` tuple, NOT from the CALL row tuple.
The three appended fields are read by reflection from the actual RefSymbol or
PredRootSymbol's `semanticIdentity`, `callKind`, and `declaredArity`, following
the existing zero-call test. The two tuples and actual `matchesTarget` result
are checked in Java. Target authority/source spelling are not separately
exported; do not claim Lean rechecks those unrecorded fields. Argument
tokens are actual literal values, not types, indices, or expected fixture data.
Parser paths are child-index paths, not source spans. Certificate paths are
scoped to their actual graph. Occurrence IDs restart with each fixture visitor.
The observation hash is SHA-256 over actual canonical stable-form UTF-8 bytes.
Do not compare noisy production debug stdout for determinism; compare TSV.

Lean replay constructors (field order is significant):

```lean
import OrderedCallValidation
open ACGN.NextFive.OrderedCallValidation
-- Capture.mk owner visit calleeKey arity
-- Edge.mk owner visit position (Target.callee key | .argument payload | .terminator)
-- Observation.mk capture actualEdges parserPayloads irPayloads certifiedPayloads
def sample : Observation :=
  ⟨⟨7, 1, 0, 2⟩,
   [⟨7, 1, 1, .callee 0⟩, ⟨7, 1, 2, .argument 1⟩,
    ⟨7, 1, 3, .argument 1⟩, ⟨7, 1, 4, .terminator⟩],
   [1, 1], [1, 1], [1, 1]⟩
theorem row_sample : checkObservation sample = true := by decide
#print axioms row_sample
```

Use `checked_observation_contract` to obtain JavaIndexSafe, exact arity,
the full indexed encoding, and IR/certified equality to the independent parser
payload list. A runner must build edges from actual edge fields, not `encode`
or the expected parser list. Check `masg_payloads` agrees with argument tokens;
check row census, list lengths, schema and uniqueness separately. Map callee
metadata tuples injectively to natural equality tokens and declare the mapping
trusted. Extend the mapping over both source and target tuples, so an unseen
wrong target cannot inherit its CALL's token. `Capture.owner` is an equality token for the recorded MASG node, not a
proof of general Java object identity. Raw IDs and lineage checks are Java
observations; the Lean model does not invent a parser-occurrence authority.

Extractor output is exactly this TAB-separated schema and three rows:

```text
control owner method start endOffset step
call-early-return is.fivefivefive.CanDis.ir.IRAgent downlinksFor 0 0 0
ir-argument-validation is.fivefivefive.CanDis.ir.IRAgent validateCallDownlinks 1 1 1
masg-argument-validation is.fivefivefive.ACGN.visitor.MASGVisitor validateCompletedCallVisit 2 0 1
```

For argument loops, indices are `start <= i < expected - endOffset`, step 1;
`expected = arity + 2`. The early-return row has sentinel zeros. The extractor
checks the complete first four statements of `downlinksFor`, including the
past-max guard and unconditional CALL validation return before the non-CALL
suffix. It checks both whole validator bodies against closed AST templates,
including count, sort/indexing, owner/visit/position, callee, argument and END
controls. Method signatures, exact declaring owners, nominal types, constructors,
CALL enum, and invoked-method owners are resolved by javac. It is not regex
matching. Numeric rows are constants of the checked closed grammar; unknown
effects or controls fail rather than being assigned an interpretation.

Diagnostic literal text alone is ignored; expression/evaluation structure is
not ignored. Javac-inferred comparator parameter type trees are normalized for
shape comparison and their resolved MASGEdge types checked separately. The
extractor does not claim to translate `visitCall`, `buildEGraph`, Java sorting,
array uniqueness/completeness, dynamic dispatch, getters, or allocation into
Lean semantics. Those facts are tested/trusted correspondences, not proved
by matching ASTs. Non-CALL fallback behavior is expressly outside scope.

## Trust and integration

PROVED: the indexed natural-number model and contracts listed above.
TESTED: the finite real parser/MASG/IR/certified boundary fixtures and controls.
CHECKED: javac-resolved, closed structural source patterns.
TRUSTED: Lean kernel/standard axioms; JDK17 javac/JVM and collection/sort/array
contracts; pinned local Alloy/parser jars; adapter/certification implementation;
reflection, test observers, TSV encoder and callee-token mapping; SHA-256,
filesystem, OS and hardware. Source sorting/permutation and Java heap-to-model
abstraction are not universally mechanized. No internet was used.

Main owns runner/plugin/config integration, source manifests, correspondence
registration, input hashes, negative-control registration, and any resulting
bounded closure report. Passing local checks must not be promoted to global
closure or universal parser/JVM refinement. Deduplicate the shared CALL proof,
test, extractor and replay when both matrix parents refer to them.

## Local verification record

Two isolated copies were compiled and tested in
`/tmp/acgn-ordered-call/finalA` and `/tmp/acgn-ordered-call/finalB`. Both full
Java source builds used `javac --release 17 -encoding UTF-8 -cp 'lib/*'` with
fresh class directories. Both extractors compiled separately with `--release
17`. The new regression main above and
`is.fivefivefive.CanDis.ZeroArgumentCallRegressionTest` and
`is.fivefivefive.CanDis.CallExtractionRegressionTest`, ran with `-ea -Xmx1g`
(the extractor has no assertions flag requirement). All exited 0. The new test,
the two existing regression mains, and the extractor ran once per clean build.

Both proof copies were compiled from their own formal directories with:

```sh
ELAN_TOOLCHAIN=leanprover/lean4:v4.33.0 lean -o OrderedCallValidation.olean OrderedCallValidation.lean
```

All 17 printed theorem inventories passed; no forbidden axiom appeared. The
`.olean`, all Java class files, extractor class files, `calls.tsv`, `controls.tsv`,
and `zero.tsv` were byte-identical between builds. Full-source compilation and
these local comparisons do not constitute a registered closure run. The final
23-column occurrence sample and three-row extraction are in each build root.
Main still owns generated 56-row Lean replay and registered negative controls.

## Negative controls

Recommended replay mutations: replace one actual MASG, IR or certified payload
by a distinct same-type token; swap two distinct actual payloads without changing
the parser list; truncate or deduplicate a repeated payload sequence; remove
END; transplant owner/visit; duplicate/gap a role; exceed the JavaIndexSafe
envelope. Alter a duplicate-only permutation as a positive identity control.

Recommended isolated source mutations for `CallValidationExtractor`: replace
the CALL early `return validateCallDownlinks(...)` by a non-returning call;
change the IR argument upper bound from `expected - 1` to `expected - 2`;
remove an owner/visit guard; change the comparator to payload order; or resolve
a nominal type/helper to a shadow owner. Mutation files must be temporary
copies, never production edits. Do not accept a compiler error as evidence that
the extractor caught a structurally valid negative control.
