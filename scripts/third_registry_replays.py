"""P2-19 finite registry observations. The encoder is a declared tested TCB item."""

import base64
import binascii
from itertools import product
import json
import re

from next_obligation_replays import rows
from run_submission_container_closure import Blocked

FIELDS = ("case group profile op pair carrier arity path identity bitwidth modular temporal rewrite signature "
          "law issued indexMatches accepted fieldControls stage").split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
OBJECTS = {"AlloyLawRegistry", "ContainerLawCertificate", "SemanticProfile", "CertificateOrigin"}
OPS = ["and", "or", "plus", "intersect", "iplus", "mul", "equals", "notEquals", "iff", "disjoint", "other"]
JAVA_OPS = ["AND", "OR", "PLUS", "INTERSECT", "IPLUS", "MUL", "EQUALS", "NOT_EQUALS", "IFF", "DISJOINT", "CALL"]
PAIRS = [(".bool", ".bool"), (".int", ".int"), ("(.relation 0)", "(.relation 0)"),
         ("(.relation 0)", "(.relation 1)"), ("(.other 0)", "(.other 0)"),
         (".bool", ".int"), (".bool", "(.relation 0)"), (".bool", None), (".bool", "(.other 0)")]
ARITIES = ["(.atLeast 1)", "(.finite [2])", "(.atLeast 0)", "(.finite [1, 2])"]


def integer(text, limit):
    if not re.fullmatch(r"0|[1-9][0-9]*", text) or int(text) > limit:
        raise Blocked("noncanonical or out-of-domain registry integer")
    return int(text)


def boolean(value):
    if value not in ("true", "false"):
        raise Blocked("noncanonical registry Boolean")
    return value


def decoded(value):
    try:
        raw = base64.b64decode(value, validate=True)
        text = raw.decode("utf-8")
    except (ValueError, UnicodeError, binascii.Error) as error:
        raise Blocked("invalid registry profile string") from error
    if base64.b64encode(raw).decode("ascii") != value:
        raise Blocked("noncanonical registry profile string")
    return json.dumps(text, ensure_ascii=False)


def request(row):
    op = integer(row["op"], 10)
    result, element = PAIRS[integer(row["pair"], 8)]
    carrier = ["seq", "bag", "set"][integer(row["carrier"], 2)]
    arity = ARITIES[integer(row["arity"], 3)]
    law = ["assoc", "comm", "idem", "unit"][integer(row["law"], 3)]
    if row["profile"] not in ("custom", "compatibility", "source"):
        raise Blocked("unknown profile-construction case")
    identity = ("ALLOY/" if boolean(row["identity"]) == "true" else "OTHER/") + JAVA_OPS[op]
    profile = "(Profile.mk (ProfileKey.mk " + str(integer(row["bitwidth"], 30)) + " " + boolean(row["modular"])
    profile += " " + " ".join(decoded(row[key]) for key in ("temporal", "rewrite", "signature"))
    profile += ") ." + row["profile"] + ")"
    schema = f"(Schema.mk .{carrier} " + ("none" if element is None else "(some " + element + ")") + " " + arity + ")"
    return f"(Request.mk {profile} .{OPS[op]} {json.dumps(identity)} {result} [{integer(row['path'], 1)}] {schema} .{law})"


def expected_keys():
    result = set()
    for modular, op, pair, carrier, arity, law in product(("false", "true"), range(11), range(9), range(3), range(4), range(4)):
        result.add(("grid", "compatibility", modular, op, pair, carrier, arity, 0, "true", 4, law))
    for modular in ("false", "true"):
        result.update({("boundary", "custom", modular, 0, 0, 2, 0, 0, "true", 4, 0),
                       ("boundary", "compatibility", modular, 0, 0, 2, 0, 1, "true", 4, 0),
                       ("boundary", "compatibility", modular, 0, 0, 2, 0, 0, "false", 4, 0)})
        for width in (3, 4, 6):
            result.add(("source", "source", modular, 0, 0, 2, 0, 0, "true", width, 0))
    return result


