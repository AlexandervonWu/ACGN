# Independent Review Evidence

These archives retain the reviewers' raw commands, input manifests, probes,
observations and logs, including blocked candidates and targeted rechecks.
Paths inside an archive refer to its original `/tmp` execution directory.
Duplicated dependency JARs, class directories and compiled Lean objects are
omitted; their recorded hashes remain in the review manifests. The package's
registered two-build evidence is separate and authoritative for closure.

- `container.tar.gz`: splice-order witness, exact reversal-control defect,
  corrected encoder recheck and the final container self-check.
- `profile.tar.gz`: initial source-version and CLI failures, rechecks and
  the final frozen profile handoff.
- `harness.tar.gz`: independent finite checks of the fourth-five driver.
- `chain.tar.gz`: missing intermediate-type witness, before/after public
  verification, fixture sequencing failures, Lean evaluation failure and the
  final exact-input recheck.

The corresponding review reports state the tested, proved and trusted
boundaries. Review opinions do not certify unlisted inputs or replace the
machine-readable closure report. `SHA256SUMS` binds the retained archives.
