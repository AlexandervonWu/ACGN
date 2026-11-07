# Desktop Resource Incident

## Confirmed Event

At November 6, 2026, 19:13:19 America/Chicago (November 7, 01:13:19 UTC),
the kernel recorded a **global out-of-memory** event and killed PID 9365,
`ChatGPT`, the Codex desktop application's process. The user reported disk
exhaustion and application collapse. RAM exhaustion is confirmed by the kernel;
historical disk exhaustion has not been established by this inspection.

The benchmark was `acgn-slot-order-rerun-20261107T0105Z`. Six ablation arms had
finished and the exact typed-port arm was running. These are incomplete run
results, not a successfully completed seven-arm comparison.

## Evidence

- Kernel: `oom-kill:constraint=CONSTRAINT_NONE`, `global_oom`, followed by
  `Out of memory: Killed process 9365 (ChatGPT)`.
- Free swap at the event: 204 KiB out of 1,194,956 KiB total.
- The killed application process had 9,650,248 KiB anonymous RSS. This is an
  observation, not a diagnosis of why that application allocated memory.
- The experiment's Java worker had about 4.86 GiB resident memory and its Java
  controller about 0.49 GiB at the event. Other desktop processes also consumed
  memory. A Java compiler thread's allocation triggered the OOM handler.
- The experiment cgroup had no recorded cgroup OOM or maximum-limit events.
  Its 11 GiB `MemoryMax` had not been reached. A per-service upper limit does
  not reserve memory for desktop applications or prevent global OOM below it.
- Inspection after the crash found approximately 27 GiB disk free and healthy
  inode availability. The newest run directory accounted for about 787 MiB by
  `du`, including hard-linked source files; this is not all newly allocated disk
  space. The cause of the earlier-to-current increase in free disk is unknown.

Kernel evidence can be retrieved with:

```sh
journalctl -k --since '2026-11-07 01:12:30 UTC' \
  --until '2026-11-07 01:14:00 UTC' --no-pager
```

## Supervisor Failure

The supervisor sampled host memory every five seconds and allowed availability
below 512 MiB to persist for 30 seconds before stopping. That leaves inadequate
time/headroom for a desktop host under abrupt allocation pressure. The service
cap did not substitute for a host reserve. Earlier launch with approximately
1.7 GiB disk free and a 1 GiB disk-stop threshold also left inadequate storage
headroom, irrespective of the confirmed RAM failure.

The recorded `run-status.json` retained only the most recent memory sample,
not a time series. Its roughly 9 GiB available-memory observation after the
application was killed does not describe the pre-crash pressure. The supervisor
continued after the desktop OOM, which is another operational deficiency.

## Containment

The benchmark service and remaining processes were stopped. No running `acgn-*`
user services remained at verification. Its run status is explicitly
`STOPPED_RESOURCE_INCIDENT`, with a manually recorded stop reason rather than
a claim that the supervisor detected the event. Partial results, manifests,
source snapshots, and completed earlier runs remain intact. No files were
deleted to reclaim space, and no benchmark was restarted.

## Before Another Launch

The prior launch policy must not be reused unchanged. A replacement needs a
conservative startup RAM/disk budget covering controllers and worker/native
memory, substantial desktop headroom, earlier host-pressure termination,
bounded historical telemetry, and termination on a newly observed global OOM.
Lower worker/heap settings and an experiment-favoring OOM victim policy should
be evaluated within those budgets. Such policy changes are not implemented or
claimed validated by this incident note. A new run requires deliberate resource
reconfiguration; this report does not authorize automatic resumption.
