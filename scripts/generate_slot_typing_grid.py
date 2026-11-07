#!/usr/bin/env python3
"""Balanced, seeded 2..10-binding grid, separate from the archived stress corpus."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import random

FAMILIES = ("alpha", "boolean_aci", "implication", "future_temporal", "past_temporal")


def digest(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def rng_for(seed, *parts):
    return random.Random(int(digest(json.dumps([seed, *parts])), 16))


def balanced_types(n, m, rng):
    if not 2 <= n <= 10 or not 1 <= m <= n:
        raise ValueError("Require 2 <= N <= 10 and 1 <= M <= N")
    q, r = divmod(n, m)
    extras = set(rng.sample(range(m), r))
    allocation = [t for t in range(m) for _ in range(q + (t in extras))]
    rng.shuffle(allocation)
    return allocation


def build(n, m, replicate, seed, index):
    types = balanced_types(n, m, rng_for(seed, "types", n, m, replicate))
    # The structural seed is independent of M: cells vary types, not graph shape.
    rng = rng_for(seed, "shape", n, replicate)
    cycle = list(range(n))
    rng.shuffle(cycle)
    decl_order = list(range(n))
    rng.shuffle(decl_order)
    family = FAMILIES[replicate % len(FAMILIES)]
    def body(prefix, right):
        x = [f"{prefix}{i}" for i in range(n)]
        ring = " and ".join(f"{x[cycle[i]]} in {x[cycle[(i+1) % n]]}.r" for i in range(n))
        joint = "some (" + " & ".join(f"{v}.r" for v in x) + ")"
        p, q = f"some {x[0]}.mark", f"some {x[1]}.mark"
        feature = {
            "alpha": p,
            "boolean_aci": f"({q}) and ({p})" if right else f"({p}) and (({q}) and ({p}))",
            "implication": f"not ({p}) or ({q})" if right else f"({p}) implies ({q})",
            "future_temporal": f"always ({x[0]} in Live implies eventually {x[1]} in Live)",
            "past_temporal": f"once {x[0]} in Live implies always {x[0]} in Live",
        }[family]
        order = decl_order if right else list(range(n))
        declarations = ", ".join(f"{x[i]}: T{types[i]}" for i in order)
        return f"all {declarations} |\n    ({ring}) and ({joint}) and ({feature})"
    name = f"grid{index:04d}"
    source = (f"module slot_grid_{index:04d}\n"
              "abstract sig Root { r, mark: set Root }\n"
              + "\n".join(f"sig T{i} extends Root {{}}" for i in range(m))
              + "\nvar sig Live in Root {}\n"
              + "fact Inhabited { " + " and ".join(f"some T{i}" for i in range(m)) + " }\n"
              + f"pred {name} {{\n  {body('x', False)}\n}}\n"
              + f"pred {name}C {{\n  {body('y', True)}\n}}\n"
              + f"assert equivalent {{ {name} iff {name}C }}\n"
              + "check equivalent for 10 but 1..3 steps\n")
    histogram = dict(sorted(Counter(f"T{t}" for t in types).items()))
    path = f"models/{family}/CORRECT/generated_{name}.als"
    row = dict(path=path, family=family, predicate=name, reference=name + "C",
               expectedEquivalent=True, outerBindingsPerPredicate=n, totalBindingsPerPredicate=n,
               outerTypeCount=m, outerTypeHistogram=histogram, replicate=replicate,
               allOuterBindingsUsed=True, sha256=digest(source),
               log10UntypedPermutationEnvelope=math.lgamma(n+1)/math.log(10),
               log10TypePartitionedPermutationEnvelope=sum(math.lgamma(c+1) for c in histogram.values())/math.log(10),
               labelBasis="alpha conversion, independent ALL exchange, ACI or implication; StressSchemas.lean")
    return path, source, row


def contents(seed=20261107, replicates=5):
    if replicates < 1:
        raise ValueError("replicates must be positive")
    files, rows = {}, []
    for n in range(2, 11):
        for m in range(1, n+1):
            for replicate in range(replicates):
                path, source, row = build(n, m, replicate, seed, len(rows))
                files[path] = source
                rows.append(row)
    inventory = "".join(f"{digest(s)}  {p}\n" for p, s in sorted(files.items()))
    files["SHA256SUMS"] = inventory
    files["manifest.json"] = json.dumps(dict(
        schema="slot-typing-grid-v1", seed=seed, targetPairs=len(rows), targetPredicates=2*len(rows),
        replicatesPerCell=replicates, gridCells=54, pairs=rows, reducedProbes=[],
        filesSha256=digest(inventory),
        allocation="balanced q/q+1; seeded uniform remainder subset and shuffled binding assignment",
        semanticBoundary="Construction laws, not fresh per-instance SAT or certificate validation",
        coverageBoundary="Controlled slot-performance grid; five shapes including temporal, not full grammar coverage"
    ), indent=2, sort_keys=True) + "\n"
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("synthetic-data/slot-typing-grid"))
    parser.add_argument("--seed", type=int, default=20261107)
    parser.add_argument("--replicates", type=int, default=5)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    files = contents(args.seed, args.replicates)
    for relative, text in files.items():
        path = args.output / relative
        if args.check:
            if not path.is_file() or path.read_text(encoding="utf-8") != text:
                raise SystemExit(f"Reproduction mismatch: {path}")
        else:
            if path.exists() and path.read_text(encoding="utf-8") != text:
                raise SystemExit(f"Refusing overwrite: {path}")
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
    actual = {str(p.relative_to(args.output)) for p in args.output.rglob("*.als")}
    if actual != {p for p in files if p.endswith(".als")}:
        raise SystemExit("Unexpected Alloy files")
    print(f"{'Checked' if args.check else 'Generated'} 54 cells, {54*args.replicates} pairs, {108*args.replicates} predicates")


if __name__ == "__main__":
    main()
