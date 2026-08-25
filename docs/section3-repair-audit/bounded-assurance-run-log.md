# Bounded Assurance Run Log

## Development Run A

- Evidence directory: `/tmp/acgn-section3-assurance-20260820-a`
- Outcome: `FAIL`
- Input-manifest SHA-256:
  `cd9abc52fc50e3ce67ee44010a39e1f8493232e7511c0232c58f6e787e03eb0f`
- Step-results SHA-256:
  `a53ace236d8ad86f9601ae2e9da2e420aa58040e09e8949dbc4e2bc2dc67df02`

All implementation tests and Lean files passed, but the runner invoked
`ProducerSemanticEvidenceMutationTest` without its seven required producer
fixtures. This was a runner defect, not a semantic-test failure. It remained a
blocking `FAIL`; the result was not relabeled or discarded.

The repair makes the runner package producer/verifier JARs, generate the
complete certificate fixture family in the evidence directory, and pass the
seven exact fixture paths to the mutation harness. Cross-run JAR-byte
determinism remains a separate open obligation.

## Development Run B

- Evidence directory: `/tmp/acgn-section3-assurance-20260820-b`
- Outcome: `INCOMPLETE`
- Executed steps: 42
- Failed executable steps: 0
- Open traceability diagnostics: 1,160
- Input-manifest SHA-256:
  `9bea0a66cdf49d164a8e5368a698e6470153169fd1cbfec0e8ff21a01004c54e`
- Output-manifest SHA-256:
  `d4edc8f9a03694a00d31585efaf07900b7652b8bce56f58e2fbd92f0c7ef53bd`
- Step-results SHA-256:
  `15c6575e9365caf6821e6629b5249efe835b8394d3ce94cbe89812ac4767facb`
- Summary SHA-256:
  `8097a63a0ec8fa0fc652ba881db34238d88047b4d5df1dbe5ac014224d55c042`
- Traceability-report SHA-256:
  `d8980065d414ffa098678178f6c58562276200c7aa20f877559d0cd1d521fe75`
- Semantic-mutation log SHA-256:
  `9a7247d4d8a06f735b6e2261845db63bb70de0bdfc39cd9fbd8c9f7a9cf4670f`

The independent semantic-evidence mutation harness passed 60 checks. Every
generated output listed in `output-manifest.tsv` was independently rehashed
with `sha256sum -c` and matched. The environment was OpenJDK/Javac 17.0.19,
Lean 4.33.0, a 1 GiB per-step Java heap, 300-second Java timeouts, and
120-second Lean timeouts on a 32-logical-CPU host.

This is development evidence over a dirty worktree at Git commit
`8ec25613e81d7b3767947db31c60cc4bbed4074d`. Its complete input manifest, not
that Git commit alone, identifies the tested bytes. It is not an immutable
phase ballot and cannot satisfy `A-12`. Its `INCOMPLETE` outcome is binding:
none of the 154 scoped requirements is currently reported as fully ready.

## Development Run C

Run C incorporates the parser-ownership/explicit-zero profile repair and the
quiescent collision-bucket proof mapping.

- Evidence directory: `/tmp/acgn-section3-assurance-20260820-c`
- Outcome: `INCOMPLETE`
- Executed steps: 42
- Failed executable steps: 0
- Open traceability diagnostics: 1,153
- Input-manifest SHA-256:
  `8ef6000fba00db586fedf276b9d0f4d510c6eeadc61d9504b99fe81144ca199d`
- Output-manifest SHA-256:
  `a12c79e48c53bf5094471066ed65c07fa4e67eb7ab0c254454c2d534a09c3bea`
- Step-results SHA-256:
  `15c6575e9365caf6821e6629b5249efe835b8394d3ce94cbe89812ac4767facb`
- Summary SHA-256:
  `ed767c2cfb03639c1a34bde741c9c5683775dc64810dc8d04241a9a3d807db7e`
- Traceability-report SHA-256:
  `29acc80b77b6d5852ad184f8591e0603e5ca514f4f0e37c24b7bbfdd3b0c1b54`

All executable steps passed. The parser-owned semantic-profile suite passed
31 checks, and every mapped Lean file compiled. This remains dirty-worktree
development evidence and does not satisfy independent immutable review.

## Development Run D

Run D preserves the explicit-width-zero profile repair, regenerates the
154-claim Markdown catalog, and records the independent P4-01 review's formal
gap instead of retaining the former overstated `PROVED` status.

- Evidence directory: `/tmp/acgn-section3-assurance-20260820-d`
- Outcome: `INCOMPLETE`
- Executed steps: 42
- Failed executable steps: 0
- Open traceability diagnostics: 1,154
- Input-manifest SHA-256:
  `f9bb658590a4696cae87a33647f12e34d8e221701b361a42cf05fa84aea42c75`
- Output-manifest SHA-256:
  `a1bbc58388c3e60bd37a4755912c0c382e7cdd1a6a95a0d0f21b37e59df1cf2e`
