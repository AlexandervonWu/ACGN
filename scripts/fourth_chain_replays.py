"""Finite A2-07/A2-11 replay. No authority is inferred from observed agreement.

Fixture types, source associations, exact DAG products, complete fold matrices,
certificate endpoints, and mutation coordinates are enumerated here independently
of Java output. All runtime verifier calls in Java use public APIs only.
"""

import base64
import binascii
import csv
import hashlib
import io
import json
from pathlib import Path
import re

from run_submission_container_closure import Blocked

FIELDS = "surface fixture coordinate producer writer verifier status".split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
VERSION = "alloy-dependent-chain-theory-v11"
DIGEST = "3387749f582a53216caa599105386b710e9e5e748110c59e1b3bf3401ac03cf8"
NAMESPACE = "ACGN.FourthFive.DependentChainWitnessReplay"
FIXTURES = ("exact", "primitive", "int", "univ", "empty", "repeat")
PINS = {
    "CertificateBundleWriter": "94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6 a8dc4e4157b854b38e8d98da97e6bf614c72ac4ffc7f08ef4fd39dc2bce4126d",
    "DependentBoundaryCorrespondence": "201590a925c01cd5a6e9f51dd7e9b9a497a7dcea5efbf499780da8dba263e67e c9763fd525bc78c86203a875e0e5063955dbe396d34dd30249b464cdd23da3da",
    "DependentChainApplication": "db81a97d3a9553bf83a22b8721205b61e940ec4c6f550ed115206782470a30f5 90dca62f7db47fe638762cbcb0a617f536bfba19a876012b122842f63e7f25bb",
    "DependentChainCertificate": "800b128e0f225b68f242d201009689bb5eeded3391250ef4259378dce034c35f 9ab2f002f27397ca2a0df0e45f98eee11a4a6993c73f8986dae6b4d0d91ec4ec",
    "DependentChainLeaf": "64c387d33dc40528ac4b1a9faa8a72237a10f0d049f656731fd5af4b88470fb8 13f9b2a502d11b0836d7453950bf0e028f8fb3f03cb416013436794fbd25b5a6",
    "DependentChainTheory": "325740a2f5587deeb28ab091880d6f2d9ce0894dd659b872103cb13a5cb3c194 e107211d2bfeb3a5a7bca53dc0d0f7db63ffbcf61fe327cdfd405e0d81a72796",
    "DependentColumnEvidence": "3aad8a1cfd9aa91431ec46ec25f3dbae94f82d8926e129d5702f9675ee495e54 11cf028d508997595a314cef1f0a36d411d1ba8f799e8c0e125bedecc02e6e47",
    "DependentTypeDag": "b6c18c3ca66eba2bdaba5385211ab9f557419ac6dc6f807659fef0c33acb5c4e b52e7b1c6925e177d91e6202f01cd5ceb4786d0ce26d9c01ec8bf2972be90c42",
    "SemanticProfile": "1b9144c54170bcd98528f79b4432cb1203057dc2ee1b7fedc0d55c2223120492 3bb8166269c04aa1cb967873088cfdeaefc3bafdbc3399c01122f12e1b99334b",
    "TheoryKeys": "6996cae14018896b70e600cdc3252ba1654f49d0865927feb30626de2bb0be80 2e67b77018788888b9be5085d2f4bd8824af0079ee701a86dccf480325f02534",
    "TypedCertificateEndpoint": "9592eec198ba9ef3b3073cbef9ecf994dd0a8f8d70fe6eeab7bc218e8703891f a6dbd09bd87ecf04e7139b6c214047614be7324329d3ada157a66d877010399a",
    "TypedEqualityCertificate": "460176ca8939a4fe2f29a9ad2b1bbe916ffcee7075e48151d55c581d8e6dd916 3fd2cb09eab2671bf23a1d0d1317428eb8b21f65f5e4bfad138813bf7d5fb22e",
    "SemanticEvidenceVerifier": "c91040e65f45bfc520051f2ccdba9aa6a609e01c0d597eba731fd613f65743da a96e5e846bc4901abe3350c51da5a02ba7650677d50a176ab88b8390e0660177",
}


def require(ok, message):
    if not ok:
        raise Blocked("dependent-chain: " + message)


