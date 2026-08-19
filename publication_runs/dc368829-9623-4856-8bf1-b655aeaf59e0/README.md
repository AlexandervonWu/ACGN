# Publication Snapshot `dc368829-9623-4856-8bf1-b655aeaf59e0`

This directory records the manifest and command plan for the publication run
imported into the repository result directories on 2026-08-19.

- Source commit: `f1bb1607911a4e5a7a0b8527be65148f66cf72d8`
- Dataset: 66,080 Alloy files, SHA-256
  `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Workers: 32
- Heap: `4g`
- Reward pool: disabled
- Status: complete

The four manifest-bound stage trees are mirrored exactly at:

- `distance_results/`
- `alloy4fun-augmented/`
- `egraph_ablation/`
- `capability_benchmark/`

`run-manifest.json`, `planned-commands.txt`, and `original-summary.md` are exact
copies from `/home/augustus/acgn-publication-run`. The manifest retains the
absolute paths of the originating run; its content hashes remain the authority
for the imported files.

To verify the imported stage artifacts from the repository root:

```bash
jq -r --arg root "$PWD" '
  .artifacts[]
  | select(.path | test("^(distance_results|alloy4fun-augmented|egraph_ablation|capability_benchmark)/"))
  | "\(.sha256)  \($root)/\(.path)"
' publication_runs/dc368829-9623-4856-8bf1-b655aeaf59e0/run-manifest.json \
  > /tmp/acgn-imported-publication.sha256
sha256sum --quiet -c /tmp/acgn-imported-publication.sha256
```

The originating experiment JAR is identified in the manifest by SHA-256
`2167064013b2c97de00dd08db9806daf06de2d0bbefe206939ffff38a1af101f`;
the binary itself is not duplicated in this data snapshot.
