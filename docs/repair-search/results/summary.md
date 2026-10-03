# Verifier-Guided Repair Pilot

8 held-out predicates, scope 3; unequal mutation/proposal spaces and budgets; not stable superiority

## Results

- uniform-puct: 0/24 checked repairs; 8 distinct tasks; 345.04 total evaluation seconds; per-seed {'711': 0, '712': 0, '713': 0}.
- learned-puct: 0/24 checked repairs; 8 distinct tasks; 328.67 total evaluation seconds; per-seed {'711': 0, '712': 0, '713': 0}.
- random-tree-walk: 0/24 checked repairs; 8 distinct tasks; 332.39 total evaluation seconds; per-seed {'711': 0, '712': 0, '713': 0}.
- tar: 4/8 checked repairs; 8 distinct tasks; 190.83 total evaluation seconds; per-seed {}.
  TAR timeouts 3; infrastructure errors 0; unrevalidated claims 0.
- base: 1/8 checked repairs; 8 distinct tasks; 70.10 total evaluation seconds; per-seed {}.
  Generation diagnostics: {'attempts': 29, 'statuses': {'SOLVED_WITHIN_PROFILE': 1, 'COUNTEREXAMPLE': 24, 'INVALID': 4}, 'incompleteResponses': 0, 'outputTokenLimits': 0}. Incomplete responses and token limits overlap with status counts; they are not additional trials.
- sft: 0/8 checked repairs; 8 distinct tasks; 104.24 total evaluation seconds; per-seed {}.
  Generation diagnostics: {'attempts': 32, 'statuses': {'FORMAT_ERROR': 28, 'COUNTEREXAMPLE': 4}, 'incompleteResponses': 24, 'outputTokenLimits': 4}. Incomplete responses and token limits overlap with status counts; they are not additional trials.
- ce: 0/8 checked repairs; 8 distinct tasks; 99.90 total evaluation seconds; per-seed {}.
  Generation diagnostics: {'attempts': 32, 'statuses': {'COUNTEREXAMPLE': 30, 'FORMAT_ERROR': 2}, 'incompleteResponses': 0, 'outputTokenLimits': 2}. Incomplete responses and token limits overlap with status counts; they are not additional trials.

## Training

Search learning: {'tasks': 16, 'solved': 1, 'updates': 384, 'seconds': 38.93714171600732}.
- sft: {'steps': 16, 'seconds': 84.4579919989992, 'selected_rows': 16, 'trainable_parameters': 2162688, 'adapter_reload_max_abs_error': 0.0}.
- ce: {'steps': 30, 'seconds': 146.480241827001, 'selected_rows': 30, 'trainable_parameters': 2162688, 'adapter_reload_max_abs_error': 0.0}.
Adapter seconds measure the training loop only, excluding checkpoint loading and export. SFT has 16 updates; CE has 30, so counterexample content is confounded with training amount.

## Interpretation

The search arms use the same typed menu and 32 simulations at depth 3. TAR uses its broader mutation inventory and a 60-second search deadline. Qwen gets up to four 512-token body proposals with counterexample feedback. These are practical pilot results, not a compute- or action-space-matched superiority claim.

Qwen LoRA training uses the local NF4 checkpoint; inference applies exported adapters to the unadapted local Q3 base. Neither the existing AIx default model nor the original dataset is changed.

Success is checked only within the shared bounded Alloy profile. Lean proves the abstract acceptance/pruning rules and checks admission receipts. Full implementation refinement and universal semantic validity remain unproved.

The earlier graph-policy study was interrupted and remains a separate negative result; its partial test totals are not mixed into these denominators.