def rows(path, fields):
    data = Path(path).read_bytes()
    require(len(data) < 64_000_000, "trace size")
    try:
        content = data.decode("utf-8", errors="strict")
    except UnicodeError as error:
        raise Blocked("dependent-chain: UTF-8") from error
    require(content.endswith("\n") and "\r" not in content and "\x00" not in content, "canonical TSV lines")
    reader = csv.reader(io.StringIO(content), delimiter="\t", quoting=csv.QUOTE_NONE)
    require(next(reader, None) == fields, "trace header")
    result = []
    for row in reader:
        require(len(row) == len(fields), "row width")
        result.append(dict(zip(fields, row)))
    require(len(result) < 25000, "row bound")
    return result


def text(value):
    return json.dumps(value, ensure_ascii=True)


def b64(value):
    return base64.b64encode(value.encode()).decode()


def decoded(value):
    try:
        raw = base64.b64decode(value, validate=True)
        result = raw.decode("utf-8", errors="strict")
    except (UnicodeError, binascii.Error, ValueError) as error:
        raise Blocked("dependent-chain: base64") from error
    require(b64(result) == value and result.isascii(), "canonical ASCII fixture encoding")
    return result


def key(tag, scalars=(), children=()):
    return tag, tuple(scalars), tuple(children)


def stable(k):
    tag, scalars, children = k
    frame = lambda s: str(len(s)) + ":" + s
    return frame(tag) + "[" + str(len(scalars)) + ":" + "".join(map(frame, scalars)) + "]{" + str(len(children)) + ":" + "".join(frame(stable(c)) for c in children) + "}"


def parse_key(value):
    require(value.isascii() and len(value) < 1_000_000, "key bound/character set")
    at = 0
    nodes = 0

    def literal(s):
        nonlocal at
        require(value.startswith(s, at), "key grammar")
        at += len(s)

    def natural():
        nonlocal at
        end = value.find(":", at)
        require(end >= 0 and re.fullmatch(r"0|[1-9][0-9]*", value[at:end]) is not None, "key length")
        n = int(value[at:end]); at = end + 1
        require(n <= 1_000_000, "key length bound")
        return n

    def string():
        nonlocal at
        n = natural(); end = at + n
        require(end <= len(value), "truncated key string")
        s = value[at:end]; at = end
        return s

    def node(depth):
        nonlocal at, nodes
        nodes += 1
        require(depth <= 64 and nodes <= 20000, "nested key bound")
        tag = string(); require(bool(tag), "empty tag")
        literal("["); count = natural()
        require(count < 1000, "scalar count")
        scalars = [string() for _ in range(count)]
        literal("]{"); count = natural()
        require(count < 1000, "child count")
        children = []
        for _ in range(count):
            size = natural(); start = at
            children.append(node(depth + 1))
            require(at - start == size, "nested key framing")
        literal("}")
        return key(tag, scalars, children)

    result = node(0)
    require(at == len(value) and stable(result) == value, "noncanonical/trailing key")
    return result


INT = key("type/INT")
BOOL = key("type/BOOL")
CTX = key("context")


def column(name):
    return INT if name == "Int" else key("type/CONSTRUCTOR", ["AlloySig:" + name])


def family(arity, products):
    return arity, tuple(tuple(p) for p in products)


def relation(f):
    arity, products = f
    if not products:
        return key("type/CONSTRUCTOR", ["AlloyEmptyRelation$arity=" + str(arity)])
    alternatives = [key("type/RELATION", children=[column(c) for c in p]) for p in products]
    return alternatives[0] if len(alternatives) == 1 else key("type/CONSTRUCTOR", ["AlloyRelationUnion"], alternatives)


def carrier(c):
    return key("type/CONSTRUCTOR", ["AlloyCarrier"], [column(c)])


def evidence(c):
    return key("dependent-column-evidence-v1", children=[column(c), key("direct-parent-path-v1", children=[column(c)])])


def product_key(tag, p):
    return key(tag, children=[evidence(c) for c in p])