- Step-results SHA-256:
  `15c6575e9365caf6821e6629b5249efe835b8394d3ce94cbe89812ac4767facb`
- Summary SHA-256:
  `54a5e7191d0d281fc721b4f3023f25c881258f065ec73f54cc325fa2afb13b53`
- Traceability-report SHA-256:
  `bb9af73e466b2d0c1792c2c5ddfda2accce6ade73a1f4021cabd1dab0c8de99c`
- All-claims Markdown SHA-256:
  `7886aa35b60732be4f6c48be0b7d885970f4cd083cd735d9edb909216d474b16`
- Atomic claim ledger SHA-256:
  `74086eca35887076bd719ea5c22b4a9188a391fe2f9996a0509a77d4400edc1b`
- Traceability matrix SHA-256:
  `e5fc80f05f4222f6b39c94b065b3a0f2b1723b473ff71c95e90ab9b3d39b1386`
- Semantic-mutation log SHA-256:
  `9a7247d4d8a06f735b6e2261845db63bb70de0bdfc39cd9fbd8c9f7a9cf4670f`
- Semantic-profile test log SHA-256:
  `a699d445272388a2da216bb9bfb1ce4480995eb2d8fa8f786b3829252a97bc00`

Every executable step reported `PASS`; the profile suite passed 31 checks,
the mutation harness passed 60 checks, every one of the 14 Lean files
compiled, and the forbidden-token scan passed. Independently checking every
data row after the versioned `output-manifest.tsv` header with
`sha256sum -c` succeeded. The header is schema metadata rather than a
`sha256sum` record and must be skipped by that generic checker.

The run remains development evidence over a dirty worktree at
`8ec25613e81d7b3767947db31c60cc4bbed4074d`. Its input manifest identifies
the exact tested bytes. It is not an immutable ballot, does not close the P3-16
or P4-01 review findings, and does not establish DO-178C certification or
compliance.

## Development Run E

Run E exercises the repaired Phase 6 order fixtures and the certified Fast
Rewrite repair metric, including all mapped Lean files and executable-vector
refinement.

- Evidence directory: `/tmp/acgn-section3-assurance-final-20260821`
- Outcome: `INCOMPLETE`
- Executed steps: 57
- Failed executable steps: 0
- Open traceability diagnostics: 168
- Input-manifest SHA-256:
  `c674dc73318e76104a8dacf1c605cb9908d2b6152b04ab84ec051ce1575572fe`
- Output-manifest SHA-256:
  `660a2a2e865158e41fcce93c762d2b52aa01571e5ca029f9c28e7721c40138f4`
- Step-results SHA-256:
  `3f6432480535fbe0b1bd5434bf16f916171124ccfc76e721281a56b11c846a20`
- Summary SHA-256:
  `6244641e0bc33a3d2ff107665edb4cd8880cc26577251b55200fe5e5295a5b5a`

Every compile, Java, standalone-verifier, Lean, forbidden-token, generated
catalog, concrete-vector, and input-stability step reported `PASS`. The run is
still development evidence over a dirty worktree at
`bc256c5b5821a5a6e2c7f423579bdda94ba22b02`; its input manifest identifies the
tested bytes. Structural coverage, complete Java/formal refinement, immutable
provenance, and independent integrated review remain open, so the runner
correctly returned exit status 3 rather than a false PASS.

## Development Run F: P0 Subtype JOIN

Run F exercises dependent JOIN subtype evidence, schema v9 rejection of v8,
the fail-closed standalone hierarchy boundary, current stream-v3 ancestry
preservation, and every pre-existing bounded Section 3 step.

- Evidence directory: `/tmp/acgn-subtype-section3-final`
- Outcome: `INCOMPLETE`
- Executed steps: 57
- Failed executable steps: 0
- Open traceability diagnostics: 168
- Input-manifest SHA-256:
  `404aa04d32b35c9a030067c8c7ea6a25d8b97c037170732c8aed8d3d6172d698`
- Output-manifest SHA-256:
  `184977ab3de33c128a249e9e5d43b1f917fa0f03b097394ce5f5e1907919545c`
- Step-results SHA-256:
  `3f6432480535fbe0b1bd5434bf16f916171124ccfc76e721281a56b11c846a20`
- Summary SHA-256:
  `42496593af9f4d342b683556c29350047a0a8457dd70032de01800bde0e36e7b`
- Traceability-report SHA-256:
  `2ee5fe9881f7cc3912ddf4d43919c79dcf2bd173935965d8b581b125369460e2`
- Subtype semantic-mutation log SHA-256:
  `dd547c7deedba88b987fadce03d0bceb5399bae13c2012d552a230647d80849e`

Every executable step completed. The runner returned exit status 3 because the
closed claim catalog still has 168 partial, bounded, or refuted obligations.
This dirty-worktree run is bounded regression evidence, not an immutable phase
ballot or whole-artifact certification.

