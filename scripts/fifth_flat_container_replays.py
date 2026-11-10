"""Bounded P3-05/P3-06 plugin. Generality is in Lean, not the Java census.

Long external identities are interned bijectively, never hashed or truncated.
Decimal and path strings retain their exact spelling. Structural preimages are
independently rebuilt before interning; the byte codec and JVM remain TCB.
"""
from __future__ import annotations

import copy
import hashlib
import json
import re

from next_obligation_replays import rows
from run_submission_container_closure import Blocked

FIELDS = "case fixture variant carrier binding record accepted stage".split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
NAMESPACE = "ACGN.FifthFive.FlatContainerRecordsReplay"
STAGE_SHA256 = "e0e419a47114d40289ab3249be708bc6bf16b853f49a5f6f84789d04b80ac66e"
SOURCE_PINS = {
    "CertificateVerificationScope": "b756bbdfe372252e690bb2811a56e671e199ae5cda83c1fe4f42f0b12d24822a 986c75b0fef819e817dfb1cf29590e7d2c553fdc0b3f2ad48189403c171b4805",
    "AlloyLawRegistry": "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b 9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041",
    "CertificateBundleWriter": "b30d10623694288f274a1fc26b6f92dc6b00ecc6264a58a54e5f01b3a35e7e46 0807ef1b7acdba3a1c72c6f339a02ede7d8beebc969500c4e66de3c5983b1d21",
    "CertificateVerifier": "368b02d882d4bcf7395cfc0dc76ccf1c0140b91bac7881340966e3594d393146 c4917a8b2603d5b8d751c0c881dede3c6de748875d447cf1d22566d15b7cd654",
    "ContainerApplicationTrace": "38cca38c37ca76f05b9c5d08f85adb69c65b2f0fed8719c891b05e3d2d52db8b fe99c389770466e820400d38e0ff8d81b86bf258d5cb994f8e66314966a45f1d",
    "ContainerConstructionCertificate": "55e8e7749ca80eb280bf17b7e93bdfe065e5f0701fbe957a91587dc1ea44922b de3134e92cead0a801f768498d3fe76d5ac8df926af55b61ad01023f3cb3de0d",
    "ContainerLawCertificate": "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2 d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e",
    "ContainerLawDeclaration": "4eca6d09ff3245d98b2711c865cb0dc61b0a82166d05348df11728722bc5618f 7b51b568114f1f32547156934bc46ae0029e9a65fd4054a172de0faa1096f298",
    "FlatApplication": "1e57064a889494f17cd75c659ee30d648a0a081befa802b8c25c6287025b2398 890ca35964d2a0cbe1586e0f8dec7ce881447fc868300679f5482a084905e0be",
    "FlatConstructionCertificate": "fddb9145978709c2881df347a902401fb1cc51ced2ac375aeb8e5d1413a97c9a 1de9f3d0ef542c59dc12a3bc379a5dd527330e103312940db1eca53e5a883aa2",
    "SemanticEvidenceVerifier": "bff2c3471c7fc123e9752ce4a70a964811382f52df9d6e5475b6854a10df03bc cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd",
    "StructuralKey": "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f",
    "TheoryAlloyAdapter": "34fab8469ffe44905c7aedb253c0bb27b40257987281bfc61536c2550c23d86f 65675f4936fbd2b8f5a2e056c752d728be467f4d574096863252da0939580b25",
    "TypedENode": "b70e73eaabd850acf69575e9e134f165dbc8a60dc1790e816b7aaa6d65e18cc1 ef393be4a64e937af202fa7ca18d9858f6aa0afe0faa6c113b8155223a767a2b",
}

TREES = ([[[1, 0], 1], 0], [1, [0, [1, 0]]], [[1, 0], [1, 0]])
WORDS = ([], [0], [1, 0, 1, 0], [0, 1], [0, 0])
# Frozen sites: (child path, scalar count, child count), independent of trace rows.
FLAT_SITES = (("", 9, 3), ("0", 4, 2), ("0.0", 4, 2), ("0.0.0.0", 1, 0),
              ("1", 0, 2), ("1.0", 5, 0), ("2", 5, 6), ("2.0", 1, 0), ("2.4", 3, 0))
