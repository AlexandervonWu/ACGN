# Incident 1: Source Slot Census NOOP Wrapper

## Production Evidence

The full serial run `full-corpus-8g-20261107T032610Z`, source commit
`a0621b567258aa5359d64ae97ef9ea6e6aeca7c5`, stopped at the ablation output
gate: slotted-egraph recorded 675 failures, 60,923 successes and 4,482
AST-identical skips out of 66,080 files. All failures reported
`IllegalArgumentException: Binding is not a variable`. The seven arms had
finished; CanonicalBatch and Augmenter had passed their gates.

Production witness: `classified-data/lts/both/2NcZqmTe3sbd2eRfn_inv4.als`,
oracle `inv4c`:

```alloy
let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} |
  all s:State | some i:Init | s in i.^ts
```

The reduced source witness is `sig A {} pred p { let r=A->A | some r }`.
The bundled parser's `ExprOrFormula.buildExpression` wraps homogeneous
relation variables as `UnaryExpr(NOOP, VarExpr)`. `LetExpr.getVar()` exposes
that wrapper, not a direct `VarExpr`. The census's direct-variable check
rejects it. A probe of both selected predicates in all 675 failing files
reproduced all 675 census failures on the frozen original JAR, finding 792
wrapped binding occurrences. The first stack enters `SlotCensus.count` from
the let branch of `visit`.

`EGraphAblationStudy.processFile` performs the census after comparison and
engine timing. Thus this is an observation/harness failure, not an engine
exception or evidence that a rewrite is unsound. The user service exited 1
at `arms_gate`; no Java/supervisor process or service cgroup remained before
edits. Kernel journal inspection found no OOM or I/O event in the run window.

The first MASG construction already eliminates these wrappers:
`MASGVisitor.visit(UnaryExpr)` returns the visited child for `NOOP`, and
`visit(LetExpr)` unwraps the binder before allocating its let symbol. The
ablation rewrite system also has existing NOOP elimination. Neither path
removes wrappers from the original parser AST. The census reads that original
`Predicate` directly; it must not infer that the graph's normalization has
mutated its source. No graph normalization repair is needed for this incident.

## Incident Repair and Requested Extension

The initial isolated repair unwrapped `NOOP` in `SlotCensus.count`, retaining
its strict `VarExpr` check. Replaying all 675 witnesses in both slotted arms
passed the unchanged gate, with all recorded untyped engine fields identical
to the original run. This establishes the incident's cause independently of
the broader change below.

The user then explicitly requested removal of both `UnaryExpr.NOOP` and `Body`
from all relevant AST-distance and AST-transformation paths. The shared
`AlloyUtil.unwrapAst` now exposes the original semantic child without mutating
source ASTs. Only these two wrapper kinds are transparent. Missing children
throw; non-variable census leaves still throw. The pinned parser has no
`UnaryFormula.NOOP`: its unary formula operators are all retained.

The shared view is used by `AlloyAstTermAdapter`, `DatasetConventions` labels,
children and equality, `SlotCensus`, and the ablation/capability/memory AST size
readers. Consequently CanonicalBatch raw tree distance, Augmenter raw tree
distance/fingerprints, and RepairCorpusSource exports omit both wrappers.
Predicate roots, declarations, ordered domains, real unary operators, temporal
boundaries and calls remain present. MASG construction already bypasses both;
source-edit feedback graphs already bypass Alloy's own NOOPs while preserving
occurrence spans. Those source-authority paths are not rewritten.

The traversal is unchanged: parameters, quantified/comprehension declarations
and let bindings count once each; declared domains, let bounds and bodies are
visited once; shadowed bindings count separately. The immutable type histogram
must still sum to the total. `<unknown>` retains its existing explicit meaning.

The initial census-only repair was purely observational. The requested
extension changes AST presentation before tree matching and can change raw
distances, representation sizes and ablation results; old results must not be
relabelled as results of this version. It does not add static rewrites or
change typed enumeration, scope/binder domains, phase barriers, source authority
or certificate admission. Expected corpus counts and failure gates stay fixed.

The correspondence is between non-decorative AST occurrences and derived
occurrences: every semantic operation retains its ordered child coordinates
and metadata, with wrapper edges contracted. It is not a claim of one unique
MASG vertex per occurrence: graph sharing and time-of-visit occurrence ledgers
remain unchanged. The original `PrettyStringVisitor` renders NOOP as precisely
its child's text; Body adds formatting around its expression. Reverse builders
already supply that formatting explicitly (`Generator`'s predicate root emits
braces/newlines; `CanonicalBacktranslator` emits predicate, quantifier and
comprehension syntax). Those syntax tokens do not need structural Body nodes.

Before the extension, `AstWrapperErasure.lean` specified ordered trees carrying
opaque semantic metadata and two identity wrappers. It proves erasure preserves
interpretation for any algebra, retains non-wrapper labels/child coordinates,
is idempotent, and makes readers invariant to either wrapper. Occurrence lookup
is preserved at every semantic child-coordinate path. Interpretation
preservation and idempotence use Lean's standard `propext` and `Quot.sound`;
occurrence correspondence uses `propext`; the remaining theorems use no axioms.
This is an abstract structural result,
not a verified Java/parser refinement or a new Alloy rewrite law. The Java
correspondence is covered by parsed source regressions and bounded gates.

## Validation and Retention

Regression coverage in `SlotTypingAblationTest` includes a reduced homogeneous
binary let, a heterogeneous control, shadowed nested lets and comprehension
bindings, alongside existing parameter/temporal/scope/type tests. The new
regression is checked against the original JAR before applying the repair.
`AstWrapperErasureTest` separately checks both wrapper kinds through both raw
distance implementations, insertion/deletion sizes, source exports, typed
adaptation, preserved operators/domains, idempotence and malformed-child
rejection. Both tests and the erasure specification run in bounded gates.

Verified on 2026-11-07:

- Final wrapper regression: 565 checks; slot-typing regression: 46 checks.
- Slot suite: 1,227,116 permutation checks, 45 binding-block checks, 66 rewrite
  order checks, existing Lean specifications and ablation regressions passed.
- The complete bounded Java CI script passed, including source authority,
  occurrence bindings, type/scope, canonicalization, certificates, backtranslation
  and frozen-artifact regeneration checks.
- All 66,080 corpus files parsed and passed census plus wrapper-free adapter
  checks. Every pair's skip classification matched the old output: 4,482 skips,
  61,598 eligible, zero classification changes. Type erasure of each typed AST
  image equalled its untyped image.
- All 675 incident witnesses passed all seven scheduled ablation arms plus the
  typed slotted arm at 16 workers, with zero failures and unchanged gate counts.
- The bounded semantic checker passed all four distinct equality claims from
  that replay and its four targeted probes. These are finite solver checks,
  not proofs of arbitrary Alloy semantics.

Machine-local incident evidence, failure CSV rows, hashed production witnesses,
probe source/output, bounded gate logs and deletion ledger are retained under
the external ACGN incident directory referenced by shared recovery state.
Completed useful stages and unresolved/negative findings are protected. The
launcher does not support stage reuse; retained old stages are not spliced
into a new manifest or represented as results of the repaired commit.
