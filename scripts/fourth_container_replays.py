"""Strict finite P2-20/P2-18 correspondence. Encoding is explicit tested TCB."""

from itertools import product
import json
import re

from next_obligation_replays import rows
from run_submission_container_closure import Blocked

FIELDS = "case surface family fixture tree inputs outputs fibers splices accepted indexMatches controls stage".split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
SOURCE_PINS = {
    "AlloyLawRegistry": "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b 9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041",
    "CertificateBundleWriter": "b30d10623694288f274a1fc26b6f92dc6b00ecc6264a58a54e5f01b3a35e7e46 0807ef1b7acdba3a1c72c6f339a02ede7d8beebc969500c4e66de3c5983b1d21",
    "CertificateVerifier": "1282022113db259138a3ca4293b580b72c674d34ec4c4d30e6cc5984afa053a5 68c116205f4cbdcbaa4b0ab023d279d86f7ab4aa00c3bc9db6a72e28a2760ee7",
    "ContainerApplicationTrace": "38cca38c37ca76f05b9c5d08f85adb69c65b2f0fed8719c891b05e3d2d52db8b fe99c389770466e820400d38e0ff8d81b86bf258d5cb994f8e66314966a45f1d",
    "ContainerConstructionCertificate": "55e8e7749ca80eb280bf17b7e93bdfe065e5f0701fbe957a91587dc1ea44922b de3134e92cead0a801f768498d3fe76d5ac8df926af55b61ad01023f3cb3de0d",
    "ContainerLawCertificate": "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2 d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e",
    "ContainerLawDeclaration": "4eca6d09ff3245d98b2711c865cb0dc61b0a82166d05348df11728722bc5618f 7b51b568114f1f32547156934bc46ae0029e9a65fd4054a172de0faa1096f298",
    "FlatApplication": "1e57064a889494f17cd75c659ee30d648a0a081befa802b8c25c6287025b2398 890ca35964d2a0cbe1586e0f8dec7ce881447fc868300679f5482a084905e0be",
    "FlatConstructionCertificate": "fddb9145978709c2881df347a902401fb1cc51ced2ac375aeb8e5d1413a97c9a 1de9f3d0ef542c59dc12a3bc379a5dd527330e103312940db1eca53e5a883aa2",
    "SemanticEvidenceVerifier": "bff2c3471c7fc123e9752ce4a70a964811382f52df9d6e5475b6854a10df03bc cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd",
    "StructuralKey": "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f",
    "TheoryAlloyAdapter": "ed25098cfc0ddb9fc0a2199d164a491b4134bd5a237a38134a1dac138606599e 9b5dc746645bd0410691e802548793866250a7b94bc72be99f722530f881eb7c",
    "TypedENode": "b70e73eaabd850acf69575e9e134f165dbc8a60dc1790e816b7aaa6d65e18cc1 ef393be4a64e937af202fa7ca18d9858f6aa0afe0faa6c113b8155223a767a2b",
}
BOUNDARIES = ("missingA", "wrongAHead", "wrongAType", "wrongAPath", "wrongASchema", "wrongAProfile",
              "wrongATheory", "testAuthority", "leafType", "leafContext", "empty", "nonflatPath",
              "wrongTarget", "mixedUnsealed")
WIRE_COMMON = ("fiber", "inputCount", "outputCount", "traceKey", "left", "right", "target")
WIRE_SPLICES = ("splicePath", "spliceOuter", "spliceNested", "splicePosition", "spliceSource", "missingSplice")
NAMESPACE = "ACGN.FourthFive.ContainerWitnessReplay"


def integer(value, maximum):
    if not isinstance(value, str) or not re.fullmatch(r"0|[1-9][0-9]*", value) or len(value) > 8 or int(value) > maximum:
        raise Blocked("noncanonical/out-of-domain container natural")
    return int(value)


def boolean(value):
    if value not in ("true", "false"):
        raise Blocked("noncanonical container Boolean")
    return value


def encode(value):
    return json.dumps(value, separators=(",", ":"))


