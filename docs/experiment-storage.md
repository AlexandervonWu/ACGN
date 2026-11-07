# Experiment Storage

Experiment runners retain their normal output directories on other machines.
No removable drive or machine-specific path is required by the repository.

The large generated `distance_results/distances.json` and
`alloy4fun-augmented/index.json` are no longer tracked. Reruns still generate
them in their selected output directories; published summaries, figures, and
manifests remain tracked. Historical versions remain available through Git LFS
at the corresponding historical commits. Existing checksum manifests are not
rewritten by this storage change and require their original bulk files.

For local storage overrides, the serial runner accepts `DISTANCE_OUTPUT`,
`AUGMENTED_OUTPUT`, `ABLATION_OUTPUT`, `CAPABILITY_OUTPUT`, and `SERIAL_SUMMARY`.
Its compilation directory respects `TMPDIR` (default `/tmp`). Java temporary
storage can be configured separately with `-Djava.io.tmpdir`. The publication
and synthetic runners continue to accept explicit output paths.

On the current workstation only, verified archives and bulk results were moved
to its attached drive. The machine-local helper and migration instructions live
under `.git/local-tools/`, outside version control. This configuration is opt-in
and neither changes portable defaults nor starts any experiment.