def dag(f):
    arity, products = f
    common = relation(f) if len(products) == 1 else key("dependent-type-no-common-ancestor-v1", ["none"])
    return key("dependent-type-dag-v1", [str(arity)], [
        key("dependent-type-correlated-alternatives-v1", children=[product_key("dependent-type-product-v1", p) for p in products]), relation(f), common])


def combine(kind, left, right):
    arity = left[0] + right[0] - (2 if kind == "JOIN" else 0)
    require(arity > 0, "nullary fixture")
    products, cases = [], []
    for i, l in enumerate(left[1]):
        for j, r in enumerate(right[1]):
            if kind == "JOIN":
                require(l[-1] == r[0], "unlicensed fixture boundary")
                c = column(l[-1])
                boundary = key("dependent-boundary-correspondence-v2", ["EXACT"], [c, c, c, c,
                    key("dependent-boundary-left-path-v1", children=[c]), key("dependent-boundary-right-path-v1", children=[c])])
                output = l[:-1] + r[1:]
            else:
                boundary = key("dependent-type-no-boundary-v1", ["arrow"])
                output = l + r
            products.append(output)
            cases.append(key("dependent-type-combination-case-v1", [str(i), str(j), "JOIN_OVERLAP" if kind == "JOIN" else "ARROW_PRODUCT"],
                             [boundary, product_key("dependent-type-case-result-v1", output)]))
    return family(arity, sorted(set(products))), cases


def fixture_types(kind, fixture):
    first = "Int" if fixture == "int" else "univ" if fixture == "univ" else "A"
    if kind == "ARROW":
        views = [family(1, [[first]]), family(2, []) if fixture == "empty" else family(1, [["B"]]), family(1, [["C"]])]
    elif fixture == "repeat":
        views = [family(2, [["A", "A"]])] * 3
    elif fixture in ("primitive", "int"):
        views = [family(1, [[first]]), family(2, [[first, "B"]]), family(2, [["B", "C"]])]
    else:
        views = [family(2, [["A", first]]), family(2, []) if fixture == "empty" else family(2, [[first, "B"]]), family(2, [["B", "C"]])]
    stored = [relation(v) for v in views]
    if fixture == "primitive": stored[0] = carrier("A")
    if fixture == "int": stored[0] = INT
    return stored, views


def leaf_proof(stored, view):
    rule = "EXACT_RELATION" if stored == relation(view) else "PRIMITIVE_SET_SINGLETON"
    return key("dependent-chain-leaf-type-proof-v1", [rule], [stored, relation(view)])


