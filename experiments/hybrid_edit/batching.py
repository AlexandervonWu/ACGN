"""Sample-weighted accumulation with one clipped optimizer step per full batch."""

from contextlib import nullcontext
from dataclasses import dataclass

import torch
from torch.nn import functional as F

from experiments.hybrid_edit.model import optimal_set_loss


@dataclass(frozen=True)
class BatchPlan:
    effective_batch: int
    microbatch: int

    def __post_init__(self):
        if (type(self.effective_batch) is not int or type(self.microbatch) is not int
                or not 1 <= self.microbatch <= self.effective_batch <= 256):
            raise ValueError("Expected 1 <= microbatch <= effective batch <= 256")

    def slices(self):
        return tuple(slice(start, min(start + self.microbatch, self.effective_batch))
                     for start in range(0, self.effective_batch, self.microbatch))

    def chunk_sizes(self):
        return tuple(s.stop - s.start for s in self.slices())


BATCH_KEYS = ("tokens", "positions", "legal", "optimal", "family", "witness", "value")


def validate_batch(batch, plan):
    if set(batch) != set(BATCH_KEYS):
        raise ValueError("Incomplete or unknown batch fields")
    if any(not isinstance(x, torch.Tensor) or x.ndim < 1
           or x.shape[0] != plan.effective_batch for x in batch.values()):
        raise ValueError("Every batch field must contain the full effective batch")
    if len({x.device for x in batch.values()}) != 1:
        raise ValueError("Mixed-device batch")


def objective(model, batch):
    output = model(batch["tokens"], batch["positions"], batch["legal"])
    return (optimal_set_loss(output["action_logits"], batch["optimal"])
            + F.cross_entropy(output["family_logits"], batch["family"])
            + F.cross_entropy(output["witness_logits"], batch["witness"])
            + F.mse_loss(output["value"], batch["value"]))


def autocast_context(batch, amp):
    if amp and batch["tokens"].device.type != "cuda":
        raise ValueError("BF16 CUDA autocast requested on a non-CUDA batch")
    return torch.autocast("cuda", dtype=torch.bfloat16) if amp else nullcontext()


def accumulate_gradients(model, batch, plan, *, amp=False):
    model.zero_grad(set_to_none=True)
    try:
        validate_batch(batch, plan)
        losses = []
        for span in plan.slices():
            chunk = {key: tensor[span] for key, tensor in batch.items()}
            weight = (span.stop - span.start) / plan.effective_batch
            with autocast_context(chunk, amp):
                loss = objective(model, chunk)
            if not bool(torch.isfinite(loss)):
                raise ValueError("Nonfinite microbatch loss")
            (loss * weight).backward()
            losses.append(float(loss.detach()) * weight)
        return sum(losses)
    except BaseException:
        model.zero_grad(set_to_none=True)
        raise


def update_batch(model, optimizer, batch, plan, *, amp=False):
    try:
        loss = accumulate_gradients(model, batch, plan, amp=amp)
        for name, parameter in model.named_parameters():
            if parameter.grad is None or not bool(torch.isfinite(parameter.grad).all()):
                raise ValueError(f"Missing or nonfinite gradient: {name}")
        norm = torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0, error_if_nonfinite=True, foreach=False)
        optimizer.step()
        return {"loss": loss, "gradient_norm_before_clip": float(norm),
                "examples": plan.effective_batch, "chunk_sizes": plan.chunk_sizes()}
    except BaseException:
        # A failed optimizer step may have changed some weights; callers must
        # discard that run, never retry from an assumed untouched state.
        model.zero_grad(set_to_none=True)
        raise


@torch.no_grad()
def evaluate_batch(model, batch, plan, *, amp=False):
    validate_batch(batch, plan)
    training = model.training
    model.eval()
    try:
        total = 0.0
        for span in plan.slices():
            chunk = {key: tensor[span] for key, tensor in batch.items()}
            with autocast_context(chunk, amp):
                loss = objective(model, chunk)
            if not bool(torch.isfinite(loss)):
                raise ValueError("Nonfinite evaluation loss")
            total += float(loss) * (span.stop - span.start) / plan.effective_batch
        return total
    finally:
        model.train(training)
