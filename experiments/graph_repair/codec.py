"""128-token, source-only DAG dictionary and replayable COPY/BUILD programs."""
import json

PAD, BOS, SEP, EOS, COPY, BUILD, BIG, NEG, TEXT, SREF, LIST, NULL, FALSE, TRUE, END, TABLE = range(16)
WORDS = ("ROOT PHASE BINDING TEMPORAL SCHEMA DOCUMENT SIG FIELD PREDICATE "
         "AND OR NOT TRUE FALSE IN NOT_IN EQUALS NOT_EQUALS SOME NO ONE LONE ALL NONE "
         "PLUS INTERSECT MINUS JOIN ARROW VARIABLE GLOBALBINDING CONSTANT REF "
         "SEQUENCE SET BAG MATRIX PARAMETER INHERITED LOCAL_INHERITED "
         "ALWAYS EVENTUALLY AFTER BEFORE ONCE HISTORICALLY UNTIL RELEASES SINCE TRIGGERED "
         "FORALL EXISTS CLOSURE RCLOSURE TRANSPOSE CARDINALITY CALL SHADOW DOMAIN RANGE "
         "univ none iden SYMBOLS").split()
assert len(WORDS) <= 64
STRINGS = {word: 32+i for i, word in enumerate(WORDS)}
STRINGS.update({f"$sig{i}": 96+i for i in range(8)})
STRINGS.update({f"$rel{i}": 104+i for i in range(8)})
STRINGS.update({f"${i}": 112+i for i in range(8)})
INVERSE = {v:k for k,v in STRINGS.items()}
assert len(INVERSE) == len(STRINGS) and max(INVERSE) < 128


def uint(n):
    if type(n) is not int or not 0 <= n < 65536:
        raise ValueError("NUMBER_BOUND")
    return [16+n] if n < 16 else [BIG, *(16+((n >> shift)&15) for shift in (0,4,8,12))]


def label_tokens(value, strings=()):
    if value is None: return [NULL]
    if type(value) is bool: return [TRUE if value else FALSE]
    if type(value) is int: return ([NEG] + uint(-value)) if value < 0 else uint(value)
    if isinstance(value, (list, tuple)):
        return [LIST, *uint(len(value)), *(t for x in value for t in label_tokens(x, strings))]
    if isinstance(value, str):
        if value in STRINGS: return [STRINGS[value]]
        if value in strings: return [SREF, *uint(strings.index(value))]
        raw = value.encode('utf-8')
        return [TEXT, *uint(len(raw)), *(t for b in raw for t in (16+(b>>4),16+(b&15)))]
    raise ValueError("Unsupported graph label")


def freeze(value):
    if isinstance(value, list): return tuple(map(freeze,value))
    return value


def tree(raw):
    return freeze(raw['label']), tuple(tree(c) for c in raw['children'])


def identity(value):
    # JSON keeps booleans distinct from numbers, unlike Python tuple equality.
    return json.dumps(value, separators=(',', ':'), ensure_ascii=False)


def dag(root):
    nodes, index = [], {}
    def visit(t):
        key = identity(t)
        if key in index: return index[key]
        children = [visit(c) for c in t[1]]
        i = len(nodes)
        nodes.append((t[0], children))
        index[key] = i
        return i
    root_id = visit(root)
    return nodes, index, root_id


def dictionary(nodes):
    result = []
    def visit(x):
        if isinstance(x, str) and x not in STRINGS and x not in result: result.append(x)
        elif isinstance(x, (tuple,list)):
            for y in x: visit(y)
    for label,_ in nodes: visit(label)
    return result


def prefix(root):
    nodes, index, root_id = dag(root)
    strings = dictionary(nodes)
    tokens = [BOS, TABLE, *uint(len(strings))]
    for s in strings: tokens += label_tokens(s)
    tokens += uint(len(nodes))
    for label, children in nodes:
        tokens += [BUILD, *label_tokens(label,strings), *uint(len(children))]
        for i in children: tokens += uint(i)
    tokens += [*uint(root_id), SEP]
    return tokens, nodes, index, strings


def compile_patch(target, index, strings):
    key = identity(target)
    if key in index: return [COPY, *uint(index[key])]
    label, children = target
    result = [BUILD, *label_tokens(label,strings), *uint(len(children))]
    for child in children: result += compile_patch(child,index,strings)
    return result


class Need(Exception):
    def __init__(self, allowed): self.allowed = frozenset(allowed)


