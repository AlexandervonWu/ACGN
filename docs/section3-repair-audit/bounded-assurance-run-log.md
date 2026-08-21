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
