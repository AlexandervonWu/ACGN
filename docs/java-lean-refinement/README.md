# Java-Lean Smart-Construction Refinement

This package closes a precisely scoped part of **P2-16**, the correspondence
between Boolean smart construction and the Java production constructor.
It supplements the earlier [container replay](../submission-closure/README.md)
with compiler-resolved source extraction and actual certified construction
traces. The machine-readable claim boundary is [closure-config.json](closure-config.json).

## Correspondence Chain

1. A full JDK parses and resolves the actual `TypedENode.flatConstructCertified`
   method against the frozen source tree. The extractor accepts exactly its
   registered statement/effect grammar, resolves receiver and factory symbols,
   and exports the actual condition, singleton type guard, and return actions.
   Unsupported syntax or effects reject. A Java condition is not substituted
   with the desired Lean condition.
2. A generated Lean definition interprets that extracted selector with explicit
   short-circuit evaluation and cast/type rejection. Kernel-checked equality
   with the specified selector yields a theorem for **all nonempty normalized
   Boolean operand lists**, independently of the finite test bound.
3. The execution probe calls the production certified constructor, checks its
   certificate through `CertificateVerifier`, compares the full typed source
   and target endpoints, and exports actual occurrence fibers and source trees.
4. Lean checks every exported observation. General theorems then prove its
   Boolean denotation for **every valuation** and its returned target shape's
   correspondence with the extracted Java selector. These traces cover
   flattening effects on the enumerated executions, not every Java execution.

The input family is AND and OR, both FORBID and MODULAR profiles, a three-atom
typed alphabet, every flat word through four leaves, and every binary same-head
association through four leaves. That is **2,356 inputs**: 2,352 successful
certified constructions and four empty-source rejections. Empty `FlatApplication`
inputs reject before target selection; they are not stored Boolean units.

## Reproduce

From the repository root, with its pinned Lean toolchain, JDK 17, and `lib/`:

```bash
python3 scripts/run_java_lean_refinement.py /tmp/acgn-java-lean-refinement-new
```

Use a fresh output directory. The driver makes two isolated source snapshots,
compiles Java with UTF-8, compiles the proof dependencies from source, extracts
and proves the Java selector, replays the certified traces, audits theorem
assumptions, and compares deterministic class/proof/trace hashes. It neither
downloads anything nor runs the corpus, rewarder, or publication experiments.

The mandatory negative controls change the production Java singleton threshold
from one to two (extraction succeeds, Lean correspondence rejects) and insert
an unmodeled effect (extraction rejects). Boundary tests also reject incomplete
censuses, broken certificate bindings, invalid fibers, and unsupported encodings.

## Claims And Trust

The seven `JLR-*` claims have one conjunctive acceptance rule: all registered
checks, both clean builds, frozen-input checks, and deterministic artifact
comparisons must succeed. Otherwise the result is `BLOCKED`, or
`INFRASTRUCTURE_FAILURE` for unavailable tooling or execution infrastructure.
Exit codes are respectively 0, 1, and 2. Claim IDs, source hashes, verifier
hashes, command exits, raw logs, generated proof sources, and archive hashes
are retained in the output. Diagnostic text, paths, host identity and timings
may differ; generated program data, observations, classes and proof objects
must match. Reviewer opinions do not discharge claims.

The trusted boundary includes javac/JVM, Java library contracts, the checked
but not Lean-proved extractor and observation encoder, the pinned Lean kernel
and standard-library axioms, Python, hashes, and the execution platform.
Generated proof dependencies are audited; `sorry`, custom axioms,
`native_decide`, and `unsafe` do not discharge these proofs.

This does **not** close universal heap/loop refinement, the complete
`flattenVisible` or certificate factory algorithms, mixed-head sealing, the
Alloy parser, or source-level empty-expression normalization. P2-16's broader
status therefore remains separate from this closed fragment. Production
certificate authority, rewrite rules, runtime semantics and empirical results
are unchanged.

Public claims in this document map to the `JLR-*` records and their generated
evidence. A result applies only to its recorded input root and trusted boundary;
later source changes require a fresh run. See `review-and-results.md` for the
latest recorded run, without treating historical evidence as current evidence.
