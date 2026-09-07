# Submission Container Replay Obligations

This package supplies an additional finite Java-to-Lean replay boundary for the
submission artifact. Its authoritative claim set is
[`closure-config.json`](closure-config.json). A successful run closes exactly
SCR-01 through SCR-08 under the declared trusted components. It does not change
the larger Section 3 assurance state or the paper's refinement status.

## Scope

The Java probe executes the existing `SeqPort`, `BagPort`, `SetPort`, and
`ContainerNormalizationTrace` code on all words of length zero through four
over three distinct complete typed `OnePort` values. It repeats the enumeration
for Boolean and `Rel(Int)` carriers: 726 traces, including 242 of each kind.
The probe decodes the actual stored outputs by Java port equality, checks that
the atom table is injective, and retains the original input word and actual
occurrence fibers. The full port, context, schema, and trace encodings remain
in the exported JSON for inspection.

The independent [Lean checker](../section3-repair-audit/formal/ContainerReplay.lean)
receives these input/output identities and fibers. It checks Seq order, Bag
permutation, Set support and duplicate-free output, and a complete partition
of the input indices. Each fiber is nonempty and contains only occurrences
equal to its output; Bag/Seq fibers are singletons and Seq fibers are positional.
General kernel-checked theorems derive order preservation, multiplicity
preservation, support preservation, and Boolean any/all denotation preservation
from acceptance. Fourteen negative controls exercise the corresponding losses,
inventions, reorders, and malformed fibers. A separate census/encoding test
rejects missing, repeated, ill-typed, and ambiguously encoded rows.

The [Boolean construction model](../section3-repair-audit/formal/Phase2VariadicLaws.lean)
now handles both AND and OR over arbitrary operand identities and
interpretations. Thirteen additional theorems cover empty constants,
singleton identity, retained carrier arity, denotation, and the absence of a
unit license. All eleven uses of `native_decide` in this file were replaced
with kernel-checked `decide` proofs without changing their statements. The
runner compiles and inventories assumptions for all 55 theorems in that file.
`BooleanSmartConstructionTest` exercises both heads in both overflow profiles.

## Boundary

This is replay of constructor normalization, not a full source-to-certificate
trace. `ContainerNormalizationTrace.of` validates its supplied normalized child
inputs; the separate certificate layer establishes how source children produced
those inputs. This package does not claim that latter bridge. Its empty words
use general `atLeast(0)` schemas, not production Alloy container authority.
Production Boolean K+ construction still rejects empty stored containers and
issues no unit certificate. Singleton operands remain the same typed objects.

The Java probe, its JSON extraction, the encoder, the Java runtime, and the
installed Lean distribution remain explicit trusted components. This package
does not prove their universal refinement. The generated Lean declarations
check each observed quotient, rather than merely naming an independently proved
theorem. No additional equality, rewrite rule, schema admission, or semantic
authority is installed into the running canonicalizer.

P2-16 remains `PARTIAL/DIRECT`: its missing OR model has been supplied, while
the broader claim that all relevant Java transitions follow this construction
model still needs refinement evidence. P2-17 gains a finite checked execution
bridge; its existing status is not promoted to a universal Java proof.

## Reproduction

From the repository root, with the pinned Lean 4.33.0 toolchain, a compatible
JDK, Python 3.10 or later, and the existing `lib/` dependencies installed:

```bash
python3 scripts/run_submission_container_closure.py /tmp/acgn-submission-container-replay
```

Use a new output directory for each run. No network or corpus experiment is
required. Each command has a 300-second timeout; Java tests use a 1 GiB heap.
The runner copies the frozen source/dependency inputs into two isolated build
directories, compiles fresh Java classes and Lean proof objects, checks all
traces and fixed negative controls, and compares the deterministic outputs.
Input changes, proof failures, unknown assumptions, missing traces, or divergent
outputs block closure. Tool availability failures are reported separately.

The output contains `closure-report.json` and its Markdown rendering, an input
manifest, command logs, per-build artifact hashes, and a compact `evidence.tar.gz`
with `archive-hash.json`. The evidence archive contains the raw probe results,
generated Lean replay source, assumption inventories, and both build manifests;
compiled classes are reproducible from the hashed sources. CI runs the same
entry point. Existing empirical result directories are not inputs or outputs.

## Located Gaps And Dispositions

| ID | Finding | Disposition |
| --- | --- | --- |
| SCR-F01 | P2-16's formal construction model handled AND but not OR, and represented singleton Boolean values rather than general operand identities. | Added an AND/OR model, 13 proofs, and 68 Java checks. The broader Java-refinement obligation remains open. |
| SCR-F02 | Eleven Phase 2 proofs relied on native evaluation despite the stronger kernel-only evidence requested for this closure. | Replaced them with `decide`; compiled and audited the whole file's theorem assumptions. |
| SCR-F03 | Existing reference connectivity alone did not replay actual constructor outputs in Lean. | Added the finite typed constructor probe, an independent checker, exact input census, fixed negative controls, and two clean builds. |
| SCR-F04 | The first development runner used `hashlib.file_digest`, unavailable on the repository's Python 3.10 environment. | Replaced it with streaming SHA-256 using the standard library; subsequent development builds completed. |

The separate [review and run record](review-and-results.md) records the bounded
independent review, final evidence location, and remaining obligations. Review
opinions do not discharge any claim; executable and kernel-checked evidence
determine this package's closure result.