class Reader:
    def __init__(self, tokens, strings=(), nodes=()):
        self.tokens, self.strings, self.nodes, self.i = tokens, strings, nodes, 0
    def take(self, allowed):
        allowed = frozenset(allowed)
        if self.i == len(self.tokens): raise Need(allowed)
        t = self.tokens[self.i]; self.i += 1
        if t not in allowed: raise ValueError("GRAMMAR")
        return t
    def number(self):
        t = self.take([BIG,*range(16,32)])
        if t != BIG: return t-16
        n = sum((self.take(range(16,32))-16)<<shift for shift in (0,4,8,12))
        if n < 16: raise ValueError("NONCANONICAL_NUMBER")
        return n
    def label(self, depth=0):
        if depth > 64: raise ValueError("LABEL_DEPTH")
        t = self.take([BIG,NEG,TEXT,LIST,NULL,FALSE,TRUE,*range(16,32),*INVERSE,
                       *([SREF] if self.strings else [])])
        if t in INVERSE: return INVERSE[t]
        if t in (NULL,FALSE,TRUE): return {NULL:None,FALSE:False,TRUE:True}[t]
        if t == NEG:
            n = self.number()
            if not n: raise ValueError("NEGATIVE_ZERO")
            return -n
        if t == LIST:
            n = self.number()
            if n > 256: raise ValueError("LABEL_ARITY")
            return tuple(self.label(depth+1) for _ in range(n))
        if t == SREF:
            i = self.number()
            if i >= len(self.strings): raise ValueError("STRING_REFERENCE")
            return self.strings[i]
        if t == TEXT:
            n = self.number()
            if n > 4096: raise ValueError("TEXT_BOUND")
            raw = bytes((self.take(range(16,32))-16)*16 + self.take(range(16,32))-16 for _ in range(n))
            return raw.decode('utf-8')
        self.i -= 1
        return self.number()
    def program(self, depth=0):
        if depth > 128: raise ValueError("PROGRAM_DEPTH")
        choices = [BUILD] + ([COPY] if self.nodes else [])
        t = self.take(choices)
        if t == COPY:
            i = self.number()
            if i >= len(self.nodes): raise ValueError("SOURCE_REFERENCE")
            return self.nodes[i]
        label = self.label()
        n = self.number()
        if n > 256: raise ValueError("NODE_ARITY")
        return label, tuple(self.program(depth+1) for _ in range(n))


def source_terms(nodes):
    result = []
    for label, children in nodes:
        if any(type(i) is not int or not 0 <= i < len(result) for i in children):
            raise ValueError("NON_TOPOLOGICAL_GRAPH")
        result.append((freeze(label), tuple(result[i] for i in children)))
    return result


def replay(tokens, strings, nodes):
    reader = Reader(tokens, strings, source_terms(nodes))
    result = reader.program()
    reader.take([EOS])
    if reader.i != len(tokens): raise ValueError("TRAILING_PROGRAM")
    return result


def allowed_next(tokens, strings, terms):
    reader = Reader(tokens, strings, terms)
    try:
        reader.program(); reader.take([EOS])
        if reader.i != len(tokens): return frozenset()
        return frozenset([EOS])
    except Need as need: return need.allowed
    except (ValueError, UnicodeDecodeError, RecursionError): return frozenset()


def decode_prefix(tokens):
    r = Reader(tokens)
    r.take([BOS]); r.take([TABLE])
    count = r.number()
    strings = [r.label() for _ in range(count)]
    if any(not isinstance(s,str) for s in strings) or len(set(strings)) != len(strings):
        raise ValueError("STRING_TABLE")
    r.strings = strings
    nodes = []
    for _ in range(r.number()):
        r.take([BUILD]); label = r.label()
        children = [r.number() for _ in range(r.number())]
        nodes.append((label,children))
    root = r.number(); r.take([SEP])
    terms = source_terms(nodes)
    if root >= len(terms) or r.i != len(tokens): raise ValueError("ROOT")
    return terms[root], nodes, strings


def encode_pair(raw, max_tokens=4096, max_target=1536):
    context = tree(raw['context'])
    if raw.get('symbolMap'):
        symbols = tuple(sorted(raw['symbolMap'].items()))
        context = context[0], context[1]+((("SYMBOLS",symbols),()),)
    source = (("DOCUMENT",), (context, tree(raw['source'])))
    target = tree(raw['target'])
    key, nodes, index, strings = prefix(source)
    program = compile_patch(target,index,strings)+[EOS]
    if identity(replay(program,strings,nodes)) != identity(target): raise AssertionError("TEACHER_REPLAY")
    if identity(decode_prefix(key)[0]) != identity(source): raise AssertionError("INPUT_ROUNDTRIP")
    if len(key)+len(program) > max_tokens or len(program)>max_target:
        raise ValueError("TOKEN_BOUND")
    return {'key':key,'value':program,'nodes':nodes,'strings':strings,'target':target,
            'sourceRoot':len(nodes)-1,'codec':'graph-patch-128-v2'}