def fixture_keys(kind, fixture, mode, association):
    stored, views = fixture_types(kind, fixture)
    ports, leaves = [], []
    for i, (s, v) in enumerate(zip(stored, views)):
        ident = 0 if kind == "JOIN" and fixture == "repeat" else i
        eclass = key("eclass", [str(ident)], [s, CTX])
        invocation = key("invocation", children=[eclass, key("embedding", children=[CTX, CTX])])
        port = key("port/one", children=[key("schema/one", children=[s]), CTX, key("port-leaf/invocation", children=[invocation])])
        ports.append(port)
        leaves.append(key("dependent-chain-leaf-v4", children=[port, leaf_proof(s, v), dag(v)]))

    def app(left, right):
        lv, lk = left; rv, rk = right
        out, cases = combine(kind, lv, rv)
        return out, key("dependent-chain-application-v3", [kind], [CTX, relation(out), dag(out), lk, rk,
                       key("dependent-chain-combination-cases-v1", children=cases)])

    inputs = list(zip(views, leaves))
    result, source = app(app(inputs[0], inputs[1]), inputs[2]) if association == 0 else app(inputs[0], app(inputs[1], inputs[2]))
    steps, combinations = [], []
    folded = views[0]
    for i, right in enumerate(views[1:], 1):
        out, cases = combine(kind, folded, right)
        combinations.append((dag(folded), dag(right), dag(out), tuple(cases)))
        steps.append(key("dependent-chain-fold-step-v1", [str(i)], [dag(folded), dag(right),
                         key("dependent-chain-complete-case-matrix-v1", children=cases), dag(out)]))
        folded = out
    require(result == folded, "fixture association typing")
    index = key("dependent-chain-theory-index-v3", [VERSION, DIGEST, kind], [
        key("dependent-chain-operand-dags-v1", children=[dag(v) for v in views]),
        key("dependent-chain-fold-steps-v1", children=steps), dag(result)])
    profile = key("semantic-profile", ["4", "FORBID" if mode == 0 else "MODULAR", "alloy-temporal", "repaired-normal-form-v2", "alloy-signature-v2"])
    schemas = [key("schema/one", children=[s]) for s in stored]
    schema = key("schema/dependent-seq", ["ORDERED_SEQUENCE"], [key("arity-policy", ["FINITE", "3"]), *schemas])
    identity = "ALLOY/DEPENDENT-CHAIN/" + kind
    declaration = key("operator-declaration", [identity, "nonflat"], [schema, relation(result), key("flat-license", ["none"]),
        key("port-law", ["0/0"], [key("container-laws", ["SEQ", "false", "false", "false", "ABSENT"])])])
    operator = key("instantiated-operator", [identity], [declaration, schema, relation(result)])
    target = key("e-node", children=[operator, CTX, key("port/seq", children=[schema, CTX, *ports])])
    ident = f"{kind}:{fixture}:{mode}:{association}"
    occurrence = key("alloy-dependent-chain-source-occurrence-v1", ["fixture/chain-witness/" + ident], [
        key("alloy-dependent-chain-typed-source-v1", children=[source]),
        key("alloy-dependent-chain-source-content-v1", ["TEST_ONLY:" + ident])])
    sort = key("certificate-sort", ["TERM"], [relation(result)])
    left = key("certificate-endpoint", ["DEPENDENT_CHAIN_APPLICATION"], [CTX, sort,
        key("certificate-term/dependent-chain-application-v1", children=[profile, source, occurrence])])
    right = key("certificate-endpoint", ["NODE"], [CTX, sort, key("certificate-term/node", children=[target])])
    certificate = key("typed-equality-certificate", ["DEPENDENT_CHAIN_NORMALIZATION"], [left, right,
        key("certificate-endpoint-type-check", children=[CTX, sort]), profile, key("dependent-chain-theory", [DIGEST]), index, source, occurrence, target])
    return dict(index=index, certificate=certificate, source=source, profile=profile, leaves=leaves,
                views=views, stored=stored, combinations=combinations, result=result,
                required=key("dependent-index-type-requirements", children=required_types(index)),
                published=key("published-exact-types", children=required_types(certificate)))


def required_types(k):
    types = {k} if k[0].startswith("type/") else set()
    if k[0] in ("dependent-type-product-v1", "dependent-type-case-result-v1"):
        require(all(c[0] == "dependent-column-evidence-v1" and not c[1] and len(c[2]) == 2 for c in k[2]), "product column shape")
        types.add(key("type/RELATION", children=[c[2][0] for c in k[2]]))
    for child in k[2]: types.update(required_types(child))
    return sorted(types, key=stable)


def key_coordinates(k, prefix):
    yield prefix + "/tag"
    for i in range(len(k[1])): yield prefix + f"/s{i}"
    for i, child in enumerate(k[2]):
        yield prefix + f"/drop{i}"
        yield from key_coordinates(child, prefix + f"/c{i}")
    for i in range(len(k[2]) - 1):
        if k[2][i] != k[2][i + 1]: yield prefix + f"/swap{i}"


def wire_shape(kind, views):
    product = lambda p: (3, [(2, [(1, [])]) for _ in p])
    dag_shape = lambda f: (4, [product(p) for p in f[1]])

    def app(l, r):
        lv, ls = l; rv, rs = r
        out, cases = combine(kind, lv, rv)
        boundary = (6, [(0, [(1, [])]), (0, [(1, [])])]) if kind == "JOIN" else (1, [])
        cs = [(4, [boundary, product([None] * out[0])]) for _ in cases]
        return out, (4, [ls, rs, dag_shape(out), (1, cs)])

    leaves = [(v, (5, [dag_shape(v)])) for v in views]
    return 11, [app(app(leaves[0], leaves[1]), leaves[2])[1]]


def wire_coordinates(shape, prefix="record"):
    n, children = shape
    for i in range(n): yield prefix + f"/s{i}"
    for i, child in enumerate(children): yield from wire_coordinates(child, prefix + f"/c{i}")


