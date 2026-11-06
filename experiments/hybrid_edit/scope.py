"""Pilot admission contracts. Adapter inventories are not semantic certificates."""

from dataclasses import dataclass


PROFILE = "relational-pilot-v2"
VOCAB_SIZE = 128
STRUCTURES = ("PAD", "BOS", "EOS", "GRAPH", "CLASS", "NODE", "PORT", "TYPE",
              "BINDING", "SOURCE", "WORLD", "ATOM", "TUPLE", "ACTION", "END", "QUERY",
              "SEQ", "SET", "BAG", "ROOT", "PROFILE", "GLOBAL", "DEPENDENCY", "DISJOINT")
OPERATORS = ("AND", "OR", "NOT", "TRUE", "FALSE", "IN", "EQ", "SOME", "NO", "ONE",
             "LONE", "UNION", "INTERSECT", "DIFFERENCE", "JOIN", "ARROW", "VAR", "SIG",
             "FIELD", "NONE", "UNIV")
ADMITTED_OPERATORS = frozenset(OPERATORS) | {"IDEN", "INT_LITERAL"}
TEMPLATES = {
    "BOOLEAN_REPLACE": ("AND", "OR"),
    "CARDINALITY_REPLACE": ("SOME", "NO", "ONE", "LONE"),
    "SET_REPLACE": ("UNION", "INTERSECT", "DIFFERENCE"),
    "QUANTIFIER_REPLACE": ("ALL", "SOME"),
}
TOKENS = {name: index for index, name in enumerate(STRUCTURES)}
TOKENS.update({"OP_" + name: 24 + i for i, name in enumerate(OPERATORS)})
TOKENS.update({"QUANT_ALL": 45, "QUANT_SOME": 46})
TOKENS.update({name: 47 + i for i, name in enumerate(TEMPLATES)})
TOKENS["OP_IDEN"] = 51
TOKENS.update({f"INT_{i}": 52 + i for i in range(5)})
TOKENS.update({f"$sig{i}": 80 + i for i in range(8)})
TOKENS.update({f"${i}": 88 + i for i in range(8)})
TOKENS.update({f"$rel{i}": 96 + i for i in range(8)})
REFERENCE_BANKS = {"signature": (80, 8), "slot": (88, 8), "relation": (96, 8)}
CONSTANT_TOKENS = {name: TOKENS["OP_" + name.upper()]
                   for name in ("true", "false", "none", "univ", "iden")}
DIGIT_START = 64
ASSIGNED = frozenset(TOKENS.values()) | frozenset(range(DIGIT_START, DIGIT_START + 16))
LIMITS = {"eclasses": 64, "enodes": 128, "source_nodes": 256, "bindings": 8,
          "globals": 16, "types": 16, "worlds": 4, "max_world_atoms": 8,
          "max_world_tuples": 128, "signatures": 8, "relations": 8}
MAX_ACTIONS = 64
MAX_TOKENS = 2048


class ScopeExclusion(ValueError):
    def __init__(self, reason):
        self.reason = reason
        super().__init__(reason)


def encode_reference(kind, index):
    """Encode an already canonicalized coordinate, not a source spelling."""
    if kind not in REFERENCE_BANKS:
        raise ScopeExclusion("REFERENCE_KIND")
    base, size = REFERENCE_BANKS[kind]
    if type(index) is not int or not 0 <= index < size:
        raise ScopeExclusion("REFERENCE_BANK_EXHAUSTED")
    return (base + index,)


def decode_reference(kind, tokens):
    if kind not in REFERENCE_BANKS:
        raise ScopeExclusion("REFERENCE_KIND")
    base, size = REFERENCE_BANKS[kind]
    if len(tokens) != 1 or type(tokens[0]) is not int or not base <= tokens[0] < base + size:
        raise ScopeExclusion("INVALID_REFERENCE_TOKEN")
    return tokens[0] - base


def encode_integer_literal(value, *, bitwidth):
    if type(value) is not int or not 0 <= value <= 4:
        raise ScopeExclusion("INTEGER_LITERAL_RANGE")
    if type(bitwidth) is not int or bitwidth < 1 or value.bit_length() >= bitwidth:
        raise ScopeExclusion("INTEGER_LITERAL_BITWIDTH")
    return (52 + value,)


def decode_integer_literal(tokens, *, bitwidth):
    if len(tokens) != 1 or type(tokens[0]) is not int or not 52 <= tokens[0] <= 56:
        raise ScopeExclusion("INVALID_INTEGER_LITERAL_TOKEN")
    value = tokens[0] - 52
    encode_integer_literal(value, bitwidth=bitwidth)
    return value


def encode_constant(kind):
    if kind not in CONSTANT_TOKENS:
        raise ScopeExclusion("CONSTANT_KIND")
    return (CONSTANT_TOKENS[kind],)


def decode_constant(tokens):
    if len(tokens) != 1 or type(tokens[0]) is not int:
        raise ScopeExclusion("INVALID_CONSTANT_TOKEN")
    for kind, token in CONSTANT_TOKENS.items():
        if tokens[0] == token:
            return kind
    raise ScopeExclusion("INVALID_CONSTANT_TOKEN")


def encode_uint(value):
    if type(value) is not int or not 0 <= value < 65536:
        raise ScopeExclusion("NUMERIC_PAYLOAD_OUT_OF_RANGE")
    return tuple(DIGIT_START + ((value >> shift) & 15) for shift in (0, 4, 8, 12))


