"""Finite corpus schedule and paired reporting; no semantic authority is inferred."""

import hashlib
import json
from pathlib import Path
import random
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PROOF = ROOT / "docs/rl-repair/formal/CorpusProtocol.lean"


def split_for(group):
    fold = int.from_bytes(hashlib.sha256(("corpus-v1:" + group).encode()).digest()[:8], "big") % 10
    return "train" if fold < 6 else "validation" if fold < 8 else "evaluation"


def task_schedule(tasks, episodes, chunk=0, seed=0):
    if any(type(n) is not int for n in (tasks, episodes, chunk, seed)) or tasks < 1 or episodes < 1 or chunk < 0:
        raise ValueError("Invalid schedule bounds")
    if chunk == 0:
        return [(i, list(range(episodes))) for i in range(tasks)]
    rng = random.Random(seed)
    schedule = []
    for start in range(0, episodes, chunk):
        order = list(range(tasks))
        rng.shuffle(order)
        schedule.extend((i, list(range(start, min(start + chunk, episodes)))) for i in order)
    return schedule


def stable_counts(rows):
    fields = {"learned", "random", "budget", "aborted"}
    if any(set(r) != fields or any(type(v) is not int or v < 0 for v in r.values()) for r in rows):
        raise ValueError("Invalid comparison counts")
    return len(rows) == 5 and all(r["budget"] > 0 and r["aborted"] == 0
                                 and r["random"] < r["learned"] <= r["budget"] for r in rows)


def check_protocol(tasks, episodes, schedule, rows=None):
    jobs = [i * episodes + e for i, numbers in schedule for e in numbers]
    if tasks < 1 or episodes < 1 or sorted(jobs) != list(range(tasks * episodes)):
        raise ValueError("Invalid complete schedule")
    request = {"tasks": tasks, "episodes": episodes, "jobs": jobs, "rows": rows or []}
    result = subprocess.run(["lean", "--run", str(PROOF)], input=json.dumps(request) + "\n",
                            text=True, capture_output=True, timeout=30, check=True)
    reply = json.loads(result.stdout)
    if reply != {"accepted": True, "stable": stable_counts(request["rows"]), "request": request}:
        raise ValueError("Lean corpus-protocol mismatch")
    return {"request": request, "reply": reply,
            "proofHash": hashlib.sha256(PROOF.read_bytes()).hexdigest()}


def paired_cluster_interval(pairs, resamples=10000, seed=99173):
    """Each input is one question's paired success differences, across all seeds."""
    if not pairs or any(not values for values in pairs.values()) or resamples < 100:
        raise ValueError("Nonempty paired question clusters required")
    groups = [(sum(v), len(v)) for _, v in sorted(pairs.items())]
    if any(x not in (-1, 0, 1) for values in pairs.values() for x in values):
        raise ValueError("Expected paired binary-outcome differences")
    rng = random.Random(seed)
    samples = []
    for _ in range(resamples):
        sampled = [rng.choice(groups) for _ in groups]
        samples.append(sum(a for a, _ in sampled) / sum(b for _, b in sampled))
    samples.sort()
    return {"lower": samples[int(0.025 * resamples)], "upper": samples[int(0.975 * resamples)],
            "difference": sum(a for a, _ in groups) / sum(b for _, b in groups),
            "clusters": len(groups), "resamples": resamples, "seed": seed}
