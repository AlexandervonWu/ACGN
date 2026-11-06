"""Message-passing actor/critic. Feature hashes are features, never identities."""

import hashlib
import torch
from torch import nn
from .proof_gate import CheckedRollout, contract_hash
from .encoders import ENCODERS, graph_contract_hash, make_encoder, message_schedule
from .transformer import GraphEditDecoder, LATENT_SLOTS, graph_request, transformer_contract_hash


SCHEMA = "repair-structured-graphs-v1"
BUCKETS = 4096


def bucket(namespace, value):
    raw = (namespace + ":" + value).encode("utf-8")
    return int.from_bytes(hashlib.sha256(raw).digest()[:8], "big") % BUCKETS


class StructuredPolicy(nn.Module):
    def __init__(self, hidden=64, layers=2, encoder="mpnn", heads=4):
        super().__init__()
        if type(hidden) is not int or hidden < 1 or type(layers) is not int or layers < 1 or encoder not in ENCODERS:
            raise ValueError("Invalid policy architecture")
        if type(heads) is not int or heads < 1 or (encoder in ("gat", "egraph_transformer") and hidden % heads):
            raise ValueError("GAT hidden width must be divisible by a positive head count")
        self.hidden = hidden
        self.layers = layers
        self.encoder_name = encoder
        self.heads = heads if encoder in ("gat", "egraph_transformer") else 1
        if encoder == "egraph_transformer" and not (8 <= hidden <= 16384 and heads <= 16 and layers <= 8):
            raise ValueError("Graph transformer architecture exceeds contract")
        self.generation = 0
        self.symbols = nn.Embedding(BUCKETS, hidden)
        self.positions = nn.Embedding(66, hidden)
        self.node_numeric = nn.Linear(3, hidden)
        self.encoder = make_encoder(encoder, hidden, layers, self.heads)
        self.context = nn.Sequential(nn.Linear(hidden + 8, hidden), nn.Tanh())
        self.action_numeric = nn.Linear(2, hidden)
        self.actor = nn.Sequential(nn.Linear(hidden * 3, hidden), nn.Tanh(), nn.Linear(hidden, 1))
        self.critic = nn.Sequential(nn.Linear(hidden, hidden), nn.Tanh(), nn.Linear(hidden, 1))
        if encoder == "egraph_transformer":
            self.decoder = GraphEditDecoder(hidden, self.heads)

    def architecture(self):
        result = {"hidden": self.hidden, "layers": self.layers, "schema": SCHEMA,
                "encoder": self.encoder_name, "heads": self.heads, "architectureVersion": 2,
                "graphContractHash": graph_contract_hash(),
                "contractHash": contract_hash()}
        if self.encoder_name == "egraph_transformer":
            result.update(architectureVersion=3, latentSlots=LATENT_SLOTS,
                          transformerContractHash=transformer_contract_hash())
        return result

    def forward(self, observation, allowed=None):
        if observation["schema"] != SCHEMA:
            raise ValueError("Incompatible structured observation schema")
        device = self.symbols.weight.device
        nodes = observation["nodes"]
        actions = observation["actions"]
        if self.encoder_name == "egraph_transformer":
            graph_request(observation, self.architecture(), allowed)
        if not 0 < len(nodes) <= 4096 or not 0 < len(actions) <= 512:
            raise ValueError("Observation/menu bound violated")
        categories = torch.tensor([[bucket(str(i), v) for i, v in enumerate(n["categories"])]
                                   for n in nodes], device=device, dtype=torch.long)
        numbers = torch.tensor([n["numeric"] for n in nodes], device=device, dtype=torch.float32)
        h = self.symbols(categories).sum(dim=1) + self.node_numeric(numbers)
        edges = message_schedule(len(nodes), observation["edges"], self.encoder.self_loops)
        src = torch.tensor([e[0] for e in edges], device=device, dtype=torch.long)
        dst = torch.tensor([e[1] for e in edges], device=device, dtype=torch.long)
        kinds = torch.tensor([bucket("edge", e[2]) for e in edges], device=device, dtype=torch.long)
        positions = torch.tensor([min(e[3], 65) for e in edges], device=device, dtype=torch.long)
        edge_features = self.symbols(kinds) + self.positions(positions)
        h = self.encoder(h, src, dst, edge_features)
        numeric = torch.tensor(observation["numeric"], device=device, dtype=torch.float32)
        context = self.context(torch.cat((h.mean(dim=0), numeric)))
        action_nodes = torch.tensor([a["node"] for a in actions], device=device)
        if int(action_nodes.min()) < 0 or int(action_nodes.max()) >= len(nodes):
            raise ValueError("Action occurrence missing")
        action_symbols = torch.tensor([[bucket("action-kind", a["kind"]), bucket("action-op", a["operation"].upper())]
                                       for a in actions], device=device)
        action_numbers = torch.tensor([a["numeric"] for a in actions], device=device, dtype=torch.float32)
        features = self.symbols(action_symbols).sum(dim=1) + self.action_numeric(action_numbers)
        if self.encoder_name == "egraph_transformer":
            features = self.decoder(h, action_nodes, features)
        logits = self.actor(torch.cat((h[action_nodes], features, context.expand(len(actions), -1)), dim=1)).squeeze(-1)
        if allowed is not None:
            mask = torch.as_tensor(allowed, dtype=torch.bool, device=device)
            if mask.shape != logits.shape or not bool(mask.any()):
                raise ValueError("Empty or malformed action mask")
            logits = logits.masked_fill(~mask, -torch.inf)
        return logits, self.critic(context).squeeze(-1)


def update_policy(policy, optimizer, trajectory, checked: CheckedRollout, entropy_weight=0.01):
    """One complete, uncensored on-policy segment; terminal bootstrap is zero."""
    if not trajectory or not isinstance(checked, CheckedRollout):
        raise ValueError("A nonempty Lean-checked rollout is required")
    checked.require_matches([x[3] for x in trajectory], policy.generation)
    log_probs = torch.stack([x[0] for x in trajectory])
    values = torch.stack([x[1] for x in trajectory])
    entropies = torch.stack([x[2] for x in trajectory])
    target = values.new_tensor(checked.returns) / 1000.0
    advantages = target - values.detach()
    actor = -(log_probs * advantages).mean()
    critic = (values - target).square().mean()
    loss = actor + 0.5 * critic - entropy_weight * entropies.mean()
    if not bool(torch.isfinite(loss)):
        raise ValueError("Non-finite objective")
    optimizer.zero_grad(set_to_none=True)
    loss.backward()
    norm = torch.nn.utils.clip_grad_norm_(policy.parameters(), 1.0, error_if_nonfinite=True)
    optimizer.step()
    policy.generation += 1
    return {"loss": float(loss.detach()), "actor": float(actor.detach()),
            "critic": float(critic.detach()), "gradientNorm": float(norm), "steps": len(trajectory),
            "proofContract": checked.contract, "checkedRequest": checked.request_hash}
