"""A2-04 replay delegate. Encoding/extraction are explicitly trusted, fail closed.

generate/negatives/source_mutations implement run_next_obligation_repairs.py's
plugin API; an aggregate plugin may concatenate these returned lists.
"""

from itertools import product
import json
from pathlib import Path
import re

from next_obligation_replays import associations, lean_list, naturals, rows, text
from run_submission_container_closure import Blocked


FIELDS = "surface fixture arities tree relations output producer verifier equivalent".split()
SOURCE_FIELDS = ("object owner method modifiers shapeSha256 bindingsSha256 minimum start endOffset "
                 "leftBoundary rightBoundary").split()
P = "is.fivefivefive.CanDis.theory."
V = "org.acgn.cert.SemanticEvidenceVerifier.SemanticReplay"
SOURCES = {
    "producer-guard": (P + "DependentChainTheory", "requireSoundFlattening", "public,static",
                       "ba3602904fbde410970535101526e96938d400e18ed14c2a23f50f649b0c8280",
                       "2833b788067346f06fd1549a7e0943855a0e899081e089fbf0d4b7a6e57ba1e4"),
    "producer-combine": (P + "DependentTypeDag", "combine", "public,static",
                         "a63d65791d82625180c9793b63c8d1b477ec9d643e738059c83d8f53e29dda27",
                         "b05927d7cc63c8e1d54a51871e08e98180d73d4d78564084516f130067e711fb"),
    "verifier-guard": (V, "requireSoundDependentFlattening", "private",
                       "86a2ab6dae44a6cad938f0f045abbf63a53409bc082a40c564793f98693ab195",
                       "b06159725dc29b6139dc94b5cfae780de7c3b26e921865064cfd93ba245983ed"),
    "verifier-combine": (V, "requireChainCombination", "private",
                         "9b68a2996d5f0fb6f27a2b93f8b430a2ba577c99ec55dd39e8e692feceaa78bf",
                         "6cd8657889f4187de4248e1283eaaa02a35fc7be87962da377b17950ea5931f9"),
}


def boolean(value):
    if value not in ("true", "false"):
        raise Blocked("noncanonical JOIN Boolean")
    return value


def nested(value, depth):
    try:
        parsed = json.loads(value)
    except (ValueError, RecursionError) as error:
        raise Blocked("invalid JOIN relation JSON") from error

    def valid(obj, level):
        if level == 0:
            return type(obj) is int and obj in (0, 1)
        return isinstance(obj, list) and len(obj) <= 128 and all(valid(item, level - 1) for item in obj)

    if not valid(parsed, depth) or json.dumps(parsed, separators=(",", ":")) != value:
        raise Blocked("noncanonical/out-of-census JOIN relation")
    return parsed


def tree_term(value):
    pos = 0

    def parse():
        nonlocal pos
        if pos >= len(value):
            raise Blocked("truncated JOIN tree")
        token = value[pos]
        pos += 1
        if token in "01234":
            return f"(.leaf {token})"
        if token != "(":
            raise Blocked("unknown JOIN tree token")
        left = parse()
        if pos >= len(value) or value[pos] != ",":
            raise Blocked("missing JOIN tree comma")
        pos += 1
        right = parse()
        if pos >= len(value) or value[pos] != ")":
            raise Blocked("missing JOIN tree close")
        pos += 1
        return f"(.app .join {left} {right})"

    if len(value) > 32:
        raise Blocked("JOIN tree exceeds frozen census")
    term = parse()
    if pos != len(value):
        raise Blocked("trailing JOIN tree data")
    return term


def fixture_spec(n, fixture, seed):
    arities = [3 if fixture == "wide" else 2] * n
    if fixture in ("left-unary", "both-unary"):
        arities[0] = 1
    if fixture in ("right-unary", "both-unary"):
        arities[-1] = 1
    if fixture == "both-unary":
        arities[1] = 3
    empty = int(fixture[6:]) if fixture.startswith("empty-") else -1
    relations = [[[bits >> col & 1 for col in reversed(range(arity))]
                  for bits in range(1 << arity) if (bits + seed + i) % 3 == 0]
                 if i != empty else [] for i, arity in enumerate(arities)]
    return arities, relations


