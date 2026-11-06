# Dependency refresh: 2026-11-06

## Scope and versions

This refresh updates the active source/build dependencies to the stable releases
checked on this date. It does not regenerate the published experimental data,
archived JARs, publication manifests, closure evidence, or training results.
Their recorded versions and hashes continue to describe their historical runs.

- Lean: 4.35.0, in both `lean-toolchain` files and active verifier configurations.
  Elan's existing 4.2.4 bootstrap pin is already current and remains unchanged.
- Alloy: 6.2.0, the latest stable AlloyTools distribution. Its internally bundled
  SAT/Kodkod components remain the matched distribution versions.
- Standalone Java libraries: Commons CLI 1.11.0, JSON-java 20260814,
  SLF4J API and simple provider 2.0.20.
- Frontend: React 19.3.1, React Query 5.106.1, React Flow 12.12.1,
  Monaco 0.57.0 with its React wrapper 4.7.0, Lucide 1.70.0, Zod 4.6.7,
  Zustand 5.1.0; TypeScript 7.0.2, Vite 8.3.6, Vitest 5.1.0,
  React Vite plugin 6.2.1 and jsdom 31.0.0. Exact testing/type package versions
  and all resolved transitives are in `frontend/package-lock.json`.
- DOMPurify: override 3.4.17, replacing Monaco's vulnerable 3.4.15 pin.
  The resulting npm audit reports zero vulnerabilities.
- Node: 26.13.0 LTS, recorded in `frontend/.node-version` and used by frontend CI.
  The frontend minimum is 22.12, not the formerly documented Node 18.
- Optional GPU stack: Python 3.12+, PyTorch 2.15.0, NumPy 2.5.4,
  Triton 3.9.0, and PyTorch's compatible CUDA 13.2 components. All resolved
  packages are pinned in `rl/requirements-cuda.txt`. CUDA transitives are selected
  by torch's ABI constraints, not independently advanced to incompatible releases.

The Java 17 compilation target remains part of the artifact contract. This is
not a claim that Java 17 is the newest JDK. Local ASG/parser components have no
new selected upstream release; the adapter compatibility changes are described
below. Optional plotting dependencies not previously locked are not newly locked
by this refresh.