def grid_types():
    unary = lambda c: family(1, [[c]])
    views = [unary("Int"), unary("A"), unary("univ"), unary("B"), family(2, [["A", "B"]]), family(1, []), family(2, []), None]
    stored = [INT, carrier("A"), carrier("univ"), relation(views[1]), relation(views[4]), relation(views[5]), relation(views[6]), BOOL,
              key("type/TYPE_VARIABLE", ["X"]), key("type/CONSTRUCTOR", ["AlloyCarrier"]),
              key("type/CONSTRUCTOR", ["AlloyCarrier"], [key("type/TYPE_VARIABLE", ["X"])]),
              key("type/CONSTRUCTOR", ["AlloyCarrier"], [key("type/CONSTRUCTOR", ["A"])])]
    return stored, views


def expected_census():
    result = {}
    stored, views = grid_types()
    for i, s in enumerate(stored):
        for j, v in enumerate(views): result[("leaf-grid", f"{i}:{j}", "rule")] = (s, v)
    for kind in ("JOIN", "ARROW"):
        for fixture in FIXTURES:
            for mode in range(2):
                for assoc in range(2):
                    ident = f"{kind}:{fixture}:{mode}:{assoc}"
                    model = fixture_keys(kind, fixture, mode, assoc)
                    for coordinate in ("index", "certificate", "source", "profile", "theory"):
                        result[("chain", ident, coordinate)] = model
                    for i in range(3): result[("leaf", ident, str(i))] = model
                    result[("ledger", ident, "coverage")] = model
                    if ident == "JOIN:primitive:0:1": result[("control", ident, "ledger/intermediate")] = None
                    if mode == 0 and assoc == 0:
                        coordinates = list(wire_coordinates(wire_shape(kind, model["views"])))
                        coordinates += list(key_coordinates(model["index"], "index"))
                        for i, leaf in enumerate(model["leaves"]):
                            coordinates += list(key_coordinates(leaf[2][1], f"leaf{i}"))
                            coordinates += [f"rule{i}/{rule}" for rule in ("EXACT_RELATION", "PRIMITIVE_SET_SINGLETON", "PARSER_AUTHENTICATED_SUBFAMILY") if rule != leaf[2][1][1][0]]
                        coordinates += ["kind/other", "profile/other", "target/other", "source/swap"]
                        coordinates += ["certificate/detail" + str(i) for i in range(9)]
                        coordinates += ["ledger/drop" + str(i) for i in range(len(model["required"][2]))]
                        require(len(set(coordinates)) == len(coordinates), "ambiguous control census")
                        for coordinate in coordinates: result[("control", ident, coordinate)] = None
    return result


class Lean:
    def __init__(self):
        self.keys, self.definitions, self.proofs = {}, [], []

    def key(self, k):
        if k not in self.keys:
            children = [self.key(c) for c in k[2]]
            name = "k" + str(len(self.keys)); self.keys[k] = name
            self.definitions.append(f"def {name} : Key := .node {text(k[0])} {json.dumps(list(k[1]))} [{', '.join(children)}]")
        return self.keys[k]

    def theorem(self, name, proposition):
        self.proofs += [f"theorem {name} : {proposition} := by decide", f"#print axioms {name}"]

    def finish(self):
        return "\n".join(["import DependentChainWitnesses", f"namespace {NAMESPACE}",
            "open ACGN.FourthFive.DependentChainWitnesses", "set_option maxRecDepth 8192", "set_option maxHeartbeats 4000000",
            *self.definitions, *self.proofs, f"end {NAMESPACE}", ""])


def family_term(f):
    products = ["[" + ", ".join(".int" if c == "Int" else ".sig " + text(c) for c in p) + "]" for p in f[1]]
    return "({ arity := " + str(f[0]) + ", products := [" + ", ".join(products) + "] } : Family)"


