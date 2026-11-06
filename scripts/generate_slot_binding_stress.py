#!/usr/bin/env python3
"""Deterministic paired Alloy binding stress corpus; no production rewrites."""
import argparse
import hashlib
import json
import math
import random
import re
from collections import Counter
from pathlib import Path

SCHEMA = "slot-binding-stress-v1"
PROFILES = [(8, 1), (16, 2), (32, 4), (64, 8), (96, 2),
            (128, 4), (160, 8), (192, 8), (224, 4), (256, 8)]
FAMILIES = [
    "homogeneous_alpha", "heterogeneous_alpha", "same_type_permutation",
    "declaration_grouping", "independent_block_exchange", "boolean_aci",
    "implication", "iff", "conditional", "let_beta", "function_inline",
    "relational_algebra", "comprehension", "cardinality_quantifiers",
    "integer_sequence", "future_unary", "past_unary", "future_binary",
    "past_binary", "temporal_imports", "dependent_shadowing",
    "negative_cross_type", "negative_disjoint_groups",
    "negative_quantifier_order", "negative_temporal_endpoint",
]
DECLS = """open util/integer as ints
open util/ordering[T7] as ord
abstract sig Root {
  r, mark: set Root,
  tri: Root -> Root,
  var changing: set Root
}
sig T0 extends Root { owned: set Root }
sig T1 extends Root { owned: set Root }
sig T2, T3, T4, T5, T6, T7 extends Root {}
sig Leaf, Peer extends T0 {}
sig Overlap in T0 + T1 {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3
  and some T4 and some T5 and some T6 and some T7 }
fun forward[u: Root]: set Root { u.r }
fun links[u: Root, v: Root]: set Root { u.(tri.v) }
"""


def sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def core(family):
    p, q, s = "some x0.mark", "some x1.mark", "x0 in Live"
    bodies = {
        "boolean_aci": (f"(({p}) and ({q})) and (({s}) and ({p}))",
                        f"({s}) and (({q}) and ({p}))", ["and", "ACI"]),
        "implication": (f"({p}) implies ({q})", f"not ({p}) or ({q})", ["implies", "not", "or"]),
        "iff": (f"({p}) iff ({q})", f"(({p}) implies ({q})) and (({q}) implies ({p}))", ["iff"]),
        "conditional": (f"({p}) implies ({q}) else ({s})",
                        f"(({p}) and ({q})) or (not ({p}) and ({s}))", ["formula-ITE"]),
        "let_beta": ("let a = x0.r, b = x1.r | some (a & b)",
                     "some (x0.r & x1.r)", ["let", "intersection"]),
        "function_inline": ("some forward[x0] and some links[x0,x1]",
                            "some x0.r and some x0.(tri.x1)", ["function-call", "join", "ternary-relation"]),
        "relational_algebra": (
            "some ((x0.r + x1.r) - (x0.r & x1.r)) and "
            "some ((T0 <: r) :> T1) and some (~r + ^r + *r) and "
            "some (r ++ x0->x1) and (iden & r) in (univ -> univ) and no ((none -> none) & r)",
            "some ((x1.r + x0.r) - (x1.r & x0.r)) and "
            "some ((T0 <: r) :> T1) and some (~r + ^r + *r) and "
            "some (r ++ x0->x1) and (iden & r) in (univ -> univ) and no ((none -> none) & r)",
            ["union", "difference", "intersection", "domain", "range", "transpose",
             "closure", "reflexive-closure", "override", "arrow", "iden", "univ", "none"]),
        "comprehension": ("some { a: T0, b: T1 | a->b in mark and x0 in a.r }",
                          "some { c: T0, d: T1 | c->d in mark and x0 in c.r }", ["comprehension"]),
        "cardinality_quantifiers": (
            "(one a: T0 | a in x0.r) and (lone b: T1 | b in x1.r) and "
            "(no c: T2 | c in x0.mark) and (some d: T3 | d in x1.mark)", None,
            ["one-quantifier", "lone-quantifier", "no-quantifier", "some-quantifier"]),
        "integer_sequence": (
            "(sum a: x0.r | #a) >= 0 and ints/add[#x0.r,1] >= 1 and "
            "ints/sub[4,2] = 2 and ints/mul[2,2] = 4 and ints/div[4,2] = 2 and "
            "ints/rem[4,3] = 1 and (some sq: seq Root | #sq >= 0) and "
            "some (Int -> Root) and some (some x0.r => x0.r else x1.r)", None,
            ["sum", "cardinality", "integer-arithmetic", "seq", "expression-ITE", "Int"]),
        "future_unary": ("always (x0 in Live implies eventually x1 in Live) and "
                         "after (x0.changing = (x0.changing)')", None,
                         ["always", "eventually", "after", "prime"]),
        "past_unary": ("once x0 in Live or historically (x0 in Live implies before x1 in Live)",
                       None, ["once", "historically", "before"]),
        "future_binary": ("(x0 in Live until x1 in Live) and (x1 in Live releases x0 in Live)",
                          None, ["until", "releases"]),
        "past_binary": ("(x0 in Live since x1 in Live) or (x1 in Live triggered x0 in Live)",
                        None, ["since", "triggered"]),
        "temporal_imports": ("(once x0 in Live implies always x0 in Live) and "
                             "after (eventually x1 in Live)", None,
                             ["outer-bound-phase-import", "sibling-temporal-phases"]),
        "dependent_shadowing": (
            "(some a: x0.r, b: a.r | b in x1.r) and "
            "(some x0: set Root | some x0) and (some a: lone T0 | a in Leaf + Peer + Overlap)",
            None, ["dependent-domain", "shadowing", "set-multiplicity", "lone-multiplicity",
                   "extends", "subset-signature"]),
        "negative_cross_type": ("x0->x1 in mark", "x1->x0 in mark", ["cross-type-slot-swap"]),
        "negative_disjoint_groups": ("some disj a,b:T0, disj c,d:T0 | a=c and b=d",
                                     "some disj a,b,c,d:T0 | a=c and b=d", ["disjointness-classes"]),
        "negative_quantifier_order": ("all a:T0 | some b:T1 | a->b in mark",
                                      "some b:T1 | all a:T0 | a->b in mark", ["alternating-quantifiers"]),
        "negative_temporal_endpoint": ("always x0 in Live and eventually x1 in Live",
                                       "always x0 in Live and eventually x0 in Live", ["phase-endpoint-identity"]),
    }
    left, right, features = bodies.get(family, ("some x0.mark", None, [family]))
    return left, left if right is None else right, features


