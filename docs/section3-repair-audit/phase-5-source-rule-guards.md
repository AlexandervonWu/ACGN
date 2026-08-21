# Phase 5 Audit: Source-Rule Guards

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Status

PRELIMINARY MAXIMUM-ADVERSARIAL REVIEW: **FAIL**. THE ABLATION-BINDING AND
COMPOUND-EMPTY COUNTEREXAMPLES ARE REPAIRED, AND THE CERTIFICATE CLAIM IS NOW
EXPLICITLY NORMALIZED-IR-ONLY. COMPLETE PARSER/IR/IMPLEMENTATION REFINEMENT AND
AN IMMUTABLE FIVE-REVIEW BALLOT REMAIN BLOCKED.

## Implemented Obligations

- `set none` and `lone none` retain one quantified relation binding, whose
  value may be the empty relation. They are not treated as empty admissible
  binding sets.
- Bare Alloy declaration domains default to multiplicity `one`; explicit
  `set`, `lone`, `some`, `one`, and exact wrappers override that default in the
  `QuantiVar` tuple.
- Empty-domain elimination fires only for a statically empty positive
  multiplicity such as `one none` or `some none`.
- Relational subset uses `none in none = true`. An arbitrary value in `none`
  remains unreduced unless the value has a static nonemptiness proof.
- Guarded subset and empty-cardinality smart rules run before the
  certificate-facing matrix snapshot. A/C/I normalization remains after that
  boundary and still requires independent law evidence.
- `AlloyRewriteSystem` reconstructs a scoped binding environment only from
  actual predicate/quantifier declaration nodes. It honors declaration order
  and shadowing; bare/`one`/`some` bindings authorize guarded membership while
  `set`/`lone` and synthetic unary labels do not.
- Standalone certificate replay begins at the normalized typed IR supplied to
  the exact graph. Raw Alloy identifiers and hashes are provenance metadata;
  they do not certify the parser-to-normal-form rewrite.

## Alloy-Backed Regression Boundary

`AlloySourceRuleRegressionTest` compiles selected higher-order declarations,
asks Alloy/Kodkod to prove `not (none in none)` unsatisfiable, and checks the
resulting MASG, `QuantiVar`, fast matrix, and certified observation. Kodkod
support is command-specific: the adversarial census observed eight translated
higher-order commands and four unsupported commands. Each result must retain
its own solver or parser/type/lowering authority; a uniform-refusal statement
is false.

## Fault And Contradiction Log

