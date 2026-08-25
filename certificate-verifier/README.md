# ACGN Independent Certificate Verifier

This module independently checks `.acgncert` bundles emitted by the exact
typed-slotted-port implementation. It is deliberately separate from the
producer source tree and compiles with JDK 17 and `java.base` only.

The verifier never loads producer objects, calls `verifyLocal()`, invokes the
canonicalizer, or computes repair distance. It decodes a closed wire
language, synthesizes typed equality judgments bottom-up, replays graph
transitions, exhaustively reconstructs finite canonical orbits, and checks
explicit finite `Rep` trees.

Schema v10 retains the closed `WITNESS_UNFOLD` kernel rule. Given only a witness
and a typed embedding, the verifier reconstructs the invocation and the acted
witness definition internally; the rule has no premises and admits no theory
axiom.

Wire schema `acgncert-schema-v10` also has a dedicated dependent ordered-Seq
construction for plain Alloy JOIN and ARROW. The verifier reconstructs the
binary source association, independently checks every positional leaf's stored
type and correlated relation-family DAG, structurally checks every supplied
direct-parent path, independently normalizes each subtype antichain, replays
the complete row-major alternative-pair matrix, derives every intermediate and
result product, and then checks the ordered variadic target.
This path is deliberately separate
from homogeneous flat-container evidence and grants no commutativity,
idempotency, permutation, or unit authority.
ARROW takes the correlated Cartesian product and never widens independent
columns. JOIN boundaries require exact identity, an explicit exact-signature
subtype correspondence, or explicit divergent-branch disjointness reconstructed
from two acyclic, single-parent paths to their first common ancestor. An
explicit `univ` endpoint is a real relation column and may participate by exact
identity or a concrete-to-`univ` subtype path; two divergent concrete branches
that merely share `univ` remain disjoint. JOIN
reassociation with more than two source operands is licensed only when each
alternative of each interior operand has at least two relation columns; a unary interior keeps the
source fixed binary because JOIN is not associative in that case. Subtype
evidence never replaces an endpoint with an invented `univ`, and synthetic union/common-
ancestor nodes never enter the nominal parent ledger. Because the standalone verifier does not
reparse the Alloy source and has no independently pinned signature-hierarchy
authority, a structurally valid nonexact subtype or disjoint-branch proof ends as
`UNCHECKABLE / MISSING_EVIDENCE`; it never yields `VERIFIED`. Malformed,
conflicting, cyclic, reversed, truncated, incomplete-matrix, or unrelated evidence is
`REJECTED`. Exact-boundary chains do not need that external authority.

Schema v10 retains the structural proof and binds it to one deterministic
source path and one canonical source-content commitment; malformed or absent
commitments are rejected rather than inferred from the typed target. Schema v9
bytes are rejected as historical because v9 did not carry correlated DAGs and
complete pair matrices.

Schema v10 also retains the enclosing typed root as part of every
binder-occurrence certificate identity and verifies the occurrence path from
that root. Historical schemas are rejected as unsupported rather than silently
reinterpreted. A provenance-only CALL ledger additionally binds parser
occurrence IDs and deterministic source paths to qualified callees, call kinds,
declared-arity authorities, contiguous roles, ordered argument endpoints, and
the complete typed CALL endpoint without changing semantic operator equality.

The checker and its closed schema implement all profiles below. The producer
bridge is intentionally narrower. It exports either a nonempty bottom-up
fresh-insertion history or one exact six-event parent-path history, including
an explicit no-op rebuild-start boundary before completion. It
requires a bounded typed free-renaming orbit and checked graph/support embeddings, a
final quiescent snapshot, and exactly one complete root unfolding. Supported
terms may recursively contain `ONE_SLOT`, `ONE_TERM`, homogeneous
`Seq`/`Bag`/`Set`, `Bind`, `BindBlock`, and certified dependent JOIN/ARROW
chains. Concrete construction and binder-occurrence evidence is mandatory.
Insertion collisions, graph e-class symmetries, interface restriction,
nonempty rebuild records, path compression, unsupported support contraction,
indirect parent derivations, cycles, and multiple root
unfoldings remain outside this bounded bridge. This is a verified finite
vertical slice, not a general producer-to-verifier pipeline.

## Build And Test

From the repository root:

```bash
scripts/build_certificate_verifier.sh
scripts/run_certificate_verifier_tests.sh
scripts/run_certificate_bundle_writer_tests.sh
scripts/run_certificate_verifier_smoke.sh /tmp/acgn-cert-smoke
```

The jar is written to
`certificate-verifier/build/acgn-certificate-verifier.jar`.

```bash
java -jar certificate-verifier/build/acgn-certificate-verifier.jar \
  --profile full \
  --theory-digest <pinned-sha256> \
  artifact.acgncert
```

Pair mode takes two independently exported bundles:

```bash
java -jar certificate-verifier/build/acgn-certificate-verifier.jar \
  --profile pair \
  --theory-digest <pinned-sha256> \
  left.acgncert right.acgncert
```