def build(family, n, kinds, index, seed):
    kinds = 1 if family == "homogeneous_alpha" else max(2, kinds)
    types = [f"T{i % kinds}" for i in range(n)]
    names = [f"x{i}" for i in range(n)]
    lhs, rhs, features = core(family)
    # The intersection keeps all slots in one atom, beyond separable pairwise constraints.
    cycle = " and ".join(f"x{i} in x{(i + 1) % n}.r" for i in range(n))
    joint = " & ".join(f"x{i}.r" for i in range(n))
    cycle = f"({cycle}) and some ({joint})"
    left_decls = [f"{name}: {typ}" for name, typ in zip(names, types)]
    right_decls = list(left_decls)
    if family in {"same_type_permutation", "independent_block_exchange"}:
        order = list(range(n))
        random.Random(seed + index).shuffle(order)
        right_decls = [left_decls[i] for i in order]
        if family == "same_type_permutation":
            left_decls = ["disj " + ", ".join(name for name, t in zip(names, types) if t == typ) + ": " + typ
                          for typ in sorted(set(types))]
            right_decls = ["disj " + ", ".join(names[i] for i in order if types[i] == typ) + ": " + typ
                           for typ in sorted(set(types))]
    elif family == "declaration_grouping":
        right_decls = [", ".join(name for name, typ in zip(names, types) if typ == t) + ": " + t
                       for t in sorted(set(types))]
    left = f"all {', '.join(left_decls)} |\n    ({cycle}) and ({lhs})"
    right = f"all {', '.join(right_decls)} |\n    ({cycle}) and ({rhs})"
    if family == "heterogeneous_alpha":
        prefix = " | ".join(("all " if i % 2 == 0 else "some ") + decl
                            for i, decl in enumerate(left_decls))
        left = prefix + f" |\n    ({cycle}) and ({lhs})"
        right = prefix + f" |\n    ({cycle}) and ({rhs})"
        features += ["long-alternating-prefix"]
    if family == "independent_block_exchange":
        right = " | ".join("all " + decl for decl in right_decls) + f" |\n    ({cycle}) and ({rhs})"
    # Lexical alpha conversion; the shadowed x0 binder is renamed with its uses too.
    right = re.sub(r"\bx(\d+)\b", lambda m: f"y{int(m[1]):03d}", right)
    name = f"stress{index:04d}"
    source = (f"module slot_stress_{index:04d}\n" + DECLS
              + f"\npred {name} {{\n  {left}\n}}\npred {name}C {{\n  {right}\n}}\n"
              + f"assert equivalent {{ {name} iff {name}C }}\n"
              + "check equivalent for 12 but 5 Int, 1..3 steps\n"
              + f"run {{ {name} }} for 12 but 5 Int, 1..3 steps\n")
    counts = Counter(types)
    return source, {
        "family": family, "predicate": name, "reference": name + "C",
        "expectedEquivalent": not family.startswith("negative_"),
        "outerBindingsPerPredicate": n, "outerTypeCount": kinds,
        "outerTypeHistogram": dict(sorted(counts.items())),
        "minimumAtomsPerTypeForNonvacuousOuterPrefix": dict(sorted(counts.items()))
        if family == "same_type_permutation" else {t: 1 for t in sorted(counts)},
        "features": features, "allOuterBindingsUsed": True,
        "log10UntypedPermutationEnvelope": math.lgamma(n + 1) / math.log(10),
        "log10TypePartitionedPermutationEnvelope": sum(math.lgamma(c + 1) for c in counts.values()) / math.log(10),
        "sha256": sha(source),
        "labelBasis": "schema construction; reduced solver probe is separate from long-instance validation",
    }