| ID | Located fault | Repair | Regression |
| --- | --- | --- | --- |
| P5-F01 | Prenexing treated every syntactic `none` domain as empty, including `set none` and `lone none`. | Distinguish the admissible binding set using the encoded cardinality. | `setSome` and `loneSome` retain `SET`/`LONE` bindings and do not collapse to false. |
| P5-F02 | `x in none` collapsed to false without proving `x` nonempty, and `none in none` was consequently wrong. | Require an explicit nonempty wrapper for the false rule and handle the empty subset first. | Core and ablation saturation tests cover unknown, empty, and statically nonempty left operands. |
| P5-F03 | Local smart rules ran only after `certificationMatrixEGraphRoot` was cloned, so the fast observation said `true` while the certified observation retained raw `IN`. | Add a narrow guarded source-rule pass before the certificate snapshot; leave algebraic normalization after it. | Certified observations agree with truth/false fixtures for all source-rule cases. |
| P5-F04 | A bare declaration domain was assigned `Cardinality.SET`, contradicting Alloy's default `one` multiplicity and making `some x: none` appear inhabited. | Default bare declaration domains to `Cardinality.ONE`; preserve explicit `set`. | `one Person` equals bare `Person`, differs from `set Person`, and bare `none` has an empty binding set. |
| P5-F05 | The first regression attempted to use Kodkod as a higher-order relation-quantifier evaluator and failed with `HigherOrderDeclException`. | Keep direct Alloy solving for the first-order subset fact; use Alloy parsing/typechecking plus lowering assertions for higher-order declarations. | The regression reports only the authority each check actually has. |
| P5-F06 | Guarded membership ignored the `QuantiVar` cardinality tuple and therefore could not distinguish certified positive multiplicity from nullable bindings. | Resolve variables through alpha, De Bruijn, and source aliases and accept only `ONE` or `SOME` binding evidence. | Parsed bare/one/some bindings fold; set/lone controls remain relational membership. |
| P5-F07 | `NOT_IN` did not mirror the independently justified `IN` empty/universal rules. | Add the exact relational duals with the same nonemptiness guard. | `none`, `univ`, and typed/nonempty controls agree across fast, certified, and ablation paths. |
| P5-F08 | A child rewrite could expose `NOT true/false` after the certification snapshot, leaving certified and fast matrices inconsistent. | Close Boolean negation after guarded child rewriting and before the snapshot. | `not(lone none)` and `not(one none)` have equal certified/fast constants and zero repair distance. |
| P5-F09 | Generic unary opcode labels such as synthetic `SOME(S)` could counterfeit a static nonemptiness proof. | Limit nonemptiness authority to authenticated positive binding tuples; remove opcode-label inference. | Manually typed synthetic labels retain `IN`/`NOT_IN` and do not become constants. |
| P5-F10 | `EGraphSaturationTest` still required an unbacked synthetic `ONE(S)` label to prove nonemptiness. | Change the test to require the term to remain `IN`. | The core saturation suite passes on the repaired authority boundary. |
| P5-F11 | `EGraphAblationTest` repeated the same label-as-proof assumption in all arms. | Require the synthetic term to remain distinct from false. | All five ablation arms pass the corrected source-rule regression. |
| P5-F12 | The audit claimed a green bounded gate before the two stale assertions were corrected. | Preserve the failed review here and report the gate only after remediation. | The complete bounded Java gate now passes, including 61 source-rule checks. |
| P5-F13 | `AlloyRewriteSystem` had no authenticated binding environment, so all five ablation engines failed `x in none`/`x not in none` for bare-`ONE` and explicit-`SOME` parameters. | Reconstruct lexical binding authority from declaration structure on every pass, preserving declaration order and nested shadowing; never infer authority from an operand label. | The original external probe now passes all 60 checks; permanent five-arm tests cover positive, nullable, synthetic, and shadowed bindings. |
| P5-F14 | `some x: one (none & A) | no none` is valid Alloy and Kodkod reports UNSAT, but the certified adapter rejected the unreduced intersection as unsupported associativity. | Prove a positive-cardinality binding domain empty when its relation expression has an explicitly empty intersection operand, before creating the binding or matrix constraint. | Alloy/Kodkod and the certified pipeline now agree; the source-rule suite includes the exact predicate. |
| P5-F15 | The audit described higher-order Kodkod support as a uniform refusal. | Correct authority per command and never promote parser/type evidence to SAT evidence. | Independent census observed `translated=8`, `unsupported=4`; public audit text is command-specific. |
| P5-F16 | Export provenance can hash raw Alloy, but certificate events begin at normalized IR and contain zero source-rewrite derivations. | Narrow certificate claims and the verification API contract to normalized typed IR; classify caller-supplied raw bytes only as provenance. Raw-source conformance remains a separate formal/implementation obligation. | Boundary probe records one `INSERT_FRESH` and zero source-rewrite events; the API and public matrix now state that exact boundary. |
| P5-B17 | Deterministic formal/refinement mappings are incomplete for nested alias resolution, the quantifier truth table, pipeline ordering, and cross-engine authority propagation. | **Unrepaired blocker:** complete claim-by-claim Lean and Java/provenance conformance obligations. | Independent Lean proves the finite semantic core but intentionally does not certify Java refinement. |
| P5-F18 | Parser-derived `none`/`univ` reach baseline terms as `SIG` atoms, and unary `some/one/no/lone none` had no baseline reductions; the original binding probe therefore remained false even after scoped authority was added. | Normalize only the fixed built-in `none`/`univ` atoms and apply the four exact empty-relation cardinality facts. Arbitrary signatures remain untouched. | Parser-backed probe moves from 20 failures to 0; `AlloySourceRuleRegressionTest=95` and `EGraphAblationTest` pass. |
| P5-F19 | Certified ACI equality reordered temporal siblings, but the repair projection numbered phases in source order; the guarded kernel therefore rejected an equivalent swapped conjunction at distance 6. | Derive one phase order from expanded certified matrix keys, preserve ordered and binary-temporal roles, and apply the same reindexing to temporal references and binder owners. | The original two-phase probe now reports SAT counterexample `false`, certified equality `true`, and guarded distance `0`; permanent two- and three-phase regressions raise `AlloySourceRuleRegressionTest` to 234 checks. |
| P5-F20 | The fixed `univ` atom was treated as unconditional evidence that its carrier is inhabited. At bitwidth zero, the universe can be empty, so that authority made `univ in none` collapse unsoundly. | Remove `univ` from the static-nonemptiness authority set. Retain only authenticated `ONE` or `SOME` binding tuples; membership *in* `univ` remains the independently valid subset law. | `Phase5SourceRules.lean` proves the empty-universe countermodel, and the parser-backed bitwidth-zero regression leaves `univ in none` guarded. |
| P5-F21 | `EXACTLYOF` was modeled as a positive multiplicity. Alloy's translator instead checks equality between the bound relation and its declared domain, so `exactly none` admits the binding `none` and proves no nonemptiness. | Model EXACTLY-of as domain equality, exclude it from empty-domain and nonemptiness rules in Fast Rewrite and all ablation paths, and retain its tuple tag without interpreting it as `some`. | The independent Lean model counts one EXACTLY-of binding over the empty relation; a direct Fast Rewrite fixture and all five ablation arms reject the forged nonemptiness fold, raising the source-rule gate to 253 checks. |
| P5-F22 | Higher-order source-rule checks had no per-command authority ledger, so mixed translator support was collapsed into prose and one aggregate pass count. | Record every selected parser command in source order as translated SAT, translated UNSAT, or parser/type/lowering-only for the exact higher-order-skolemization limitation; propagate every unrelated translator error. | Twelve command records are emitted and checked: eight translated results and four unsupported results. The expanded source-rule gate passes 299 checks, and Lean proves classification and ledger cardinality. |
| P5-F23 | Repair projection indexed predicate parameters and prenexed quantifiers by their raw source spelling as well as their scope-qualified identities. A parameter `x:A` and nested `some x:B` therefore collided after implication expansion, even though Alloy proved the source equivalent to `no B`. Same-carrier shadowing could instead have silently selected the wrong binding. | Treat original spellings as presentation metadata only. Projection authority is indexed by the alpha-renamed identity and rooted De Bruijn key; local binders retain their separate certified occurrence maps. The regression backtranslator derives predicate parameter names from the same prepared object rather than rewriting alpha text. | Parser-backed implication, IFF, outer-use, and same-carrier shadowing predicates all prepare and remain source-equivalent through scope 3. `PrenexAciScheduling.lean` proves that different scope paths separate equal spellings, and the source-rule gate passes 332 checks. Full parser-to-Java refinement remains part of P5-14. |

