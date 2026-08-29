# Publication Snapshot `df4d8d4c-6265-4fe7-88d5-3aceee60398b`

This directory records the manifest and command plan for the publication run
imported into the repository result directories on 2026-08-29.

- Source commit: `fbd9b1497a9036c55780da777f56581bc1c6bcec`
- Dataset: 66,080 Alloy files, SHA-256
  `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Eligible pairs: 61,598 after 4,482 raw-AST-identical pairs were excluded
- Workers: 16
- Heap: `8g`
- Reward pool: 100
- Status: complete

The four manifest-bound stage trees are mirrored exactly at:

- `distance_results/`
- `alloy4fun-augmented/`
- `egraph_ablation/`
- `capability_benchmark/`

The run completed every stage with no evaluation, parsing, ranking, reward, or
ablation-arm failures. All seven natural-corpus arms processed the 61,598
eligible pairs. The bounded semantic checker found no counterexample among the
4,088 claimed-equivalent pair union, and the four targeted negative controls
remained unmerged. The capability benchmark closed all 5,500 generated pairs
in the slotted, Fast Rewrite IR, and Certificate-Integrated IR arms.

This run is the first full-corpus snapshot after repairing Fast Rewrite field
ownership and cross-temporal alpha alignment. Fast Rewrite has zero
incorrect-to-any-truth zeroes, while the Certificate-Integrated path adds 14
`CORRECT` paired-oracle zeroes and loses none of the 4,074 Fast Rewrite zeroes.

The manifest records the originating absolute run root
`/home/augustus/acgn-codex-supervised-20260829T205326Z/run`. Portable snapshot
identity comes from relative artifact paths, sizes, and SHA-256 hashes, not
from that host path.

Materialize the two Git LFS payloads and verify the imported stage artifacts
from the repository root:

```bash
git lfs install
git lfs pull
./scripts/verify_imported_publication_snapshot.sh
```

The originating experiment JAR is identified in the manifest and retained
byte-for-byte at `release-assets/acgn-experiments.jar`:

- size: 2,292,989 bytes
- SHA-256: `361b33ef56f6ccb1089a7a6fdda2a92bf621e501166c5a1c73330a0cc1686807`

The sibling `SHA256SUMS` file is the checksum input for the release asset. The
JAR is not rebuilt from the later result-import commit.