def array(value, depth=1, maximum=100):
    try:
        result = json.loads(value)
    except (ValueError, TypeError, RecursionError) as error:
        raise Blocked("invalid container array") from error
    def valid(item, level):
        if level == 0:
            return type(item) is int and 0 <= item <= maximum
        return isinstance(item, list) and len(item) <= 16 and all(valid(x, level - 1) for x in item)
    if not valid(result, depth) or encode(result) != value:
        raise Blocked("noncanonical/out-of-domain container array")
    return result


def branches(word):
    if len(word) == 1:
        return [word[0]]
    return [[left, right] for split in range(1, len(word))
            for left in branches(word[:split]) for right in branches(word[split:])]


def leaf_order(tree):
    return [tree] if type(tree) is int else [x for child in tree for x in leaf_order(child)]


def splice_coordinates(tree, path=()):
    result = []
    for position, child in enumerate(tree):
        if isinstance(child, list):
            result.append([*path, position, len(tree), len(child), position])
            result.extend(splice_coordinates(child, (*path, position)))
    return result


def expected_keys():
    """Independent product/Catalan census, never derived from observation rows."""
    expected = {}
    for family in range(3):
        for length in range(1, 5):
            for ordinal, word in enumerate(product(range(3), repeat=length)):
                trees = [[word[0]]] if length == 1 else branches(word)
                for association, tree in enumerate(trees):
                    expected[("flat", family, f"{length}:{ordinal}:{association}")] = tree
    for carrier in range(3):
        for length in range(5):
            for ordinal, word in enumerate(product(range(2), repeat=length)):
                expected[("trace", carrier, f"{length}:{ordinal}")] = list(word)
    for family in range(3):
        for label in BOUNDARIES:
            expected[("boundary", family, label)] = None
    for family, carrier in product(range(2), range(3)):
        expected[("unit", family, str(carrier))] = None
    for family, name in product(range(2), ("Left", "Right", "Barrier")):
        expected[("pipeline", family, name)] = None
    for family in (0, 2, 3):
        for label in ("original", *WIRE_COMMON, *(("inputOrder",) if family == 3 else WIRE_SPLICES)):
            expected[("wire", family, label)] = None
    for family in (0, 2):
        for shape, tree in enumerate(branches((1, 0, 1, 0))):
            for label in ("original", "reverseSplices"):
                expected[("wireTree", family, f"{shape}:{label}")] = tree
    return expected


def source_census(extracted):
    if len(extracted) != len(SOURCE_PINS):
        raise Blocked("incomplete container source census")
    seen = set()
    for row in extracted:
        if set(row) != set(SOURCE_FIELDS):
            raise Blocked("malformed container source row")
        name = row["object"]
        if name not in SOURCE_PINS or name in seen:
            raise Blocked("extra/duplicate container source object")
        seen.add(name)
        owner = ("org.acgn.cert." if name == "SemanticEvidenceVerifier" else "is.fivefivefive.CanDis.theory.") + name
        if row["owner"] != owner or row["shapeSha256"] + " " + row["bindingsSha256"] != SOURCE_PINS[name]:
            raise Blocked("unbound container source signature/body/bindings")
    if seen != set(SOURCE_PINS):
        raise Blocked("missing container source object")


def operator(family):
    return '(OperatorIndex.mk "' + ("ALLOY/IPLUS" if family == 2 else "ALLOY/AND") + '" ' + str(family == 2 and 1 or 0) \
        + ' [0] "' + ("bag-int-K+" if family == 2 else "set-bool-K+") + '" "' \
        + ("FORBID" if family == 0 else "MODULAR") + '" "fixed-registry-v3" true true)'


def lean_tree(tree, family):
    if type(tree) is int:
        return f"(.leaf {1 if family == 2 else 0} {tree})"
    return f"(.node {operator(family)} [" + ", ".join(lean_tree(child, family) for child in tree) + "])"


def expected_outputs(carrier, inputs):
    return inputs if carrier == 0 else sorted(inputs) if carrier == 1 else sorted(set(inputs))