Release references: [Lean 4.35.0](https://github.com/leanprover/lean4/releases/tag/v4.35.0),
[Alloy 6.2.0](https://github.com/AlloyTools/org.alloytools.alloy/releases/tag/v6.2.0),
[Node release inventory](https://nodejs.org/dist/index.json),
[PyTorch 2.15.0](https://pypi.org/project/torch/2.15.0/).
Maven artifact URLs and upstream/installed SHA-256 values are recorded in
`lib/dependencies.json`; npm records resolved URLs and integrity digests in its lockfile.

## Compatibility changes

1. The old `AlloyASG-Release.jar` contained an embedded Alloy 6.1 distribution,
   parser and third-party libraries. It is now a thin ASG archive. Independently
   pinned CLI, JSON and SLF4J classes are also removed from the Alloy fat JAR.
   This prevents classpath order from silently selecting an obsolete runtime.
2. Two source overlays in `src/parser/` adapt `getModuleName()`, the new `Assert`
   representation and the SATFactory solver API. All production runners compile
   these sources and put compiled classes before the dependency JARs. Local
   parser/ASG provenance and reproduction instructions are in `lib/README.md`.
3. Java solver selection uses `SATFactory` instead of the removed
   `A4Options.SatSolver`. Command and primitive-signature constructors carry the
   additional Alloy 6.2 metadata arguments. Unknown solver identifiers still
   fail closed; no equivalence rules or certificate authorities were relaxed.
4. React refs, Zod records and Monaco package exports use the new APIs. The
   deployed frontend remains static and does not require a server-side Node runtime.
5. Lean verifier version guards and the three exact engine-hash bindings now
   refer to the updated runner. Hash checking itself is unchanged. Historical
   closure reports have not been relabeled as new evidence. Whole-artifact
   two-build closure must be rerun before claiming a new closure snapshot.

## Local runtime setup

The new GPU environment is `/home/augustus/.venvs/acgn-rl-cu132-py312`.
The old Python 3.10/CUDA environment was preserved. Active learning scripts
default to the new environment; their environment-variable overrides still work.

Node 26.13.0 was installed under
`/home/augustus/.local/opt/node-v26.13.0-linux-x64`, with `node`, `npm`, and `npx`
links in `~/.local/bin`. The system installation was not removed. Other machines
should select the pinned version before running `npm ci`.

```sh
elan toolchain install leanprover/lean4:v4.35.0
python3 scripts/refresh_java_dependencies.py
bash scripts/setup_rl_cuda.sh
cd frontend
npm ci
npm test -- --run
npm run build
```

The refresh script requires network access. Normal Java builds use the checked-in
JARs and do not require Maven. The CUDA setup requires Python 3.12+ and either
pip in the target environment or a host pip supporting `--python` for bootstrapping.

## Validation

Executed against the upgraded dependencies:

- Full Java source compilation with `--release 17 -encoding UTF-8`.
- `scripts/run_bounded_ci_java_tests.sh`: passed, including all 51 logged Java
  check invocations, assertion-enabled regressions, and distance-artifact
  regeneration smoke checks. Log: `/tmp/acgn-deps-bounded-java-final.log`.
- `DependencyCompatibilityTest`: 13 checks, including unique class resources,
  module/assertion/predicate/function adapters and temporal SAT/check results.
- `CanonicalAlloyPipelineTest`: 2,041 checks.
- `FastRewriteParityTest`: 199 checks; the 14 checked certified digests unchanged.
- `SemanticProfileSourceCommandTest`: 44 checks.
- `SlotTypingAblationTest`: 28 checks; `EGraphAblationTest`: passed.
- Synthetic stress corpus: 250 models / 500 target predicates parsed through
  stock Alloy 6.2 and the upgraded repository adapter, zero failures. All 23
  reduced solver probes retained their expected outcomes (19 UNSAT equivalence
  checks, four SAT counterexamples); two second-order probes remain explicitly
  solver-unchecked. This is input validation, not a new timed typed/untyped
  benchmark or an unbounded semantic proof. Reports: `/tmp/acgn-deps-stress-full`.
- Cataloged rewrite Lean check: five source files compiled and assumption-audited.
- Paper formalization: `lake build`, 22 jobs passed under Lean 4.35.0.
- Slot typing model and stress schemas: Lean compilation passed.
- Five obligation-runner unit suites: 106 tests passed, in separate processes.
  Verifier suites intentionally inspect imported modules; combining them in one
  unittest discovery process contaminates the synthetic frozen-repository tests.
- Reporting, replay, flat-container replay, Java-Lean refinement and submission
  closure unit suites: another 58 tests passed in separate processes.
- RL: 65 tests passed with the compiled Java worker classpath; `pip check` clean.
  A CUDA tensor forward/backward smoke check passed on the RTX 5080 with
  torch `2.15.0+cu132`. No model training was launched.
- Frontend: 50 tests across 12 files, production build passed, npm audit clean.

Initial compatibility failures were resolved: Alloy's changed binary API,
React/Zod/Monaco API changes, and stale exact runner-hash bindings after the Lean
pin update. Alloy 6.2's assertion-enabled subtype constructor also requires a
non-null parent-position marker when a parent is supplied; synthetic signature
fixtures now use `Pos.UNKNOWN`, without granting parser provenance.
An initial RL test invocation omitted `ACGN_RL_CLASSES`; the corrected
invocation passed all 65 tests. These are not suppressed test failures.

Full-corpus performance and semantic experiments were not rerun. No numerical
equivalence with historical experiments is inferred from these bounded checks.
