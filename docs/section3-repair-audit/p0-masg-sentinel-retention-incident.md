# P0 MASG Sentinel Retention Incident

## Symptom

`CanonicalBatchTest` slowed sharply near file 35,000 and eventually exhausted an
8 GiB Java heap. The run used 32 workers and `--skip-rewards`, so neither the
reward solver nor serial report generation was active.

## Live Evidence

The affected JVM was inspected before it exited:

- heap: 8,347,100 KiB used of 8,388,608 KiB;
- process CPU: approximately 2,256%, with all 32 workers active;
- worker stacks: exact graph construction and repeated invariant/certificate
  verification;
- dominant retained objects: approximately 81,600 `CompModule` objects,
  199,000 `Multigraph` objects, 6.6 million `MASGEdge` objects, and 12.6
  million Alloy `ExprUnary` objects.

The count of one `GlobalVariables` object per completed source file ruled out
an ordinary 32-task working set.

## Root Cause

`MASGVisitor` previously exposed one static mutable `END_NODE` and one static
mutable `SHADOW_NODE`. `AugmentedNode.connect` stores graph-specific edges and
occurrence evidence in the node itself. In particular, a target node retains
every incoming edge in `uplinks`, while occurrence maps use `Multigraph` as a
strong key.

The static root therefore formed this retention path:

```text
MASGVisitor.END_NODE
  -> uplinks / graph-keyed occurrence maps
  -> completed Multigraph and MASG nodes
  -> ExactAlloyType / GlobalVariables
  -> parser CompModule and Alloy AST
```

The heap growth was cumulative and genuine; GC could not reclaim these
objects because they remained reachable from a static field.

## Repair

`END_SYMBOL` and `SHADOW_SYMBOL` remain shared semantic symbols. Their mutable
`AugmentedNode` carriers are now allocated once per `MASGVisitor`, so sharing
within one parsed module is preserved while cross-module retention is removed.
Node equality and structural labels are unchanged.

`CanonicalBatchTest` now also visits only the selected predicate pair and its
transitive local callable dependencies. It retains the established full-model
fallback if focused construction rejects a parser edge case. Stable fields for
the first 100 `socialMedia` results are byte-identical between focused and full
construction; only measured timing fields differ.

The call-corruption regression now obtains the END node from the graph under
test instead of relying on a global node. `MASGVisitorTypeRegressionTest`
requires that two visitors have distinct END and SHADOW nodes and that running
the second visitor leaves the first visitor's END links unchanged.

## Workload Boundary

Sorted corpus order enters `classified-data/socialMedia` at item 34,774. This
coincides with the reported slowdown and adds a real, smaller cost increase:

| Bounded slice | Workers | Files | Throughput | Average exact preparation |
| --- | ---: | ---: | ---: | ---: |
| Corpus prefix (`classroom_fol`) | 8 | 500 | 15.73 files/s | 418.17 ms/file |
| `socialMedia` prefix | 8 | 100 | 10.40 files/s | 516.10 ms/file |

The certificate-integrated construction remains allocation-heavy because it
checks graph invariants and recursively verifies certificates during exact
preparation. This explains the lower `socialMedia` throughput, but not the
unbounded heap growth or the eventual OOM; those were caused by the shared
mutable sentinel.

## Bounded Verification

- all Java sources compile with Java 17 and UTF-8;
- `MASGVisitorTypeRegressionTest` passes;
- `CallExtractionRegressionTest` passes 150 checks;
- `CanonicalAlloyPipelineTest` passes 514 checks;
- a 500-file `CanonicalBatchTest` run with eight workers, `-Xmx1g`, and
  `--skip-rewards` completes in 32.00 seconds and writes both reports;
- all stable JSON result fields match full-model construction on a 100-file
  `socialMedia` differential.

This is bounded moving-worktree evidence. A full-corpus rerun is still required
before replacing publication measurements.
