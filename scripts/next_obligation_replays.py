"""Strict observation encodings for the v2.13 finite correspondence package.

The Lean kernel checks the emitted propositions. This encoder and its source
extractors remain explicit trusted, tested correspondence components.
"""

import csv
from itertools import product
import json
from pathlib import Path
import re

from run_submission_container_closure import Blocked


def rows(path, fields):
    with Path(path).open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != fields:
            raise Blocked("unexpected observation schema: " + str(path))
        result = list(reader)
    if not result:
        raise Blocked("empty observation table: " + str(path))
    for row in result:
        if set(row) != set(fields) or any(value is None or any(ord(c) < 32 for c in value)
                                          for value in row.values()):
            raise Blocked("malformed observation: " + str(path))
    return result


def text(value):
    return json.dumps(value, ensure_ascii=False)


def natural(value):
    if not re.fullmatch(r"0|[1-9][0-9]{0,18}", value):
        raise Blocked("noncanonical natural in observation")
    return value


def naturals(value):
    return [] if value == "" else [int(natural(item)) for item in value.split(",")]


def lean_list(values):
    return "[" + ", ".join(str(value) for value in values) + "]"


def tree_program(value, kind):
    position = 0
    def parse():
        nonlocal position
        if position >= len(value):
            raise Blocked("truncated chain tree")
        token = value[position]
        position += 1
        if token in "012":
            return "(.leaf " + token + ")", [int(token)]
        if token != "(":
            raise Blocked("unregistered chain leaf")
        left, lw = parse()
        if position >= len(value) or value[position] != ",":
            raise Blocked("missing chain separator")
        position += 1
        right, rw = parse()
        if position >= len(value) or value[position] != ")":
            raise Blocked("missing chain close")
        position += 1
        return "(.app ." + kind + " " + left + " " + right + ")", lw + rw
    term, leaves = parse()
    if position != len(value):
        raise Blocked("trailing chain input")
    return term, leaves


def associations(word):
    if len(word) == 1:
        return [str(word[0])]
    return ["(" + left + "," + right + ")" for split in range(1, len(word))
            for left in associations(word[:split]) for right in associations(word[split:])]


CHAIN_FIELDS = "surface profile kind fixture tree source output length counts carrier replay".split()
CHAIN_SOURCE_FIELDS = "object owner method arity shapeSha256 bindingsSha256 model".split()
CHAIN_MODELS = {
    **dict.fromkeys(["source-application", "source-leaf", "source-left", "source-right", "source-leaves",
                    "wire-source", "adapter-application", "adapter-barrier"], "sourceLeaves"),
    **dict.fromkeys(["source-collector", "source-leaf-inputs"], "collect"),
    **dict.fromkeys(["construction", "construction-default", "schema-factory", "schema-copy", "schema-kind",
                    "schema-quotient", "schema-dependent", "schema-position", "sequence-copy", "sequence-elements",
                    "wire-port", "wire-container", "wire-normalization"], "construct"),
    **dict.fromkeys(["producer-certificate", "wire-certificate", "replay-certificate", "replay-schema"], "accepts"),
    "replay-source": "replayLeaves",
}


