# RL Depth and Hyperparameter Sweep

Status: COMPLETE

Bounded related-fixture tuning only; no corpus generalization claim; application refinement remains open

Validation seeds: [142, 143]; fresh test seeds: [201, 202, 203].
Selection uses validation solved counts only, ties by fixed grid order. Test results do not select configurations.
Learning rates, width and depth vary; this is not a parameter-matched comparison.

## Validation

Configuration order: control-64x4, large-256x4, large-512x6, large-1024x6
- gcn: solved counts [0, 0, 0, 3] / 12; selected large-1024x6.
- gat: solved counts [0, 3, 3, 0] / 12; selected large-256x4.

## Fresh-Seed Test
- gcn control-64x4 (baseline): 15/27 solved; per seed [3, 3, 9]; random 4/27; parameters 321410; wall 53.61s; peak CUDA allocated 75161600 bytes; peak CUDA reserved 77594624 bytes.
- gcn large-1024x6 (selected): 9/27 solved; per seed [3, 0, 6]; random 4/27; parameters 22120450; wall 50.25s; peak CUDA allocated 598116864 bytes; peak CUDA reserved 658505728 bytes.
- gat control-64x4 (baseline): 9/27 solved; per seed [3, 3, 3]; random 4/27; parameters 322178; wall 49.63s; peak CUDA allocated 76206592 bytes; peak CUDA reserved 77594624 bytes.
- gat large-256x4 (selected): 3/27 solved; per seed [3, 0, 0]; random 4/27; parameters 1927682; wall 49.48s; peak CUDA allocated 115846144 bytes; peak CUDA reserved 136314880 bytes.

Repeated random controls are the same evidence, not extra independent trials. Episodes share evolving instance banks. No global model default has been changed.
Unique child runs: 28; optimizer updates: 672; total elapsed seconds: 485.35.
