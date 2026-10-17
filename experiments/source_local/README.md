# Source-local cardinality prototype

A deterministic, standard-library Python controller for the **archived** Java
feedback executor. It performs no training and does not install the archived
runtime into the live repository. See [results and limitations](../../docs/repair-search/SOURCE-LOCAL-CARDINALITY.md).

From the repository root, with Java 17 including the `jdk.compiler` module:

```sh
python -m unittest experiments.source_local.test_candidates -v
python -m experiments.source_local.prepare /tmp/acgn-local-producer-new
python -m experiments.source_local.run /tmp/acgn-local-producer-new /tmp/acgn-local-audit-new
python -m experiments.source_local.run /tmp/acgn-local-producer-new /tmp/acgn-local-checked-new --check
```

Each destination must be fresh. Restore the existing evidence LFS object using
`git lfs pull` first if the checkout contains a pointer. `prepare` checks the
outer archive and input manifest, copies only the 549 pinned input files (including
matching repository JARs), then compiles all archived Java sources. It does not
invoke any producer training/preflight script or require PyTorch, Lean or a GPU.
The explicit compiler-module invocation also works when `javac` is not on PATH.
No dependencies are fetched by these scripts.

`run` verifies all producer input hashes before use. All 104 original IDs and
splits must match. Without `--check` it only loads and enumerates; the repair
count is null, not zero. With `--check`, it enumerates three alternatives for
each supported task and checks each independently from the original source.
It checks the original predicate first, requiring an actual counterexample.
There are at most two queries and sixteen decisions per candidate session;
each worker request has a thirty-second kill-and-reap deadline. A timeout or
unknown/vacuous result is never counted as repair success.

Coverage observations, all attempt transcripts, diagnostics, counts and hashes
are emitted to the fresh output directory. Offline regression uses new recorded
observations from all 95 successfully loaded natural inputs; it does not require
the Java environment. It does not re-prove the provenance of those observations.

The only edit is `card E` to another member of `no/one/lone/some`, inside a
single-binder, single-declaration, static `all x : D | card E`. Nested binders,
temporal phases and other root/body structures are refused. An AST occurrence
must have a source location; the existing MATRIX_UPDATE and COPY heads must
admit each operation. Source graph and revision bind occurrence IDs. The operand
is copied at the original lexical scope. Java COMMIT reparses/type-checks the
complete predicate. A post-commit check requires every noncanonical source table
to remain identical except the selected unary opcode. Canonical views are derived
and may change. This fingerprint is a stale-address guard, not a proof certificate.

Every committed candidate then goes to Java VALIDATE. RepairEvaluator checks
both extra and missing models for the **complete predicate** under the original
facts/command/profile. There is no local evaluator and no assignment of a whole
predicate's truth label to the edited subexpression. There is also no retained-world
prefilter across candidate sessions: full solver checks subsume such a filter
within the bounded profile. This prototype makes no query-efficiency comparison
to the historical minimum-edit baseline.