def source_rows(extracted, lean):
    require(len(extracted) == len(PINS) == 13, "source census")
    seen = set()
    for i, row in enumerate(extracted):
        name = row["object"]
        require(name in PINS and name not in seen, "source object"); seen.add(name)
        owner = ("org.acgn.cert." if name == "SemanticEvidenceVerifier" else "is.fivefivefive.CanDis.theory.") + name
        require(row["owner"] == owner, "source owner")
        for field in ("shapeSha256", "bindingsSha256"):
            require(re.fullmatch("[0-9a-f]{64}", row[field]) is not None, "source digest syntax")
        shape, binding = PINS[name].split()
        lean.theorem("source" + str(i), f"{text(row['shapeSha256'])} = {text(shape)} /\\ {text(row['bindingsSha256'])} = {text(binding)}")


def program(observed, extracted):
    lean = Lean(); source_rows(extracted, lean)
    expected, seen = expected_census(), set()
    require(len(observed) == len(expected), "observation census size")
    for i, row in enumerate(observed):
        ident = tuple(row[k] for k in ("surface", "fixture", "coordinate"))
        require(ident in expected and ident not in seen, "foreign/duplicate observation"); seen.add(ident)
        p, w, v = (decoded(row[k]) for k in ("producer", "writer", "verifier"))
        surface, fixture, coordinate = ident
        model = expected[ident]
        status = row["status"]
        if surface == "leaf-grid":
            s, view = model
            require(parse_key(w) == s and parse_key(v) == (BOOL if view is None else relation(view)), "leaf fixture inputs")
            si = int(fixture.split(":")[0])
            st = ".primitive .int" if si == 0 else '.primitive (.sig "A")' if si in (1, 11) else '.primitive (.sig "univ")' if si == 2 else ".relation " + family_term(grid_types()[1][{3:1,4:4,5:5,6:6}[si]]) if si in (3,4,5,6) else ".other " + lean.key(s)
            require(p in ("EXACT_RELATION", "PRIMITIVE_SET_SINGLETON", "REJECTED") and status == "PRODUCER", "leaf outcome")
            r = {"EXACT_RELATION": "some .exact", "PRIMITIVE_SET_SINGLETON": "some .primitive", "REJECTED": "none"}[p]
            proposition = f"derive ({st}) {family_term(view)} = {r}" if view else f"{text(p)} = \"REJECTED\""
        elif surface == "control":
            require(p == "CHANGED" and w == "ENCODED", "control input stage")
            require(status in {"THEORY_MISMATCH", "DIGEST_MISMATCH", "INVALID_RECORD_SHAPE", "UNKNOWN_VARIANT", "DANGLING_REFERENCE", "INTEGER_OVERFLOW", "MISSING_EVIDENCE"}, "control failure class")
            require(v in ("REJECTED", "VERIFIED"), "control outcome")
            proposition = f"{text(v)} = \"REJECTED\""
        elif surface == "leaf":
            at = int(coordinate); proof = model["leaves"][at][2][1]
            require(status == "VERIFIED" and v in ("EXACT_RELATION", "PRIMITIVE_SET_SINGLETON", "PARSER_AUTHENTICATED_SUBFAMILY"), "leaf wire rule")
            proposition = f"{lean.key(parse_key(p))} = {lean.key(proof)} /\\ {lean.key(parse_key(w))} = {lean.key(proof)} /\\ {text(v)} = {text(proof[1][0])}"
            stored = model["stored"][at]
            st = ".primitive .int" if stored == INT else '.primitive (.sig "A")' if stored == carrier("A") else ".relation " + family_term(model["views"][at])
            rule = ".exact" if proof[1][0] == "EXACT_RELATION" else ".primitive"
            proposition += f" /\\ checkLeaf ({st}) {family_term(model['views'][at])} {rule} {lean.key(parse_key(w))} = true"
        elif surface == "ledger":
            require(status == "NONE" and v in ("VERIFIED", "REJECTED"), "ledger outcome")
            published = parse_key(w)
            require(published[0] == "published-exact-types" and not published[1], "ledger shape")
            ledger = "[" + ", ".join(lean.key(t) for t in published[2]) + "]"
            proposition = f"{lean.key(parse_key(p))} = {lean.key(model['required'])} /\\ {lean.key(published)} = {lean.key(model['published'])} /\\ {text(v)} = \"VERIFIED\" /\\ publishes {ledger} {lean.key(model['index'])} = true"
        elif coordinate == "theory":
            require(status == "SHA256", "theory stage")
            require(hashlib.sha256((VERSION + "\n" + p).encode()).hexdigest() == DIGEST, "fixed source-text digest")
            proposition = f"{text(w)} = {text(VERSION)} /\\ {text(v)} = {text(DIGEST)}"
        else:
            require(status == "NONE" and v in ("VERIFIED", "REJECTED"), "bundle outcome")
            expected_key = model[coordinate]
            proposition = f"{lean.key(parse_key(p))} = {lean.key(expected_key)}"
            if coordinate == "profile":
                proposition += f" /\\ {text(w)} = {text(hashlib.sha256(stable(expected_key).encode()).hexdigest())}"
            else:
                proposition += f" /\\ {lean.key(parse_key(w))} = {lean.key(expected_key)}"
            proposition += f" /\\ {text(v)} = \"VERIFIED\""
            if coordinate == "index":
                combo = "none"
                for left, right, result, cases in reversed(model["combinations"]):
                    combo = f"if l = {lean.key(left)} /\\ r = {lean.key(right)} then some ({lean.key(result)}, [{', '.join(lean.key(c) for c in cases)}]) else ({combo})"
                name = "combine" + str(i)
                lean.definitions.append(f"def {name} : Combine := fun l r => {combo}")
                operands = ", ".join(lean.key(dag(f)) for f in model["views"])
                proposition += f" /\\ reconstruct {name} {text(VERSION)} {text(DIGEST)} {text(fixture.split(':')[0])} [{operands}] {lean.key(dag(model['result']))} = some {lean.key(parse_key(w))}"
        lean.theorem("observation" + str(i), proposition)
    require(seen == set(expected), "missing observations")
    return lean.finish(), len(expected) + len(PINS)


