# Superseded Performance Attempt

Stopped by SIGINT during the first GIN-128 screening run, after the 200-update
log (103.1 seconds). No validation, model selection or test-set evaluation took
place, and no completed study output manifest was published.

The eager teacher cache encoded entire trajectories on a miss and estimated
memory from heavily indented JSON bytes. The resulting eviction/re-encoding
cost left GPU utilization low and put the Python adapter on the critical path.
The replacement uses lazy, per-decision encoding and compact-JSON-based memory
estimation, with a cache-transparency Lean model and cold/warm regression.

This attempt is not experimental repair-performance evidence. The fresh v2 run
restarts every optimizer and rechecks producer/consumer manifests.
