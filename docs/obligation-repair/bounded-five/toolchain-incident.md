# Isolated Lean Toolchain Selection

## Witness

The first v2.12 candidate failed in GitHub Actions run `34154581866`, at
`build1-BF-P2-02-lean`. The repository-root version check succeeded, Java
compilation and all three source extractors succeeded, and the first
standalone Lean invocation exited immediately. The failed Actions log is
retained under `evidence/superseded-unpinned-cwd/`.

The runner copied `lean-toolchain` into `build1/source`, but invoked proofs
from the sibling `build1/formal` directory. That directory had no ancestor
toolchain pin. CI installs elan with no default toolchain; the local machine
has a default. Repeating `lean --version` in the earlier local proof directory
selected Lean 4.33.1, whereas the repository-root check selected 4.33.0.
Consequently, the earlier report did not establish the promised toolchain
identity for its proof invocations. Its bytes are preserved as superseded
evidence, not reused as pinned closure evidence.

## Repair

The driver validates that the repository pin matches the frozen configuration,
sets `ELAN_TOOLCHAIN` explicitly for every child process, copies the exact pin
into each formal output directory, and checks the version again from each
isolated proof working directory. An inherited `stable` or different version
cannot override the selected pin. Negative source/proof checks retain their
existing exit-code requirements. Unexpected command failures now include the
tail of their log in CI output.

The new environment regression checks absent, stable, and differing inherited
toolchains, rejects mismatched repository pins, and confirms that the caller's
environment is not mutated. The final two-build replay checks actual Lean
invocations, rather than relying on that environment unit test alone.

## Scope

No production Java, rewrite rule, certificate authority, experimental result,
or parent claim text changed. This repair affects proof-runner reproducibility.
The authoritative replacement report is `evidence/report.json`; the previous
`bounded-five-v1-5c9400cca03d749b` report remains under
`evidence/superseded-unpinned-cwd/`. A new input root is required because the
runner and its registered tests changed. No tag or release was published from
either failed or cancelled candidate.
