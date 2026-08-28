# Publication Snapshot `57f5a2d8-f501-494d-81d5-b3f1396dbe18`

This directory records the manifest and command plan for the publication run
imported into the repository result directories on 2026-08-28.

- Source commit: `88363ea23728329948ccc9d5cdad690cc5787ca5`
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

The manifest records the originating absolute run root
`/home/augustus/acgn-publication-v2.1-20260828T064537Z`. Portable snapshot
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

- size: 2,285,442 bytes
- SHA-256: `7b308e3156fbb36dfeda4af52f8ec339132546a0fcabb24129227f41debbad71`

The sibling `SHA256SUMS` file is the checksum input for the release asset. The
JAR is not rebuilt from the later packaging commit.
