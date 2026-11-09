# Startup Headroom And Runtime Reserve

Latest direct user correction, 2026-11-09: do not require 17 GiB of free RAM
throughout a running workload. This supersedes older ambiguous resource wording.
The repair loop and heartbeat remain PAUSED_BY_USER until explicitly resumed.

## Admission Versus Runtime

- The 17 GiB check is a one-time admission check for a new full-corpus workload,
  before that workload allocates its heap. It uses Linux `MemAvailable`, not
  `MemFree`; cache usage alone is not a resource failure.
- Once admitted, use the 6 GiB host `MemAvailable` reserve. Falling below 17 GiB
  while the workload consumes its intended memory is not a stop condition.
  Do not subtract the running workload's memory a second time or demand that
  its original startup headroom remain unused.
- Serial focused tests and the fixed 4,072-attempt regression are not new
  full-corpus workloads on each JVM launch. Do not impose the 17 GiB check on
  every attempt, sample, child process, or stage transition. Admit bounded work
  against its explicit resource budget and the 6 GiB host reserve, accounting
  for additional planned allocations and preserving sequential ownership.
- A genuinely new full-corpus launch repeats its startup check. A fresh safe
  environment for bounded recovery must satisfy that bounded workload's needs,
  not an unrelated full-corpus startup threshold.

## Retained Safeguards

Keep the 12 GiB service cap, 10 GiB high watermark, zero service swap, enforced
OOM stops, 6 GiB runtime host reserve, mounted volume identity, 32 GiB external
and 10 GiB internal disk guards. Full-corpus settings remain 16 workers, 8g heap,
reward pool 100. No blind budget increases or concurrent experiment owners.
Missing telemetry remains UNKNOWN; use reviewed run-bound service telemetry
where applicable. Actual reserve/cap/swap/OOM/disk violations still stop the run.
All source, proof, replay, correspondence, first-incident and coverage gates stay.

## Existing Runner And Resume Obligation

The frozen `lean-runner-validation-FaAFeP/guard.sh` calls
`check_resource 17825792` before every command. That full-corpus-sized admission
check is overconservative for the bounded serial regression. It is not a
continuous runtime check, but repeated per-attempt admission has the same
undesired scheduling effect. The frozen wrapper must not be edited in place.

Before resuming, prepare a separately versioned runner that distinguishes
full-corpus admission, bounded-command admission and runtime checks. Validate
that sufficient bounded headroom below 17 GiB is accepted, that an admitted
workload can run below 17 GiB while maintaining the 6 GiB reserve, and that
actual resource violations remain rejected. Bind and review the changed runner
and its controls before execution. This implementation/validation is PENDING;
the policy change itself is not evidence that the old runner implements it.

Preserve the original index-1181 operational interruption and unknown exact
guard sample. Its preceding below-17-GiB sample is not, under this corrected
policy, evidence of a runtime resource breach or an invalid semantic result.
Record any new guard hash and environment in a new recovery binding. Reuse old
semantic results only through checked candidate/input/verifier/claim matching;
never silently substitute the new runner under old hashes. Keep all 4,072
attempts and all 66,080 original files in scope.
