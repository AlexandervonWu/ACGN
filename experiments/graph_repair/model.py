"""Causal graph-prefix / complete-program transformer, without menu heads."""
import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.checkpoint import checkpoint

from experiments.hybrid_edit.model import Block, Config, RMSNorm, HybridEditTransformer


def rotary_at(x, offset=0):
    dim = x.shape[-1]
    frequencies = 10000.0 ** (-torch.arange(0, dim, 2, device=x.device).float() / dim)
    angles = torch.arange(offset, offset+x.shape[-2], device=x.device).float()[:, None] * frequencies
    cosine, sine = angles.cos().to(x.dtype), angles.sin().to(x.dtype)
    even, odd = x[..., 0::2], x[..., 1::2]
    return torch.stack((even*cosine-odd*sine, even*sine+odd*cosine), -1).flatten(-2)


class GraphRepairTransformer(nn.Module):
    def __init__(self, config, checkpoint_blocks=True):
        super().__init__()
        self.config, self.checkpoint_blocks = config, checkpoint_blocks
        self.embedding = nn.Embedding(config.vocab, config.width)
        self.blocks = nn.ModuleList(Block(config) for _ in range(config.layers))
        self.norm = RMSNorm(config.width)
        self.apply(HybridEditTransformer._initialize)

    def forward(self, tokens):
        if tokens.ndim != 2 or not 1 <= tokens.shape[1] <= self.config.max_tokens:
            raise ValueError('CONTEXT_BOUND')
        x = self.embedding(tokens)
        for block in self.blocks:
            x = checkpoint(block, x, use_reentrant=False) if self.training and self.checkpoint_blocks else block(x)
        return F.linear(self.norm(x), self.embedding.weight)

    def cached(self, tokens, cache=None, valid=None):
        """Prefill a left-padded batch, then append one token per decoding step."""
        c = self.config
        batch, length = tokens.shape
        offset = 0 if cache is None else cache[0][0].shape[2]
        if not 1 <= length or length+offset > c.max_tokens or (cache is not None and length != 1):
            raise ValueError('CONTEXT_BOUND')
        if valid is None:
            valid = torch.ones((batch, offset+length), dtype=torch.bool, device=tokens.device)
        if valid.shape != (batch, offset+length): raise ValueError('CACHE_MASK')
        positions = torch.arange(length, device=tokens.device) + offset
        allowed = (torch.arange(offset+length, device=tokens.device)[None, :] <= positions[:, None])
        allowed = allowed[None, None] & valid[:, None, None, :]
        x, result = self.embedding(tokens), []
        for i, block in enumerate(self.blocks):
            normalized = block.pre_attention(x)
            q = rotary_at(block.q(normalized).view(batch,length,c.heads,c.head_dim).transpose(1,2),offset)
            k = rotary_at(block.k(normalized).view(batch,length,c.kv_heads,c.head_dim).transpose(1,2),offset)
            v = block.v(normalized).view(batch,length,c.kv_heads,c.head_dim).transpose(1,2)
            if cache is not None:
                k, v = torch.cat((cache[i][0],k),dim=2), torch.cat((cache[i][1],v),dim=2)
            result.append((k,v))
            attention = F.scaled_dot_product_attention(q,k.repeat_interleave(c.heads//c.kv_heads,1),
                v.repeat_interleave(c.heads//c.kv_heads,1),attn_mask=allowed,dropout_p=0.0)
            x = x+block.o(attention.transpose(1,2).reshape(batch,length,c.width))
            normalized = block.pre_ff(x)
            x = x+block.down(F.silu(block.gate(normalized))*block.up(normalized))
        return F.linear(self.norm(x[:, -1:]),self.embedding.weight)[:,0], result


def batch_tensors(records, device='cpu'):
    length = max(len(r['key'])+len(r['value'])-1 for r in records)
    tokens = torch.zeros((len(records),length), dtype=torch.long,device=device)
    targets = torch.full_like(tokens,-100)
    for i,r in enumerate(records):
        sequence = r['key']+r['value']
        tokens[i,:len(sequence)-1] = torch.tensor(sequence[:-1],device=device)
        start = len(r['key'])-1
        targets[i,start:len(sequence)-1] = torch.tensor(r['value'],device=device)
    return tokens,targets


def loss_sum(model, records, device='cpu'):
    tokens,targets = batch_tensors(records,device)
    logits = model(tokens)
    return F.cross_entropy(logits.float().flatten(0,1),targets.flatten(),ignore_index=-100,reduction='sum')
