# Publication Snapshot `6000d695-8b5e-4972-b0ea-3d9e55111245`

This directory records the manifest and command plan for the publication run
imported into the repository result directories on 2026-08-27.

- Source commit: `ebce874382c87108a32874149008842a7b0fa528`
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
ablation-arm failures. The certificate-integrated metric produced zero
incorrect-to-truth zero-distance rankings. The Fast Rewrite IR retained ten
such zeroes as explicitly non-certifying diagnostics; their witnesses are in
`alloy4fun-augmented/incorrect_nearest_zero_distances.csv`.

The manifest records the originating absolute run root
`/home/augustus/acgn-publication-20260827T194941Z`. Portable snapshot identity
comes from relative artifact paths, sizes, and SHA-256 hashes, not from that
host path.

Materialize the two Git LFS payloads and verify the imported stage artifacts
from the repository root:

```bash
git lfs install
git lfs pull
./scripts/verify_imported_publication_snapshot.sh
```

The originating experiment JAR is identified in the manifest and retained
byte-for-byte at `release-assets/acgn-experiments.jar`:

- size: 2,258,622 bytes
- SHA-256: `21b721e31b5270c1b5e63bca368eccee9323886fd5c571e6190c296a853abc52`

The sibling `SHA256SUMS` file is the checksum input for the release asset. The
JAR is not rebuilt from the later packaging commit.
