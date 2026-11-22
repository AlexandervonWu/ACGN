# A2-26 source UNION and INTERSECTION agreement

The frozen I/P claim has SHA-256 `2383859cecf4dbfa79f149e0308fde456c5fcb367993b813221961fbd99da6ad`. Its registration points to the actual dependent-chain leaf adapter. A concrete source set operation must agree with its independently evaluated parser family, an empty family must retain its positive arity, and an unresolved occurrence must receive no dependent equality authority.

## Source observation and implementation

The ninth baseline `TheoryAlloyAdapter.Builder.dependentChainInput` dispatches to recursive evaluation only for parser kinds RELATION and EMPTY_RELATION. Real Alloy parses `(1+2)->Q` with a left PLUS over two integer constants and `(1&2)->Q` with a left INTERSECT over two integer constants. Each left operand’s parser type consists of exactly one unary product, with the built-in `Sig.SIGINT` at its only column. The adapter’s retained type is INT. On the ninth path both cases acquire a dependent ARROW certificate by constructing a relation DAG solely from the stored primitive type. The recursive set-operator check is bypassed, including in the mixed expression `((A+1)&Int)->Q`.

The tenth change affects the two adapter methods. Every source PLUS/INTERSECT now enters `dependentTypeDagForSource`. On a homogeneous integer subtree it reconstructs `Rel(Int)` with the existing `DependentChainTheory.relationViewFromStoredType(GraphType.INT)`. It recursively checks each child, applies the ordinary DAG union/intersection, compares the complete occurrence evidence, and returns the independently derived DAG. The three integer cases, including nested `((1+2)&3)->Q`, retain the same `PRIMITIVE_SET_SINGLETON` rule and the same complete leaf-proof/DAG keys. SHA-256 of their integer leaf’s two serialized keys joined by a newline is `84207557e5f903980dd870bac3d1ac1d20e04268ea12721c44b7357f41a1611f` in both implementations.

The primitive lift has no independently established nominal ancestor or live parser-module witness. A set node that crosses from the primitive representation to a nominal/empty-family representation takes the unsupported branch. `(A+1)->Q` already had fixed-binary ARROW behavior in ninth. `((A+1)&Int)->Q` and `((A&B)+1)->Q` previously took the unchecked INT shortcut; the tenth adapter produces a fixed binary two-One-port ARROW and no equality certificate for that occurrence. The fixed expression remains an ordinary Alloy term.

The source guard compares ordered alternatives, complete relation type, common ancestor, column evidence and identity of the live parser authority. A concrete disagreement throws `IllegalStateException`. A source expression containing the two exhaustive children of an abstract signature gives a real hard-disagreement observation after normalization. Active set-eclass reentry also throws. An unsupported chain may attempt the distinct guarded-JOIN proof; only absence of both authorities reaches a fixed node. Individually certified nested chains keep their own evidence.

## Qualification

`A226SourceAgreement.lean` proves 14 declarations, each with a local axiom print. On a finite graph unfolding, every accepted source child index is visited successfully. The returned DAG equals its parser DAG and all descendant comparisons agree. A typed-empty accepted result has the same positive width as its parser. The model distinguishes unsupported representation, hard disagreement/cycle, independent guarded proof, and fixed syntax. It assumes the operand DAG algebra supplied to the source walk. It does not re-prove the algebra of union or intersection. The finite Java correspondence binds the actual algebra and its type/ancestry comparison methods. The mathematical fuel bounds this source-level interpreter; Java itself uses its active-eclass guard.

`A226CompilerContract` attributes 15 selected JDK 17 methods across five real source files. It checks the ordered effects and their resolved calls, including the initial external parser DAG, recursive operation/operand traversal, primitive lift/domain, union/intersection dispatch, occurrence comparison, hard failures, optional guarded route and fixed-node construction. Its aggregate method/binding digest for the tenth producer source is `1cf3422585bab93741d15f539e991a93b147aeeae46c11df000a753cf4e85dcf`. The Lean entry validates that emitted effect program; five omission controls are refused.

`A226SourceAgreementTest` checks 21 observations. These include real parser-command models for both nested set-operation orders, correlated alternatives, unary and binary empty unions and intersections, three primitive integer operations, three mixed-scope fallbacks, the ordinary hard disagreement, separately guarded JOIN, and a correlated unary-interior fixed JOIN with retained child authority. The explicit recursive-cycle and path-restoration controls use the private walker on a real set node. The cycle control prepopulates the active ancestor set. All other observations use the ordinary parse/normalize/adapt entry. For nonempty nominal leaves a separate parser module with the same input is rejected by occurrence-evidence comparison.

Execute `is.fivefivefive.CanDis.A226Qualification ROOT EXISTING_RESULTS_DIR` with the compiled producer classes, the repository dependency classpath, Java 17, `ACGN_TENTH_LEAN` set to Lean 4.35.0, and `ACGN_TENTH_PROOF` pointing to this primary Lean source. The primary imports Std. The observed final output is `A226 qualification passed: 15 source methods, 6 compiler-program controls, 21 ordinary and unit observations`.

| Output | SHA-256 |
|---|---|
| a226-controls.tsv | `859a2530c73c7c4c65edfcac42ae7bc019bec11b2073c323db27ac16e71afa73` |
| a226-methods.tsv | `9977cbb8d2f32585bac3f8f97fbc5d3380e8f0eef844817139cad9f027b086d4` |
| a226-program.txt | `e6f4cfffcf7e945e6a3f897bf0793fe96f26dd3ae1bcd0a8fb49d8bf4509b5bc` |
| a226-source.tsv | `105492314e56916f8400ba9459d86018fdf7914cb279629b72848cfbf7b42c13` |

## Source and assurance boundary

The source change takes `TheoryAlloyAdapter.java` from `12990ed5fce6717a72f0fd15f2dc3eb580a4c121acef8cd9360b536e8f14a76a` to `d528e9b39ade3879af3dda6482647e55a1ce7fdc3fdb1ba93a819ce08521f33f` on the published ninth base `8b068de6199f561f683681e9a74f4c400a43c640`. The [shared compiler inventory](A226-shared-pins.md) records the paired Java/Python fingerprints, rejection coverage and A2-22 compatibility. The general Alloy normalization process and bundle-only source ancestry have separate ledger obligations.
