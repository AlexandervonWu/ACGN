"""Resident reference QAT model. Low-bit forwards do not reduce master storage."""

from dataclasses import dataclass
import math

import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.checkpoint import checkpoint


@dataclass(frozen=True)
class Config:
    vocab: int = 4096
    width: int = 3072
    layers: int = 32
    heads: int = 24
    kv_heads: int = 8
    head_dim: int = 128
    ff: int = 8192
    weight_bits: int = 16
    group_size: int = 128
    max_tokens: int = 2048

    def __post_init__(self):
        if min(self.vocab, self.width, self.layers, self.heads, self.kv_heads,
               self.head_dim, self.ff, self.group_size, self.max_tokens) <= 0:
            raise ValueError("Architecture dimensions must be positive")
        if self.width != self.heads * self.head_dim or self.heads % self.kv_heads:
            raise ValueError("Invalid GQA dimensions")
        if self.head_dim % 2 or self.weight_bits not in (4, 8, 16):
            raise ValueError("Expected even rotary dimension and 4/8/16 weight bits")
        if self.width % self.group_size or self.ff % self.group_size:
            raise ValueError("Quantization groups must divide every linear input width")

    def quantized_parameters(self):
        return self.layers * (2 * self.width * self.heads * self.head_dim
                              + 2 * self.width * self.kv_heads * self.head_dim
                              + 3 * self.width * self.ff)

    def parameters(self):
        return (self.quantized_parameters() + self.vocab * self.width
                + 2 * self.layers * self.width + self.width
                + 2 * self.width * self.width + 12 * self.width)

    def packed_weight_bytes(self):
        """Proposed mixed packed checkpoint only; excludes all training state."""
        q = self.quantized_parameters()
        high = 2 * (self.parameters() - q)
        scales = 4 * (q // self.group_size) if self.weight_bits < 16 else 0
        return high + (q * self.weight_bits + 7) // 8 + scales


def candidates():
    return {f"l{layers}-w{bits}a16": Config(layers=layers, weight_bits=bits)
            for bits, depths in ((16, (16, 24, 32)), (8, (32, 40)), (4, (32, 40, 48)))
            for layers in depths}


def quantize_groups(weight, bits, group_size):
    if bits not in (4, 8) or weight.ndim != 2 or group_size <= 0:
        raise ValueError("Expected a matrix, positive group size, and 4/8 bits")
    if weight.shape[1] % group_size:
        raise ValueError("Incomplete groups require a separately specified padding codec")
    groups = weight.detach().float().reshape(weight.shape[0], -1, group_size)
    qmax = (1 << (bits - 1)) - 1
    maxima = groups.abs().amax(dim=-1, keepdim=True)
    scale = torch.where(maxima > 0, maxima / qmax, torch.ones_like(maxima))
    codes = torch.round(groups / scale).clamp(-qmax, qmax).to(torch.int8)
    return codes, scale


def fake_quant_weight(weight, bits, group_size):
    if bits == 16:
        return weight
    codes, scale = quantize_groups(weight, bits, group_size)
    rounded = (codes.float() * scale).reshape_as(weight).to(weight.dtype)
    # Identity STE is a chosen surrogate, not the derivative of rounding.
    return weight + (rounded - weight).detach()


def pack_nibbles(codes):
    if codes.dtype != torch.uint8 or codes.ndim != 1 or bool((codes > 15).any()):
        raise ValueError("Expected a vector of unsigned four-bit codes")
    if codes.numel() % 2:
        codes = F.pad(codes, (0, 1))
    return codes[0::2] | (codes[1::2] << 4)


def unpack_nibbles(packed, length):
    if (packed.dtype != torch.uint8 or packed.ndim != 1 or length < 0
            or packed.numel() != (length + 1) // 2):
        raise ValueError("Packed vector length mismatch")
    if length % 2 and int(packed[-1]) >= 16:
        raise ValueError("Noncanonical nonzero padding nibble")
    return torch.stack((packed & 15, packed >> 4), dim=-1).flatten()[:length]


class QLinear(nn.Linear):
    def __init__(self, inputs, outputs, config):
        super().__init__(inputs, outputs, bias=False)
        self.bits = config.weight_bits
        self.group_size = config.group_size

    def forward(self, x):
        return F.linear(x, fake_quant_weight(self.weight, self.bits, self.group_size))


class RMSNorm(nn.Module):
    def __init__(self, width):
        super().__init__()
        self.weight = nn.Parameter(torch.ones(width))

    def forward(self, x):
        values = x.float()
        normalized = values * torch.rsqrt(values.square().mean(dim=-1, keepdim=True) + 1e-6)
        return normalized.to(x.dtype) * self.weight.to(x.dtype)


def rotary(x):
    dim = x.shape[-1]
    inv_freq = 10000.0 ** (-torch.arange(0, dim, 2, device=x.device).float() / dim)
    angles = torch.arange(x.shape[-2], device=x.device).float()[:, None] * inv_freq
    cosine, sine = angles.cos().to(x.dtype), angles.sin().to(x.dtype)
    even, odd = x[..., 0::2], x[..., 1::2]
    return torch.stack((even * cosine - odd * sine, even * sine + odd * cosine), -1).flatten(-2)


class Block(nn.Module):
    def __init__(self, config):
        super().__init__()
        self.config = config
        self.pre_attention = RMSNorm(config.width)
        self.pre_ff = RMSNorm(config.width)
        self.q = QLinear(config.width, config.heads * config.head_dim, config)
        self.k = QLinear(config.width, config.kv_heads * config.head_dim, config)
        self.v = QLinear(config.width, config.kv_heads * config.head_dim, config)
        self.o = QLinear(config.width, config.width, config)
        self.gate = QLinear(config.width, config.ff, config)
        self.up = QLinear(config.width, config.ff, config)
        self.down = QLinear(config.ff, config.width, config)

    def forward(self, x):
        c = self.config
        batch, length, _ = x.shape
        normalized = self.pre_attention(x)
        q = rotary(self.q(normalized).view(batch, length, c.heads, c.head_dim).transpose(1, 2))
        k = rotary(self.k(normalized).view(batch, length, c.kv_heads, c.head_dim).transpose(1, 2))
        v = self.v(normalized).view(batch, length, c.kv_heads, c.head_dim).transpose(1, 2)
        k = k.repeat_interleave(c.heads // c.kv_heads, dim=1)
        v = v.repeat_interleave(c.heads // c.kv_heads, dim=1)
        attention = F.scaled_dot_product_attention(q, k, v, dropout_p=0.0, is_causal=True)
        x = x + self.o(attention.transpose(1, 2).reshape(batch, length, c.width))
        normalized = self.pre_ff(x)
        return x + self.down(F.silu(self.gate(normalized)) * self.up(normalized))


class HybridEditTransformer(nn.Module):
    def __init__(self, config, checkpoint_blocks=False):
        super().__init__()
        self.config = config
        self.checkpoint_blocks = checkpoint_blocks
        self.embedding = nn.Embedding(config.vocab, config.width)
        self.blocks = nn.ModuleList(Block(config) for _ in range(config.layers))
        self.norm = RMSNorm(config.width)
        self.query = nn.Linear(config.width, config.width, bias=False)
        self.action_key = nn.Linear(config.width, config.width, bias=False)
        self.family = nn.Linear(config.width, 9, bias=False)
        self.witness = nn.Linear(config.width, 2, bias=False)
        self.value = nn.Linear(config.width, 1, bias=False)
        self.apply(self._initialize)

    @staticmethod
    def _initialize(module):
        if isinstance(module, (nn.Linear, nn.Embedding)):
            nn.init.normal_(module.weight, mean=0.0, std=0.02)

    def encode(self, tokens):
        if tokens.ndim != 2 or not 1 <= tokens.shape[1] <= self.config.max_tokens:
            raise ValueError("Packets must fit the context exactly; no silent truncation")
        x = self.embedding(tokens)
        for block in self.blocks:
            x = checkpoint(block, x, use_reentrant=False) if (
                self.checkpoint_blocks and self.training) else block(x)
        return self.norm(x)

    def forward(self, tokens, action_positions, legal):
        if (action_positions.ndim != 2 or action_positions.dtype != torch.long
                or legal.dtype != torch.bool or legal.shape != action_positions.shape
                or action_positions.shape[0] != tokens.shape[0]):
            raise ValueError("Invalid action pointer/mask shape or dtype")
        if not bool(legal.any(dim=1).all()):
            raise ValueError("Empty legal menu requires controller abstention")
        if bool(((action_positions < 0) | (action_positions >= tokens.shape[1] - 1)).any()):
            raise ValueError("Every action must precede the final QUERY token")
        hidden = self.encode(tokens)
        action_hidden = hidden.gather(1, action_positions[..., None].expand(-1, -1, self.config.width))
        query = hidden[:, -1]
        logits = (self.query(query).float()[:, None] * self.action_key(action_hidden).float()).sum(-1)
        logits = logits / math.sqrt(self.config.width)
        if not bool(torch.isfinite(logits[legal]).all()):
            raise ValueError("Nonfinite policy scores require controller abstention")
        return {"action_logits": logits.masked_fill(~legal, -torch.inf),
                "family_logits": self.family(query).float(),
                "witness_logits": self.witness(query).float(),
                "value": self.value(query).float().squeeze(-1)}

    def token_logits(self, hidden):
        return F.linear(hidden, self.embedding.weight)


def optimal_set_loss(logits, optimal):
    if optimal.dtype != torch.bool or optimal.shape != logits.shape or logits.ndim != 2:
        raise ValueError("Expected matching batched target masks")
    if not bool(optimal.any(dim=1).all()) or not bool(torch.isfinite(logits[optimal]).all()):
        raise ValueError("Targets must be a nonempty subset of legal actions")
    if bool(torch.isnan(logits).any()) or bool(torch.isposinf(logits).any()):
        raise ValueError("Invalid policy logits")
    return (torch.logsumexp(logits, -1)
            - torch.logsumexp(logits.masked_fill(~optimal, -torch.inf), -1)).mean()