def census():
    """Frozen keys map to exact arities and, where applicable, finite inputs."""
    expected = {}
    for n in range(6):
        for word in product((1, 2, 3), repeat=n):
            expected["guard", "word-" + ",".join(map(str, word)), "-"] = (list(word), None)
    for n in (8, 17, 64):
        for i in range(n):
            word = [2] * n
            word[i] = 1
            expected["guard", f"long-{n}-{i}", "-"] = (word, None)
    for arity in (1, 2, 3):
        for i in range(5):
            word = [2] * 5
            word[i] = arity
            expected["guard", f"empty-{arity}-{i}", "-"] = (word, None)
    expected["guard", "univ", "-"] = ([1, 2, 2, 1], None)
    for n in range(2, 6):
        fixtures = ["binary", "left-unary", "right-unary", "wide", "univ"]
        if n >= 3:
            fixtures.append("both-unary")
        fixtures += [f"empty-{i}" for i in range(n)]
        for fixture, seed in product(fixtures, range(2)):
            spec = fixture_spec(n, fixture, seed)
            for tree in associations(list(range(n))):
                expected["finite", f"{n}:{fixture}:{seed}", tree] = spec
    for tree in associations([0, 1, 2]):
        expected["counter", "unary", tree] = ([2, 1, 2], [[[0, 1]], [[1]], [[0, 0]]])
    for fixture in ("binary3", "binary4", "binary5", "left", "right", "both", "empty", "univ"):
        n = 3 if fixture == "binary3" else 5 if fixture == "binary5" else 4
        word = [2] * n
        if fixture in ("left", "both"):
            word[0] = 1
        if fixture in ("right", "both"):
            word[-1] = 1
        if fixture == "both":
            word[1] = 3
        for mode, tree in product(("FORBID", "MODULAR"), associations(list(range(n)))):
            expected["parser", fixture + ":" + mode, tree] = (word, None)
    return expected


def program(observed, extracted):
    expected = census()
    if len(expected) != 1021 or len(observed) != len(expected):
        raise Blocked("incomplete guarded JOIN observation census")
    if len(extracted) != 4 or {row["object"] for row in extracted} != set(SOURCES):
        raise Blocked("incomplete guarded JOIN source census")
    output = ["import GuardedJoinChain", "namespace ACGN.ThirdFive.JoinReplay",
              "open ACGN.ThirdFive.GuardedJoinChain",
              "open ACGN.Section3.DependentChainSequence",
              "open ACGN.BoundedFive.DependentJoinGuard (guard)"]
    for i, row in enumerate(extracted):
        if tuple(row[k] for k in ("owner", "method", "modifiers", "shapeSha256", "bindingsSha256")) != SOURCES[row["object"]]:
            raise Blocked("unregistered JOIN source binding/modifier/shape")
        values = [row[k] for k in ("minimum", "start", "endOffset")]
        if any(not re.fullmatch(r"[0-3]", v) for v in values):
            raise Blocked("unregistered JOIN source coordinate")
        if any(row[k] not in ("first", "last") for k in ("leftBoundary", "rightBoundary")):
            raise Blocked("unregistered JOIN boundary coordinate")
        output += [f"theorem source{i} : ({lean_list(values)} : List Nat) = [2, 1, 1] ∧",
                   f"    {text(row['leftBoundary'])} = \"last\" ∧ {text(row['rightBoundary'])} = \"first\" := by decide",
                   f"#print axioms source{i}"]
    seen = set()
    for i, row in enumerate(observed):
        key = tuple(row[k] for k in ("surface", "fixture", "tree"))
        if key not in expected or key in seen:
            raise Blocked("unexpected/duplicate guarded JOIN observation")
        seen.add(key)
        arities, relations = expected[key]
        if naturals(row["arities"]) != arities:
            raise Blocked("guarded JOIN fixture arities changed")
        formula = []
        if row["surface"] == "guard":
            if any(row[k] != "-" for k in ("relations", "output", "equivalent")):
                raise Blocked("unexpected guard payload")
        else:
            term = tree_term(row["tree"])
            output.append(f"def tree{i} : SourceTree Nat .join := {term}")
            formula.append(f"sourceLeaves tree{i} = {lean_list(range(len(arities)))}")
        if row["surface"] == "parser":
            if any(row[k] != "-" for k in ("relations", "output", "producer", "verifier")):
                raise Blocked("unexpected parser payload")
            # This Boolean is only a tested pipeline outcome, not parser refinement.
            formula.append(f"({boolean(row['equivalent'])} : Bool) = true")
        else:
            formula.extend(f"guard .JOIN {lean_list(arities)} = {boolean(row[k])}" for k in ("producer", "verifier"))
        if row["surface"] in ("finite", "counter"):
            if nested(row["relations"], 3) != relations:
                raise Blocked("finite JOIN fixture relation changed")
            actual = nested(row["output"], 2)
            if actual != sorted(actual) or len({tuple(v) for v in actual}) != len(actual):
                raise Blocked("noncanonical finite JOIN set")
            output.append(f"def relations{i} : List (List (List Nat)) := {relations}")
            formula.append(f"sameRelation (finiteEval relations{i} tree{i}) {actual} = true")
            first = tree_term(associations(list(range(len(arities))))[0])
            formula.append(f"sameRelation (finiteEval relations{i} tree{i}) (finiteEval relations{i} {first}) = "
                           + ("true" if row["surface"] == "finite" or row["tree"] == associations([0, 1, 2])[0] else "false"))
            formula.append(f"({boolean(row['equivalent'])} : Bool) = " + ("false" if row["surface"] == "counter" else "true"))
        proof = "by decide" if row["surface"] == "parser" else "by\n  simp only [guard_executable]\n  decide"
        output += [f"theorem observation{i} : " + " ∧\n    ".join(formula) + " := " + proof,
                   f"#print axioms observation{i}"]
    if seen != set(expected):
        raise Blocked("missing guarded JOIN observation")
    output.append("end ACGN.ThirdFive.JoinReplay")
    return "\n".join(output) + "\n", 1025