def chain_program(observed, extracted):
    if len(extracted) != len(CHAIN_MODELS) or {row["object"] for row in extracted} != set(CHAIN_MODELS):
        raise Blocked("incomplete chain source object census")
    for row in extracted:
        if row["model"] != CHAIN_MODELS[row["object"]] or not all(re.fullmatch(r"[0-9a-f]{64}", row[key])
                for key in ("shapeSha256", "bindingsSha256")):
            raise Blocked("unregistered chain correspondence")
        natural(row["arity"])
    expected = set()
    for profile, kind in product(("FORBID", "MODULAR"), ("JOIN", "ARROW")):
        for length in (2, 3, 4):
            for ordinal, word in enumerate(product(range(3), repeat=length)):
                for shape in associations(word):
                    expected.add(("typed", profile, kind, f"{length}:{ordinal}", shape))
        for fixture in ("Left", "Right", "Swapped"):
            expected.add(("pipeline", profile, kind, fixture))
            expected.add(("certificate", profile, kind, fixture))
        expected.add(("barrier", profile, kind, "Barrier"))
    if len(observed) != 1900:
        raise Blocked("incomplete chain observation census")
    seen = set()
    output = ["import DependentChainSequence", "open ACGN.Section3.DependentChainSequence"]
    for index, row in enumerate(observed):
        key = tuple(row[name] for name in ("surface", "profile", "kind", "fixture"))
        if row["surface"] == "typed":
            key += (row["tree"],)
        if key not in expected or key in seen:
            raise Blocked("unexpected/duplicate chain row")
        seen.add(key)
        if row["replay"] != ("FULL_VERIFIED" if row["surface"] == "certificate" else "LOCAL_VERIFIED"):
            raise Blocked("chain replay not verified at declared boundary")
        kind = row["kind"].lower()
        tree, _ = tree_program(row["tree"], kind)
        if row["carrier"] not in ("SEQ", "BAG", "SET"):
            raise Blocked("unknown chain carrier")
        source, actual, counts = (naturals(row[key]) for key in ("source", "output", "counts"))
        if len(counts) != 3:
            raise Blocked("chain count census changed")
        output += [f"def tree{index} : SourceTree Nat .{kind} := {tree}",
                   f"def target{index} : Target Nat := ⟨.{row['carrier'].lower()}, {lean_list(actual)}⟩",
                   f"theorem chain{index} : accepts tree{index} target{index} = true ∧",
                   f"    sourceLeaves tree{index} = {lean_list(source)} ∧",
                   f"    target{index}.elements.length = {natural(row['length'])} ∧",
                   f"    [target{index}.elements.count 0, target{index}.elements.count 1,",
                   f"      target{index}.elements.count 2] = {lean_list(counts)} := by decide",
                   f"#print axioms chain{index}"]
    if seen != expected:
        raise Blocked("missing chain observation")
    return "\n".join(output) + "\n", len(observed)


CALL_FIELDS = ("schema fixture parser_path occurrence owner visit callee kind arity parser_payloads "
               "masg_payloads ir_payloads cert_payloads positions edge_owners edge_visits edge_targets "
               "cert_path cert_operator observation_sha256 target_callee target_kind target_arity").split()
CALL_SOURCE_FIELDS = "control owner method start endOffset step".split()
CALL_CONTROLS = {
    "call-early-return": ("is.fivefivefive.CanDis.ir.IRAgent", "downlinksFor", (0, 0, 0)),
    "ir-argument-validation": ("is.fivefivefive.CanDis.ir.IRAgent", "validateCallDownlinks", (1, 1, 1)),
    "masg-argument-validation": ("is.fivefivefive.ACGN.visitor.MASGVisitor", "validateCompletedCallVisit", (2, 0, 1)),
}
CALL_ARITIES = (0, 1, 2, 3, 5, 8, 16)


def call_program(observed, extracted):
    if len(extracted) != 3 or {row["control"] for row in extracted} != set(CALL_CONTROLS):
        raise Blocked("incomplete CALL source census")
    output = ["import OrderedCallValidation", "open ACGN.NextFive.OrderedCallValidation"]
    for index, row in enumerate(extracted):
        owner, method, bounds = CALL_CONTROLS[row["control"]]
        if row["owner"] != owner or row["method"] != method:
            raise Blocked("foreign CALL source control")
        actual = [natural(row[name]) for name in ("start", "endOffset", "step")]
        output += [f"theorem control{index} : ({lean_list(actual)} : List Nat) = {lean_list(bounds)} := by decide",
                   f"#print axioms control{index}"]
    if len(observed) != 56:
        raise Blocked("incomplete CALL occurrence census")
    def key(row, prefix):
        if row[prefix + "kind"] not in ("call/formula", "call/expression"):
            raise Blocked("unknown CALL kind")
        return (row[prefix + "callee"], row[prefix + "kind"], natural(row[prefix + "arity"]))
    # Both sets participate: a wrong target gets its own token, never the source's.
    keys = {k: index for index, k in enumerate(sorted({key(row, prefix)
            for row in observed for prefix in ("", "target_")}))}
    expected = {(f"arity-{arity}", str(i)) for arity in CALL_ARITIES for i in range(8)}
    seen, paths = set(), set()
    for index, row in enumerate(observed):
        ident = (row["fixture"], natural(row["occurrence"]))
        path = (row["fixture"], row["parser_path"])
        if row["schema"] != "ordered-call-v1" or ident not in expected or ident in seen or path in paths:
            raise Blocked("unknown/duplicate CALL occurrence")
        if row["fixture"] != "arity-" + natural(row["arity"]):
            raise Blocked("CALL arity fixture mismatch")
        if not re.fullmatch(r"[0-9a-f]{64}", row["observation_sha256"]):
            raise Blocked("invalid observation hash")
        seen.add(ident)
        paths.add(path)
        positions, owners, visits = (naturals(row[name]) for name in ("positions", "edge_owners", "edge_visits"))
        targets = row["edge_targets"].split(",")
        if not len(positions) == len(owners) == len(visits) == len(targets) == int(row["arity"]) + 2:
            raise Blocked("CALL edge-column mismatch")
        if naturals(row["masg_payloads"]) != [int(natural(value)) for value in targets[1:-1]]:
            raise Blocked("MASG payload tokens differ from observed edges")
        edges = []
        for position, owner, visit, target in zip(positions, owners, visits, targets):
            if target == "callee":
                term = "(.callee " + str(keys[key(row, "target_")]) + ")"
            elif target == "end":
                term = ".terminator"
            else:
                term = "(.argument " + natural(target) + ")"
            edges.append(f"(Edge.mk {owner} {visit} {position} {term})")
        capture = "(Capture.mk " + " ".join([natural(row["owner"]), natural(row["visit"]),
                    str(keys[key(row, "")]), natural(row["arity"])]) + ")"
        arguments = [lean_list(naturals(row[name])) for name in ("parser_payloads", "ir_payloads", "cert_payloads")]
        output += [f"def call{index} : Observation := Observation.mk {capture} {lean_list(edges)} "
                   + " ".join(arguments),
                   f"theorem call_replay{index} : checkObservation call{index} = true := by decide",
                   f"#print axioms call_replay{index}"]
    if seen != expected:
        raise Blocked("missing CALL occurrence")
    return "\n".join(output) + "\n", 3 + len(observed)


