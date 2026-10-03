# RL Depth and Hyperparameter Sweep

Status: COMPLETE

Bounded related-fixture tuning only; no corpus generalization claim; application refinement remains open

Validation seeds: [42, 43]; fresh test seeds: [101, 102, 103].
Selection uses validation solved counts only, ties by fixed grid order. Test results do not select configurations.
Learning rates, width and depth vary; this is not a parameter-matched comparison.

## Validation

Configuration order: baseline-2, depth-4, wide-4-slow, depth-6-slow
- mpnn: solved counts [3, 3, 3, 3] / 12; selected baseline-2.
- gcn: solved counts [0, 3, 3, 0] / 12; selected depth-4.
- gat: solved counts [3, 3, 3, 0] / 12; selected baseline-2.
- gin: solved counts [0, 3, 6, 0] / 12; selected wide-4-slow.

## Fresh-Seed Test
- mpnn baseline-2 (baseline, selected): 3/27 solved; per seed [3, 0, 0]; random 11/27; parameters 354818; wall 49.94s; peak CUDA allocated 76119040 bytes.
- gcn baseline-2 (baseline): 6/27 solved; per seed [3, 3, 0]; random 11/27; parameters 304770; wall 50.06s; peak CUDA allocated 74635264 bytes.
- gcn depth-4 (selected): 9/27 solved; per seed [3, 3, 3]; random 11/27; parameters 321410; wall 48.91s; peak CUDA allocated 75166720 bytes.
- gat baseline-2 (baseline, selected): 3/27 solved; per seed [0, 3, 0]; random 11/27; parameters 305154; wall 51.16s; peak CUDA allocated 75170816 bytes.
- gin baseline-2 (baseline): 6/27 solved; per seed [3, 3, 0]; random 11/27; parameters 329732; wall 48.70s; peak CUDA allocated 75187712 bytes.
- gin wide-4-slow (selected): 6/27 solved; per seed [3, 3, 0]; random 11/27; parameters 633798; wall 50.61s; peak CUDA allocated 82377216 bytes.

Repeated random controls are the same evidence, not extra independent trials. Episodes share evolving instance banks. No global model default has been changed.
Unique child runs: 50; optimizer updates: 1200; total elapsed seconds: 847.39.
