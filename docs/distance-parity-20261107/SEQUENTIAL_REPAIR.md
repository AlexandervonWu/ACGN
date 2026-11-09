# Walkthrough-First Replay-Guided Repairs

## Latest Pause And Resource Override

The user paused work on 2026-11-09 after the current review and authorized a
checkpoint push. Wait for explicit resume; older overnight auto-resume and
no-push wording below are historical. See `PAUSED_CHECKPOINT_20261109.md`.
`RESOURCE_POLICY.md` governs memory checks: 17 GiB MemAvailable is only a
full-corpus startup admission threshold, not a runtime requirement or a
per-attempt threshold for bounded serial work. The 6 GiB runtime host reserve
and service/swap/OOM/disk safeguards remain unchanged. A reviewed replacement
for the overstrict frozen focused wrapper is required before resuming.

## Current Overnight Authorization

The latest user instruction supersedes the foreground-only scheduling below:
rerun the full corpus, stop at the first concrete mismatch between replayed
Fast Rewrite and Certificate-Integrated operations, extract its pattern,
locate the earliest faulty stage with a minimal bounded static walkthrough of
the data traces, repair, run the combined regression once, and restart from
the beginning in a fresh manifest-bound directory. Do not bypass walkthroughs
or launch competing runs/owners. Retain all earlier focused witnesses.

The operation scan must compare independently replayed, endpoint-linked
selected actions, including zero-cost actions and original binding coordinates.
Component equality alone is not operation equality. Unsupported/ambiguous
correspondence is explicitly unchecked, never matched; report checked and
unchecked coverage separately. A concrete action mismatch, invalid replay,
distance/component discrepancy or execution/soundness failure stops the run.
Missing public certification remains BLOCKED and does not become a false
operation mismatch. No unrelated exporter/collision detours are authorized.

Use the workstation controller's current overnight SOP for coordination and
the existing resource/retention boundaries below. After a tested repair,
verify source/dataset hashes and make a local commit before restarting.
No push, tag, release or dataset edits are authorized. A completed scan with
unchecked pairs is an incomplete assessment, not full-corpus parity.

## Prior Scheduling Context

The author authorized automatic progression from one validated repair to the
next on 2026-11-07. This does not authorize publication, scalar substitution,
weaker certification, changes to classified-data, or concurrent recovery.
The previously authorized diagnostic mode remains distinct from strict mode.

The earlier authorization replaced isolated witness-by-witness patching with a
foreground walkthrough-and-repair cycle. The competing heartbeat was cancelled;
do not recreate it or restart the corpus after individual patches. Retained mismatches are
focused diagnostic inputs and regression controls, not permission to bypass the
walkthrough. `focused-witnesses.json` indexes the retained source cases without
replacing their original external receipts or promoting diagnostic agreement to
certification.

The subsequent instruction is a bounded static-analysis walkthrough first,
followed by real-corpus pattern discovery. Cover the five boundaries below,
using focused witnesses and minimal probes to distinguish demonstrated defects
from unsupported or unresolved cases. Run the combined regression suite once
per frozen repair; do not duplicate it with an agent-run existing-test suite.
New minimal reproducers and Lean compilation precede that regression run. A
failed regression requires investigation and a revised repair, never an
unchanged rerun. After the static pass and validated repairs, proceed to one
guarded real-corpus diagnostic scan, without recreating the cancelled monitor.

## Cycle

1. Read the local controller pointer and check actual agent/process liveness.
   Continue an existing owner instead of dispatching duplicate work.
2. Begin with the implementation walkthrough below, using the current retained
   residual and previously repaired families. Reproduce stage boundaries against
   a frozen build with bounded probes. A new corpus scan is a later validation
   step, not an automatic replacement for diagnosis. Do not edit the checkout
   during a manifest-bound run.
   If full-scan startup lacks resource headroom, continue one independently
   reproduced data-discrepancy residual with bounded
   serial tests, provided the host reserve is preserved. Record that owner
   before dispatch; do not launch a corpus scan while the repair is active,
   even if memory recovers. Resource refusal never permits weaker guards.
3. Stop all run descendants and retain the source/hash, predicate identities,
   component costs, native operation receipts, build identity and fingerprint.
