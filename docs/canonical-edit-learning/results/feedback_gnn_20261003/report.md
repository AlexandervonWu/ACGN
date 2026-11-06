# Bounded GNN Comparison

Final repairs on eight training tasks for seeds 17, 29, 43:

- gin: [3, 5, 4]; 1,541,252 parameters; teacher joint accuracy 0.832.
- sage: [2, 4, 2]; 1,541,249 parameters; teacher joint accuracy 0.810.
- gat: [3, 2, 2]; 1,639,553 parameters; teacher joint accuracy 0.822.
- gcn: [1, 4, 1]; 1,541,249 parameters; teacher joint accuracy 0.729.
- mlp: [1, 1, 0]; 1,479,809 parameters; teacher joint accuracy 0.548.
- original: [0, 1, 0]; 482,049 parameters; teacher joint accuracy 0.405.

## Limitations

- Eight training tasks, not held-out generalization.
- New readout and decoder are shared interventions, not isolated single-factor ablations.
- Gradients and imitation scores cannot certify semantic repair.
- No large-model escalation; original 1/8/64 gate outcome preserved.
