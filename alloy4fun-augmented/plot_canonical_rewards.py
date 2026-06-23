#!/usr/bin/env python3
import csv, math
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CSV = ROOT / 'canonical_reward_points.csv'
def corr(xs, ys):
    if len(xs) < 2:
        return 0.0
    xb = sum(xs) / len(xs)
    yb = sum(ys) / len(ys)
    num = sum((x - xb) * (y - yb) for x, y in zip(xs, ys))
    xd = math.sqrt(sum((x - xb) ** 2 for x in xs))
    yd = math.sqrt(sum((y - yb) ** 2 for y in ys))
    return 0.0 if xd == 0.0 or yd == 0.0 else num / (xd * yd)

print('Use the generated SVG plots:')
print(ROOT / 'canonical_distance_vs_reward_error_raw.svg')
print(ROOT / 'canonical_distance_vs_reward_error_log.svg')
with CSV.open() as f:
    rows = [r for r in csv.DictReader(f) if r.get('candidateReward')]
print(f'Loaded {len(rows)} rewarded points from {CSV}')
errs = [float(r['rewardError']) for r in rows]
positive = [e for e in errs if e > 0.0]
floor = min(positive) / 10.0 if positive else 1e-6
logs = [math.log10(max(e, floor)) for e in errs]
for key, ratio_key, label in [('levenshteinDistance', 'levenshteinDistanceRatio', 'Levenshtein'), ('rawAstDistance', 'rawAstDistanceRatio', 'Raw AST'), ('canonicalDistance', 'canonicalDistanceRatio', 'Canonical')]:
    xs = [float(r[key]) for r in rows]
    ratios = [float(r[ratio_key]) for r in rows]
    print(f"Pearson {label} distance vs raw 1-reward: {corr(xs, errs):.6f}")
    print(f"Pearson {label} distance vs log10(1-reward): {corr(xs, logs):.6f}")
    print(f"Pearson {label} ratio vs raw 1-reward: {corr(ratios, errs):.6f}")
    print(f"Pearson {label} ratio vs log10(1-reward): {corr(ratios, logs):.6f}")
