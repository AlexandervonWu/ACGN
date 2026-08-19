# ACGN Independent Certificate Verifier

This module independently checks `.acgncert` bundles emitted by the exact
typed-slotted-port implementation. It is deliberately separate from the
producer source tree and compiles with JDK 17 and `java.base` only.

The verifier never loads producer objects, calls `verifyLocal()`, invokes the
canonicalizer, or computes repair distance. It decodes a closed wire
language, synthesizes typed equality judgments bottom-up, replays graph
transitions, exhaustively reconstructs finite canonical orbits, and checks
explicit finite `Rep` trees.

The checker and its closed schema implement all profiles below. The producer
bridge is intentionally narrower. In addition to the original nullary case,
it exports a rigid nonempty typed context, `ONE_SLOT` and recursively nested
`ONE_TERM`, and one exact retained parent edge through a height-two unfolding.
The parent-path slice has exactly two fresh leaves, one direct ground union,
one quiescent rebuild completion, and one fresh wrapper insertion. This is a
verified finite vertical slice, not a general producer-to-verifier pipeline.

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

The supported contexts contain at most one free slot of each type, so the
complete type-preserving free-renaming orbit is rigid identity. Inclusion,
sigma, omega, and shape witnesses are identity, with no support contraction
or nontrivial symmetry. A parent edge must be a direct, correctly oriented
ground input equation or rewrite; its axiom is registered by stable origin,
then independently replayed through `PARENT_EDGE`, `CONGRUENCE`, and `TRANS`.

The writer still refuses insertion collisions, symmetry/restriction/rebuild
record/path-compression events, nonidentity alpha maps, repeated same-type
free slots, support contraction, Seq/Bag/Set/Bind/BindBlock ports, indirect
parent derivations, cyclic or multiple root unfoldings, and any retained
history outside the exact one-event or five-event slices. The representative
source census currently verifies its nullary predicate and classifies its
slot-bearing and compound predicates as `UNCHECKABLE` because flexible
container-law export is outside this bridge. These remain
`UNCHECKABLE`; they are not silently omitted or approximated. The harness
requires the exact stable-code census `nullary=VERIFIED/NONE`,
`slotBearing=UNCHECKABLE/EXPORT_UNSUPPORTED`,
`deliberatelyUnsupported=UNCHECKABLE/EXPORT_UNSUPPORTED`, and zero rejected
cases. Parsed nonempty typed contexts and parent histories remain outside the
production source bridge even though deterministic bundle-level fixtures cover
those verifier slices.

See [FORMAT.md](FORMAT.md), [TRUST.md](TRUST.md), and
[FAILURE_CODES.md](FAILURE_CODES.md).
