"""Local/latent-global graph encoder and menu-bound graph-edit decoder."""

import hashlib
import json
from pathlib import Path
import torch
from torch import nn
from torch.nn import functional as F


LATENT_SLOTS = 8
GRAPH_FILES = ("EGraph2Graph.lean", "EGraph2GraphRunner.lean")


def transformer_contract_hash():
    root = Path(__file__).resolve().parents[2]
    paths = [root / "docs/rl-repair/formal" / name for name in GRAPH_FILES]
    paths += [Path(__file__), Path(__file__).with_name("model.py")]
    digest = hashlib.sha256()
    for path in paths:
        digest.update(path.name.encode() + b"\0" + path.read_bytes() + b"\0")
    return digest.hexdigest()


def request_valid(r):
    natural = lambda x: type(x) is int and x >= 0
    if any(not natural(r[k]) for k in ("nodes", "width", "heads", "layers", "slots")):
        return False
    n, w, heads = r["nodes"], r["width"], r["heads"]
    return (0 < n <= 4096 and len(r["edges"]) <= 65536
            and all(natural(e["source"]) and natural(e["target"]) and natural(e["position"])
                    and isinstance(e["kind"], str) and e["source"] < n and e["target"] < n for e in r["edges"])
            and 0 < len(r["actions"]) <= 512 and all(natural(a) and a < n for a in r["actions"])
            and len(r["allowed"]) == len(r["actions"]) and all(type(a) is bool for a in r["allowed"])
            and any(r["allowed"]) and 8 <= w <= 16384 and 0 < heads <= 16 and w % heads == 0
            and 0 < r["layers"] <= 8 and r["slots"] == LATENT_SLOTS)


def graph_request(observation, architecture, allowed=None):
    if observation["schema"] != "repair-structured-graphs-v1" or architecture["encoder"] != "egraph_transformer":
        raise ValueError("Incompatible graph transformer request")
    request = {"nodes": len(observation["nodes"]),
               "edges": [dict(zip(("source", "target", "kind", "position"), e)) for e in observation["edges"]],
               "actions": [a["node"] for a in observation["actions"]],
               "allowed": [True] * len(observation["actions"]) if allowed is None else list(allowed),
               "width": architecture["hidden"], "heads": architecture["heads"],
               "layers": architecture["layers"], "slots": architecture["latentSlots"]}
    if any(len(e) != 4 for e in observation["edges"]) or not request_valid(request):
        raise ValueError("Invalid graph transformer structural request")
    return request


def verify_graph_trace(traces, architecture):
    steps = [t for t in traces if "step" in t and t.get("mode") in ("train", "learned")]
    contract = transformer_contract_hash()
    if architecture.get("transformerContractHash") != contract:
        raise ValueError("Trace architecture contract mismatch")
    for step in steps:
        request = graph_request(step["observation"], architecture)
        payload = json.dumps(request, separators=(",", ":"), sort_keys=True, allow_nan=False) + "\n"
        expected = {"contractHash": contract, "requestHash": hashlib.sha256(payload.encode("utf-8")).hexdigest()}
        if step.get("graphAdmission") != expected:
            raise ValueError("Graph receipt does not match recorded observation")
    return len(steps)


class GraphTransformerLayer(nn.Module):
    def __init__(self, hidden, heads):
        super().__init__()
        self.pre = nn.LayerNorm(hidden)
        self.local_node = nn.Linear(hidden, hidden, bias=False)
        self.local_edge = nn.Linear(hidden, hidden, bias=False)
        self.latents = nn.Parameter(torch.empty(LATENT_SLOTS, hidden))
        nn.init.normal_(self.latents, std=hidden ** -0.5)
        self.read = nn.MultiheadAttention(hidden, heads, dropout=0.0, batch_first=True)
        self.write = nn.MultiheadAttention(hidden, heads, dropout=0.0, batch_first=True)
        self.ff_norm = nn.LayerNorm(hidden)
        self.ff = nn.Sequential(nn.Linear(hidden, 4 * hidden), nn.GELU(), nn.Linear(4 * hidden, hidden))

    def forward(self, h, src, dst, edge):
        z = self.pre(h)
        messages = F.gelu(self.local_node(z)[src] + self.local_edge(edge))
        local = torch.zeros_like(z).index_add(0, dst, messages)
        latent = self.latents + self.read(self.latents, z, z, need_weights=False)[0]
        global_values = self.write(z, latent, latent, need_weights=False)[0]
        h = h + local + global_values
        return h + self.ff(self.ff_norm(h))


class EGraphTransformerEncoder(nn.Module):
    self_loops = False

    def __init__(self, hidden, layers, heads):
        super().__init__()
        self.layers = nn.ModuleList(GraphTransformerLayer(hidden, heads) for _ in range(layers))

    def forward(self, h, src, dst, edge):
        for layer in self.layers:
            h = layer(h, src, dst, edge)
        return h


class GraphEditDecoder(nn.Module):
    def __init__(self, hidden, heads):
        super().__init__()
        self.query = nn.Linear(2 * hidden, hidden)
        self.attention = nn.MultiheadAttention(hidden, heads, dropout=0.0, batch_first=True)
        self.norm = nn.LayerNorm(hidden)

    def forward(self, nodes, action_nodes, features):
        queries = self.query(torch.cat((nodes[action_nodes], features), dim=-1))
        return self.norm(features + self.attention(queries, nodes, nodes, need_weights=False)[0])
