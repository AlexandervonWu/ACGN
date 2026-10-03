# RL Graph Encoder Comparison

Bounded encoder experiment; not whole-application proof or a generalization benchmark

Status: COMPLETE

Matched settings: manifest=/home/augustus/ACGN/docs/rl-repair/fixtures/encoder_comparison.json, classes=/tmp/acgn-rl-learning-build.72jqmOLB/classes, device=cuda, episodes=10, eval_episodes=3, horizon=4, capacity=100, seeds_per_class=2, hidden=64, layers=2, heads=4, lr=0.003, timeout=30, heap=2g

Seeds: 42, 43, 44

Width/depth are matched; parameter counts are not. Times sum all seeds; peak memory is the maximum per process.

## MPNN
Completed runs: 3; failed runs: 0.
- train: 29/60 solved within profile; 0 aborted; mean steps 2.500; mean edits 2.400; mean return -165.767; per-seed rates [0.45, 0.55, 0.45].
- random: 5/18 solved within profile; 0 aborted; mean steps 2.389; mean edits 2.056; mean return -257.167; per-seed rates [0.3333333333333333, 0.3333333333333333, 0.16666666666666666].
- learned: 3/18 solved within profile; 0 aborted; mean steps 3.500; mean edits 3.500; mean return -375.889; per-seed rates [0.0, 0.5, 0.0].
- Parameters: 354818; updates: 60.
- Wall: 38.103s; model forward: 1.126s; model update: 0.604s.
- Observed solver calls: 474; peak CUDA allocated bytes: 76120576.

## GCN
Completed runs: 3; failed runs: 0.
- train: 21/60 solved within profile; 0 aborted; mean steps 2.833; mean edits 2.717; mean return -287.500; per-seed rates [0.4, 0.3, 0.35].
- random: 5/18 solved within profile; 0 aborted; mean steps 2.389; mean edits 2.056; mean return -257.167; per-seed rates [0.3333333333333333, 0.3333333333333333, 0.16666666666666666].
- learned: 6/18 solved within profile; 0 aborted; mean steps 3.000; mean edits 3.000; mean return -193.333; per-seed rates [0.0, 1.0, 0.0].
- Parameters: 304770; updates: 60.
- Wall: 38.656s; model forward: 1.344s; model update: 0.635s.
- Observed solver calls: 474; peak CUDA allocated bytes: 74631168.

## GAT
Completed runs: 3; failed runs: 0.
- train: 29/60 solved within profile; 0 aborted; mean steps 2.433; mean edits 2.333; mean return -158.933; per-seed rates [0.45, 0.65, 0.35].
- random: 5/18 solved within profile; 0 aborted; mean steps 2.389; mean edits 2.056; mean return -257.167; per-seed rates [0.3333333333333333, 0.3333333333333333, 0.16666666666666666].
- learned: 3/18 solved within profile; 0 aborted; mean steps 3.167; mean edits 3.167; mean return -381.778; per-seed rates [0.0, 0.5, 0.0].
- Parameters: 305154; updates: 60.
- Wall: 37.883s; model forward: 1.263s; model update: 0.640s.
- Observed solver calls: 474; peak CUDA allocated bytes: 75162624.

## GIN
Completed runs: 3; failed runs: 0.
- train: 20/60 solved within profile; 0 aborted; mean steps 2.850; mean edits 2.733; mean return -308.933; per-seed rates [0.35, 0.4, 0.25].
- random: 5/18 solved within profile; 0 aborted; mean steps 2.389; mean edits 2.056; mean return -257.167; per-seed rates [0.3333333333333333, 0.3333333333333333, 0.16666666666666666].
- learned: 6/18 solved within profile; 0 aborted; mean steps 2.667; mean edits 2.500; mean return -199.222; per-seed rates [0.5, 0.5, 0.0].
- Parameters: 329732; updates: 60.
- Wall: 38.375s; model forward: 1.183s; model update: 0.633s.
- Observed solver calls: 474; peak CUDA allocated bytes: 75187712.

No winner is selected from this held-out pilot. Small samples are not evidence of superiority.
Whole-application refinement remains open. Numerical kernels are external TCB; semantic authority is unchanged.