FLAT_FIELDS = ["case", "kind", "element", "output", "expected"]
FLAT_SOURCE_FIELDS = ["elementSubstitution", "resultSubstitution", "checkedMethods"]


def flat_program(observations, source):
    if len(source) != 1 or source[0]["checkedMethods"] != "10":
        raise Blocked("incomplete flat source census")
    if len(observations) != 675:
        raise Blocked("incomplete flat instance census")
    output = ["import FlatTypeSubstitution", "open ACGN.NextFive.FlatTypeSubstitution"]
    sites = source[0]
    output += ["def sites : SubstitutionSites := ⟨" + text(sites["elementSubstitution"]) + ", "
               + text(sites["resultSubstitution"]) + "⟩",
               "theorem same_sites : sites.elementField = sites.resultField := by decide",
               "theorem source_type_preservation {T U : Type} (env : String -> T -> U)",
               "    (s : Schema T) (r : T) (h : element? s = some (.one r)) :",
               "    element? (substitute (env sites.elementField) s) =",
               "      some (.one (env sites.resultField r)) :=",
               "  extracted_shared_substitution sites same_sites env s r h",
               "#print axioms same_sites", "#print axioms source_type_preservation"]
    for index, row in enumerate(observations):
        if natural(row["case"]) != str(index) or row["kind"] != ["SEQ", "BAG", "SET"][index // 225]:
            raise Blocked("flat row identity/kind census changed")
        output.extend(["theorem flat" + str(index) + " : replay (Observation.mk "
                       + " ".join(text(row[name]) for name in ("element", "output", "expected"))
                       + ") = true := by decide", "#print axioms flat" + str(index)])
    return "\n".join(output) + "\n", 2 + len(observations)


def generate(build, formal):
    source, count = flat_program(rows(build / "flat-types.tsv", FLAT_FIELDS),
                                 rows(build / "flat-type-source.tsv", FLAT_SOURCE_FIELDS))
    chain, chain_count = chain_program(rows(build / "chain-sequences.tsv", CHAIN_FIELDS),
                                       rows(build / "chain-sequence-source.tsv", CHAIN_SOURCE_FIELDS))
    calls, call_count = call_program(rows(build / "ordered-calls.tsv", CALL_FIELDS),
                                     rows(build / "call-validation-source.tsv", CALL_SOURCE_FIELDS))
    return [("FlatTypeReplay.lean", source, count), ("ChainSequenceReplay.lean", chain, chain_count),
            ("CallValidationReplay.lean", calls, call_count)]


def negatives(build, formal):
    observed = rows(build / "flat-types.tsv", FLAT_FIELDS)
    extracted = rows(build / "flat-type-source.tsv", FLAT_SOURCE_FIELDS)
    result = []
    for field in ("element", "output"):
        changed = [dict(row) for row in observed]
        changed[0][field] = "different-exact-type"
        result.append(("flat-wrong-" + field, "RejectFlat.lean",
                       flat_program(changed, extracted)[0].split("theorem flat1 :", 1)[0]))
    changed_source = [dict(extracted[0], resultSubstitution="foreignInstantiation")]
    result.append(("flat-wrong-substitution", "RejectFlat.lean",
                   flat_program(observed, changed_source)[0].split("theorem flat1 :", 1)[0]))
    chains = rows(build / "chain-sequences.tsv", CHAIN_FIELDS)
    chain_source = rows(build / "chain-sequence-source.tsv", CHAIN_SOURCE_FIELDS)
    for field, value in (("carrier", "BAG"), ("output", "0"), ("output", "1,0")):
        changed = [dict(row) for row in chains]
        changed[0][field] = value
        label = "chain-" + field + "-" + value.replace(",", "-")
        result.append((label, "RejectChain.lean", chain_program(changed, chain_source)[0].split("def tree1 :", 1)[0]))
    changed = [dict(row) for row in chains]
    if changed[1]["source"] != "0,1":
        raise Blocked("distinct ordered negative-control fixture changed")
    changed[1]["output"] = "1,0"
    result.append(("chain-distinct-swap", "RejectChain.lean",
                   chain_program(changed, chain_source)[0].split("def tree2 :", 1)[0]))
    calls = rows(build / "ordered-calls.tsv", CALL_FIELDS)
    call_source = rows(build / "call-validation-source.tsv", CALL_SOURCE_FIELDS)
    for field, value in (("target_callee", "foreign/callee"), ("edge_owners", "99999,99999"),
                         ("edge_targets", "callee,1"), ("cert_payloads", "1")):
        changed = [dict(row) for row in calls]
        changed[0][field] = value
        result.append(("call-" + field, "RejectCall.lean",
                       call_program(changed, call_source)[0].split("def call1 :", 1)[0]))
    index = next(i for i, row in enumerate(calls) if row["parser_payloads"] == "1,2")
    changed = [dict(row) for row in calls]
    changed[index]["cert_payloads"] = "2,1"
    result.append(("call-distinct-swap", "RejectCall.lean",
                   call_program(changed, call_source)[0].split(f"def call{index + 1} :", 1)[0]))
    return result


def source_mutations():
    base = "src/is/fivefivefive/CanDis/theory/"
    return [
        ("flat-omitted-type-guard", base + "OperatorDeclaration.java",
         "|| !((OnePortSchema) element).type().equals(outputType)", "",
         "FlatTypeSubstitutionExtractor"),
        ("flat-wrong-map", base + "InstantiatedOperator.java",
         "declaration.outputType().substitute(this.typeArguments)",
         "declaration.outputType().substitute(Map.of())", "FlatTypeSubstitutionExtractor"),
        ("flat-unsubstituted-one", base + "OnePortSchema.java",
         "new OnePortSchema(type.substitute(substitution))", "new OnePortSchema(type)",
         "FlatTypeSubstitutionExtractor"),
        ("flat-shared-instance-state", base + "InstantiatedOperator.java",
         "private final List<PortSchema> portSchemas;", "private static List<PortSchema> portSchemas;",
         "FlatTypeSubstitutionExtractor"),
        ("call-omitted-early-return", "src/is/fivefivefive/CanDis/ir/IRAgent.java",
         "return validateCallDownlinks(node, tov, downlinks);", "validateCallDownlinks(node, tov, downlinks);",
         "CallValidationExtractor"),
        ("chain-shared-instance-state", base + "InstantiatedOperator.java",
         "private final List<PortSchema> portSchemas;", "private static List<PortSchema> portSchemas;",
         "ChainSequenceExtractor"),
        ("chain-reordered-source", base + "DependentChainApplication.java",
         "ordered.addAll(left.leaves());\n        ordered.addAll(right.leaves());",
         "ordered.addAll(right.leaves());\n        ordered.addAll(left.leaves());", "ChainSequenceExtractor"),
        ("chain-deduplicated-source", base + "DependentChainApplication.java",
         "this.leaves = Collections.unmodifiableList(ordered);",
         "this.leaves = Collections.unmodifiableList(ordered.stream().distinct().toList());", "ChainSequenceExtractor"),
        ("call-omitted-last-argument", "src/is/fivefivefive/CanDis/ir/IRAgent.java",
         "int index = 1; index < expected - 1; index++", "int index = 1; index < expected - 2; index++",
         "CallValidationExtractor"),
    ]