def generate(build, formal):
    source, count = program(rows(Path(build) / "dependent-chain-witness.tsv", FIELDS),
                            rows(Path(build) / "dependent-chain-witness-source.tsv", SOURCE_FIELDS))
    return [("DependentChainWitnessReplay.lean", source, count)]


def negatives(build, formal):
    observed = rows(Path(build) / "dependent-chain-witness.tsv", FIELDS)
    extracted = rows(Path(build) / "dependent-chain-witness-source.tsv", SOURCE_FIELDS)
    result = []
    targets = [("leaf-primitive", next(i for i,r in enumerate(observed) if r["surface"] == "leaf-grid" and r["fixture"] == "1:1"), "producer", b64("EXACT_RELATION")),
               ("leaf-absent", next(i for i,r in enumerate(observed) if r["surface"] == "leaf-grid" and r["fixture"] == "8:2"), "producer", b64("PRIMITIVE_SET_SINGLETON"))]
    for surface, coordinate, field, value in [("chain", "index", "verifier", b64("REJECTED")),
            ("chain", "certificate", "verifier", b64("REJECTED")), ("leaf", "0", "verifier", b64("PARSER_AUTHENTICATED_SUBFAMILY"))]:
        targets.append((coordinate, next(i for i,r in enumerate(observed) if r["surface"] == surface and r["coordinate"] == coordinate), field, value))
    for path in ("record/s2", "record/s7", "record/s8", "index/c0/drop0", "index/c1/c0/s0", "leaf0/c0/tag"):
        targets.append((path.replace("/", "-"), next(i for i,r in enumerate(observed) if r["surface"] == "control" and r["coordinate"] == path), "verifier", b64("VERIFIED")))
    leaf = next(i for i, row in enumerate(observed) if row["surface"] == "leaf")
    proof = parse_key(decoded(observed[leaf]["writer"]))
    for coordinate, changed in (("stored-key", key(proof[0], proof[1], [BOOL, proof[2][1]])),
            ("view-key", key(proof[0], proof[1], [proof[2][0], BOOL])),
            ("rule-key", key(proof[0], ["PRIMITIVE_SET_SINGLETON"], proof[2]))):
        targets.append((coordinate, leaf, "writer", b64(stable(changed))))
    ledger = next(i for i, row in enumerate(observed) if row["surface"] == "ledger" and row["fixture"] == "JOIN:primitive:0:1")
    published = parse_key(decoded(observed[ledger]["writer"]))
    intermediate = relation(family(1, [["B"]]))
    require(intermediate in published[2], "positive intermediate type")
    targets.append(("ledger-intermediate", ledger, "writer", b64(stable(key(published[0], children=[t for t in published[2] if t != intermediate])))))
    targets.append(("ledger-public-control", next(i for i,r in enumerate(observed) if r["coordinate"] == "ledger/intermediate"), "verifier", b64("VERIFIED")))
    for label, index, field, value in targets:
        changed = [dict(r) for r in observed]; changed[index][field] = value
        source = program(changed, extracted)[0]
        source = source.split(f"#print axioms observation{index}\n", 1)[0] + f"\nend {NAMESPACE}\n"
        result.append(("chain-" + label, "RejectDependentChainWitness.lean", source))
    return result