## Development Run G: P0 Formal-Fold Repair

Run G follows the failed first module-authority ballot. It adds executable Lean
producer and structural folds that consume module identity-to-label evidence,
positioned parent edges, Java-equivalent arity/interior/non-nullary guards, and
computed results. It also models schema-v9 exact, malformed, and nonexact
standalone outcomes.

- Evidence directory: `/tmp/acgn-subtype-section3-final5`
- Outcome: `INCOMPLETE`
- Executed steps: 57
- Failed executable steps: 0
- Open traceability diagnostics: 168
- Input-manifest SHA-256:
  `fcb8231fb5ba4d1b078e2a3793428c040963081acee5a6a59bc88b73d40fdaad`
- Output-manifest SHA-256:
  `3c200e72e98c11e124153cce9e7c34dfa7493af2ad89cdf900c701c614df9267`
- Step-results SHA-256:
  `3f6432480535fbe0b1bd5434bf16f916171124ccfc76e721281a56b11c846a20`
- Summary SHA-256:
  `bf79e2ee0c28353128718276bddb497522c638f6dfa773dcdf135b3817abfc7f`
- Traceability-report SHA-256:
  `2ee5fe9881f7cc3912ddf4d43919c79dcf2bd173935965d8b581b125369460e2`

Every executable step passed under pinned Lean 4.33.0. The run remains
development evidence over a dirty tree, and the 168 broader open obligations
keep the correct outcome `INCOMPLETE`. The audit-log bytes added by this record
postdate its input manifest, so a manifest-stable successor run is required
before the replacement review ballot.

## Development Run H: Correlated Dependent-Type DAG

Run H exercises dependent theory v7 and wire schema v10 after replacing the
single-product subtype projection with a normalized DAG of correlated ordered
products. It covers UNION/INTERSECTION normalization, ordered ARROW Cartesian
products, exhaustive JOIN alternative-pair decisions, `univ` nonauthority,
parser-result agreement, producer serialization, and independent verifier
mutation rejection. The standalone
`formal/DependentTypeDagStandalone.lean` module is included in the exact Lean
file census.

- Evidence directory: `/tmp/acgn-section3-dag-release-prep-v2`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `959d5701f0c55606a1e717b89f09feee774dda66e6d7a92d261346c966750908`
- Output-manifest SHA-256:
  `9fc7abaa2083465874d02cf8e1ef4ca5de5fea382cf50e9dae0c4a73d5fb4b8a`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `7d7b48d2358c22e805cc871af7738c396978235f604ae04acff827c33dfc7204`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

All 58 executable steps passed. The outcome remains `INCOMPLETE` because the
closed 160-claim catalog deliberately retains 180 formal, implementation,
coverage, provenance, and immutable-review diagnostics. This dirty-worktree
run is bounded regression evidence and does not certify arbitrary Alloy type
hierarchies or Java-to-Lean refinement.

## Development Run I: Pre-Consumption Hierarchy Validation

Run I follows the first correlated-DAG review round. It validates the combined
input hierarchy before JOIN or intersection can consume boundary columns and
adds a parser-backed distinction between subset-signature carrier types and
primitive nominal parent paths. It also includes the standalone DAG Lean model
and every prior bounded Section 3 step.

- Evidence directory: `/tmp/acgn-section3-release-cleanup-v3`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `48db630a0e91a566ad04ca29716b9323ad8bb34b7dd87ed06b560c84e764cd0c`
- Output-manifest SHA-256:
  `084db74aac0845da241009795f7b93283915e95b9068519a365f2c552cc77971`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `c3657f510fd27ec2ca391c1f8cdf72439fc791b698da44b6b61e4091c6d3e1aa`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

All executable steps passed. The expected exit status remains 3 because 180
catalog obligations are explicitly open, so this is not a whole-artifact
certification. The run was made on a dirty development tree, and this log entry
postdates its input manifest.

## Development Run J: Closed Carrier And Toolchain Boundaries

Run J follows invalidated Luna Round 2. It denies dependent authority to every
explicit `univ` operand, restricts dependent columns to `Int` or nonempty
`AlloySig:*` identities, and selects Lean 4.33.0 through the repository
`lean-toolchain`. The run context records the resolved 4.33.0 executable.

- Evidence directory: `/tmp/acgn-section3-release-cleanup-v4`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `6eac8f4b75ea9fd87c17bfbecb0bfa72c55567f605bb85c414602f805f8a2e2f`
- Output-manifest SHA-256:
  `4922c2b843573280aa0adce8dd60eaa20d3df2788b1611536a992d9a7416de2f`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `6c7552e4a7cc691965dd9271f94b3d70e863f8e4d2ef5cf1519ad630bfef4a8d`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

Every executable step passed, including 67 focused dependent-chain checks and
both dependent Lean modules. The broader 180 diagnostics keep the correct
outcome `INCOMPLETE`; this dirty-tree development run is not a release ballot,
and this log record postdates its manifest.

