# Augmenter Native Solver Startup Failure

## Incident

Run `acgn-full-20261106T204318Z` completed CanonicalBatchTest over 66,080
files: 61,598 successful distances, 4,482 AST-identical skips, zero distance
failures and zero reward failures. Alloy4FunAugmenter completed all 42,386
incorrect-predicate rankings, then crashed at parallel reward startup.

The JVM exited with SIGBUS (exit -6), not a Java semantic exception or an
OutOfMemoryError. The preserved report is
`/home/augustus/acgn-full-20261106T204318Z/source/hs_err_pid2819296.log`.
The supervisor stopped before ablation, capability, and typed/untyped stages.
Partial augmenter outputs must not be treated as a completed evaluation.

## Evidence and Cause

- Failing thread: `pool-4-thread-9`, in `Rewarder.instances`.
- Stack: `SATFactory.get("sat4j") -> find -> getSolvers -> isPresent ->
  initUnused -> System.load -> dlopen`.
- Fault address `0x000078b33405cf58` lies in the mapped `libglucose.so`,
  extracted under `/tmp/alloy-7827283377699654638/`.
- The installed Alloy 6.2 bytecode shows that `getSolvers` is unsynchronized.
  Concurrent first lookups construct separate service-provider instances;
  per-instance initialization locks therefore do not serialize discovery.
  Native extraction uses shared paths and `Files.copy(..., REPLACE_EXISTING)`.
- A fresh-JVM regression run against the pre-fix Rewarder independently
  produced concurrent `FileAlreadyExistsException` errors for native
  `electrod` extraction, then failed the discovery sentinel assertion.
- At the fatal report the heap used about 5.6 GiB, below its 8 GiB limit.
  The supervisor also recorded available memory and disk space. The observed
  failure is native loading, not evidence of GC exhaustion.

These observations identify concurrent global solver discovery as the faulty
path and support a native extraction/loading race as the SIGBUS mechanism.
They do not claim to reconstruct every instruction interleaving of the crash.

## Repair and Semantic Boundary

Rewarder selects `SATFactory.DEFAULT` directly at both solver-use sites. In the
pinned Alloy 6.2 library this is the same SAT4J singleton selected by successful
`get("sat4j")` discovery, without probing unrelated native backends.

The later capability and ablation semantic-check paths use the same direct
selection. `AlloyEquivalenceValidator` resolves SAT4J directly too; explicit
nondefault requests retain discovery, serialized within that resolver.
Unknown identifiers still fail closed, and replay retains its exact solver-ID
check. This is not a general repair of Alloy's public discovery implementation;
unrelated callers of its raw API are outside this patch.

No rewrite rules, certificate semantics, scopes, reward arithmetic, instance
pool sizes, or solver search options change. There is no new Lean theorem or
rewrite obligation: the change is dependency/runtime initialization within the
existing Java/solver trusted computing base. Runtime identity and behavior are
tested, not presented as a Lean proof of JVM concurrency or SAT4J correctness.

## Regression

`RewarderConcurrencyTest` starts 16 workers together in a fresh JVM, half with
static predicates and half with temporal predicates. It checks self-reward
equals 1 and negated-oracle reward equals 0, exercises the saturated-pool solver
checks, and creates semantic execution options concurrently. An unrelated
solver sentinel rejects global discovery. The solver ID and lack of native
libraries are checked explicitly.

The initial Rewarder-only regression passed ten fresh JVM repetitions
(320 reward assertions); the old Rewarder failed the negative control.
The extended test is registered in `scripts/run_bounded_ci_java_tests.sh`.

Validation completed for this patch:

- Bounded Java CI script: exit 0, 52 `Running` entries, including the extended
  concurrency regression, Lean temporal-command guard, and distance-artifact
  regeneration checks. Log: `/tmp/acgn-reward-native-bounded-ci.log`.
- Full augmenter smoke workflow: 64 source files, 16 requested workers, pool
  size 100; 64 rankings and 64 successful rewards. Parse, reference-pool,
  ranking, and reward failures are all zero. Outputs:
  `/tmp/acgn-augmenter-reward-native-smoke/`.
- Negative control against the original JAR: exit 1 with the unrelated-solver
  sentinel assertion. Log: `/tmp/acgn-reward-native-negative-control.log`.

## Continuation Policy

Preserve the failed run, original JAR, manifests, logs, and completed canonical
outputs. A separately identified continuation must record the patched source
and JAR hashes and the inherited canonical output hashes. Recompute the
augmenter, then run the remaining stages serially. Inherited canonical results
remain attributed to their original JAR, not to the continuation build.

Continuation directory: `/home/augustus/acgn-full-20261106T204318Z-resume01`.
It uses a separate source snapshot, result directory, supervisor, and manifest;
unchanged source files are hard-linked to conserve disk space, while every
patched file has its own inode. The original source files and failed-run
outputs remain unchanged. Resources remain 8 GiB heap, 16 workers, pool 100;
synthetic trials retain one worker, 4 GiB heap, and 300 seconds per predicate.
Full-corpus continuation completion is tracked separately in its
`run-status.json`; the bounded checks above are not a full-corpus success claim.