def decode_uint(tokens):
    if len(tokens) != 4 or any(type(t) is not int or not 64 <= t < 80 for t in tokens):
        raise ScopeExclusion("INVALID_NUMERIC_PAYLOAD")
    return sum((t - DIGIT_START) << shift for t, shift in zip(tokens, (0, 4, 8, 12)))


def validate_tokens(tokens):
    if not 2 <= len(tokens) <= MAX_TOKENS:
        raise ScopeExclusion("TOKEN_BUDGET")
    if any(type(t) is not int or t not in ASSIGNED for t in tokens):
        raise ScopeExclusion("UNASSIGNED_TOKEN")
    if tokens[0] != TOKENS["BOS"] or tokens[-1] != TOKENS["QUERY"]:
        raise ScopeExclusion("PACKET_BOUNDARY")
    # This is the alphabet/budget gate, not a full graph record parser.


@dataclass(frozen=True)
class Inventory:
    profile: str
    phase_count: int
    source_features: tuple[str, ...]
    operators: tuple[str, ...]
    relation_arities: tuple[int, ...]
    quantifiers: tuple[str, ...]
    binder_multiplicities: tuple[str, ...]
    binder_primitive_domains: tuple[bool, ...]
    eclasses: int
    enodes: int
    source_nodes: int
    bindings: int
    globals: int
    types: int
    worlds: int
    max_world_atoms: int
    max_world_tuples: int
    signatures: int
    relations: int
    integer_literals: tuple[int, ...]
    integer_bitwidth: int


def validate_inventory(item):
    if item.profile != PROFILE:
        raise ScopeExclusion("PROFILE_MISMATCH")
    if type(item.phase_count) is not int or item.phase_count != 1:
        raise ScopeExclusion("TEMPORAL_PHASE")
    if ("BOOLEAN" not in item.source_features
            or set(item.source_features) - {"BOOLEAN", "RELATIONAL", "ATOM_BINDER", "DISJ", "INT_LITERAL"}):
        raise ScopeExclusion("SOURCE_FEATURE")
    if set(item.operators) - ADMITTED_OPERATORS:
        raise ScopeExclusion("MATRIX_OPERATOR")
    if any(type(arity) is not int or arity not in (1, 2) for arity in item.relation_arities):
        raise ScopeExclusion("RELATION_ARITY")
    for name, limit in LIMITS.items():
        count = getattr(item, name)
        minimum = 1 if name in ("eclasses", "enodes", "source_nodes") else 0
        if type(count) is not int or not minimum <= count <= limit:
            raise ScopeExclusion("SIZE_" + name.upper())
    if item.globals != item.signatures + item.relations:
        raise ScopeExclusion("GLOBAL_INVENTORY")
    if type(item.integer_bitwidth) is not int or item.integer_bitwidth < 1:
        raise ScopeExclusion("INTEGER_LITERAL_BITWIDTH")
    if (bool(item.integer_literals) != ("INT_LITERAL" in item.source_features)
            or ("INT_LITERAL" in item.operators and not item.integer_literals)):
        raise ScopeExclusion("INTEGER_LITERAL_INVENTORY")
    for literal in item.integer_literals:
        encode_integer_literal(literal, bitwidth=item.integer_bitwidth)
    if not (len(item.quantifiers) == len(item.binder_multiplicities)
            == len(item.binder_primitive_domains) == item.bindings):
        raise ScopeExclusion("BINDER_INVENTORY")
    if (any(q not in ("ALL", "SOME") for q in item.quantifiers)
            or any(m != "ONE" for m in item.binder_multiplicities)
            or any(primitive is not True for primitive in item.binder_primitive_domains)):
        raise ScopeExclusion("BINDER_SCOPE")


@dataclass(frozen=True)
class Proposal:
    template: str
    before: str
    after: str
    source_occurrence: int
    exact_type_matches: bool

    @property
    def family(self):
        if self.template not in TEMPLATES:
            raise ScopeExclusion("ACTION_TEMPLATE")
        return "BINDING_UPDATE" if self.template == "QUANTIFIER_REPLACE" else "MATRIX_UPDATE"


@dataclass(frozen=True)
class ScopedMenu:
    actions: tuple[Proposal, ...]
    excluded: tuple[tuple[int, str], ...]


def scoped_menu(inventory, proposals, *, source_menu_truncated):
    validate_inventory(inventory)
    if source_menu_truncated is not False:
        raise ScopeExclusion("UPSTREAM_MENU_TRUNCATED")
    kept, excluded = [], []
    for index, proposal in enumerate(proposals):
        choices = TEMPLATES.get(proposal.template, ())
        reason = None
        if proposal.before not in choices or proposal.after not in choices:
            reason = "ACTION_TEMPLATE"
        elif proposal.before == proposal.after:
            reason = "IDENTITY_ACTION"
        elif (type(proposal.source_occurrence) is not int
              or not 0 <= proposal.source_occurrence < inventory.source_nodes):
            reason = "ACTION_SOURCE_POINTER"
        elif proposal.exact_type_matches is not True:
            reason = "ACTION_TYPE"
        if reason:
            excluded.append((index, reason))
        elif proposal in kept:
            excluded.append((index, "DUPLICATE_ACTION"))
        else:
            kept.append(proposal)
    if not kept:
        raise ScopeExclusion("NO_SCOPED_ACTION")
    if len(kept) > MAX_ACTIONS:
        raise ScopeExclusion("ACTION_BUDGET")
    return ScopedMenu(tuple(kept), tuple(excluded))