## Development Run K: Complete-Operand Authority Preflight

Run K moves module and hierarchy validation ahead of the entire DAG fold, so
no intermediate exact JOIN can consume the only evidence before a later
foreign operand enters. It retains the closed carrier and pinned-toolchain
repairs from Run J.

- Evidence directory: `/tmp/acgn-section3-release-cleanup-v5`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `507038f6165b7a87accc9ac8712f4dbb8a53de07e967d29a87e865300d9db573`
- Output-manifest SHA-256:
  `633918c704738e96d8806ef87d5189ac03e46b5f4d7a4072e3a343417b0152ac`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `6229b95bff044f8c1e5510a10f96996eb546481bc88aba08117c49f6dddb5bab`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

All executable steps passed, including 68 focused dependent-chain checks. The
runner correctly remains `INCOMPLETE` for the unchanged 180 broader open
obligations. This is dirty-tree development evidence; the log entry postdates
the recorded input manifest.

## Development Run L: Direct Boundary Formal Parity

Run L makes explicit-`univ` denial part of the standalone Lean boundary
function itself, matching the Java producer and standalone verifier before the
whole-family JOIN/ARROW admission layer is consulted.

- Evidence directory: `/tmp/acgn-section3-release-cleanup-v6`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `a74c5d9c3aa10b3d3e1d0e7693c2fc4858ba6f6bb3565980f2c5604ba24fba4b`
- Output-manifest SHA-256:
  `17243975e113c8a6ed70fd783fbb79b135cac6eb8099f32b3255ab9c1968bc1c`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `33ee59d1528b64c255934ab729bd1e8d290a96a29e920124fc41c39faaa867ac`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

All executable steps passed. The run remains correctly `INCOMPLETE` for 180
broader diagnostics and remains dirty-tree development evidence whose log
entry postdates the input manifest.

## Development Run M: Exact Explicit-Univ Endpoint Semantics

Run M corrects the overbroad explicit-`univ` denial recorded in Runs J and L.
Parser-provided `AlloySig:univ` is an exact unary relation carrier. It may
therefore occur at either endpoint of an ordered dependent JOIN sequence, with
concrete-to-`univ` boundaries justified by the authenticated parser subtype
path. Missing or unresolved type evidence still cannot invent `univ`. JOIN
flattening remains guarded against an interior unary operand, the arity shape
for which reassociation is not generally valid.

- Evidence directory: `/tmp/acgn-section3-univ-v8`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `d27724d06d1dcf27994c5041ff15ca89ab3fd5a00bb2cd33458875a950991d78`
- Output-manifest SHA-256:
  `4332975adebbd4f666c51a6a84db0ba213703d63cfa6b68bd6bdc86d90047af8`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `1d4eb743cccb237a5f9029142b40bed9a49a2762cc815d52e05c721f3139a276`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

All executable steps passed, including 83 focused dependent-chain checks, 504
pipeline checks, 101 producer/verifier mutation checks, and both dependent
Lean modules. The unchanged 180 open catalog obligations correctly keep the
whole-artifact result `INCOMPLETE`. This is dirty-tree development evidence;
the log entry postdates the recorded input manifest.

## Development Run N: Typed-Empty Dependent Families

Run N repairs the parser-valid all-disjoint JOIN boundary. A successful
complete disjoint matrix now yields a positive-arity typed empty family rather
than an unsupported fallback. Ordered source `Seq` structure and every
disjoint decision remain committed; only a computed nullary relation remains
outside the supported Alloy relation slice.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v9`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 180
- Input-manifest SHA-256:
  `5c4040ac33968bae48c275b4877e4a0cab7c93cdaf68f2a9b20b57f46b87b7f6`
- Output-manifest SHA-256:
  `e5fcf2ba4013018c1ba3987287a64664068f7120b6b752d54412a6f66e2a135c`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `61b6bd7523940ff8bd7382a4df8b373e036edd89a44333fd41b09e810e602d80`
- Traceability-report SHA-256:
  `39177aec7696ed3b7988c1a18e384b5538c7ba75a0f2c822ddb881936ceb8f5c`

All executable steps passed, including 102 focused dependent-chain checks,
508 parser-pipeline checks, 101 writer checks, 107 producer/verifier mutation
checks, and both dependent Lean modules. The unchanged 180 open catalog
obligations correctly keep the whole-artifact result `INCOMPLETE`. This is
dirty-tree development evidence; the log entry and this run description
postdate the recorded input manifest.

## Development Run O: Correlated Authority and Empty-Source Replay

Run O closes three bounded implementation/model contradictions found against
Run N. Typed-empty interior JOIN operands now use the same retained-arity guard
in producer and verifier; parser-empty UNION and INTERSECTION nodes recursively
derive their source DAGs before comparing the parser result; and the correlated
Lean family model binds every column to a live parser module plus object and
nominal ancestry paths. Theory v10 records both the source-derivation rule and
the typed-empty interior guard. Claim A2-27 makes the remaining Java/parser to
Lean refinement obligation explicit rather than treating the formal authority
model as complete.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r2`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `d7ab6ef65f232039df2620f421ea3a58ae397bba6fb78791d47f728b58ca195f`
- Output-manifest SHA-256:
  `eb33816946a026fea96d9d53b42ef565da63b2f523997cc86036a15ca6b0fdbb`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `624cbe29dd73d9c9d7d91e481f960ab54332bc6442bb4859a141c8300f83d08e`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All executable steps passed, including 109 dependent-chain checks, 514