CONTAINER_SITES = (("", 8, 2), ("0", 0, 2), ("0.0", 1, 0), ("1", 5, 4),
                   ("1.0", 1, 0), ("1.2", 2, 0))
STAGES = {"VERIFIED:NONE", "LOCAL_TRACE", "REJECTED:INVALID_RECORD_SHAPE", "REJECTED:THEORY_MISMATCH",
          "REJECTED:UNKNOWN_VARIANT", "REJECTED:DANGLING_REFERENCE", "REJECTED:INTEGER_OVERFLOW",
          "REJECTED:NONCANONICAL_ENCODING", "REJECTED:DIGEST_MISMATCH"}

def require(ok, message):
    if not ok:
        raise Blocked(message)


def encode(value):
    return json.dumps(value, ensure_ascii=True, separators=(",", ":"))


def wire(tag, scalars=(), children=()):
    return [tag, list(scalars), list(children)]


def parse(value):
    try:
        result = json.loads(value)
    except (ValueError, TypeError, RecursionError) as error:
        raise Blocked("malformed records JSON") from error
    require(encode(result) == value, "noncanonical records JSON")
    return result


def check_wire(n, depth=0):
    require(depth <= 20 and isinstance(n, list) and len(n) == 3, "records wire shape")
    tag, ss, cs = n
    require(isinstance(tag, str) and 0 < len(tag) < 80 and tag.isascii(), "records tag")
    require(isinstance(ss, list) and len(ss) <= 32 and all(
        isinstance(s, str) and s.isascii() and len(s) <= 100000 and not any(c in s for c in "\t\n\r")
        for s in ss), "records scalars")
    require(isinstance(cs, list) and len(cs) <= 16, "records children")
    for c in cs:
        check_wire(c, depth + 1)
    return n


def stable(tag, scalars=(), children=()):
    # The finite bridge is ASCII; Java UTF-16 length and Python length agree here.
    def part(s):
        require(isinstance(s, str) and s.isascii(), "non-ASCII structural-key boundary")
        return str(len(s)) + ":" + s
    return part(tag) + "[" + str(len(scalars)) + ":" + "".join(map(part, scalars)) + "]{" + str(len(children)) + ":" + "".join(map(part, children)) + "}"


