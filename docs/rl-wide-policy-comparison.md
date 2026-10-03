# RL Depth and Hyperparameter Sweep

Status: COMPLETE

Bounded related-fixture tuning only; no corpus generalization claim; application refinement remains open

Validation seeds: [242, 243]; fresh test seeds: [301, 302, 303].
Selection maximizes validation solved counts, then minimizes parameter count; remaining ties use grid order. Test results do not select configurations.
Settings are recorded in the protocol; this is not a parameter-matched comparison.

## Validation

Configuration order: control-64x2, wide-1024x2, wide-2048x2, wide-4096x2
- mpnn: solved counts [0, 0, 3, 0] / 12; selected wide-2048x2.
- gcn: solved counts [0, 0, 0, 0] / 12; selected control-64x2.
- gat: solved counts [3, 0, 0, 0] / 12; selected control-64x2.
- gin: solved counts [0, 3, 0, 0] / 12; selected wide-1024x2.

## Fresh-Seed Test
Overall validation selection: gat control-64x2 (305154 parameters).

- mpnn control-64x2 (baseline): 3/27 solved; per seed [3, 0, 0]; random 8/27; parameters 354818; wall 49.70s; peak CUDA allocated 76111360 bytes; peak CUDA reserved 77594624 bytes.
- mpnn wide-2048x2 (selected): 9/27 solved; per seed [3, 3, 3]; random 8/27; parameters 96681986; wall 50.39s; peak CUDA allocated 2387495424 bytes; peak CUDA reserved 2529165312 bytes.
- gcn control-64x2 (baseline, selected): 9/27 solved; per seed [6, 0, 3]; random 8/27; parameters 304770; wall 50.29s; peak CUDA allocated 74631680 bytes; peak CUDA reserved 77594624 bytes.
- gat control-64x2 (baseline, selected): 9/27 solved; per seed [3, 3, 3]; random 8/27; parameters 305154; wall 49.55s; peak CUDA allocated 75187200 bytes; peak CUDA reserved 77594624 bytes.
- gin control-64x2 (baseline): 9/27 solved; per seed [3, 6, 0]; random 8/27; parameters 329732; wall 49.81s; peak CUDA allocated 75183104 bytes; peak CUDA reserved 75497472 bytes.
- gin wide-1024x2 (selected): 9/27 solved; per seed [6, 0, 3]; random 8/27; parameters 20021252; wall 48.49s; peak CUDA allocated 547676672 bytes; peak CUDA reserved 591396864 bytes.

Repeated random controls are the same evidence, not extra independent trials. Episodes share evolving instance banks. No global model default has been changed.
Unique child runs: 50; optimizer updates: 1200; total elapsed seconds: 878.04.