## Current Bounded Re-review

A fresh read-only review of the pre-P5-F22 candidate returned
`PASS-for-bounded-scope` for five explicitly bounded obligations. Its report is
`/tmp/acgn-p5-rereview-20260821.md`, SHA-256
`b73d29b11bf43eea10ec67608436ffdc9c0e57134f1d02e0e12b87519a54dcbd`.
It passed 253 source-rule checks, nine SAT falsification queries, schema-v8
writer/replay, and 76 metric-refinement checks over 11 Lean vectors. This is
not an immutable phase ballot. P5-F22 changed the candidate afterward and
therefore requires fresh review; complete alias/De Bruijn and cross-engine
refinement remain open under P5-14 and P5-11.

A later replacement review returned **FAIL** on the P5-F23 counterexample and
also identified a stale generated assurance catalog. Its report is
`/tmp/acgn-phase5-replacement-review-20260821.md`, SHA-256
`0effc5df4d35b810ddf3a612b58d4d9665cd8706c3bae6bf3360242398aca0d9e`.
That verdict remains part of the audit record. The exact counterexample is now
permanent, the focused suite passes 332 checks, and the scope-separation Lean
theorems compile; a new independent replacement review is required before any
bounded PASS can be recorded. The generated assurance catalog must also be
regenerated only after the traceability matrix stabilizes.

