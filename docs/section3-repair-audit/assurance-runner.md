# Bounded Assurance Runner

## Entry Point

`scripts/run_section3_assurance.sh OUTPUT_DIRECTORY` is the nonprotected
requirements-based verification entry point. It does not invoke or modify the
historical corpus experiments, result trees, publication manifests, or their
protected terminal scripts.

The output directory must be absent or empty. Reusing evidence paths is
rejected so stale logs cannot silently survive a run.

## Frozen Inputs

Before compilation, the runner records every regular file and symlink under
the scoped producer source, standalone verifier, formal proofs, assurance
documents, libraries, and runner itself. Each row binds the SHA-256, Unix mode,
object type, and repository-relative path. The run context separately records
the Git commit, dirty-tree state, Java/Javac/Lean versions, host, kernel,
logical CPU count, heap bound, and timeout bounds.

This development manifest does not assert SHA-256 injectivity or tool
qualification. It makes byte substitution detectable under those explicit
environmental assumptions.

## Executed Evidence

The runner performs these bounded steps:

1. Compile all producer and independent-verifier Java with Java 17 and explicit
   UTF-8 source encoding.
2. Run the focused CALL extraction, source-rule, graph, metric,
   dependent-chain, canonicalization, determinism, and traceability suites
   with assertions enabled and a bounded heap.
3. Run the standalone verifier and semantic-evidence mutation suites without
   the producer classpath.
4. Compile every Lean file in `docs/section3-repair-audit/formal` with the
   pinned Lean executable.
5. Reject any formal file containing a raw `sorry`, `admit`, `axiom`, or
   `unsafe` token.
6. Require exact equality among the 154-entry checked-in scope manifest,
   ledger, and matrix; run the traceability anti-counterfeit tests; and
   regenerate the complete claim catalog for byte comparison.
7. Recompute the complete input manifest after all execution and reject any
   time-of-check/time-of-use difference.
8. Hash every generated log and compiled class into the output manifest.

Each command has a wall-clock timeout. A timeout is `FAIL`; it is never retried
inside the assurance run. Defaults are 300 seconds per Java step, 120 seconds
per Lean file, and a 1 GiB Java heap. The environment variables
`SECTION3_JAVA_TIMEOUT_SECONDS`, `SECTION3_LEAN_TIMEOUT_SECONDS`,
`SECTION3_JAVA_HEAP`, and `LEAN_BIN` may override those values and are recorded
in the evidence.

## Outcomes

- `PASS` / exit 0: every executable step and every traceability row closes.
- `FAIL` / exit 1: compilation, proof, test, scan, or manifest production fails.
- `INCOMPLETE` / exit 3: executable steps pass but at least one scoped claim
  remains unmapped or partially conformed.
- Usage failure / exit 64: invocation cannot define a fresh evidence run.

No current document may cite an `INCOMPLETE` run as assurance success.