def program(observed, extracted):
    if len(extracted) != 4 or {row["object"] for row in extracted} != OBJECTS:
        raise Blocked("incomplete registry source census")
    for row in extracted:
        if row["owner"] != "is.fivefivefive.CanDis.theory." + row["object"] or not all(
                re.fullmatch(r"[0-9a-f]{64}", row[key]) for key in ("shapeSha256", "bindingsSha256")):
            raise Blocked("unbound registry source object")
    if len(observed) != 9516:
        raise Blocked("incomplete registry request census")
    expected, seen = expected_keys(), set()
    checks = []
    for i, row in enumerate(observed):
        if integer(row["case"], 9515) != i:
            raise Blocked("registry case identity/order changed")
        key = (row["group"], row["profile"], boolean(row["modular"]), integer(row["op"], 10),
               integer(row["pair"], 8), integer(row["carrier"], 2), integer(row["arity"], 3),
               integer(row["path"], 1), boolean(row["identity"]), integer(row["bitwidth"], 30), integer(row["law"], 3))
        if key not in expected or key in seen:
            raise Blocked("unregistered/duplicate registry request")
        seen.add(key)
        issued, accepted, matches = (boolean(row[k]) for k in ("issued", "accepted", "indexMatches"))
        controls = integer(row["fieldControls"], 9)
        stage = "SCHEMA_REJECTED" if key[5:7] == (2, 1) else "ISSUED" if issued == "true" else "REGISTRY_REJECTED"
        if row["stage"] != stage or controls != (9 if issued == "true" else 0):
            raise Blocked("registry execution stage/control count changed")
        # The request and observed outcome enter independently; the Lean kernel
        # decides the model admission result rather than trusting the Java flag.
        checks.append(f"(admitted {request(row)} == {issued} && ({issued} == {accepted}) && ({issued} == {matches}))")
    if seen != expected:
        raise Blocked("missing registry request")
    output = ["import RegistryAdmission", "open ACGN.ThirdFive.RegistryAdmission", "set_option maxRecDepth 2048",
              "set_option maxHeartbeats 2000000", "namespace ACGN.ThirdFive.RegistryReplay"]
    count = 0
    for start in range(0, len(checks), 32):
        output += [f"theorem registryBlock{count} : ([" + ",\n  ".join(checks[start:start + 32])
                   + "] : List Bool).all id = true := by decide", f"#print axioms registryBlock{count}"]
        count += 1
    output.append("end ACGN.ThirdFive.RegistryReplay")
    return "\n".join(output) + "\n", count


def generate(build, formal):
    code, count = program(rows(build / "registry-admission.tsv", FIELDS),
                          rows(build / "registry-admission-source.tsv", SOURCE_FIELDS))
    return [("RegistryAdmissionReplay.lean", code, count)]


def negatives(build, formal):
    observed = rows(build / "registry-admission.tsv", FIELDS)
    extracted = rows(build / "registry-admission-source.tsv", SOURCE_FIELDS)
    positive = next(i for i, row in enumerate(observed) if row["issued"] == "true")
    result = []
    for field in ("accepted", "indexMatches"):
        changed = [dict(row) for row in observed]
        changed[positive][field] = "false"
        code = program(changed, extracted)[0]
        result.append(("registry-" + field, "RejectRegistry.lean", code.split(f"theorem registryBlock{positive // 32 + 1} :", 1)[0]
                       + "\nend ACGN.ThirdFive.RegistryReplay\n"))
    changed = [dict(row) for row in observed]
    false_case = next(i for i, row in enumerate(observed) if row["law"] == "3" and row["stage"] == "REGISTRY_REJECTED")
    changed[false_case].update(issued="true", accepted="true", indexMatches="true", fieldControls="9", stage="ISSUED")
    result.append(("registry-invented-unit", "RejectRegistry.lean",
                   program(changed, extracted)[0].split(f"theorem registryBlock{false_case // 32 + 1} :", 1)[0]
                   + "\nend ACGN.ThirdFive.RegistryReplay\n"))
    return result


def source_mutations():
    base = "src/is/fivefivefive/CanDis/theory/"
    return [
        ("registry-omitted-parameter", base + "AlloyLawRegistry.java", "certificate.lawParameter().equals(expectedParameter)",
         "true", "RegistryAdmissionExtractor"),
        ("registry-omitted-profile-authority", base + "SemanticProfile.java",
         "return authority == Authority.FIXED_COMPATIBILITY\n                || isAuthorizedAlloyProfile();",
         "return true;", "RegistryAdmissionExtractor"),
        ("registry-shifted-path", base + "AlloyLawRegistry.java", "if (!PortPath.at(0).equals(path))",
         "if (!PortPath.at(1).equals(path))", "RegistryAdmissionExtractor"),
        ("registry-omitted-identity", base + "AlloyLawRegistry.java", "if (!expectedIdentity.equals(operatorIdentity))",
         "if (false)", "RegistryAdmissionExtractor"),
    ]