def fixtures():
    result = []
    for prefix, carrier in (("flat-set", 2), ("flat-bag", 1)):
        for i, tree in enumerate(TREES):
            result.append((f"{prefix}-{i}", carrier, tree))
    for i in range(4):
        result.append((f"container-bag-{i}", 1, [i // 2, i % 2]))
    for carrier in range(3):
        for i, word in enumerate(WORDS):
            result.append((f"trace-{carrier}-{i}", carrier, word))
    return result


def sites(fixture):
    if fixture == "flat-set-0":
        return FLAT_SITES
    if fixture == "flat-bag-0":
        return tuple((p, 2 if p == "2.4" else ns, 8 if p == "2" else nc) for p, ns, nc in FLAT_SITES)
    return CONTAINER_SITES if fixture == "container-bag-2" else ()


def labels(ns, nc):
    result = ["tag"]
    for i in range(ns):
        result += [f"omit-s{i}", f"sub-s{i}"]
    if ns:
        result.append("duplicate-s")
    if ns > 1:
        result.append("reorder-s")
    result += [f"omit-c{i}" for i in range(nc)]
    if nc:
        result.append("duplicate-c")
    if nc > 1:
        result.append("reorder-c")
    return result


def expected_keys():
    result = []
    for name, carrier, _ in fixtures():
        result.append((name, "original", carrier))
        for path, ns, nc in sites(name):
            result.extend((name, (path or "root") + ":" + label, carrier) for label in labels(ns, nc))
    return result


def source_census(extracted):
    require(len(extracted) == len(SOURCE_PINS), "incomplete records source census")
    seen = set()
    for row in extracted:
        require(set(row) == set(SOURCE_FIELDS), "records source schema")
        name = row["object"]
        require(name in SOURCE_PINS and name not in seen, "extra/duplicate records source object")
        seen.add(name)
        owner = ("org.acgn.cert." if name == "SemanticEvidenceVerifier" else "is.fivefivefive.CanDis.theory.") + name
        require(row["owner"] == owner and row["shapeSha256"] + " " + row["bindingsSha256"] == SOURCE_PINS[name],
                "UNMODELED_SOURCE: records signature/body/resolved binding differs")


def expand(n, dictionary, depth=0):
    require(depth <= 20 and isinstance(n, list) and len(n) == 3, "packed records shape")
    tag, ss, cs = n
    require(isinstance(ss, list) and isinstance(cs, list), "packed records lists")
    values = []
    for s in ss:
        if type(s) is int:
            require(0 <= s < len(dictionary), "unbound dictionary reference")
            values.append(dictionary[s])
        else:
            require(isinstance(s, str) and len(s) < 64, "noncanonical packed scalar")
            values.append(s)
    return check_wire(wire(tag, values, [expand(c, dictionary, depth+1) for c in cs]))


def binding(value, fixture):
    envelope = parse(value)
    require(isinstance(envelope, list) and len(envelope) == 2, "missing dictionary envelope")
    dictionary = envelope[1]
    require(isinstance(dictionary, list) and len(dictionary) <= 64 and all(
        isinstance(s, str) and 64 <= len(s) <= 100000 and s.isascii() for s in dictionary), "dictionary domain")
    require(dictionary == sorted(set(dictionary)), "dictionary order/duplicates")
    b = expand(envelope[0], dictionary)
    size = 6 if fixture.startswith("trace-") else 14 if fixture.startswith("container-") else 15
    require(b[0] == "bindings" and len(b[1]) == size and len(b[2]) == 2, "complete external binding")
    require(b[2][0][0] == "ids" and b[2][1][0] == "keys" and
            all(len(c[1]) == 2 and not c[2] for c in b[2]), "complete alphabet binding")
    ids, keys = b[2][0][1], b[2][1][1]
    require(ids[0] != ids[1] and keys[0] < keys[1], "exact independent alphabet ranking")
    if size != 6:
        meta = b[1][6:]
        require(meta[2] == b[1][0] and meta[3] == "0/0", "operator/root port binding")
        require(re.fullmatch("[0-9a-f]{64}", meta[1]) is not None, "profile fingerprint")
        if size == 15:
            require(meta[4] == "NODE", "frozen full flat target kind")
    return b, dictionary


def leaf_order(tree):
    return [tree] if type(tree) is int else [x for child in tree for x in leaf_order(child)]


def normal(carrier, xs):
    out = list(xs) if carrier == 0 else sorted(xs) if carrier == 1 else sorted(set(xs))
    fs = ([[i] for i in range(len(xs))] if carrier == 0 else
          [[i] for i in sorted(range(len(xs)), key=lambda i: xs[i])] if carrier == 1 else
          [[i for i, x in enumerate(xs) if x == v] for v in out])
    return out, fs


def reconstruct(b, name, carrier, request):
    op, ctx, schema, op_key, ctx_key, schema_key = b[1][:6]
    ids, keys = b[2][0][1], b[2][1][1]
    source_keys = {}
    def source(t):
        if type(t) is int:
            key = stable("flat-input/leaf", children=[keys[t]])
            source_keys[encode(t)] = key
            return wire("flat-leaf", [ids[t]]), key
        children = [source(c) for c in t]
        key = stable("flat-input/application", children=[op_key, ctx_key] + [c[1] for c in children])
        source_keys[encode(t)] = key
        return wire("flat-application", [op, ctx, str(len(t)), key], [c[0] for c in children]), key
    def splices(t, path=()):
        if type(t) is int:
            return []
        result = []
        for i, child in enumerate(t):
            if isinstance(child, list):
                result.append(wire("splice", ["/".join(map(str, (*path, i))), str(len(t)), str(len(child)), str(i), source_keys[encode(child)]]))
                result.extend(splices(child, (*path, i)))
        return result
    xs = leaf_order(request) if name.startswith("flat-") else request
    out, fs = normal(carrier, xs)
    trace_children = [wire("trace-input", [ids[i]]) for i in xs]
    trace_children += [wire("trace-output", [ids[i], *map(str, f)]) for i, f in zip(out, fs)]
    preimages = [stable("container-application/input", children=[keys[i]]) for i in xs]
    preimages += [stable("container-application/output", list(map(str, f)), [keys[i]]) for i, f in zip(out, fs)]
    trace_key = stable("container-application-trace-v1", children=[schema_key, ctx_key, *preimages])
    trace = wire("container-trace", [schema, ctx, str(len(xs)), str(len(out)), trace_key], trace_children)
    if name.startswith("trace-"):
        result = trace
    elif name.startswith("flat-"):
        src, _ = source(request)
        result = wire("flat-construction", b[1][6:], [src, wire("splices", children=splices(request)), trace])
    else:
        result = wire("container-construction", b[1][6:], [wire("input-occurrences", children=[wire("input", [ids[i]]) for i in xs]), trace])
    return result, source_keys, trace_key


def mutate(record, variant):
    if variant == "original":
        return copy.deepcopy(record)
    result = copy.deepcopy(record)
    path, label = variant.split(":")
    n = result
    if path != "root":
        for p in path.split("."):
            n = n[2][int(p)]
    if label == "tag":
        n[0] = "wrong-record-tag"
    elif label.startswith("omit-s"):
        del n[1][int(label[6:])]
    elif label.startswith("sub-s"):
        n[1][int(label[5:])] = "wrong-field"
    elif label == "duplicate-s":
        n[1].insert(0, n[1][0])
    elif label == "reorder-s":
        n[1][0], n[1][-1] = n[1][-1], n[1][0]
    elif label.startswith("omit-c"):
        del n[2][int(label[6:])]
    elif label == "duplicate-c":
        n[2].insert(0, copy.deepcopy(n[2][0]))
    elif label == "reorder-c":
        n[2].reverse()
    else:
        raise Blocked("unregistered mutation")
    require(result != record, "vacuous field control")
    return result


class Lean:
    def __init__(self):
        self.symbols = {}
    def atom(self, s):
        # Keep grammar, all numerals, and paths literal. Intern only long identities.
        if len(s) < 64:
            require(not s.startswith("ref-"), "reserved interning namespace")
            return encode(s)
        if s not in self.symbols:
            self.symbols[s] = '"ref-' + str(len(self.symbols)) + '"'
        return self.symbols[s]
    def strings(self, ss):
        return "[" + ",".join(map(self.atom, ss)) + "]"
    def wire(self, n):
        return "(.node " + encode(n[0]) + " " + self.strings(n[1]) + " [" + ",".join(self.wire(c) for c in n[2]) + "])"
    def tree(self, t):
        return f"(.leaf {t})" if type(t) is int else "(.app [" + ",".join(self.tree(c) for c in t) + "])"


def program(observed, extracted):
    source_census(extracted)
    required = expected_keys()
    require(len(observed) == len(required) == 311, "incomplete records observation census")
    require(all(set(row) == set(FIELDS) for row in observed), "records schema")
    stages = "\n".join(row["fixture"] + "\t" + row["variant"] + "\t" + row["stage"] for row in observed) + "\n"
    require(hashlib.sha256(stages.encode()).hexdigest() == STAGE_SHA256, "exact verifier outcome/code census changed")
    lean = Lean()
    lines = ["import FlatContainerRecords", "open ACGN.FifthFive.FlatContainerRecords",
             "set_option maxRecDepth 4096", "set_option maxHeartbeats 4000000", "namespace " + NAMESPACE]
    requests = {name: (c, req) for name, c, req in fixtures()}
    expected = {}
    definitions = {}
    checks = []
    for i, (row, key) in enumerate(zip(observed, required)):
        require(set(row) == set(FIELDS) and row["case"] == str(i), "records schema/canonical case/order")
        require((row["fixture"], row["variant"], row["carrier"]) == (key[0], key[1], str(key[2])), "unregistered/reordered records census")
        name, variant, carrier = key
        require(row["accepted"] in ("true", "false"), "noncanonical records acceptance")
        require(row["stage"] in STAGES and (row["stage"] == "LOCAL_TRACE") == name.startswith("trace-"),
                "unregistered verifier boundary: " + row["stage"])
        if variant == "original":
            b, dictionary = binding(row["binding"], name)
            record, source_keys, trace_key = reconstruct(b, name, carrier, requests[name][1])
            expected[name] = record
            j = len(definitions)
            definitions[name] = j
            # Match against complete source shapes, not hash values or digest equality.
            keys = list(source_keys.items())
            key_fn = ("fun s => " if keys else "fun _ => ") + "".join("if sourceCode s == " + encode(k) + " then " + lean.atom(v) + " else " for k, v in keys) + '"unbound-source"'
            ids = b[2][0][1]
            env = "⟨" + ", ".join([lean.atom(b[1][0]), lean.atom(b[1][1]), lean.atom(b[1][2]),
                    "(fun i => if i == 0 then " + lean.atom(ids[0]) + " else if i == 1 then " + lean.atom(ids[1]) + ' else "unbound-term")',
                    "(" + key_fn + ")", "(fun _ _ => " + lean.atom(trace_key) + ")"]) + "⟩"
            lines += [f"def env{j} : Environment := " + env]
            mode = ("seq", "bag", "set")[carrier]
            req = requests[name][1]
            if name.startswith("flat-"):
                meta = ", ".join(lean.atom(x) for x in b[1][6:])
                lines += [f"def bound{j} : FlatRecord := ⟨" + meta + ', leaf "unused" [], [], leaf "unused" []⟩',
                          f"def expected{j} : FlatRecord := reconstructFlat env{j} .{mode} {lean.tree(req)} bound{j}"]
            elif name.startswith("container-"):
                meta = ", ".join(lean.atom(x) for x in b[1][6:])
                lines += [f"def bound{j} : ContainerRecord := ⟨" + meta + ', [], leaf "unused" []⟩',
                          f"def expected{j} : ContainerRecord := reconstructContainer env{j} .{mode} {encode(req)} bound{j}"]
            else:
                lines += [f"def expected{j} : Wire := reconstructTrace env{j} .{mode} {encode(req)}"]
        else:
            require(row["binding"] == "[]", "mutation must retain original external binding")
        actual = expand(parse(row["record"]), dictionary)
        required_record = mutate(expected[name], variant)
        j = definitions[name]
        accepted = row["accepted"]
        if name.startswith("trace-"):
            decision = f"(wireEqual expected{j} {lean.wire(actual)} == {accepted})"
        else:
            method = "acceptsFlat" if name.startswith("flat-") else "acceptsContainer"
            decision = f"({method} expected{j} {lean.wire(actual)} == {accepted})"
        stage_accepts = row["stage"] in ("VERIFIED:NONE", "LOCAL_TRACE")
        positive = variant == "original"
        checks.append("(" + decision + f" && ({accepted} == {str(positive).lower()})" +
                      f" && ({accepted} == {str(stage_accepts).lower()})" +
                      " && wireEqual " + lean.wire(actual) + " " + lean.wire(required_record) + ")")
    for i in range(0, len(checks), 8):
        lines += [f"theorem recordsBlock{i//8} : ([" + ",\n".join(checks[i:i+8]) + "] : List Bool).all id = true := by decide",
                  f"#print axioms recordsBlock{i//8}"]
    lines += ["end " + NAMESPACE, ""]
    return "\n".join(lines), (len(checks)+7)//8


def generate(build, formal):
    text, count = program(rows(build / "flat-container-records.tsv", FIELDS),
                          rows(build / "flat-container-records-source.tsv", SOURCE_FIELDS))
    return [("FlatContainerRecordsReplay.lean", text, count)]


def negatives(build, formal):
    observed = rows(build / "flat-container-records.tsv", FIELDS)
    extracted = rows(build / "flat-container-records-source.tsv", SOURCE_FIELDS)
    program(observed, extracted)
    result = []
    for label, fixture, variant, field in (
            ("acceptance", "flat-set-0", "original", "accepted"),
            ("flat-source", "flat-set-0", "original", "source"),
            ("splice-ledger", "flat-set-0", "original", "splices"),
            ("trace-fiber", "flat-bag-0", "original", "trace"),
            ("container-input", "container-bag-2", "original", "inputs"),
            ("seq-order", "trace-0-2", "original", "trace"),
            ("wire-control-accept", "flat-set-0", "root:sub-s0", "accepted")):
        changed = copy.deepcopy(observed)
        index = next(i for i,r in enumerate(changed) if r["fixture"] == fixture and r["variant"] == variant)
        if field == "accepted":
            changed[index][field] = "false" if changed[index][field] == "true" else "true"
        else:
            record = parse(changed[index]["record"])
            if field == "source":
                record[2][0][2].reverse()
            elif field == "splices":
                record[2][1][2].reverse()
            elif field == "inputs":
                record[2][0][2].reverse()
            else:
                trace = record if fixture.startswith("trace-") else record[2][-1]
                trace[2][-1][1][-1] = "99"
            changed[index]["record"] = encode(record)
        source, _ = program(changed, extracted)
        # Retain only the failing block; definitions precede all theorem blocks.
        head = source.split("theorem recordsBlock0 :",1)[0]
        block = index//8
        body = source.split(f"theorem recordsBlock{block} :",1)[1].split(f"#print axioms recordsBlock{block}",1)[0]
        # A negative example must fail; it has no accepted theorem to audit.
        result.append(("records-"+label, "RejectFlatContainerRecords.lean", head + "example :" + body +
                       f"end {NAMESPACE}\n"))
    return result


def source_mutations():
    p = "src/is/fivefivefive/CanDis/theory/"
    v = "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java"
    e = "FlatContainerRecordsExtractor"
    return [
        ("memo-identity", p+"CertificateVerificationScope.java", "new IdentityHashMap<>()", "new java.util.HashMap<>()", e),
        ("memo-policy", p+"CertificateVerificationScope.java", "!policy.equals(currentPolicy)", "false", e),
        ("memo-local-proof", p+"CertificateVerifier.java", "certificate.verifyLocal();", ";", e),
        ("writer-source-arity", p+"CertificateBundleWriter.java", "Integer.toString(application.operands().size()),",
         'Integer.toString(application.operands().size() + 1),', e),
        ("producer-splice-position", p+"FlatConstructionCertificate.java", "coordinates.add(Integer.toString(position));", 'coordinates.add("0");', e),
        ("producer-trace-fiber", p+"ContainerApplicationTrace.java", "origins.add(Integer.toString(input));", 'origins.add("0");', e),
        ("decoder-flat-arity", v, 'record.requireShape("flat-construction", 9, 3);', 'record.requireShape("flat-construction", 8, 3);', e),
        ("decoder-container-arity", v, 'record.requireShape("container-construction", 8, 2);', 'record.requireShape("container-construction", 7, 2);', e),
        ("verifier-preorder", v, "splices.add(splicePosition, new FlatSplice(", "splices.add(new FlatSplice(", e),
        ("verifier-fiber", v, "if (!fiber.equals(normalized.fibers().get(index)))", "if (false)", e),
        ("resolved-dispatch", p+"StructuralKey.java", "public final class StructuralKey implements Comparable<StructuralKey>",
         "public class StructuralKey implements Comparable<StructuralKey>", e),
    ]
