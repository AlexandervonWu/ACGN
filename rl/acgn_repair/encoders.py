"""Sparse, edge-aware graph encoders over occurrence-preserving messages."""

import hashlib
from pathlib import Path
import torch
from torch import nn
from torch.nn import functional as F


ENCODERS = ("mpnn", "gcn", "gat", "gin", "egraph_transformer")
MAX_EDGES = 65536


def graph_contract_hash():
    proof = Path(__file__).resolve().parents[2] / "docs/rl-repair/formal/GraphEncoders.lean"
    return hashlib.sha256(proof.read_bytes() + b"\0" + Path(__file__).read_bytes()).hexdigest()


def message_schedule(node_count, edges, self_loops=False):
    if not 0 < node_count <= 4096 or len(edges) > MAX_EDGES:
        raise ValueError("Graph occurrence bound violated")
    messages = []
    for source, target, kind, position in edges:
        if (type(source) is not int or type(target) is not int or type(position) is not int
                or not 0 <= source < node_count or not 0 <= target < node_count
                or position < 0 or not isinstance(kind, str)):
            raise ValueError("Invalid graph edge")
        messages.extend(((source, target, kind, position), (target, source, "reverse:" + kind, position)))
    if self_loops:
        messages.extend((i, i, "SELF", 0) for i in range(node_count))
    return messages


class GatedEncoder(nn.Module):
    self_loops = False

    def __init__(self, hidden, layers):
        super().__init__()
        self.messages = nn.ModuleList(nn.Linear(hidden * 2, hidden) for _ in range(layers))
        self.updates = nn.ModuleList(nn.GRUCell(hidden, hidden) for _ in range(layers))
        self.norms = nn.ModuleList(nn.LayerNorm(hidden) for _ in range(layers))

    def forward(self, h, src, dst, edge):
        if src.numel():
            for message, update, norm in zip(self.messages, self.updates, self.norms):
                values = torch.tanh(message(torch.cat((h[src], edge), dim=-1)))
                aggregated = torch.zeros_like(h).index_add(0, dst, values)
                h = norm(update(aggregated, h))
        return h


class GCNLayer(nn.Module):
    def __init__(self, hidden):
        super().__init__()
        self.node = nn.Linear(hidden, hidden, bias=False)
        self.edge = nn.Linear(hidden, hidden, bias=False)
        self.norm = nn.LayerNorm(hidden)

    def forward(self, h, src, dst, edge):
        degree = h.new_zeros(h.shape[0]).index_add(0, dst, h.new_ones(src.shape[0]))
        weight = (degree[src] * degree[dst]).rsqrt()
        values = (self.node(h)[src] + self.edge(edge)) * weight[:, None]
        return self.norm(F.relu(torch.zeros_like(h).index_add(0, dst, values)))


def destination_softmax(scores, dst, nodes):
    if not bool(torch.isfinite(scores).all()):
        raise ValueError("Non-finite attention scores")
    maxima = scores.new_full((nodes, scores.shape[1]), -torch.inf).scatter_reduce(
        0, dst[:, None].expand_as(scores), scores.detach(), reduce="amax", include_self=True)
    weights = (scores - maxima[dst]).exp()
    totals = scores.new_zeros((nodes, scores.shape[1])).index_add(0, dst, weights)
    return weights / totals[dst]


class GATLayer(nn.Module):
    def __init__(self, hidden, heads):
        super().__init__()
        self.heads = heads
        self.width = hidden // heads
        self.node = nn.Linear(hidden, hidden, bias=False)
        self.edge = nn.Linear(hidden, hidden, bias=False)
        self.source_attention = nn.Parameter(torch.empty(heads, self.width))
        self.target_attention = nn.Parameter(torch.empty(heads, self.width))
        self.edge_attention = nn.Parameter(torch.empty(heads, self.width))
        for parameter in (self.source_attention, self.target_attention, self.edge_attention):
            nn.init.xavier_uniform_(parameter)
        self.norm = nn.LayerNorm(hidden)

    def messages(self, h, src, dst, edge):
        projected = self.node(h).reshape(h.shape[0], self.heads, self.width)
        relations = self.edge(edge).reshape(edge.shape[0], self.heads, self.width)
        scores = ((projected[src] * self.source_attention).sum(-1)
                  + (projected[dst] * self.target_attention).sum(-1)
                  + (relations * self.edge_attention).sum(-1))
        scores = F.leaky_relu(scores, negative_slope=0.2)
        alpha = destination_softmax(scores, dst, h.shape[0])
        return alpha, projected[src] + relations

    def forward(self, h, src, dst, edge):
        alpha, values = self.messages(h, src, dst, edge)
        weighted = (alpha[:, :, None] * values).reshape(src.shape[0], -1)
        aggregated = torch.zeros_like(h).index_add(0, dst, weighted)
        return self.norm(F.elu(aggregated))


class GINLayer(nn.Module):
    def __init__(self, hidden):
        super().__init__()
        self.edge = nn.Linear(hidden, hidden, bias=False)
        self.epsilon = nn.Parameter(torch.zeros(()))
        self.mlp = nn.Sequential(nn.Linear(hidden, hidden * 2), nn.ReLU(), nn.Linear(hidden * 2, hidden))
        self.norm = nn.LayerNorm(hidden)

    def forward(self, h, src, dst, edge):
        values = F.relu(h[src] + self.edge(edge))
        neighbors = torch.zeros_like(h).index_add(0, dst, values)
        return self.norm(self.mlp((1 + self.epsilon) * h + neighbors))


class LayeredEncoder(nn.Module):
    def __init__(self, family, hidden, layers, heads):
        super().__init__()
        self.self_loops = family in ("gcn", "gat")
        constructors = {"gcn": lambda: GCNLayer(hidden), "gat": lambda: GATLayer(hidden, heads),
                        "gin": lambda: GINLayer(hidden)}
        self.layers = nn.ModuleList(constructors[family]() for _ in range(layers))

    def forward(self, h, src, dst, edge):
        for layer in self.layers:
            h = layer(h, src, dst, edge)
        return h


def make_encoder(family, hidden, layers, heads):
    if family == "egraph_transformer":
        from .transformer import EGraphTransformerEncoder
        return EGraphTransformerEncoder(hidden, layers, heads)
    if family == "mpnn":
        return GatedEncoder(hidden, layers)
    return LayeredEncoder(family, hidden, layers, heads)
