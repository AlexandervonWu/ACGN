# Why Typed Was Slower in the Mixed Smoke

## Finding

The current typed arm is not constructed by building a type-erased graph first
and annotating it afterward. However, the measured workload provides no
declaration-permutation pruning advantage, while the adapter repeatedly
materializes exact types. The smoke therefore measures extra type processing
on largely the same search, not the anticipated benefit of a substantially
smaller typed search space.

This is a limitation of the current search design and experimental coverage.
The timings alone do not demonstrate an equality/certificate semantic defect.
The experimental slotted arms do not issue semantic certificates.

## Construction Order Checked in Source

1. `AlloyAstTermAdapter.fromAst` creates each typed variable directly from
   `ExactAlloyType.from(variable.getType())`. It never first builds an untyped
   e-graph for this arm.
2. `SlotCanonicalizer.collectDeclarationGroups` partitions each declaration
   by `slotType` before `Search.visitGroup` enumerates permutations.
3. `SlottedEGraph.Core.add` includes the type in the `SLOT` shape before
   hash-consing; new e-classes receive their exposed slot colors at creation.
4. `addPermutationClosure` checks a generator's colors before composing its
   closure. Composition of admitted color-preserving permutations does not
   require enumerating arbitrary color-changing permutations first.
5. Union also checks colors before committing a merge. Those checks are
   additional safeguards; their presence does not mean the initial graph was
   untyped. The unmatched-slot completion loop still scans occupied/color
   candidates rather than using a per-color index.

## Why the Candidate Space Does Not Shrink Here

The enumerator creates groups inside individual `DECL` nodes, not across an
arbitrary whole prefix. In the sampled valid source, each multi-variable
declaration already gives its variables the same domain/type. The untyped arm
retains these declaration and scope boundaries. Erasing slot colors therefore
does not suddenly allow all variables in the predicate to exchange.

The heterogeneous-alpha witness alternates single-variable `all` and `some`
declarations. It has no nontrivial declaration permutation groups in either
arm. The same-type-permutation witness has two groups of four, each already
homogeneous. Both arms have a candidate envelope of `4! * 4! = 576` per
canonicalization pass, not `8! = 40,320`. The latter is the configured cap,
not this witness's search size. This corrects the earlier conversational claim.

These envelopes were reconstructed from the actual adapted terms using the
current declaration grouping policy. They are not counters of total visited
candidates across all passes, and they do not measure e-class symmetry closure.

## Bounded Warm Probe

Evidence on this workstation:
`/media/augustus/8618-0ED0/ACGN/intermediate/typed-cost-probe-20261106/`.
The diagnostic reuses the previous smoke's frozen classes, libraries, and
inputs. It changes no production code. Each case runs in a fresh JVM with a
1 GiB heap and one logical processor, within a 3 GiB no-swap systemd scope.
Each case has ten warm-up rounds and thirty measured rounds, alternating arm
order. Every comparison constructs a new graph. Parsing is outside these
timers. Results use current-thread CPU time and allocated bytes, not total RSS
or retained heap; this is a diagnostic microbenchmark, not a JMH study.

| Input | Variable occurrences across pair | Distinct parser type identities | Untyped / typed declaration envelope |
| --- | ---: | ---: | ---: |
| Social-media regression | 9 | 2 | 1 / 1 |
| Heterogeneous alpha | 66 | 2 | 1 / 1 |
| Same-type permutation | 66 | 2 | 576 / 576 |

| Input | Untyped / typed median adapter CPU ms | Untyped / typed median comparison CPU ms | Untyped / typed median adapter allocated bytes |
| --- | ---: | ---: | ---: |
| Social-media regression | 0.009 / 0.105 | 0.244 / 0.267 | 13,272 / 62,856 |
| Heterogeneous alpha | 0.030 / 0.350 | 1.007 / 1.045 | 88,880 / 471,680 |
| Same-type permutation | 0.024 / 0.138 | 52.253 / 51.027 | 57,184 / 439,984 |

`ExactAlloyType.from` traverses product alternatives and signature ancestry;
its constructor copies, validates, sorts, and serializes the exact shape. The
adapter repeats this for every variable occurrence, including repeated uses
with the same parser `Type` object. This is avoidable per-conversion allocation
and CPU work, not just cold class initialization.

The permutation comparison allocates about 272 MB cumulatively per comparison
in either arm in this probe. This is not peak memory: repeated term renaming,
sorting, and graph work allocate many short-lived objects. Nearly identical
search spaces explain why typing does not remove this cost here. A roughly
2% typed advantage in this warm comparison is not enough evidence of speedup;
the results do not support a universal claim that typed is slower either.

## Repair Boundaries

Suitable implementation work is to cache exact type conversion within one
adaptation context, and to generate/index admissible mappings by type before
expensive candidate construction wherever type partitioning actually narrows
the admissible space. A local identity cache must not become a cross-module or
name-based authority cache.

A meaningful search redesign also needs explicit admissible exchange-block
semantics and matching counters. It must preserve scope, dependencies,
quantifier order, and disjointness, with the same structural policy in both
arms apart from the type treatment. In particular, widening the untyped arm to
arbitrary global permutations just to manufacture a speedup would invalidate
the comparison; combining alternating `all`/`some` blocks would be unsound.

No such redesign or optimization is claimed as implemented by this diagnostic.
The next performance claim should include candidate/partition counters and
repeated paired measurements, not infer pruning from a total slot histogram.