def generate(build, formal):
    source, count = program(rows(Path(build) / "guarded-join-chains.tsv", FIELDS),
                            rows(Path(build) / "guarded-join-source.tsv", SOURCE_FIELDS))
    return [("GuardedJoinChainReplay.lean", source, count)]


def negatives(build, formal):
    observed = rows(Path(build) / "guarded-join-chains.tsv", FIELDS)
    extracted = rows(Path(build) / "guarded-join-source.tsv", SOURCE_FIELDS)
    result = []

    def changed_observation(label, index, field, value):
        changed = [dict(row) for row in observed]
        changed[index][field] = value
        source = program(changed, extracted)[0]
        # Retain the failing theorem; omit unrelated later observations.
        source = source.split(f"#print axioms observation{index}\n", 1)[0] + "\nend ACGN.ThirdFive.JoinReplay\n"
        result.append((label, "RejectGuardedJoin.lean", source))

    unary = next(i for i, r in enumerate(observed) if r["fixture"] == "word-2,1,2")
    endpoint = next(i for i, r in enumerate(observed) if r["fixture"] == "word-1,2,1")
    finite = next(i for i, r in enumerate(observed) if r["surface"] == "finite" and r["output"] != "[]")
    counter = next(i for i, r in enumerate(observed) if r["surface"] == "counter")
    parser = next(i for i, r in enumerate(observed) if r["surface"] == "parser")
    for field in ("producer", "verifier"):
        changed_observation("join-unary-" + field, unary, field, "true")
        changed_observation("join-endpoint-" + field, endpoint, field, "false")
    changed_observation("join-wrong-relational-output", finite, "output", "[]")
    changed_observation("join-erased-counterexample", counter, "equivalent", "true")
    changed_observation("join-parser-inequality", parser, "equivalent", "false")
    for field, value in (("minimum", "1"), ("start", "0"), ("endOffset", "2"),
                         ("leftBoundary", "first"), ("rightBoundary", "last")):
        changed = [dict(row) for row in extracted]
        changed[0][field] = value
        source = program(observed, changed)[0].split("#print axioms source0\n", 1)[0] + "\nend ACGN.ThirdFive.JoinReplay\n"
        result.append(("join-source-" + field, "RejectGuardedJoin.lean", source))
    return result


def source_mutations():
    base = "src/is/fivefivefive/CanDis/theory/"
    verifier = "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java"
    specs = [
        ("join-producer-unary", base + "DependentChainTheory.java", "operandTypes.get(index)) < 2", "operandTypes.get(index)) < 1"),
        ("join-verifier-unary", verifier, "arity == null || arity < 2", "arity == null || arity < 1"),
        ("join-producer-start", base + "DependentChainTheory.java", "int index = 1; index + 1 < operandTypes.size()", "int index = 0; index + 1 < operandTypes.size()"),
        ("join-verifier-end", verifier, "index + 1 < operandTypes.size()", "index + 2 < operandTypes.size()"),
        ("join-producer-untyped", base + "DependentChainTheory.java", "!AlloyTypeBridge.isRelationFamily(checked)", "false"),
        ("join-producer-left-boundary", base + "DependentTypeDag.java", "leftProduct.get(leftProduct.size() - 1)", "leftProduct.get(0)"),
        ("join-producer-right-boundary", base + "DependentTypeDag.java", "rightProduct.get(0)", "rightProduct.get(rightProduct.size() - 1)"),
        ("join-verifier-left-boundary", verifier, "leftProduct.get(leftProduct.size() - 1)", "leftProduct.get(0)"),
        ("join-verifier-right-boundary", verifier, "rightProduct.get(0)", "rightProduct.get(rightProduct.size() - 1)"),
        ("join-producer-wrong-output", base + "DependentTypeDag.java", "product.addAll(rightProduct.subList(1, rightProduct.size()))", "product.addAll(rightProduct.subList(0, rightProduct.size()))"),
        ("join-producer-modifiers", base + "DependentChainTheory.java", "public static void requireSoundFlattening(", "public static synchronized void requireSoundFlattening("),
        ("join-verifier-modifiers", verifier, "private void requireSoundDependentFlattening(", "private synchronized void requireSoundDependentFlattening("),
    ]
    return [(*spec, "GuardedJoinChainExtractor") for spec in specs]
