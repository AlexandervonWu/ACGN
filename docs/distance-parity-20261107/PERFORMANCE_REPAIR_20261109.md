# Scoped Performance Repair

This is regression evidence for a performance patch, not full-corpus parity or
public certification. The corpus repair loop remains paused. No reference-pool
members, admission checks, costs, tie rules, or replay obligations were removed.

## Cause And Change

Fast Rewrite's paid grouped-declaration path repeatedly reconstructed the same
source-certified declaration orders for each reference, then again for selected
trace reconstruction. Retain successful orders on the frozen Prepared endpoint,
keyed by the actual binding identities/order and resource policy, with defensive
array copies. Never cache a failed admission or share across endpoints.

Within one synchronous TheoryAlloyAdapter invocation, shared immutable proof
premises were recursively checked repeatedly. A bounded positive identity memo
reuses completed checks only. Cycles, failed checks, mutable source admission,
wrapper predicates and graph invariants still run through their existing checks.
Scopes are thread-local, nested invocations isolate their memo, policy changes
discard successes, and capacity exhaustion falls back to ordinary verification.

The Lean memo model proves lookup equivalence under its explicit stable-verifier
and sound-memo assumptions. It is not a proof of the Java implementation or a
renewal of historical public certification bindings.

## Executed Performance And Regression Checks

- Nine retained inputs: seven historical timeout cases and two prior controls,
  each with its complete original reference pool (20 to 283 references).
- Cold one-CPU, 512 MiB final Fast Rewrite: 2.58 to 8.37 seconds; all nine complete
  below the unchanged 60-second deadline. Six old-candidate timeouts reproduced;
  the seventh completed in 52.69 seconds. Successful baseline responses agree.
- Certificate-integrated final path: 2.98 to 19.88 seconds, including both native
  selected trace directions and replay. All nine baseline/new responses agree,
  including per-reference costs, canonical digests and phase bindings.
- Across those certified pools, 1,863 actual typed-slot checks; every wrong-type
  and foreign-slot substitution rejected. Cache tests additionally reject changed
  type, alphabet and ordinal contexts and cover failure/cycle/policy isolation.
- A fixed 2 GiB heap on the three slowest reference-pool inputs preserved all
  responses in both modes, with no full GC. The 283-reference certified case
  took 16.16 seconds with 397 ms of young-GC pauses. GC is measured, not disabled.
- AlloyStudio's fresh engine build/self-test and 100 focused Python tests pass,
  including all 181 exercises' starter/self comparisons in both canonical and
  raw-AST modes, worker deadlines and work-budget controls.
- The complete bounded ACGN Java/Lean suite passes, including the existing
  19,760-check performance digest and the new cache/scope controls.

Source-contract checks pin the new memo and retain the old negative controls.
Javac's task locale is explicitly ROOT; the standalone occurrence extractor also
sets the process locale for anonymous-class names. This removes localized owner
rendering drift while preserving unchanged source pins.

The bounded contract regression passed two clean builds with identical hashes
for all 18 products, including compiled Lean artifacts. All 40 source mutations
and 32 invalid-evidence controls rejected. Of these, 21 source and 16 Lean controls
are explicitly retained from the earlier run after checked input/log matching;
they are not described as newly executed or as a successful earlier whole run.
The four compiled memo theorem audits use only declared standard Lean foundations,
with no `sorryAx`. Direct Terra review accepted this bounded evidence with no
actionable findings. Failed harness attempts remain recorded as failed.

The final contract receipt is `contracts5/result.json`, SHA-256
`823e1d0f495c631e56e26385f237f826958b200614babe30e11b8e628bfa0646`.
Full GitHub CI for the resulting commits is a separate check; the local results
above do not imply that remote CI has passed.

Timing observations apply to these inputs/environment, not a universal timeout
guarantee or a completed 4,072/66,080-file regression. Workstation receipts,
source/input hashes, complete responses, GC logs and failed-attempt records are
under the external supervision directory `performance-repair-20261109`.