def source_mutations():
    p = "src/is/fivefivefive/CanDis/theory/"
    v = "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java"
    specs = [
        ("leaf-exact", p + "DependentChainTheory.java", "storedType.equals(relationType)", "!storedType.equals(relationType)"),
        ("leaf-unary", p + "DependentChainTheory.java", "alternatives.get(0).arguments().size() != 1", "alternatives.get(0).arguments().size() != 2"),
        ("leaf-proof-rule", p + "DependentChainTheory.java", "LeafTypeRule checked = requireLeafTypeProof(storedType, relationType);\n        if (rule != checked)", "LeafTypeRule checked = requireLeafTypeProof(storedType, relationType);\n        if (rule == checked)"),
        ("leaf-primitive", p + "DependentChainTheory.java", "storedType.equals(GraphType.INT)", "storedType.equals(GraphType.BOOL)"),
        ("index-kind", p + "DependentChainTheory.java", "List.of(VERSION, DIGEST, kind.name())", "List.of(VERSION, DIGEST, \"JOIN\")"),
        ("index-version", p + "DependentChainTheory.java", '"alloy-dependent-chain-theory-v11"', '"alloy-dependent-chain-theory-v12"'),
        ("index-result", p + "DependentChainTheory.java", "if (!folded.equals(resultDag))", "if (folded.equals(resultDag))"),
        ("certificate-profile", p + "DependentChainCertificate.java", "semanticProfile.structuralKey(),", "target.structuralKey(),"),
        ("certificate-order", p + "DependentChainCertificate.java", "targetSequence.elements().get(index)", "targetSequence.elements().get(0)"),
        ("verifier-leaf", v, "stored.key().equals(relation.key())", "!stored.key().equals(relation.key())"),
        ("verifier-unary", v, "alternatives.get(0).arguments().size() != 1", "alternatives.get(0).arguments().size() != 2"),
        ("verifier-proof", v, "if (rule != expected)", "if (rule == expected)"),
        ("verifier-index", v, "if (!folded.equals(result))", "if (folded.equals(result))"),
        ("verifier-order", v, "sequence.children().get(index).equals(expected.id())", "sequence.children().get(0).equals(expected.id())"),
        ("writer-index", p + "CertificateBundleWriter.java", "certificate.theoryIndex().stableString(),", "certificate.sourceOccurrenceCommitment().stableString(),"),
        ("writer-rule", p + "CertificateBundleWriter.java", "leaf.typeRule().name(),", "\"EXACT_RELATION\","),
        ("writer-fold-ledger", p + "CertificateBundleWriter.java", "collectDependentFoldTypes(construction.source());", "collectDependentChainTypes(construction.source());"),
        ("writer-fold-result-ledger", p + "CertificateBundleWriter.java", "folded = step.result();\n                collectDependentDagTypes(folded);", "folded = step.result();\n                collectDependentDagTypes(leaves.get(index).outputTypeDag());"),
        ("writer-product-ledger", p + "CertificateBundleWriter.java", "collectExactType(DependentChainKind.typeOf(product));", "collectExactType(product.get(0).exactColumn());"),
        ("writer-case-ledger", p + "CertificateBundleWriter.java", "proof.resultAlternative().ifPresent(this::collectDependentProductTypes);", "proof.resultAlternative().ifPresent(product -> { });"),
    ]
    return [("chain-" + label, path, old, new, "DependentChainWitnessesExtractor") for label, path, old, new in specs]
