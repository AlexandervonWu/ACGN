# ACGN Independent Certificate Verifier

This module independently checks `.acgncert` bundles emitted by the exact
typed-slotted-port implementation. It is deliberately separate from the
producer source tree and compiles with JDK 17 and `java.base` only.

The verifier never loads producer objects, calls `verifyLocal()`, invokes the
canonicalizer, or computes repair distance. It decodes a closed wire
language, synthesizes typed equality judgments bottom-up, replays graph
transitions, exhaustively reconstructs finite canonical orbits, and checks
explicit finite `Rep` trees.

The checker and its closed schema implement all profiles below. The current
producer bridge is intentionally narrower: it can export one nullary source
node, one fresh insertion at empty effective support, and one complete
height-one unfolding. Any richer retained trace is refused as
`UNCHECKABLE` before an output file is opened. This module is therefore a
verified vertical slice, not yet a complete producer-to-verifier pipeline.

## Build And Test

From the repository root:

```bash
scripts/build_certificate_verifier.sh
scripts/run_certificate_verifier_tests.sh
scripts/run_certificate_verifier_smoke.sh 100 /tmp/acgn-cert-smoke
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

Inspect a bundle's untrusted manifest digest before selecting an out-of-band
pin:

```bash
java -cp certificate-verifier/build/acgn-certificate-verifier.jar \
  org.acgn.cert.ManifestInspector artifact.acgncert
```

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

The test script compiles with `--release 17 -Xlint:all -Werror`, rejects
imports from producer packages, and checks `jdeps -summary` for the sole
dependency `java.base`. The smoke exports every preparation twice, checks
byte identity, verifies every bundle under `full`, and exercises `pair`.

## Producer Export Status

`CanonicalAlloyPipeline.prepareForVerification(...)` enables the optional
recording path. Ordinary preparation uses `NoOpCertificateTraceSink`, so
existing experiments retain no trace. Export must occur before
`compactForComparison()`.

The writer currently refuses traces containing typed ports, nonempty free
contexts, support contraction, nonidentity alpha action, collisions, unions,
symmetries, restrictions, rebuild, path compression, container-law records,
multiple transitions, or recursive/multiple unfoldings. The verifier has
independent replay algorithms and direct fixtures for those records; the
remaining work is exact producer serialization of their retained evidence.

See [FORMAT.md](FORMAT.md), [TRUST.md](TRUST.md), and
[FAILURE_CODES.md](FAILURE_CODES.md).