The fresh scope-shadow replacement review subsequently returned **PASS for the
explicitly exercised bounded Phase 5 scope**. Its report is
`/tmp/acgn-phase5-shadow-replacement-review-20260821.md`, SHA-256
`28f1003f59a5a1d367d86c4ad0a11f5d33c1c2db11a54a8c67f3836993184c1d`.
It compiled 296 producer sources, passed the 332-check source suite, 182
instrumented saturation assertions, and 264 ablation assertions. An independent
matrix covered 11 shadowing forms at scopes 1 through 4 with 44 UNSAT
source-versus-normalized checks and 60 projection checks. Four mutants were
killed, including source-first same-carrier capture and incorrect implication
and IFF polarity. The review explicitly excludes universal JVM refinement,
malformed internal IR, exhaustive scopes, corpus reruns, and artifact closure.

The independent semantic core is recorded in
`formal/Phase5SourceRules.lean`. It proves the finite relation, multiplicity,
empty-domain, subset, duality, compound-empty, and authority rules without
importing producer code. It also proves that the existing graph trace-kind
vocabulary cannot encode a raw-source rewrite. This is partial formal evidence,
not a Java/parser refinement proof.

## Independent Review 2

Verdict: **FAIL**. The reviewer confirmed P5-F06 through P5-F09 were repaired
and found no remaining label-based inference in `NormalForm`, `EGraphNode`, or
`AlloyRewriteSystem`. It correctly rejected closure because two repository
tests still demanded the removed behavior and this document therefore stated
a stale gate result. P5-F10 through P5-F12 record those contradictions.

## Remediation After Review 2

Both stale assertions now express the fail-closed rule. The complete bounded
gate passes `AlloySourceRuleRegressionTest=61`,
`CanonicalAlloyPipelineTest=251`, core saturation, all ablation arms, and
backtranslation. A fresh independent review remains pending.

## Independent Review 3

Historical verdict: **PASS under the superseded protocol**. The fresh read-only reviewer passed 61 source-rule checks,
34 saturation cases, 229 ablation assertions across five engines, 251 pipeline
checks, four backtranslation cases, and independent `123 + 40` check probes.
Synthetic `ONE`/`SOME` labels cannot prove nonemptiness; authenticated
`QuantiVar` cardinalities `ONE` and `SOME` can, while `SET`, `LONE`, and
`EXACTLY` remain guarded. No repository file was changed by that reviewer. Its
closure statement is invalid under the controlling protocol and is refuted by
P5-B13 through P5-B17.

That closure statement records the earlier review protocol. It is superseded
by `adversarial-review-protocol.md`; current closure requires five fresh
unanimous reviews of one unchanged snapshot.

## Review Gate

No five-review ballot may start until every blocker above is repaired on one
immutable snapshot. Each fresh reviewer must independently probe all five source forms, negated
variants, bare versus explicit multiplicities, the pre-certificate boundary,
and consistency between the fast, certified, and ablation rewrite paths.