parser-pipeline checks, 104 writer checks, 110 producer/verifier mutation
checks, and both dependent Lean modules. The newly scoped A2-27 row raises the
catalog from 160 claims and 180 diagnostics to 161 claims and 182 diagnostics;
that honest expansion keeps the whole-artifact result `INCOMPLETE`. This is
dirty-tree development evidence whose log entry postdates the input manifest.

## Development Run P: Total Variadic Guards

Run P follows the invalidated Round 8 snapshot. Every Java variadic JOIN fold
entry point now checks the same interior-arity predicate before combination;
the parser-correlated Lean fold rejects absent authority entries; and every
standalone typed-family operation validates positive arity and product width.
The A2-27 claim distinguishes parser-owned ancestry proofs from exact primitive
singleton leaf proofs. GC-F79 separately records that raw set-operation source
derivation is not independently replayed by the current wire schema.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r5`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `916ba775dd1c86a41adb9a7d171bdb2454272c3ecfc93155c1b2234bfbfafcbb`
- Output-manifest SHA-256:
  `4c44d9b7f6f27dd9e4577e26651aa1eacd647451b04b71f8518af1234b39051f`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `3ebb220fdd5d0717e7c10a2c298bdb1c9dcb9d319f8436875d80df89a0103be7`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All executable steps passed, including 112 dependent-chain checks, 514
parser-pipeline checks, 408 aggregate theory-certificate checks, 104 writer
checks, 110 producer/verifier mutation checks, and both dependent Lean modules.
The 182 explicit open obligations keep the correct result `INCOMPLETE`. This is
dirty-tree development evidence whose log entry postdates the input manifest.

## Development Run Q: Exact Atomic Column Parity

Run Q follows the invalidated Round 9 snapshot. Standalone replay now admits
exact dependent columns under the same closed vocabulary as producer
construction: `Int` or a nullary constructor with a nonempty `AlloySig:`
identity. The raw Lean JOIN fold also validates its empty-rest base case. The
scalar column helper is explicitly scoped to nonempty single products; typed
empty arity is retained by the graph-type and DAG family paths used in
production.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r7`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `7b17812b61c5bc4faf91fdf477dc53752966f298bf75b4fc793fc4e49631be98`
- Output-manifest SHA-256:
  `9f43546b1bd859546aa50aa77414e3a0addc30df881218c9d59ef2fef60c3e50`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `eaec95e284cd2506169acb78a5da1b99dcb6a00b3b2ac8e21a5acac8cca14fe4`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All executable steps passed, including 142 standalone verifier checks, 112
dependent-chain checks, 514 parser-pipeline checks, 408 aggregate theory
certificate checks, 104 writer checks, 110 producer/verifier mutation checks,
and both dependent Lean modules. The 182 explicit open obligations keep the
correct result `INCOMPLETE`. This is dirty-tree development evidence whose log
entry postdates the input manifest.

## Development Run R: Closed Typed-Family Helper Boundaries

Run R follows the invalidated Round 10 snapshot. The standalone variadic guard
now validates every family itself, the ARROW certification theorem crosses the
typed-family boundary, and the format contract agrees that a positive-arity
typed empty may participate in dependent JOIN/ARROW evidence without inventing
columns or nominal boundaries.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r8`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `8ed3983d1e0ef00f251f0e43c4f1b39e7944932af542847f7f0807aa5e2d6f31`
- Output-manifest SHA-256:
  `34cb80d5237161146ea817358f7b280f4cb1f6e51f0988e4300d0367771a0606`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `74e92ed40b4528744732596a76ddf4876f581ba208881d75254cee366e62622f`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed with the same focused census as Run Q. The 182
explicit open obligations keep the correct result `INCOMPLETE`. This is
dirty-tree development evidence whose log entry postdates the input manifest.

## Development Run S: Primitive Singleton Identity Parity

Run S follows the invalidated Round 11 snapshot. Producer primitive singleton
conversion now rejects an empty Alloy signature identity before constructing a
unary relation view, matching dependent DAG and standalone verifier admission.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r9`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `6a48db01c8cdc32f6da613585b35ba9ef2f3d32d3254248caec6ab7e60951a21`
- Output-manifest SHA-256:
  `c5d8e7be1a80c20f48ce06cad0f935338ff32c2b5c34f49869016793db1f0756`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `a8586209920ed147d70a28e895b8b2f837a2e04384c2b6ef531e7146a550b9c4`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 114 dependent-chain checks and 410