Exit codes are `0` for `VERIFIED`, `2` for `REJECTED`, `3` for
`UNCHECKABLE`, and `64` for command-line misuse.

Inspect a bundle's untrusted theory digest before selecting an out-of-band
pin:

```bash
java -cp certificate-verifier/build/acgn-certificate-verifier.jar \
  org.acgn.cert.ManifestInspector artifact.acgncert
```

The bounded producer harness does not use that output as authority. It selects
named digests from [`trusted/theory-pins.tsv`](trusted/theory-pins.tsv), checks
that generated bundles match the prior selection, and exercises a wrong-pin
`REJECTED / UNTRUSTED_THEORY` case. The complete test-only theory ledger is in
[`trusted/THEORY_REVIEW.md`](trusted/THEORY_REVIEW.md); its entries remain
author-approved only under their declared `TEST_ONLY` and
`TEST_ONLY_INPUT_SPECIFIC` fixture scopes.

## Profiles

| Profile | Independently checks |
| --- | --- |
| `kernel` | canonical bytes, manifest pin, typed language, proof DAG and trusted leaves |
| `checkpoint` | kernel plus snapshots, events, EC/PC/SC and quiescent publication |
| `canonical` | kernel plus complete free/leader/binder orbit and global minimum |
| `unfold` | kernel/checkpoint plus explicit finite `Rep` trees |
| `full` | all single-bundle profiles |
| `pair` | two full bundles and a composite equality through one checked kernel |

Resource exhaustion and absent evidence are `UNCHECKABLE`; neither can
produce `VERIFIED`.

The test scripts compile explicitly as UTF-8 with `--release 17`; the
standalone module additionally uses `-Xlint:all -Werror`, rejects
imports from producer packages, and checks `jdeps -summary` for the sole
dependency `java.base`. The producer harness starts from an empty temporary
build, launches the writer twice in separate JVMs and directories, compares
every expected byte and SHA-256 digest, rejects unexpected files, verifies
the supported bundles under `full`, and exercises both a manually constructed
bundle-level PAIR and a real two-file parser -> MASG -> adapter -> writer PAIR.
The latter asserts distinct source identities and content hashes before the
standalone verifier accepts the pair under the static empty-theory pin.
The producer test output subdirectory named `schema-v8-coverage` is retained
only as a stable historical harness path; newly generated bundles in that
directory use schema v10 and v9 payload roots are rejected.

## Producer Export Status

`CanonicalAlloyPipeline.prepareForVerification(...)` enables the optional
recording path. Ordinary preparation uses `NoOpCertificateTraceSink`, so
existing experiments retain no trace. Export must occur before
`compactForComparison()`.

The writer uses `phase-j-producer-export-v3` with the pinned rule set
`phase-j-proof-kernel-v3`. It builds and validates the entire bundle in
memory, writes a sibling temporary file, and atomically replaces the target
only after successful encoding. Unsupported state throws
`IOException("UNCHECKABLE: ...")`; a pre-existing target remains unchanged.

The supported contexts have a complete type-preserving free-renaming orbit
within the configured finite bound. Nonidentity free renaming is supported
only for the explicit slot-only slice; other graph/support maps must satisfy
the writer's checked identity/support restrictions. Nontrivial graph e-class
symmetry remains unsupported. A parent edge must be a direct, correctly oriented
ground input equation or rewrite; its axiom is registered by stable origin,
then independently replayed through `PARENT_EDGE`, `CONGRUENCE`, and `TRANS`.

The writer recursively encodes `Seq`, `Bag`, `Set`, `Bind`, and `BindBlock`
ports, including dependent positional `Seq` schemas, when the surrounding
slice satisfies all other export restrictions. It still refuses insertion
collisions, symmetry/restriction/nontrivial-rebuild record events,
unsupported support contraction, indirect parent derivations, cyclic or
multiple root unfoldings, and retained history outside the bottom-up
fresh-insertion or exact six-event parent-path slices. Repeated same-type free
slots are accepted only in the bounded
slot-only orbit slice and are serialized with the complete finite renaming
candidate set. The representative source census currently verifies its nullary
predicate and classifies its slot-bearing and compound predicates as
`UNCHECKABLE` because their shape witnesses retain redundant coordinates,
which this bridge does not serialize. These remain
`UNCHECKABLE`; they are not silently omitted or approximated. The harness
requires the exact stable-code census `nullary=VERIFIED/NONE`,
`slotBearing=UNCHECKABLE/EXPORT_UNSUPPORTED`,
`deliberatelyUnsupported=UNCHECKABLE/EXPORT_UNSUPPORTED`, and zero rejected
cases. Parsed nonempty typed contexts and parent histories remain outside the
production source bridge even though deterministic bundle-level fixtures cover
those verifier slices.

See [FORMAT.md](FORMAT.md), [TRUST.md](TRUST.md), and
[FAILURE_CODES.md](FAILURE_CODES.md).
