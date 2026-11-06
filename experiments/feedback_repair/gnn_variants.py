"""Public-table GNN alternatives sharing one pointer/action interface."""
import math
import torch
from torch import nn
from .policy import bits, GraphPolicy
from .tables import TABLES

VARIANTS = ('original', 'mlp', 'gcn', 'sage', 'gin', 'gat')


def channel_means(h, kinds):
    sums = h.new_zeros((len(TABLES), h.shape[1])).index_add(0, kinds, h)
    counts = h.new_zeros(len(TABLES)).index_add(0, kinds, h.new_ones(len(h)))
    return sums / counts.clamp_min(1).unsqueeze(1), counts > 0


class MessageLayer(nn.Module):
    def __init__(self, width, variant, heads=4):
        super().__init__()
        self.variant, self.heads, self.width = variant, heads, width
        self.norm = nn.LayerNorm(width)
        if variant != 'mlp':
            self.message = nn.Linear(width, width, bias=False)
            self.role = nn.Embedding(32, width)
        self.update = nn.Sequential(nn.Linear(width * 2, width * 2), nn.GELU(),
                                    nn.Linear(width * 2, width), nn.LayerNorm(width))
        if variant == 'gin': self.epsilon = nn.Parameter(torch.zeros(()))
        if variant == 'gat':
            if width % heads: raise ValueError('GAT width must divide into heads')
            self.query = nn.Linear(width, width, bias=False)
            self.key = nn.Linear(width, width, bias=False)

    def forward(self, h, graph):
        x = self.norm(h)
        src, dst = graph.edges
        incoming = torch.zeros_like(x)
        if self.variant == 'mlp':
            return h + self.update(torch.cat((x, incoming), -1))
        degree = x.new_zeros(len(x)).index_add(0, dst, x.new_ones(len(dst)))
        messages = self.message(x[src]) + self.role(graph.roles)
        if self.variant == 'gcn':
            norm = ((degree[src] + 1) * (degree[dst] + 1)).rsqrt()
            incoming = incoming.index_add(0, dst, messages * norm[:, None])
            incoming = incoming + self.message(x) / (degree + 1)[:, None]
        elif self.variant == 'gat':
            shape = (-1, self.heads, self.width // self.heads)
            q, k = self.query(x).reshape(shape), self.key(x).reshape(shape)
            edge = self.role(graph.roles).reshape(shape)
            energy = (q[dst] * (k[src] + edge)).sum(-1) / math.sqrt(shape[-1])
            index = dst[:, None].expand(-1, self.heads)
            peak = x.new_full((len(x), self.heads), -torch.inf)
            peak = peak.scatter_reduce(0, index, energy, reduce='amax', include_self=True)
            weight = (energy - peak[dst]).exp()
            denom = x.new_zeros((len(x), self.heads)).index_add(0, dst, weight)
            weight = weight / denom[dst].clamp_min(torch.finfo(x.dtype).tiny)
            incoming = incoming.index_add(0, dst, (messages.reshape(shape) * weight[:, :, None]).flatten(1))
        else:
            incoming = incoming.index_add(0, dst, messages)
            if self.variant == 'sage': incoming = incoming / degree.clamp_min(1)[:, None]
            elif self.variant == 'gin': incoming = incoming + (1 + self.epsilon) * x
            else: raise ValueError(self.variant)
        return h + self.update(torch.cat((x, incoming), -1))


class VariantPolicy(nn.Module):
    def __init__(self, variant, width=128, layers=3):
        super().__init__()
        if variant not in VARIANTS[1:]: raise ValueError(variant)
        self.variant, self.width = variant, width
        self.kind = nn.Embedding(128, width)
        self.scalar = nn.Linear(512, width, bias=False)
        self.input_norm = nn.LayerNorm(width)
        self.layers = nn.ModuleList(MessageLayer(width, variant) for _ in range(layers))
        self.output_norm = nn.LayerNorm(width)
        # Fixed table channels plus explicit public anchors, not graph row IDs.
        self.context = nn.Sequential(nn.Linear((len(TABLES) + 6) * width, width),
                                     nn.GELU(), nn.LayerNorm(width))
        self.choice = nn.Sequential(nn.Linear(512, width), nn.GELU())
        self.pointer = nn.Linear(width, width, bias=False)
        self.query_score = nn.Sequential(nn.Linear(width, width), nn.LayerNorm(width))
        self.candidate_score = nn.LayerNorm(width)
        self.prior = nn.Linear(width, 1)
        self.next_head = nn.GRUCell(width, width)

    def encode(self, graph):
        h = self.input_norm(self.kind(graph.kinds) + self.scalar(bits(graph.values).to(self.scalar.weight.dtype)))
        for layer in self.layers: h = layer(h, graph)
        h = self.output_norm(h)
        channels, _ = channel_means(h, graph.kinds)
        def anchor(table, index=0):
            address = graph.addresses.get((table, index))
            return h[address] if address is not None else h.new_zeros(self.width)
        history = [i for table, i in graph.addresses if table == 'history']
        anchors = [anchor('state'), anchor('current.nodes'), anchor('initial.nodes'),
                   anchor('draft'), anchor('holes'), anchor('history', max(history, default=-1))]
        return h, self.context(torch.cat((channels.flatten(), *anchors)))

    def logits(self, h, query, candidates, addresses):
        vals = [c.features + [0] * (16-len(c.features)) for c in candidates]
        vectors = self.choice(bits(torch.tensor(vals, dtype=torch.int64, device=h.device)).to(h.dtype))
        for i, c in enumerate(candidates):
            if c.pointers:
                refs = [addresses[ref] for ref in c.pointers]
                weights = torch.arange(1, len(refs)+1, device=h.device, dtype=h.dtype)
                pointer = self.pointer((h[refs] * weights[:, None]).sum(0))
                vectors = vectors.index_add(0, torch.tensor([i], device=h.device), pointer[None])
        scores = (self.candidate_score(vectors) * self.query_score(query)).sum(-1) / math.sqrt(self.width)
        return scores + self.prior(vectors).squeeze(-1), vectors


def make_policy(variant, width=128, layers=3):
    if variant == 'original': return GraphPolicy(width, layers)
    return VariantPolicy(variant, width, layers)