aggregate theory-certificate checks. The remaining focused census matches Run
R. The 182 explicit open obligations keep the correct result `INCOMPLETE`.
This is dirty-tree development evidence whose log entry postdates the input
manifest.

## Development Run T: Whitespace-Free Atomic Identity

Run T follows the unanimously failed Round 12 snapshot. Producer DAG,
correspondence, primitive conversion, and standalone replay now reject a blank
or whitespace-bearing `AlloySig:` identity through mirrored atomic-column
predicates.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r10`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `fd38afedb7599d2fcd5466e40126ed315615cbee85cf19d75c0bfb37d4c97ad8`
- Output-manifest SHA-256:
  `fb4aa9062fd1bba6da8ec6a5f3ae2da6877b4c4a612474c4bf596d8d31a3f05f`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `93c4b5f8988113debcfd654d3627194f45e0881e94fa7e6559871c776ded34db`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 116 dependent-chain, 412 aggregate
theory-certificate, 143 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run U: Unicode Space-Separator Closure

Run U strengthens Run T's whitespace-free identity rule to reject Unicode
space separators that `String.isBlank` alone does not classify, with an escaped
`U+00A0` producer/verifier witness.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r12`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `fa48e490f8ad1c7fdffe2400209bc28b91ba26d4fa23b6e9c092397599f9d442`
- Output-manifest SHA-256:
  `9dbcc15e1c5c845f25b3d3ba923839ea01b1e49dc1b55541d1ca025f09a7d0f3`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `9f4d8688aec37fcef990b6496cee4c5d66326ee532426924170727b3441681a4`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 117 dependent-chain, 413 aggregate
theory-certificate, 144 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run V: Typed Fallback And Sequence Replay

Run V follows the failed Round 13 snapshot. It closes the sequence-ancestry
producer/verifier mismatch, validates exact leaf families before proof
issuance, rejects malformed exact and binding identities at ingress, and
restricts binary fallback to explicit unsupported-theory markers.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r14`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `fab0780edcc96330a644fc0a3b27701ad9f506eabd22fe067c9f5692253579fd`
- Output-manifest SHA-256:
  `f583fdf000762621dd2aa2af7a6b52a81df354b0432df37278682e80f822757f`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `ed3c1a9dbc2ee4e08b20207174a2cdd5221fe98ae221e7e9e124020d6e7f6b6e`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 119 dependent-chain, 415 aggregate
theory-certificate, 144 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run W: Fail-Closed Column Conversion

Run W follows the failed Round 14 snapshot. Package-level conversion no longer
trims a whitespace-bearing identity into a new Alloy signature identity.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r15`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `231d5a840cc968b5e15539962f519aac3a0bf451bcc9ea2a4ce18d8e42251279`
- Output-manifest SHA-256:
  `682e602b19c71b9e5a1eddb3fa592eb6739e462464a64021ec9f448e7fa47aa0`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `236756c02b551519f7446f871afdc38c4069cce1c0ea615b297ddb62fc0647cd`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 120 dependent-chain, 416 aggregate
theory-certificate, 144 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run X: Well-Formed Scalar Identity

Run X follows the failed Round 15 Terra tier. Producer and verifier now reject
identity code points that are invisible, lossy under UTF-8, or outside the
admitted parser-label scalar categories.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r16`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `d7d4c93b6ba4aec3fdd9c2a7cbba1b2b9576e2b43a64775dc9c534a4bc9216f8`
- Output-manifest SHA-256:
  `4ed341b2734f689f42ecc0b05072bd153fed83346b127e3dd31b5491dd428f8f`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `130735ea0cdbb38008544a0340fe80d88fbbe7a0a7d24ffb1f20dcb944f80aba`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 125 dependent-chain, 421 aggregate
theory-certificate, 147 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run Y: Strict Canonical UTF-8

Run Y follows the unanimously failed Round 16 Luna tier. Canonical producer
encoding and polymorphic-key verifier decoding now reject malformed Unicode
instead of replacing it, and the identity matrix includes excluded private-use
and unassigned code points plus one admitted supplementary-plane scalar.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r17`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `da29cf09bea18323b7ff887749e4bd4652e55146db53ae19617338cea0dada7c`
- Output-manifest SHA-256:
  `f00fdda35684dec03c12bbe4dee13f287455b9a1892e7f88a7fbafb7bcdd4267`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `5dbde3cfd0217d7229050344d1db41d0f1c79f29cd583f7b80144b2b4b000e74`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 132 dependent-chain, 428 aggregate
theory-certificate, 154 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run Z: Constructor-Level Identity Closure