4. Assign one actual `gpt-6-astra` walkthrough owner. Record the first demonstrated
   faulty boundary and its premises before authorizing a semantic repair. A
   downstream receipt difference alone does not establish an earlier faulty
   rewrite. Replay the shorter sequence
   against its endpoints first. A failed replay targets the shorter path;
   valid replay directs investigation toward extra edits or missing admitted
   representations in the longer path. Incomplete public alignment remains
   blocked and cannot be treated as a complete replay success.
5. Compile the relevant Lean contract before refining Java. Keep original
   occurrences, result types, binder scopes, temporal owners, certificate
   premises and selected representation links. Never copy a distance or
   take the minimum of two unexplained scalars.
6. Add the concrete witness and boundary controls, test both directions, then
   run the combined regression suite from frozen, hashed inputs. Keep compact
   before/after evidence and a clean local commit. Update CLI expectations
   when a real defect is repaired; do not retain a bug solely as a test case.
7. Release recovery ownership and begin the next implementation walkthrough
   using the focused witness set. No per-issue user confirmation is required,
   but no competing monitor is recreated. The newly authorized real-corpus
   pattern phase follows the bounded static pass, not each individual repair.

## Required Walkthrough

Trace both sides of each boundary before changing semantics:

1. Shared source preparation, alpha/beta normalization, NNF, prenex and the
   pre-ACI certification snapshot.
2. Fast ACI/saturation and comparison view versus certified construction and
   repair projection. Compare typed, source-linked occurrences and owners,
   not raw IR strings.
3. Admitted representations and declaration/alpha candidate sets, including
   support/refusal branches, paid links, local scopes and ordering barriers.
4. Per-action costs, candidate selection and deterministic tie-breaking.
5. Selected declaration, temporal and matrix receipts, their common binding
   correspondence, and independent replay against original endpoints.

For each stage retain the code branch, build/input identity, observed boundary
values, checked premises and unresolved obligations. Separate equivalent but
differently represented states from unsupported candidates, omitted candidates,
cost defects and tie differences. Mark unobserved earlier stages unresolved;
do not label a downstream difference the first faulty rewrite without evidence.
Generalize the demonstrated invariant into a Lean contract before Java changes.
Run related earlier witness families and negative controls as well as the new
case; retain failed candidates instead of changing expectations to hide them.

## Boundaries

- One corpus run or one recovery owner at a time; no competing recovery agents.
- Preserve the established worker, heap, service cap, host reserve and storage
  guards. Resource refusal is not permission to weaken an OOM safeguard.
  The author subsequently approved relaxing the diagnostic startup threshold:
  use 17 GiB MemAvailable rather than 18 GiB for the workstation parity runner.
  The runtime host reserve remains 6 GiB, with 16 workers, 8g heap, 12 GiB
  service cap, 10 GiB high watermark, zero service swap and OOM stops unchanged.
  This is an admission threshold, not a claim that the full cap is reserved.
  Prioritize the implementation walkthrough and focused pattern diagnosis.
  The author redirected work away from independent exporter
  and certification prerequisites: park the unfinished collision-export work
  separately and do not resume it unless it directly explains a measured
  distance or edit-sequence discrepancy. Keep certification blocked honestly;
  do not spend this repair cycle trying to clear unrelated release gates.
- Two recurrences of the same fingerprint after investigated repairs require
  user attention. Do not launch an unchanged semantic failure again.
- Preserve original final natural and synthetic evidence, completed useful
  stages and unresolved incidents. Remove disposable build copies or failed
  partial outputs only after recording decisive evidence and a deletion ledger.
- Stop for user cancellation, unavailable required models/storage, unsafe
  resources or an unresolved semantic admission that cannot be repaired safely.
  Report the concrete blocker, not an invented successful monitor cycle.
- Component equality is only diagnostic progress. Completion requires the
  original 61,598 eligible paired rows (4,482 exclusions), equal distances and
  independently validated common action sequences, soundness gates, exact
  zero subsets and the declared finite minimality boundary. Missing public
  source/certificate/Java-Lean alignment keeps strict certification blocked.
- No push, tag or release is part of this repair authorization.

Workstation-specific mutable pointers and storage live outside this document;
consult `.git/local-tools/STORAGE.md` and the active investigation controller.
The controller is a checkpoint, not evidence of process liveness.
