"""Bounded structural packets for source-backed, one-step repair learning."""
from .scope import TOKENS, ASSIGNED, encode_uint, ScopeExclusion, TEMPLATES

READ_ONLY = ("IMPLIES", "IFF", "CLOSURE", "RCLOSURE", "TRANSPOSE")
T = dict(TOKENS, **{"OP_" + op: 104 + i for i, op in enumerate(READ_ONLY)})
CORPUS_TOKENS = ASSIGNED | frozenset(range(104, 109))


ALIASES = {"PLUS": "UNION", "MINUS": "DIFFERENCE", "EQUALS": "EQ", "EQUAL": "EQ",
           "VARIABLE": "VAR", "EMPTYNESS": "NONE"}


def opname(name):
    return ALIASES.get(name, name)


def compact_uint(value):
    digits = encode_uint(value)
    return (64 + value,) if value < 16 else (T["END"], *digits)


def decode_compact_uint(code):
    from .scope import decode_uint
    if len(code) == 1 and type(code[0]) is int and 64 <= code[0] < 80:
        return code[0] - 64
    if len(code) == 5 and code[0] == T["END"]:
        value = decode_uint(code[1:])
        if value >= 16:
            return value
    raise ScopeExclusion("NONCANONICAL_NUMBER")


class Encoder:
    def __init__(self, record):
        self.r = record
        self.tokens = [T["BOS"]]
        self.sigs = {s["name"]: i for i, s in enumerate(record["signatures"])}
        self.rels = {s["name"]: i for i, s in enumerate(record["fields"])}
        self.aliases = {}
        for kind, rows in (("sig", record["signatures"]), ("rel", record["fields"])):
            for i, row in enumerate(rows):
                for alias in {row["name"], row["name"].removeprefix("this/"), row.get("label", row["name"].removeprefix("this/"))}:
                    if alias in self.aliases and self.aliases[alias] != (kind, i):
                        raise ScopeExclusion("AMBIGUOUS_SYMBOL_ALIAS")
                    self.aliases[alias] = kind, i
        if len(self.sigs) > 8 or len(self.rels) > 8 or record["sourceSlots"] > 8:
            raise ScopeExclusion("REFERENCE_BANK_EXHAUSTED")
        self.matrix_count = 0

    def emit(self, *names):
        self.tokens.extend(T[n] for n in names)

    def number(self, value):
        self.tokens.extend(compact_uint(value))

    def symbol(self, name):
        if name == "univ":
            self.emit("OP_UNIV")
            return
        if name not in self.aliases:
            raise ScopeExclusion("UNKNOWN_SYMBOL")
        kind, index = self.aliases[name]
        self.emit(f"${kind}{index}")

    def slot(self, value):
        if type(value) is not int or not 0 <= value < 8:
            raise ScopeExclusion("BINDER_SCOPE")
        self.emit(f"${value}")

    def operation(self, op):
        op = opname(op)
        if op in ("NOT_IN", "NOT_EQUALS", "NOT_EQUAL"):
            self.emit("OP_NOT", "OP_IN" if op == "NOT_IN" else "OP_EQ")
        elif op == "PREDICATE":
            self.emit("ROOT")
        elif op in ("QUANT_ALL", "QUANT_SOME"):
            self.emit(op)
        elif op in ("SETOF", "ONEOF", "LONEOF", "SOMEOF"):
            self.emit("SET" if op == "SETOF" else "OP_" + op.removesuffix("OF"))
        elif "OP_" + op in T and op not in ("UNIV", "IDEN"):
            self.emit("OP_" + op)
        else:
            raise ScopeExclusion("OPERATOR_" + op)

    def type(self, products):
        self.emit("TYPE")
        self.number(len(products))
        for product in products:
            if len(product) not in (1, 2, 3):
                raise ScopeExclusion("RELATION_ARITY")
            self.number(len(product))
            for name in product:
                self.symbol(name)

    def matrix(self, node):
        self.matrix_count += 1
        if self.matrix_count > 128:
            raise ScopeExclusion("MATRIX_SIZE")
        self.emit("NODE")
        if node["op"] == "GLOBALBINDING":
            self.emit("GLOBAL")
            self.symbol(node["payload"])
        elif node["op"] == "CONSTANT":
            self.operation(node["payload"].upper())
        else:
            self.operation(node["op"])
        self.emit({"ONE": "PORT", "SEQUENCE": "SEQ", "SET": "SET", "BAG": "BAG"}[node["container"]])
        if node["variable"]:
            self.slot(node["slot"])
        elif node["payload"] and node["op"] not in ("GLOBALBINDING", "CONSTANT"):
            raise ScopeExclusion("UNKNOWN_MATRIX_PAYLOAD")
        self.number(len(node["children"]))
        for child in node["children"]:
            self.matrix(child)
        self.emit("CLASS")
        self.number(len(node["alternatives"]))
        for alt in node["alternatives"]:
            self.matrix(alt)
        self.emit("END")

    def encode(self):
        r = self.r
        if r["schema"] != "hybrid-corpus-v1" or len(r["phases"]) != 1:
            raise ScopeExclusion("PROFILE")
        self.emit("PROFILE")
        self.number(r["bitwidth"])
        self.emit("GLOBAL")
        self.number(len(r["signatures"]))
        for sig in r["signatures"]:
            self.symbol(sig["name"])
            self.number(int(sig["subset"]) + 2 * int(sig["abstract"]))
            self.emit("SET" if sig["multiplicity"] == "SET" else "OP_" + sig["multiplicity"])
            parents = [p for p in sig["parents"] if p != "univ"]
            self.number(len(parents))
            for parent in parents:
                self.symbol(parent)
        self.number(len(r["fields"]))
        for field in r["fields"]:
            self.symbol(field["name"])
            self.type(field["type"])
            self.number(field["domain"])
        self.emit("SOURCE")
        self.number(r["root"])
        self.number(r["facts"])
        self.number(len(r["source"]))
        for node in r["source"]:
            self.emit("NODE")
            self.operation(node["op"])
            self.type(node["type"])
            if "symbol" in node:
                self.symbol(node["symbol"])
            if "slot" in node:
                self.slot(node["slot"])
            self.number(len(node["children"]))
            for child in node["children"]:
                self.number(child)
            self.number(len(node["binders"]))
            for b in node["binders"]:
                domain = r["source"][b["domain"]]
                if domain["op"] != "ONEOF" or len(domain["children"]) != 1:
                    raise ScopeExclusion("SOURCE_BINDER_DOMAIN")
                self.slot(b["slot"])
                self.number(b["domain"])
                self.number(b["disjoint"] + 1)
        self.emit("GRAPH")
        phase = r["phases"][0]
        if len(phase["bindings"]) > 8:
            raise ScopeExclusion("BINDER_SCOPE")
        self.number(len(phase["bindings"]))
        for i, b in enumerate(phase["bindings"]):
            if b["quantifier"] not in ("ALL", "SOME") or b["cardinality"] != "ONE" or b["role"] != "MATRIX":
                raise ScopeExclusion("BINDER_SCOPE")
            self.emit("BINDING", "QUANT_" + b["quantifier"])
            self.slot(i)
            self.symbol(b["type"])
            self.number(b["disjoint"] + 1)
            self.number(b["exchange"] + 1)
            self.number(b["coordinate"])
            for key in ("orbit", "dependencies"):
                self.number(len(b[key]))
                for index in b[key]:
                    self.number(index)
        self.matrix(phase["matrix"])
        if len(r["worlds"]) > 4:
            raise ScopeExclusion("WORLD_COUNT")
        self.emit("WORLD")
        self.number(len(r["worlds"]))
        for world in r["worlds"]:
            atoms = sorted({atom for tuples in world["relations"].values() for row in tuples for atom in row})
            if len(atoms) > 16 or sum(map(len, world["relations"].values())) > 128:
                raise ScopeExclusion("WORLD_SIZE")
            ids = {name: i for i, name in enumerate(atoms)}
            self.emit("OP_TRUE" if world["expected"] else "OP_FALSE", "OP_TRUE" if world["actual"] else "OP_FALSE")
            self.number(len(atoms))
            self.number(len(world["relations"]))
            for name, tuples in sorted(world["relations"].items(), key=lambda item: self.aliases[item[0]]):
                self.symbol(name)
                self.number(len(tuples))
                for row in tuples:
                    self.emit("TUPLE")
                    self.number(len(row))
                    for atom in row:
                        self.number(ids[atom])
        kept, positions = [], []
        for action in r["actions"]:
            before, after = opname(action["before"]), opname(action["after"])
            if before.startswith("QUANT_"):
                before = before.removeprefix("QUANT_")
                template = "QUANTIFIER_REPLACE"
            else:
                template = next((key for key, choices in TEMPLATES.items()
                                 if key != "QUANTIFIER_REPLACE" and before in choices and after in choices), None)
            if template is None or before not in TEMPLATES[template] or after not in TEMPLATES[template] or before == after:
                continue
            self.emit("ACTION", template)
            self.number(action["node"])
            self.operation("QUANT_" + after if template == "QUANTIFIER_REPLACE" else after)
            self.emit("END")
            positions.append(len(self.tokens) - 1)
            kept.append(dict(action, template=template, family=5 if template == "QUANTIFIER_REPLACE" else 8))
        if not 1 <= len(kept) <= 64:
            raise ScopeExclusion("SCOPED_MENU_SIZE")
        self.emit("QUERY")
        if len(self.tokens) > 2048:
            raise ScopeExclusion("TOKEN_BUDGET")
        if any(t not in CORPUS_TOKENS for t in self.tokens):
            raise ScopeExclusion("TOKEN_ALPHABET")
        return {"codec": "hybrid-corpus-input-v2", "tokens": self.tokens, "positions": positions, "actions": kept,
                "witness": int(any(w["expected"] and not w["actual"] for w in r["worlds"])),
                "value": sum(w["expected"] == w["actual"] for w in r["worlds"]) / len(r["worlds"])}


def encode(record):
    return Encoder(record).encode()