Run Z follows the unanimously failed Round 17 Luna tier. Exact-type wire
symbols, in-memory wire nodes, and public Alloy signature symbols now enforce
the same identity boundary before hashing or serialization.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r18`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `c3039d45b336ac98ade15f883ba89e4768aea89db952d4288c67b074d6536ae4`
- Output-manifest SHA-256:
  `e0e493d548ecc67dc97163da4eee3d7d0d595e38bdee047658b709f3741ef681`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `a3b6dc80421046c1bb5e9f561c0247bccbf60c8277b25b5ff32ee988b1f27910`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 137 dependent-chain, 433 aggregate
theory-certificate, 159 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run AA: Producer Identity Parity

Run AA follows the unanimously failed Round 18 Luna tier. Generic graph-type
symbols now match verifier admission, public exact types normalize parser
`this/` prefixes, and the nested structural-key/wire length units are explicit.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r19`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `641d4cb82a5a0a0b32a3027744bcd1b4612599e0fcc2b27d23fdb1bed46d8b09`
- Output-manifest SHA-256:
  `044f01a230648ca6383690b96e3052570f84ef1f8f4ab33b6ad9e01878212a09`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `6a6063985fa9992f41658b3b4bfd108b49de246578564109baf218db783b1e8a`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 142 dependent-chain, 438 aggregate
theory-certificate, 159 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run AB: Canonical Alloy Prefixes

Run AB follows the locally aborted Round 19 Luna tier. All producer Alloy
identity constructors now agree on one `this/` normalization rule and verifier
wire replay rejects noncanonical aliases.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r20`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `5ce4ae75cc24764e621b4505d05bfe80846cc29d4b93955078062d52a7df5fa5`
- Output-manifest SHA-256:
  `88d3f1612183b8e5df8ea4f95a7fc4ac924cd9130c6f244512313bd144785cec`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `fae2c916db291dbfc26f8281a08e827e5ebd2123e1fe10e8c289707652412a47`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed, including 146 dependent-chain, 442 aggregate
theory-certificate, 162 standalone verifier, 104 writer, 110 mutation, and 514
pipeline checks. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run AC: Polymorphic Identity Admission

Run AC follows the failed Round 20 Luna tier. Operator and type-parameter names
now share the visible-identity boundary used by their graph types.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r21`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `624af87bad0535e114b07ea7f5a360f9a00301554c6a580dfc783cf74b95ef2d`
- Output-manifest SHA-256:
  `42cf7ee200a50256a2cae28859f1337d8a3f4720ab69e90696bc06255df1b5ff`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `882c1f2bab6a5382d8a3dd91c676e08c619279bb500fe29f862238e9cd7bf5c8`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed. Current focused counts include
`TheoryPortsTest=1,014`, dependent-chain `146`, aggregate theory-certificate
`442`, standalone verifier `162`, writer `104`, mutation `110`, and pipeline
`514`. The 182 explicit open obligations keep the result `INCOMPLETE`. This is
dirty-tree development evidence whose log entry postdates the input manifest.

## Development Run AD: Verifier Declaration Identity

Run AD follows the failed Round 21 Luna tier. Standalone polymorphic parameter
and operator semantic identities now match producer declaration admission.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r22`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `f21c951a26c9f7b8b771b1dbde83d25c5a0b45726a3bcef156b6c8128644ad25`
- Output-manifest SHA-256:
  `3e9e2d54ae5a3273f739f8bb29076ec5c873c7fa84b0a4d93d723ca9b0522483`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `85195baee46bc43c51decefbc1663a20709720e1187c86c9dbd265868ee20a14`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed. Current focused counts include
`TheoryPortsTest=1,014`, dependent-chain `146`, aggregate theory-certificate
`442`, standalone verifier `174`, writer `104`, mutation `110`, and pipeline
`514`. The 182 explicit open obligations keep the result `INCOMPLETE`. This is
dirty-tree development evidence whose log entry postdates the input manifest.

## Development Run AE: Exact-Type Reference Namespace

Run AE follows the failed Round 22 Luna tier. Exact-type content IDs and
distinct human-readable displays now form disjoint reference namespaces before
the verifier resolves any reference.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r23`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `3d5fa9d27aa5d4da3430742e98e605f418242ea24b3fe110d98d6b783bcbba10`
- Output-manifest SHA-256:
  `a95789d47cb7a1373df23c129a9b7078aee8c54f0bd77c9cecb98b19af32e514`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `6be73ad064c726ed6eba47e902691a2a4e604ddb175d0428917c9f90b36a425b`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed. Current focused counts include
`TheoryPortsTest=1,014`, dependent-chain `146`, aggregate theory-certificate
`442`, standalone verifier `175`, writer `104`, mutation `110`, and pipeline
`514`. The 182 explicit open obligations keep the result `INCOMPLETE`. This is
dirty-tree development evidence whose log entry postdates the input manifest.

## Development Run AF: CALL Visible Identities

