"""Exact parameter accounting; CUDA telemetry is not a memory-safety proof."""

import torch


GIB = 1024 ** 3


class ResourceLimitError(RuntimeError):
    pass


def training_estimate(parameters, reserve=GIB):
    if type(parameters) is not int or parameters < 0 or type(reserve) is not int or reserve < 0:
        raise ValueError("Nonnegative integer memory inputs required")
    return 24 * parameters + reserve


def fits_budget(parameters, reserve, budget):
    if type(budget) is not int or budget < 0:
        raise ValueError("Nonnegative integer budget required")
    return training_estimate(parameters, reserve) <= budget


def apply_cuda_budget(device, family, width, depth, budget):
    snapshot = cuda_memory_snapshot(device)
    if snapshot is None:
        raise ValueError("A CUDA memory limit requires a CUDA device")
    count = expected_parameters(family, width, depth)
    if not fits_budget(count, GIB, budget):
        raise ResourceLimitError("Training estimate exceeds the configured CUDA budget")
    if budget + GIB > snapshot["deviceFreeBytes"]:
        raise ResourceLimitError("Insufficient free GPU memory for budget plus driver headroom")
    index = torch.device(device).index
    if index is None:
        index = torch.cuda.current_device()
    torch.cuda.set_per_process_memory_fraction(budget / snapshot["deviceTotalBytes"], index)
    return {"limitBytes": budget, "planningEstimateBytes": training_estimate(count),
            "deviceBeforeLimit": snapshot, "estimateIsPeakBound": False}


def expected_parameters(family, width, depth):
    if type(width) is not int or width < 1 or type(depth) is not int or depth < 1:
        raise ValueError("Positive integer width/depth required")
    if family == "egraph_transformer":
        return 11 * width * width + 4189 * width + 2 + depth * (18 * width * width + 25 * width)
    coefficients = {"mpnn": (8, 9, 0), "gcn": (2, 2, 0), "gat": (2, 5, 0), "gin": (5, 5, 1)}
    if family not in coefficients:
        raise ValueError("Unknown encoder")
    a, b, c = coefficients[family]
    return 5 * width * width + 4182 * width + 2 + depth * (a * width * width + b * width + c)


def capacity_statistics(policy):
    count = sum(p.numel() for p in policy.parameters())
    expected = expected_parameters(policy.encoder_name, policy.hidden, policy.layers)
    if count != expected:
        raise ValueError("Policy parameter layout differs from capacity contract")
    if any(p.dtype != torch.float32 for p in policy.parameters()):
        raise ValueError("Capacity contract expects the current FP32 policy")
    storage = sum(p.numel() * p.element_size() for p in policy.parameters())
    return {"parameterCount": count, "parameterBytes": storage,
            "nominalParameterGradientAdamBytes": storage * 4}


def cuda_memory_snapshot(device):
    device = torch.device(device)
    if device.type != "cuda":
        return None
    torch.cuda.synchronize(device)
    free, total = torch.cuda.mem_get_info(device)
    return {"allocatedBytes": torch.cuda.memory_allocated(device),
            "reservedBytes": torch.cuda.memory_reserved(device),
            "peakAllocatedBytes": torch.cuda.max_memory_allocated(device),
            "peakReservedBytes": torch.cuda.max_memory_reserved(device),
            "deviceFreeBytes": free, "deviceTotalBytes": total}
