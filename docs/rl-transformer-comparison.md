# RL Depth and Hyperparameter Sweep

Status: COMPLETE

Bounded related-fixture tuning only; no corpus generalization claim; application refinement remains open

Validation seeds: [342, 343]; fresh test seeds: [401, 402, 403].
Selection maximizes validation solved counts, then minimizes parameter count; remaining ties use grid order. Test results do not select configurations.
Settings are recorded in the protocol; this is not a parameter-matched comparison.

## Validation

Configuration order: control-64x2, transformer-128x2, transformer-256x4, transformer-512x4
- egraph_transformer: solved counts [0, 0, 3, 6] / 12; selected transformer-512x4.
- gat: solved counts [3, 0, 0, 9] / 12; selected transformer-512x4.

## Fresh-Seed Test
Overall validation selection: gat transformer-512x4 (5559298 parameters).

- egraph_transformer control-64x2 (baseline): 9/27 solved; per seed [0, 6, 3]; random 8/27; parameters 463810; wall 109.05s; peak CUDA allocated 78548480 bytes; peak CUDA reserved 79691776 bytes.
- egraph_transformer transformer-512x4 (selected): 6/27 solved; per seed [0, 3, 3]; random 8/27; parameters 23953922; wall 102.49s; peak CUDA allocated 658700800 bytes; peak CUDA reserved 683671552 bytes.
- gat control-64x2 (baseline): 12/27 solved; per seed [3, 6, 3]; random 8/27; parameters 305154; wall 81.96s; peak CUDA allocated 75194880 bytes; peak CUDA reserved 77594624 bytes.
- gat transformer-512x4 (selected): 6/27 solved; per seed [0, 3, 3]; random 8/27; parameters 5559298; wall 78.68s; peak CUDA allocated 203614720 bytes; peak CUDA reserved 220200960 bytes.

Repeated random controls are the same evidence, not extra independent trials. Episodes share evolving instance banks. No global model default has been changed.
Unique child runs: 28; optimizer updates: 1344; total elapsed seconds: 856.18.