def program(observed, extracted):
    source_census(extracted)
    expected, seen = expected_keys(), set()
    if len(observed) != len(expected) or len(expected) != 1617:
        raise Blocked("incomplete container observation census")
    checks = []
    for i, row in enumerate(observed):
        if set(row) != set(FIELDS) or integer(row["case"], 1616) != i:
            raise Blocked("container schema/case identity/order changed")
        family = integer(row["family"], 3)
        key = row["surface"], family, row["fixture"]
        if key not in expected or key in seen:
            raise Blocked("extra/duplicate/unregistered container observation")
        seen.add(key)
        accepted, matches = boolean(row["accepted"]), boolean(row["indexMatches"])
        controls = integer(row["controls"], 100)
        inputs, outputs = array(row["inputs"], maximum=2), array(row["outputs"], maximum=2)
        fibers, splices = array(row["fibers"], depth=2), array(row["splices"], depth=2)
        surface, _, label = key
        if surface in ("flat", "trace", "wireTree"):
            recursive = surface != "trace"
            tree = expected[key] if recursive else []
            required_inputs = leaf_order(tree) if recursive else expected[key]
            if row["tree"] != encode(tree) or inputs != required_inputs:
                raise Blocked("container input request/tree differs from independent census")
            carrier = (1 if family == 2 else 2) if recursive else family
            name = ("seq", "bag", "set")[carrier]
            required_outputs = expected_outputs(carrier, inputs)
            required_splices = splice_coordinates(tree) if recursive else []
            required_controls = 2 + len(inputs) + len(required_outputs)
            if surface == "flat":
                required_controls += (18 if family == 2 else 27) + 2 + sum(len(s) + 1 for s in required_splices)
            stage = "LOCAL_VERIFIED" if surface == "flat" else "STRUCTURAL_ONLY"
            positive = surface != "wireTree" or label.endswith(":original")
            if surface == "wireTree":
                required_controls = 1
                stage = "VERIFIED:NONE" if positive else "REJECTED:THEORY_MISMATCH"
                if not positive and splices != list(reversed(required_splices)):
                    raise Blocked("container reverseSplices differs from the exact registered reversal")
            if controls != required_controls or row["stage"] != stage:
                raise Blocked("container stage/field control census changed")
            check = f"(({accepted} == {str(positive).lower()}) && {matches} && (outputs .{name} {encode(inputs)} == {encode(outputs)})"
            check += f" && (fibers .{name} {encode(inputs)} == {encode(fibers)})"
            if recursive:
                modeled_tree = lean_tree(tree, family)
                check += f' && (spliceCoordinates (producerSplices (fun _ => "source") [] {modeled_tree}) == {encode(required_splices)})'
                check += f' && (acceptsSpliceLedger (fun _ => "source") {modeled_tree} {encode(splices)} == {accepted})'
                if surface == "wireTree" and not positive:
                    check += f' && ((spliceCoordinates (producerSplices (fun _ => "source") [] {modeled_tree})).reverse == {encode(splices)})'
                check += f" && (flatten {operator(family)} {lean_tree(tree, family)} == some {encode(inputs)})"
            else:
                check += f" && (([] : List (List Nat)) == {encode(splices)})"
            checks.append(check + ")")
        else:
            if any(row[k] != "[]" for k in ("tree", "inputs", "outputs", "fibers", "splices")) or controls != 1:
                raise Blocked("noncanonical container boundary observation")
            positive = surface == "pipeline" or (surface == "wire" and label == "original")
            stage = ("ADAPTER_VERIFIED" if surface == "pipeline" else "LOCAL_REJECTED" if surface == "boundary"
                     else "REGISTRY_REJECTED" if surface == "unit" else "VERIFIED:NONE" if positive
                     else "REJECTED:INVALID_RECORD_SHAPE" if label in ("inputCount", "outputCount", "missingSplice")
                     else "REJECTED:THEORY_MISMATCH")
            if row["stage"] != stage:
                raise Blocked("container boundary verifier outcome changed: " + str(key) + " " + row["stage"])
            check = f"({matches} && ({accepted} == {str(positive).lower()})"
            if surface == "unit":
                check += f' && (productionUnit "{label}" 0 == {accepted})'
            checks.append(check + ")")
    if seen != set(expected):
        raise Blocked("omitted container observations")
    return render(checks), (len(checks) + 15) // 16


