"""Small relational GNN and conditional, public-mask semantic pointer heads."""
from dataclasses import dataclass
import torch
from torch import nn
from .replay import CONTROLS, decision
from .tables import TABLES


def bits(values):
    # Every int32 bit, including the sign, is retained before any learned map.
    return ((values.unsqueeze(-1) >> torch.arange(32, device=values.device)) & 1).float().flatten(-2)


class GraphPolicy(nn.Module):
    def __init__(self, width=128, layers=3):
        super().__init__()
        self.width = width
        self.kind = nn.Embedding(128, width)
        self.scalar = nn.Linear(16 * 32, width, bias=False)
        self.role = nn.Embedding(32, width)
        self.messages = nn.ModuleList(nn.Linear(width, width) for _ in range(layers))
        self.updates = nn.ModuleList(nn.Sequential(nn.Linear(width*2, width), nn.GELU(), nn.LayerNorm(width)) for _ in range(layers))
        self.context = nn.Sequential(nn.Linear(width*2, width), nn.GELU())
        self.choice = nn.Sequential(nn.Linear(16*32, width), nn.GELU())
        self.pointer = nn.Linear(width, width, bias=False)
        self.score = nn.Sequential(nn.Linear(width*2, width), nn.Tanh(), nn.Linear(width, 1))
        self.next_head = nn.GRUCell(width, width)

    def encode(self, graph):
        h = self.kind(graph.kinds) + self.scalar(bits(graph.values))
        src, dst = graph.edges
        for message, update in zip(self.messages, self.updates):
            incoming = torch.zeros_like(h)
            incoming.index_add_(0, dst, message(h[src]) + self.role(graph.roles))
            degree = torch.zeros(len(h), device=h.device).index_add_(0, dst, torch.ones(len(dst), device=h.device))
            h = h + update(torch.cat((h, incoming / degree.clamp_min(1).unsqueeze(1)), dim=1))
        state = h[graph.addresses['state', 0]]
        return h, self.context(torch.cat((h.mean(0), state)))

    def logits(self, h, query, candidates, addresses):
        vals, pointers = [], []
        for candidate in candidates:
            vals.append(candidate.features + [0] * (16-len(candidate.features)))
            pointers.append([addresses[ref] for ref in candidate.pointers])
        vectors = self.choice(bits(torch.tensor(vals, dtype=torch.int64, device=h.device)))
        for i, refs in enumerate(pointers):
            if refs:
                vectors = vectors.index_add(0, torch.tensor([i], device=h.device),
                                            self.pointer((h[refs] * torch.arange(1, len(refs)+1,
                                                device=h.device).unsqueeze(1)).sum(0)).unsqueeze(0))
        logits = self.score(torch.cat((query.expand(len(vectors), -1), vectors), dim=1)).squeeze(1)
        return logits, vectors


@dataclass
class Choice:
    fields: dict
    features: list
    pointers: list


def options(observation, field, partial, queries, query_limit=2):
    a = observation['actions']
    if field == 'control':
        return [Choice({'control': code}, [0, code], []) for code, in a['controls']
                if code not in (11, 12) or queries < query_limit]
    control = CONTROLS[partial['control']]
    if field == 'site':
        table = a['deletions' if control == 'DELETE' else 'sites']
        return [Choice(dict(zip(('family', 'site', 'pointer'), row)), [1, row[0]],
                       [('current.nodes', row[1])] + ([('current.nodes', row[2])] if len(row) == 3 else [])) for row in table]
    if field == 'pointer':
        table, target = {
            'COPY': ('copies', 'current.nodes'), 'SYMBOL': ('symbols', 'current.symbols'),
            'VARIABLE': ('variables', 'current.bindings'), 'DRAFT_VARIABLE': ('draftVariables', 'draftDeclarations'),
            'FEEDBACK_SYMBOL': ('feedbackSymbols', 'feedback.symbols'),
        }[control]
        result = []
        for value, in a[table]:
            address = value
            if control == 'DRAFT_VARIABLE':
                matches = [i for i, row in enumerate(observation['draftDeclarations']) if row[2] == value]
                if len(matches) != 1: raise ValueError('Draft binding not uniquely addressable')
                address = matches[0]
            result.append(Choice({'pointer': value}, [2, partial['control']], [(target, address)]))
        return result
    if field == 'operator':
        if control == 'CONSTANT':
            return [Choice({'operator': kind, 'value': value}, [3, kind, value], [])
                    for kind, lo, hi in a['constants'] for value in range(lo, hi+1)]
        return [Choice({'operator': op}, [4, op], []) for op, in a['quantifiers' if control == 'QUANTIFIER' else 'operators']]
    name = {'count': 'counts', 'disjoint': 'disjointness', 'cardinality': 'cardinalities'}[field]
    return [Choice({field: value}, [5 + ('count', 'disjoint', 'cardinality').index(field), value], [])
            for lo, hi in a[name] for value in range(lo, hi+1)]


def fields(control):
    name = CONTROLS[control]
    if name in ('BEGIN', 'DELETE'): return ['site']
    if name in ('COPY', 'SYMBOL', 'VARIABLE', 'DRAFT_VARIABLE', 'FEEDBACK_SYMBOL'): return ['pointer']
    if name in ('OPERATOR', 'CONSTANT'): return ['operator']
    if name == 'QUANTIFIER': return ['operator', 'count', 'disjoint', 'cardinality']
    if name == 'DECLARATION': return ['count', 'disjoint', 'cardinality']
    return []


def choose(model, graph, observation, queries, label=None, rng=None, query_limit=2):
    """Labels are used only as targets/preceding decoder choices in imitation."""
    h, query = model.encode(graph) if model is not None else (None, None)
    action, losses, matches = {}, [], []
    heads = ['control']
    for field in heads:
        candidates = options(observation, field, action, queries, query_limit)
        if not candidates: raise ValueError('Empty legal action head')
        if model is not None:
            logits, vectors = model.logits(h, query, candidates, graph.addresses)
            predicted = int(logits.argmax())
        else: predicted = rng.randrange(len(candidates))
        selected = predicted
        if label is not None:
            matching = [i for i, candidate in enumerate(candidates)
                        if all(label.get(k) == v for k, v in candidate.fields.items())]
            if len(matching) != 1: raise ValueError('Teacher outside exact public choices')
            selected = matching[0]
            losses.append(nn.functional.cross_entropy(logits[None, :], torch.tensor([selected], device=h.device)))
            matches.append(predicted == selected)
        action.update(candidates[selected].fields)
        if model is not None: query = model.next_head(vectors[selected], query)
        if field == 'control': heads.extend(fields(action['control']))
    decision(observation, action)
    return action, (torch.stack(losses).mean() if losses else None), matches
