# P4-04 parent installation

The original Phase 4 row reads “A parent is installed only with a typed embedding and exact directed parent-certificate endpoint.” The English SHA-256 is `ab47c5a21bf9acba434c49c0796b183d63d1a40b8d08fb61c120d67e948d4624`.

## What the producer installs

The quantified graph is a certificate-enforcing `TypedSlottedPortEGraph`. All three public constructors select `REQUIRED`. Package `TEST_ONLY` also enforces parent certificates. `STRUCTURAL_FIXTURE` is a separate, package-only algebra harness that explicitly permits uncertified primitive steps and refuses to replay them as certificates. A universal statement over that harness as well as the certified graph would be false.

A child-to-parent proof has source the child's witness and target the invocation of the parent under the entire parent-to-child slot embedding. Slot types, declared source and codomain, the injective map, class metadata and output type all matter. A genuine reverse premise is admitted by applying symmetry to it. An unrelated endpoint cannot be oriented. A root's identity assignment admits a reflexive proof without any nonroot input equation.

The JDK 17 census uses compiler resolution of the private final union-find field and of its private final assignment map. It attributes 106 methods, all 36 graph-owned union-find receiver expressions, nine direct assignment-map uses, six storage expressions (including the local replacements map), and nine graph calls to assignment-changing union-find operations. The source binding is `b36c208fc0d2849b91835ccf4b745e13e27e8056af0a81dc7f182bfb45b8af6a`. Additional order checks bind derivation verification, the two orientation arms, path direction, lexical construction of the certified step and restriction factorization. The census includes the recursive endpoint structural keys, exact key comparison, identity normalization, proof transport and constructor visibility.

| Storage operation | Source of the installed proof |
| --- | --- |
| Registration | The registered interface is both child and parent and supplies its identity map. |
| Direct union | The graph checks the candidate, obtains `ParentStep.certified(checked)`, and links the two current leaders. Collision insertion and collision resolution use this same certified internal union. The raw fixture caller and all public constructors are checked independently. |
| Compression | The existing primitive path is concatenated with the tail. Each later primitive certificate is transported through the prefix before transitivity. The embedding is composed in the opposite traversal direction, from final parent slots back into the child's context. |
| Restriction root | The existing leader id obtains the identity map on its new proper subcontext. |
| Restriction descendant | Every affected non-root child uses its actual old path together with the independently supplied restriction factorization, renamed into the child's context. This yields a directed proof with the new interface and the composition of the inclusion with the old embedding. |
| Restriction commit | The prepared replacement map is applied in bulk. Both stores preserve the same directed proof invariant during preparation and installation. |

## Mechanical correspondence

`P404InstalledParent.lean` imports `Std`. The main theorem is `ACGN.Eleventh.P404.decoded_installation_exact`. It quantifies over a successfully decoded compiler program, every finite execution of its modeled writes, both certificate-enforcing modes and every installed entry. It derives the original key, typed injective map, equal output sort and exact directed certificate. `orient_exact` chooses orientation from checks against the input proof's original endpoints. `path_exact` constructs the full certificate by induction over retained primitives. `historical_find_exact` composes a historical normalization proof with the path transported to the caller's context. `execution_preserves_both_stores` discharges staged and committed writes. The 15 declarations use at most `propext`.

`P404WriteReplay.lean` decodes the actual compiler-generated storage expressions. It rejects omission, reversal, duplication and removal of the certified-step operation from a copied instruction stream. The runtime independently traverses every observed primitive path, constructs the finite composite without calling the producer's embedding composition, and checks both endpoints of the primitive certificate and its derivation. It checks the composed certificate against the installed parent and independently expected finite map. The legal four-class BOOL/INT branching example exposes a proper injection, opposite input orientation, two-edge compression, one-step replacements for all affected descendants, and a historical find on the leader's former two-slot interface. These empty classes are registered through the package Phase F setup, then changed via the normal public union, find, restriction and rebuild operations. The input equations hold in the stated constant-true interpretation for every assignment. A separate ordinary repeated source-node insertion constructs its own collision evidence through the public entry point. The strict and TEST_ONLY graph fixtures both reject raw linking before a state change. The structural-only comparison reports its missing certificate explicitly.

The five existing unit methods cover certificate algebra, certified union and find replay, 64 deterministic certified chain cases, the independent restriction obligation, and direction/compression. Their original expectations remain in force.

## Focused reproduction

Compile the primary and replay modules into a private Lean 4.35.0 module directory, with that directory on `LEAN_PATH`. Compile `java/P404ParentWrites.java` and `java/P404ParentAssignmentTest.java` using JDK 17 against the integrated producer and its repository libraries. Set `ACGN_ELEVENTH_LEAN` to that Lean executable and `ACGN_ELEVENTH_PROOF` to the replay source. Supply an existing fresh output directory.

```text
java -ea -Xmx480m -cp CLASSPATH is.fivefivefive.CanDis.theory.P404ParentAssignmentTest CHECKOUT FRESH_RESULTS
```

| Result | Rows | SHA-256 |
| --- | ---: | --- |
| parent-writes.tsv | 6 | `945ee3bdd662c6f438c5ea20dcab2302a511428eb560371b694fb58d56a04ade` |
| parent-observations.tsv | 18 | `1e405b99a12380c206d627f078c516706b0846973190bc71867590c43977163b` |

The proof relies on accepted primitive equality premises and the declared direction of a supplied restriction factorization. The JDK and its attributed tree API, SHA-256, the source extractor's interpretation of the registered operations, the JVM and Lean's kernel are trusted. Private map ownership and immutable value semantics are ordinary Java assumptions. The model abstracts successful field/collection operations and the mathematical composition of the verified primitive rules. It establishes the original parent-installation property on the stated production graph surface. General verification of the compiler and JVM, semantic truth of arbitrary caller input equations, and separate wire trust, graph invariants and fail-atomicity claims are outside this row.
