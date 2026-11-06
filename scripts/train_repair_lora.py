#!/usr/bin/env python3
"""Bounded pilot wrapper around the existing AIx streamed-prefix trainer."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import runpy
import sys


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dataset',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    records=[json.loads(line) for line in args.dataset.read_text().splitlines()]
    if not 1 <= len(records) <= 32 or len({r['id'] for r in records}) != len(records):
        raise ValueError('Expected 1..32 distinct pilot training rows')
    metadata=json.loads(args.dataset.with_name('manifest.json').read_text())
    name=args.dataset.stem
    if metadata['status']!='COMPLETE' or metadata['datasetHashes'].get(name)!=hashlib.sha256(args.dataset.read_bytes()).hexdigest():
        raise ValueError('Dataset is not bound to a completed admission manifest')
    allowed=set(metadata['trainTasks'])
    if any(r['id'].removesuffix('-ce') not in allowed for r in records):
        raise ValueError('Non-training task in dataset')
    os.environ.setdefault('HF_HUB_OFFLINE','1')
    os.environ.setdefault('PYTORCH_CUDA_ALLOC_CONF','expandable_segments:True')
    import torch
    if not torch.cuda.is_available():
        raise RuntimeError('CUDA is required')
    torch.cuda.set_per_process_memory_fraction(13*1024**3/torch.cuda.get_device_properties(0).total_memory)
    from torch.utils.checkpoint import checkpoint
    # Check the detached-input case used at the frozen-prefix / trainable-suffix boundary.
    torch.manual_seed(801)
    x=torch.randn(5,7,device='cuda')
    weight=torch.randn(7,3,device='cuda',requires_grad=True)
    def layer(value):
        return (value @ weight).tanh()
    direct=layer(x).square().sum()
    expected,=torch.autograd.grad(direct,weight)
    repeated=checkpoint(layer,x,use_reentrant=False).square().sum()
    actual,=torch.autograd.grad(repeated,weight)
    torch.testing.assert_close(repeated,direct,atol=0,rtol=0)
    torch.testing.assert_close(actual,expected,atol=0,rtol=0)
    del x,weight,direct,repeated,expected,actual
    import peft
    original=peft.get_peft_model
    def checkpointed_model(*a,**kw):
        model=original(*a,**kw)
        model.gradient_checkpointing_enable(gradient_checkpointing_kwargs={'use_reentrant':False})
        layers=model.base_model.model.model.language_model.layers
        for index,decoder in enumerate(layers):
            decoder.gradient_checkpointing=index >= len(layers)-4
        return model
    peft.get_peft_model=checkpointed_model
    aix=Path('/home/augustus/AIx')
    runner=aix/'scripts/train_distillation_offload.py'
    base=aix/'.local/hf-training/models--unsloth--Qwen3.8-27B-unsloth-bnb-4bit/snapshots/8aa5f05d26b7205477066e1449e0af13f762a299'
    sys.path.insert(0,str(runner.parent))
    sys.argv=[str(runner),'--base',str(base),'--dataset',str(args.dataset.resolve()),
              '--output',str(args.output.resolve()),'--probe',str(len(records)),
              '--epochs','1','--last-layers','4','--resident-frozen-layers','16',
              '--rank','8','--learning-rate','0.0002','--max-length','4096',
              '--checkpoint-every','4','--seed','801']
    metadata_path=args.output.with_name(args.output.name+'-wrapper.json')
    metadata_path.write_text(json.dumps(dict(wrapperHash=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        checkpointing='last four resident decoder layers; use_reentrant=False; frozen prefix disabled',
        detachedInputCheckpointGradientTest='exact equality on the recorded CUDA toy test',
        cudaAllocationCapGiB=13,upstreamRunner=str(runner)),indent=2)+'\n')
    try:
        runpy.run_path(str(runner),run_name='__main__')
    finally:
        peft.get_peft_model=original


if __name__=='__main__':
    main()