def contents(seed):
    files, rows, probes = {}, [], []
    for fi, family in enumerate(FAMILIES):
        for pi, (n, kinds) in enumerate(PROFILES):
            index = fi * len(PROFILES) + pi
            source, row = build(family, n, kinds, index, seed)
            status = "CORRECT" if row["expectedEquivalent"] else "NEGATIVE"
            path = f"models/{family}/{status}/generated_{row['predicate']}.als"
            row.update(path=path, profile=pi)
            files[path] = source
            rows.append(row)
        source, probe = build(family, 4, 2, 1000 + fi, seed)
        path = f"probes/{family}/generated_{probe['predicate']}.als"
        # Small shared scopes admit witnesses but avoid exponential long-prefix SAT expansion.
        source = source.replace("for 12 but 5 Int, 1..3 steps",
                                "for 10 but exactly 2 T0, exactly 2 T1, exactly 1 T2, "
                                "exactly 1 T3, exactly 1 T4, exactly 1 T5, exactly 1 T6, "
                                "exactly 1 T7, 5 Int, 1..3 steps")
        probe.update(path=path, sha256=sha(source))
        # Relational second-order quantification is legal syntax but not uniformly solver-supported.
        probe["solverCheck"] = family not in {"integer_sequence", "dependent_shadowing"}
        probes.append(probe)
        files[path] = source
    inventory = "".join(f"{sha(text)}  {path}\n" for path, text in sorted(files.items()))
    manifest = {
        "schema": SCHEMA, "seed": seed, "targetPairs": len(rows), "targetPredicates": 2 * len(rows),
        "positivePairs": sum(r["expectedEquivalent"] for r in rows),
        "negativePairs": sum(not r["expectedEquivalent"] for r in rows),
        "profiles": [{"bindings": n, "requestedTypes": k} for n, k in PROFILES],
        "filesSha256": sha(inventory), "pairs": rows, "reducedProbes": probes,
        "coverageBoundary": "Broad Alloy 6.2 syntax including temporal logic; not exhaustive grammar production coverage.",
        "semanticBoundary": "All long models parsed/typechecked; no long-model SAT certification claimed.",
    }
    files["SHA256SUMS"] = inventory
    files["manifest.json"] = json.dumps(manifest, indent=2, sort_keys=True) + "\n"
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("synthetic-data/slot-binding-stress"))
    parser.add_argument("--seed", type=int, default=20261106)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    files = contents(args.seed)
    for relative, content in files.items():
        path = args.output / relative
        if args.check:
            if not path.is_file() or path.read_text(encoding="utf-8") != content:
                raise SystemExit(f"Reproduction mismatch: {path}")
        else:
            if path.exists() and path.read_text(encoding="utf-8") != content:
                raise SystemExit(f"Refusing to overwrite changed data: {path}; use a fresh output directory")
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
    actual = {p.relative_to(args.output).as_posix() for directory in ("models", "probes")
              for p in (args.output / directory).rglob("*.als")}
    if actual != {p for p in files if p.endswith(".als")}:
        raise SystemExit("Unexpected additional Alloy files in generated corpus")
    print(f"{'Checked' if args.check else 'Generated'} 250 pairs / 500 target predicates and 25 reduced probes")


if __name__ == "__main__":
    main()