Run AF follows the failed Round 23 Luna tier. CALL source names, qualified
callees, and occurrence paths now share the producer/verifier visible-identity
boundary. A concurrent blanket traceability promotion was quarantined before
this run and is not part of its input.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r26`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `4d4e2d54c78a2f2af0a1f0a16710a0a8bc7422b41c1905e30887213ee78f6156`
- Output-manifest SHA-256:
  `58e5d6914a611ccbd3910667ad70fa576c57e9db3308f1c30cbf962b0e70b32b`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `1b062d750d436167e6c2666d63f9c5b345ca0b54bd91f9a820d85385e8c22c7c`
- Traceability-report SHA-256:
  `5b4f1f613c7130bb043b9dff8b692f8669020e32806665c93b8b83bf40781af8`

All 58 executable steps passed. Current focused counts include CALL extraction
`148`, `TheoryPortsTest=1,014`, dependent-chain `146`, aggregate
theory-certificate `442`, standalone verifier `175`, writer `104`, mutation
`110`, and pipeline `514`. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run AG: DAG Authority And CALL Completeness

Run AG follows the failed Round 24 Terra tier. Recursive set-DAG comparison
now preserves parser-module occurrence authority, and CALL occurrence evidence
is closed under both producer-ledger and standalone operator coverage.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r30`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `9c24b73c231630382ec0fe46df837dc8f3826590f8c3f34739306ce0af09c93a`
- Output-manifest SHA-256:
  `ee1dbe6dfeef9a347810be09ef40b0fab2d66b6df63e1a4600c78bb386c97685`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `7babfbfa2e67ae85c1dfd7ce5e45d7ff923f87730b820265339ceb76035e5709`
- Traceability-report SHA-256:
  `2ea5f26bfdae15b543925044fb3cbf3b416552b5c00a53b94a0908d7f5d8ad48`

All 58 executable steps passed. Current focused counts include CALL extraction
`148`, `TheoryPortsTest=1,014`, dependent-chain `149`, aggregate
theory-certificate `445`, standalone verifier `175`, writer `105`, mutation
`111`, and pipeline `514`. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run AH: CALL Occurrence Anchors

Run AH follows the failed Round 25 Luna tier. Each replayed CALL wire
occurrence now has an injective provenance-only model anchor, so same-operator
nested occurrences do not collapse in the completeness check.

- Evidence directory: `/tmp/acgn-section3-release-candidate-v10-r34`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `fb0474388fec781aaabda679440066beb0492981c1a8aff889faefb48de0dd20`
- Output-manifest SHA-256:
  `b54463d4c955b803d0839549a7de8419aeb111c03047eff9da71f8c6dfa57fd8`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `122c68ce438e3a807ede77cf114166bea54ecb6a9b18c1032ca9fa66e8d455ba`
- Traceability-report SHA-256:
  `2ea5f26bfdae15b543925044fb3cbf3b416552b5c00a53b94a0908d7f5d8ad48`

All 58 executable steps passed. Current focused counts include CALL extraction
`148`, `TheoryPortsTest=1,014`, dependent-chain `149`, aggregate
theory-certificate `445`, standalone verifier `175`, writer `109`, mutation
`113`, and pipeline `514`. The 182 explicit open obligations keep the result
`INCOMPLETE`. This is dirty-tree development evidence whose log entry postdates
the input manifest.

## Development Run AI: Narrowed CALL Authority

Run AI follows the unanimous Round 28 Luna failure. CALL markers retain exact
unpaired-tampering and isolation checks, while documentation and traceability
now state that coordinated source-ledger omission needs raw source replay or
an external occurrence authority.

- Evidence directory: `/tmp/acgn-section3-release-final-v2`
- Outcome: `INCOMPLETE`
- Executed steps: 58
- Failed executable steps: 0
- Open traceability diagnostics: 182
- Input-manifest SHA-256:
  `cdd634bbbc792e1211c5eb4ddbf1ef14f62baa800fb782edca8fe30f0959312f`
- Output-manifest SHA-256:
  `d1da724d354afae9ad440313ec09adf8f0e07e6bd1f207a2fa39912ab734b6f4`
- Step-results SHA-256:
  `999478aac067e7830cfdc17ad6a225b5e56a8833b3e51aad52031f77b70ff09a`
- Summary SHA-256:
  `962795026e049ced775b95015ba4c7aa49dc16a76ed7c820384cb48af1733b45`
- Traceability-report SHA-256:
  `2ea5f26bfdae15b543925044fb3cbf3b416552b5c00a53b94a0908d7f5d8ad48`

All 58 executable steps passed. Current focused counts include CALL extraction
`148`, `TheoryPortsTest=1,014`, dependent-chain `149`, aggregate
theory-certificate `445`, standalone verifier `179`, writer `109`, mutation
`113`, and pipeline `514`. The 182 explicit open obligations, including the
newly explicit GC-F108 authority boundary, keep the result `INCOMPLETE`. This
is dirty-tree development evidence whose log entry postdates the input
manifest.