def render(checks):
    lines = ["import ContainerWitnessTransitions", "open ACGN.FourthFive.ContainerWitnessTransitions",
             "set_option maxRecDepth 4096", "set_option maxHeartbeats 2000000", "namespace " + NAMESPACE]
    for i in range(0, len(checks), 16):
        lines += [f"theorem containerBlock{i // 16} : ([" + ",\n ".join(checks[i:i + 16])
                  + "] : List Bool).all id = true := by decide", f"#print axioms containerBlock{i // 16}"]
    return "\n".join(lines + ["end " + NAMESPACE, ""])


def generate(build, formal):
    source, count = program(rows(build / "container-witness.tsv", FIELDS),
                            rows(build / "container-witness-source.tsv", SOURCE_FIELDS))
    return [("ContainerWitnessReplay.lean", source, count)]


def negatives(build, formal):
    observed = rows(build / "container-witness.tsv", FIELDS)
    extracted = rows(build / "container-witness-source.tsv", SOURCE_FIELDS)
    program(observed, extracted)
    controls = []
    for label, surface, field, value in (("accepted", "flat", "accepted", "false"),
            ("index", "flat", "indexMatches", "false"), ("order", "flat", "outputs", "[2]"),
            ("permutation", "trace", "fibers", "[[99]]"), ("splice", "flat", "splices", "[[99]]"),
            ("unit-authority", "unit", "accepted", "true"), ("missing-A", "boundary", "accepted", "true"),
            ("wire-acceptance", "wire", "accepted", "false"),
            ("recursive-ledger", "wireTree", "splices", "[[1,1,2,2,1],[1,2,2,1]]")):
        index = next(i for i, row in enumerate(observed) if row["surface"] == surface)
        changed = [dict(row) for row in observed]; changed[index][field] = value
        source, _ = program(changed, extracted)
        # Keep exactly the failing block and its audited namespace, with no loader substitutions.
        block = index // 16
        source = source.split(f"theorem containerBlock{block + 1} :", 1)[0]
        if not source.rstrip().endswith("end " + NAMESPACE):
            source += "\nend " + NAMESPACE + "\n"
        controls.append(("container-" + label, "RejectContainerWitness.lean", source))
    return controls


def source_mutations():
    base = "src/is/fivefivefive/CanDis/theory/"
    return [
        ("law-parameter", base + "ContainerLawCertificate.java", 'Objects.requireNonNull(lawParameter, "lawParameter")))',
         'StructuralKey.leaf("changed-law-parameter", "omitted")))', "ContainerWitnessTransitionsExtractor"),
        ("trace-fiber", base + "ContainerApplicationTrace.java", "origins.add(Integer.toString(input));",
         'origins.add("0");', "ContainerWitnessTransitionsExtractor"),
        ("splice-position", base + "FlatConstructionCertificate.java", "coordinates.add(Integer.toString(position));",
         'coordinates.add("0");', "ContainerWitnessTransitionsExtractor"),
        ("same-head", base + "TheoryAlloyAdapter.java", "if (source.sameFlatOperatorInstance(child)",
         "if (true", "ContainerWitnessTransitionsExtractor"),
        ("resolved-dispatch", base + "StructuralKey.java", "public final class StructuralKey implements Comparable<StructuralKey>",
         "public class StructuralKey implements Comparable<StructuralKey>", "ContainerWitnessTransitionsExtractor"),
        ("verifier-fiber", "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java",
         "if (!fiber.equals(normalized.fibers().get(index)))", "if (false)", "ContainerWitnessTransitionsExtractor"),
        ("verifier-postorder", "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java",
         "splices.add(splicePosition, new FlatSplice(", "splices.add(new FlatSplice(", "ContainerWitnessTransitionsExtractor"),
    ]
